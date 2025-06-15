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
    @State private var comboCount = 0
    @State private var showingPeek = false
    @FocusState private var isKeyboardFocused: Bool
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
        VStack(spacing: 25) {
            // Progress indicator with full-width progress bar
            VStack(spacing: 12) {
                HStack {
                    Text("Card \(currentIndex + 1) of \(cards.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Score: \(correctAnswers)/\(totalAnswers)")
                        .font(.caption)
                        .foregroundColor(totalAnswers > 0 ? (Double(correctAnswers)/Double(totalAnswers) >= 0.7 ? .green : .orange) : .primary)
                }
                
                // Full-width progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        // Progress fill
                        Rectangle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [.blue, .purple]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * (cards.count > 0 ? Double(currentIndex) / Double(cards.count) : 0), height: 6)
                            .cornerRadius(3)
                            .animation(.easeInOut(duration: 0.3), value: currentIndex)
                    }
                }
                .frame(height: 6)
                
                // Combo counter
                if comboCount > 0 {
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Text("\(comboCount) combo")
                                .font(.caption)
                                .bold()
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .scaleEffect(comboCount > 5 ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: comboCount)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 50) // Add top padding for status bar
            
            if let card = currentCard {
                // Definition display
                VStack(spacing: 20) {
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
                VStack(spacing: 15) {
                    TextField("Type your answer here...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                        .focused($isKeyboardFocused)
                        .disabled(hasAnswered)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    // Peek functionality
                    if showingPeek && !hasAnswered {
                        VStack(spacing: 8) {
                            Text("The answer is:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(spacing: 12) {
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
                                        .foregroundColor(.blue)
                                }
                                
                                // Pronunciation button for peeked word
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
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .transition(.opacity)
                    }
                    
                    HStack(spacing: 12) {
                        // Peek button
                        if !hasAnswered {
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingPeek.toggle()
                                }
                            }) {
                                Text(showingPeek ? "Hide" : "Peek")
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
                        
                        // Submit button
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
                                
                                HStack(spacing: 8) {
                                    VStack(spacing: 2) {
                                        if !card.article.isEmpty {
                                            Text(card.article)
                                                .font(.caption2)
                                                .foregroundColor(.blue)
                                                .bold()
                                        }
                                        Text(card.word)
                                            .foregroundColor(.green)
                                            .bold()
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
        .onAppear {
            // Auto-play pronunciation for incorrect answers
            if isCorrect == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    speakCurrentWord()
                }
            }
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
            comboCount += 1
            HapticManager.shared.correctAnswer()
            viewModel.setCardStatus(cardId: card.id, status: .known)
        } else {
            comboCount = 0
            HapticManager.shared.wrongAnswer()
            viewModel.setCardStatus(cardId: card.id, status: .unknown)
        }
        
        // Record learning statistics
        viewModel.recordCardShown(card.id, isCorrect: answersMatch)
        
        isKeyboardFocused = false
    }
    
    private func overrideAnswer() {
        guard let card = currentCard else { return }
        
        // Change incorrect to correct
        if isCorrect == false {
            correctAnswers += 1
            comboCount += 1
            isCorrect = true
            HapticManager.shared.correctAnswer()
            viewModel.setCardStatus(cardId: card.id, status: .known)
            
            // Record corrected answer as correct
            viewModel.recordCardShown(card.id, isCorrect: true)
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
            
            HapticManager.shared.gameComplete()
            StreakManager.shared.recordGameCompletion(); showingResults = true
        }
    }
    
    private func resetForNextCard() {
        userInput = ""
        hasAnswered = false
        isCorrect = nil
        showingOverride = false
        showingPeek = false
        isKeyboardFocused = true
    }
    
    private func resetGame() {
        cards = viewModel.sortCardsForLearning(cards)
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        comboCount = 0
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
