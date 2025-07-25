import Foundation

struct VocabularyItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let dutchWord: String
    let translation: String
    let vocabularyReference: String?
    
    init(dutchWord: String, translation: String, vocabularyReference: String? = nil) {
        self.dutchWord = dutchWord
        self.translation = translation
        self.vocabularyReference = vocabularyReference
    }
}

struct Lesson: Identifiable, Codable, Hashable {
    var id: UUID
    let title: String
    let description: String
    let vocabulary: [VocabularyItem] // Dutch words with translations, linked to user's flashcards
    let exercises: [Exercise]
    
    // Additional properties from JSON
    var level: String = ""
    var category: String = ""
    var estimatedTime: Int = 0
    var difficulty: String = ""
    var prerequisites: [String] = []
    var rewards: [LessonRewardJSON] = []
    
    init(id: UUID = UUID(), title: String, description: String, vocabulary: [VocabularyItem], exercises: [Exercise]) {
        self.id = id
        self.title = title
        self.description = description
        self.vocabulary = vocabulary
        self.exercises = exercises
    }
}

struct Exercise: Identifiable, Codable, Hashable {
    enum ExerciseType: String, Codable, Hashable {
        case fillInBlank
        case missingWord
        case matchMeaning
        case useInSentence
        case sentenceBuilding
    }
    let id: UUID
    let type: ExerciseType
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
    let vocabularyReference: String? // Link to main vocab by word
    
    init(type: ExerciseType, prompt: String, options: [String], correctAnswer: String, explanation: String, vocabularyReference: String? = nil) {
        self.id = UUID()
        self.type = type
        self.prompt = prompt
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.vocabularyReference = vocabularyReference
    }
}

// MARK: - Lesson Manager

class LessonManager: ObservableObject {
    static let shared = LessonManager()
    
    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var lessonLevels: [String: String] = [:]
    @Published private(set) var lessonCategories: [String: String] = [:]
    @Published private(set) var metadata: LessonMetadataJSON?
    
    private init() {
        loadLessonsFromJSON()
    }
    
    private func loadLessonsFromJSON() {
        guard let url = Bundle.main.url(forResource: "dutch_lessons_complete", withExtension: "json") else {
            print("❌ Could not find dutch_lessons_complete.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let lessonData = try decoder.decode(LessonRootJSON.self, from: data)
            
            // Store metadata
            self.metadata = lessonData.metadata
            
            // Store levels and categories
            for level in lessonData.levels {
                lessonLevels[level.id] = level.name
            }
            
            for category in lessonData.categories {
                lessonCategories[category.id] = category.name
            }
            
            // Convert JSON lessons to Swift lessons
            lessons = lessonData.lessons.map { jsonLesson in
                var lesson = jsonLesson.toLesson()
                lesson.level = jsonLesson.level
                lesson.category = jsonLesson.category
                lesson.estimatedTime = jsonLesson.estimatedTime
                lesson.difficulty = jsonLesson.difficulty
                lesson.prerequisites = jsonLesson.prerequisites
                lesson.rewards = jsonLesson.rewards
                return lesson
            }
            
            print("✅ Loaded \(lessons.count) lessons from JSON")
            print("📊 Levels: \(lessonLevels)")
            print("📊 Categories: \(lessonCategories)")
            
        } catch {
            print("❌ Error loading lessons JSON: \(error)")
        }
    }
    
    // MARK: - Filter Methods
    
    func lessonsByLevel(_ level: String) -> [Lesson] {
        return lessons.filter { $0.level == level }
    }
    
    func lessonsByCategory(_ category: String) -> [Lesson] {
        return lessons.filter { $0.category == category }
    }
    
    func lesson(withId lessonId: String) -> Lesson? {
        return lessons.first { $0.id.uuidString == lessonId }
    }
    
    func availableLessons(for userLevel: String) -> [Lesson] {
        return lessons.filter { lesson in
            // Check if user meets prerequisites and level requirements
            return isLessonAvailable(lesson, for: userLevel)
        }
    }
    
    private func isLessonAvailable(_ lesson: Lesson, for userLevel: String) -> Bool {
        // Simple level-based availability
        let levelOrder = ["A1", "A2", "B1", "B2", "C1"]
        
        guard let userLevelIndex = levelOrder.firstIndex(of: userLevel),
              let lessonLevelIndex = levelOrder.firstIndex(of: lesson.level) else {
            return false
        }
        
        return lessonLevelIndex <= userLevelIndex
    }
    
    // MARK: - Vocabulary Integration
    
    func linkVocabularyToDatabase() {
        for lesson in lessons {
            for vocabItem in lesson.vocabulary {
                if let reference = vocabItem.vocabularyReference,
                   let _ = DutchVocabularyDatabase.shared.findWord(reference) {
                    // Link lesson vocabulary to database word
                    print("🔗 Linked lesson vocabulary '\(vocabItem.dutchWord)' to database word '\(reference)'")
                }
            }
        }
    }
    
    // MARK: - Replace Lessons (for import)
    @MainActor
    func replaceLessons(with newLessons: [Lesson]) {
        self.lessons = newLessons
    }
    
    // MARK: - Legacy Support (for backward compatibility)
    
    // These properties maintain backward compatibility with existing code
    var chapter25: Lesson? {
        return lessons.first { $0.title.contains("Chapter 2.5") }
    }
    
    var chapter26: Lesson? {
        return lessons.first { $0.title.contains("Chapter 2.6") }
    }
    
    var chapter31: Lesson? {
        return lessons.first { $0.title.contains("Chapter 3.1") }
    }
    
    var chapter33: Lesson? {
        return lessons.first { $0.title.contains("Chapter 3.3") }
    }
    
    var chapter35: Lesson? {
        return lessons.first { $0.title.contains("Chapter 3.5") }
    }
    
    // MARK: - Export Methods
    
    /// Export selected lessons as JSON string
    func exportLessonsToJSON(_ lessons: [Lesson]) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(lessons)
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            print("❌ Error encoding lessons to JSON: \(error)")
            return ""
        }
    }
    
    /// Export selected lessons as CSV string (basic, for spreadsheet use)
    func exportLessonsToCSV(_ lessons: [Lesson]) -> String {
        var csv = "Title,Description,Level,Category,EstimatedTime,Difficulty,Vocabulary,Exercises\n"
        for lesson in lessons {
            let vocab = lesson.vocabulary.map { $0.dutchWord }.joined(separator: "; ")
            let exercises = lesson.exercises.map { $0.prompt }.joined(separator: "; ")
            let row = [
                escapeCSV(lesson.title),
                escapeCSV(lesson.description),
                escapeCSV(lesson.level),
                escapeCSV(lesson.category),
                "\(lesson.estimatedTime)",
                escapeCSV(lesson.difficulty),
                escapeCSV(vocab),
                escapeCSV(exercises)
            ].joined(separator: ",")
            csv += row + "\n"
        }
        return csv
    }
    
    /// Export lessons as CSV (one row per lesson, no exercises)
    func exportLessonsTableCSV(_ lessons: [Lesson]) -> String {
        var csv = "LessonID,Title,Description,Level,Category,EstimatedTime,Difficulty,Vocabulary,Prerequisites,Rewards\n"
        for lesson in lessons {
            let vocab = lesson.vocabulary.map { "\($0.dutchWord) (\($0.translation))" }.joined(separator: "; ")
            let prereqs = lesson.prerequisites.joined(separator: "; ")
            let rewards = lesson.rewards.map { "\($0.type):\($0.value)" }.joined(separator: "; ")
            let row = [
                escapeCSV(lesson.id.uuidString),
                escapeCSV(lesson.title),
                escapeCSV(lesson.description),
                escapeCSV(lesson.level),
                escapeCSV(lesson.category),
                "\(lesson.estimatedTime)",
                escapeCSV(lesson.difficulty),
                escapeCSV(vocab),
                escapeCSV(prereqs),
                escapeCSV(rewards)
            ].joined(separator: ",")
            csv += row + "\n"
        }
        return csv
    }

    /// Export exercises as CSV (one row per exercise, with lesson ID)
    func exportExercisesTableCSV(_ lessons: [Lesson]) -> String {
        var csv = "LessonID,ExerciseID,Type,Prompt,Options,CorrectAnswer,Explanation,VocabularyReference\n"
        for lesson in lessons {
            for exercise in lesson.exercises {
                let options = exercise.options.joined(separator: "|")
                let row = [
                    escapeCSV(lesson.id.uuidString),
                    escapeCSV(exercise.id.uuidString),
                    escapeCSV(exercise.type.rawValue),
                    escapeCSV(exercise.prompt),
                    escapeCSV(options),
                    escapeCSV(exercise.correctAnswer),
                    escapeCSV(exercise.explanation),
                    escapeCSV(exercise.vocabularyReference ?? "")
                ].joined(separator: ",")
                csv += row + "\n"
            }
        }
        return csv
    }
    
    /// Helper to escape CSV fields
    private func escapeCSV(_ value: String) -> String {
        var v = value.replacingOccurrences(of: "\"", with: "\"\"")
        if v.contains(",") || v.contains("\n") || v.contains("\"") {
            v = "\"" + v + "\""
        }
        return v
    }
} 