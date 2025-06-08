import SwiftUI

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
    @Environment(\.dismiss) private var dismiss
    @State private var gameCards: [Card] = []
    @State private var displayedCards: [Card] = []
    @State private var remainingCards: [Card] = []
    @State private var selectedCard: Card?
    @State private var score = 0
    @State private var moves = 0
    @State private var showingGameOver = false
    @State private var incorrectMatches: Set<FlashCard> = []
    @State private var showingReview = false
    @State private var reviewCards: [FlashCard] = []
    @State private var showingCloseConfirmation = false
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return moves > 0 || score > 0
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        self.cards = cards
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if cards.isEmpty {
                    emptyStateView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    gameView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Bottom Navigation Bar
                HStack {
                    Button(action: {
                        handleBackButton()
                    }) {
                        VStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        setupGame()
                    }) {
                        VStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Reset")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Save progress button
                    if hasSignificantProgress && !showingGameOver {
                        Button(action: {
                            saveCurrentProgress()
                            HapticManager.shared.successNotification()
                        }) {
                            VStack {
                                Image(systemName: "bookmark.fill")
                                Text("Save")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .opacity(0.2),
                    alignment: .top
                )
            }

            if showingGameOver {
                // Semi-transparent background
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                // Game over popup
                VStack(spacing: 20) {
                    // Score summary
                    VStack(spacing: 10) {
                        Text("Game Complete! 🎉")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("You completed the game in \(moves) moves!")
                            .font(.headline)
                    }
                    .padding(.top)
                    
                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            setupGame()
                            showingGameOver = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            dismissToRoot()
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Return to Main Menu")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                setupGame()
            }
        }
        .onDisappear {
            // Auto-save when view disappears
            if hasSignificantProgress && !showingGameOver {
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
        if hasSignificantProgress && !showingGameOver {
            showingCloseConfirmation = true
        } else {
            dismiss()
        }
    }
    
    private func saveCurrentProgress() {
        guard !deckIds.isEmpty && hasSignificantProgress else { return }
        
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
            deckIds: deckIds,
            gameData: gameState
        )
        
        print("💾 Memory game progress saved - Score: \(score), Moves: \(moves)")
    }
    
    private func loadSavedProgress() {
        guard !deckIds.isEmpty else { 
            setupGame()
            return 
        }
        
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .memoryGame,
            deckIds: deckIds,
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
            
            print("🧠 Memory game progress loaded - Score: \(score), Moves: \(moves)")
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("🧠 No saved state found, starting fresh memory game")
            setupGame()
        }
    }
    
    private func clearSavedProgress() {
        guard !deckIds.isEmpty else { return }
        
        SaveStateManager.shared.deleteSaveState(
            gameType: .memoryGame,
            deckIds: deckIds
        )
    }
    
    private func saveProgressAndDismiss() {
        if hasSignificantProgress && !showingGameOver {
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
        VStack(spacing: 20) {
            // Score and moves - with top padding for status bar
            HStack {
                Text("Matches: \(score)")
                    .font(.headline)
                Spacer()
                Text("Moves: \(moves)")
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            // Game grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<8) { index in
                        if index < displayedCards.count {
                            GameCardView(card: displayedCards[index]) {
                                cardTapped(displayedCards[index])
                            }
                            .opacity(displayedCards[index].isMatched ? 0 : 1)
                        } else {
                            // Empty space to maintain grid
                            Color.clear
                                .frame(height: 110)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func setupGame() {
        // Reset game state
        score = 0
        moves = 0
        selectedCard = nil
        
        // Clear any saved progress when starting fresh
        clearSavedProgress()
        
        // Create pairs of cards (word and definition)
        var allPairs: [(Card, Card)] = cards.map { flashCard in
            let wordCard = Card(content: flashCard.word, type: .word, originalCard: flashCard)
            let defCard = Card(content: flashCard.definition, type: .definition, originalCard: flashCard)
            return (wordCard, defCard)
        }
        
        // Shuffle the pairs
        allPairs.shuffle()
        
        // Take first 4 pairs for display (8 cards total)
        displayedCards = Array(allPairs.prefix(4)).flatMap { [$0.0, $0.1] }
        // Store remaining pairs
        remainingCards = Array(allPairs.dropFirst(4)).flatMap { [$0.0, $0.1] }
        // Shuffle the displayed cards
        displayedCards.shuffle()
        
        gameCards = displayedCards + remainingCards
    }
    
    private func replaceMatchedCards() {
        // If we still have cards to add
        if !remainingCards.isEmpty {
            // Find indices of matched cards
            let matchedIndices = displayedCards.enumerated()
                .filter { $0.element.isMatched }
                .map { $0.offset }
            
            // Create new cards
            var newCards: [Card] = []
            for _ in matchedIndices {
                guard !remainingCards.isEmpty else { break }
                var newCard = remainingCards.removeFirst()
                newCard.isSelected = false
                newCard.isMatched = false
                newCard.showWrongAnimation = false
                newCards.append(newCard)
            }
            
            // Replace all matched cards at once
            for (index, matchedIndex) in matchedIndices.enumerated() {
                guard index < newCards.count else { break }
                displayedCards[matchedIndex] = newCards[index]
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
        
        // Light haptic for card tap
        HapticManager.shared.lightImpact()
        
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
                HapticManager.shared.cardMatch() // Strong haptic for successful match
                score += 1
                displayedCards[index].isSelected = true
                
                // After a brief delay, mark them as matched
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // Clear selection and set matched state
                    displayedCards[selectedIndex].isSelected = false
                    displayedCards[index].isSelected = false
                    displayedCards[selectedIndex].isMatched = true
                    displayedCards[index].isMatched = true
                    
                    // Replace matched cards after fade out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        replaceMatchedCards()
                        
                        // Check if this was the last pair
                        let unmatchedCards = displayedCards.filter { !$0.isMatched }
                        if unmatchedCards.isEmpty && remainingCards.isEmpty {
                            HapticManager.shared.gameComplete() // Double haptic for game completion
                            
                            // Clear saved progress since game is complete
                            clearSavedProgress()
                            
                            showingGameOver = true
                        }
                    }
                }
            } else {
                // Not a match
                HapticManager.shared.cardMismatch() // Medium haptic for mismatch
                displayedCards[index].showWrongAnimation = true
                
                // Track incorrect matches
                incorrectMatches.insert(selectedCard!.originalCard)
                incorrectMatches.insert(tappedCard.originalCard)
                
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
}

struct GameCardView: View {
    let card: Card
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(radius: 3)
                
                if !card.isMatched {
                    Text(card.content)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding()
                        .opacity(card.isMatched ? 0 : 1)
                }
            }
        }
        .frame(height: 110)
        .animation(nil, value: card.isSelected)
        .animation(nil, value: card.showWrongAnimation)
    }
    
    private var backgroundColor: Color {
        if card.isSelected {
            return .green.opacity(0.3)
        } else if card.showWrongAnimation {
            return .red.opacity(0.3)
        } else {
            return .white
        }
    }
} 