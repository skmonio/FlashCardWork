import Foundation

// MARK: - JSON Data Models for Lessons

struct LessonRootJSON: Codable {
    let metadata: LessonMetadataJSON
    let levels: [LessonLevelJSON]
    let categories: [LessonCategoryJSON]
    let lessons: [LessonJSON]
}

struct LessonMetadataJSON: Codable {
    let version: String
    let lastUpdated: String
    let totalLessons: Int
    let description: String
}

struct LessonLevelJSON: Codable {
    let id: String
    let name: String
    let description: String
    let estimatedTime: Int
}

struct LessonCategoryJSON: Codable {
    let id: String
    let name: String
    let dutchName: String
    let description: String
}

struct LessonJSON: Codable {
    let id: String
    let title: String
    let description: String
    let level: String
    let category: String
    let estimatedTime: Int
    let difficulty: String
    let prerequisites: [String]
    let vocabulary: [LessonVocabularyItemJSON]
    let exercises: [LessonExerciseJSON]
    let rewards: [LessonRewardJSON]
}

struct LessonVocabularyItemJSON: Codable {
    let dutchWord: String
    let translation: String
    let article: String
    let example: String
    let wordType: String
    let vocabularyReference: String?
}

struct LessonExerciseJSON: Codable {
    let id: String
    let type: String
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
    let vocabularyReference: String?
    let grammarReference: String?
}

struct LessonRewardJSON: Codable, Hashable, Equatable {
    let type: String
    let value: Int
    let description: String
}

// MARK: - Conversion Extensions

extension LessonJSON {
    func toLesson() -> Lesson {
        return Lesson(
            id: UUID(),
            title: self.title,
            description: self.description,
            vocabulary: self.vocabulary.map { $0.toVocabularyItem() },
            exercises: self.exercises.map { $0.toExercise() }
        )
    }
}

extension LessonVocabularyItemJSON {
    func toVocabularyItem() -> VocabularyItem {
        return VocabularyItem(
            dutchWord: self.dutchWord,
            translation: self.translation,
            vocabularyReference: self.vocabularyReference
        )
    }
}

extension LessonExerciseJSON {
    func toExercise() -> Exercise {
        let exerciseType: Exercise.ExerciseType
        switch self.type {
        case "fillInBlank":
            exerciseType = .fillInBlank
        case "missingWord":
            exerciseType = .missingWord
        case "matchMeaning":
            exerciseType = .matchMeaning
        case "useInSentence":
            exerciseType = .useInSentence
        case "sentenceBuilding":
            exerciseType = .sentenceBuilding
        default:
            exerciseType = .fillInBlank
        }
        
        return Exercise(
            type: exerciseType,
            prompt: self.prompt,
            options: self.options,
            correctAnswer: self.correctAnswer,
            explanation: self.explanation,
            vocabularyReference: self.vocabularyReference
        )
    }
} 