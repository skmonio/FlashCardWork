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
    
    // Navigation state
    @Published var shouldNavigateToRoot = false
    @Published var navigationPath: [String] = []
    
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
        
        // Reset navigation state first
        shouldNavigateToRoot = false
        navigationPath = []
        
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
        
        // Create system decks if they don't exist
        if !decks.contains(where: { $0.name == "📖 Learning" }) {
            let learningDeck = Deck(name: "📖 Learning", isEditable: false)
            decks.append(learningDeck)
            print("Created 'Learning' system deck")
        }
        
        if !decks.contains(where: { $0.name == "📚 Learnt" }) {
            let learntDeck = Deck(name: "📚 Learnt", isEditable: false)
            decks.append(learntDeck)
            print("Created 'Learnt' system deck")
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
    
    func navigateToRoot() {
        shouldNavigateToRoot = true
    }
    
    func resetNavigationToRoot() {
        shouldNavigateToRoot = false
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
        
        // Get uncategorized deck ID
        let uncategorizedDeckId = decks.first(where: { $0.name == "Uncategorized" })?.id
        
        // Reassign cards to appropriate decks
        for cardIndex in flashCards.indices {
            let card = flashCards[cardIndex]
            
            if card.deckIds.isEmpty {
                // Add to uncategorized if no decks and set the uncategorized deck ID
                if let uncategorizedId = uncategorizedDeckId {
                    flashCards[cardIndex].deckIds.insert(uncategorizedId)
                    print("Card '\(card.word)' assigned to Uncategorized deck")
                }
                if let uncategorizedIndex = decks.firstIndex(where: { $0.name == "Uncategorized" }) {
                    decks[uncategorizedIndex].cards.append(flashCards[cardIndex])
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
    
    func addCard(word: String, definition: String, example: String, deckIds: Set<UUID>, article: String? = nil, pastTense: String? = nil, futureTense: String? = nil, cardId: UUID? = nil) -> FlashCard {
        print("Adding new card")
        
        var finalDeckIds = deckIds
        
        // If no decks specified, assign to Uncategorized
        if finalDeckIds.isEmpty {
            if let uncategorizedDeck = decks.first(where: { $0.name == "Uncategorized" }) {
                finalDeckIds.insert(uncategorizedDeck.id)
                print("Card '\(word)' assigned to Uncategorized deck")
            }
        }
        
        let newCard = FlashCard(
            word: word, 
            definition: definition, 
            example: example, 
            deckIds: finalDeckIds,
            article: article,
            pastTense: pastTense,
            futureTense: futureTense,
            cardId: cardId
        )
        flashCards.append(newCard)
        updateCardDeckAssociations()
        return newCard
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
        if deck.name != "Uncategorized" && deck.isEditable {
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
        } else {
            print("Cannot delete system deck: \(deck.name)")
        }
    }
    
    func renameDeck(_ deck: Deck, newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty && trimmedName != deck.name else { return }
        
        // Check if name already exists
        if decks.contains(where: { $0.name == trimmedName && $0.id != deck.id }) {
            return // Name already exists
        }
        
        // Update the deck name
        if let index = decks.firstIndex(where: { $0.id == deck.id }) {
            decks[index].name = trimmedName
            saveDecks()
        }
    }
    
    func getSelectableDecks() -> [Deck] {
        return getAllDecksHierarchical().filter { 
            $0.name != "Uncategorized" && 
            $0.name != "📖 Learning" && 
            $0.name != "📚 Learnt" && 
            $0.isEditable 
        }
    }
    
    // MARK: - Export Functionality
    
    func exportCardsToCSV() -> String {
        let headers = ["Word", "Definition", "Example", "Article", "Past Tense", "Future Tense", "Decks", "Success Count"]
        var csvContent = headers.joined(separator: ",") + "\n"
        
        for card in flashCards {
            let deckNames = getDeckNamesForCard(card).joined(separator: "; ")
            
            let row = [
                escapeCSVField(card.word),
                escapeCSVField(card.definition),
                escapeCSVField(card.example),
                escapeCSVField(card.article ?? ""),
                escapeCSVField(card.pastTense ?? ""),
                escapeCSVField(card.futureTense ?? ""),
                escapeCSVField(deckNames),
                String(card.successCount)
            ]
            
            csvContent += row.joined(separator: ",") + "\n"
        }
        
        return csvContent
    }
    
    func exportDeckToCSV(_ deck: Deck) -> String {
        let headers = ["Word", "Definition", "Example", "Article", "Past Tense", "Future Tense", "Success Count"]
        var csvContent = headers.joined(separator: ",") + "\n"
        
        for card in deck.cards {
            let row = [
                escapeCSVField(card.word),
                escapeCSVField(card.definition),
                escapeCSVField(card.example),
                escapeCSVField(card.article ?? ""),
                escapeCSVField(card.pastTense ?? ""),
                escapeCSVField(card.futureTense ?? ""),
                String(card.successCount)
            ]
            
            csvContent += row.joined(separator: ",") + "\n"
        }
        
        return csvContent
    }
    
    private func getDeckNamesForCard(_ card: FlashCard) -> [String] {
        var deckNames: [String] = []
        
        for deckId in card.deckIds {
            if let deck = decks.first(where: { $0.id == deckId }) {
                deckNames.append(deck.name)
            }
        }
        
        // If no decks found, add to uncategorized
        if deckNames.isEmpty {
            deckNames.append("Uncategorized")
        }
        
        return deckNames.sorted()
    }
    
    private func escapeCSVField(_ field: String) -> String {
        // Escape commas, quotes, and newlines in CSV fields
        let escapedField = field.replacingOccurrences(of: "\"", with: "\"\"")
        
        if field.contains(",") || field.contains("\"") || field.contains("\n") {
            return "\"\(escapedField)\""
        }
        
        return escapedField
    }
    
    // MARK: - Import Functionality
    
    func importCardsFromCSV(_ csvContent: String) -> (success: Int, errors: [String]) {
        let lines = csvContent.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        guard lines.count > 1 else {
            return (0, ["CSV file appears to be empty or invalid"])
        }
        
        var successCount = 0
        var errors: [String] = []
        
        // Skip header row
        for (index, line) in lines.dropFirst().enumerated() {
            let lineNumber = index + 2 // +2 because we dropped first and want 1-based indexing
            
            let fields = parseCSVLine(line)
            
            // Validate minimum required fields
            guard fields.count >= 2, 
                  !fields[0].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !fields[1].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                errors.append("Line \(lineNumber): Missing required word or definition")
                continue
            }
            
            let word = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let definition = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let example = fields.count > 2 ? fields[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let article = fields.count > 3 ? (fields[3].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : fields[3].trimmingCharacters(in: .whitespacesAndNewlines)) : nil
            let pastTense = fields.count > 4 ? (fields[4].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : fields[4].trimmingCharacters(in: .whitespacesAndNewlines)) : nil
            let futureTense = fields.count > 5 ? (fields[5].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : fields[5].trimmingCharacters(in: .whitespacesAndNewlines)) : nil
            
            // Handle deck names (if provided)
            var deckIds: Set<UUID> = []
            if fields.count > 6 && !fields[6].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let deckNamesString = fields[6].trimmingCharacters(in: .whitespacesAndNewlines)
                let deckNames = deckNamesString.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                
                for deckName in deckNames {
                    if let existingDeck = decks.first(where: { $0.name == deckName }) {
                        deckIds.insert(existingDeck.id)
                    } else if deckName != "Uncategorized" {
                        // Create new deck if it doesn't exist
                        let newDeck = createDeck(name: deckName)
                        deckIds.insert(newDeck.id)
                    }
                }
            }
            
            // Create the card
            let _ = addCard(
                word: word,
                definition: definition,
                example: example,
                deckIds: deckIds,
                article: article,
                pastTense: pastTense,
                futureTense: futureTense
            )
            
            successCount += 1
        }
        
        return (successCount, errors)
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                if insideQuotes && i < line.index(before: line.endIndex) && line[line.index(after: i)] == "\"" {
                    // Escaped quote
                    currentField += "\""
                    i = line.index(after: i) // Skip next quote
                } else {
                    // Toggle quote state
                    insideQuotes.toggle()
                }
            } else if char == "," && !insideQuotes {
                // Field separator
                fields.append(currentField)
                currentField = ""
            } else {
                currentField += String(char)
            }
            
            i = line.index(after: i)
        }
        
        // Add final field
        fields.append(currentField)
        
        return fields
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
        if let savedDecks = UserDefaults.standard.data(forKey: decksDefaultsKey) {
            // Try to decode with new format first
            do {
                let decodedDecks = try JSONDecoder().decode([Deck].self, from: savedDecks)
                decks = decodedDecks
                print("✅ Successfully loaded \(decks.count) decks with new format")
                return
            } catch {
                print("❌ Failed to decode with new format: \(error)")
            }
            
            // Try to decode with old format (without parentId and subDeckIds)
            do {
                let oldDecks = try JSONDecoder().decode([OldDeck].self, from: savedDecks)
                print("✅ Found \(oldDecks.count) decks in old format, migrating...")
                
                // Convert old format to new format
                decks = oldDecks.map { oldDeck in
                    var newDeck = Deck(name: oldDeck.name, cards: oldDeck.cards, parentId: nil)
                    newDeck.id = oldDeck.id
                    return newDeck
                }
                
                print("✅ Successfully migrated \(decks.count) decks to new format")
                
                // Save in new format immediately
                saveDecks()
                return
            } catch {
                print("❌ Failed to decode with old format: \(error)")
            }
        }
        
        print("No saved decks found or error decoding")
    }
    
    // MARK: - Statistics Tracking
    
    /// Records that a card was shown to the user
    func recordCardShown(_ cardId: UUID) {
        if let index = flashCards.firstIndex(where: { $0.id == cardId }) {
            flashCards[index].timesShown += 1
            print("Card '\(flashCards[index].word)' shown. Times shown: \(flashCards[index].timesShown)")
            saveCards()
        }
    }
    
    /// Records that a card was answered correctly
    func recordCardCorrect(_ cardId: UUID) {
        if let index = flashCards.firstIndex(where: { $0.id == cardId }) {
            flashCards[index].timesCorrect += 1
            flashCards[index].successCount += 1 // Keep existing success count for backward compatibility
            
            let card = flashCards[index]
            print("Card '\(card.word)' answered correctly. Times correct: \(card.timesCorrect)/\(card.timesShown)")
            
            // Check if card should move to Learnt deck (80% accuracy with 5+ attempts)
            if card.isFullyLearned {
                print("Card '\(card.word)' is fully learned (80%+ accuracy)! Moving to 'Learnt' deck.")
                moveCardToLearntDeck(card)
            } else if let percentage = card.learningPercentage {
                print("Card '\(card.word)' learning percentage: \(String(format: "%.1f", percentage))%")
                updateCardInLearningDeck(card)
            }
            
            saveCards()
        }
    }
    
    /// Records that a card was answered incorrectly
    func recordCardIncorrect(_ cardId: UUID) {
        if let index = flashCards.firstIndex(where: { $0.id == cardId }) {
            // timesShown is already incremented when card is shown
            // timesCorrect stays the same since this was incorrect
            
            let card = flashCards[index]
            
            // Check if card should move back to Learning deck
            if let percentage = card.learningPercentage {
                print("Card '\(card.word)' answered incorrectly. Learning percentage: \(String(format: "%.1f", percentage))%")
                
                // If card was in Learnt deck or accuracy dropped below 70%, move back to Learning
                let learntDeck = getLearntDeck()
                let wasInLearntDeck = card.deckIds.contains(learntDeck.id)
                
                if wasInLearntDeck || percentage < 70.0 {
                    print("Card '\(card.word)' moving back to Learning deck (accuracy below 70% or was answered wrong in Learnt)")
                    moveCardBackToLearningDeck(card)
                } else {
                    updateCardInLearningDeck(card)
                }
            } else {
                // First time shown, add to Learning deck
                updateCardInLearningDeck(card)
            }
            
            saveCards()
        }
    }
    
    /// Gets or creates the "Learnt" deck for cards at 100%
    private func getLearntDeck() -> Deck {
        if let existingDeck = decks.first(where: { $0.name == "📚 Learnt" }) {
            return existingDeck
        }
        
        let learntDeck = Deck(name: "📚 Learnt", isEditable: false)
        decks.append(learntDeck)
        print("Created 'Learnt' deck for fully learned cards")
        return learntDeck
    }
    
    /// Gets or creates the "Learning" deck for cards in progress
    private func getLearningDeck() -> Deck {
        if let existingDeck = decks.first(where: { $0.name == "📖 Learning" }) {
            return existingDeck
        }
        
        let learningDeck = Deck(name: "📖 Learning", isEditable: false)
        decks.append(learningDeck)
        print("Created 'Learning' deck for cards in progress")
        return learningDeck
    }
    
    /// Copies a fully learned card to the "Learnt" deck (keeps in original decks)
    private func moveCardToLearntDeck(_ card: FlashCard) {
        let learntDeck = getLearntDeck()
        
        // Add card to learnt deck if not already there
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[cardIndex].deckIds.insert(learntDeck.id)
        }
        
        // Remove from learning deck if present (but keep in original decks)
        let learningDeck = getLearningDeck()
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[cardIndex].deckIds.remove(learningDeck.id)
        }
        
        updateCardDeckAssociations()
    }
    
    /// Copies a card back to the "Learning" deck (keeps in original decks)
    private func moveCardBackToLearningDeck(_ card: FlashCard) {
        let learningDeck = getLearningDeck()
        let learntDeck = getLearntDeck()
        
        // Add card to learning deck if not already there
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[cardIndex].deckIds.insert(learningDeck.id)
        }
        
        // Remove from learnt deck if present (but keep in original decks)
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[cardIndex].deckIds.remove(learntDeck.id)
        }
        
        updateCardDeckAssociations()
    }
    
    /// Copies a card to the "Learning" deck (for cards that have been shown but aren't 80% yet)
    private func updateCardInLearningDeck(_ card: FlashCard) {
        guard !card.isFullyLearned else { return } // Fully learned cards (80%+) go to learnt deck
        guard card.timesShown > 0 else { return } // Don't add new cards
        
        let learningDeck = getLearningDeck()
        
        // Add card to learning deck if not already there
        if let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[cardIndex].deckIds.insert(learningDeck.id)
        }
        
        updateCardDeckAssociations()
    }
    
    /// Returns formatted learning percentage string for display
    func getLearningPercentageString(for card: FlashCard) -> String? {
        guard let percentage = card.learningPercentage else { return nil }
        return String(format: "%.0f%%", percentage)
    }
    
    /// Returns all cards currently being learned (have been shown but not 80%+ accuracy)
    func getCardsInProgress() -> [FlashCard] {
        return flashCards.filter { card in
            card.timesShown > 0 && !card.isFullyLearned
        }
    }
    
    /// Returns all fully learned cards (80%+ accuracy with 5+ attempts)
    func getFullyLearnedCards() -> [FlashCard] {
        return flashCards.filter { $0.isFullyLearned }
    }
    
    /// Debug method to print card deck assignments
    func debugCardDeckAssignments() {
        print("=== Card Deck Assignments Debug ===")
        for card in flashCards {
            let deckNames = card.deckIds.compactMap { deckId in
                decks.first(where: { $0.id == deckId })?.name
            }
            print("Card '\(card.word)': \(deckNames.joined(separator: ", "))")
        }
        print("===================================")
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

// Old deck format without parentId and subDeckIds
private struct OldDeck: Codable {
    var id: UUID
    var name: String
    var cards: [FlashCard]
} 