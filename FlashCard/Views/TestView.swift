import SwiftUI

struct TestView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var showingResults = false
    @State private var correctAnswers = 0
    @State private var selectedAnswer: String?
    @State private var hasAnswered = false
    @State private var shuffledOptions: [String] = []
    @State private var showingCloseConfirmation = false
    @Environment(\.dismiss) private var dismiss
    @State private var incorrectCards: Set<UUID> = []
    
    // Add speech service for pronunciation
    @StateObject private var speechService = DutchSpeechService.shared
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return currentIndex > 0 || correctAnswers > 0
    }
    
    // Get the text to speak for current card
    private var textToSpeak: String {
        let card = currentCard
        return card.article.isEmpty ? card.word : "\(card.article) \(card.word)"
    }
    
    // Check if current word is being spoken
    private var isCurrentWordSpeaking: Bool {
        return speechService.isSpeaking && speechService.currentlySpeaking == textToSpeak
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        self.cards = viewModel.sortCardsForLearning(cards)
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
    }
    
    private var currentCard: FlashCard {
        cards[currentIndex]
    }
    
    private func generateOptions() -> [String] {
        var options = [currentCard.definition] // Correct answer
        
        // Get all available decks for the current card
        let cardDecks = viewModel.decks.filter { deck in
            deck.cards.contains { $0.id == currentCard.id }
        }
        
        // Get all cards from the same decks (excluding current card)
        var poolOfOptions = Set<String>()
        for deck in cardDecks {
            let deckDefinitions = deck.cards
                .filter { $0.id != currentCard.id }
                .map { $0.definition }
            poolOfOptions.formUnion(deckDefinitions)
        }
        
        // If we don't have enough options from the same decks, use other cards
        if poolOfOptions.count < 3 {
            let otherDefinitions = viewModel.flashCards
                .filter { $0.id != currentCard.id }
                .map { $0.definition }
            poolOfOptions.formUnion(otherDefinitions)
        }
        
        // Add random definitions until we have 4 total options
        let additionalOptions = Array(poolOfOptions)
            .shuffled()
            .prefix(3)
        
        options.append(contentsOf: additionalOptions)
        return options.shuffled()
    }
    
    private func handleAnswer(_ option: String) {
        if !hasAnswered {
            selectedAnswer = option
            hasAnswered = true
            let isCorrect = option == currentCard.definition
            if isCorrect {
                correctAnswers += 1
                HapticManager.shared.correctAnswer()
            } else {
                incorrectCards.insert(currentCard.id)
                HapticManager.shared.wrongAnswer()
            }
            
            // Record learning statistics - card was shown and answered correctly/incorrectly
            viewModel.recordCardShown(currentCard.id, isCorrect: isCorrect)
            
            // Automatically move to next question after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                moveToNextQuestion()
            }
        }
    }
    
    private func moveToNextQuestion() {
        HapticManager.shared.questionAdvance()
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            selectedAnswer = nil
            hasAnswered = false
            shuffledOptions = generateOptions()
            
            // Auto-play pronunciation for new question
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speakCurrentWord()
            }
            
            // Auto-save progress periodically (every 5 questions)
            if currentIndex % 5 == 0 {
                saveCurrentProgress()
            }
        } else {
            // End of current round - check if there are incorrect cards to replay
            if !incorrectCards.isEmpty {
                // Auto-replay incorrect cards with intelligent ordering
                let incorrectCardsList = cards.filter { incorrectCards.contains($0.id) }
                cards = viewModel.sortCardsForLearning(incorrectCardsList)
                currentIndex = 0
                selectedAnswer = nil
                hasAnswered = false
                incorrectCards.removeAll() // Reset for next round
                shuffledOptions = generateOptions()
                
                // Auto-play pronunciation for first question of new round
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    speakCurrentWord()
                }
                
                HapticManager.shared.mediumImpact() // Feedback for round transition
                
                // Optional: Show a brief message that we're replaying incorrect cards
                // For now, just continue seamlessly
            } else {
                // All cards answered correctly - show completion
                HapticManager.shared.gameComplete()
                
                // Clear saved progress since test is complete
                clearSavedProgress()
                
                StreakManager.shared.recordGameCompletion(); showingResults = true
            }
        }
    }
    
    private func resetTest(onlyIncorrect: Bool = false) {
        if onlyIncorrect {
            cards = cards.filter { incorrectCards.contains($0.id) }
        } else {
            cards = viewModel.sortCardsForLearning(cards)
        }
        currentIndex = 0
        correctAnswers = 0
        showingResults = false
        selectedAnswer = nil
        hasAnswered = false
        incorrectCards.removeAll()
        shuffledOptions = generateOptions()
        
        // Clear any saved progress when resetting
        clearSavedProgress()
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
    
    var body: some View {
        VStack(spacing: 0) {
            if cards.isEmpty {
                emptyStateView
            } else if showingResults {
                resultsView
            } else {
                testView
            }
            
            // Bottom close button
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
        .navigationBarHidden(true)
        .alert("Close Test?", isPresented: $showingCloseConfirmation) {
            Button("Save & Close") {
                saveCurrentProgress()
                dismissToRoot()
            }
            Button("Close", role: .destructive) {
                dismissToRoot()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(hasSignificantProgress ? "Would you like to save your progress?" : "Are you sure you want to close?")
        }
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                shuffledOptions = generateOptions()
            }
            
            // Auto-play pronunciation when test starts
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                speakCurrentWord()
            }
        }
        .onDisappear {
            // Auto-save when view disappears
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
    }
    
    private var testView: some View {
        VStack(spacing: 30) {
            // Progress indicator
            HStack {
                Text("\(currentIndex + 1) of \(cards.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Score: \(correctAnswers)")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            Spacer()
            
            // Question card with pronunciation
            ZStack {
                VStack(spacing: 16) {
                    // Word with optional article
                    VStack(spacing: 4) {
                        if !currentCard.article.isEmpty {
                            Text(currentCard.article)
                                .font(.caption)
                                .foregroundColor(.blue)
                                .bold()
                        }
                        Text(currentCard.word)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    
                    // Pronunciation button
                    Button(action: {
                        if isCurrentWordSpeaking {
                            speechService.stopSpeaking()
                        } else {
                            speakCurrentWord()
                        }
                        HapticManager.shared.lightImpact()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: isCurrentWordSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                                .foregroundColor(.blue)
                            Text(isCurrentWordSpeaking ? "Stop" : "Pronounce")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                
                // Learning percentage in top right
                VStack {
                    HStack {
                        Spacer()
                        LearningPercentageView(percentage: currentCard.learningPercentage)
                            .padding(.top, 16)
                            .padding(.trailing, 16)
                    }
                    Spacer()
                }
            }
            
            Text("Choose the correct translation:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Answer options
            VStack(spacing: 10) {
                ForEach(shuffledOptions, id: \.self) { option in
                    Button(action: {
                        handleAnswer(option)
                    }) {
                        Text(option)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Group {
                                    if hasAnswered {
                                        if option == currentCard.definition {
                                            Color.green.opacity(0.2)
                                        } else if option == selectedAnswer {
                                            Color.red.opacity(0.2)
                                        } else {
                                            Color(.systemGray6)
                                        }
                                    } else {
                                        Color(.systemGray6)
                                    }
                                }
                            )
                            .cornerRadius(10)
                    }
                    .disabled(hasAnswered)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 20) {
            Text("Test Complete! 🎉")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text("Score: \(correctAnswers) / \(cards.count)")
                .font(.title2)
            
            Text("\(Int((Double(correctAnswers) / Double(cards.count)) * 100))%")
                .font(.largeTitle)
                .bold()
                .foregroundColor(
                    Double(correctAnswers) / Double(cards.count) >= 0.7 ? .green : .red
                )
            
            VStack(spacing: 16) {
                Button(action: {
                    // Explicitly save all ViewModel data to ensure statistics persist
                    viewModel.saveAllData()
                    
                    // Force UI refresh
                    DispatchQueue.main.async {
                        viewModel.objectWillChange.send()
                    }
                    
                    resetTest()
                }) {
                    Text("Test All Cards Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    dismissToRoot()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top)
        }
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to test")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
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
        
        let gameState = TestGameState(
            currentIndex: currentIndex,
            correctAnswers: correctAnswers,
            incorrectCards: incorrectCards,
            cards: cards,
            selectedAnswer: selectedAnswer,
            hasAnswered: hasAnswered
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .test,
            gameData: gameState
        )
        
        print("💾 Test progress saved - Index: \(currentIndex), Correct: \(correctAnswers)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .test,
            as: TestGameState.self
        ) {
            // Restore state
            currentIndex = savedState.currentIndex
            correctAnswers = savedState.correctAnswers
            incorrectCards = savedState.incorrectCards
            selectedAnswer = savedState.selectedAnswer
            hasAnswered = savedState.hasAnswered
            
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
            
            shuffledOptions = generateOptions()
            
            print("📝 Test progress loaded - Index: \(currentIndex), Correct: \(correctAnswers)")
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("📝 No saved state found, starting fresh test")
            shuffledOptions = generateOptions()
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .test)
    }
    
    // MARK: - Speech Functions
    private func speakCurrentWord() {
        let text = textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Use slower speech rate for learning
        speechService.speakDutch(text, rate: 0.4)
    }
} 