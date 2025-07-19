import Foundation

// MARK: - Dutch Vocabulary System
// This file contains JSON loading and database functionality
// Core types and DutchVocabularyDatabase are defined in FlashCard/Models/VocabularyTypes.swift

// MARK: - JSON Data Structures

struct VocabularyPackJSON: Codable {
    let name: String
    let level: String
    let category: String
    let words: [DutchWordJSON]
    let description: String
}

struct DutchWordJSON: Codable {
    let word: String
    let article: String
    let definition: String
    let example: String
    let plural: String
    let pastTense: String
    let futureTense: String
    let pastParticiple: String
    let wordType: String
    let level: String
    let category: String
}

// MARK: - JSON Loader

class VocabularyLoader {
    static let shared = VocabularyLoader()
    private var allPacks: [VocabularyPackJSON] = []
    
    private init() {
        loadVocabularyFromJSON()
    }
    
    private func loadVocabularyFromJSON() {
        guard let url = Bundle.main.url(forResource: "dutch_vocabulary_complete", withExtension: "json") else {
            print("❌ Could not find dutch_vocabulary_complete.json")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let vocabularyData = try decoder.decode([VocabularyPackJSON].self, from: data)
            allPacks = vocabularyData
            print("✅ Loaded \(allPacks.count) vocabulary packs from JSON")
            
            // Load the data into the database
            let vocabularyPacks = allPacks.map { DutchVocabularyPack(from: $0) }
            DutchVocabularyDatabase.shared.loadPacks(vocabularyPacks)
            
        } catch {
            print("❌ Error loading vocabulary JSON: \(error)")
        }
    }
    
    func getAllPacks() -> [VocabularyPackJSON] {
        return allPacks
    }
    
    func getPacksByLevel(_ level: LanguageLevel) -> [VocabularyPackJSON] {
        return allPacks.filter { $0.level == level.rawValue }
    }
    
    func getPacksByCategory(_ category: VocabularyCategory) -> [VocabularyPackJSON] {
        return allPacks.filter { $0.category == category.rawValue }
    }
    
    func searchPacks(query: String) -> [VocabularyPackJSON] {
        return allPacks.filter { pack in
            pack.name.localizedCaseInsensitiveContains(query) ||
            pack.description.localizedCaseInsensitiveContains(query) ||
            pack.words.contains { word in
                word.word.localizedCaseInsensitiveContains(query) ||
                word.definition.localizedCaseInsensitiveContains(query)
            }
        }
    }
}

// MARK: - Static Initialization
// This ensures the vocabulary loader is created when the app starts

extension VocabularyLoader {
    static func initializeVocabulary() {
        // This will trigger the shared instance creation and load the data
        _ = VocabularyLoader.shared
    }
}

// MARK: - Extensions for JSON Conversion

extension DutchVocabularyPack {
    // Create from JSON data
    init(from jsonPack: VocabularyPackJSON) {
        self.name = jsonPack.name
        self.level = LanguageLevel(rawValue: jsonPack.level) ?? .a1
        self.category = VocabularyCategory(rawValue: jsonPack.category) ?? .family
        self.words = jsonPack.words.map { DutchWord(from: $0) }
        self.description = jsonPack.description
    }
}

extension DutchWord {
    // Create from JSON data
    init(from jsonWord: DutchWordJSON) {
        self.word = jsonWord.word
        self.article = jsonWord.article
        self.definition = jsonWord.definition
        self.example = jsonWord.example
        self.plural = jsonWord.plural
        self.pastTense = jsonWord.pastTense
        self.futureTense = jsonWord.futureTense
        self.pastParticiple = jsonWord.pastParticiple
        self.wordType = WordType(rawValue: jsonWord.wordType) ?? .noun
        self.level = LanguageLevel(rawValue: jsonWord.level) ?? .a1
        self.category = VocabularyCategory(rawValue: jsonWord.category) ?? .family
    }
} 