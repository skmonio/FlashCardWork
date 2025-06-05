import Foundation

class FlashCardViewModel: ObservableObject {
    @Published var flashCards: [FlashCard] = [] {
        didSet {
            print("FlashCards changed: \(flashCards.count) cards")
            saveCards()
        }
    }
    
    @Published var decks: [Deck] = [] {
        didSet {
            print("Decks changed: \(decks.count) decks")
            saveDecks()
        }
    }
    
    private let userDefaultsKey = "SavedFlashCards"
    private let decksDefaultsKey = "SavedDecks"
    private var uncategorizedDeckId: UUID?
    
    init() {
        print("ViewModel init - Loading data")
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
        print("Updating card-deck associations")
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
        
        // Save decks after updating associations
        saveDecks()
    }
    
    func addCard(word: String, definition: String, example: String, deckIds: Set<UUID>) {
        print("Adding new card")
        let newCard = FlashCard(word: word, definition: definition, example: example, deckIds: deckIds)
        flashCards.append(newCard)
        updateCardDeckAssociations()
    }
    
    func updateCard(_ card: FlashCard, word: String, definition: String, example: String, deckIds: Set<UUID>) {
        print("Updating card: \(card.id)")
        print("Before update - flashCards count: \(flashCards.count)")
        
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            print("Found card at index: \(cardIndex)")
            
            // Create updated card
            var updatedCard = card
            updatedCard.word = word
            updatedCard.definition = definition
            updatedCard.example = example
            updatedCard.deckIds = deckIds
            
            // Update in flashCards array
            flashCards[cardIndex] = updatedCard
            
            print("Card updated - New word: \(updatedCard.word)")
            
            // Force a save of the cards
            saveCards()
            
            // Update deck associations
            updateCardDeckAssociations()
            
            // Force UserDefaults to synchronize
            UserDefaults.standard.synchronize()
            
            print("After update - flashCards count: \(flashCards.count)")
        } else {
            print("Error: Card not found in flashCards array")
        }
    }
    
    func deleteCard(at indices: IndexSet) {
        print("Deleting card(s) at indices: \(indices)")
        flashCards.remove(atOffsets: indices)
        updateCardDeckAssociations()
    }
    
    func createDeck(name: String) -> Deck {
        print("Creating new deck: \(name)")
        let newDeck = Deck(name: name)
        decks.append(newDeck)
        return newDeck
    }
    
    func deleteDeck(_ deck: Deck) {
        print("Deleting deck: \(deck.name)")
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
        print("Saving cards to UserDefaults")
        if let encoded = try? JSONEncoder().encode(flashCards) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            print("Cards saved successfully")
        } else {
            print("Error: Failed to encode cards")
        }
    }
    
    private func loadCards() {
        print("Loading cards from UserDefaults")
        if let savedCards = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedCards = try? JSONDecoder().decode([FlashCard].self, from: savedCards) {
            flashCards = decodedCards
            print("Loaded \(flashCards.count) cards")
        } else {
            print("No saved cards found or error decoding")
        }
    }
    
    private func saveDecks() {
        print("Saving decks to UserDefaults")
        if let encoded = try? JSONEncoder().encode(decks) {
            UserDefaults.standard.set(encoded, forKey: decksDefaultsKey)
            print("Decks saved successfully")
        } else {
            print("Error: Failed to encode decks")
        }
    }
    
    private func loadDecks() {
        print("Loading decks from UserDefaults")
        if let savedDecks = UserDefaults.standard.data(forKey: decksDefaultsKey),
           let decodedDecks = try? JSONDecoder().decode([Deck].self, from: savedDecks) {
            decks = decodedDecks
            print("Loaded \(decks.count) decks")
        } else {
            print("No saved decks found or error decoding")
        }
    }
} 