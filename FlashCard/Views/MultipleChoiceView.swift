import SwiftUI

struct MultipleChoiceView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var totalAnswers = 0
    @State private var showingResults = false
    @State private var selectedAnswer: String?
    @State private var hasAnswered = false
    @State private var shuffledOptions: [String] = []
    @State private var showingCloseConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Add user profile manager for XP tracking
    @StateObject private var userProfileManager = UserProfileManager.shared
    
    // Session XP tracking
    @State private var sessionXP: Int = 0 // Track XP gained during current session
    
    // Session tracking
    @State private var sessionStartTime: Date = Date()
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return currentIndex > 0 || totalAnswers > 0
    }
    
    private var currentCard: FlashCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    // Get the text to speak for current card
    private var textToSpeak: String {
        return "" // Not needed for multiple choice
    }
    
    // Check if current word is being spoken
    private var isCurrentWordSpeaking: Bool {
        return false // Removed speech service
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        _cards = State(initialValue: viewModel.sortCardsForLearning(cards))
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    handleBackButton()
                }
            }
        }
        .navigationTitle("Multiple Choice")
        .navigationBarTitleDisplayMode(.inline)
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
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                setupGame()
            }
        }
        .onDisappear {
            // Auto-save when view disappears
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Cards Available")
                .font(.title2)
                .bold()
            
            Text("Add some cards to your decks to practice multiple choice.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 0) {
            // Unified header with progress bar
            GameHeaderView(
                currentIndex: currentIndex + 1,
                totalCards: cards.count,
                score: userProfileManager.xp, // Use current XP instead of calculated score
                knownCount: nil,
                unknownCount: nil,
                skippedCount: nil,
                sessionXP: sessionXP,
                isComplete: showingResults
            )
            
            Spacer()
            
            // Question card
            VStack(spacing: 20) {
                if let card = currentCard {
                    Text(card.word)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    // Options
                    VStack(spacing: 12) {
                        ForEach(shuffledOptions, id: \.self) { option in
                            Button(action: {
                                handleAnswer(option)
                            }) {
                                Text(option)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                                    )
                            }
                            .disabled(hasAnswered)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    Text("No card available")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Multiple Choice Complete!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(correctAnswers) / \(totalAnswers)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Double(correctAnswers)/Double(totalAnswers) >= 0.7 ? .green : .orange)
                
                let percentage = totalAnswers > 0 ? Int((Double(correctAnswers) / Double(totalAnswers)) * 100) : 0
                Text("\(percentage)%")
                    .font(.title)
                    .foregroundColor(.secondary)
            }
            
            Button("Play Again") {
                // Explicitly save all ViewModel data to ensure statistics persist
                viewModel.saveAllData()
                
                // Force UI refresh
                DispatchQueue.main.async {
                    viewModel.objectWillChange.send()
                }
                
                resetGame()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
        .padding()
    }
    
    // MARK: - Game Logic
    
    private func setupGame() {
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        cards = viewModel.sortCardsForLearning(cards)
        
        // Reset session XP to 0 for new game
        sessionXP = 0
        
        setupCurrentQuestion()
        sessionStartTime = Date()
    }
    
    private func setupCurrentQuestion() {
        guard let card = currentCard else {
            // Reset state if no card is available
            selectedAnswer = nil
            hasAnswered = false
            shuffledOptions = []
            return
        }
        
        // Reset state
        selectedAnswer = nil
        hasAnswered = false
        
        // Generate options
        shuffledOptions = generateOptions()
    }
    
    private func generateOptions() -> [String] {
        guard let card = currentCard else { return [] }
        
        var options = [getCorrectAnswer()] // Correct answer
        
        // Get all available cards from all decks for wrong answers
        var poolOfOptions = Set<String>()
        
        // Add words from all cards (excluding current card)
        let allWords = viewModel.flashCards
            .filter { $0.id != card.id }
            .map { flashCard in
                flashCard.article.isEmpty ? flashCard.word : "\(flashCard.article) \(flashCard.word)"
            }
        
        poolOfOptions.formUnion(allWords)
        
        // Add random words until we have 4 total options
        let additionalOptions = Array(poolOfOptions)
            .shuffled()
            .prefix(3)
        
        options.append(contentsOf: additionalOptions)
        
        // Ensure we have exactly 4 options
        while options.count < 4 {
            options.append("Option \(options.count)")
        }
        
        return Array(options.prefix(4)).shuffled()
    }
    
    private func getCorrectAnswer() -> String {
        guard let card = currentCard else { return "" }
        return card.article.isEmpty ? card.word : "\(card.article) \(card.word)"
    }
    
    private func handleAnswer(_ option: String) {
        guard !hasAnswered, let card = currentCard else { return }
        
        selectedAnswer = option
        hasAnswered = true
        totalAnswers += 1
        
        let isCorrect = option == getCorrectAnswer()
        if isCorrect {
            correctAnswers += 1
            // Use custom sound for games (not study mode)
            HapticManager.shared.successNotification() // Haptic only
            SoundManager.shared.playTestCorrectSound() // Custom Correct.wav
            
            // Add XP for correct answer
            userProfileManager.addXP(15)
            sessionXP += 15
        } else {
            // Use custom sound for games (not study mode)
            HapticManager.shared.errorNotification() // Haptic only
            SoundManager.shared.playTestWrongSound() // Custom Wrong.wav
            
            // Add XP for attempting (even if wrong)
            userProfileManager.addXP(5)
            sessionXP += 5
        }
        
        // Record learning statistics
        viewModel.recordCardShown(card.id, isCorrect: isCorrect)
    }
    
    private func nextQuestion() {
        // Auto-save progress periodically (every 5 questions)
        if currentIndex % 5 == 0 && currentIndex > 0 {
            saveCurrentProgress()
        }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            setupCurrentQuestion()
        } else {
            // Clear saved progress since game is complete
            clearSavedProgress()
            
            // Check for perfect session (100% accuracy with at least 5 cards)
            if cards.count >= 5 && correctAnswers == cards.count {
                let sessionDuration = Date().timeIntervalSince(sessionStartTime)
                StatisticsManager.shared.recordPerfectSession(
                    gameType: .multipleChoice,
                    totalCards: cards.count,
                    knownCards: correctAnswers,
                    duration: sessionDuration
                )
            }
            
            showingResults = true
        }
    }
    
    private func resetGame() {
        cards = viewModel.sortCardsForLearning(cards)
        setupGame()
        
        // Clear any saved progress when resetting
        clearSavedProgress()
    }
    
    private func saveCurrentProgress() {
        guard hasSignificantProgress else { return }
        
        let gameState = MultipleChoiceGameState(
            currentIndex: currentIndex,
            correctAnswers: correctAnswers,
            totalAnswers: totalAnswers,
            cards: cards
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .multipleChoice,
            gameData: gameState
        )
        
        print("💾 Multiple Choice progress saved - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .multipleChoice,
            as: MultipleChoiceGameState.self
        ) {
            // Restore state
            currentIndex = savedState.currentIndex
            correctAnswers = savedState.correctAnswers
            totalAnswers = savedState.totalAnswers
            
            // Update cards to match saved order if they exist
            if !savedState.cards.isEmpty {
                // Filter to only include cards that still exist in the current deck selection
                let currentCardIds = Set(cards.map { $0.id })
                let savedCards = savedState.cards.filter { currentCardIds.contains($0.id) }
                
                if !savedCards.isEmpty {
                    cards = savedCards
                }
            }
            
            // Ensure currentIndex is valid
            if currentIndex >= cards.count {
                currentIndex = max(0, cards.count - 1)
            }
            
            setupCurrentQuestion()
            
            print("🔤 Multiple Choice progress loaded - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
        } else {
            // No saved state found, start normally
            print("🔤 No saved state found, starting fresh Multiple Choice")
            setupGame()
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .multipleChoice)
    }
    
    private func saveProgressAndDismiss() {
        if hasSignificantProgress && !showingResults {
            saveCurrentProgress()
        }
        dismissToRoot()
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
    
    // MARK: - Speech Functions
    private func speakCurrentWord() {
        // No speech functionality in multiple choice
    }
    
    private func speakText(_ text: String) {
        // No speech functionality in multiple choice
    }
    
    private func handleBackButton() {
        // Implement the logic to handle the back button
        if hasSignificantProgress && !showingResults {
            showingCloseConfirmation = true
        } else {
            dismissToRoot()
        }
    }
}

// MARK: - Save State

struct MultipleChoiceGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let totalAnswers: Int
    let cards: [FlashCard]
} 