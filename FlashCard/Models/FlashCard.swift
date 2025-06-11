import Foundation

struct FlashCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var definition: String
    var example: String
    var deckIds: Set<UUID>  // Changed from single deckId to Set of deckIds
    var imageName: String?  // Optional image name for image-based cards
    
    // Learning statistics
    var attempts: Int = 0   // Number of times the card has been shown
    var successes: Int = 0  // Number of times the card was correctly answered
    
    // Dutch language features
    var article: String? = nil       // "het" or "de"
    var pastTense: String? = nil     // Past tense form
    var futureTense: String? = nil   // Future tense form
    
    var learningProgress: Double? {
        guard attempts > 0 else { return nil }  // Return nil for new cards
        return Double(successes) / Double(attempts) * 100.0
    }
    
    var isFullyLearned: Bool {
        guard let progress = learningProgress else { return false }
        return progress == 100.0 && attempts >= 3  // Consider fully learned if 100% after at least 3 attempts
    }
    
    init(word: String = "", definition: String = "", example: String = "", deckIds: Set<UUID> = [], imageName: String? = nil, article: String? = nil, pastTense: String? = nil, futureTense: String? = nil, cardId: UUID? = nil, dateCreated: Date? = nil) {
        if let cardId = cardId {
            self.id = cardId
        }
        self.word = word
        self.definition = definition
        self.example = example
        self.deckIds = deckIds
        self.imageName = imageName
        self.attempts = 0
        self.successes = 0
        self.article = article
        self.pastTense = pastTense
        self.futureTense = futureTense
        self.dateCreated = dateCreated ?? Date()
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        lhs.id == rhs.id
    }
    
    mutating func recordAttempt(wasSuccessful: Bool) {
        attempts += 1
        if wasSuccessful {
            successes += 1
        }
    }
    
    mutating func resetStatistics() {
        attempts = 0
        successes = 0
    }
} 