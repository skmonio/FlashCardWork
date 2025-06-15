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
        VStack(spacing: 30) {
            // Progress indicator - with top padding for status bar
            HStack {
                Text("Word \(currentIndex + 1) of \(cards.count)")
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
                VStack(spacing: 20) {
                    Text("Arrange the letters to spell:")
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
                .padding(.horizontal)
                
                // Selected chunks (user's current arrangement)
                VStack(spacing: 15) {
                    Text("Your Answer:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(selectedChunks) { chunk in
                            ChunkView(chunk: chunk, isSelected: true) {
                                removeChunk(chunk)
                            }
                        }
                        
                        // Show placeholder if no chunks selected
                        if selectedChunks.isEmpty {
                            Text("Tap chunks below to build the word")
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
                .padding(.horizontal)
                
                // Available chunks
                VStack(spacing: 15) {
                    Text("Available Pieces:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(wordChunks.filter { !selectedChunks.contains($0) }) { chunk in
                            ChunkView(chunk: chunk, isSelected: false) {
                                addChunk(chunk)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Action buttons
                if !hasAnswered {
                    HStack(spacing: 12) {
                        Button("Clear") {
                            clearSelection()
                        }
                        .buttonStyle(.bordered)
                        .disabled(selectedChunks.isEmpty)
                        
                        Button("Check Answer") {
                            checkAnswer()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedChunks.isEmpty)
                    }
                } else {
                    // Show result and next button
                    VStack(spacing: 15) {
                        if let correct = isCorrect {
                            HStack {
                                Image(systemName: correct ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(correct ? .green : .red)
                                    .font(.title2)
                                
                                Text(correct ? "Correct!" : "Incorrect")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(correct ? .green : .red)
                            }
                            
                            if !correct {
                                VStack(spacing: 8) {
                                    Text("Correct answer:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    HStack(spacing: 8) {
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
                                                .foregroundColor(.green)
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
                                                .font(.title3)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                        
                        Button("Next Word") {
                            nextCard()
                        }
                        .buttonStyle(.borderedProminent)
                        .font(.headline)
                    }
                }
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
    }
    
    // MARK: - Game Logic
    
    private func setupGame() {
        currentIndex = 0
        correctAnswers = 0
        totalAnswers = 0
        showingResults = false
        cards = viewModel.sortCardsForLearning(cards)
        setupCurrentWord()
    }
    
    private func setupCurrentWord() {
        guard let card = currentCard else { return }
        
        // Reset state
        selectedChunks.removeAll()
        hasAnswered = false
        isCorrect = nil
        
        // Break word into chunks of 2-4 characters
        wordChunks = createWordChunks(from: card.word)
    }
    
    private func createWordChunks(from word: String) -> [WordChunk] {
        let cleanWord = word.lowercased().replacingOccurrences(of: " ", with: "")
        var chunks: [WordChunk] = []
        var currentIndex = 0
        let characters = Array(cleanWord)
        
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
        
        // Shuffle the chunks
        return chunks.shuffled()
    }
    
    private func addChunk(_ chunk: WordChunk) {
        guard !selectedChunks.contains(chunk) else { return }
        selectedChunks.append(chunk)
        HapticManager.shared.lightImpact()
    }
    
    private func removeChunk(_ chunk: WordChunk) {
        selectedChunks.removeAll { $0.id == chunk.id }
        HapticManager.shared.lightImpact()
    }
    
    private func clearSelection() {
        selectedChunks.removeAll()
        HapticManager.shared.lightImpact()
    }
    
    private func checkAnswer() {
        guard let card = currentCard else { return }
        
        let userAnswer = selectedChunks.map { $0.text }.joined().lowercased()
        let correctAnswer = card.word.lowercased().replacingOccurrences(of: " ", with: "")
        
        let correct = userAnswer == correctAnswer
        isCorrect = correct
        hasAnswered = true
        totalAnswers += 1
        
        if correct {
            correctAnswers += 1
            HapticManager.shared.correctAnswer()
        } else {
            HapticManager.shared.wrongAnswer()
        }
        
        // Record learning statistics
        viewModel.recordCardShown(card.id, isCorrect: correct)
        
        // Auto-play pronunciation for incorrect answers
        if !correct {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                speakCurrentWord()
            }
        }
    }
    
    private func nextCard() {
        // Auto-save progress periodically (every 5 cards)
        if currentIndex % 5 == 0 && currentIndex > 0 {
            saveCurrentProgress()
        }
        
        if currentIndex < cards.count - 1 {
            currentIndex += 1
            setupCurrentWord()
        } else {
            // Clear saved progress since game is complete
            clearSavedProgress()
            StreakManager.shared.recordGameCompletion(); showingResults = true
            HapticManager.shared.gameComplete()
        }
    }
    
    private func resetGame() {
        cards = viewModel.sortCardsForLearning(cards)
        setupGame()
        
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
    }
}

// MARK: - Save State

struct WordScrambleGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let totalAnswers: Int
    let cards: [FlashCard]
} 