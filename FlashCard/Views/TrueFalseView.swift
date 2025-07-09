import SwiftUI
import SpriteKit
import os

struct TrueFalseQuestion: Hashable {
    let word: String
    let definition: String
    let isCorrect: Bool
    let originalCard: FlashCard
    
    // Implement Hashable manually since FlashCard might not be Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(definition)
        hasher.combine(isCorrect)
        hasher.combine(originalCard.id)
    }
    
    static func == (lhs: TrueFalseQuestion, rhs: TrueFalseQuestion) -> Bool {
        return lhs.word == rhs.word &&
               lhs.definition == rhs.definition &&
               lhs.isCorrect == rhs.isCorrect &&
               lhs.originalCard.id == rhs.originalCard.id
    }
}

struct TrueFalseView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
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
    @State private var incorrectCards: Set<UUID> = [] // Track which cards were answered incorrectly
    @State private var showingCloseConfirmation = false
    @State private var isShowingExample = false
    
    // SpriteKit for confetti celebration (unused, remove if not needed elsewhere)
    @State private var hasAnswered = false
    @State private var selectedAnswer: Bool? = nil
    @State private var showingFeedback = false
    @State private var userAnswer: Bool? = nil
    
    // SpriteKit scene for effects
    @State private var gameScene = GameScene()
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Progressive study properties
    private var studyMode: StudyMode?
    private var onLevelComplete: ((LevelResult) -> Void)?
    private var maxQuestions: Int?
    
    // Navigation state variables for back/next functionality
    @State private var maxProgressIndex: Int = 1
    @State private var hasGoneBack: Bool = false
    @State private var answerHistory: [Int: Bool] = [:]
    @State private var hasAnsweredHistory: [Int: Bool] = [:]
    @State private var questionHistory: [Int: TrueFalseQuestion] = [:]
    
    // Session tracking for SRS
    @State private var currentSession: StudySession?
    @State private var sessionStartTime: Date = Date()
    @State private var sessionXP: Int = 0 // Track XP gained during current session
    @StateObject private var statsManager = StatisticsManager.shared
    @StateObject private var srsManager = SRSManager.shared
    @StateObject private var userProfileManager = UserProfileManager.shared
    
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
    
    @State private var selectedCardForEdit: FlashCard? = nil
    @State private var forceRefreshID = UUID()
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false, studyMode: StudyMode? = nil, maxQuestions: Int? = nil, onLevelComplete: ((LevelResult) -> Void)? = nil) {
        self.viewModel = viewModel
        self.studyMode = studyMode
        self.maxQuestions = maxQuestions
        self.onLevelComplete = onLevelComplete
        
        // Apply intelligent ordering based on study mode
        let sortedCards: [FlashCard]
        if let studyMode = studyMode {
            sortedCards = SmartStudyManager.shared.sortCardsForStudyMode(cards, mode: studyMode)
        } else {
            sortedCards = viewModel.sortCardsForLearning(cards)
        }
        
        self._cards = State(initialValue: sortedCards)
        _remainingCards = State(initialValue: sortedCards)
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
    }
    
    var body: some View {
        ZStack {
        VStack(spacing: 0) {
            if cards.isEmpty {
                emptyStateView
            } else if showingResults {
                resultsView
            } else {
                gameView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    handleBackButton()
                }
            }
        }
        .navigationTitle("True or False")
        .navigationBarTitleDisplayMode(.inline)
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
            // Start session tracking
            sessionStartTime = Date()
            currentSession = statsManager.startSession(deckIds: deckIds, cardCount: cards.count)
            
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
            .onChange(of: selectedCardForEdit) { newValue in
                if newValue == nil, let question = currentQuestion {
                    // Try to get the latest version of the card
                    if let updated = viewModel.flashCards.first(where: { $0.id == question.originalCard.id }) {
                        // Rebuild the current question with updated card data
                        currentQuestion = TrueFalseQuestion(
                            word: updated.word,
                            definition: question.definition, // Keep the same definition for this round
                            isCorrect: question.isCorrect,
                            originalCard: updated
                        )
                        forceRefreshID = UUID()
                    }
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
        .sheet(item: $selectedCardForEdit) { card in
            EditCardView(viewModel: viewModel, card: card)
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
                    currentIndex: currentIndex + 1,
                    totalCards: maxQuestions ?? cards.count,
                    score: userProfileManager.xp, // Use current XP instead of calculated score
                    knownCount: nil,
                    unknownCount: nil,
                    skippedCount: nil,
                    sessionXP: sessionXP,
                    showProgressIndicator: false, // Use Quick Study style
                    isComplete: showingResults
                )
                
                Spacer()
                
                VStack(spacing: 20) {
                    // Title outside the card - instruction text
                    Text("Does this word translate to:")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Use shared card component with vibrant borders - only show the word
                    if let question = currentQuestion {
                    SharedGameCardView(
                        card: question.originalCard,
                        title: "",
                        content: question.word,
                        showArticle: false
                    )
                        .id("\(question.originalCard.id)-\(forceRefreshID)")
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
                        // Navigation buttons below the card
                        HStack(spacing: 12) {
                            Button(action: {
                                goToPreviousQuestion()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left.circle")
                                    Text("Back")
                                }
                                .font(.subheadline)
                                .foregroundColor(currentIndex == 0 ? .gray : .blue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(currentIndex == 0 ? 0.04 : 0.08))
                                .cornerRadius(10)
                            }
                            .disabled(currentIndex == 0)
                            .buttonStyle(PlainButtonStyle())

                            Button(action: {
                                selectedCardForEdit = question.originalCard
                            }) {
                                HStack {
                                    Image(systemName: "pencil")
                                    Text("Edit")
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.08))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())

                            // Show Next button after answering a question
                            if hasAnswered {
                                Button(action: {
                                    setupNextQuestion()
                                }) {
                                    HStack {
                                        Text("Next")
                                        Image(systemName: "arrow.right.circle")
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.blue.opacity(0.08))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.top, 8)
                    }
                    
                    // Definition display
                    VStack(spacing: 8) {
                Text("Translates to:")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(currentQuestion?.definition ?? "")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    }
                    
                    // Reserved space for feedback (fixed height to prevent layout shifts)
                    VStack(spacing: 8) {
                        // Show feedback when answer is incorrect
                        if showingFeedback, let question = currentQuestion, let userAnswer = userAnswer, userAnswer != question.isCorrect {
                            VStack(spacing: 8) {
                                Text("Incorrect!")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                
                                Text("The answer is: \(question.originalCard.definition)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        // Show success message when answer is correct
                        if showingFeedback, let question = currentQuestion, let userAnswer = userAnswer, userAnswer == question.isCorrect {
                            VStack(spacing: 8) {
                                Text("Correct!")
                                    .font(.headline)
                                    .foregroundColor(.green)
                                
                                // Show additional context when user correctly answers "False"
                                if !question.isCorrect {
                                    Text("That's because the correct word is: \(question.originalCard.definition)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .frame(minHeight: 80) // Reserved space to prevent layout shifts
                    .animation(.easeInOut(duration: 0.3), value: showingFeedback)
                
                Spacer()
                
                    // Answer buttons (side by side, half width each) - fixed position
                HStack(spacing: 12) {
                    Button(action: { checkAnswer(true) }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("True")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                            .background(hasAnswered ? (userAnswer == true ? (currentQuestion?.isCorrect == true ? Color.green : Color.red) : Color.gray) : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                        .disabled(hasAnswered)
                    
                    Button(action: { checkAnswer(false) }) {
                        HStack {
                            Image(systemName: "x.circle.fill")
                            Text("False")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                            .background(hasAnswered ? (userAnswer == false ? (currentQuestion?.isCorrect == false ? Color.green : Color.red) : Color.gray) : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                        .disabled(hasAnswered)
                }
                .padding(.horizontal)
                
                Spacer()
                }
                .padding(.horizontal)
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
        Group {
            if let session = currentSession {
                StudySessionResultsView(
                    session: session,
                    viewModel: viewModel,
                    onStudyAgain: {
                        resetGame()
                    },
                    onReviewUnknown: {
                        // Filter cards to only incorrect ones and restart
                        cards = cards.filter { incorrectCards.contains($0.id) }
                        resetGame()
                    },
                    onDone: {
                        dismissToRoot()
                    }
                )
            } else {
                // Fallback if session is nil
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
                    }
                }
                .padding()
            }
        }
    }
    
    private func setupNextQuestion(incrementIndex: Bool = true) {
        // Check if we've reached the max questions limit
        if let maxQuestions = maxQuestions, questionsAnswered >= maxQuestions {
            HapticManager.shared.gameComplete()
            StreakManager.shared.recordGameCompletion(); showingResults = true
            return
        }
        
        // If we're out of cards but haven't reached maxQuestions, recycle cards
        if remainingCards.isEmpty {
            if let maxQuestions = maxQuestions, questionsAnswered < maxQuestions {
                // Recycle all cards for progressive study mode
                remainingCards = cards
            } else {
                // Normal mode - end game
                HapticManager.shared.gameComplete()
                StreakManager.shared.recordGameCompletion(); showingResults = true
                return
            }
        }
        
        // Increment currentIndex for navigation (only if requested)
        if incrementIndex {
            currentIndex += 1
        }
        
        // Reset example state for new question
        isShowingExample = false
        
        // Reset feedback state for new question
        hasAnswered = false
        showingFeedback = false
        userAnswer = nil
        
        // Select a random card for the word
        let wordCard = remainingCards.randomElement()!
        // Always use the latest version of the card from viewModel.flashCards
        let latestWordCard = viewModel.flashCards.first(where: { $0.id == wordCard.id }) ?? wordCard
        
        // Decide if this will be a true or false question (50/50 chance)
        let isCorrect = Bool.random()
        
        let definition: String
        if isCorrect {
            // Use the correct definition (from latest card)
            definition = latestWordCard.definition
        } else {
            // Use a definition from another random card (also fetch latest)
            let otherCards = cards.filter { $0.id != wordCard.id }
            let latestOtherCards = otherCards.compactMap { card in
                viewModel.flashCards.first(where: { $0.id == card.id }) ?? card
            }
            if let randomCard = latestOtherCards.randomElement() {
                definition = randomCard.definition
            } else {
                // If no other cards available, use the correct definition
                definition = latestWordCard.definition
            }
        }
        
        currentQuestion = TrueFalseQuestion(
            word: latestWordCard.word,
            definition: definition,
            isCorrect: isCorrect,
            originalCard: latestWordCard
        )
        
        // Remove the used card from remaining cards
        remainingCards.removeAll { $0.id == wordCard.id }
    }
    
    private func checkAnswer(_ answer: Bool) {
        guard let question = currentQuestion else { return }
        
        // Set feedback state
        hasAnswered = true
        userAnswer = answer
        showingFeedback = true
        
        // Track answer history for navigation
        answerHistory[currentIndex] = answer
        hasAnsweredHistory[currentIndex] = true
        questionHistory[currentIndex] = question
        
        // Update maxProgressIndex if answering the latest question
        if currentIndex >= maxProgressIndex {
            maxProgressIndex = currentIndex + 1
            print("🔍 Updated maxProgressIndex to \(maxProgressIndex) after answering question \(currentIndex)")
        }
        
        questionsAnswered += 1
        let isCorrect = answer == question.isCorrect
        
        if isCorrect {
            score += 1
            correctAnswers += 1
            
            // Show SpriteKit success effect instead of text
            let centerPoint = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2)
            gameScene.createSuccessParticles(at: centerPoint)
            gameScene.createFloatingScore(score: "+10", at: centerPoint, color: .systemGreen)
            
            // Add XP for correct answer
            userProfileManager.addXP(12)
            sessionXP += 12
            
            // Use custom sound for games (not study mode)
            HapticManager.shared.successNotification() // Haptic only
            SoundManager.shared.playTestCorrectSound() // Custom Correct.wav
            
            // Apply SRS logic for correct answer (50/50 consideration)
            // Since True/False is easier than multiple choice, we use a more conservative approach
            let updatedCard = srsManager.processSimpleReview(for: question.originalCard, simpleQuality: .know)
            viewModel.updateCardWithSRSData(updatedCard)
        } else {
            incorrectAnswers += 1
            // Track which card was answered incorrectly
            incorrectCards.insert(question.originalCard.id)
            
            // Show SpriteKit error effect instead of text
            let centerPoint = CGPoint(x: gameScene.size.width / 2, y: gameScene.size.height / 2)
            gameScene.createErrorEffect(at: centerPoint)
            
            // Add XP for attempting (even if wrong)
            userProfileManager.addXP(5)
            sessionXP += 5
            
            // Use custom sound for games (not study mode)
            HapticManager.shared.errorNotification() // Haptic only
            SoundManager.shared.playTestWrongSound() // Custom Wrong.wav
            
            // Apply SRS logic for incorrect answer (50/50 consideration)
            // Since True/False is easier, incorrect answers are penalized more heavily
            let updatedCard = srsManager.processSimpleReview(for: question.originalCard, simpleQuality: .dontKnow)
            viewModel.updateCardWithSRSData(updatedCard)
        }
        
        // Record learning statistics - only count when the question shows the correct definition
        if question.isCorrect {
            viewModel.recordCardShown(question.originalCard.id, isCorrect: isCorrect)
        }
        
        // Auto-save progress periodically (every 5 questions)
        if questionsAnswered % 5 == 0 {
            saveCurrentProgress()
        }
        
        // Check if we've reached the max questions limit (for progressive study)
        if let maxQuestions = maxQuestions, questionsAnswered >= maxQuestions {
            // End session tracking immediately
            if var session = currentSession {
                session.knownCards = correctAnswers
                session.unknownCards = incorrectAnswers
                session.skippedCards = 0 // No skipped cards in True/False mode
                session.endTime = Date()
                session.duration = session.endTime!.timeIntervalSince(session.startTime)
                statsManager.endSession(
                    session,
                    knownCards: correctAnswers,
                    unknownCards: incorrectAnswers,
                    skippedCards: 0
                )
                currentSession = session
                
                // Add XP for completing the True/False session
                let baseXP = 50
                let performanceBonus = correctAnswers * 12 // 12 XP per correct answer
                let totalXP = baseXP + performanceBonus
                userProfileManager.addXP(totalXP)
                
                // Check for perfect session (100% accuracy with at least 5 questions)
                if questionsAnswered >= 5 && correctAnswers == questionsAnswered {
                    statsManager.recordPerfectSession(
                        gameType: .truefalse,
                        totalCards: questionsAnswered,
                        knownCards: correctAnswers,
                        duration: session.endTime!.timeIntervalSince(session.startTime)
                    )
                }
                
                print("🎮 True/False session complete! Earned \(totalXP) XP (Base: \(baseXP), Performance: \(performanceBonus))")
            }
            
            // Clear saved progress since game is complete
            clearSavedProgress()
            HapticManager.shared.gameComplete()
            
            // Call level completion callback immediately if this is a progressive study session
            if let onLevelComplete = onLevelComplete {
                let levelNumber: Int
                switch studyMode {
                case .maintenance: levelNumber = 1
                case .cram: levelNumber = 2
                case .adaptive: levelNumber = 3
                default: levelNumber = 1
                }
                
                let result = LevelResult(
                    level: levelNumber,
                    score: score,
                    total: questionsAnswered
                )
                onLevelComplete(result)
            } else {
                withAnimation {
                    StreakManager.shared.recordGameCompletion(); showingResults = true
                }
            }
            return // Exit immediately, don't show next question
        }
        
        // Don't automatically move to next question - let user review and click Next
    }
    
    private func resetGame() {
        remainingCards = cards
        score = 0
        questionsAnswered = 0
        correctAnswers = 0
        incorrectAnswers = 0
        incorrectCards.removeAll() // Reset incorrect cards tracking
        showingResults = false
        isShowingExample = false
        hasAnswered = false
        showingFeedback = false
        userAnswer = nil
        currentIndex = 0
        setupNextQuestion(incrementIndex: false)
        
        // Clear navigation state
        maxProgressIndex = 1
        hasGoneBack = false
        answerHistory.removeAll()
        hasAnsweredHistory.removeAll()
        questionHistory.removeAll()
        
        // Start new session tracking
        sessionStartTime = Date()
        currentSession = statsManager.startSession(deckIds: deckIds, cardCount: cards.count)
        
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
                setupNextQuestion(incrementIndex: false)
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
        incorrectCards.removeAll() // Reset incorrect cards tracking
        showingResults = false
        currentIndex = 0
        setupNextQuestion(incrementIndex: false)
        
        // Clear navigation state
        maxProgressIndex = 1
        hasGoneBack = false
        answerHistory.removeAll()
        hasAnsweredHistory.removeAll()
        questionHistory.removeAll()
        
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
    
    // MARK: - Navigation Functions
    
    private func goToPreviousQuestion() {
        if currentIndex > 0 {
            hasGoneBack = true
            withAnimation(.none) {
                currentIndex -= 1
            }
            // Restore previous question and answer state
            if let question = questionHistory[currentIndex] {
                currentQuestion = question
            }
            selectedAnswer = answerHistory[currentIndex]
            hasAnswered = hasAnsweredHistory[currentIndex] ?? false
            showingFeedback = hasAnswered
            userAnswer = selectedAnswer
            isShowingExample = false
            forceRefreshID = UUID()
            print("🔍 Went to previous question: currentIndex=\(currentIndex), maxProgressIndex=\(maxProgressIndex)")
        }
    }
    
    private func goToNextQuestion() {
        if currentIndex < maxProgressIndex {
            currentIndex += 1
            // Restore question and answer state for this index
            if let question = questionHistory[currentIndex] {
                currentQuestion = question
            }
            selectedAnswer = answerHistory[currentIndex]
            hasAnswered = hasAnsweredHistory[currentIndex] ?? false
            showingFeedback = hasAnswered
            userAnswer = selectedAnswer
            isShowingExample = false
            forceRefreshID = UUID()
        }
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