import Foundation

struct UserAnswer: Identifiable, Codable, Hashable {
    var id: UUID
    var text: String
    var isCorrect: Bool
    var orderIndex: Int? // For sentence building - indicates position in correct order (0-based)
    
    init(text: String, isCorrect: Bool = false, orderIndex: Int? = nil) {
        self.id = UUID()
        self.text = text
        self.isCorrect = isCorrect
        self.orderIndex = orderIndex
    }
}

struct UserQuestion: Identifiable, Codable, Hashable {
    var id: UUID
    var questionType: String
    var question: String
    var answers: [UserAnswer]
    var hint: String
    
    init(questionType: String, question: String, answers: [UserAnswer] = [], hint: String) {
        self.id = UUID()
        self.questionType = questionType
        self.question = question
        self.answers = answers.isEmpty ? [UserAnswer(text: "", isCorrect: true)] : answers
        self.hint = hint
    }
    
    // Computed property to get the first correct answer for backward compatibility
    var correctAnswer: String {
        if questionType.lowercased() == "sentence building" {
            // For sentence building, return words in correct order
            let orderedWords = answers
                .filter { $0.orderIndex != nil }
                .sorted { ($0.orderIndex ?? 0) < ($1.orderIndex ?? 0) }
                .map { $0.text }
            return orderedWords.joined(separator: " ")
        } else {
            return answers.first(where: { $0.isCorrect })?.text ?? ""
        }
    }
    
    // Get all correct answers
    var correctAnswers: [String] {
        if questionType.lowercased() == "sentence building" {
            return [correctAnswer] // Single correct sentence
        } else {
            return answers.filter { $0.isCorrect }.map { $0.text }
        }
    }
    
    // Check if this is a sentence building question
    var isSentenceBuilding: Bool {
        return questionType.lowercased() == "sentence building"
    }
}

struct UserLesson: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var questions: [UserQuestion]
    var createdDate: Date
    var lastModified: Date
    
    init(title: String, description: String, questions: [UserQuestion] = []) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.questions = questions
        self.createdDate = Date()
        self.lastModified = Date()
    }
    
    // Convert to Lesson format for compatibility with existing system
    func toLesson() -> Lesson {
        // Create exercises from all user questions
        let exercises = questions.map { userQuestion in
            var options: [String]
            
            if userQuestion.isSentenceBuilding {
                // For sentence building, provide all words in random order
                options = userQuestion.answers.map { $0.text }.shuffled()
            } else {
                // For other types, use all answers as options
                options = userQuestion.answers.map { $0.text }.shuffled()
            }
            
            return Exercise(
                type: self.exerciseTypeFromString(userQuestion.questionType),
                prompt: userQuestion.question,
                options: options,
                correctAnswer: userQuestion.correctAnswer,
                explanation: userQuestion.hint.isEmpty ? "User created lesson" : userQuestion.hint
            )
        }
        
        return Lesson(
            id: self.id,
            title: self.title,
            description: self.description,
            vocabulary: [], // User lessons don't have vocabulary by default
            exercises: exercises
        )
    }
    
    private func exerciseTypeFromString(_ typeString: String) -> Exercise.ExerciseType {
        switch typeString.lowercased() {
        case "fill in blank":
            return .fillInBlank
        case "missing word":
            return .missingWord
        case "match meaning":
            return .matchMeaning
        case "use in sentence":
            return .useInSentence
        case "sentence building":
            return .sentenceBuilding
        default:
            return .fillInBlank
        }
    }
}

class UserLessonManager: ObservableObject {
    static let shared = UserLessonManager()
    
    @Published var userLessons: [UserLesson] = []
    
    private let userDefaults = UserDefaults.standard
    private let userLessonsKey = "userCreatedLessons"
    
    private init() {
        loadUserLessons()
    }
    
    // MARK: - Public Methods
    
    func addLesson(_ lesson: UserLesson) {
        userLessons.append(lesson)
        saveUserLessons()
    }
    
    func updateLesson(_ lesson: UserLesson) {
        if let index = userLessons.firstIndex(where: { $0.id == lesson.id }) {
            var updatedLesson = lesson
            updatedLesson.lastModified = Date()
            userLessons[index] = updatedLesson
            saveUserLessons()
        }
    }
    
    func deleteLesson(id: UUID) {
        userLessons.removeAll { $0.id == id }
        saveUserLessons()
    }
    
    func getLesson(id: UUID) -> UserLesson? {
        return userLessons.first { $0.id == id }
    }
    
    // Convert user lessons to regular lessons for compatibility
    func getUserLessonsAsLessons() -> [Lesson] {
        return userLessons.map { $0.toLesson() }
    }
    
    // MARK: - Private Methods
    
    private func saveUserLessons() {
        do {
            let data = try JSONEncoder().encode(userLessons)
            userDefaults.set(data, forKey: userLessonsKey)
            print("✅ Saved \(userLessons.count) user lessons")
        } catch {
            print("❌ Error saving user lessons: \(error)")
        }
    }
    
    private func loadUserLessons() {
        guard let data = userDefaults.data(forKey: userLessonsKey) else {
            print("📝 No user lessons found")
            return
        }
        
        do {
            userLessons = try JSONDecoder().decode([UserLesson].self, from: data)
            print("✅ Loaded \(userLessons.count) user lessons")
        } catch {
            print("❌ Error loading user lessons: \(error)")
            
            // Try to migrate from previous format (multiple questions, single answer)
            do {
                let oldLessons = try JSONDecoder().decode([OldMultiQuestionLesson].self, from: data)
                userLessons = oldLessons.map { oldLesson in
                    let migratedQuestions = oldLesson.questions.map { oldQuestion in
                        UserQuestion(
                            questionType: oldQuestion.questionType,
                            question: oldQuestion.question,
                            answers: [UserAnswer(text: oldQuestion.answer, isCorrect: true)],
                            hint: oldQuestion.hint
                        )
                    }
                    return UserLesson(
                        title: oldLesson.title,
                        description: oldLesson.description,
                        questions: migratedQuestions
                    )
                }
                saveUserLessons()
                print("✅ Migrated \(userLessons.count) lessons from multiple questions format")
            } catch {
                // Try to migrate from original format (single question)
                do {
                    let oldLessons = try JSONDecoder().decode([OldUserLesson].self, from: data)
                    userLessons = oldLessons.map { oldLesson in
                        let question = UserQuestion(
                            questionType: oldLesson.questionType,
                            question: oldLesson.question,
                            answers: [UserAnswer(text: oldLesson.answer, isCorrect: true)],
                            hint: oldLesson.hint
                        )
                        return UserLesson(
                            title: oldLesson.title,
                            description: oldLesson.description,
                            questions: [question]
                        )
                    }
                    saveUserLessons()
                    print("✅ Migrated \(userLessons.count) lessons from original format")
                } catch {
                    print("❌ Error migrating user lessons: \(error)")
                    userLessons = []
                }
            }
        }
    }
}

// Migration support for previous formats
private struct OldMultiQuestionLesson: Codable {
    let id: UUID
    let title: String
    let description: String
    let questions: [OldUserQuestion]
    let createdDate: Date
    let lastModified: Date
}

private struct OldUserQuestion: Codable {
    let id: UUID
    let questionType: String
    let question: String
    let answer: String
    let hint: String
}

// Original format for migration
private struct OldUserLesson: Codable {
    let id: UUID
    let title: String
    let description: String
    let questionType: String
    let question: String
    let answer: String
    let hint: String
    let createdDate: Date
    let lastModified: Date
} 