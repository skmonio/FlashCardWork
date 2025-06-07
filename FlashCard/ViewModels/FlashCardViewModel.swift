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
    private let cardStatusKey = "CardStatus"
    private var uncategorizedDeckId: UUID?
    
    enum CardStatus: String, Codable {
        case unknown
        case known
    }
    
    private var cardStatus: [UUID: CardStatus] = [:] {
        didSet {
            saveCardStatus()
        }
    }
    
    init() {
        print("ViewModel init - Loading data")
        
        loadCards()
        loadDecks()
        loadCardStatus()
        
        // Create "Uncategorized" deck if it doesn't exist
        if !decks.contains(where: { $0.name == "Uncategorized" }) {
            let uncategorizedDeck = Deck(name: "Uncategorized")
            uncategorizedDeckId = uncategorizedDeck.id
            decks.append(uncategorizedDeck)
        } else {
            uncategorizedDeckId = decks.first(where: { $0.name == "Uncategorized" })?.id
        }
        
        // Add example Dutch cards if no cards exist
        if flashCards.isEmpty {
            createExampleDutchCards()
        }
        
        // Update cards and decks
        updateCardDeckAssociations()
    }
    
    private func createExampleDutchCards() {
        // Create decks
        let basicsDeck = createDeck(name: "A1 - Basics")
        let familyDeck = createDeck(name: "A1 - Family")
        let foodDeck = createDeck(name: "A1 - Food & Drinks")
        let numbersDeck = createDeck(name: "A1 - Numbers & Time")
        let dailyDeck = createDeck(name: "A2 - Daily Life")
        let weatherDeck = createDeck(name: "A2 - Weather")
        
        // Basic Greetings and Phrases (A1)
        addCard(
            word: "Hallo",
            definition: "Hello",
            example: "Hallo, hoe gaat het?",
            deckIds: [basicsDeck.id]
        )
        addCard(
            word: "Dank je wel",
            definition: "Thank you",
            example: "Dank je wel voor je hulp.",
            deckIds: [basicsDeck.id]
        )
        addCard(
            word: "Alsjeblieft",
            definition: "Please / Here you are",
            example: "Mag ik een kopje koffie, alsjeblieft?",
            deckIds: [basicsDeck.id]
        )
        
        // Family (A1)
        addCard(
            word: "Familie",
            definition: "Family",
            example: "Mijn familie woont in Amsterdam.",
            deckIds: [familyDeck.id]
        )
        addCard(
            word: "Ouders",
            definition: "Parents",
            example: "Mijn ouders komen uit Nederland.",
            deckIds: [familyDeck.id]
        )
        addCard(
            word: "Broer",
            definition: "Brother",
            example: "Ik heb één broer.",
            deckIds: [familyDeck.id]
        )
        
        // Food & Drinks (A1)
        addCard(
            word: "Brood",
            definition: "Bread",
            example: "Ik eet brood met kaas.",
            deckIds: [foodDeck.id]
        )
        addCard(
            word: "Koffie",
            definition: "Coffee",
            example: "Wil je een kopje koffie?",
            deckIds: [foodDeck.id]
        )
        addCard(
            word: "Water",
            definition: "Water",
            example: "Mag ik een glas water?",
            deckIds: [foodDeck.id]
        )
        
        // Numbers & Time (A1)
        addCard(
            word: "Een",
            definition: "One",
            example: "Ik heb een kat.",
            deckIds: [numbersDeck.id]
        )
        addCard(
            word: "Tijd",
            definition: "Time",
            example: "Hoe laat is het?",
            deckIds: [numbersDeck.id]
        )
        addCard(
            word: "Uur",
            definition: "Hour",
            example: "Het is twee uur.",
            deckIds: [numbersDeck.id]
        )
        
        // Daily Life (A2)
        addCard(
            word: "Werken",
            definition: "To work",
            example: "Ik werk in een kantoor.",
            deckIds: [dailyDeck.id]
        )
        addCard(
            word: "Boodschappen",
            definition: "Groceries",
            example: "Ik ga boodschappen doen.",
            deckIds: [dailyDeck.id]
        )
        addCard(
            word: "Afspraak",
            definition: "Appointment",
            example: "Ik heb een afspraak met de dokter.",
            deckIds: [dailyDeck.id]
        )
        
        // Weather (A2)
        addCard(
            word: "Weer",
            definition: "Weather",
            example: "Het weer is mooi vandaag.",
            deckIds: [weatherDeck.id]
        )
        addCard(
            word: "Regen",
            definition: "Rain",
            example: "Het regent vandaag.",
            deckIds: [weatherDeck.id]
        )
        addCard(
            word: "Zonnig",
            definition: "Sunny",
            example: "Het is zonnig buiten.",
            deckIds: [weatherDeck.id]
        )
    }
    
    func getCardStatus(cardId: UUID) -> CardStatus {
        return cardStatus[cardId] ?? .unknown
    }
    
    func setCardStatus(cardId: UUID, status: CardStatus) {
        cardStatus[cardId] = status
    }
    
    private func saveCardStatus() {
        if let encoded = try? JSONEncoder().encode(cardStatus) {
            UserDefaults.standard.set(encoded, forKey: cardStatusKey)
        }
    }
    
    private func loadCardStatus() {
        if let savedStatus = UserDefaults.standard.data(forKey: cardStatusKey),
           let decodedStatus = try? JSONDecoder().decode([UUID: CardStatus].self, from: savedStatus) {
            cardStatus = decodedStatus
        }
    }
    
    func updateCardDeckAssociations() {
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
    
    func addCard(word: String, definition: String, example: String, deckIds: Set<UUID>, article: String? = nil, pastTense: String? = nil, futureTense: String? = nil) {
        print("Adding new card")
        let newCard = FlashCard(
            word: word, 
            definition: definition, 
            example: example, 
            deckIds: deckIds,
            article: article,
            pastTense: pastTense,
            futureTense: futureTense
        )
        flashCards.append(newCard)
        updateCardDeckAssociations()
    }
    
    func updateCard(_ card: FlashCard, word: String, definition: String, example: String, deckIds: Set<UUID>, article: String? = nil, pastTense: String? = nil, futureTense: String? = nil) {
        if let index = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[index].word = word
            flashCards[index].definition = definition
            flashCards[index].example = example
            flashCards[index].deckIds = deckIds
            flashCards[index].article = article
            flashCards[index].pastTense = pastTense
            flashCards[index].futureTense = futureTense
            updateCardDeckAssociations()
        }
    }
    
    func deleteCard(at offsets: IndexSet) {
        // Remove the card from all decks first
        offsets.forEach { index in
            let cardToDelete = flashCards[index]
            decks = decks.map { deck in
                var updatedDeck = deck
                updatedDeck.cards.removeAll { $0.id == cardToDelete.id }
                return updatedDeck
            }
        }
        
        // Then remove from main cards array
        flashCards.remove(atOffsets: offsets)
        saveCards()
        saveDecks()
    }
    
    func removeCardFromDeck(card: FlashCard, deck: Deck) {
        // Remove the deck ID from the card's deckIds
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[cardIndex].deckIds.remove(deck.id)
        }
        
        // Remove the card from the specified deck
        decks = decks.map { currentDeck in
            if currentDeck.id == deck.id {
                var updatedDeck = currentDeck
                updatedDeck.cards.removeAll { $0.id == card.id }
                return updatedDeck
            }
            return currentDeck
        }
        
        // Update associations to ensure card goes to Uncategorized if needed
        updateCardDeckAssociations()
        saveCards()
        saveDecks()
    }
    
    func createDeck(name: String) -> Deck {
        print("Creating new deck: \(name)")
        let newDeck = Deck(name: name)
        decks.append(newDeck)
        return newDeck
    }
    
    func createSubDeck(name: String, parentId: UUID) -> Deck {
        print("Creating new sub-deck: \(name) under parent: \(parentId)")
        let newSubDeck = Deck(name: name, parentId: parentId)
        decks.append(newSubDeck)
        
        // Update parent deck to include this sub-deck
        if let parentIndex = decks.firstIndex(where: { $0.id == parentId }) {
            decks[parentIndex].subDeckIds.insert(newSubDeck.id)
        }
        
        return newSubDeck
    }
    
    func getTopLevelDecks() -> [Deck] {
        return decks.filter { $0.parentId == nil }
    }
    
    func getSubDecks(for parentId: UUID) -> [Deck] {
        return decks.filter { $0.parentId == parentId }
    }
    
    func getAllDecksHierarchical() -> [Deck] {
        // Returns all decks organized hierarchically (parents first, then their children)
        var result: [Deck] = []
        let topLevel = getTopLevelDecks().sorted { $0.name < $1.name }
        
        for deck in topLevel {
            result.append(deck)
            let subDecks = getSubDecks(for: deck.id).sorted { $0.name < $1.name }
            result.append(contentsOf: subDecks)
        }
        
        return result
    }
    
    func deleteDeck(_ deck: Deck) {
        print("Deleting deck: \(deck.name)")
        if deck.name != "Uncategorized" {
            // If this is a parent deck, delete all its sub-decks first
            if !deck.subDeckIds.isEmpty {
                let subDecks = decks.filter { deck.subDeckIds.contains($0.id) }
                for subDeck in subDecks {
                    deleteDeck(subDeck)
                }
            }
            
            // If this is a sub-deck, remove it from parent's subDeckIds
            if let parentId = deck.parentId,
               let parentIndex = decks.firstIndex(where: { $0.id == parentId }) {
                decks[parentIndex].subDeckIds.remove(deck.id)
            }
            
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
        return getAllDecksHierarchical().filter { $0.name != "Uncategorized" }
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
        
        // Check if there's any data at all
        if let savedCards = UserDefaults.standard.data(forKey: userDefaultsKey) {
            print("Found saved data: \(savedCards.count) bytes")
            
            // Try to see what the raw data looks like
            if let jsonString = String(data: savedCards, encoding: .utf8) {
                print("Raw saved data: \(jsonString.prefix(500))...")
            }
            
            // First try to decode with new format (Set<UUID> for deckIds)
            do {
                let decodedCards = try JSONDecoder().decode([FlashCard].self, from: savedCards)
            flashCards = decodedCards
                print("✅ Successfully loaded \(flashCards.count) cards with new format")
                return
            } catch {
                print("❌ Failed to decode with new format: \(error)")
            }
            
            // If that fails, try to decode with old format (single deckId)
            do {
                let oldCards = try JSONDecoder().decode([OldFlashCard].self, from: savedCards)
                print("✅ Found \(oldCards.count) cards in old format, migrating...")
                
                // Convert old format to new format
                flashCards = oldCards.map { oldCard in
                    var newCard = FlashCard(
                        word: oldCard.word,
                        definition: oldCard.definition,
                        example: oldCard.example,
                        deckIds: oldCard.deckId.map { Set([$0]) } ?? []
                    )
                    newCard.id = oldCard.id
                    newCard.successCount = oldCard.successCount
                    return newCard
                }
                
                print("✅ Successfully migrated \(flashCards.count) cards to new format")
                
                // Save in new format immediately
                saveCards()
                return
            } catch {
                print("❌ Failed to decode with old format: \(error)")
            }
            
            // Try very old format without deckId
            do {
                let veryOldCards = try JSONDecoder().decode([VeryOldFlashCard].self, from: savedCards)
                print("✅ Found \(veryOldCards.count) cards in very old format, migrating...")
                
                // Convert very old format to new format
                flashCards = veryOldCards.map { veryOldCard in
                    var newCard = FlashCard(
                        word: veryOldCard.word,
                        definition: veryOldCard.definition,
                        example: veryOldCard.example,
                        deckIds: []  // No deck associations in very old format
                    )
                    newCard.id = veryOldCard.id
                    newCard.successCount = veryOldCard.successCount ?? 0
                    return newCard
                }
                
                print("✅ Successfully migrated \(flashCards.count) cards from very old format")
                
                // Save in new format immediately
                saveCards()
                return
            } catch {
                print("❌ Failed to decode with very old format: \(error)")
            }
            
            // Try simple format without successCount or deckId
            do {
                let simpleCards = try JSONDecoder().decode([SimpleFlashCard].self, from: savedCards)
                print("✅ Found \(simpleCards.count) cards in simple format, migrating...")
                
                // Convert simple format to new format
                flashCards = simpleCards.map { simpleCard in
                    var newCard = FlashCard(
                        word: simpleCard.word,
                        definition: simpleCard.definition,
                        example: simpleCard.example,
                        deckIds: []  // No deck associations in simple format
                    )
                    newCard.id = simpleCard.id
                    newCard.successCount = 0
                    return newCard
                }
                
                print("✅ Successfully migrated \(flashCards.count) cards from simple format")
                
                // Save in new format immediately
                saveCards()
                return
            } catch {
                print("❌ Failed to decode with simple format: \(error)")
            }
            
            // If both fail, try to see if there are any other possible formats
            print("❌ Failed to decode data in any known format")
            
        } else {
            print("❌ No saved data found in UserDefaults for key: \(userDefaultsKey)")
        }
        
        // Also check for any other possible keys that might have been used
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let cardKeys = allKeys.filter { $0.lowercased().contains("card") || $0.lowercased().contains("flash") }
        if !cardKeys.isEmpty {
            print("Found other potential card-related keys: \(cardKeys)")
            
            // Try loading from alternative keys
            for key in cardKeys {
                if key != userDefaultsKey, let altData = UserDefaults.standard.data(forKey: key) {
                    print("Trying to load from alternative key: \(key)")
                    
                    // Try the same migration process with this alternative data
                    if let jsonString = String(data: altData, encoding: .utf8) {
                        print("Alternative data: \(jsonString.prefix(200))...")
                    }
                    
                    // Try simple format first (most likely to work)
                    if let simpleCards = try? JSONDecoder().decode([SimpleFlashCard].self, from: altData) {
                        print("✅ Found \(simpleCards.count) cards under key '\(key)' in simple format!")
                        
                        flashCards = simpleCards.map { simpleCard in
                            var newCard = FlashCard(
                                word: simpleCard.word,
                                definition: simpleCard.definition,
                                example: simpleCard.example,
                                deckIds: []
                            )
                            newCard.id = simpleCard.id
                            newCard.successCount = 0
                            return newCard
                        }
                        
                        saveCards() // Save under correct key
                        return
                    }
                    
                    // Try very old format
                    if let veryOldCards = try? JSONDecoder().decode([VeryOldFlashCard].self, from: altData) {
                        print("✅ Found \(veryOldCards.count) cards under key '\(key)' in very old format!")
                        
                        flashCards = veryOldCards.map { veryOldCard in
                            var newCard = FlashCard(
                                word: veryOldCard.word,
                                definition: veryOldCard.definition,
                                example: veryOldCard.example,
                                deckIds: []
                            )
                            newCard.id = veryOldCard.id
                            newCard.successCount = veryOldCard.successCount ?? 0
                            return newCard
                        }
                        
                        saveCards() // Save under correct key
                        return
                    }
                    
                    // Try old format with deckId
                    if let oldCards = try? JSONDecoder().decode([OldFlashCard].self, from: altData) {
                        print("✅ Found \(oldCards.count) cards under key '\(key)' in old format!")
                        
                        flashCards = oldCards.map { oldCard in
                            var newCard = FlashCard(
                                word: oldCard.word,
                                definition: oldCard.definition,
                                example: oldCard.example,
                                deckIds: oldCard.deckId.map { Set([$0]) } ?? []
                            )
                            newCard.id = oldCard.id
                            newCard.successCount = oldCard.successCount
                            return newCard
                        }
                        
                        saveCards() // Save under correct key
                        return
                    }
                }
            }
        }
        
        print("No saved cards found or error decoding")
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

// Add this struct for migration purposes at the end of the file
private struct OldFlashCard: Codable {
    var id: UUID
    var word: String
    var definition: String
    var example: String
    var deckId: UUID?  // Old single deckId format
    var successCount: Int
}

// Try even older format without deckId
private struct VeryOldFlashCard: Codable {
    var id: UUID
    var word: String
    var definition: String
    var example: String
    var successCount: Int?
}

// Try format without successCount
private struct SimpleFlashCard: Codable {
    var id: UUID
    var word: String
    var definition: String
    var example: String
} 