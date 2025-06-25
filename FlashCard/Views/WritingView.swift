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
    @State private var showingOverride = false
    @State private var showingCloseConfirmation = false
    @State private var comboCount = 0
    @State private var showingPeek = false
    @State private var showLetterMode = false // New state for showing letter hints
    @State private var lettersRevealed = 0 // Track how many letters have been revealed
    @FocusState private var isKeyboardFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    // Add speech service for pronunciation
    @StateObject private var speechService = DutchSpeechService.shared
    
    // Add user profile manager for XP tracking
    @StateObject private var userProfileManager = UserProfileManager.shared
    
    // Session XP tracking
    @State private var sessionXP: Int = 0 // Track XP gained during current session
    
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
        VStack(spacing: 0) {
            // Unified header with progress bar
            GameHeaderView(
                currentIndex: currentIndex + 1,
                totalCards: cards.count,
                score: userProfileManager.xp, // Use current XP instead of calculated score
                combo: comboCount,
                knownCount: nil,
                unknownCount: nil,
                skippedCount: nil,
                sessionXP: sessionXP
            )
            
            if let card = currentCard {
                VStack(spacing: 20) {
                    // Definition display with reduced spacing
                    VStack(spacing: 15) {
                        Text("Write the translation for the word:")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text(card.definition)
                            .font(.title2)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Peek display (simplified - just shows the word)
                    if showingPeek && !hasAnswered {
                        VStack(spacing: 8) {
                            Text("The answer is:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
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
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .transition(.opacity)
                    }
                    
                    // Button row: Peek, Letters, Submit
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
                        
                        // Toggle letters hint button
                        if !hasAnswered {
                            Button(action: {
                                revealNextLetter()
                                HapticManager.shared.lightImpact()
                            }) {
                                Text("Letters")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .disabled(isWordComplete)
                        }
                        
                        // Submit button
                        if !hasAnswered {
                            Button(action: checkAnswer) {
                                Text("Submit")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(isAnswerReady ? Color.green : Color.gray)
                                    .cornerRadius(8)
                            }
                            .disabled(!isAnswerReady)
                        }
                    }
                    
                    // Text input (always shown when not answered)
                    if !hasAnswered {
                        TextField("Type your answer here", text: $userInput)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .focused($isKeyboardFocused)
                            .autocapitalization(.none)
                            .disableAutocorrection(false)
                            .keyboardType(.default)
                            .textContentType(.none)
                            .onSubmit {
                                if !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    checkAnswer()
                                }
                            }
                            .onChange(of: userInput) { newValue in
                                // Reset letter count if user manually edits the text
                                lettersRevealed = min(newValue.count, currentCard?.word.count ?? 0)
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
                
                Button(action: {
                    dismissToRoot()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
    }
    
    // MARK: - Game Logic
    
    private var isAnswerReady: Bool {
        // Always check if there's text input since we only use typing mode now
        return !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func checkAnswer() {
        guard let card = currentCard else { return }
        
        HapticManager.shared.buttonTap()
        
        let correctAnswer = card.word.lowercased()
        let userAnswer = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Check for exact match or close match
        let answersMatch = userAnswer == correctAnswer || 
                          userAnswer.replacingOccurrences(of: " ", with: "") == correctAnswer.replacingOccurrences(of: " ", with: "")
        
        isCorrect = answersMatch
        hasAnswered = true
        totalAnswers += 1
        
        if answersMatch {
            correctAnswers += 1
            comboCount += 1
            // Use custom sound for games (not study mode)
            HapticManager.shared.successNotification() // Haptic only
            SoundManager.shared.playTestCorrectSound() // Custom Correct.wav
            viewModel.setCardStatus(cardId: card.id, status: .known)
            
            // Add XP for correct answer
            userProfileManager.addXP(15)
            sessionXP += 15
        } else {
            comboCount = 0
            // Use custom sound for games (not study mode)
            HapticManager.shared.errorNotification() // Haptic only
            SoundManager.shared.playTestWrongSound() // Custom Wrong.wav
            viewModel.setCardStatus(cardId: card.id, status: .unknown)
            
            // Add XP for attempting (even if wrong)
            userProfileManager.addXP(5)
            sessionXP += 5
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
            // Use custom sound for games (not study mode)
            HapticManager.shared.successNotification() // Haptic only
            SoundManager.shared.playTestCorrectSound() // Custom Correct.wav
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
        showLetterMode = false // Reset letter hint
        lettersRevealed = 0
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
    
    private func revealNextLetter() {
        guard let card = currentCard else { return }
        let correctWord = card.word
        
        if lettersRevealed < correctWord.count {
            let index = correctWord.index(correctWord.startIndex, offsetBy: lettersRevealed)
            let nextLetter = correctWord[index]
            userInput += String(nextLetter)
            lettersRevealed += 1
        }
    }
    
    private var isWordComplete: Bool {
        guard let card = currentCard else { return false }
        return lettersRevealed >= card.word.count
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
