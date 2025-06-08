import SwiftUI

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
    @State private var showingOverride = false
    @State private var showingCloseConfirmation = false
    @FocusState private var isKeyboardFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
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
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        _cards = State(initialValue: cards.shuffled())
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if cards.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if showingResults {
                resultsView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                gameView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom Navigation Bar
            bottomNavigationBar
        }
        .navigationBarHidden(true)
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                // Initialize normally - reset to first card and prepare for input
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
        VStack(spacing: 40) {
            // Progress indicator - with top padding for status bar
            HStack {
                Text("Card \(currentIndex + 1) of \(cards.count)")
                    .font(.headline)
                Spacer()
                Text("Score: \(correctAnswers)/\(totalAnswers)")
                    .font(.headline)
                    .foregroundColor(totalAnswers > 0 ? (Double(correctAnswers)/Double(totalAnswers) >= 0.7 ? .green : .orange) : .primary)
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            if let card = currentCard {
                // Definition display
                VStack(spacing: 25) {
                    Text("What is the word for:")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text(card.definition)
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Input section
                VStack(spacing: 20) {
                    TextField("Type your answer here...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                        .focused($isKeyboardFocused)
                        .disabled(hasAnswered)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if !hasAnswered {
                        Button(action: checkAnswer) {
                            Text("Submit Answer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                
                // Answer feedback
                if hasAnswered {
                    answerFeedbackView(for: card)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
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
                                Text("Your answer:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(userInput)
                                    .foregroundColor(.red)
                            }
                            
                            HStack {
                                Text("Correct answer:")
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(card.word)
                                    .foregroundColor(.green)
                                    .bold()
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
                if isCorrect == false {
                    Button(action: {
                        showingOverride = true
                    }) {
                        Text("I Was Right")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange, lineWidth: 1)
                            )
                    }
                }
                
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
        .alert("Override Answer", isPresented: $showingOverride) {
            Button("Cancel", role: .cancel) { }
            Button("Mark as Correct") {
                overrideAnswer()
            }
        } message: {
            Text("Are you sure your answer was correct? This will count as a correct answer.")
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Writing Session Complete!")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
            }
            
            // Score summary
            VStack(spacing: 12) {
                HStack {
                    Text("Final Score:")
                        .font(.title3)
                    Spacer()
                    Text("\(correctAnswers)/\(totalAnswers)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(totalAnswers > 0 ? (Double(correctAnswers)/Double(totalAnswers) >= 0.7 ? .green : .orange) : .primary)
                }
                
                let percentage = totalAnswers > 0 ? Int((Double(correctAnswers) / Double(totalAnswers)) * 100) : 0
                HStack {
                    Text("Accuracy:")
                        .font(.title3)
                    Spacer()
                    Text("\(percentage)%")
                        .font(.title2)
                        .bold()
                        .foregroundColor(percentage >= 70 ? .green : .orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Action buttons
            VStack(spacing: 12) {
                Button(action: resetGame) {
                    Text("Practice Again")
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
        }
        .padding(.horizontal)
    }
    
    private var bottomNavigationBar: some View {
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
    
    // MARK: - Game Logic
    
    private func checkAnswer() {
        guard let card = currentCard else { return }
        
        HapticManager.shared.buttonTap()
        
        let userAnswer = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswer = card.word.lowercased()
        
        // Check for exact match or close match
        let answersMatch = userAnswer == correctAnswer || 
                          userAnswer.replacingOccurrences(of: " ", with: "") == correctAnswer.replacingOccurrences(of: " ", with: "")
        
        isCorrect = answersMatch
        hasAnswered = true
        totalAnswers += 1
        
        if answersMatch {
            correctAnswers += 1
            HapticManager.shared.correctAnswer()
            viewModel.setCardStatus(cardId: card.id, status: .known)
        } else {
            HapticManager.shared.wrongAnswer()
            viewModel.setCardStatus(cardId: card.id, status: .unknown)
        }
        
        isKeyboardFocused = false
    }
    
    private func overrideAnswer() {
        guard let card = currentCard else { return }
        
        // Change incorrect to correct
        if isCorrect == false {
            correctAnswers += 1
            isCorrect = true
            HapticManager.shared.correctAnswer()
            viewModel.setCardStatus(cardId: card.id, status: .known)
        }
    }
    
    private func nextCard() {
        // Auto-save progress periodically (every 5 cards)
        if currentIndex % 5 == 0 && currentIndex > 0 {
            saveCurrentProgress()
        }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            resetForNextCard()
        } else {
            // Clear saved progress since game is complete
            clearSavedProgress()
            
            showingResults = true
        }
    }
    
    private func resetForNextCard() {
        userInput = ""
        hasAnswered = false
        isCorrect = nil
        showingOverride = false
        isKeyboardFocused = true
    }
    
    private func resetGame() {
        cards = cards.shuffled()
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        resetForNextCard()
        
        // Clear any saved progress when resetting
        clearSavedProgress()
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
        
        let gameState = WritingGameState(
            currentIndex: currentIndex,
            correctAnswers: correctAnswers,
            totalAnswers: totalAnswers,
            cards: cards
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .writing,
            deckIds: deckIds,
            gameData: gameState
        )
        
        print("💾 Writing practice progress saved - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
    }
    
    private func loadSavedProgress() {
        guard !deckIds.isEmpty else { 
            // If no deckIds, just start normally
            resetForNextCard()
            return 
        }
        
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .writing,
            deckIds: deckIds,
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
        guard !deckIds.isEmpty else { return }
        
        SaveStateManager.shared.deleteSaveState(
            gameType: .writing,
            deckIds: deckIds
        )
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