import Foundation

// MARK: - Dutch Word Exercise System
// Allows users to create custom exercises for specific words they're struggling with

struct DutchWordExercise: Identifiable, Codable, Hashable {
    let id: UUID
    let targetWord: String
    let wordTranslation: String
    let exercises: [WordExercise]
    let difficulty: ExerciseDifficulty
    let category: WordCategory
    let createdAt: Date
    let lastModified: Date
    let isUserCreated: Bool
    let sourceFile: String? // For imported exercises
    
    init(targetWord: String, wordTranslation: String, exercises: [WordExercise], difficulty: ExerciseDifficulty = .medium, category: WordCategory = .general, isUserCreated: Bool = true, sourceFile: String? = nil) {
        self.id = UUID()
        self.targetWord = targetWord
        self.wordTranslation = wordTranslation
        self.exercises = exercises
        self.difficulty = difficulty
        self.category = category
        self.createdAt = Date()
        self.lastModified = Date()
        self.isUserCreated = isUserCreated
        self.sourceFile = sourceFile
    }
}

struct WordExercise: Identifiable, Codable, Hashable {
    enum ExerciseType: String, Codable, Hashable, CaseIterable {
        case fillInBlank = "Fill in the Blank"
        case sentenceBuilding = "Sentence Building"
        case multipleChoice = "Multiple Choice"
        case translation = "Translation"
        case wordOrder = "Word Order"
        case contextClue = "Context Clue"
        case pronunciation = "Pronunciation"
        case conjugation = "Verb Conjugation"
        case articlePractice = "Article Practice"
        case synonymAntonym = "Synonym/Antonym"
    }
    
    let id: UUID
    let type: ExerciseType
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
    let hint: String?
    let difficulty: ExerciseDifficulty
    let context: String? // Additional context for the exercise
    
    init(type: ExerciseType, prompt: String, options: [String], correctAnswer: String, explanation: String, hint: String? = nil, difficulty: ExerciseDifficulty = .medium, context: String? = nil) {
        self.id = UUID()
        self.type = type
        self.prompt = prompt
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.hint = hint
        self.difficulty = difficulty
        self.context = context
    }
}

enum ExerciseDifficulty: String, Codable, Hashable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: String {
        switch self {
        case .easy: return "green"
        case .medium: return "orange"
        case .hard: return "red"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "Beginner level - basic understanding"
        case .medium: return "Intermediate level - practical usage"
        case .hard: return "Advanced level - complex contexts"
        }
    }
}

enum WordCategory: String, Codable, Hashable, CaseIterable {
    case general = "General"
    case business = "Business"
    case academic = "Academic"
    case casual = "Casual"
    case formal = "Formal"
    case technical = "Technical"
    case medical = "Medical"
    case legal = "Legal"
    case travel = "Travel"
    case food = "Food"
    case family = "Family"
    case emotions = "Emotions"
    case weather = "Weather"
    case time = "Time"
    case numbers = "Numbers"
    case colors = "Colors"
    case animals = "Animals"
    case sports = "Sports"
    case music = "Music"
    case art = "Art"
    
    var icon: String {
        switch self {
        case .general: return "textformat"
        case .business: return "briefcase"
        case .academic: return "graduationcap"
        case .casual: return "person.2"
        case .formal: return "doc.text"
        case .technical: return "gearshape"
        case .medical: return "cross"
        case .legal: return "building.columns"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .family: return "house"
        case .emotions: return "heart"
        case .weather: return "cloud.sun"
        case .time: return "clock"
        case .numbers: return "number"
        case .colors: return "paintpalette"
        case .animals: return "pawprint"
        case .sports: return "sportscourt"
        case .music: return "music.note"
        case .art: return "paintbrush"
        }
    }
}

// MARK: - Import/Export Support
struct DutchWordExerciseImport: Codable {
    let exercises: [DutchWordExercise]
    let metadata: ImportMetadata
}

struct ImportMetadata: Codable {
    let source: String
    let version: String
    let importedAt: Date
    let totalExercises: Int
    let categories: [String]
}

// MARK: - Example Exercise Data
extension DutchWordExercise {
    static func exampleForWord(_ word: String, translation: String) -> DutchWordExercise {
        let exercises: [WordExercise]
        
        switch word.lowercased() {
        case "terecht":
            exercises = [
                WordExercise(
                    type: .fillInBlank,
                    prompt: "De straf was _____ voor wat hij had gedaan.",
                    options: ["terecht", "onterecht", "recht", "rechtstreeks"],
                    correctAnswer: "terecht",
                    explanation: "'Terecht' means 'justified' or 'deserved'. The punishment was justified for what he had done.",
                    hint: "Think about whether the punishment was deserved",
                    difficulty: .medium
                ),
                WordExercise(
                    type: .sentenceBuilding,
                    prompt: "Arrange the words to form a correct Dutch sentence:",
                    options: ["De", "kritiek", "was", "terecht", "en", "nuttig"],
                    correctAnswer: "De kritiek was terecht en nuttig",
                    explanation: "'De kritiek was terecht en nuttig' means 'The criticism was justified and useful'.",
                    hint: "Start with 'De kritiek'",
                    difficulty: .medium
                ),
                WordExercise(
                    type: .multipleChoice,
                    prompt: "What does 'terecht' mean in English?",
                    options: ["Wrong", "Justified", "Direct", "Correct"],
                    correctAnswer: "Justified",
                    explanation: "'Terecht' means 'justified' or 'deserved'. It's used when something is fair or appropriate.",
                    difficulty: .easy
                ),
                WordExercise(
                    type: .translation,
                    prompt: "Translate 'The complaint was justified' to Dutch:",
                    options: ["De klacht was terecht", "De klacht was onterecht", "De klacht was recht", "De klacht was rechtstreeks"],
                    correctAnswer: "De klacht was terecht",
                    explanation: "'De klacht was terecht' is the correct translation. 'Terecht' means 'justified'.",
                    difficulty: .medium
                ),
                WordExercise(
                    type: .contextClue,
                    prompt: "In the sentence 'Hij kreeg terecht een boete', what does 'terecht' indicate?",
                    options: ["The fine was too high", "The fine was deserved", "The fine was unfair", "The fine was unexpected"],
                    correctAnswer: "The fine was deserved",
                    explanation: "'Terecht' indicates that the fine was deserved or justified for what he did.",
                    difficulty: .hard
                ),
                WordExercise(
                    type: .wordOrder,
                    prompt: "Complete the sentence with the correct word order: 'De beslissing _____ was _____'",
                    options: ["om", "terecht", "te", "gaan"],
                    correctAnswer: "om te gaan was terecht",
                    explanation: "'De beslissing om te gaan was terecht' means 'The decision to leave was justified'.",
                    hint: "Think about the infinitive construction 'om te'",
                    difficulty: .hard
                ),
                WordExercise(
                    type: .synonymAntonym,
                    prompt: "Which word is an antonym of 'terecht'?",
                    options: ["rechtvaardig", "onterecht", "correct", "passend"],
                    correctAnswer: "onterecht",
                    explanation: "'Onterecht' is the opposite of 'terecht'. It means 'unjustified' or 'undeserved'.",
                    difficulty: .medium
                ),
                WordExercise(
                    type: .conjugation,
                    prompt: "Complete: 'Deze straf _____ (zijn) terecht'",
                    options: ["is", "zijn", "was", "waren"],
                    correctAnswer: "is",
                    explanation: "'Deze straf is terecht' means 'This punishment is justified'. 'Straf' is singular, so we use 'is'.",
                    difficulty: .medium
                ),
                WordExercise(
                    type: .articlePractice,
                    prompt: "Which article is correct: '_____ terecht oordeel'?",
                    options: ["De", "Het", "Een", "Geen"],
                    correctAnswer: "Een",
                    explanation: "'Een terecht oordeel' means 'a justified judgment'. 'Oordeel' is a het-word, but we use 'een' here.",
                    difficulty: .hard
                ),
                WordExercise(
                    type: .pronunciation,
                    prompt: "How do you pronounce 'terecht'?",
                    options: ["teh-REH-cht", "TEH-recht", "teh-recht", "teh-REH-kt"],
                    correctAnswer: "teh-REH-cht",
                    explanation: "'Terecht' is pronounced 'teh-REH-cht' with emphasis on the second syllable.",
                    difficulty: .easy
                )
            ]
        default:
            exercises = [
                WordExercise(
                    type: .fillInBlank,
                    prompt: "Complete the sentence with '\(word)':",
                    options: [word, "other", "different", "similar"],
                    correctAnswer: word,
                    explanation: "This is a basic exercise for the word '\(word)' which means '\(translation)'.",
                    difficulty: .easy
                )
            ]
        }
        
        return DutchWordExercise(
            targetWord: word,
            wordTranslation: translation,
            exercises: exercises,
            difficulty: .medium,
            category: .general
        )
    }
} 