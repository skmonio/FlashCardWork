import Foundation

struct FlashCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var definition: String
    var example: String
    var deckIds: Set<UUID>  // Changed from single deckId to Set of deckIds
    var successCount: Int = 0
    var dateCreated: Date = Date()
    
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
} 