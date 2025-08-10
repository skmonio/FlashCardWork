import Foundation
import SwiftUI

@MainActor
class DutchWordExerciseManager: ObservableObject {
    static let shared = DutchWordExerciseManager()
    
    @Published var wordExercises: [DutchWordExercise] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userDefaults = UserDefaults.standard
    private let wordExercisesKey = "dutchWordExercises"
    
    private init() {
        loadWordExercises()
        loadExampleExercises()
    }
    
    // MARK: - Data Management
    
    func loadWordExercises() {
        guard let data = userDefaults.data(forKey: wordExercisesKey),
              let exercises = try? JSONDecoder().decode([DutchWordExercise].self, from: data) else {
            return
        }
        wordExercises = exercises
    }
    
    func saveWordExercises() {
        guard let data = try? JSONEncoder().encode(wordExercises) else {
            errorMessage = "Failed to save word exercises"
            return
        }
        userDefaults.set(data, forKey: wordExercisesKey)
    }
    
    func addWordExercise(_ exercise: DutchWordExercise) {
        wordExercises.append(exercise)
        saveWordExercises()
    }
    
    func updateWordExercise(_ exercise: DutchWordExercise) {
        if let index = wordExercises.firstIndex(where: { $0.id == exercise.id }) {
            var updatedExercise = exercise
            updatedExercise = DutchWordExercise(
                targetWord: exercise.targetWord,
                wordTranslation: exercise.wordTranslation,
                exercises: exercise.exercises,
                difficulty: exercise.difficulty,
                category: exercise.category,
                isUserCreated: exercise.isUserCreated,
                sourceFile: exercise.sourceFile
            )
            wordExercises[index] = updatedExercise
            saveWordExercises()
        }
    }
    
    func deleteWordExercise(_ exercise: DutchWordExercise) {
        wordExercises.removeAll { $0.id == exercise.id }
        saveWordExercises()
    }
    
    func deleteWordExercise(at indexSet: IndexSet) {
        wordExercises.remove(atOffsets: indexSet)
        saveWordExercises()
    }
    
    // MARK: - Search and Filter
    
    func searchWordExercises(query: String) -> [DutchWordExercise] {
        guard !query.isEmpty else { return wordExercises }
        
        return wordExercises.filter { exercise in
            exercise.targetWord.localizedCaseInsensitiveContains(query) ||
            exercise.wordTranslation.localizedCaseInsensitiveContains(query) ||
            exercise.category.rawValue.localizedCaseInsensitiveContains(query)
        }
    }
    
    func filterWordExercises(by category: WordCategory?) -> [DutchWordExercise] {
        guard let category = category else { return wordExercises }
        return wordExercises.filter { $0.category == category }
    }
    
    func filterWordExercises(by difficulty: ExerciseDifficulty?) -> [DutchWordExercise] {
        guard let difficulty = difficulty else { return wordExercises }
        return wordExercises.filter { $0.difficulty == difficulty }
    }
    
    func getWordExercise(for word: String) -> DutchWordExercise? {
        return wordExercises.first { $0.targetWord.lowercased() == word.lowercased() }
    }
    
    // MARK: - Import/Export
    
    func importWordExercises(from url: URL) async throws {
        isLoading = true
        defer { isLoading = false }
        
        let data = try Data(contentsOf: url)
        
        if url.pathExtension.lowercased() == "json" {
            try await importFromJSON(data)
        } else if url.pathExtension.lowercased() == "xlsx" || url.pathExtension.lowercased() == "xls" {
            try await importFromExcel(data)
        } else {
            throw ImportError.unsupportedFormat
        }
    }
    
    private func importFromJSON(_ data: Data) async throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            let importData = try decoder.decode(DutchWordExerciseImport.self, from: data)
            let newExercises = importData.exercises.map { exercise in
                DutchWordExercise(
                    targetWord: exercise.targetWord,
                    wordTranslation: exercise.wordTranslation,
                    exercises: exercise.exercises,
                    difficulty: exercise.difficulty,
                    category: exercise.category,
                    isUserCreated: false,
                    sourceFile: importData.metadata.source
                )
            }
            
            // Add new exercises, avoiding duplicates
            for newExercise in newExercises {
                if !wordExercises.contains(where: { $0.targetWord.lowercased() == newExercise.targetWord.lowercased() }) {
                    wordExercises.append(newExercise)
                }
            }
            
            saveWordExercises()
        } catch {
            throw ImportError.invalidJSON
        }
    }
    
    private func importFromExcel(_ data: Data) async throws {
        // Basic Excel import - in a real implementation, you'd use a library like CoreXLSX
        // For now, we'll throw an error indicating this needs to be implemented
        throw ImportError.excelNotImplemented
    }
    
    func exportWordExercises(to url: URL) async throws -> Data {
        isLoading = true
        defer { isLoading = false }
        
        let exportData = DutchWordExerciseImport(
            exercises: wordExercises,
            metadata: ImportMetadata(
                source: "Taal Trek App",
                version: "1.0",
                importedAt: Date(),
                totalExercises: wordExercises.count,
                categories: Array(Set(wordExercises.map { $0.category.rawValue }))
            )
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(exportData)
        try data.write(to: url)
        return data
    }
    
    // MARK: - Example Data
    
    private func loadExampleExercises() {
        // Only load examples if no exercises exist
        guard wordExercises.isEmpty else { return }
        
        let exampleWords = [
            ("terecht", "justified"),
            ("eigenlijk", "actually"),
            ("nogal", "quite"),
            ("zomaar", "out of the blue"),
            ("geschikt", "suitable")
        ]
        
        for (word, translation) in exampleWords {
            let exercise = DutchWordExercise.exampleForWord(word, translation: translation)
            wordExercises.append(exercise)
        }
        
        saveWordExercises()
    }
    
    // MARK: - Statistics
    
    func getStatistics() -> WordExerciseStatistics {
        let totalExercises = wordExercises.count
        let totalQuestions = wordExercises.reduce(0) { $0 + $1.exercises.count }
        let userCreated = wordExercises.filter { $0.isUserCreated }.count
        let imported = wordExercises.filter { !$0.isUserCreated }.count
        
        let categoryBreakdown = Dictionary(grouping: wordExercises, by: { $0.category })
            .mapValues { $0.count }
        
        let difficultyBreakdown = Dictionary(grouping: wordExercises, by: { $0.difficulty })
            .mapValues { $0.count }
        
        return WordExerciseStatistics(
            totalWordExercises: totalExercises,
            totalQuestions: totalQuestions,
            userCreated: userCreated,
            imported: imported,
            categoryBreakdown: categoryBreakdown,
            difficultyBreakdown: difficultyBreakdown
        )
    }
}

// MARK: - Supporting Types

struct WordExerciseStatistics {
    let totalWordExercises: Int
    let totalQuestions: Int
    let userCreated: Int
    let imported: Int
    let categoryBreakdown: [WordCategory: Int]
    let difficultyBreakdown: [ExerciseDifficulty: Int]
}

enum ImportError: LocalizedError {
    case unsupportedFormat
    case invalidJSON
    case excelNotImplemented
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .unsupportedFormat:
            return "Unsupported file format. Please use JSON or Excel files."
        case .invalidJSON:
            return "Invalid JSON format. Please check your file."
        case .excelNotImplemented:
            return "Excel import is not yet implemented. Please use JSON format."
        case .fileNotFound:
            return "File not found. Please check the file path."
        }
    }
} 