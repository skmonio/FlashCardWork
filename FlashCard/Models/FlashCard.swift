import Foundation

// Enum for different verb forms
enum VerbForm: String, CaseIterable, Codable {
    case infinitive = "Infinitive"
    case present = "Present"
    case pastTense = "Past tense"
    case futureTense = "Future tense"
    case pastParticiple = "Past participle"
    
    var description: String {
        return self.rawValue
    }
    
    var placeholder: String {
        switch self {
        case .infinitive:
            return "e.g., eten"
        case .present:
            return "e.g., eet (ik/jij)"
        case .pastTense:
            return "e.g., at"
        case .futureTense:
            return "e.g., zal eten"
        case .pastParticiple:
            return "e.g., gegeten"
        }
    }
    
    var translationPlaceholder: String {
        switch self {
        case .infinitive:
            return "e.g., to eat"
        case .present:
            return "e.g., eat / eats"
        case .pastTense:
            return "e.g., ate"
        case .futureTense:
            return "e.g., will eat"
        case .pastParticiple:
            return "e.g., eaten"
        }
    }
    
    var examplePlaceholder: String {
        switch self {
        case .infinitive:
            return "e.g., Ik wil eten."
        case .present:
            return "e.g., Ik eet een appel."
        case .pastTense:
            return "e.g., Ik at een appel."
        case .futureTense:
            return "e.g., Ik zal eten om zes uur."
        case .pastParticiple:
            return "e.g., Ik heb een appel gegeten."
        }
    }
}

struct FlashCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String // Now represents the infinitive/stem form
    var definition: String // Translation
    var example: String
    var deckIds: Set<UUID>
    var successCount: Int = 0
    var dateCreated: Date = Date()
    
    // Learning statistics
    var timesShown: Int = 0
    var timesCorrect: Int = 0
    
    // New verb form structure
    var verbForm: VerbForm = .infinitive // Default to infinitive
    
    // Dutch language features (keeping article for nouns)
    var article: String? = nil // "het" or "de" for nouns
    
    // Computed property for learning percentage
    var learningPercentage: Int? {
        guard timesShown > 0 else { return nil }
        return Int((Double(timesCorrect) / Double(timesShown)) * 100)
    }
    
    // Check if card is fully learned (5+ correct answers)
    var isFullyLearned: Bool {
        return timesCorrect >= 5
    }
    
    init(word: String = "", definition: String = "", example: String = "", deckIds: Set<UUID> = [], verbForm: VerbForm = .infinitive, article: String? = nil, cardId: UUID? = nil, dateCreated: Date? = nil) {
        if let cardId = cardId {
            self.id = cardId
        }
        self.word = word
        self.definition = definition
        self.example = example
        self.deckIds = deckIds
        self.verbForm = verbForm
        self.successCount = 0
        self.timesShown = 0
        self.timesCorrect = 0
        self.article = article
        self.dateCreated = dateCreated ?? Date()
    }
    
    // Migration initializer to handle old cards with pastTense/futureTense
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
        article = try container.decodeIfPresent(String.self, forKey: .article)
        
        // Handle new verbForm field
        verbForm = try container.decodeIfPresent(VerbForm.self, forKey: .verbForm) ?? .infinitive
        
        // Handle migration from old pastTense/futureTense fields (ignore them)
        // These fields are no longer used but might exist in old data
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, word, definition, example, deckIds, successCount, dateCreated
        case timesShown, timesCorrect, article, verbForm
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        lhs.id == rhs.id
    }
} 