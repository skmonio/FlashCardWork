import Foundation

// MARK: - Lesson Analytics Models

struct LessonAttempt: Identifiable, Codable {
    let id: UUID
    let lessonId: UUID
    let lessonTitle: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let totalExercises: Int
    let correctAnswers: Int
    let exerciseAttempts: [ExerciseAttempt]
    let completionRate: Double
    let averageTimePerExercise: TimeInterval
    
    var accuracy: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalExercises)
    }
    
    var scorePercentage: Int {
        Int(accuracy * 100)
    }
    
    init(lessonId: UUID, lessonTitle: String, startTime: Date, endTime: Date, totalExercises: Int, correctAnswers: Int, exerciseAttempts: [ExerciseAttempt]) {
        self.id = UUID()
        self.lessonId = lessonId
        self.lessonTitle = lessonTitle
        self.startTime = startTime
        self.endTime = endTime
        self.duration = endTime.timeIntervalSince(startTime)
        self.totalExercises = totalExercises
        self.correctAnswers = correctAnswers
        self.exerciseAttempts = exerciseAttempts
        self.completionRate = exerciseAttempts.isEmpty ? 0 : Double(exerciseAttempts.count) / Double(totalExercises)
        self.averageTimePerExercise = exerciseAttempts.isEmpty ? 0 : duration / Double(exerciseAttempts.count)
    }
}

struct ExerciseAttempt: Identifiable, Codable {
    let id: UUID
    let exerciseId: UUID
    let exerciseType: String
    let prompt: String
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let timeSpent: TimeInterval
    let attemptNumber: Int // For tracking multiple attempts
    let vocabularyWord: String?
    
    init(exerciseId: UUID, exerciseType: String, prompt: String, userAnswer: String, correctAnswer: String, timeSpent: TimeInterval, attemptNumber: Int = 1, vocabularyWord: String? = nil) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.exerciseType = exerciseType
        self.prompt = prompt
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.isCorrect = userAnswer == correctAnswer
        self.timeSpent = timeSpent
        self.attemptNumber = attemptNumber
        self.vocabularyWord = vocabularyWord
    }
}

// MARK: - Analytics Manager

class LessonAnalyticsManager: ObservableObject {
    static let shared = LessonAnalyticsManager()
    
    @Published private(set) var lessonAttempts: [LessonAttempt] = []
    
    private let userDefaults = UserDefaults.standard
    private let analyticsKey = "lesson_analytics_data"
    
    private init() {
        loadAnalytics()
    }
    
    // MARK: - Public Methods
    
    func startLessonTracking(lessonId: UUID, lessonTitle: String) -> Date {
        return Date()
    }
    
    func recordLessonCompletion(
        lessonId: UUID,
        lessonTitle: String,
        startTime: Date,
        totalExercises: Int,
        correctAnswers: Int,
        exerciseAttempts: [ExerciseAttempt]
    ) {
        let attempt = LessonAttempt(
            lessonId: lessonId,
            lessonTitle: lessonTitle,
            startTime: startTime,
            endTime: Date(),
            totalExercises: totalExercises,
            correctAnswers: correctAnswers,
            exerciseAttempts: exerciseAttempts
        )
        
        lessonAttempts.append(attempt)
        saveAnalytics()
    }
    
    // MARK: - Analytics Queries
    
    func getAnalyticsForLesson(_ lessonId: UUID) -> [LessonAttempt] {
        return lessonAttempts.filter { $0.lessonId == lessonId }
    }
    
    func getBestScoreForLesson(_ lessonId: UUID) -> Int {
        return getAnalyticsForLesson(lessonId).map { $0.scorePercentage }.max() ?? 0
    }
    
    func getAverageScoreForLesson(_ lessonId: UUID) -> Double {
        let attempts = getAnalyticsForLesson(lessonId)
        guard !attempts.isEmpty else { return 0 }
        return attempts.map { $0.accuracy }.reduce(0, +) / Double(attempts.count)
    }
    
    func getTotalLessonsCompleted() -> Int {
        return Set(lessonAttempts.map { $0.lessonId }).count
    }
    
    func getTotalTimeSpentOnLessons() -> TimeInterval {
        return lessonAttempts.reduce(0) { $0 + $1.duration }
    }
    
    func getDifficultVocabulary() -> [(word: String, errorRate: Double)] {
        let exerciseAttempts = lessonAttempts.flatMap { $0.exerciseAttempts }
        let vocabularyAttempts = exerciseAttempts.compactMap { attempt -> (String, Bool)? in
            guard let word = attempt.vocabularyWord else { return nil }
            return (word, attempt.isCorrect)
        }
        
        let grouped = Dictionary(grouping: vocabularyAttempts, by: { $0.0 })
        return grouped.compactMap { word, attempts in
            let errorRate = Double(attempts.filter { !$0.1 }.count) / Double(attempts.count)
            return errorRate > 0 ? (word, errorRate) : nil
        }.sorted { $0.errorRate > $1.errorRate }
    }
    
    func getExerciseTypePerformance() -> [(type: String, accuracy: Double)] {
        let exerciseAttempts = lessonAttempts.flatMap { $0.exerciseAttempts }
        let grouped = Dictionary(grouping: exerciseAttempts, by: { $0.exerciseType })
        
        return grouped.map { type, attempts in
            let accuracy = Double(attempts.filter { $0.isCorrect }.count) / Double(attempts.count)
            return (type, accuracy)
        }.sorted { $0.accuracy < $1.accuracy }
    }
    
    // MARK: - Persistence
    
    private func saveAnalytics() {
        do {
            let data = try JSONEncoder().encode(lessonAttempts)
            userDefaults.set(data, forKey: analyticsKey)
        } catch {
            print("Failed to save lesson analytics: \(error)")
        }
    }
    
    private func loadAnalytics() {
        guard let data = userDefaults.data(forKey: analyticsKey) else { return }
        do {
            lessonAttempts = try JSONDecoder().decode([LessonAttempt].self, from: data)
        } catch {
            print("Failed to load lesson analytics: \(error)")
        }
    }
} 