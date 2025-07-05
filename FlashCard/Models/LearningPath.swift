import Foundation
import SwiftUI

// MARK: - Learning Path Models
struct LearningPath: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    var chapters: [LearningChapter]
    let totalLessons: Int
    let completedLessons: Int
    
    init(title: String, description: String, chapters: [LearningChapter]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.chapters = chapters
        self.totalLessons = chapters.reduce(0) { $0 + $1.lessons.count }
        self.completedLessons = chapters.reduce(0) { $0 + $1.lessons.filter { $0.isCompleted }.count }
    }
    
    var progressPercentage: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }
}

struct LearningChapter: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    var lessons: [LearningLesson]
    let chapterNumber: Int
    
    init(title: String, description: String, lessons: [LearningLesson], chapterNumber: Int) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.lessons = lessons
        self.chapterNumber = chapterNumber
    }
    
    var isCompleted: Bool {
        lessons.allSatisfy { $0.isCompleted }
    }
    
    var progressPercentage: Double {
        guard !lessons.isEmpty else { return 0 }
        let completedCount = lessons.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(lessons.count)
    }
}

struct LearningLesson: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let lessonId: UUID // Reference to the actual lesson
    let lessonNumber: Int
    var isCompleted: Bool
    var isLocked: Bool
    let requiredLessonIds: [UUID] // Lessons that must be completed first
    let estimatedTime: Int // in minutes
    let difficulty: LessonDifficulty
    let rewards: [LessonReward]
    
    init(title: String, description: String, lessonId: UUID, lessonNumber: Int, requiredLessonIds: [UUID] = [], estimatedTime: Int = 5, difficulty: LessonDifficulty = .beginner, rewards: [LessonReward] = [], isLocked: Bool = false) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.lessonId = lessonId
        self.lessonNumber = lessonNumber
        self.isCompleted = false
        self.isLocked = isLocked
        self.requiredLessonIds = requiredLessonIds
        self.estimatedTime = estimatedTime
        self.difficulty = difficulty
        self.rewards = rewards
    }
    
    mutating func updateStatus(isCompleted: Bool, isLocked: Bool) {
        self.isCompleted = isCompleted
        self.isLocked = isLocked
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LearningLesson, rhs: LearningLesson) -> Bool {
        lhs.id == rhs.id
    }
}

enum LessonDifficulty: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"
    
    var color: Color {
        switch self {
        case .beginner: return .green
        case .intermediate: return .orange
        case .advanced: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .beginner: return "1.circle.fill"
        case .intermediate: return "2.circle.fill"
        case .advanced: return "3.circle.fill"
        }
    }
}

struct LessonReward: Identifiable, Codable {
    let id: UUID
    let type: RewardType
    let value: Int
    let description: String
    
    init(type: RewardType, value: Int, description: String) {
        self.id = UUID()
        self.type = type
        self.value = value
        self.description = description
    }
}

enum RewardType: String, Codable {
    case experience = "experience"
    case streak = "streak"
    case vocabulary = "vocabulary"
    case achievement = "achievement"
    
    var icon: String {
        switch self {
        case .experience: return "star.fill"
        case .streak: return "flame.fill"
        case .vocabulary: return "book.fill"
        case .achievement: return "trophy.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .experience: return .yellow
        case .streak: return .orange
        case .vocabulary: return .blue
        case .achievement: return .purple
        }
    }
}

// MARK: - Learning Path Manager
class LearningPathManager: ObservableObject {
    static let shared = LearningPathManager()
    
    @Published var currentPath: LearningPath?
    @Published var userProgress: [UUID: Bool] = [:] // lessonId: isCompleted
    
    private init() {
        loadUserProgress()
        createSamplePath()
    }
    
    private func loadUserProgress() {
        if let data = UserDefaults.standard.data(forKey: "learningPathProgress"),
           let progress = try? JSONDecoder().decode([UUID: Bool].self, from: data) {
            userProgress = progress
        }
    }
    
    private func saveUserProgress() {
        if let data = try? JSONEncoder().encode(userProgress) {
            UserDefaults.standard.set(data, forKey: "learningPathProgress")
        }
    }
    
    func markLessonCompleted(_ lessonId: UUID) {
        userProgress[lessonId] = true
        saveUserProgress()
        updatePathCompletionStatus()
    }
    
    func isLessonCompleted(_ lessonId: UUID) -> Bool {
        return userProgress[lessonId] ?? false
    }
    
    func isLessonLocked(_ lesson: LearningLesson) -> Bool {
        // Check if all required lessons are completed
        for requiredId in lesson.requiredLessonIds {
            if !isLessonCompleted(requiredId) {
                return true
            }
        }
        return false
    }
    
    private func updatePathCompletionStatus() {
        // Update the completion status of lessons based on user progress
        guard var path = currentPath else { return }
        
        for chapterIndex in path.chapters.indices {
            for lessonIndex in path.chapters[chapterIndex].lessons.indices {
                let lesson = path.chapters[chapterIndex].lessons[lessonIndex]
                let isCompleted = isLessonCompleted(lesson.lessonId)
                let isLocked = isLessonLocked(lesson)
                
                path.chapters[chapterIndex].lessons[lessonIndex].updateStatus(
                    isCompleted: isCompleted,
                    isLocked: isLocked
                )
            }
        }
        
        currentPath = path
    }
    
    private func createSamplePath() {
        // Get the existing Chapter 3.5 lesson
        let chapter35Lesson = LessonManager.shared.lessons.first!
        
        // Create Chapter 3 learning path with all sub-chapters
        let chapter3Lessons = [
            // Chapter 3.1 - Basic Communication (Locked)
            LearningLesson(
                title: "Chapter 3.1: Basic Communication",
                description: "Learn fundamental communication skills and essential vocabulary",
                lessonId: UUID(), // Placeholder for future lesson
                lessonNumber: 1,
                estimatedTime: 8,
                difficulty: .beginner,
                rewards: [
                    LessonReward(type: .experience, value: 50, description: "50 XP"),
                    LessonReward(type: .achievement, value: 1, description: "Basic Communication Achievement")
                ],
                isLocked: true // Locked until previous lessons are completed
            ),
            // Chapter 3.2 - Daily Conversations (Locked)
            LearningLesson(
                title: "Chapter 3.2: Daily Conversations",
                description: "Master everyday conversations and social interactions",
                lessonId: UUID(), // Placeholder for future lesson
                lessonNumber: 2,
                estimatedTime: 10,
                difficulty: .beginner,
                rewards: [
                    LessonReward(type: .experience, value: 75, description: "75 XP"),
                    LessonReward(type: .achievement, value: 1, description: "Daily Conversations Achievement")
                ],
                isLocked: true // Locked until previous lessons are completed
            ),
            // Chapter 3.3 - Shopping and Services (Locked)
            LearningLesson(
                title: "Chapter 3.3: Shopping and Services",
                description: "Navigate shopping experiences and service interactions",
                lessonId: UUID(), // Placeholder for future lesson
                lessonNumber: 3,
                estimatedTime: 12,
                difficulty: .intermediate,
                rewards: [
                    LessonReward(type: .experience, value: 100, description: "100 XP"),
                    LessonReward(type: .achievement, value: 1, description: "Shopping and Services Achievement")
                ],
                isLocked: true // Locked until previous lessons are completed
            ),
            // Chapter 3.4 - Travel and Transportation (Locked)
            LearningLesson(
                title: "Chapter 3.4: Travel and Transportation",
                description: "Learn travel vocabulary and transportation systems",
                lessonId: UUID(), // Placeholder for future lesson
                lessonNumber: 4,
                estimatedTime: 15,
                difficulty: .intermediate,
                rewards: [
                    LessonReward(type: .experience, value: 125, description: "125 XP"),
                    LessonReward(type: .achievement, value: 1, description: "Travel and Transportation Achievement")
                ],
                isLocked: true // Locked until previous lessons are completed
            ),
            // Chapter 3.5 - Dutch Vocabulary in Context (Unlocked - has content)
            LearningLesson(
                title: "Chapter 3.5: Dutch Vocabulary in Context",
                description: "Apply vocabulary in real-world contexts and scenarios",
                lessonId: chapter35Lesson.id, // Use the actual lesson ID
                lessonNumber: 5,
                estimatedTime: 18,
                difficulty: .intermediate,
                rewards: [
                    LessonReward(type: .experience, value: 150, description: "150 XP"),
                    LessonReward(type: .achievement, value: 1, description: "Dutch Vocabulary in Context Achievement")
                ],
                isLocked: false // Unlocked since we have content
            ),
            // Chapter 3.6 - Advanced Communication (Locked)
            LearningLesson(
                title: "Chapter 3.6: Advanced Communication",
                description: "Master complex conversations and professional Dutch",
                lessonId: UUID(), // Placeholder for future lesson
                lessonNumber: 6,
                estimatedTime: 20,
                difficulty: .advanced,
                rewards: [
                    LessonReward(type: .experience, value: 200, description: "200 XP"),
                    LessonReward(type: .achievement, value: 1, description: "Advanced Communication Achievement")
                ],
                isLocked: true // Locked until previous lessons are completed
            )
        ]
        
        let chapter = LearningChapter(
            title: "Communication Mastery",
            description: "Master Dutch communication from basic to advanced levels",
            lessons: chapter3Lessons,
            chapterNumber: 3
        )
        
        let path = LearningPath(
            title: "Chapter 3: Communication Mastery",
            description: "A comprehensive journey through Dutch communication skills",
            chapters: [chapter]
        )
        
        currentPath = path
    }
} 