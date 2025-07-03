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
        cards[currentIndex]
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
    
    private func handleAnswer(_ option: String) {
        if !hasAnswered {
            selectedAnswer = option
            hasAnswered = true
            let isCorrect = option == currentCard.definition
            
            if isCorrect {
                correctAnswers += 1
                HapticManager.shared.testCorrectHaptic() // Haptic only, no system sound
                SoundManager.shared.playTestCorrectSound() // Play custom correct sound
                
                // Add XP for correct answer
                userProfileManager.addXP(15)
                sessionXP += 15
                
                // Apply SRS logic for correct answer
                let updatedCard = srsManager.processSimpleReview(for: currentCard, simpleQuality: .know)
                viewModel.updateCardWithSRSData(updatedCard)
            } else {
                incorrectCards.insert(currentCard.id)
                HapticManager.shared.testWrongHaptic() // Haptic only, no system sound
                SoundManager.shared.playTestWrongSound() // Play custom wrong sound
                
                // Add XP for attempting (even if wrong)
                userProfileManager.addXP(5)
                sessionXP += 5
                
                // Apply SRS logic for incorrect answer
                let updatedCard = srsManager.processSimpleReview(for: currentCard, simpleQuality: .dontKnow)
                viewModel.updateCardWithSRSData(updatedCard)
            }
            
            // Record learning statistics - card was shown and answered correctly/incorrectly
            viewModel.recordCardShown(currentCard.id, isCorrect: isCorrect)
            
            // Automatically move to next question after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                moveToNextQuestion()
            }
        }
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
                let baseXP = 50
                let performanceBonus = correctAnswers * 10 // 10 XP per correct answer
                let totalXP = baseXP + performanceBonus
                userProfileManager.addXP(totalXP)
                
                print("🎮 Test session complete! Earned \(totalXP) XP (Base: \(baseXP), Performance: \(performanceBonus))")
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
            selectedAnswer = nil
            hasAnswered = false
            isShowingExample = false // Reset example state
            shuffledOptions = generateOptions()
            
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
                let baseXP = 50
                let performanceBonus = correctAnswers * 10 // 10 XP per correct answer
                let totalXP = baseXP + performanceBonus
                userProfileManager.addXP(totalXP)
                
                print("🎮 Test session complete! Earned \(totalXP) XP (Base: \(baseXP), Performance: \(performanceBonus))")
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
            
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                shuffledOptions = generateOptions()
            }
            
            // Removed automatic audio playback - only manual card taps trigger audio
        }
        .onDisappear {
            // Auto-save when view disappears
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
    }
    
    private var testView: some View {
        VStack(spacing: 0) {
            // Use same header as StudyView
            GameHeaderView(
                currentIndex: currentIndex + 1,
                totalCards: maxQuestions ?? cards.count,
                score: userProfileManager.xp,
                combo: 0,
                knownCount: nil,
                unknownCount: nil,
                skippedCount: nil,
                sessionXP: sessionXP,
                showProgressIndicator: false,
                progressOverride: showingResults ? 1.0 : Double(max(currentIndex, 0)) / Double(maxQuestions ?? cards.count)
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
                    onStudyAgain: {
                        resetTest()
                    },
                    onReviewUnknown: {
                        // For test mode, just retest all cards (don't retest only incorrect ones)
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
} 