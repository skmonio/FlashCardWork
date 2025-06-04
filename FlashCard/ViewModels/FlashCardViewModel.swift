import Foundation

class FlashCardViewModel: ObservableObject {
    @Published var flashCards: [FlashCard] = [] {
        didSet {
            saveCards()
        }
    }
    
    @Published var decks: [Deck] = [] {
        didSet {
            saveDecks()
        }
    }
    
    private let userDefaultsKey = "SavedFlashCards"
    private let decksDefaultsKey = "SavedDecks"
    private var uncategorizedDeckId: UUID?
    
    init() {
        loadCards()
        loadDecks()
        
        // Create "Uncategorized" deck if it doesn't exist
        if !decks.contains(where: { $0.name == "Uncategorized" }) {
            let uncategorizedDeck = Deck(name: "Uncategorized")
            uncategorizedDeckId = uncategorizedDeck.id
            decks.append(uncategorizedDeck)
        } else {
            uncategorizedDeckId = decks.first(where: { $0.name == "Uncategorized" })?.id
        }
        
        // Update cards and decks
        updateCardDeckAssociations()
    }
    
    private func updateCardDeckAssociations() {
        // Clear all deck cards
        for index in decks.indices {
            decks[index].cards = []
        }
        
        // Reassign cards to appropriate decks
        for card in flashCards {
            if card.deckIds.isEmpty {
                // Add to uncategorized if no decks
                if let uncategorizedIndex = decks.firstIndex(where: { $0.name == "Uncategorized" }) {
                    decks[uncategorizedIndex].cards.append(card)
                }
            } else {
                // Add to all assigned decks
                for deckId in card.deckIds {
                    if let deckIndex = decks.firstIndex(where: { $0.id == deckId }) {
                        decks[deckIndex].cards.append(card)
                    }
                }
            }
        }
    }
    
    func addCard(word: String, definition: String, example: String, deckIds: Set<UUID>) {
        let newCard = FlashCard(word: word, definition: definition, example: example, deckIds: deckIds)
        flashCards.append(newCard)
        updateCardDeckAssociations()
    }
    
    func updateCard(_ card: FlashCard, word: String, definition: String, example: String, deckIds: Set<UUID>) {
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            // Update card
            flashCards[cardIndex].word = word
            flashCards[cardIndex].definition = definition
            flashCards[cardIndex].example = example
            flashCards[cardIndex].deckIds = deckIds
            
            updateCardDeckAssociations()
        }
    }
    
    func deleteCard(at indices: IndexSet) {
        flashCards.remove(atOffsets: indices)
        updateCardDeckAssociations()
    }
    
    func createDeck(name: String) -> Deck {
        let newDeck = Deck(name: name)
        decks.append(newDeck)
        return newDeck
    }
    
    func deleteDeck(_ deck: Deck) {
        if deck.name != "Uncategorized" {
            // Remove deck from all cards that reference it
            for index in flashCards.indices {
                flashCards[index].deckIds.remove(deck.id)
            }
            
            // Remove the deck
            decks.removeAll { $0.id == deck.id }
            
            // Update associations
            updateCardDeckAssociations()
        }
    }
    
    func getSelectableDecks() -> [Deck] {
        return decks.filter { $0.name != "Uncategorized" }
    }
    
    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(flashCards) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadCards() {
        if let savedCards = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedCards = try? JSONDecoder().decode([FlashCard].self, from: savedCards) {
            flashCards = decodedCards
        }
    }
    
    private func saveDecks() {
        if let encoded = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(encoded, forKey: decksDefaultsKey)
        }
    }
    
    private func loadDecks() {
        if let savedDecks = UserDefaults.standard.data(forKey: decksDefaultsKey),
           let decodedDecks = try? JSONDecoder().decode([Deck].self, from: savedDecks) {
            decks = decodedDecks
        }
    }
} 