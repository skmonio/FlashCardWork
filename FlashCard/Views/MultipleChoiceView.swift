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
    
    // Add speech service for pronunciation
    @StateObject private var speechService = DutchSpeechService.shared
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
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
        VStack(spacing: 30) {
            // Progress indicator - with top padding for status bar
            HStack {
                Text("Question \(currentIndex + 1) of \(cards.count)")
                    .font(.headline)
                Spacer()
                Text("Score: \(correctAnswers)/\(totalAnswers)")
                    .font(.headline)
                    .foregroundColor(totalAnswers > 0 ? (Double(correctAnswers)/Double(totalAnswers) >= 0.7 ? .green : .orange) : .primary)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            if let card = currentCard {
                // Question display
                VStack(spacing: 25) {
                    Text("How do you say this in Dutch?")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text(card.definition)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemBackground))
                                .shadow(radius: 5)
                        )
                        .padding(.horizontal)
                }
                
                // Answer options
                VStack(spacing: 12) {
                    ForEach(shuffledOptions, id: \.self) { option in
                        Button(action: {
                            handleAnswer(option)
                        }) {
                            HStack {
                                Text(option)
                                    .font(.body)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Show pronunciation button for each option when answered
                                if hasAnswered {
                                    Button(action: {
                                        speakText(option)
                                        HapticManager.shared.lightImpact()
                                    }) {
                                        Image(systemName: "speaker.wave.2")
                                            .font(.callout)
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Group {
                                    if hasAnswered {
                                        if option == getCorrectAnswer() {
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
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        hasAnswered && option == getCorrectAnswer() ? Color.green :
                                        hasAnswered && option == selectedAnswer ? Color.red :
                                        Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .disabled(hasAnswered)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
                
                // Show result feedback
                if hasAnswered {
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: selectedAnswer == getCorrectAnswer() ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(selectedAnswer == getCorrectAnswer() ? .green : .red)
                                .font(.title2)
                            
                            Text(selectedAnswer == getCorrectAnswer() ? "Correct!" : "Incorrect")
                                .font(.title2)
                                .bold()
                                .foregroundColor(selectedAnswer == getCorrectAnswer() ? .green : .red)
                        }
                        
                        if selectedAnswer != getCorrectAnswer() {
                            VStack(spacing: 8) {
                                Text("The correct answer is:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 8) {
                                    VStack(spacing: 4) {
                                        if !card.article.isEmpty {
                                            Text(card.article)
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                                .bold()
                                        }
                                        Text(card.word)
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.green)
                                    }
                                    
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
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Button("Next Question") {
                            nextQuestion()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.headline)
                    }
                }
            }
            
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
        setupCurrentQuestion()
    }
    
    private func setupCurrentQuestion() {
        guard let card = currentCard else { return }
        
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
        guard !hasAnswered else { return }
        
        selectedAnswer = option
        hasAnswered = true
        totalAnswers += 1
        
        let isCorrect = option == getCorrectAnswer()
        if isCorrect {
            correctAnswers += 1
            HapticManager.shared.correctAnswer()
        } else {
            HapticManager.shared.wrongAnswer()
        }
        
        // Record learning statistics
        if let card = currentCard {
            viewModel.recordCardShown(card.id, isCorrect: isCorrect)
        }
        
        // Auto-play pronunciation for incorrect answers
        if !isCorrect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                speakCurrentWord()
            }
        }
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
            showingResults = true
            HapticManager.shared.gameComplete()
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
            HapticManager.shared.successNotification()
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
        let text = textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Use slower speech rate for learning
        speechService.speakDutch(text, rate: 0.4)
    }
    
    private func speakText(_ text: String) {
        let cleanText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanText.isEmpty else { return }
        
        // Use slower speech rate for learning
        speechService.speakDutch(cleanText, rate: 0.4)
    }
}

// MARK: - Save State

struct MultipleChoiceGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let totalAnswers: Int
    let cards: [FlashCard]
} 