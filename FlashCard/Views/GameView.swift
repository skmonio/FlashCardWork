import SwiftUI
import SpriteKit

struct Card: Identifiable {
    let id = UUID()
    let content: String
    let type: CardType
    let originalCard: FlashCard
    var isMatched = false
    var isSelected = false
    var showWrongAnimation = false
    
    enum CardType {
        case word
        case definition
    }
}

struct GameView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let difficulty: MemoryGameDifficulty
    @Environment(\.dismiss) private var dismiss
    @State private var gameCards: [Card] = []
    @State private var displayedCards: [Card] = []
    @State private var remainingCards: [Card] = []
    @State private var selectedCard: Card?
    @State private var score = 0
    @State private var moves = 0
    @State private var showingGameOver = false
    @State private var incorrectMatches: Set<FlashCard> = []
    @State private var showingCloseConfirmation = false
    @State private var showingResults = false
    @State private var comboCount = 0
    @State private var consecutiveMatches = 0
    
    // Timer for Match Madness style
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var gameStartTime: Date?
    
    // Progressive study properties
    private var studyMode: StudyMode?
    private var onLevelComplete: ((LevelResult) -> Void)?
    private var maxQuestions: Int?
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Add user profile manager for XP tracking
    @StateObject private var userProfileManager = UserProfileManager.shared
    
    // Session XP tracking
    @State private var sessionXP: Int = 0 // Track XP gained during current session
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return moves > 0 || score > 0
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], difficulty: MemoryGameDifficulty, deckIds: [UUID] = [], shouldLoadSaveState: Bool = false, studyMode: StudyMode? = nil, maxQuestions: Int? = nil, onLevelComplete: ((LevelResult) -> Void)? = nil) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        self.cards = viewModel.sortCardsForLearning(cards)
        self.difficulty = difficulty
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
        self.studyMode = studyMode
        self.maxQuestions = maxQuestions
        self.onLevelComplete = onLevelComplete
    }

    var body: some View {
        VStack(spacing: 0) {
            if cards.isEmpty {
                emptyStateView
            } else if showingResults {
                resultsView
            } else {
                gameView
            }
            
            // Bottom close button (only show when not in results screen)
            if !showingResults {
                HStack {
                    Spacer()
                    Button(action: {
                        if hasSignificantProgress && !showingResults {
                            showingCloseConfirmation = true
                        } else {
                            dismissToRoot()
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .padding(12)
                            .background(Circle().fill(Color(.systemGray5)))
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
                .background(Color(.systemBackground))
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    handleBackButton()
                }
            }
        }
        .navigationTitle("Remember Your Cards")
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
            // Dismiss this view when dismiss to root is requested
            dismiss()
        }
        .onAppear {
            print("🧠 GameView appeared - initializing SpriteKit scene")
            
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                setupGame()
            }
        }
        .onDisappear {
            // Stop timer when view disappears
            stopTimer()
            
            // Auto-save when view disappears (if user navigates away without using back button)
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
        .alert("Close Game?", isPresented: $showingCloseConfirmation) {
            Button("Save & Close", role: .destructive) {
                saveProgressAndDismiss()
            }
            Button("Close Without Saving") {
                dismissToRoot()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(hasSignificantProgress ? 
                "Would you like to save your progress?" : 
                "Are you sure you want to close?")
        }
    }
    
    private func handleBackButton() {
        if hasSignificantProgress && !showingResults {
            showingCloseConfirmation = true
        } else {
            dismiss()
        }
    }
    
    private func saveCurrentProgress() {
        guard hasSignificantProgress else { return }
        
        let savedCards = gameCards.map { card in
            MemoryGameState.SavedCard(
                id: card.id,
                content: card.content,
                cardType: card.type == .word ? "word" : "definition",
                originalCardId: card.originalCard.id,
                isMatched: card.isMatched,
                isSelected: card.isSelected
            )
        }
        
        let displayedSavedCards = displayedCards.map { card in
            MemoryGameState.SavedCard(
                id: card.id,
                content: card.content,
                cardType: card.type == .word ? "word" : "definition",
                originalCardId: card.originalCard.id,
                isMatched: card.isMatched,
                isSelected: card.isSelected
            )
        }
        
        let remainingSavedCards = remainingCards.map { card in
            MemoryGameState.SavedCard(
                id: card.id,
                content: card.content,
                cardType: card.type == .word ? "word" : "definition",
                originalCardId: card.originalCard.id,
                isMatched: card.isMatched,
                isSelected: card.isSelected
            )
        }
        
        let gameState = MemoryGameState(
            gameCards: savedCards,
            displayedCards: displayedSavedCards,
            remainingCards: remainingSavedCards,
            selectedCardId: selectedCard?.id,
            score: score,
            moves: moves,
            incorrectMatches: Set(incorrectMatches.map { $0.id })
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .memoryGame,
            gameData: gameState
        )
        
        print("💾 Memory game progress saved - Score: \(score), Moves: \(moves)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .memoryGame,
            as: MemoryGameState.self
        ) {
            // Helper function to convert saved cards back to Card objects
            func convertSavedCard(_ savedCard: MemoryGameState.SavedCard) -> Card? {
                guard let originalCard = cards.first(where: { $0.id == savedCard.originalCardId }) else {
                    return nil
                }
                
                var card = Card(
                    content: savedCard.content,
                    type: savedCard.cardType == "word" ? .word : .definition,
                    originalCard: originalCard
                )
                card.isMatched = savedCard.isMatched
                card.isSelected = savedCard.isSelected
                
                return card
            }
            
            // Restore game state
            score = savedState.score
            moves = savedState.moves
            
            // Convert saved cards back to Card objects
            gameCards = savedState.gameCards.compactMap(convertSavedCard)
            displayedCards = savedState.displayedCards.compactMap(convertSavedCard)
            remainingCards = savedState.remainingCards.compactMap(convertSavedCard)
            
            // Restore selected card
            if let selectedId = savedState.selectedCardId {
                selectedCard = displayedCards.first { $0.id == selectedId }
            }
            
            // Restore incorrect matches
            incorrectMatches = Set(savedState.incorrectMatches.compactMap { cardId in
                cards.first { $0.id == cardId }
            })
            
            // Set up timer for saved game
            let timePerCardSet = difficulty.timePerCardSet
            timeRemaining = displayedCards.count * timePerCardSet
            
            // Start timer
            startTimer()
            
            print("🧠 Memory game progress loaded - Score: \(score), Moves: \(moves)")
        } else {
            // No saved state found, start normally
            print("🧠 No saved state found, starting fresh memory game")
            setupGame()
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .memoryGame)
    }
    
    private func saveProgressAndDismiss() {
        if hasSignificantProgress && !showingResults {
            saveCurrentProgress()
        }
        dismissToRoot()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to play")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
        }
    }
    
    private var gameView: some View {
        ZStack {
            VStack(spacing: 0) {
                // Time bar instead of progress bar
                VStack(spacing: 8) {
                    HStack {
                        Text("Match Madness")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // Show progress indicator for progressive study
                        if maxQuestions != nil {
                            let totalPairs = gameCards.count / 2
                            Text("\(score)/\(totalPairs)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.blue.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.blue, lineWidth: 1)
                                        )
                                )
                        }
                        
                        Text(timeString)
                            .font(.headline)
                            .foregroundColor(timeRemaining <= 10 ? .red : .primary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Time bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background bar
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                            
                            // Progress bar (time remaining) - grows from left to right
                            RoundedRectangle(cornerRadius: 8)
                                .fill(timeBarColor)
                                .frame(width: timeBarWidth(geometry), height: 8)
                                .animation(.linear(duration: 1.0), value: timeRemaining)
                        }
                    }
                    .frame(height: 8)
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
                
                // Game grid with proper centering
                VStack {
                    Spacer()
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(0..<10, id: \.self) { index in
                            if index < displayedCards.count {
                                MemoryGameCardView(card: displayedCards[index]) {
                                    cardTapped(displayedCards[index])
                                }
                                .opacity(displayedCards[index].isMatched ? 0 : 1)
                                .animation(.easeInOut(duration: 0.3), value: displayedCards[index].isMatched)
                            } else {
                                // Empty space to maintain grid layout
                                Color.clear
                                    .frame(height: 70)
                            }
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func setupGame() {
        // For progressive study, always use 10 pairs (20 cards) per level
        let cardsToUse: [FlashCard]
        if let maxQuestions = maxQuestions {
            // Always use 10 pairs (20 cards) for progressive study
            let targetPairs = 10
            let availableCards = Array(cards.prefix(targetPairs))
            cardsToUse = availableCards
            print("🧠 Progressive Memory: using \(availableCards.count) cards for \(targetPairs) pairs")
        } else {
            cardsToUse = cards
        }

        // Create pairs (word + definition) for each selected card
        gameCards = cardsToUse.flatMap { card in
            [
                Card(content: card.word, type: .word, originalCard: card),
                Card(content: card.definition, type: .definition, originalCard: card)
            ]
        }
        print("🧠 Created \(gameCards.count) game cards (\(gameCards.count / 2) pairs)")

        // Shuffle the cards
        gameCards.shuffle()

        // Show first 10 cards (5 pairs) initially
        displayedCards = Array(gameCards.prefix(10))
        remainingCards = Array(gameCards.dropFirst(10))
        print("🧠 Showing first 5 pairs (\(displayedCards.count) cards), \(remainingCards.count) remaining")

        // Reset game state
        score = 0
        moves = 0
        incorrectMatches.removeAll()
        consecutiveMatches = 0
        comboCount = 0
        selectedCard = nil

        // Set up timer based on difficulty and number of cards
        let timePerCardSet = difficulty.timePerCardSet
        timeRemaining = gameCards.count * timePerCardSet

        // Start timer
        startTimer()
    }
    
    private func startTimer() {
        gameStartTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                // Time's up!
                timer?.invalidate()
                timer = nil
                showingResults = true
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func replaceMatchedCards() {
        // Find indices of matched cards
        let matchedIndices = displayedCards.enumerated().compactMap { index, card in
            card.isMatched ? index : nil
        }
        
        // Remove matched cards and add new ones from remaining cards
        for index in matchedIndices.sorted(by: >) {
            if !remainingCards.isEmpty {
                // Replace matched card with new card from remaining cards
                let newCard = remainingCards.removeFirst()
                displayedCards[index] = newCard
                print("🧠 Replaced matched card at index \(index) with new card: \(newCard.content)")
            } else {
                // No more cards to add, remove the matched card
                displayedCards.remove(at: index)
                print("🧠 Removed matched card at index \(index) - no more cards remaining")
            }
        }
        
        // Check if game is complete (no more cards to play)
        if remainingCards.isEmpty && displayedCards.allSatisfy({ $0.isMatched }) {
            // Stop the timer
            stopTimer()
            
            // Clear saved progress since game is complete
            clearSavedProgress()
            
            // Call level completion callback if this is a progressive study session
            if let onLevelComplete = onLevelComplete {
                let levelNumber: Int
                switch studyMode {
                case .maintenance: levelNumber = 1
                case .cram: levelNumber = 2
                case .adaptive: levelNumber = 3
                default: levelNumber = 1
                }
                
                let result = LevelResult(
                    level: levelNumber,
                    score: score,
                    total: maxQuestions ?? cards.count
                )
                onLevelComplete(result)
            } else {
                StreakManager.shared.recordGameCompletion()
                showingResults = true
            }
        }
    }
    
    private func cardTapped(_ tappedCard: Card) {
        guard let index = displayedCards.firstIndex(where: { $0.id == tappedCard.id }) else { return }
        
        // Ignore tapped card if it's already matched or if two cards are already selected
        if displayedCards[index].isMatched || 
           displayedCards.filter({ $0.isSelected }).count >= 2 {
            return
        }
        
        // If this card is already selected (first card), deselect it
        if displayedCards[index].isSelected {
            displayedCards[index].isSelected = false
            selectedCard = nil
            return
        }
        
        // If this is the first card of the pair
        if selectedCard == nil {
            displayedCards[index].isSelected = true
            selectedCard = displayedCards[index]
            return
        }
        
        // This is the second card
        moves += 1
        
        // Auto-save progress periodically (every 10 moves)
        if moves % 10 == 0 {
            saveCurrentProgress()
        }
        
        if let selectedIndex = displayedCards.firstIndex(where: { $0.id == selectedCard?.id }) {
            if selectedCard?.originalCard.id == tappedCard.originalCard.id &&
               selectedCard?.type != tappedCard.type {
                // It's a match! 
                score += 1
                consecutiveMatches += 1
                
                // Add XP for successful match
                userProfileManager.addXP(10)
                sessionXP += 10
                
                // Update combo count (after 2 consecutive matches)
                if consecutiveMatches >= 2 {
                    comboCount = consecutiveMatches
                }
                
                displayedCards[index].isSelected = true
                
                // After a brief delay, mark them as matched
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // Clear selection and set matched state
                    displayedCards[selectedIndex].isSelected = false
                    displayedCards[index].isSelected = false
                    displayedCards[selectedIndex].isMatched = true
                    displayedCards[index].isMatched = true
                    
                    // Record successful match as correct answer
                    viewModel.recordCardShown(tappedCard.originalCard.id, isCorrect: true)
                    
                    // Replace matched cards after fade out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        replaceMatchedCards()
                    }
                }
            } else {
                // Not a match
                displayedCards[index].showWrongAnimation = true
                
                // Reset combo on mismatch
                consecutiveMatches = 0
                comboCount = 0
                
                // Track incorrect matches
                incorrectMatches.insert(selectedCard!.originalCard)
                incorrectMatches.insert(tappedCard.originalCard)
                
                // Record incorrect match
                viewModel.recordCardShown(tappedCard.originalCard.id, isCorrect: false)
                
                // Reset both cards after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    displayedCards[selectedIndex].isSelected = false
                    displayedCards[index].showWrongAnimation = false
                }
            }
            
            // Reset selected card
            selectedCard = nil
        }
    }
    
    private func dismissToRoot() {
        // Send notification to dismiss all views
        NotificationCenter.default.post(name: NSNotification.Name("DismissToRoot"), object: nil)
        
        // Also trigger ViewModel navigation
        viewModel.navigateToRoot()
        
        // Fallback with multiple dismissals
        dismiss()
        for i in 1...8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                dismiss()
            }
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 20) {
            // Determine result type based on performance
            let resultType = determineResultType()
            
            switch resultType {
            case .victory:
                // Victory - completed all matches with time remaining
                Image(systemName: "trophy.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.yellow)
                
                Text("Victory! 🏆")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Perfect match! You completed all pairs!")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Time remaining: \(timeString)")
                    .font(.headline)
                    .foregroundColor(.green)
                
            case .almost:
                // Almost - completed most matches but ran out of time
                Image(systemName: "hand.thumbsup.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Almost There! 👍")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Great effort! You matched \(score) out of \(totalPairs) pairs")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Try again to get them all!")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                
            case .timeUp:
                // Time's up - completed very few matches
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Time's Up! ⏰")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("You matched \(score) out of \(totalPairs) pairs")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Keep practicing to improve!")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
            
            // Show moves and score info
            VStack(spacing: 8) {
                Text("Moves: \(moves)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if score > 0 {
                    Text("Score: \(score) pairs")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
            
            VStack(spacing: 16) {
                Button(action: {
                    // Explicitly save all ViewModel data to ensure statistics persist
                    viewModel.saveAllData()
                    
                    // Force UI refresh
                    DispatchQueue.main.async {
                        viewModel.objectWillChange.send()
                    }
                    
                    // Reset the game state and start a new game with the same cards
                    showingResults = false
                    setupGame()
                }) {
                    Text("Play Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.top)
        }
        .padding()
    }
    
    // MARK: - Result Type Enum
    private enum ResultType {
        case victory
        case almost
        case timeUp
    }
    
    // MARK: - Helper Properties
    private var totalPairs: Int {
        return displayedCards.count / 2
    }
    
    // MARK: - Helper Methods
    private func determineResultType() -> ResultType {
        // Check if all pairs are matched (victory condition)
        let allPairsMatched = displayedCards.allSatisfy { $0.isMatched }
        
        if allPairsMatched {
            // All pairs matched - this is victory regardless of time
            return .victory
        } else {
            // Time ran out - determine performance level
            let completionPercentage = Double(score) / Double(totalPairs)
            
            if completionPercentage >= 0.7 {
                // Completed 70% or more - "Almost There"
                return .almost
            } else {
                // Completed less than 70% - "Time's Up"
                return .timeUp
            }
        }
    }
    
    private var timeBarWidth: (GeometryProxy) -> CGFloat {
        return { geometry in
            let totalTime = displayedCards.count * difficulty.timePerCardSet
            let elapsedTime = totalTime - timeRemaining
            let progressRatio = CGFloat(elapsedTime) / CGFloat(totalTime)
            return geometry.size.width * progressRatio
        }
    }
    
    private var timeBarColor: Color {
        if timeRemaining <= 10 {
            return .red
        } else if timeRemaining <= 30 {
            return .orange
        } else {
            return .blue
        }
    }
}

struct MemoryGameCardView: View {
    let card: Card
    let action: () -> Void
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .shadow(color: cardBorderColor.opacity(0.2), radius: 3, x: 0, y: 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(cardBorderColor.opacity(0.3), lineWidth: 1)
                    )
                
                if !card.isMatched {
                    Text(card.content)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .opacity(card.isMatched ? 0 : 1)
                }
            }
        }
        .frame(height: 70)
        .scaleEffect(card.isSelected ? 1.05 : 1.0)
        .offset(y: floatingOffset)
        .animation(.easeInOut(duration: 0.2), value: card.isSelected)
        .animation(.easeInOut(duration: 0.2), value: card.showWrongAnimation)
        .animation(.easeInOut(duration: 0.3), value: card.isMatched)
        .onAppear {
            // Start subtle floating animation
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                floatingOffset = -2
            }
        }
    }
    
    private var backgroundColor: Color {
        if card.isMatched {
            return .green.opacity(0.2) // Green for matched cards
        } else if card.isSelected {
            return Color.blue.opacity(0.15) // Light blue for selected cards
        } else if card.showWrongAnimation {
            return .red.opacity(0.1) // Very light red for wrong animation
        } else {
            return Color(.systemBackground) // No background color
        }
    }
    
    private var cardBorderColor: Color {
        if card.isMatched {
            return .green // Green border for matched cards
        } else if card.isSelected {
            return .blue // Blue border for selected cards
        } else if card.showWrongAnimation {
            return .red // Red border for wrong animation
        } else {
            // Generate consistent color based on card content
            let vibrantColors: [Color] = [
                Color(red: 1.0, green: 0.4, blue: 0.2),    // Coral/Orange-Red
                Color(red: 1.0, green: 0.6, blue: 0.0),    // Bright Orange
                Color(red: 1.0, green: 0.8, blue: 0.0),    // Golden Yellow
                Color(red: 0.2, green: 0.8, blue: 0.6),    // Teal/Turquoise
                Color(red: 0.0, green: 0.7, blue: 0.8),    // Cyan Blue
                Color(red: 0.6, green: 0.4, blue: 1.0),    // Purple
                Color(red: 1.0, green: 0.3, blue: 0.6),    // Pink
                Color(red: 0.4, green: 0.9, blue: 0.3),    // Lime Green
            ]
            
            guard !card.content.isEmpty else {
                return vibrantColors[0]
            }
            let hash = abs(card.content.hashValue)
            let index = hash % vibrantColors.count
            return vibrantColors[index]
        }
    }
} 