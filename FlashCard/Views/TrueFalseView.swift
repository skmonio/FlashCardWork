import SwiftUI
import SpriteKit
import os

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
    @State private var showingResults = false
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var incorrectAnswers = 0
    @State private var showingCloseConfirmation = false
    @State private var isShowingExample = false
    
    // SpriteKit for confetti celebration (unused, remove if not needed elsewhere)
    @State private var hasAnswered = false
    @State private var selectedAnswer: Bool? = nil
    
    // SpriteKit scene for effects
    @State private var gameScene = GameScene()
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Add speech service for pronunciation
    @ObservedObject private var speechService = DutchSpeechService.shared
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return questionsAnswered > 0 || score > 0
    }
    
    // Get the text to speak for current card
    private var textToSpeak: String {
        guard let question = currentQuestion else { return "" }
        return question.originalCard.article.isEmpty ? question.word : "\(question.originalCard.article) \(question.word)"
    }
    
    // Check if current word is being spoken
    private var isCurrentWordSpeaking: Bool {
        return speechService.isSpeaking && speechService.currentlySpeaking == textToSpeak
    }
    
    private let logger = Logger(subsystem: "com.flashcards", category: "TrueFalseView")
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        let sortedCards = viewModel.sortCardsForLearning(cards)
        self.cards = sortedCards
        _remainingCards = State(initialValue: sortedCards)
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
            // Dismiss this view when dismiss to root is requested
            dismiss()
        }
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                setupGame()
            }
        }
        .onDisappear {
            // Auto-save when view disappears (if user navigates away without using back button)
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
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
    
    private var gameView: some View {
        ZStack {
            VStack(spacing: 0) {
                // Use same header as TestView (no audio button)
                GameHeaderView(
                    currentIndex: questionsAnswered + 1,
                    totalCards: max(remainingCards.count + questionsAnswered, 1),
                    score: score * 10, // Convert to scoring system like other games
                    combo: 0, // True/False doesn't have combo system
                    knownCount: nil,
                    unknownCount: nil,
                    skippedCount: nil
                )
                
                Spacer()
                
                if let question = currentQuestion {
                    // Title at top - "True OR False" in bold
                    Text("True OR False")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    
                    // Question text - "Does the word"
                    Text("Does the word")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 10)
                    
                    // Question card (tappable for audio, double-tap for example)
                    Button(action: {
                        speakCurrentWord()
                        HapticManager.shared.lightImpact()
                    }) {
                        VStack(spacing: 16) {
                            // Word with optional article
                            VStack(spacing: 4) {
                                if !question.originalCard.article.isEmpty {
                                    Text(question.originalCard.article)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .bold()
                                }
                                Text(question.word)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // Example (if showing) - plain text, centered
                            if isShowingExample && !question.originalCard.example.isEmpty {
                                Text(question.originalCard.example)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(4)
                                    .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(24)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(.secondarySystemGroupedBackground))
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture(count: 2) {
                        // Double tap to show/hide example
                        HapticManager.shared.lightImpact()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isShowingExample.toggle()
                        }
                    }
                    .onTapGesture(count: 1) {
                        // Single tap for audio
                        speakCurrentWord()
                        HapticManager.shared.lightImpact()
                    }
                    
                    Spacer()
                    
                    // "mean:" text above definition
                    Text("mean")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.bottom, 10)
                    
                    // Definition display
                    Text(question.definition)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Spacer()
                    
                    // Answer buttons (side by side, half width each)
                    HStack(spacing: 12) {
                        Button(action: { checkAnswer(true) }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("True")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
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
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            
            // SpriteKit overlay for particle effects (non-interactive)
            SpriteKitGameView(scene: gameScene)
                .allowsHitTesting(false)
                .ignoresSafeArea()
        }
        .onAppear {
            print("🎯 TrueFalseView appeared - initializing SpriteKit scene")
            setupSpriteKitScene()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("True or False Complete!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            VStack(spacing: 15) {
                Text("Final Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(correctAnswers) / \(correctAnswers + incorrectAnswers)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Double(correctAnswers)/Double(correctAnswers + incorrectAnswers) >= 0.7 ? .green : .orange)
                
                let totalQuestions = correctAnswers + incorrectAnswers
                let percentage = totalQuestions > 0 ? Int((Double(correctAnswers) / Double(totalQuestions)) * 100) : 0
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
        }
        .padding()
    }
    
    private func setupNextQuestion() {
        guard !remainingCards.isEmpty else {
            HapticManager.shared.gameComplete()
            StreakManager.shared.recordGameCompletion(); showingResults = true
            return
        }
        
        // Reset example state for new question
        isShowingExample = false
        
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
            correctAnswers += 1
            
            // Show SpriteKit success effect instead of text
            let centerPoint = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2)
            gameScene.createSuccessParticles(at: centerPoint)
            gameScene.createFloatingScore(score: "+10", at: centerPoint, color: .systemGreen)
            
            // Use custom sound for games (not study mode)
            HapticManager.shared.successNotification() // Haptic only
            SoundManager.shared.playTestCorrectSound() // Custom Correct.wav
        } else {
            incorrectAnswers += 1
            
            // Show SpriteKit error effect instead of text
            let centerPoint = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2)
            gameScene.createErrorEffect(at: centerPoint)
            
            // Use custom sound for games (not study mode)
            HapticManager.shared.errorNotification() // Haptic only
            SoundManager.shared.playTestWrongSound() // Custom Wrong.wav
        }
        
        // Record learning statistics - only count when the question shows the correct definition
        if question.isCorrect {
            viewModel.recordCardShown(question.originalCard.id, isCorrect: isCorrect)
        }
        
        // Auto-save progress periodically (every 5 questions)
        if questionsAnswered % 5 == 0 {
            saveCurrentProgress()
        }
        
        // Clear feedback and show next question after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if remainingCards.isEmpty {
                // Clear saved progress since game is complete
                clearSavedProgress()
                HapticManager.shared.gameComplete()
                StreakManager.shared.recordGameCompletion(); showingResults = true
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
        showingResults = false
        isShowingExample = false
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
        guard hasSignificantProgress else { return }
        
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
            gameData: gameState
        )
        
        print("💾 True/False progress saved - Score: \(score), Questions: \(questionsAnswered)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .trueFalse,
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
                HapticManager.shared.gameComplete()
                StreakManager.shared.recordGameCompletion(); showingResults = true
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
        SaveStateManager.shared.deleteSaveState(gameType: .trueFalse)
    }
    
    private func saveProgressAndDismiss() {
        if hasSignificantProgress && !showingResults {
            saveCurrentProgress()
        }
        dismissToRoot()
    }
    
    private func setupGame() {
        remainingCards = cards
        score = 0
        questionsAnswered = 0
        correctAnswers = 0
        incorrectAnswers = 0
        showingResults = false
        setupNextQuestion()
        
        // Clear any saved progress when resetting
        clearSavedProgress()
    }
    
    private func speakCurrentWord() {
        let text = textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Use slower speech rate for learning
        speechService.speakDutch(text, rate: 0.4)
    }
    
    private func setupSpriteKitScene() {
        // Create a properly sized scene
        let sceneSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        gameScene.size = sceneSize
        gameScene.scaleMode = .resizeFill
        print("🎮 TrueFalseView SpriteKit scene setup with size: \(sceneSize)")
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