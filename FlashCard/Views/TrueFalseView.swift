import SwiftUI

struct TrueFalseQuestion {
    let word: String
    let definition: String
    let isCorrect: Bool
    let originalCard: FlashCard
}

struct TrueFalseView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestion: TrueFalseQuestion?
    @State private var remainingCards: [FlashCard]
    @State private var score = 0
    @State private var questionsAnswered = 0
    @State private var showingGameOver = false
    @State private var feedback = ""
    @State private var showingFeedback = false
    @State private var feedbackColor = Color.green
    @State private var showingResults = false
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var incorrectAnswers = 0
    @State private var showingCloseConfirmation = false
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return questionsAnswered > 0 || score > 0
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        self.cards = cards
        _remainingCards = State(initialValue: cards)
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
                trueFalseView
            }
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    if questionsAnswered > 0 && !showingResults {
                        showingCloseConfirmation = true
                    } else {
                        dismiss()
                    }
                }) {
                    VStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    resetGame()
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
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                resetGame()
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
                if hasSignificantProgress && !showingResults {
                    saveCurrentProgress()
                }
                dismissToRoot()
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
                    
                    Text("Score: \(score)/\(questionsAnswered)")
                        .font(.headline)
                }
                .padding(.top)
                
                // Action buttons
                VStack(spacing: 15) {
                    Button(action: {
                        // Explicitly save all ViewModel data to ensure statistics persist
                        viewModel.saveAllData()
                        
                        // Force UI refresh
                        DispatchQueue.main.async {
                            viewModel.objectWillChange.send()
                        }
                        
                        resetGame()
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
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to play")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
        }
    }
    
    private var trueFalseView: some View {
        VStack(spacing: 20) {
            // Score display - with top padding for status bar
            HStack {
                Text("Score: \(score)/\(questionsAnswered)")
                    .font(.headline)
                Spacer()
                Text("Remaining: \(remainingCards.count)")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            if let question = currentQuestion {
                // Question display
                VStack(spacing: 20) {
                    Text("Does the word:")
                        .font(.title3)
                    
                    Text(question.word)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("mean:")
                        .font(.title3)
                    
                    Text(question.definition)
                        .font(.title3)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Answer buttons
                VStack(spacing: 15) {
                    Button(action: { checkAnswer(true) }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("True")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: { checkAnswer(false) }) {
                        HStack {
                            Image(systemName: "x.circle.fill")
                            Text("False")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            
            if showingFeedback {
                Text(feedback)
                    .font(.title2)
                    .foregroundColor(feedbackColor)
                    .padding()
            }
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 20) {
            Text("Game Complete! 🎉")
                .font(.title)
                .multilineTextAlignment(.center)
            
            Text("Score: \(correctAnswers) / \(correctAnswers + incorrectAnswers)")
                .font(.title2)
            
            Text("\(Int((Double(correctAnswers) / Double(correctAnswers + incorrectAnswers)) * 100))%")
                .font(.largeTitle)
                .bold()
                .foregroundColor(
                    Double(correctAnswers) / Double(correctAnswers + incorrectAnswers) >= 0.7 ? .green : .red
                )
            
            VStack(spacing: 16) {
                Button(action: {
                    // Explicitly save all ViewModel data to ensure statistics persist
                    viewModel.saveAllData()
                    
                    // Force UI refresh
                    DispatchQueue.main.async {
                        viewModel.objectWillChange.send()
                    }
                    
                    resetGame()
                    showingResults = false
                }) {
                    Text("Play Again")
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
    
    private func setupNextQuestion() {
        guard !remainingCards.isEmpty else {
            showingResults = true
            return
        }
        
        // Select a random card for the word
        let wordCard = remainingCards.randomElement()!
        
        // Decide if this will be a true or false question (50/50 chance)
        let isCorrect = Bool.random()
        
        let definition: String
        if isCorrect {
            // Use the correct definition
            definition = wordCard.definition
        } else {
            // Use a definition from another random card
            let otherCards = cards.filter { $0.id != wordCard.id }
            if let randomCard = otherCards.randomElement() {
                definition = randomCard.definition
            } else {
                // If no other cards available, use the correct definition
                definition = wordCard.definition
            }
        }
        
        currentQuestion = TrueFalseQuestion(
            word: wordCard.word,
            definition: definition,
            isCorrect: isCorrect,
            originalCard: wordCard
        )
        
        // Remove the used card from remaining cards
        remainingCards.removeAll { $0.id == wordCard.id }
    }
    
    private func checkAnswer(_ answer: Bool) {
        guard let question = currentQuestion else { return }
        
        questionsAnswered += 1
        let isCorrect = answer == question.isCorrect
        
        if isCorrect {
            score += 1
            feedback = "Correct! 🎉"
            feedbackColor = .green
            correctAnswers += 1
        } else {
            feedback = "Wrong! Try again!"
            feedbackColor = .red
            incorrectAnswers += 1
        }
        
        // Record learning statistics - only count when the question shows the correct definition
        if question.isCorrect {
            viewModel.recordCardShown(question.originalCard.id, isCorrect: isCorrect)
        }
        
        showingFeedback = true
        
        // Auto-save progress periodically (every 5 questions)
        if questionsAnswered % 5 == 0 {
            saveCurrentProgress()
        }
        
        // Clear feedback and show next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showingFeedback = false
            if remainingCards.isEmpty {
                // Clear saved progress since game is complete
                clearSavedProgress()
                showingResults = true
            } else {
                setupNextQuestion()
            }
        }
    }
    
    private func resetGame() {
        remainingCards = cards
        score = 0
        questionsAnswered = 0
        correctAnswers = 0
        incorrectAnswers = 0
        showingFeedback = false
        showingResults = false
        setupNextQuestion()
        
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
    
    private func saveCurrentProgress() {
        guard !deckIds.isEmpty && hasSignificantProgress else { return }
        
        let gameState = TrueFalseGameState(
            currentIndex: currentIndex,
            score: score,
            questionsAnswered: questionsAnswered,
            correctAnswers: correctAnswers,
            incorrectAnswers: incorrectAnswers,
            remainingCards: remainingCards,
            cards: cards
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .trueFalse,
            deckIds: deckIds,
            gameData: gameState
        )
        
        print("💾 True/False progress saved - Score: \(score), Questions: \(questionsAnswered)")
    }
    
    private func loadSavedProgress() {
        guard !deckIds.isEmpty else { 
            resetGame()
            return 
        }
        
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .trueFalse,
            deckIds: deckIds,
            as: TrueFalseGameState.self
        ) {
            // Restore state
            currentIndex = savedState.currentIndex
            score = savedState.score
            questionsAnswered = savedState.questionsAnswered
            correctAnswers = savedState.correctAnswers
            incorrectAnswers = savedState.incorrectAnswers
            remainingCards = savedState.remainingCards
            
            // Update cards to match saved order if they exist
            if !savedState.cards.isEmpty {
                // Filter to only include cards that still exist in the current deck selection
                let currentCardIds = Set(cards.map { $0.id })
                let savedCards = savedState.cards.filter { currentCardIds.contains($0.id) }
                
                if !savedCards.isEmpty {
                    // Update the cards array but keep the original as reference
                    let filteredRemainingCards = savedState.remainingCards.filter { currentCardIds.contains($0.id) }
                    remainingCards = filteredRemainingCards
                }
            }
            
            // Set up next question if there are remaining cards
            if !remainingCards.isEmpty {
                setupNextQuestion()
            } else {
                showingResults = true
            }
            
            print("🔥 True/False progress loaded - Score: \(score), Questions: \(questionsAnswered)")
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("🔥 No saved state found, starting fresh True/False game")
            resetGame()
        }
    }
    
    private func clearSavedProgress() {
        guard !deckIds.isEmpty else { return }
        
        SaveStateManager.shared.deleteSaveState(
            gameType: .trueFalse,
            deckIds: deckIds
        )
    }
}

// Preview provider for SwiftUI canvas
struct TrueFalseView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FlashCardViewModel()
        let sampleCards = [
            FlashCard(word: "Hello", definition: "A greeting", example: "Hello, how are you?"),
            FlashCard(word: "Goodbye", definition: "A farewell", example: "Goodbye, see you later!")
        ]
        TrueFalseView(viewModel: viewModel, cards: sampleCards)
    }
} 