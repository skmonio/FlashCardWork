import SwiftUI

struct WordScrambleView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var correctAnswers = 0
    @State private var totalAnswers = 0
    @State private var showingResults = false
    @State private var wordChunks: [WordChunk] = []
    @State private var selectedChunks: [WordChunk] = []
    @State private var hasAnswered = false
    @State private var isCorrect: Bool? = nil
    @State private var showingCloseConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    // Progressive study properties
    private var studyMode: StudyMode?
    private var onLevelComplete: ((LevelResult) -> Void)?
    private var maxQuestions: Int?
    
    // Add speech service for pronunciation
    @ObservedObject private var speechService = DutchSpeechService.shared
    
    // Add user profile manager for XP tracking
    @StateObject private var userProfileManager = UserProfileManager.shared
    
    // Add SRS manager for spaced repetition
    @StateObject private var srsManager = SRSManager.shared
    
    // Session XP tracking
    @State private var sessionXP: Int = 0 // Track XP gained during current session
    
    // Session tracking
    @State private var sessionStartTime: Date = Date()
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Track answer history for navigation
    @State private var answerHistory: [Int: [UUID]] = [:] // Save selected chunk IDs
    @State private var hasAnsweredHistory: [Int: Bool] = [:]
    @State private var isCorrectHistory: [Int: Bool] = [:]
    @State private var wordChunksHistory: [Int: [WordChunk]] = [:]
    
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
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false, studyMode: StudyMode? = nil, maxQuestions: Int? = nil, onLevelComplete: ((LevelResult) -> Void)? = nil) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        _cards = State(initialValue: viewModel.sortCardsForLearning(cards))
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
        self.studyMode = studyMode
        self.maxQuestions = maxQuestions
        self.onLevelComplete = onLevelComplete
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
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    handleBackButton()
                }
            }
        }
        .navigationTitle("Jumble Your Cards")
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
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            } else {
                setupGame()
            }
        }
        .onDisappear {
            // Auto-save when view disappears
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "textformat.abc")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Cards Available")
                .font(.title2)
                .bold()
            
            Text("Add some cards to your decks to practice word scramble.")
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
                totalCards: maxQuestions ?? cards.count,
                score: userProfileManager.xp,
                knownCount: nil,
                unknownCount: nil,
                skippedCount: nil,
                sessionXP: sessionXP,
                showProgressIndicator: false,
                isComplete: showingResults
            )
            
            if let card = currentCard {
                VStack(spacing: 20) {
                    // Instruction text outside the card
                    Text("Arrange the letters to translate:")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    // Use shared card component with vibrant borders - show the translation instead of the word
                    SharedGameCardView(
                        card: card,
                        title: "",
                        content: card.definition,
                        showArticle: false
                    )
                    .onTapGesture(count: 2) {
                        // Double tap to show/hide example
                        HapticManager.shared.lightImpact()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            // Example functionality could be added here
                        }
                    }
                    .onTapGesture(count: 1) {
                        // Single tap for audio
                        speakCurrentWord()
                        HapticManager.shared.lightImpact()
                    }
                    
                    // Navigation buttons below the card
                        HStack(spacing: 12) {
                        // Show Back button only after first card
                        if currentIndex > 0 {
                            Button(action: {
                                goToPreviousQuestion()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.left.circle")
                                    Text("Back")
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

                        // Show Next button after answering
                        if hasAnswered {
                            Button(action: {
                                nextCard()
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
                    
                    // Answer area (selected chunks display)
                    VStack(spacing: 15) {
                        HStack(spacing: 8) {
                            ForEach(selectedChunks) { chunk in
                                ChunkView(chunk: chunk, isSelected: true, disabled: hasAnswered) {
                                    removeChunk(chunk)
                                }
                            }
                            
                            // Show placeholder if no chunks selected
                            if selectedChunks.isEmpty {
                                Text("Tap pieces below to build the word")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .frame(minHeight: 50)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                                .background(Color.blue.opacity(0.05))
                        )
                    }
                    
                    // Available chunks section
                    VStack(spacing: 15) {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(wordChunks.filter { !selectedChunks.contains($0) }) { chunk in
                                ChunkView(chunk: chunk, isSelected: false, disabled: hasAnswered) {
                                    addChunk(chunk)
                                }
                            }
                        }
                    }
                    
                    // Answer feedback (shown after checking answer)
                    if hasAnswered {
                        answerFeedbackView(for: card)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Word Scramble Complete!")
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
                
                // XP Award Display
                VStack(spacing: 8) {
                    Text("XP Earned")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    let baseXP = 50
                    let performanceBonus = correctAnswers * 5
                    let totalXP = baseXP + performanceBonus
                    
                    Text("+\(totalXP)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.yellow)
                    
                    Text("\(baseXP) base + \(performanceBonus) bonus")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 10)
            }
            
            Button("Play Again") {
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
        .padding()
        .onAppear {
            // Award XP when results are shown
            let baseXP = 50
            let performanceBonus = correctAnswers * 5
            let totalXP = baseXP + performanceBonus
            userProfileManager.addXP(totalXP)
        }
    }
    
    // MARK: - Game Logic
    
    private func setupGame() {
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        sessionStartTime = Date()
        cards = viewModel.sortCardsForLearning(cards)
        
        // Reset session XP to 0 for new game
        sessionXP = 0
        
        setupCurrentWord()
    }
    
    private func setupCurrentWord(resetState: Bool = true) {
        guard let card = currentCard else { return }
        
        // Only reset state if requested (for new questions, not when going back)
        if resetState {
        selectedChunks.removeAll()
        hasAnswered = false
        isCorrect = nil
        }
        
        // Break word into chunks of 2-4 characters
        wordChunks = createWordChunks(from: card.word)
        
        // Save word chunks to history for navigation (only if not already saved)
        if wordChunksHistory[currentIndex] == nil {
            wordChunksHistory[currentIndex] = wordChunks
            print("🔤 Saved word chunks for index \(currentIndex): \(wordChunks.map { $0.text })")
        }
    }
    
    private func createWordChunks(from word: String) -> [WordChunk] {
        let cleanWord = word.lowercased().replacingOccurrences(of: " ", with: "")
        var chunks: [WordChunk] = []
        var currentIndex = 0
        let characters = Array(cleanWord)
        
        // For very short words (2-3 characters), split into individual characters to ensure at least 2 chunks
        if characters.count <= 3 {
            for (index, char) in characters.enumerated() {
                chunks.append(WordChunk(
                    id: UUID(),
                    text: String(char),
                    originalPosition: index
                ))
            }
        } else {
            // For longer words, use the original chunking logic
            while currentIndex < characters.count {
                let remainingChars = characters.count - currentIndex
                let chunkSize: Int
                
                // Determine chunk size (2-4 characters)
                if remainingChars >= 4 && Bool.random() {
                    chunkSize = Int.random(in: 3...4)
                } else if remainingChars >= 3 && Bool.random() {
                    chunkSize = Int.random(in: 2...3)
                } else if remainingChars >= 2 {
                    chunkSize = 2
                } else {
                    chunkSize = 1
                }
                
                let actualChunkSize = min(chunkSize, remainingChars)
                let chunkChars = Array(characters[currentIndex..<currentIndex + actualChunkSize])
                let chunkText = String(chunkChars)
                
                chunks.append(WordChunk(
                    id: UUID(),
                    text: chunkText,
                    originalPosition: chunks.count
                ))
                
                currentIndex += actualChunkSize
            }
        }
        
        // Shuffle the chunks
        return chunks.shuffled()
    }
    
    private func addChunk(_ chunk: WordChunk) {
        // Prevent interaction after answer has been submitted
        guard !hasAnswered else { return }
        guard !selectedChunks.contains(chunk) else { return }
        
        selectedChunks.append(chunk)
        HapticManager.shared.lightImpact()
        
        // Auto-submit when all chunks are selected
        if selectedChunks.count == wordChunks.count && !hasAnswered {
            // Add a slight delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                checkAnswer()
            }
        }
    }
    
    private func removeChunk(_ chunk: WordChunk) {
        // Prevent interaction after answer has been submitted
        guard !hasAnswered else { return }
        
        selectedChunks.removeAll { $0.id == chunk.id }
        HapticManager.shared.lightImpact()
    }
    
    private func checkAnswer() {
        print("🔤 checkAnswer() called")
        guard let card = currentCard else { return }
        
        let userAnswer = selectedChunks.map { $0.text }.joined().lowercased()
        let correctAnswer = card.word.lowercased().replacingOccurrences(of: " ", with: "")
        
        let correct = userAnswer == correctAnswer
        print("🔤 Answer check: user='\(userAnswer)' correct='\(correctAnswer)' isCorrect=\(correct)")
        isCorrect = correct
        hasAnswered = true
        totalAnswers += 1
        
        // Save answer state for navigation
        answerHistory[currentIndex] = selectedChunks.map { $0.id }
        hasAnsweredHistory[currentIndex] = true
        isCorrectHistory[currentIndex] = correct
        print("🔤 Saved answer history for index \(currentIndex): \(selectedChunks.map { $0.text })")
        
        if correct {
            print("🔤 CORRECT ANSWER - awarding XP")
            correctAnswers += 1
            HapticManager.shared.testCorrectHaptic()
            SoundManager.shared.playTestCorrectSound()
            
            // Award XP for correct answer
            sessionXP += 5
            print("🔤 Correct answer! Session XP: \(sessionXP)")
            
            // Apply SRS logic for correct answer
            let updatedCard = srsManager.processSimpleReview(for: card, simpleQuality: .know)
            viewModel.updateCardWithSRSData(updatedCard)
        } else {
            print("🔤 INCORRECT ANSWER")
            HapticManager.shared.testWrongHaptic()
            SoundManager.shared.playTestWrongSound()
            
            // Apply SRS logic for incorrect answer
            let updatedCard = srsManager.processSimpleReview(for: card, simpleQuality: .dontKnow)
            viewModel.updateCardWithSRSData(updatedCard)
        }
        
        // Record learning statistics
        viewModel.recordCardShown(card.id, isCorrect: correct)
    }
    
    private func nextCard() {
        // Auto-save progress periodically (every 5 cards)
        if currentIndex % 5 == 0 && currentIndex > 0 {
            saveCurrentProgress()
        }
        
        // Check if we've reached the max questions limit (for progressive study)
        if let maxQuestions = maxQuestions, currentIndex >= maxQuestions - 1 {
            print("🔤 Reached max questions limit for progressive study")
            HapticManager.shared.gameComplete()
            
            // Clear saved progress since game is complete
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
                // Post notification for regular word scramble mode
                NotificationCenter.default.post(name: .wordScrambleSessionCompleted, object: nil)
                
                // Check for perfect session (100% accuracy with at least 5 cards)
                if maxQuestions >= 5 && correctAnswers == maxQuestions {
                    let sessionDuration = Date().timeIntervalSince(sessionStartTime)
                    StatisticsManager.shared.recordPerfectSession(
                        gameType: .wordScramble,
                        totalCards: maxQuestions,
                        knownCards: correctAnswers,
                        duration: sessionDuration
                    )
                }
                
                StreakManager.shared.recordGameCompletion(); showingResults = true
            }
            return
        }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            print("🔤 Moving forward to question \(currentIndex)")
            
            // Check if we have history for this question (i.e., we've been here before)
            if let previousAnswer = answerHistory[currentIndex] {
                print("🔤 Found existing history for index \(currentIndex), restoring state")
                
                // Restore the exact word chunks from history
                if let previousChunks = wordChunksHistory[currentIndex] {
                    print("🔤 Restoring word chunks for index \(currentIndex): \(previousChunks.map { $0.text })")
                    wordChunks = previousChunks
                    
                    // Reconstruct selected chunks using the restored chunks and saved IDs
                    selectedChunks = previousAnswer.compactMap { savedID in
                        wordChunks.first { $0.id == savedID }
                    }
                    print("🔤 Reconstructed selected chunks: \(selectedChunks.map { $0.text })")
                } else {
                    // Fallback if chunks not in history
                    setupCurrentWord(resetState: false)
                    selectedChunks = []
                }
                
                hasAnswered = hasAnsweredHistory[currentIndex] ?? false
                isCorrect = isCorrectHistory[currentIndex]
            } else {
                print("🔤 No history for index \(currentIndex), creating fresh state")
                // This is a new question, reset state completely
                selectedChunks.removeAll()
                hasAnswered = false
                isCorrect = nil
                setupCurrentWord()
            }
        } else {
            // Clear saved progress since game is complete
            clearSavedProgress()
            
            // Check for perfect session (100% accuracy with at least 5 cards)
            if cards.count >= 5 && correctAnswers == cards.count {
                let sessionDuration = Date().timeIntervalSince(sessionStartTime)
                StatisticsManager.shared.recordPerfectSession(
                    gameType: .wordScramble,
                    totalCards: cards.count,
                    knownCards: correctAnswers,
                    duration: sessionDuration
                )
            }
            
            HapticManager.shared.gameComplete()
            StreakManager.shared.recordGameCompletion(); showingResults = true
        }
    }
    
    private func resetGame() {
        cards = viewModel.sortCardsForLearning(cards)
        setupGame()
        
        // Clear answer history
        answerHistory.removeAll()
        hasAnsweredHistory.removeAll()
        isCorrectHistory.removeAll()
        wordChunksHistory.removeAll()
        
        // Clear any saved progress when resetting
        clearSavedProgress()
    }
    
    private func saveCurrentProgress() {
        guard hasSignificantProgress else { return }
        
        let gameState = WordScrambleGameState(
            currentIndex: currentIndex,
            correctAnswers: correctAnswers,
            totalAnswers: totalAnswers,
            cards: cards
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .wordScramble,
            gameData: gameState
        )
        
        print("💾 Word Scramble progress saved - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .wordScramble,
            as: WordScrambleGameState.self
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
            
            setupCurrentWord()
            
            print("🔤 Word Scramble progress loaded - Index: \(currentIndex), Score: \(correctAnswers)/\(totalAnswers)")
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("🔤 No saved state found, starting fresh Word Scramble")
            setupGame()
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .wordScramble)
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
                                Text(selectedChunks.map { $0.text }.joined())
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
        }
    }
    
    private func handleBackButton() {
        if hasSignificantProgress && !showingResults {
            showingCloseConfirmation = true
        } else {
            dismissToRoot()
        }
    }
    
    private func goToPreviousQuestion() {
        if currentIndex > 0 {
            currentIndex -= 1
            print("🔤 Going back to question \(currentIndex)")
            
            // Restore answer state from history
            if let previousAnswer = answerHistory[currentIndex] {
                print("🔤 Found answer history for index \(currentIndex): \(previousAnswer)")
                
                // Restore the exact word chunks from history
                if let previousChunks = wordChunksHistory[currentIndex] {
                    print("🔤 Restoring word chunks for index \(currentIndex): \(previousChunks.map { $0.text })")
                    wordChunks = previousChunks
                    
                    // Now reconstruct selected chunks using the restored chunks and saved IDs
                    selectedChunks = previousAnswer.compactMap { savedID in
                        wordChunks.first { $0.id == savedID }
                    }
                    print("🔤 Reconstructed selected chunks: \(selectedChunks.map { $0.text })")
                } else {
                    print("🔤 No word chunks history for index \(currentIndex), creating new ones")
                    // Fallback: recreate chunks if not in history
                    setupCurrentWord(resetState: false)
                    selectedChunks = []
                }
                
                hasAnswered = hasAnsweredHistory[currentIndex] ?? false
                isCorrect = isCorrectHistory[currentIndex]
            } else {
                print("🔤 No answer history for index \(currentIndex), resetting state")
                // No history for this question, reset state and create new chunks
                selectedChunks = []
                hasAnswered = false
                isCorrect = nil
                setupCurrentWord(resetState: false)
            }
        }
    }
}

// MARK: - Supporting Types

struct WordChunk: Identifiable, Equatable {
    let id: UUID
    let text: String
    let originalPosition: Int
    
    static func == (lhs: WordChunk, rhs: WordChunk) -> Bool {
        return lhs.id == rhs.id
    }
}

struct ChunkView: View {
    let chunk: WordChunk
    let isSelected: Bool
    let disabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(chunk.text)
                .font(.title2)
                .bold()
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1.0)
    }
}

// MARK: - Save State

struct WordScrambleGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let totalAnswers: Int
    let cards: [FlashCard]
} 