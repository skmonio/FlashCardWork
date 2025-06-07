import Foundation

struct Deck: Identifiable, Codable {
    var id = UUID()
    var name: String
    var cards: [FlashCard]
    var parentId: UUID? = nil       // Parent deck ID for sub-decks
    var subDeckIds: Set<UUID> = []  // Child deck IDs
    
    init(name: String, cards: [FlashCard] = [], parentId: UUID? = nil) {
        self.name = name
        self.cards = cards
        self.parentId = parentId
        self.subDeckIds = []
    }
    
    // Helper computed properties
    var isSubDeck: Bool {
        return parentId != nil
    }
    
    var displayName: String {
        return name
    }
} 