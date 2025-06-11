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
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return currentIndex > 0 || correctAnswers > 0
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        _cards = State(initialValue: cards.shuffled())
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
            
            // Auto-save progress periodically (every 5 questions)
            if currentIndex % 5 == 0 {
                saveCurrentProgress()
            }
        } else {
            HapticManager.shared.gameComplete()
            
            // Clear saved progress since test is complete
            clearSavedProgress()
            
            showingResults = true
        }
    }
    
    private func resetTest(onlyIncorrect: Bool = false) {
        if onlyIncorrect {
            cards = cards.filter { incorrectCards.contains($0.id) }
        } else {
            cards = cards.shuffled()
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
                    resetTest()
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset")
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Save progress button
                if hasSignificantProgress && !showingResults {
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
        .navigationBarHidden(true)
        .alert("Close Test?", isPresented: $showingCloseConfirmation) {
            if hasSignificantProgress {
                Button("Save & Close") {
                    saveProgressAndDismiss()
                }
                Button("Close Without Saving", role: .destructive) {
                    dismissToRoot()
                }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("Close", role: .destructive) {
                    dismissToRoot()
                }
                Button("Cancel", role: .cancel) { }
            }
        } message: {
            Text(hasSignificantProgress ? 
                "Would you like to save your progress or close without saving?" : 
                "Are you sure you want to close?")
        }
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                shuffledOptions = generateOptions()
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
        VStack(spacing: 20) {
            // Progress - with top padding for status bar
            HStack {
                Text("\(currentIndex + 1) of \(cards.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Correct: \(correctAnswers)")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            // Question
            VStack(spacing: 15) {
                Text("What does this word mean?")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ZStack {
                    VStack {
                        Text(currentCard.word)
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
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
                
                Text("Choose one of the following:")
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
            }
            
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
                
                if !incorrectCards.isEmpty {
                    Button(action: {
                        resetTest(onlyIncorrect: true)
                    }) {
                        Text("Review Incorrect Answers (\(incorrectCards.count))")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
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
        guard !deckIds.isEmpty && hasSignificantProgress else { return }
        
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
            deckIds: deckIds,
            gameData: gameState
        )
        
        print("💾 Test progress saved - Index: \(currentIndex), Correct: \(correctAnswers)")
    }
    
    private func loadSavedProgress() {
        guard !deckIds.isEmpty else { 
            shuffledOptions = generateOptions()
            return 
        }
        
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .test,
            deckIds: deckIds,
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
        guard !deckIds.isEmpty else { return }
        
        SaveStateManager.shared.deleteSaveState(
            gameType: .test,
            deckIds: deckIds
        )
    }
    
    private func saveProgressAndDismiss() {
        if hasSignificantProgress && !showingResults {
            saveCurrentProgress()
        }
        dismissToRoot()
    }
} 