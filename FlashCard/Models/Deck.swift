import Foundation

struct Deck: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var cards: [FlashCard]
    var parentId: UUID? = nil       // Parent deck ID for sub-decks
    var subDeckIds: Set<UUID> = []  // Child deck IDs
    var isEditable: Bool = true     // Whether deck can be edited or deleted (false for system decks)
    
    init(name: String, cards: [FlashCard] = [], parentId: UUID? = nil, isEditable: Bool = true) {
        self.name = name
        self.cards = cards
        self.parentId = parentId
        self.subDeckIds = []
        self.isEditable = isEditable
    }
    
    // Helper computed properties
    var isSubDeck: Bool {
        return parentId != nil
    }
    
    var displayName: String {
        return name
    }
    
    // Check if this is a system deck (not editable)
    var isSystemDeck: Bool {
        return !isEditable
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Deck, rhs: Deck) -> Bool {
        lhs.id == rhs.id
    }
} 