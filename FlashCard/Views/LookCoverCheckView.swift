import SwiftUI

struct LookCoverCheckView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var totalAnswers = 0
    @State private var showingResults = false
    @State private var userInput = ""
    @State private var gamePhase: GamePhase = .look
    @State private var isCorrect: Bool? = nil
    @State private var showingCloseConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    // Add speech service for pronunciation
    @ObservedObject private var speechService = DutchSpeechService.shared
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return currentIndex > 0 || totalAnswers > 0
    }
    
    enum GamePhase: String {
        case look      // Show the word
        case cover     // Hide word, show input field
        case check     // Show result and comparison
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
        .alert("Close Session?", isPresented: $showingCloseConfirmation) {
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
            // Dismiss this view when dismiss to root is requested
            dismiss()
        }
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                setupSession()
            }
        }
        .onDisappear {
            // Auto-save when view disappears (if user navigates away without using back button)
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
    }
    
    private func saveProgressAndDismiss() {
        if hasSignificantProgress && !showingResults {
            saveCurrentProgress()
        }
        dismissToRoot()
    }
    
    private func setupSession() {
        // Initialize session state
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        gamePhase = .look
        showingResults = false
        userInput = ""
        cards = viewModel.sortCardsForLearning(cards)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "eye.slash")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Cards Available")
                .font(.title2)
                .bold()
            
            Text("Add some cards to your decks to practice with Look Cover Check.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var gameView: some View {
        VStack(spacing: 30) {
            // Unified header with progress bar
            GameHeaderView(
                currentIndex: currentIndex + 1,
                totalCards: cards.count,
                score: correctAnswers * 10, // Convert to scoring system like other games
                combo: 0, // Look Cover Check doesn't have combo system
                knownCount: nil,
                unknownCount: nil,
                skippedCount: nil
            )
            
            if let card = currentCard {
                switch gamePhase {
                case .look:
                    lookPhaseView(card: card)
                case .cover:
                    coverPhaseView(card: card)
                case .check:
                    checkPhaseView(card: card)
                }
            }
            
            Spacer()
        }
    }
    
    private func lookPhaseView(card: FlashCard) -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("Look at this word:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Display the word prominently with pronunciation
                VStack(spacing: 15) {
                    VStack(spacing: 8) {
                        if !card.article.isEmpty {
                            Text(card.article)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .bold()
                        }
                        Text(card.word)
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                    
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
                            Text(isCurrentWordSpeaking ? "Stop" : "Listen")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                    }
                }
                
                // Show definition as context
                Text(card.definition)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button("Cover") {
                gamePhase = .cover
                HapticManager.shared.lightImpact()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
            .controlSize(.large)
        }
        .onAppear {
            // Auto-play pronunciation when word appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speakCurrentWord()
            }
        }
    }
    
    private func coverPhaseView(card: FlashCard) -> some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Text("Now write the word from memory:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Hidden word placeholder
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .overlay(
                        Text("Word is covered")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    )
                    .padding(.horizontal)
                
                // Input field
                TextField("Type the word here...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button("Check") {
                checkAnswer()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
            .controlSize(.large)
            .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
    
    private func checkPhaseView(card: FlashCard) -> some View {
        VStack(spacing: 30) {
            // Show result
            VStack(spacing: 20) {
                if let correct = isCorrect {
                    HStack {
                        Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(correct ? .green : .red)
                            .font(.system(size: 40))
                        
                        Text(correct ? "Correct!" : "Incorrect")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(correct ? .green : .red)
                    }
                }
                
                // Show comparison
                VStack(spacing: 15) {
                    VStack(spacing: 8) {
                        Text("Correct word:")
                            .font(.headline)
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
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            
                            // Pronunciation button for correct word
                            Button(action: {
                                if isCurrentWordSpeaking {
                                    speechService.stopSpeaking()
                                } else {
                                    speakCurrentWord()
                                }
                                HapticManager.shared.lightImpact()
                            }) {
                                Image(systemName: isCurrentWordSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.green.opacity(0.1))
                        )
                    }
                    
                    VStack(spacing: 8) {
                        Text("Your answer:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(userInput.isEmpty ? "(empty)" : userInput)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(isCorrect == true ? .green : .red)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill((isCorrect == true ? Color.green : Color.red).opacity(0.1))
                            )
                    }
                }
            }
            
            Button("Next") {
                nextCard()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
            .controlSize(.large)
        }
        .onAppear {
            // Auto-play correct word pronunciation in check phase
            if isCorrect == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    speakCurrentWord()
                }
            }
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Practice Complete!")
                .font(.largeTitle)
                .bold()
            
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
            
            Button("Practice Again") {
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
    }
    
    private func checkAnswer() {
        guard let card = currentCard else { return }
        
        let userAnswer = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswer = card.word.lowercased()
        
        let correct = userAnswer == correctAnswer
        isCorrect = correct
        totalAnswers += 1
        
        if correct {
            correctAnswers += 1
            // Use custom sound for games (not study mode)
            HapticManager.shared.successNotification() // Haptic only
            SoundManager.shared.playTestCorrectSound() // Custom Correct.wav
        } else {
            // Use custom sound for games (not study mode)
            HapticManager.shared.errorNotification() // Haptic only
            SoundManager.shared.playTestWrongSound() // Custom Wrong.wav
        }
        
        // Record learning statistics
        viewModel.recordCardShown(card.id, isCorrect: correct)
        
        gamePhase = .check
    }
    
    private func nextCard() {
        // Auto-save progress periodically (every 5 cards)
        if currentIndex % 5 == 0 && currentIndex > 0 {
            saveCurrentProgress()
        }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            resetForNextCard()
            
            // Auto-play pronunciation for new word in look phase
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speakCurrentWord()
            }
        } else {
            // Clear saved progress since game is complete
            clearSavedProgress()
            showingResults = true
            HapticManager.shared.gameComplete()
        }
    }
    
    private func resetForNextCard() {
        userInput = ""
        gamePhase = .look
        isCorrect = nil
    }
    
    private func resetGame() {
        cards = viewModel.sortCardsForLearning(cards)
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        resetForNextCard()
        
        // Clear any saved progress when resetting
        clearSavedProgress()
    }
    
    private func saveCurrentProgress() {
        guard hasSignificantProgress else { return }
        
        let gameState = LookCoverCheckGameState(
            currentIndex: currentIndex,
            correctAnswers: correctAnswers,
            totalAnswers: totalAnswers,
            cards: cards,
            gamePhase: gamePhase.rawValue
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .lookCoverCheck,
            gameData: gameState
        )
        
        print("💾 Look Cover Check progress saved - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .lookCoverCheck,
            as: LookCoverCheckGameState.self
        ) {
            // Restore state
            currentIndex = savedState.currentIndex
            correctAnswers = savedState.correctAnswers
            totalAnswers = savedState.totalAnswers
            
            // Restore game phase
            if let phase = GamePhase(rawValue: savedState.gamePhase) {
                gamePhase = phase
            } else {
                gamePhase = .look
            }
            
            // Reset userInput since we don't save it (user can re-enter)
            userInput = ""
            isCorrect = nil
            
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
            
            print("👁️ Look Cover Check progress loaded - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("👁️ No saved state found, starting fresh Look Cover Check")
            resetGame()
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .lookCoverCheck)
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