import Foundation

// MARK: - Save State Models
struct GameSaveState: Codable {
    var id: UUID
    let gameType: SavedGameType
    let deckIds: [UUID]
    let savedAt: Date
    var gameData: Data
    
    init(gameType: SavedGameType, deckIds: [UUID], savedAt: Date, gameData: Data) {
        self.id = UUID()
        self.gameType = gameType
        self.deckIds = deckIds
        self.savedAt = savedAt
        self.gameData = gameData
    }
    
    enum SavedGameType: String, Codable {
        case study
        case test
        case memoryGame
        case trueFalse
        case lookCoverCheck
        case writing
        case wordScramble
        case multipleChoice
        case lesson
        case dutchGrammar
        
        var displayName: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .memoryGame: return "Memory Game"
            case .trueFalse: return "True or False"
            case .lookCoverCheck: return "Look Cover Check"
            case .writing: return "Write Your Card"
            case .wordScramble: return "Word Scramble"
            case .multipleChoice: return "Multiple Choice"
            case .lesson: return "Dutch Lesson"
            case .dutchGrammar: return "Dutch Grammar"
            }
        }
        
        var icon: String {
            switch self {
            case .study: return "book.fill"
            case .test: return "checkmark.circle.fill"
            case .memoryGame: return "brain.fill"
            case .trueFalse: return "questionmark.circle.fill"
            case .lookCoverCheck: return "eye.fill"
            case .writing: return "pencil.and.scribble"
            case .wordScramble: return "textformat.abc"
            case .multipleChoice: return "list.bullet.circle.fill"
            case .lesson: return "graduationcap.fill"
            case .dutchGrammar: return "textformat.abc"
            }
        }
    }
}

// MARK: - Individual Game State Structures
struct StudyGameState: Codable {
    let currentIndex: Int
    let knownCards: Set<UUID>
    let unknownCards: Set<UUID>
    let skippedCards: Set<UUID>
    let isShowingFront: Bool
    let isShowingExample: Bool
    let cards: [FlashCard]
}

struct TestGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let incorrectCards: Set<UUID>
    let cards: [FlashCard]
    let selectedAnswer: String?
    let hasAnswered: Bool
}

struct MemoryGameState: Codable {
    let gameCards: [SavedCard]
    let displayedCards: [SavedCard]
    let remainingCards: [SavedCard]
    let selectedCardId: UUID?
    let score: Int
    let moves: Int
    let incorrectMatches: Set<UUID>
    
    struct SavedCard: Codable {
        let id: UUID
        let content: String
        let cardType: String // "word" or "definition"
        let originalCardId: UUID
        let isMatched: Bool
        let isSelected: Bool
    }
}

struct TrueFalseGameState: Codable {
    let currentIndex: Int
    let score: Int
    let questionsAnswered: Int
    let correctAnswers: Int
    let incorrectAnswers: Int
    let remainingCards: [FlashCard]
    let cards: [FlashCard]
}

struct WritingGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let totalAnswers: Int
    let cards: [FlashCard]
}

struct LookCoverCheckGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let totalAnswers: Int
    let cards: [FlashCard]
    let gamePhase: String // "look", "cover", "check"
}

struct DeHetGameState: Codable {
    let currentIndex: Int
    let correctAnswers: Int
    let totalAnswers: Int
    let cards: [FlashCard]
    let showingAnswer: Bool
    let lastAnswerCorrect: Bool?
}

struct LessonGameState: Codable {
    let lessonId: UUID
    let lessonTitle: String
    let currentExerciseIndex: Int
    let correctCount: Int
    let userAnswers: [Int: String]
    let shuffledExercises: [SavedExercise]
    let lessonStartTime: Date?
    let exerciseAttempts: [ExerciseAttempt]
    
    struct SavedExercise: Codable {
        let exerciseId: UUID
        let prompt: String
        let shuffledOptions: [String]
        let correctIndex: Int
        let correctAnswer: String
        let explanation: String
        let vocabularyReference: String?
    }
}

struct DutchGrammarGameState: Codable {
    let ruleId: String
    let ruleTitle: String
    let currentExerciseIndex: Int
    let exerciseScore: Int
    let questionAnswers: [Int: Int]
    let questionScores: [Int: Bool]
    let shuffledExercises: [SavedGrammarExercise]
    let exerciseStartTime: Date?
    
    var hasSignificantProgress: Bool {
        return currentExerciseIndex > 0 || exerciseScore > 0
    }
    
    struct SavedGrammarExercise: Codable {
        let question: String
        let options: [String]
        let correctAnswer: Int
        let explanation: String
        let hint: String?
        let exerciseType: String
    }
}

// MARK: - Save State Manager
class SaveStateManager: ObservableObject {
    static let shared = SaveStateManager()
    
    @Published var availableSaveStates: [GameSaveState] = []
    
    private let saveStatesKey = "GameSaveStates"
    private let maxSaveStates = 10 // Limit to prevent storage bloat
    
    private init() {
        loadSaveStates()
    }
    
    // MARK: - Public Interface
    
    /// Save a game state
    func saveGameState<T: Codable>(
        gameType: GameSaveState.SavedGameType,
        gameData: T
    ) {
        do {
            let encodedData = try JSONEncoder().encode(gameData)
            let saveState = GameSaveState(
                gameType: gameType,
                deckIds: [], // No longer tracking specific decks
                savedAt: Date(),
                gameData: encodedData
            )
            
            // Remove existing save state for same game type
            availableSaveStates.removeAll { existingState in
                existingState.gameType == gameType
            }
            
            // Add new save state
            availableSaveStates.append(saveState)
            
            // Keep only the most recent save states
            availableSaveStates = Array(availableSaveStates
                .sorted { $0.savedAt > $1.savedAt }
                .prefix(maxSaveStates))
            
            saveSaveStates()
            
            print("✅ Saved game state for \(gameType.displayName)")
        } catch {
            print("❌ Failed to save game state: \(error)")
        }
    }
    
    /// Load a game state
    func loadGameState<T: Codable>(
        gameType: GameSaveState.SavedGameType,
        as type: T.Type
    ) -> T? {
        guard let saveState = availableSaveStates.first(where: { 
            $0.gameType == gameType
        }) else {
            return nil
        }
        
        do {
            let gameData = try JSONDecoder().decode(type, from: saveState.gameData)
            print("✅ Loaded game state for \(gameType.displayName)")
            return gameData
        } catch {
            print("❌ Failed to load game state: \(error)")
            return nil
        }
    }
    
    /// Check if a save state exists for a specific game type
    func hasSaveState(gameType: GameSaveState.SavedGameType) -> Bool {
        return availableSaveStates.contains { 
            $0.gameType == gameType
        }
    }
    
    /// Get save state info for display
    func getSaveStateInfo(gameType: GameSaveState.SavedGameType) -> Date? {
        guard let saveState = availableSaveStates.first(where: { 
            $0.gameType == gameType
        }) else {
            return nil
        }
        
        return saveState.savedAt
    }
    
    /// Delete a specific save state
    func deleteSaveState(gameType: GameSaveState.SavedGameType) {
        availableSaveStates.removeAll { 
            $0.gameType == gameType
        }
        saveSaveStates()
        print("🗑️ Deleted save state for \(gameType.displayName)")
    }
    
    /// Clear all save states
    func clearAllSaveStates() {
        availableSaveStates.removeAll()
        saveSaveStates()
        print("🗑️ Cleared all save states")
    }
    
    /// Clear old save states (older than 30 days)
    func clearOldSaveStates() {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let originalCount = availableSaveStates.count
        
        availableSaveStates.removeAll { $0.savedAt < thirtyDaysAgo }
        
        if availableSaveStates.count != originalCount {
            saveSaveStates()
            print("🧹 Cleared \(originalCount - availableSaveStates.count) old save states")
        }
    }
    
    // MARK: - Private Methods
    
    private func loadSaveStates() {
        guard let data = UserDefaults.standard.data(forKey: saveStatesKey) else {
            print("📁 No save states found")
            return
        }
        
        do {
            availableSaveStates = try JSONDecoder().decode([GameSaveState].self, from: data)
            print("📁 Loaded \(availableSaveStates.count) save states")
            
            // Clean up old save states on load
            clearOldSaveStates()
        } catch {
            print("❌ Failed to load save states: \(error)")
            availableSaveStates = []
        }
    }
    
    private func saveSaveStates() {
        do {
            let data = try JSONEncoder().encode(availableSaveStates)
            UserDefaults.standard.set(data, forKey: saveStatesKey)
            print("💾 Saved \(availableSaveStates.count) save states")
        } catch {
            print("❌ Failed to save save states: \(error)")
        }
    }
} 