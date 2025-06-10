import Foundation

struct FlashCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var definition: String
    var example: String
    var deckIds: Set<UUID>  // Changed from single deckId to Set of deckIds
    var successCount: Int = 0
    var dateCreated: Date = Date()
    
    // Statistics for learning percentage
    var timesShown: Int = 0      // Total times card has been shown in any game
    var timesCorrect: Int = 0    // Total times answered correctly
    
    // Dutch language features
    var article: String? = nil       // "het" or "de"
    var pastTense: String? = nil     // Past tense form
    var futureTense: String? = nil   // Future tense form
    
    init(word: String = "", definition: String = "", example: String = "", deckIds: Set<UUID> = [], article: String? = nil, pastTense: String? = nil, futureTense: String? = nil, cardId: UUID? = nil, dateCreated: Date? = nil) {
        if let cardId = cardId {
            self.id = cardId
        }
        self.word = word
        self.definition = definition
        self.example = example
        self.deckIds = deckIds
        self.successCount = 0
        self.timesShown = 0
        self.timesCorrect = 0
        self.article = article
        self.pastTense = pastTense
        self.futureTense = futureTense
        self.dateCreated = dateCreated ?? Date()
    }
    
    // Computed property for learning percentage
    var learningPercentage: Double? {
        guard timesShown > 0 else { return nil } // Don't show % if word is new
        return (Double(timesCorrect) / Double(timesShown)) * 100.0
    }
    
    // Helper property to check if card is fully learned (100% with at least 5 attempts)
    var isFullyLearned: Bool {
        guard let percentage = learningPercentage else { return false }
        return percentage >= 100.0 && timesShown >= 5
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        lhs.id == rhs.id
    }
} 