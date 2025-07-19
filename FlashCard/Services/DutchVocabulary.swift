import Foundation

// MARK: - Dutch Vocabulary System
// This file contains JSON loading and database functionality
// Core types and DutchVocabularyDatabase are defined in FlashCard/Models/VocabularyTypes.swift

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
            let rootData = try decoder.decode(VocabularyRootJSON.self, from: data)
            allPacks = rootData.vocabularyPacks
            print("✅ Loaded \(allPacks.count) vocabulary packs from JSON")
            
            // Load the data into the database
            let vocabularyPacks = allPacks.map { jsonPack in
                DutchVocabularyPack(
                    name: jsonPack.name,
                    level: LanguageLevel(rawValue: jsonPack.level) ?? .a1,
                    category: VocabularyCategory(rawValue: jsonPack.category) ?? .family,
                    words: jsonPack.words.map { jsonWord in
                        DutchWord(
                            word: jsonWord.word,
                            article: jsonWord.article,
                            definition: jsonWord.definition,
                            example: jsonWord.example,
                            plural: jsonWord.plural,
                            pastTense: jsonWord.pastTense,
                            futureTense: jsonWord.futureTense,
                            pastParticiple: jsonWord.pastParticiple,
                            wordType: WordType(rawValue: jsonWord.wordType) ?? .noun,
                            level: LanguageLevel(rawValue: jsonWord.level) ?? .a1,
                            category: VocabularyCategory(rawValue: jsonWord.category) ?? .family
                        )
                    },
                    description: jsonPack.description
                )
            }
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