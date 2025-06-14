import Foundation

struct FlashCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var definition: String // Translation
    var example: String
    var deckIds: Set<UUID>
    var successCount: Int = 0
    var dateCreated: Date = Date()
    
    // Learning statistics
    var timesShown: Int = 0
    var timesCorrect: Int = 0
    
    // Additional grammatical fields
    var article: String = "" // "het" or "de" for nouns
    var plural: String = "" // Plural form for nouns
    var pastTense: String = "" // Past tense form
    var futureTense: String = "" // Future tense form
    var pastParticiple: String = "" // Past participle form
    
    // Computed property for learning percentage
    var learningPercentage: Int? {
        guard timesShown > 0 else { return nil }
        return Int((Double(timesCorrect) / Double(timesShown)) * 100)
    }
    
    // Check if card is fully learned (5+ correct answers)
    var isFullyLearned: Bool {
        return timesCorrect >= 5
    }
    
    init(word: String = "", definition: String = "", example: String = "", deckIds: Set<UUID> = [], article: String = "", plural: String = "", pastTense: String = "", futureTense: String = "", pastParticiple: String = "", cardId: UUID? = nil, dateCreated: Date? = nil) {
        if let cardId = cardId {
            self.id = cardId
        }
        self.word = word
        self.definition = definition
        self.example = example
        self.deckIds = deckIds
        self.article = article
        self.plural = plural
        self.pastTense = pastTense
        self.futureTense = futureTense
        self.pastParticiple = pastParticiple
        self.successCount = 0
        self.timesShown = 0
        self.timesCorrect = 0
        self.dateCreated = dateCreated ?? Date()
    }
    
    // Migration initializer to handle old cards
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        word = try container.decode(String.self, forKey: .word)
        definition = try container.decode(String.self, forKey: .definition)
        example = try container.decode(String.self, forKey: .example)
        deckIds = try container.decode(Set<UUID>.self, forKey: .deckIds)
        successCount = try container.decodeIfPresent(Int.self, forKey: .successCount) ?? 0
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated) ?? Date()
        timesShown = try container.decodeIfPresent(Int.self, forKey: .timesShown) ?? 0
        timesCorrect = try container.decodeIfPresent(Int.self, forKey: .timesCorrect) ?? 0
        
        // Handle new fields with defaults for backward compatibility
        article = try container.decodeIfPresent(String.self, forKey: .article) ?? ""
        plural = try container.decodeIfPresent(String.self, forKey: .plural) ?? ""
        pastTense = try container.decodeIfPresent(String.self, forKey: .pastTense) ?? ""
        futureTense = try container.decodeIfPresent(String.self, forKey: .futureTense) ?? ""
        pastParticiple = try container.decodeIfPresent(String.self, forKey: .pastParticiple) ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, word, definition, example, deckIds, successCount, dateCreated
        case timesShown, timesCorrect, article, plural, pastTense, futureTense, pastParticiple
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        lhs.id == rhs.id
    }
} 