import Foundation

struct FlashCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var definition: String
    var example: String
    var deckIds: Set<UUID>  // Changed from single deckId to Set of deckIds
    var successCount: Int = 0
    
    init(word: String = "", definition: String = "", example: String = "", deckIds: Set<UUID> = []) {
        self.word = word
        self.definition = definition
        self.example = example
        self.deckIds = deckIds
        self.successCount = 0
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        lhs.id == rhs.id
    }
} 