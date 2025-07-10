import SwiftUI
import SpriteKit

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
    @State private var isShowingExample = false
    @State private var showingExample = false
    @State private var selectedCardForEdit: FlashCard? = nil
    @State private var forceRefreshID = UUID()
    
    // Track original number of cards for proper percentage calculation
    @State private var originalCardCount = 0
    
    // Add speech service for pronunciation
    @ObservedObject private var speechService = DutchSpeechService.shared
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Progressive study properties
    private var studyMode: StudyMode?
    private var onLevelComplete: ((LevelResult) -> Void)?
    private var maxQuestions: Int?
    
    // Session tracking for SRS
    @State private var currentSession: StudySession?
    @State private var sessionStartTime: Date = Date()
    @State private var sessionXP: Int = 0 // Track XP gained during current session
    @StateObject private var statsManager = StatisticsManager.shared
    @StateObject private var srsManager = SRSManager.shared
    @StateObject private var userProfileManager = UserProfileManager.shared
    
    // Track answers for each card
    @State private var answerHistory: [Int: String] = [:]
    @State private var hasAnsweredHistory: [Int: Bool] = [:]
    
    // Track the furthest question the user has reached
    @State private var maxProgressIndex: Int = 1
    
    // Track if user has gone back to review previous questions
    @State private var hasGoneBack: Bool = false
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return currentIndex > 0 || correctAnswers > 0
    }
    
    // Get the text to speak for current card
    private var textToSpeak: String {
        let card = currentCard
        return card.article.isEmpty ? card.word : "\(card.article) \(card.word)"
    }
    
    // Check if current word is being spoken
    private var isCurrentWordSpeaking: Bool {
        return speechService.isSpeaking && speechService.currentlySpeaking == textToSpeak
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false, studyMode: StudyMode? = nil, maxQuestions: Int? = nil, onLevelComplete: ((LevelResult) -> Void)? = nil) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        self.cards = viewModel.sortCardsForLearning(cards)
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
        self.studyMode = studyMode
        self.maxQuestions = maxQuestions
        self.onLevelComplete = onLevelComplete
        // Track original number of cards for proper scoring
        self._originalCardCount = State(initialValue: cards.count)
    }
    
    private var currentCard: FlashCard {
        let id = cards[currentIndex].id
        return viewModel.flashCards.first(where: { $0.id == id }) ?? cards[currentIndex]
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
    
    private func handleAnswer(_ answer: String) {
        print("🧪 handleAnswer() called with answer: '\(answer)'")
        guard !hasAnswered else { return }
        
        selectedAnswer = answer
        hasAnswered = true
        
        let isCorrect = answer == currentCard.definition
        print("🧪 Answer check: selected='\(answer)' correct='\(currentCard.definition)' isCorrect=\(isCorrect)")
        
        // Save answer state for navigation
        answerHistory[currentIndex] = answer
        hasAnsweredHistory[currentIndex] = true
        
        // Update maxProgressIndex if answering the latest question
        if currentIndex >= maxProgressIndex {
            maxProgressIndex = currentIndex + 1
            print("🔍 Updated maxProgressIndex to \(maxProgressIndex) after answering question \(currentIndex)")
        }
        
        if isCorrect {
            print("🧪 CORRECT ANSWER - awarding XP")
            correctAnswers += 1
            HapticManager.shared.testCorrectHaptic() // Haptic only, no system sound
            SoundManager.shared.playTestCorrectSound() // Play custom correct sound
            
            // Award XP for correct answer immediately
            sessionXP += 5
            userProfileManager.addXP(5)
            print("🧪 Correct answer! Session XP: \(sessionXP)")
            
            // Apply SRS logic for correct answer
            let updatedCard = srsManager.processSimpleReview(for: currentCard, simpleQuality: .know)
            viewModel.updateCardWithSRSData(updatedCard)
        } else {
            print("🧪 INCORRECT ANSWER")
            incorrectCards.insert(currentCard.id)
            HapticManager.shared.testWrongHaptic() // Haptic only, no system sound
            SoundManager.shared.playTestWrongSound() // Play custom wrong sound
            
            // Apply SRS logic for incorrect answer
            let updatedCard = srsManager.processSimpleReview(for: currentCard, simpleQuality: .dontKnow)
            viewModel.updateCardWithSRSData(updatedCard)
        }
        
        // Record learning statistics - card was shown and answered correctly/incorrectly
        viewModel.recordCardShown(currentCard.id, isCorrect: isCorrect)
        
        // Don't automatically move to next question - let user review and click Next
    }
    
    private func moveToNextQuestion() {
        HapticManager.shared.questionAdvance()
        
        // Check if we've reached the max questions limit (for progressive study)
        if let maxQuestions = maxQuestions, currentIndex >= maxQuestions - 1 {
            print("🧪 Reached max questions limit for progressive study")
            HapticManager.shared.gameComplete()
            
            // End session tracking
            if var session = currentSession {
                session.knownCards = correctAnswers
                session.unknownCards = maxQuestions - correctAnswers
                session.skippedCards = 0 // No skipped cards in test mode
                session.endTime = Date()
                session.duration = session.endTime!.timeIntervalSince(session.startTime)
                statsManager.endSession(
                    session,
                    knownCards: correctAnswers,
                    unknownCards: maxQuestions - correctAnswers,
                    skippedCards: 0
                )
                currentSession = session
                
                // Add XP for completing the test session
                let totalXP = correctAnswers * 5 // 5 XP per correct answer
                // Remove session completion XP - will be awarded in session results view
                // userProfileManager.addXP(totalXP)
                
                // Check for perfect session (100% accuracy with at least 5 cards)
                if maxQuestions >= 5 && correctAnswers == maxQuestions {
                    statsManager.recordPerfectSession(
                        gameType: .test,
                        totalCards: maxQuestions,
                        knownCards: correctAnswers,
                        duration: session.endTime!.timeIntervalSince(session.startTime)
                    )
                }
                
                print("🎮 Test session complete! Earned \(totalXP) XP")
            }
            
            // Clear saved progress since test is complete
            clearSavedProgress()
            
            // Call level completion callback if this is a progressive study session
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
                    score: correctAnswers,
                    total: maxQuestions
                )
                onLevelComplete(result)
            } else {
                // Post notification for regular test mode
                NotificationCenter.default.post(name: .testSessionCompleted, object: nil)
                
                withAnimation {
                    StreakManager.shared.recordGameCompletion(); showingResults = true
                }
            }
            return
        }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            selectedAnswer = answerHistory[currentIndex]
            hasAnswered = hasAnsweredHistory[currentIndex] ?? false
            isShowingExample = false // Reset example state
            shuffledOptions = generateOptions()
            
            // Update maxProgressIndex if moving forward
            if currentIndex > maxProgressIndex {
                maxProgressIndex = currentIndex
            }
            
            // Auto-save progress periodically (every 5 questions)
            if currentIndex % 5 == 0 {
                saveCurrentProgress()
            }
        } else {
            // End of test - show completion
            HapticManager.shared.gameComplete()
            
            // End session tracking
            if var session = currentSession {
                session.knownCards = correctAnswers
                session.unknownCards = originalCardCount - correctAnswers
                session.skippedCards = 0 // No skipped cards in test mode
                session.endTime = Date()
                session.duration = session.endTime!.timeIntervalSince(session.startTime)
                statsManager.endSession(
                    session,
                    knownCards: correctAnswers,
                    unknownCards: originalCardCount - correctAnswers,
                    skippedCards: 0
                )
                currentSession = session
                
                // Add XP for completing the test session
                let totalXP = correctAnswers * 5 // 5 XP per correct answer
                // Remove session completion XP - will be awarded in session results view
                // userProfileManager.addXP(totalXP)
                
                // Check for perfect session (100% accuracy with at least 5 cards)
                if originalCardCount >= 5 && correctAnswers == originalCardCount {
                    statsManager.recordPerfectSession(
                        gameType: .test,
                        totalCards: originalCardCount,
                        knownCards: correctAnswers,
                        duration: session.endTime!.timeIntervalSince(session.startTime)
                    )
                }
                
                print("🎮 Test session complete! Earned \(totalXP) XP")
            }
            
            // Clear saved progress since test is complete
            clearSavedProgress()
            
            withAnimation {
                StreakManager.shared.recordGameCompletion(); showingResults = true
            }
        }
    }
    
    private func resetTest() {
        cards = viewModel.sortCardsForLearning(cards)
        // Reset original card count for new test
        originalCardCount = cards.count
        currentIndex = 0
        correctAnswers = 0
        showingResults = false
        selectedAnswer = nil
        hasAnswered = false
        isShowingExample = false // Reset example state
        incorrectCards.removeAll()
        shuffledOptions = generateOptions()
        answerHistory = [:]
        hasAnsweredHistory = [:]
        maxProgressIndex = 1
        hasGoneBack = false
        
        // Reset session XP to 0 for new test
        sessionXP = 0
        
        // Start new session tracking
        sessionStartTime = Date()
        currentSession = statsManager.startSession(deckIds: deckIds, cardCount: cards.count)
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    handleBackButton()
                }
            }
        }
        .navigationTitle("Test Your Cards")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Close Test?", isPresented: $showingCloseConfirmation) {
            Button("Save & Close") {
                saveCurrentProgress()
                dismissToRoot()
            }
            Button("Close", role: .destructive) {
                dismissToRoot()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(hasSignificantProgress ? "Would you like to save your progress?" : "Are you sure you want to close?")
        }
        .onAppear {
            // Start session tracking
            sessionStartTime = Date()
            currentSession = statsManager.startSession(deckIds: deckIds, cardCount: cards.count)
            maxProgressIndex = 1
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                shuffledOptions = generateOptions()
            }
            // Removed automatic audio playback - only manual card taps trigger audio
            print("🔍 View appeared: currentIndex=\(currentIndex), maxProgressIndex=\(maxProgressIndex)")
        }
        .onDisappear {
            // Auto-save when view disappears
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
        .onChange(of: selectedCardForEdit) { newValue in
            if newValue == nil {
                forceRefreshID = UUID()
            }
        }
        .onChange(of: currentIndex) { newValue in
            print("🔍 currentIndex changed to \(newValue), maxProgressIndex=\(maxProgressIndex)")
        }
        .sheet(item: $selectedCardForEdit) { card in
            EditCardView(viewModel: viewModel, card: card)
        }
    }
    
    private var testView: some View {
        VStack(spacing: 0) {
            // Use same header as StudyView
            GameHeaderView(
                currentIndex: currentIndex + 1,
                totalCards: maxQuestions ?? cards.count,
                score: userProfileManager.xp,
                knownCount: nil,
                unknownCount: nil,
                skippedCount: nil,
                sessionXP: sessionXP,
                showProgressIndicator: false,
                isComplete: showingResults
            )
            
            Spacer()
            
            VStack(spacing: 20) {
                // Title outside the card
                Text("Choose the correct definition:")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                // Use shared card component with vibrant borders - only show the word
                SharedGameCardView(
                    card: currentCard,
                    title: "",
                    content: currentCard.word,
                    showArticle: false
                )
                .id("\(currentCard.id)-\(forceRefreshID)")
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
                // Previous and Edit Card buttons below the card
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
                        selectedCardForEdit = currentCard
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
                            moveToNextQuestion()
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
                
                Spacer()
                
                // Answer options (thinner)
                VStack(spacing: 8) {
                    ForEach(shuffledOptions, id: \.self) { option in
                        Button(action: {
                            handleAnswer(option)
                        }) {
                            Text(option)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
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
                
                Spacer()
            }
        }
    }
    
    private var resultsView: some View {
        Group {
            if let session = currentSession {
                StudySessionResultsView(
                    session: session,
                    viewModel: viewModel,
                    sessionXP: sessionXP,
                    onStudyAgain: {
                        resetTest()
                    },
                    onReviewUnknown: {
                        // Filter cards to only incorrect ones and restart
                        cards = cards.filter { incorrectCards.contains($0.id) }
                        resetTest()
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
                    
                    Text("Test Complete!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text("All cards have been mastered! 🎉")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    .foregroundColor(.green)
                    
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
                    }
                }
                .padding()
            }
        }
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
        guard hasSignificantProgress else { return }
        
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
            gameData: gameState
        )
        
        print("💾 Test progress saved - Index: \(currentIndex), Correct: \(correctAnswers)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .test,
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
        SaveStateManager.shared.deleteSaveState(gameType: .test)
    }
    
    // MARK: - Speech Functions
    private func speakCurrentWord() {
        let text = textToSpeak.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // Use slower speech rate for learning
        speechService.speakDutch(text, rate: 0.4)
    }
    
    // Add a function to go to the previous question
    private func goToPreviousQuestion() {
        if currentIndex > 0 {
            hasGoneBack = true
            withAnimation(.none) {
                currentIndex -= 1
            }
            // Restore previous answer state
            selectedAnswer = answerHistory[currentIndex]
            hasAnswered = hasAnsweredHistory[currentIndex] ?? false
            isShowingExample = false
            shuffledOptions = generateOptions()
            forceRefreshID = UUID()
            print("🔍 Went to previous question: currentIndex=\(currentIndex), maxProgressIndex=\(maxProgressIndex)")
        }
    }
    
    // Go to next question in review/history mode
    private func goToNextQuestion() {
        if currentIndex < maxProgressIndex {
            currentIndex += 1
            selectedAnswer = answerHistory[currentIndex]
            hasAnswered = hasAnsweredHistory[currentIndex] ?? false
            isShowingExample = false
            shuffledOptions = generateOptions()
            forceRefreshID = UUID()
        }
    }
} 