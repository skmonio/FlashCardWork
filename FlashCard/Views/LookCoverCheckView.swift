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
            } else if showingResults {
                resultsView
            } else {
                gameView
            }
            
            // Bottom Navigation Bar
            bottomNavigationBar
        }
        .navigationBarHidden(true)
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
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
                
                // Display the word prominently
                Text(card.word)
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(radius: 5)
                    )
                    .padding(.horizontal)
                
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
                        Text(card.word)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
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
                resetGame()
            }
            .buttonStyle(.borderedProminent)
            .font(.headline)
        }
    }
    
    private var bottomNavigationBar: some View {
        HStack {
            Button(action: {
                if totalAnswers > 0 && !showingResults {
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
    
    private func checkAnswer() {
        guard let card = currentCard else { return }
        
        let userAnswer = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswer = card.word.lowercased()
        
        let correct = userAnswer == correctAnswer
        isCorrect = correct
        totalAnswers += 1
        
        if correct {
            correctAnswers += 1
            HapticManager.shared.correctAnswer()
        } else {
            HapticManager.shared.wrongAnswer()
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
        cards = cards.shuffled()
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        resetForNextCard()
        
        // Clear any saved progress when resetting
        clearSavedProgress()
    }
    
    private func saveCurrentProgress() {
        guard !deckIds.isEmpty && hasSignificantProgress else { return }
        
        let gameState = LookCoverCheckGameState(
            currentIndex: currentIndex,
            correctAnswers: correctAnswers,
            totalAnswers: totalAnswers,
            cards: cards,
            gamePhase: gamePhase.rawValue
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .lookCoverCheck,
            deckIds: deckIds,
            gameData: gameState
        )
        
        print("💾 Look Cover Check progress saved - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
    }
    
    private func loadSavedProgress() {
        guard !deckIds.isEmpty else { 
            resetGame()
            return 
        }
        
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .lookCoverCheck,
            deckIds: deckIds,
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
        guard !deckIds.isEmpty else { return }
        
        SaveStateManager.shared.deleteSaveState(
            gameType: .lookCoverCheck,
            deckIds: deckIds
        )
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