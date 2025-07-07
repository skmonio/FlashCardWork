import SwiftUI

// MARK: - Notification Names for Progressive Study
extension Notification.Name {
    static let studySessionCompleted = Notification.Name("studySessionCompleted")
    static let testSessionCompleted = Notification.Name("testSessionCompleted")
    static let memoryGameCompleted = Notification.Name("memoryGameCompleted")
    static let writingSessionCompleted = Notification.Name("writingSessionCompleted")
    static let wordScrambleSessionCompleted = Notification.Name("wordScrambleSessionCompleted")
}

struct ProgressiveStudyView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let gameMode: GameMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var currentLevel: Int = 1
    @State private var levelResults: [LevelResult] = []
    @State private var isStartingLevel = false
    @State private var showingFinalResults = false
    @State private var showingLevelCompletion = false
    
    // Track used cards to prevent repetition between levels
    @State private var usedCardIds: Set<UUID> = []
    
    private let totalLevels = 3
    private let questionsPerLevel = 10
    
    var body: some View {
        VStack(spacing: 0) {
            UnifiedHeader(
                title: gameTitle,
                onBack: { navigationCoordinator.pop() },
                onProfile: { navigationCoordinator.presentSheet(.userProfile) }
            )
            
            if showingFinalResults {
                // Show final results after all levels
                finalResultsView
            } else if showingLevelCompletion {
                // Show level completion screen
                levelCompletionView
            } else if isStartingLevel {
                // Show the game view for the current level
                gameViewForCurrentLevel
            } else {
                // Show level selection or completion
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Level \(currentLevel) of \(totalLevels)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(levelDescription)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 40)
                    
                    // Level Progress
                    VStack(spacing: 16) {
                        HStack(spacing: 8) {
                            ForEach(1...totalLevels, id: \.self) { level in
                                Circle()
                                    .fill(levelColor(for: level))
                                    .frame(width: 12, height: 12)
                                    .overlay(
                                        Circle()
                                            .stroke(level == currentLevel ? .blue : .clear, lineWidth: 2)
                                    )
                            }
                        }
                        
                        Text("Progress: \(completedLevels)/\(totalLevels) levels")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Level Details
                    VStack(spacing: 20) {
                        LevelInfoCard(
                            level: currentLevel,
                            title: levelTitle,
                            description: levelDescription,
                            icon: levelIcon,
                            color: levelColor(for: currentLevel)
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Start Level Button
                    Button(action: {
                        isStartingLevel = true
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Start Level \(currentLevel)")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(levelColor(for: currentLevel))
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            // Start immediately with level 1
            isStartingLevel = true
        }
    }
    
    @ViewBuilder
    private var gameViewForCurrentLevel: some View {
        switch gameMode {
        case .study:
            StudyView(
                viewModel: viewModel,
                cards: getCardsForLevel(),
                deckIds: [],
                shouldLoadSaveState: false,
                studyMode: studyModeForLevel(),
                maxQuestions: questionsPerLevel,
                onLevelComplete: { result in
                    // Mark the cards used in this level
                    let levelCards = getCardsForLevel()
                    markLevelCardsAsUsed(levelCards)
                    
                    levelResults.append(result)
                    
                    if currentLevel < totalLevels {
                        // Show level completion screen for levels 1 and 2
                        showingLevelCompletion = true
                    } else {
                        // Level 3 completed, show final results
                        showingFinalResults = true
                    }
                }
            )
        case .test:
            TestView(
                viewModel: viewModel,
                cards: getCardsForLevel(),
                deckIds: [],
                shouldLoadSaveState: false,
                studyMode: studyModeForLevel(),
                maxQuestions: questionsPerLevel,
                onLevelComplete: { result in
                    // Mark the cards used in this level
                    let levelCards = getCardsForLevel()
                    markLevelCardsAsUsed(levelCards)
                    
                    levelResults.append(result)
                    
                    if currentLevel < totalLevels {
                        // Show level completion screen for levels 1 and 2
                        showingLevelCompletion = true
                    } else {
                        // Level 3 completed, show final results
                        showingFinalResults = true
                    }
                }
            )
        case .writing:
            WritingView(
                viewModel: viewModel,
                cards: getCardsForLevel(),
                deckIds: [],
                shouldLoadSaveState: false,
                studyMode: studyModeForLevel(),
                maxQuestions: questionsPerLevel,
                onLevelComplete: { result in
                    // Mark the cards used in this level
                    let levelCards = getCardsForLevel()
                    markLevelCardsAsUsed(levelCards)
                    
                    levelResults.append(result)
                    
                    if currentLevel < totalLevels {
                        // Show level completion screen for levels 1 and 2
                        showingLevelCompletion = true
                    } else {
                        // Level 3 completed, show final results
                        showingFinalResults = true
                    }
                }
            )
        case .wordScramble:
            WordScrambleView(
                viewModel: viewModel,
                cards: getCardsForLevel(),
                deckIds: [],
                shouldLoadSaveState: false,
                studyMode: studyModeForLevel(),
                maxQuestions: questionsPerLevel,
                onLevelComplete: { result in
                    // Mark the cards used in this level
                    let levelCards = getCardsForLevel()
                    markLevelCardsAsUsed(levelCards)
                    
                    levelResults.append(result)
                    
                    if currentLevel < totalLevels {
                        // Show level completion screen for levels 1 and 2
                        showingLevelCompletion = true
                    } else {
                        // Level 3 completed, show final results
                        showingFinalResults = true
                    }
                }
            )
        case .truefalse:
            TrueFalseView(
                viewModel: viewModel,
                cards: getCardsForLevel(),
                deckIds: [],
                shouldLoadSaveState: false,
                studyMode: studyModeForLevel(),
                maxQuestions: questionsPerLevel,
                onLevelComplete: { result in
                    // Mark the cards used in this level
                    let levelCards = getCardsForLevel()
                    markLevelCardsAsUsed(levelCards)
                    
                    levelResults.append(result)
                    
                    if currentLevel < totalLevels {
                        // Show level completion screen for levels 1 and 2
                        showingLevelCompletion = true
                    } else {
                        // Level 3 completed, show final results
                        showingFinalResults = true
                    }
                }
            )
        case .game:
            // Implementation needed
            Text("Game mode not implemented")
        }
    }
    
    @ViewBuilder
    private var finalResultsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.yellow)
                    
                    Text("Study Complete")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Congratulations! You've completed all three levels.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Overall Stats
                VStack(spacing: 16) {
                    Text("Overall Performance")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(totalCorrectAnswers)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Correct")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(totalQuestions)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(overallAccuracy)%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Accuracy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                // Level Breakdown
                VStack(spacing: 16) {
                    Text("Level Breakdown")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 12) {
                        ForEach(levelResults.indices, id: \.self) { index in
                            let result = levelResults[index]
                            LevelResultRow(
                                level: index + 1,
                                result: result,
                                color: levelColor(for: index + 1)
                            )
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        // Reset and start over
                        currentLevel = 1
                        levelResults = []
                        showingFinalResults = false
                        resetUsedCards() // Reset used cards for new session
                        isStartingLevel = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.title2)
                            Text("Play Again")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var levelCompletionView: some View {
        LevelCompletionView(
            level: currentLevel,
            result: levelResults.last ?? LevelResult(level: 1, score: 0, total: 0),
            onContinue: {
                showingLevelCompletion = false
                if currentLevel < totalLevels {
                    // Continue to next level
                    currentLevel += 1
                    isStartingLevel = true
                }
            },
            onFinish: {
                showingLevelCompletion = false
                navigationCoordinator.pop()
            }
        )
    }
    
    // MARK: - Computed Properties
    private var completedLevels: Int {
        return currentLevel - 1
    }
    
    private var totalCorrectAnswers: Int {
        return levelResults.reduce(0) { $0 + $1.score }
    }
    
    private var totalQuestions: Int {
        return levelResults.reduce(0) { $0 + $1.total }
    }
    
    private var overallAccuracy: Int {
        guard totalQuestions > 0 else { return 0 }
        return Int((Double(totalCorrectAnswers) / Double(totalQuestions)) * 100)
    }
    
    private var levelTitle: String {
        switch currentLevel {
        case 1: return "Warm Up"
        case 2: return "Challenge"
        case 3: return "Expert"
        default: return "Level \(currentLevel)"
        }
    }
    
    private var levelDescription: String {
        switch currentLevel {
        case 1: return "Start with cards you know well - 10 questions"
        case 2: return "Mix of all cards for a challenge - 10 questions"
        case 3: return "Focus on your difficult cards - 10 questions"
        default: return "Level \(currentLevel) description"
        }
    }
    
    private var levelIcon: String {
        switch currentLevel {
        case 1: return "leaf.fill"
        case 2: return "bolt.fill"
        case 3: return "brain.head.profile"
        default: return "number.circle.fill"
        }
    }
    
    private var gameTitle: String {
        switch gameMode {
        case .study: return "Study Your Cards"
        case .test: return "Test Your Cards"
        case .game: return "Remember Your Cards"
        case .writing: return "Write Your Cards"
        case .wordScramble: return "Jumble Your Cards"
        case .truefalse: return "True or False"
        }
    }
    
    // MARK: - Helper Methods
    private func markLevelCardsAsUsed(_ cards: [FlashCard]) {
        usedCardIds.formUnion(cards.map { $0.id })
    }
    
    private func resetUsedCards() {
        usedCardIds.removeAll()
    }
    
    private func levelColor(for level: Int) -> Color {
        switch level {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }
    
    private func studyModeForLevel() -> StudyMode {
        switch currentLevel {
        case 1: return .maintenance
        case 2: return .cram
        case 3: return .adaptive
        default: return .adaptive
        }
    }
    
    private func getCardsForLevel() -> [FlashCard] {
        // Filter out cards that have already been used in previous levels
        let availableCards = viewModel.flashCards.filter { !usedCardIds.contains($0.id) }
        
        // Apply study mode filtering based on current level
        let filteredCards: [FlashCard]
        switch currentLevel {
        case 1: // Maintenance mode - cards with 70-90% learning percentage
            filteredCards = availableCards.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage >= 70 && percentage <= 90
            }
        case 2: // Cram mode - all available cards
            filteredCards = availableCards
        case 3: // Adaptive mode - struggling cards (< 70% or consecutive incorrect)
            filteredCards = availableCards.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage < 70 || card.consecutiveIncorrect > 0
            }
        default:
            filteredCards = availableCards
        }
        
        // If we don't have enough cards for the specific mode, fall back to all available cards
        if filteredCards.count < questionsPerLevel {
            return Array(availableCards.prefix(questionsPerLevel))
        }
        
        // Return the first 10 cards for this level
        return Array(filteredCards.prefix(questionsPerLevel))
    }
    
    private func difficultyForLevel(_ level: Int) -> MemoryGameDifficulty {
        switch level {
        case 1: return .easy
        case 2: return .medium
        case 3: return .hard
        default: return .medium
        }
    }
}

// MARK: - Supporting Views
struct LevelInfoCard: View {
    let level: Int
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct LevelCompletionView: View {
    let level: Int
    let result: LevelResult
    let onContinue: () -> Void
    let onFinish: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    
                    Text("Level \(level) Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("Great job! You've completed this level.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Results
                VStack(spacing: 16) {
                    Text("Your Score")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(result.score)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            Text("Correct")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(result.total)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        VStack {
                            Text("\(Int((Double(result.score) / Double(result.total)) * 100))%")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            Text("Accuracy")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                // Level progression info
                if level < 3 {
                    VStack(spacing: 12) {
                        Text("Next Level: \(levelTitle(for: level + 1))")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(levelDescription(for: level + 1))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(levelColor(for: level + 1).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(levelColor(for: level + 1).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    if level < 3 {
                        Button(action: onContinue) {
                            HStack {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title2)
                                Text("Continue to Level \(level + 1)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(levelColor(for: level + 1))
                            )
                        }
                    }
                    
                    Button(action: onFinish) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            Text(level < 3 ? "Finish Here" : "Complete")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.blue, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func levelTitle(for level: Int) -> String {
        switch level {
        case 1: return "Warm Up"
        case 2: return "Challenge"
        case 3: return "Expert"
        default: return "Level \(level)"
        }
    }
    
    private func levelDescription(for level: Int) -> String {
        switch level {
        case 1: return "Start with cards you know well - 10 questions"
        case 2: return "Mix of all cards for a challenge - 10 questions"
        case 3: return "Focus on your difficult cards - 10 questions"
        default: return "Level \(level) description"
        }
    }
    
    private func levelColor(for level: Int) -> Color {
        switch level {
        case 1: return .green
        case 2: return .orange
        case 3: return .red
        default: return .gray
        }
    }
}

// MARK: - Supporting Types
struct LevelResult {
    let level: Int
    let score: Int
    let total: Int
}

struct LevelResultRow: View {
    let level: Int
    let result: LevelResult
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Level indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)
                
                Text("Level \(level)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Score
            HStack(spacing: 8) {
                Text("\(result.score)/\(result.total)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text("(\(Int((Double(result.score) / Double(result.total)) * 100))%)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
} 