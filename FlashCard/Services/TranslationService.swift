import Foundation
import os

/// Service for handling translations with fallback to local dictionary
class TranslationService: ObservableObject {
    static let shared = TranslationService()
    
    private let logger = Logger(subsystem: "com.flashcards", category: "TranslationService")
    
    private init() {
        // Initialize without TranslationSession for compatibility
        // Translation framework integration is handled in CompatibilityHelper
    }
    
    /// Get translation with fallback to dictionary lookup
    func getTranslationWithFallback(for word: String) async -> String {
        // For now, use local dictionary as primary source
        // In the future, this can be enhanced with Apple's Translation framework
        if let dictionaryTranslation = getDictionaryTranslation(for: word) {
            return dictionaryTranslation
        }
        
        // Return empty string instead of "translation needed"
        return ""
    }
    
    /// Batch translate multiple words
    func translateWords(_ words: [String]) async -> [String: String] {
        var translations: [String: String] = [:]
        
        for word in words {
            let translation = await getTranslationWithFallback(for: word)
            if translation != "translation needed" {
                translations[word] = translation
            }
        }
        
        return translations
    }
    
    /// Local dictionary for common Dutch words
    private func getDictionaryTranslation(for word: String) -> String? {
        let localDictionary: [String: String] = [
            // Common nouns
            "huis": "house",
            "kat": "cat",
            "hond": "dog",
            "auto": "car",
            "boek": "book",
            "tafel": "table",
            "stoel": "chair",
            "water": "water",
            "brood": "bread",
            "melk": "milk",
            "koffie": "coffee",
            "thee": "tea",
            "appel": "apple",
            "banaan": "banana",
            "kaas": "cheese",
            "vlees": "meat",
            "vis": "fish",
            "rijst": "rice",
            "aardappel": "potato",
            "groente": "vegetable",
            "fruit": "fruit",
            "school": "school",
            "werk": "work",
            "familie": "family",
            "vriend": "friend",
            "stad": "city",
            "land": "country",
            "wereld": "world",
            
            // Common verbs
            "eten": "to eat",
            "drinken": "to drink",
            "slapen": "to sleep",
            "werken": "to work",
            "lopen": "to walk",
            "rennen": "to run",
            "spreken": "to speak",
            "luisteren": "to listen",
            "kijken": "to look",
            "lezen": "to read",
            "schrijven": "to write",
            "denken": "to think",
            "voelen": "to feel",
            "houden": "to hold",
            "geven": "to give",
            "nemen": "to take",
            "komen": "to come",
            "gaan": "to go",
            "zijn": "to be",
            "hebben": "to have",
            "doen": "to do",
            "maken": "to make",
            "zien": "to see",
            "horen": "to hear",
            "weten": "to know",
            "kunnen": "can/to be able to",
            "willen": "to want",
            "moeten": "must/to have to",
            
            // Common adjectives
            "groot": "big",
            "klein": "small",
            "goed": "good",
            "slecht": "bad",
            "mooi": "beautiful",
            "lelijk": "ugly",
            "oud": "old",
            "nieuw": "new",
            "warm": "warm",
            "koud": "cold",
            "snel": "fast",
            "langzaam": "slow",
            "hoog": "high",
            "laag": "low",
            "zwaar": "heavy",
            "licht": "light",
            "donker": "dark",
            "wit": "white",
            "zwart": "black",
            "rood": "red",
            "blauw": "blue",
            "groen": "green",
            "geel": "yellow",
            
            // Common words
            "ja": "yes",
            "nee": "no",
            "hallo": "hello",
            "dag": "day/goodbye",
            "dank": "thank",
            "alsjeblieft": "please",
            "sorry": "sorry",
            "hier": "here",
            "daar": "there",
            "nu": "now",
            "later": "later",
            "vandaag": "today",
            "gisteren": "yesterday",
            "morgen": "tomorrow",
            "tijd": "time",
            "uur": "hour",
            "minuut": "minute",
            "week": "week",
            "maand": "month",
            "jaar": "year",
            
            // Numbers
            "een": "one/a/an",
            "twee": "two",
            "drie": "three",
            "vier": "four",
            "vijf": "five",
            "zes": "six",
            "zeven": "seven",
            "acht": "eight",
            "negen": "nine",
            "tien": "ten",
            
            // Articles and pronouns
            "de": "the",
            "het": "the",
            "ik": "I",
            "jij": "you",
            "hij": "he",
            "zij": "she/they",
            "wij": "we",
            "jullie": "you (plural)",
            "mij": "me",
            "jou": "you",
            "hem": "him",
            "haar": "her",
            "ons": "us",
            "hun": "them"
        ]
        
        return localDictionary[word.lowercased()]
    }
    
    /// Enhanced translation that provides context and grammar information
    func getEnhancedTranslation(for word: String) async -> EnhancedTranslation {
        let translation = await getTranslationWithFallback(for: word)
        let wordType = determineWordType(word)
        let grammarInfo = getGrammarInfo(for: word, type: wordType)
        
        return EnhancedTranslation(
            originalWord: word,
            translation: translation,
            wordType: wordType,
            grammarInfo: grammarInfo,
            confidence: translation.isEmpty ? 0.0 : 0.85
        )
    }
    
    private func determineWordType(_ word: String) -> DutchWordType {
        let verbEndings = ["en", "eren", "elen"]
        let nounIndicators = ["heid", "ing", "schap", "er", "aar"]
        
        // Check for verb endings
        for ending in verbEndings {
            if word.lowercased().hasSuffix(ending) {
                return .verb
            }
        }
        
        // Check for noun indicators
        for indicator in nounIndicators {
            if word.lowercased().contains(indicator) {
                return .noun
            }
        }
        
        // Check if it starts with capital (likely noun)
        if word.first?.isUppercase == true {
            return .noun
        }
        
        return .unknown
    }
    
    private func getGrammarInfo(for word: String, type: DutchWordType) -> GrammarInfo? {
        switch type {
        case .noun:
            return GrammarInfo(
                article: guessArticle(for: word),
                plural: guessPluralForm(for: word),
                additionalInfo: "Dutch nouns use 'de' or 'het' as articles"
            )
        case .verb:
            return GrammarInfo(
                conjugationPattern: guessConjugationPattern(for: word),
                additionalInfo: "Dutch verbs typically end in -en"
            )
        case .adjective:
            return GrammarInfo(
                additionalInfo: "Dutch adjectives may change form when used before nouns"
            )
        case .adverb:
            return GrammarInfo(
                additionalInfo: "Dutch adverbs often end in -lijk or are the same as adjectives"
            )
        case .pronoun:
            return GrammarInfo(
                additionalInfo: "Dutch pronouns change form based on their grammatical function"
            )
        case .preposition:
            return GrammarInfo(
                additionalInfo: "Dutch prepositions often combine with articles (e.g., van + de = van de)"
            )
        case .conjunction:
            return GrammarInfo(
                additionalInfo: "Dutch conjunctions connect words, phrases, or clauses"
            )
        case .unknown:
            return nil
        }
    }
    
    private func guessArticle(for word: String) -> String? {
        // Simple heuristics for Dutch articles
        let deWords = ["heid", "ing", "schap", "er", "aar", "en"]
        let hetWords = ["isme", "ment", "um"]
        
        for ending in hetWords {
            if word.lowercased().hasSuffix(ending) {
                return "het"
            }
        }
        
        for ending in deWords {
            if word.lowercased().hasSuffix(ending) {
                return "de"
            }
        }
        
        // Default to 'de' as it's more common
        return "de"
    }
    
    private func guessPluralForm(for word: String) -> String? {
        let lowerWord = word.lowercased()
        
        if lowerWord.hasSuffix("e") {
            return word + "n"
        } else if lowerWord.hasSuffix("el") || lowerWord.hasSuffix("er") || lowerWord.hasSuffix("en") {
            return word + "s"
        } else {
            return word + "en"
        }
    }
    
    private func guessConjugationPattern(for word: String) -> String? {
        if word.lowercased().hasSuffix("en") {
            let stem = String(word.dropLast(2))
            return "ik \(stem), jij \(stem)t, hij/zij \(stem)t"
        }
        return nil
    }
}

// MARK: - Supporting Types

struct EnhancedTranslation {
    let originalWord: String
    let translation: String
    let wordType: DutchWordType
    let grammarInfo: GrammarInfo?
    let confidence: Float
}

enum DutchWordType {
    case noun
    case verb
    case adjective
    case adverb
    case pronoun
    case preposition
    case conjunction
    case unknown
    
    var displayName: String {
        switch self {
        case .noun: return "Noun"
        case .verb: return "Verb"
        case .adjective: return "Adjective"
        case .adverb: return "Adverb"
        case .pronoun: return "Pronoun"
        case .preposition: return "Preposition"
        case .conjunction: return "Conjunction"
        case .unknown: return "Unknown"
        }
    }
}

struct GrammarInfo {
    let article: String?
    let plural: String?
    let conjugationPattern: String?
    let additionalInfo: String?
    
    init(article: String? = nil, plural: String? = nil, conjugationPattern: String? = nil, additionalInfo: String? = nil) {
        self.article = article
        self.plural = plural
        self.conjugationPattern = conjugationPattern
        self.additionalInfo = additionalInfo
    }
}

// MARK: - Array Extension

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
} 