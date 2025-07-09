import SwiftUI
import SpriteKit

struct WritingView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var totalAnswers = 0
    @State private var showingResults = false
    @State private var userInput = ""
    @State private var hasAnswered = false
    @State private var isCorrect: Bool? = nil
    @State private var showingCloseConfirmation = false
    @FocusState private var isKeyboardFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Progressive study properties
    private var studyMode: StudyMode?
    private var onLevelComplete: ((LevelResult) -> Void)?
    private var maxQuestions: Int?
    
    // Add speech service for pronunciation
    @StateObject private var speechService = DutchSpeechService.shared
    
    // Add user profile manager for XP tracking
    @StateObject private var userProfileManager = UserProfileManager.shared
    
    // Session XP tracking
    @State private var sessionXP: Int = 0 // Track XP gained during current session
    
    // Session tracking
    @State private var sessionStartTime: Date = Date()
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Hangman-style game state
    @State private var revealedLetters: Set<Character> = []
    @State private var guessedLetters: Set<Character> = []
    @State private var wrongGuesses = 0
    @State private var maxWrongGuesses = 5
    
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
        guard let card = currentCard else { return "" }
        return card.article.isEmpty ? card.word : "\(card.article) \(card.word)"
    }
    
    // Check if current word is being spoken
    private var isCurrentWordSpeaking: Bool {
        return speechService.isSpeaking && speechService.currentlySpeaking == textToSpeak
    }
    
    // Computed property for displaying the word with placeholders
    private var displayWord: String {
        guard let card = currentCard else { return "" }
        return card.word.map { char in
            if char.isWhitespace {
                return String(char) // Show spaces as spaces
            } else {
                let lowerChar = char.lowercased()
                if revealedLetters.contains(lowerChar) || guessedLetters.contains(lowerChar) {
                    return String(char)
                } else {
                    return "_"
                }
            }
        }.joined(separator: "")
    }
    
    // Check if word is complete
    private var isWordComplete: Bool {
        guard let card = currentCard else { return false }
        let wordLetters = Set(card.word.lowercased().filter { $0.isLetter }.map { $0 })
        return wordLetters.isSubset(of: revealedLetters.union(guessedLetters))
    }
    
    // Check if game is over (too many wrong guesses)
    private var isGameOver: Bool {
        return wrongGuesses >= maxWrongGuesses
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false, studyMode: StudyMode? = nil, maxQuestions: Int? = nil, onLevelComplete: ((LevelResult) -> Void)? = nil) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        _cards = State(initialValue: viewModel.sortCardsForLearning(cards))
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    handleBackButton()
                }
            }
        }
        .navigationTitle("Write Your Cards")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                // Initialize normally - reset to first card and prepare for input
                sessionStartTime = Date()
                resetForNextCard()
            }
        }
        .onDisappear {
            // Auto-save when view disappears
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
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Cards Available")
                .font(.title2)
                .bold()
            
            Text("Add some cards to your decks to practice writing.")
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
                totalCards: maxQuestions ?? cards.count,
                score: userProfileManager.xp,
                knownCount: nil,
                unknownCount: nil,
                skippedCount: nil,
                sessionXP: sessionXP,
                showProgressIndicator: false,
                isComplete: showingResults
            )
            
            if let card = currentCard {
                VStack(spacing: 20) {
                    // Instruction text outside the card
                    Text("Write the translation for:")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Use shared card component with vibrant borders - show the translation instead of the word
                    SharedGameCardView(
                        card: card,
                        title: "",
                        content: card.definition,
                        showArticle: false
                    )
                    
                    // Word display with placeholders
                    if !hasAnswered {
                        VStack(spacing: 16) {
                            // Display the word with placeholders
                            Text(displayWord)
                                .font(.system(size: 32, weight: .bold, design: .monospaced))
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .onTapGesture {
                                    isKeyboardFocused = true
                    }
                    
                            // Hidden text field for keyboard input
                            TextField("", text: $userInput)
                            .focused($isKeyboardFocused)
                                .opacity(0)
                                .onChange(of: userInput) { newValue in
                                    // Process each character typed
                                    if let lastChar = newValue.last {
                                        let letter = Character(lastChar.lowercased())
                                        if letter.isLetter && !guessedLetters.contains(letter) && !revealedLetters.contains(letter) {
                                            guessLetter(letter)
                                        }
                                    }
                                    // Clear input after processing
                                    userInput = ""
                                }
                            }
                    }
                    
                    // Answer feedback
                    if hasAnswered {
                        answerFeedbackView(for: card)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .onAppear {
            isKeyboardFocused = true
        }
    }
    
    private func answerFeedbackView(for card: FlashCard) -> some View {
        VStack(spacing: 16) {
            // Feedback section
            VStack(spacing: 12) {
                if let isCorrect = isCorrect {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isCorrect ? .green : .red)
                            .font(.title2)
                        
                        Text(isCorrect ? "Correct!" : "Incorrect")
                            .font(.title3)
                            .bold()
                            .foregroundColor(isCorrect ? .green : .red)
                    }
                    
                    if !isCorrect {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Correct answer:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                
                                HStack(spacing: 8) {
                                        Text(card.word)
                                            .foregroundColor(.green)
                                            .bold()
                                    
                                    // Pronunciation button for correct answer
                                    Button(action: {
                                        if isCurrentWordSpeaking {
                                            speechService.stopSpeaking()
                                        } else {
                                            speakCurrentWord()
                                        }
                                        HapticManager.shared.lightImpact()
                                    }) {
                                        Image(systemName: isCurrentWordSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                                            .font(.callout)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Action buttons
            HStack(spacing: 12) {
                Button(action: nextCard) {
                    Text(currentIndex < cards.count - 1 ? "Next Card" : "Finish")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Writing Complete!")
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
            
            VStack(spacing: 16) {
                Button(action: {
                    // Explicitly save all ViewModel data to ensure statistics persist
                    viewModel.saveAllData()
                    
                    // Force UI refresh
                    DispatchQueue.main.async {
                        viewModel.objectWillChange.send()
                    }
                    
                    resetGame()
                }) {
                    Text("Practice Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Game Logic
    
    private var isAnswerReady: Bool {
        // Check if word is complete or game is over
        return isWordComplete || isGameOver
    }
    
    private func checkAnswer() {
        guard let card = currentCard else { return }
        
        HapticManager.shared.buttonTap()
        
        // Check if word is complete
        let answersMatch = isWordComplete
        
        isCorrect = answersMatch
        hasAnswered = true
        totalAnswers += 1
        
        if answersMatch {
            correctAnswers += 1
            HapticManager.shared.testCorrectHaptic()
            SoundManager.shared.playTestCorrectSound()
            
            // Apply SRS logic for correct answer
            let updatedCard = srsManager.processSimpleReview(for: card, simpleQuality: .know)
            viewModel.updateCardWithSRSData(updatedCard)
        } else {
            HapticManager.shared.testWrongHaptic()
            SoundManager.shared.playTestWrongSound()
            
            // Apply SRS logic for incorrect answer
            let updatedCard = srsManager.processSimpleReview(for: card, simpleQuality: .dontKnow)
            viewModel.updateCardWithSRSData(updatedCard)
        }
        
        // Record learning statistics
        viewModel.recordCardShown(card.id, isCorrect: answersMatch)
    }
    
    private func nextCard() {
        // Auto-save progress periodically (every 5 cards)
        if currentIndex % 5 == 0 && currentIndex > 0 {
            saveCurrentProgress()
        }
        
        // Check if we've reached the max questions limit (for progressive study)
        if let maxQuestions = maxQuestions, currentIndex >= maxQuestions - 1 {
            print("✏️ Reached max questions limit for progressive study")
            HapticManager.shared.gameComplete()
            
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
                    score: correctAnswers,
                    total: maxQuestions
                )
                onLevelComplete(result)
            } else {
                // Post notification for regular writing mode
                NotificationCenter.default.post(name: .writingSessionCompleted, object: nil)
                
                // Check for perfect session (100% accuracy with at least 5 cards)
                if maxQuestions >= 5 && correctAnswers == maxQuestions {
                    let sessionDuration = Date().timeIntervalSince(sessionStartTime)
                    StatisticsManager.shared.recordPerfectSession(
                        gameType: .writing,
                        totalCards: maxQuestions,
                        knownCards: correctAnswers,
                        duration: sessionDuration
                    )
                }
                
                StreakManager.shared.recordGameCompletion(); showingResults = true
            }
            return
        }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            resetForNextCard()
        } else {
            // Clear saved progress since game is complete
            clearSavedProgress()
            
            // Check for perfect session (100% accuracy with at least 5 cards)
            if cards.count >= 5 && correctAnswers == cards.count {
                let sessionDuration = Date().timeIntervalSince(sessionStartTime)
                StatisticsManager.shared.recordPerfectSession(
                    gameType: .writing,
                    totalCards: cards.count,
                    knownCards: correctAnswers,
                    duration: sessionDuration
                )
            }
            
            HapticManager.shared.gameComplete()
            StreakManager.shared.recordGameCompletion(); showingResults = true
        }
    }
    
    private func resetForNextCard() {
        userInput = ""
        hasAnswered = false
        isCorrect = nil
        revealedLetters = []
        guessedLetters = []
        wrongGuesses = 0
        isKeyboardFocused = true
    }
    
    private func resetGame() {
        cards = viewModel.sortCardsForLearning(cards)
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        isKeyboardFocused = true
        
        // Reset session XP to 0 for new game
        sessionXP = 0
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
        
        let gameState = WritingGameState(
            currentIndex: currentIndex,
            correctAnswers: correctAnswers,
            totalAnswers: totalAnswers,
            cards: cards
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .writing,
            gameData: gameState
        )
        
        print("💾 Writing practice progress saved - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .writing,
            as: WritingGameState.self
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
            
            print("✏️ Writing practice progress loaded - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("✏️ No saved state found, starting fresh writing practice")
            resetForNextCard()
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .writing)
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
        let text = textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Use slower speech rate for learning
        speechService.speakDutch(text, rate: 0.4)
    }
    
    // MARK: - Hangman Game Logic

    private func guessLetter(_ letter: Character) {
        guard let card = currentCard else { return }
        
        let lowerLetter = letter.lowercased().first ?? letter
        guessedLetters.insert(lowerLetter)
        
        // Check if letter is in the word
        let wordLetters = Set(card.word.lowercased().filter { $0.isLetter }.map { $0 })
        if wordLetters.contains(lowerLetter) {
            // Correct guess - reveal all instances of this letter
            HapticManager.shared.lightImpact()
        } else {
            // Wrong guess
            wrongGuesses += 1
            HapticManager.shared.errorNotification()
        }
        
        // Check if word is complete or game is over
        if isWordComplete || isGameOver {
            checkAnswer()
        }
    }
}

struct WritingView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FlashCardViewModel()
        let sampleCards = [
            FlashCard(word: "Hallo", definition: "Hello", example: "Hallo, hoe gaat het?"),
            FlashCard(word: "Dank je wel", definition: "Thank you", example: "Dank je wel voor je hulp.")
        ]
        WritingView(viewModel: viewModel, cards: sampleCards)
    }
}
