import Foundation

struct Deck: Identifiable, Codable {
    var id = UUID()
    var name: String
    var cards: [FlashCard]
    
    init(name: String, cards: [FlashCard] = []) {
        self.name = name
        self.cards = cards
    }
} 