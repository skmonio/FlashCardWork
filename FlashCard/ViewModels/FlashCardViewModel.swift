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
    private var learntDeckId: UUID?
    private var learningDeckId: UUID?
    
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
        
        // Create "Learnt" deck if it doesn't exist
        if !decks.contains(where: { $0.name == "Learnt" }) {
            let learntDeck = Deck(name: "Learnt")
            learntDeckId = learntDeck.id
            decks.append(learntDeck)
        } else {
            learntDeckId = decks.first(where: { $0.name == "Learnt" })?.id
        }
        
        // Create "Learning" deck if it doesn't exist
        if !decks.contains(where: { $0.name == "Learning" }) {
            let learningDeck = Deck(name: "Learning")
            learningDeckId = learningDeck.id
            decks.append(learningDeck)
        } else {
            learningDeckId = decks.first(where: { $0.name == "Learning" })?.id
        }
        
        // Add example Dutch cards if no cards exist
        if flashCards.isEmpty {
            createExampleDutchCards()
        }
        
        // Initialize statistics for existing cards that might not have them
        initializeStatisticsForExistingCards()
        
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
        
        // Family (A1) - Nouns with articles
        addCard(
            word: "familie",
            definition: "family",
            example: "Mijn familie woont in Amsterdam.",
            deckIds: [familyDeck.id],
            article: "de",
            plural: "families"
        )
        addCard(
            word: "ouder",
            definition: "parent",
            example: "Mijn ouders komen uit Nederland.",
            deckIds: [familyDeck.id],
            article: "de",
            plural: "ouders"
        )
        addCard(
            word: "broer",
            definition: "brother",
            example: "Ik heb één broer.",
            deckIds: [familyDeck.id],
            article: "de",
            plural: "broers"
        )
        
        // Food & Drinks (A1) - Nouns with articles
        addCard(
            word: "brood",
            definition: "bread",
            example: "Ik eet brood met kaas.",
            deckIds: [foodDeck.id],
            article: "het",
            plural: "broden"
        )
        addCard(
            word: "koffie",
            definition: "coffee",
            example: "Wil je een kopje koffie?",
            deckIds: [foodDeck.id],
            article: "de",
            plural: "koffies"
        )
        addCard(
            word: "water",
            definition: "water",
            example: "Mag ik een glas water?",
            deckIds: [foodDeck.id],
            article: "het",
            plural: "waters"
        )
        
        // Numbers & Time (A1)
        addCard(
            word: "een",
            definition: "one",
            example: "Ik heb een kat.",
            deckIds: [numbersDeck.id]
        )
        addCard(
            word: "tijd",
            definition: "time",
            example: "Hoe laat is het?",
            deckIds: [numbersDeck.id],
            article: "de",
            plural: "tijden"
        )
        addCard(
            word: "uur",
            definition: "hour",
            example: "Het is twee uur.",
            deckIds: [numbersDeck.id],
            article: "het",
            plural: "uren"
        )
        
        // Daily Life (A2) - Including verb examples with tenses
        addCard(
            word: "werken",
            definition: "to work",
            example: "Ik wil werken in een kantoor.",
            deckIds: [dailyDeck.id],
            pastTense: "werkte",
            futureTense: "zal werken",
            pastParticiple: "gewerkt"
        )
        addCard(
            word: "eten",
            definition: "to eat",
            example: "Ik wil eten om zes uur.",
            deckIds: [dailyDeck.id],
            pastTense: "at",
            futureTense: "zal eten",
            pastParticiple: "gegeten"
        )
        addCard(
            word: "boodschap",
            definition: "grocery / message",
            example: "Ik ga boodschappen doen.",
            deckIds: [dailyDeck.id],
            article: "de",
            plural: "boodschappen"
        )
        addCard(
            word: "afspraak",
            definition: "appointment",
            example: "Ik heb een afspraak met de dokter.",
            deckIds: [dailyDeck.id],
            article: "de",
            plural: "afspraken"
        )
        
        // Weather (A2)
        addCard(
            word: "weer",
            definition: "weather",
            example: "Het weer is mooi vandaag.",
            deckIds: [weatherDeck.id],
            article: "het"
        )
        addCard(
            word: "regen",
            definition: "rain",
            example: "Het regent vandaag.",
            deckIds: [weatherDeck.id],
            article: "de"
        )
        addCard(
            word: "zonnig",
            definition: "sunny",
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
    
    func addCard(word: String, definition: String, example: String, deckIds: Set<UUID>, article: String = "", plural: String = "", pastTense: String = "", futureTense: String = "", pastParticiple: String = "", cardId: UUID? = nil) -> FlashCard {
        print("Adding new card")
        let newCard = FlashCard(
            word: word, 
            definition: definition, 
            example: example, 
            deckIds: deckIds,
            article: article,
            plural: plural,
            pastTense: pastTense,
            futureTense: futureTense,
            pastParticiple: pastParticiple,
            cardId: cardId
        )
        flashCards.append(newCard)
        updateCardDeckAssociations()
        return newCard
    }
    
    func updateCard(_ card: FlashCard, word: String, definition: String, example: String, deckIds: Set<UUID>, article: String = "", plural: String = "", pastTense: String = "", futureTense: String = "", pastParticiple: String = "") {
        if let index = flashCards.firstIndex(where: { $0.id == card.id }) {
            flashCards[index].word = word
            flashCards[index].definition = definition
            flashCards[index].example = example
            flashCards[index].deckIds = deckIds
            flashCards[index].article = article
            flashCards[index].plural = plural
            flashCards[index].pastTense = pastTense
            flashCards[index].futureTense = futureTense
            flashCards[index].pastParticiple = pastParticiple
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
        if canDeleteDeck(deck) {
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
    
    func renameDeck(_ deck: Deck, newName: String) {
        let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty && trimmedName != deck.name && canRenameDeck(deck) else { return }
        
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
        return getAllDecksHierarchical().filter { $0.name != "Uncategorized" }
    }
    
    // MARK: - Export Functionality
    
    func exportCardsToCSV() -> String {
        let headers = ["Word", "Translation", "Example", "Article", "Plural", "Past Tense", "Future Tense", "Past Participle", "Decks", "Success Count", "Times Shown", "Times Correct"]
        var csvContent = headers.joined(separator: ",") + "\n"
        
        for card in flashCards {
            let deckNames = getDeckNamesForCard(card).joined(separator: "; ")
            
            let row = [
                escapeCSVField(card.word),
                escapeCSVField(card.definition),
                escapeCSVField(card.example),
                escapeCSVField(card.article),
                escapeCSVField(card.plural),
                escapeCSVField(card.pastTense),
                escapeCSVField(card.futureTense),
                escapeCSVField(card.pastParticiple),
                escapeCSVField(deckNames),
                String(card.successCount),
                String(card.timesShown),
                String(card.timesCorrect)
            ]
            
            csvContent += row.joined(separator: ",") + "\n"
        }
        
        return csvContent
    }
    
    func exportDeckToCSV(_ deck: Deck) -> String {
        let headers = ["Word", "Translation", "Example", "Article", "Plural", "Past Tense", "Future Tense", "Past Participle", "Success Count", "Times Shown", "Times Correct"]
        var csvContent = headers.joined(separator: ",") + "\n"
        
        for card in deck.cards {
            let row = [
                escapeCSVField(card.word),
                escapeCSVField(card.definition),
                escapeCSVField(card.example),
                escapeCSVField(card.article),
                escapeCSVField(card.plural),
                escapeCSVField(card.pastTense),
                escapeCSVField(card.futureTense),
                escapeCSVField(card.pastParticiple),
                String(card.successCount),
                String(card.timesShown),
                String(card.timesCorrect)
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
                errors.append("Line \(lineNumber): Missing required word or translation")
                continue
            }
            
            let word = fields[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let definition = fields[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let example = fields.count > 2 ? fields[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            
            // Handle grammatical fields
            let article = fields.count > 3 ? fields[3].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let plural = fields.count > 4 ? fields[4].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let pastTense = fields.count > 5 ? fields[5].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let futureTense = fields.count > 6 ? fields[6].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            let pastParticiple = fields.count > 7 ? fields[7].trimmingCharacters(in: .whitespacesAndNewlines) : ""
            
            // Handle deck names
            var deckIds: Set<UUID> = []
            let deckFieldIndex = 8 // Updated index for new format
            if fields.count > deckFieldIndex && !fields[deckFieldIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let deckNamesString = fields[deckFieldIndex].trimmingCharacters(in: .whitespacesAndNewlines)
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
            
            // Handle success count
            var successCount = 0
            if fields.count > 9 {
                successCount = Int(fields[9].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            }
            
            // Handle learning statistics
            var timesShown = 0
            var timesCorrect = 0
            if fields.count > 10 {
                timesShown = Int(fields[10].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            }
            if fields.count > 11 {
                timesCorrect = Int(fields[11].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
            }
            
            // Create the card with new signature
            let newCard = addCard(
                word: word,
                definition: definition,
                example: example,
                deckIds: deckIds,
                article: article,
                plural: plural,
                pastTense: pastTense,
                futureTense: futureTense,
                pastParticiple: pastParticiple
            )
            
            // Update statistics if provided
            if let cardIndex = flashCards.firstIndex(where: { $0.id == newCard.id }) {
                flashCards[cardIndex].successCount = successCount
                flashCards[cardIndex].timesShown = timesShown
                flashCards[cardIndex].timesCorrect = timesCorrect
            }
            
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
                            newCard.timesShown = 0  // Initialize new statistics fields
                            newCard.timesCorrect = 0
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
                        newCard.timesShown = 0  // Initialize new statistics fields
                        newCard.timesCorrect = 0
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
                            newCard.timesShown = 0  // Initialize new statistics fields
                            newCard.timesCorrect = 0
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
                            newCard.timesShown = 0  // Initialize new statistics fields
                            newCard.timesCorrect = 0
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
                            newCard.timesShown = 0  // Initialize new statistics fields
                            newCard.timesCorrect = 0
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
    
    // MARK: - Learning Statistics Methods
    
    private func initializeStatisticsForExistingCards() {
        var needsSave = false
        for index in flashCards.indices {
            // Check if card has uninitialized statistics (this might happen with old save data)
            if flashCards[index].timesShown == 0 && flashCards[index].timesCorrect == 0 {
                // These are likely default values, which is fine
                continue
            }
        }
        
        if needsSave {
            saveCards()
        }
        
        print("📊 Statistics initialization check completed for \(flashCards.count) cards")
    }
    
    func recordCardShown(_ cardId: UUID, isCorrect: Bool) {
        guard let cardIndex = flashCards.firstIndex(where: { $0.id == cardId }) else { return }
        
        // Update statistics
        flashCards[cardIndex].timesShown += 1
        if isCorrect {
            flashCards[cardIndex].timesCorrect += 1
        }
        
        // Update learning decks with the updated card
        updateLearningDecks(for: flashCards[cardIndex])
        
        // Save changes
        saveCards()
        
        print("📊 Card '\(flashCards[cardIndex].word)' stats updated: \(flashCards[cardIndex].timesCorrect)/\(flashCards[cardIndex].timesShown) = \(flashCards[cardIndex].learningPercentage ?? 0)%")
        
        // Force UI update by triggering objectWillChange
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func updateLearningDecks(for card: FlashCard) {
        guard let learntDeckId = learntDeckId,
              let learningDeckId = learningDeckId,
              let cardIndex = flashCards.firstIndex(where: { $0.id == card.id }) else { return }
        
        // Remove card from both learning decks first
        flashCards[cardIndex].deckIds.remove(learntDeckId)
        flashCards[cardIndex].deckIds.remove(learningDeckId)
        
        // Add to appropriate deck based on learning status
        if flashCards[cardIndex].isFullyLearned {
            flashCards[cardIndex].deckIds.insert(learntDeckId)
            print("📚 Card '\(flashCards[cardIndex].word)' moved to LEARNT deck (\(flashCards[cardIndex].learningPercentage ?? 0)%)")
        } else if flashCards[cardIndex].learningPercentage != nil {
            // Only add to learning deck if the card has been shown at least once
            flashCards[cardIndex].deckIds.insert(learningDeckId)
            print("📖 Card '\(flashCards[cardIndex].word)' moved to LEARNING deck (\(flashCards[cardIndex].learningPercentage ?? 0)%)")
        }
        
        // Update deck associations
        updateCardDeckAssociations()
    }
    
    func resetLearningStatistics() {
        // Reset all card statistics
        for index in flashCards.indices {
            flashCards[index].timesShown = 0
            flashCards[index].timesCorrect = 0
            
            // Remove cards from learning decks
            if let learntDeckId = learntDeckId,
               let learningDeckId = learningDeckId {
                flashCards[index].deckIds.remove(learntDeckId)
                flashCards[index].deckIds.remove(learningDeckId)
            }
        }
        
        // Update deck associations and save
        updateCardDeckAssociations()
        saveCards()
    }
    
    /// Sort cards intelligently for games: less-known cards first, well-known cards later
    func sortCardsForLearning(_ cards: [FlashCard]) -> [FlashCard] {
        return cards.sorted { card1, card2 in
            // Calculate learning scores (lower score = should appear earlier)
            let score1 = calculateLearningScore(for: card1)
            let score2 = calculateLearningScore(for: card2)
            
            // If scores are equal, randomize to avoid predictable patterns
            if score1 == score2 {
                return Bool.random()
            }
            
            return score1 < score2
        }
    }
    
    /// Calculate a learning score for card ordering (0-1000, lower = needs more practice)
    private func calculateLearningScore(for card: FlashCard) -> Int {
        // Base score from learning percentage (0-100)
        let percentageScore = card.learningPercentage ?? 0
        
        // Bonus for times shown (more exposure = later in deck)
        let exposureBonus = min(card.timesShown * 10, 100)
        
        // Bonus for consecutive correct answers
        let correctBonus = min(card.timesCorrect * 20, 200)
        
        // Penalty for recent failures (if percentage is low despite attempts)
        let failurePenalty = card.timesShown > 0 && card.learningPercentage != nil && card.learningPercentage! < 50 ? -50 : 0
        
        // Cards never shown get priority (score 0)
        if card.timesShown == 0 {
            return 0
        }
        
        return percentageScore + exposureBonus + correctBonus + failurePenalty
    }
    
    func canDeleteDeck(_ deck: Deck) -> Bool {
        // Prevent deletion of special learning decks
        return deck.name != "Uncategorized" && deck.name != "Learnt" && deck.name != "Learning"
    }
    
    func canRenameDeck(_ deck: Deck) -> Bool {
        // Prevent renaming of special learning decks
        return deck.name != "Uncategorized" && deck.name != "Learnt" && deck.name != "Learning"
    }
    
    func saveAllData() {
        saveCards()
        saveDecks()
        saveCardStatus()
        print("💾 All ViewModel data saved to UserDefaults")
    }
    
    // MARK: - Duplicate Card Management
    
    enum DuplicateCheckResult {
        case noDuplicate
        case exactMatch(FlashCard)
        case partialMatch(FlashCard, differences: CardComparison)
    }
    
    struct CardComparison {
        let existingFilledFields: Int
        let newFilledFields: Int
        let fieldDifferences: [String: (existing: String, new: String)]
        let newFieldsCount: Int // Fields that are empty in existing but filled in new
        
        var hasMoreInformation: Bool {
            return newFieldsCount > 0 || newFilledFields > existingFilledFields
        }
    }
    
    /// Check if a card with the same word already exists
    func checkForDuplicateCard(word: String, definition: String, example: String, article: String, plural: String, pastTense: String, futureTense: String, pastParticiple: String) -> DuplicateCheckResult {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let existingCard = flashCards.first(where: { $0.word.lowercased() == trimmedWord.lowercased() }) else {
            return .noDuplicate
        }
        
        // Check if it's an exact match (all fields the same)
        if existingCard.definition == definition &&
           existingCard.example == example &&
           existingCard.article == article &&
           existingCard.plural == plural &&
           existingCard.pastTense == pastTense &&
           existingCard.futureTense == futureTense &&
           existingCard.pastParticiple == pastParticiple {
            return .exactMatch(existingCard)
        }
        
        // It's a partial match - compare the differences
        let comparison = compareCards(existing: existingCard, 
                                    newWord: trimmedWord,
                                    newDefinition: definition,
                                    newExample: example,
                                    newArticle: article,
                                    newPlural: plural,
                                    newPastTense: pastTense,
                                    newFutureTense: futureTense,
                                    newPastParticiple: pastParticiple)
        
        return .partialMatch(existingCard, differences: comparison)
    }
    
    /// Compare existing card with new card data
    private func compareCards(existing: FlashCard, newWord: String, newDefinition: String, newExample: String, newArticle: String, newPlural: String, newPastTense: String, newFutureTense: String, newPastParticiple: String) -> CardComparison {
        
        var fieldDifferences: [String: (existing: String, new: String)] = [:]
        var newFieldsCount = 0
        
        // Helper function to check if a field has content
        func hasContent(_ field: String) -> Bool {
            return !field.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        
        // Check each field for differences
        if existing.definition != newDefinition && hasContent(newDefinition) {
            fieldDifferences["definition"] = (existing.definition, newDefinition)
        }
        
        if existing.example != newExample && hasContent(newExample) {
            fieldDifferences["example"] = (existing.example, newExample)
            if !hasContent(existing.example) {
                newFieldsCount += 1
            }
        }
        
        if existing.article != newArticle && hasContent(newArticle) {
            fieldDifferences["article"] = (existing.article, newArticle)
            if !hasContent(existing.article) {
                newFieldsCount += 1
            }
        }
        
        if existing.plural != newPlural && hasContent(newPlural) {
            fieldDifferences["plural"] = (existing.plural, newPlural)
            if !hasContent(existing.plural) {
                newFieldsCount += 1
            }
        }
        
        if existing.pastTense != newPastTense && hasContent(newPastTense) {
            fieldDifferences["pastTense"] = (existing.pastTense, newPastTense)
            if !hasContent(existing.pastTense) {
                newFieldsCount += 1
            }
        }
        
        if existing.futureTense != newFutureTense && hasContent(newFutureTense) {
            fieldDifferences["futureTense"] = (existing.futureTense, newFutureTense)
            if !hasContent(existing.futureTense) {
                newFieldsCount += 1
            }
        }
        
        if existing.pastParticiple != newPastParticiple && hasContent(newPastParticiple) {
            fieldDifferences["pastParticiple"] = (existing.pastParticiple, newPastParticiple)
            if !hasContent(existing.pastParticiple) {
                newFieldsCount += 1
            }
        }
        
        // Count filled fields in existing card
        let existingFilledFields = [
            existing.definition,
            existing.example,
            existing.article,
            existing.plural,
            existing.pastTense,
            existing.futureTense,
            existing.pastParticiple
        ].filter { hasContent($0) }.count
        
        // Count filled fields in new card
        let newFilledFields = [
            newDefinition,
            newExample,
            newArticle,
            newPlural,
            newPastTense,
            newFutureTense,
            newPastParticiple
        ].filter { hasContent($0) }.count
        
        return CardComparison(
            existingFilledFields: existingFilledFields,
            newFilledFields: newFilledFields,
            fieldDifferences: fieldDifferences,
            newFieldsCount: newFieldsCount
        )
    }
    
    /// Merge new card data into existing card
    func mergeCardData(existingCard: FlashCard, newDefinition: String, newExample: String, newDeckIds: Set<UUID>, newArticle: String, newPlural: String, newPastTense: String, newFutureTense: String, newPastParticiple: String, mergeStrategy: MergeStrategy) {
        
        guard let cardIndex = flashCards.firstIndex(where: { $0.id == existingCard.id }) else { return }
        
        switch mergeStrategy {
        case .keepExisting:
            // Only add new deck associations
            flashCards[cardIndex].deckIds.formUnion(newDeckIds)
            
        case .replaceWithNew:
            // Replace all fields with new data
            flashCards[cardIndex].definition = newDefinition
            flashCards[cardIndex].example = newExample
            flashCards[cardIndex].deckIds = newDeckIds
            flashCards[cardIndex].article = newArticle
            flashCards[cardIndex].plural = newPlural
            flashCards[cardIndex].pastTense = newPastTense
            flashCards[cardIndex].futureTense = newFutureTense
            flashCards[cardIndex].pastParticiple = newPastParticiple
            
        case .mergeAdditionalFields:
            // Keep existing definition, but add new fields where existing is empty
            if !newExample.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && flashCards[cardIndex].example.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                flashCards[cardIndex].example = newExample
            }
            if !newArticle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && flashCards[cardIndex].article.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                flashCards[cardIndex].article = newArticle
            }
            if !newPlural.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && flashCards[cardIndex].plural.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                flashCards[cardIndex].plural = newPlural
            }
            if !newPastTense.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && flashCards[cardIndex].pastTense.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                flashCards[cardIndex].pastTense = newPastTense
            }
            if !newFutureTense.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && flashCards[cardIndex].futureTense.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                flashCards[cardIndex].futureTense = newFutureTense
            }
            if !newPastParticiple.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && flashCards[cardIndex].pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                flashCards[cardIndex].pastParticiple = newPastParticiple
            }
            
            // Always merge deck associations
            flashCards[cardIndex].deckIds.formUnion(newDeckIds)
        }
        
        updateCardDeckAssociations()
    }
    
    enum MergeStrategy {
        case keepExisting
        case replaceWithNew
        case mergeAdditionalFields
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