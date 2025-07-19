import Foundation

// MARK: - Dutch Vocabulary Types
// This file contains the core vocabulary types that are used throughout the app
// IMPORTANT: This file should be compiled early in the build process to ensure
// LanguageLevel, VocabularyCategory, WordType, DutchVocabularyPack, and DutchWord
// are available to all other files that need them.

// MARK: - Enums

enum LanguageLevel: String, CaseIterable, Hashable {
    case a1 = "A1"
    case a2 = "A2" 
    case b1 = "B1"
    
    var description: String {
        switch self {
        case .a1: return "Beginner - Basic everyday words"
        case .a2: return "Elementary - Expanding vocabulary"
        case .b1: return "Intermediate - Complex concepts"
        }
    }
}

enum VocabularyCategory: String, CaseIterable, Hashable {
    case family = "family"
    case food = "food"
    case home = "home"
    case work = "work"
    case travel = "travel"
    case time = "time"
    case weather = "weather"
    case body = "body"
    case clothing = "clothing"
    case animals = "animals"
    case colors = "colors"
    case numbers = "numbers"
    case verbs = "verbs"
    case adjectives = "adjectives"
    case emotions = "emotions"
    case education = "education"
    case technology = "technology"
    case sports = "sports"
    case shopping = "shopping"
    case nature = "nature"
    case business = "business"
    case medical = "medical"
    case politics = "politics"
    case culture = "culture"
    case media = "media"
    case science = "science"
    case environment = "environment"
    case finance = "finance"
    case relationships = "relationships"
    case personality = "personality"
    case cooking = "cooking"
    case textiles = "textiles"
    case daily = "daily"
    case transportation = "transportation"
    case entertainment = "entertainment"
    case law = "law"
    case logistics = "logistics"
    case crime = "crime"
    case agriculture = "agriculture"
    case automotive = "automotive"
    case construction = "construction"
    case geography = "geography"
    case history = "history"
    case hospitality = "hospitality"
    case realEstate = "realEstate"
    case telecommunications = "telecommunications"
    case housing = "housing"
    case religion = "religion"
    case retail = "retail"
    case banking = "banking"
    case insurance = "insurance"
    case energy = "energy"
}

enum WordType: String, CaseIterable, Hashable {
    case noun = "noun"
    case verb = "verb"
    case adjective = "adjective"
    case adverb = "adverb"
    case preposition = "preposition"
    case conjunction = "conjunction"
    case pronoun = "pronoun"
    case interjection = "interjection"
}

// MARK: - Core Data Structures

struct DutchVocabularyPack: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let level: LanguageLevel
    let category: VocabularyCategory
    let words: [DutchWord]
    let description: String
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DutchVocabularyPack, rhs: DutchVocabularyPack) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Original initializer for backward compatibility
    init(name: String, level: LanguageLevel, category: VocabularyCategory, words: [DutchWord], description: String) {
        self.name = name
        self.level = level
        self.category = category
        self.words = words
        self.description = description
    }
}

struct DutchWord: Hashable {
    let word: String
    let article: String
    let definition: String
    let example: String
    let plural: String
    let pastTense: String
    let futureTense: String
    let pastParticiple: String
    let wordType: WordType
    let level: LanguageLevel
    let category: VocabularyCategory
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(definition)
    }
    
    static func == (lhs: DutchWord, rhs: DutchWord) -> Bool {
        return lhs.word == rhs.word && lhs.definition == rhs.definition
    }
    
    // Original initializer for backward compatibility
    init(word: String, article: String, definition: String, example: String, plural: String, pastTense: String, futureTense: String, pastParticiple: String, wordType: WordType, level: LanguageLevel, category: VocabularyCategory) {
        self.word = word
        self.article = article
        self.definition = definition
        self.example = example
        self.plural = plural
        self.pastTense = pastTense
        self.futureTense = futureTense
        self.pastParticiple = pastParticiple
        self.wordType = wordType
        self.level = level
        self.category = category
    }
    
    // Convert to FlashCard
    func toFlashCard() -> FlashCard {
        return FlashCard(
            word: word,
            definition: definition,
            example: example,
            deckIds: [],
            article: article,
            plural: plural,
            pastTense: pastTense,
            futureTense: futureTense,
            pastParticiple: pastParticiple
        )
    }
}

// MARK: - Database Compatibility Layer

class DutchVocabularyDatabase {
    static let shared = DutchVocabularyDatabase()
    private var _allPacks: [DutchVocabularyPack] = []
    private static var _isInitialized = false
    
    private init() {
        // Initialize with empty packs - will be loaded by DutchVocabulary.swift
        print("DutchVocabularyDatabase initialized")
    }
    
    // Static method to initialize vocabulary (called from other files)
    static func initializeVocabulary() {
        guard !_isInitialized else { return }
        _isInitialized = true
        
        // This will trigger the vocabulary loader to load data
        // We'll use a different approach to avoid circular dependencies
        print("🔄 Initializing vocabulary system...")
        
        // Load vocabulary data directly here
        loadVocabularyFromJSON()
    }
    
    private static func loadVocabularyFromJSON() {
        print("🔍 Starting vocabulary loading...")
        print("🔍 Bundle identifier: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("🔍 Bundle path: \(Bundle.main.bundlePath)")
        
        guard let url = Bundle.main.url(forResource: "dutch_vocabulary_complete", withExtension: "json") else {
            print("❌ Could not find dutch_vocabulary_complete.json in app bundle")
            print("🔍 Checking available bundle resources...")
            if let resourcePath = Bundle.main.resourcePath {
                do {
                    let contents = try FileManager.default.contentsOfDirectory(atPath: resourcePath)
                    let jsonFiles = contents.filter { $0.hasSuffix(".json") }
                    print("📁 Available JSON files in bundle: \(jsonFiles)")
                    
                    // Also check for any files that might contain "vocabulary" or "dutch"
                    let vocabularyFiles = contents.filter { $0.lowercased().contains("vocabulary") || $0.lowercased().contains("dutch") }
                    print("📁 Files containing 'vocabulary' or 'dutch': \(vocabularyFiles)")
                } catch {
                    print("❌ Error reading bundle contents: \(error)")
                }
            } else {
                print("❌ Could not get bundle resource path")
            }
            return
        }
        
        print("✅ Found JSON file at: \(url)")
        
        do {
            let data = try Data(contentsOf: url)
            print("✅ Read \(data.count) bytes from JSON file")
            
            let decoder = JSONDecoder()
            let rootData = try decoder.decode(VocabularyRootJSON.self, from: data)
            print("✅ Successfully decoded root JSON with \(rootData.vocabularyPacks.count) vocabulary packs")
            
            // Convert to DutchVocabularyPack objects
            let vocabularyPacks = rootData.vocabularyPacks.map { jsonPack in
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
            
            print("✅ Converted to \(vocabularyPacks.count) DutchVocabularyPack objects")
            shared.loadPacks(vocabularyPacks)
            
        } catch {
            print("❌ Error loading vocabulary JSON: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
            
            // Try to read the file as string to see what's in it
            do {
                let jsonString = try String(contentsOf: url)
                print("📄 First 500 characters of JSON file:")
                print(String(jsonString.prefix(500)))
            } catch {
                print("❌ Could not read JSON file as string: \(error)")
            }
        }
    }
    
    // MARK: - Original API Methods (Preserved for Compatibility)
    
    func getPacksByLevel(_ level: LanguageLevel) -> [DutchVocabularyPack] {
        return _allPacks.filter { $0.level == level }
    }
    
    func getPacksByCategory(_ category: VocabularyCategory) -> [DutchVocabularyPack] {
        return _allPacks.filter { $0.category == category }
    }
    
    func getAllPacks() -> [DutchVocabularyPack] {
        return _allPacks
    }
    
    // Property for backward compatibility
    var allPacks: [DutchVocabularyPack] {
        return _allPacks
    }
    
    func searchWords(query: String) -> [DutchWord] {
        return _allPacks.flatMap { $0.words }.filter { word in
            word.word.localizedCaseInsensitiveContains(query) ||
            word.definition.localizedCaseInsensitiveContains(query)
        }
    }
    
    // Method for getting words by level
    func getWordsForLevel(_ level: LanguageLevel) -> [DutchWord] {
        return _allPacks.filter { $0.level == level }.flatMap { $0.words }
    }
    
    // Method for getting all words (for TranslationService)
    func getAllWords() -> [DutchWord] {
        return _allPacks.flatMap { $0.words }
    }
    
    // Property for expanded packs (for TranslationService compatibility)
    static var expandedPacks: [DutchVocabularyPack] {
        return DutchVocabularyDatabase.shared.getAllPacks()
    }
    
    // MARK: - Original Lazy Var Compatibility (Major packs)
    
    var familyA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Familie") && $0.level == .a1 } ?? createEmptyPack("Familie (A1)", .a1, .family)
    }
    
    var foodA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Eten") && $0.level == .a1 } ?? createEmptyPack("Eten en Drinken (A1)", .a1, .food)
    }
    
    var homeA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Huis") && $0.level == .a1 } ?? createEmptyPack("Huis en Wonen (A1)", .a1, .home)
    }
    
    var colorsA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Kleuren") && $0.level == .a1 } ?? createEmptyPack("Kleuren (A1)", .a1, .colors)
    }
    
    var verbsA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Werkwoorden") && $0.level == .a1 } ?? createEmptyPack("Werkwoorden (A1)", .a1, .verbs)
    }
    
    var numbersA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Getallen") && $0.level == .a1 } ?? createEmptyPack("Getallen (A1)", .a1, .numbers)
    }
    
    var animalsA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Dieren") && $0.level == .a1 } ?? createEmptyPack("Dieren (A1)", .a1, .animals)
    }
    
    var clothingA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Kleding") && $0.level == .a1 } ?? createEmptyPack("Kleding (A1)", .a1, .clothing)
    }
    
    var bodyA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Lichaam") && $0.level == .a1 } ?? createEmptyPack("Lichaam (A1)", .a1, .body)
    }
    
    var adjectivesA1: DutchVocabularyPack {
        return _allPacks.first { $0.name.contains("Bijvoeglijke") && $0.level == .a1 } ?? createEmptyPack("Bijvoeglijke Naamwoorden (A1)", .a1, .adjectives)
    }
    
    // Add more lazy vars as needed...
    
    private func createEmptyPack(_ name: String, _ level: LanguageLevel, _ category: VocabularyCategory) -> DutchVocabularyPack {
        return DutchVocabularyPack(name: name, level: level, category: category, words: [], description: "Empty pack")
    }
    
    // Internal method to load packs (called by DutchVocabulary.swift)
    internal func loadPacks(_ packs: [DutchVocabularyPack]) {
        _allPacks = packs
        print("Loaded \(_allPacks.count) vocabulary packs into database")
        
        // Debug: Print some sample data
        if !_allPacks.isEmpty {
            let firstPack = _allPacks[0]
            print("📚 Sample pack: '\(firstPack.name)' with \(firstPack.words.count) words")
            if !firstPack.words.isEmpty {
                let firstWord = firstPack.words[0]
                print("📝 Sample word: '\(firstWord.word)' - \(firstWord.definition)")
            }
        }
    }
    
    // Debug method to check if data is loaded
    func debugVocabularyStatus() {
        print("🔍 Vocabulary Database Status:")
        print("   Total packs: \(_allPacks.count)")
        print("   Total words: \(getAllWords().count)")
        
        for level in LanguageLevel.allCases {
            let levelWords = getWordsForLevel(level)
            print("   \(level.rawValue) words: \(levelWords.count)")
        }
        
        if !_allPacks.isEmpty {
            print("   Sample packs:")
            for (index, pack) in _allPacks.prefix(3).enumerated() {
                print("     \(index + 1). \(pack.name) (\(pack.words.count) words)")
            }
        }
    }
}

// MARK: - Extension for Finding Packs

extension DutchVocabularyDatabase {
    func findPack(containing text: String, level: LanguageLevel? = nil) -> DutchVocabularyPack? {
        return _allPacks.first { pack in
            let nameMatch = pack.name.localizedCaseInsensitiveContains(text)
            let levelMatch = level == nil || pack.level == level
            return nameMatch && levelMatch
        }
    }
    
    func findPacks(containing text: String) -> [DutchVocabularyPack] {
        return _allPacks.filter { pack in
            pack.name.localizedCaseInsensitiveContains(text) ||
            pack.description.localizedCaseInsensitiveContains(text)
        }
    }
}

// MARK: - FlashCard Compatibility

// FlashCard type is already defined in FlashCard/Models/FlashCard.swift
// No need to define it here to avoid conflicts 

// MARK: - JSON Data Structures (for vocabulary loading)

struct VocabularyRootJSON: Codable {
    let metadata: VocabularyMetadataJSON
    let levels: [VocabularyLevelJSON]
    let categories: [VocabularyCategoryJSON]
    let vocabularyPacks: [VocabularyPackJSON]
}

struct VocabularyMetadataJSON: Codable {
    let version: String
    let lastUpdated: String
    let language: String
    let targetLanguage: String
}

struct VocabularyLevelJSON: Codable {
    let id: String
    let name: String
    let description: String
}

struct VocabularyCategoryJSON: Codable {
    let id: String
    let name: String
    let dutchName: String
}

struct VocabularyPackJSON: Codable {
    let name: String
    let id: String
    let level: String
    let category: String
    let description: String
    let words: [DutchWordJSON]
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