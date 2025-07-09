import Foundation
import UIKit
import CloudKit

class FlashCardViewModel: ObservableObject {
    @Published var flashCards: [FlashCard] = [] {
        didSet {
            print("FlashCards changed: \(flashCards.count) cards")
            saveCards()
            // Remove automatic CloudKit sync on every change - too aggressive!
            // triggerCloudKitSync()
        }
    }
    
    @Published var decks: [Deck] = [] {
        didSet {
            print("Decks changed: \(decks.count) decks")
            saveDecks()
            // Remove automatic CloudKit sync on every change - too aggressive!
            // triggerCloudKitSync()
        }
    }
    
    // Navigation state
    @Published var shouldNavigateToRoot = false
    @Published var navigationPath: [String] = []
    @Published var shouldNavigateToManageDecks = false
    @Published var shouldNavigateToSettings = false
    
    // CloudKit integration
    @Published var isCloudSyncEnabled: Bool = false {  // Changed from true to false temporarily
        didSet {
            UserDefaults.standard.set(isCloudSyncEnabled, forKey: "CloudSyncEnabled")
            if isCloudSyncEnabled {
                // Add schema validation before triggering sync
                validateCloudKitSchemaBeforeSync()
            }
        }
    }
    
    private let cloudKitManager = CloudKitManager.shared
    private var syncTimer: Timer?
    private var lastSyncTime: Date = .distantPast
    private let minimumSyncInterval: TimeInterval = 1800 // 30 minutes instead of 5
    
    private let userDefaultsKey = "SavedFlashCards"
    private let decksDefaultsKey = "SavedDecks"
    private let cardStatusKey = "CardStatus"
    private var uncategorizedDeckId: UUID?
    private var reviewDeckId: UUID?
    
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
        print("🚀 ViewModel init - Starting...")
        
        // Reset navigation state first
        shouldNavigateToRoot = false
        navigationPath = []
        print("✅ Navigation state reset")
        
        // Load CloudKit settings
        isCloudSyncEnabled = UserDefaults.standard.bool(forKey: "CloudSyncEnabled")
        print("✅ CloudKit settings loaded: \(isCloudSyncEnabled)")
        
        // Load critical data synchronously for immediate UI
        print("📂 Loading cards...")
        loadCards()
        print("✅ Cards loaded: \(flashCards.count)")
        
        print("📁 Loading decks...")
        loadDecks()
        print("✅ Decks loaded: \(decks.count)")
        
        print("📊 Loading card status...")
        loadCardStatus()
        print("✅ Card status loaded")
        
        print("🏗️ Creating system decks...")
        // Remove creation of 'Learnt' and 'Learning' decks
        // Only create 'Uncategorized' and 'Review' decks as system decks
        if !decks.contains(where: { $0.name == "Uncategorized" }) {
            let uncategorizedDeck = Deck(name: "Uncategorized")
            uncategorizedDeckId = uncategorizedDeck.id
            decks.append(uncategorizedDeck)
            print("✅ Created Uncategorized deck")
        } else {
            uncategorizedDeckId = decks.first(where: { $0.name == "Uncategorized" })?.id
            print("✅ Found existing Uncategorized deck")
        }
        if !decks.contains(where: { $0.name == "Review" }) {
            let reviewDeck = Deck(name: "Review")
            reviewDeckId = reviewDeck.id
            decks.append(reviewDeck)
            print("✅ Created Review deck")
        } else {
            reviewDeckId = decks.first(where: { $0.name == "Review" })?.id
            print("✅ Found existing Review deck")
        }
        // Remove any loaded decks named 'Learnt' or 'Learning'
        decks.removeAll { $0.name == "Learnt" || $0.name == "Learning" }
        print("📚 Total decks after system deck creation: \(decks.count)")
        
        // Defer non-critical operations to background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.performDeferredInitialization()
        }
        
        print("🎉 ViewModel initialization complete!")
        print("📊 Final state: \(flashCards.count) cards, \(decks.count) decks")
    }
    
    private func performDeferredInitialization() {
        print("🔄 Starting deferred initialization...")
        
        // Add example Dutch cards if no cards exist
        if flashCards.isEmpty {
            print("📝 Creating example cards...")
            DispatchQueue.main.async { [weak self] in
                self?.createExampleDutchCards()
                print("✅ Example cards created: \(self?.flashCards.count ?? 0)")
            }
        } else {
            print("✅ Using existing cards: \(flashCards.count)")
        }
        
        // Initialize statistics for existing cards that might not have them
        print("📈 Initializing statistics...")
        DispatchQueue.main.async { [weak self] in
            self?.initializeStatisticsForExistingCards()
            print("✅ Statistics initialized")
        }
        
        // Update cards and decks
        print("🔄 Updating card-deck associations...")
        DispatchQueue.main.async { [weak self] in
            self?.updateCardDeckAssociations()
            print("✅ Associations updated")
        }
        
        // Set up CloudKit sync (deferred to avoid blocking UI)
        print("☁️ Setting up CloudKit sync...")
        DispatchQueue.main.async { [weak self] in
            self?.setupCloudKitSync()
            print("✅ CloudKit setup complete")
        }
        
        print("✅ Deferred initialization complete")
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
    
    func navigateToManageDecks() {
        shouldNavigateToManageDecks = true
    }
    
    func resetNavigationToManageDecks() {
        shouldNavigateToManageDecks = false
    }
    
    func navigateToSettings() {
        shouldNavigateToSettings = true
    }
    
    func resetNavigationToSettings() {
        shouldNavigateToSettings = false
    }
    
    private func saveCardStatus() {
        // Use background queue for saving to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            if let encoded = try? JSONEncoder().encode(self.cardStatus) {
                UserDefaults.standard.set(encoded, forKey: self.cardStatusKey)
            }
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
        
        // Safety check to prevent crashes
        guard !flashCards.isEmpty || !decks.isEmpty else {
            print("⚠️ Skipping deck associations update - no cards or decks")
            return
        }
        
        // Create a mutable copy of decks to prevent didSet loops
        var tempDecks = decks
        
        // Clear all deck cards safely
        for index in tempDecks.indices {
            tempDecks[index].cards = []
        }
        
        // Reassign cards to appropriate decks with safety checks
        for card in flashCards {
            // Safety check for card validity
            guard !card.word.isEmpty else {
                print("⚠️ Skipping invalid card with empty word")
                continue
            }
            
            if card.deckIds.isEmpty {
                // Add to uncategorized if no decks
                if let uncategorizedIndex = tempDecks.firstIndex(where: { $0.name == "Uncategorized" }) {
                    tempDecks[uncategorizedIndex].cards.append(card)
                }
            } else {
                // Add to all assigned decks with safety checks
                for deckId in card.deckIds {
                    if let deckIndex = tempDecks.firstIndex(where: { $0.id == deckId }) {
                        tempDecks[deckIndex].cards.append(card)
                    }
                }
            }
        }
        
        // Update decks only once at the end to avoid didSet loops
        decks = tempDecks
    }
    
    func addCard(word: String, definition: String, example: String, deckIds: Set<UUID>, article: String = "", plural: String = "", pastTense: String = "", futureTense: String = "", pastParticiple: String = "", cardId: UUID? = nil) -> FlashCard {
        print("Adding new card")
        
        // Safety checks to prevent crashes
        let safeWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !safeWord.isEmpty else {
            print("❌ Cannot add card with empty word")
            // Return a placeholder card that won't be saved
            return FlashCard(word: "Error", definition: "Invalid card", example: "")
        }
        
        guard !safeDefinition.isEmpty else {
            print("❌ Cannot add card with empty definition")
            // Return a placeholder card that won't be saved
            return FlashCard(word: safeWord, definition: "Translation needed", example: example)
        }
        
        // Ensure cards without decks go to Uncategorized
        var finalDeckIds = deckIds
        if finalDeckIds.isEmpty {
            if let uncategorizedDeck = decks.first(where: { $0.name == "Uncategorized" }) {
                finalDeckIds.insert(uncategorizedDeck.id)
                print("📁 Card '\(safeWord)' has no decks - adding to Uncategorized")
            }
        }
        
        do {
            var newCard = FlashCard(
                word: safeWord, 
                definition: safeDefinition, 
                example: example.trimmingCharacters(in: .whitespacesAndNewlines), 
                deckIds: finalDeckIds,
                article: article.trimmingCharacters(in: .whitespacesAndNewlines),
                plural: plural.trimmingCharacters(in: .whitespacesAndNewlines),
                pastTense: pastTense.trimmingCharacters(in: .whitespacesAndNewlines),
                futureTense: futureTense.trimmingCharacters(in: .whitespacesAndNewlines),
                pastParticiple: pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines),
                cardId: cardId
            )
            
            // Mark as modified for CloudKit
            newCard.markAsModified()
            
            flashCards.append(newCard)
            
            // Use DispatchQueue to prevent potential main thread issues
            DispatchQueue.main.async { [weak self] in
                self?.updateCardDeckAssociations()
            }
            
            print("✅ Successfully added card: '\(safeWord)' -> '\(safeDefinition)' to \(finalDeckIds.count) deck(s)")
            return newCard
        } catch {
            print("❌ Error creating card: \(error)")
            // Return a safe fallback card
            return FlashCard(word: safeWord, definition: safeDefinition, example: example)
        }
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
            
            // Mark as modified for CloudKit
            flashCards[index].markAsModified()
            
            updateCardDeckAssociations()
        }
    }
    
    /// Update a card with SRS data (used by SRS study mode)
    func updateCardWithSRSData(_ updatedCard: FlashCard) {
        if let index = flashCards.firstIndex(where: { $0.id == updatedCard.id }) {
            // Update SRS-specific fields
            flashCards[index].srsLevel = updatedCard.srsLevel
            flashCards[index].nextReviewDate = updatedCard.nextReviewDate
            flashCards[index].consecutiveCorrect = updatedCard.consecutiveCorrect
            flashCards[index].consecutiveIncorrect = updatedCard.consecutiveIncorrect
            flashCards[index].easeFactor = updatedCard.easeFactor
            flashCards[index].lastReviewDate = updatedCard.lastReviewDate
            flashCards[index].totalReviews = updatedCard.totalReviews
            
            // Mark as modified for CloudKit
            flashCards[index].markAsModified()
            
            // Save changes
            saveCards()
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
        var newDeck = Deck(name: name)
        
        // Mark as modified for CloudKit
        newDeck.markAsModified()
        
        decks.append(newDeck)
        return newDeck
    }
    
    func createSubDeck(name: String, parentId: UUID) -> Deck {
        print("Creating new sub-deck: \(name) under parent: \(parentId)")
        var newSubDeck = Deck(name: name, parentId: parentId)
        
        // Mark as modified for CloudKit
        newSubDeck.markAsModified()
        
        decks.append(newSubDeck)
        
        // Update parent deck to include this sub-deck
        if let parentIndex = decks.firstIndex(where: { $0.id == parentId }) {
            decks[parentIndex].subDeckIds.insert(newSubDeck.id)
            decks[parentIndex].markAsModified()
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
            
            // Mark as modified for CloudKit
            decks[index].markAsModified()
            
            saveDecks()
        }
    }
    
    func getSelectableDecks() -> [Deck] {
        return getAllDecksHierarchical().filter { $0.name != "Uncategorized" }
    }
    
    // MARK: - Export Functionality
    
func exportCardsToCSV() -> String {
    print("🔍 Export Debug: Starting exportCardsToCSV")
    print("🔍 Export Debug: flashCards.count = \(flashCards.count)")

    let headers = ["Word", "Translation", "Example", "Article", "Plural", "Past Tense", "Future Tense", "Past Participle", "Decks", "Success Count", "Times Shown", "Times Correct"]
    var csvContent = headers.joined(separator: ",") + "\n"

    print("🔍 Export Debug: Headers added, csvContent length = \(csvContent.count)")

    // Export all cards as before
    for (index, card) in flashCards.enumerated() {
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
        if index < 3 { // Log first 3 cards for debugging
            print("🔍 Export Debug: Card \(index + 1): \(card.word) -> \(card.definition)")
        }
    }

    // Add a row for every deck with zero cards
    let decksWithNoCards = decks.filter { $0.cards.isEmpty }
    for deck in decksWithNoCards {
        let row = [String](repeating: "", count: 8) + [escapeCSVField(deck.name)] + [String](repeating: "", count: 3)
        csvContent += row.joined(separator: ",") + "\n"
    }

    print("🔍 Export Debug: Final csvContent length = \(csvContent.count)")
    print("🔍 Export Debug: First 200 chars: \(String(csvContent.prefix(200)))")

    return csvContent
}
    
    func exportDeckToCSV(_ deck: Deck) -> String {
        let headers = ["Word", "Translation", "Example", "Article", "Plural", "Past Tense", "Future Tense", "Past Participle", "Decks", "Success Count", "Times Shown", "Times Correct"]
        var csvContent = headers.joined(separator: ",") + "\n"
        
        // Collect all cards from this deck and its sub-decks
        var allCards: Set<FlashCard> = []
        
        // Add cards from this deck
        allCards.formUnion(Set(deck.cards))
        
        // Add cards from all sub-decks
        let subDecks = getSubDecks(for: deck.id)
        for subDeck in subDecks {
            allCards.formUnion(Set(subDeck.cards))
        }
        
        // Convert to sorted array for consistent output
        let sortedCards = Array(allCards).sorted { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending }
        
        for card in sortedCards {
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
    
    func exportMultipleDecksToCSV(_ deckIds: Set<UUID>) -> String {
        print("🔍 Export Debug: Starting exportMultipleDecksToCSV with \(deckIds.count) deck IDs")
        print("🔍 Export Debug: Selected deck IDs: \(deckIds)")
        
        // Auto-include parent decks when their sub-decks are selected
        let expandedDeckIds = expandDeckSelectionWithParents(deckIds)
        if expandedDeckIds.count > deckIds.count {
            print("🔍 Export Debug: Auto-included \(expandedDeckIds.count - deckIds.count) parent decks")
        }
        
        let headers = ["Word", "Translation", "Example", "Article", "Plural", "Past Tense", "Future Tense", "Past Participle", "Decks", "Success Count", "Times Shown", "Times Correct"]
        var csvContent = headers.joined(separator: ",") + "\n"
        
        // Collect all cards from selected decks (including hierarchy)
        var allCards: Set<FlashCard> = []
        
        for deckId in expandedDeckIds {
            if let deck = decks.first(where: { $0.id == deckId }) {
                print("🔍 Export Debug: Processing deck '\(deck.name)' with \(deck.cards.count) cards")
                
                // Add cards from this deck
                allCards.formUnion(Set(deck.cards))
                
                // Add cards from all sub-decks
                let subDecks = getSubDecks(for: deck.id)
                print("🔍 Export Debug: Found \(subDecks.count) sub-decks for '\(deck.name)'")
                
                for subDeck in subDecks {
                    print("🔍 Export Debug: Processing sub-deck '\(subDeck.name)' with \(subDeck.cards.count) cards")
                    allCards.formUnion(Set(subDeck.cards))
                }
            } else {
                print("❌ Export Debug: Could not find deck with ID \(deckId)")
            }
        }
        
        print("🔍 Export Debug: Total unique cards found: \(allCards.count)")
        
        if allCards.isEmpty {
            print("⚠️ Export Debug: No cards found in selected decks. This might indicate:")
            print("   - Selected decks are empty")
            print("   - Cards are not properly associated with decks")
            print("   - Only sub-decks were selected without their parent decks")
        }
        
        // Convert to sorted array for consistent output
        let sortedCards = Array(allCards).sorted { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending }
        
        for card in sortedCards {
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
        
        print("🔍 Export Debug: Final CSV content length: \(csvContent.count) characters")
        print("🔍 Export Debug: CSV has \(csvContent.components(separatedBy: .newlines).count) lines")
        
        return csvContent
    }
    
    // Helper function to automatically include parent decks when their sub-decks are selected
    private func expandDeckSelectionWithParents(_ selectedDeckIds: Set<UUID>) -> Set<UUID> {
        var expandedIds = selectedDeckIds
        
        for deckId in selectedDeckIds {
            if let deck = decks.first(where: { $0.id == deckId }),
               let parentId = deck.parentId {
                // This is a sub-deck, add its parent
                expandedIds.insert(parentId)
                print("🔍 Export Debug: Auto-including parent deck for sub-deck '\(deck.name)'")
            }
        }
        
        return expandedIds
    }
    
    func getTotalCardsInDeckHierarchy(_ deck: Deck) -> Int {
        var totalCards = deck.cards.count
        
        // Add cards from all sub-decks
        let subDecks = getSubDecks(for: deck.id)
        for subDeck in subDecks {
            totalCards += subDeck.cards.count
        }
        
        return totalCards
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
        
        // Ensure Uncategorized deck exists
        let uncategorizedDeck: Deck
        if let existing = decks.first(where: { $0.name == "Uncategorized" }) {
            uncategorizedDeck = existing
        } else {
            uncategorizedDeck = createDeck(name: "Uncategorized")
        }
        
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
            
            // If no decks were assigned, add to Uncategorized
            if deckIds.isEmpty {
                deckIds.insert(uncategorizedDeck.id)
            }
            
            // Handle success count
            var cardSuccessCount = 0
            if fields.count > 9 {
                cardSuccessCount = Int(fields[9].trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
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
                flashCards[cardIndex].successCount = cardSuccessCount
                flashCards[cardIndex].timesShown = timesShown
                flashCards[cardIndex].timesCorrect = timesCorrect
            }
            
            successCount += 1
        }
        
        // Only sync to CloudKit after bulk import (not on every card)
        if successCount > 0 {
            print("📦 Imported \(successCount) cards - scheduling CloudKit sync")
            forceSyncAfterDataChange()
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
        // Use background queue for saving to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            print("Saving cards to UserDefaults")
            if let encoded = try? JSONEncoder().encode(self.flashCards) {
                UserDefaults.standard.set(encoded, forKey: self.userDefaultsKey)
                print("Cards saved successfully")
            } else {
                print("Error: Failed to encode cards")
            }
        }
    }
    
    private func loadCards() {
        print("Loading cards from UserDefaults")
        
        // Check if there's any data at all
        guard let savedCards = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            print("❌ No saved data found in UserDefaults for key: \(userDefaultsKey)")
            return
        }
        
        print("Found saved data: \(savedCards.count) bytes")
        
        // Try to decode with new format first (most common case)
        do {
            let decodedCards = try JSONDecoder().decode([FlashCard].self, from: savedCards)
            flashCards = decodedCards
            print("✅ Successfully loaded \(flashCards.count) cards with new format")
            return
        } catch {
            print("❌ Failed to decode with new format: \(error)")
        }
        
        // Try to decode with old format (single deckId)
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
                newCard.timesShown = 0  // Initialize new statistics fields
                newCard.timesCorrect = 0
                return newCard
            }
            
            print("✅ Successfully migrated \(flashCards.count) cards from old format")
            
            // Save in new format immediately
            saveCards()
            return
        } catch {
            print("❌ Failed to decode with old format: \(error)")
        }
        
        // Try to decode with simple format
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
        
        print("❌ Failed to decode data in any known format")
    }
    
    private func saveDecks() {
        // Use background queue for saving to avoid blocking UI
        DispatchQueue.global(qos: .utility).async {
            print("Saving decks to UserDefaults")
            if let encoded = try? JSONEncoder().encode(self.decks) {
                UserDefaults.standard.set(encoded, forKey: self.decksDefaultsKey)
                print("Decks saved successfully")
            } else {
                print("Error: Failed to encode decks")
            }
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
        print("📊 Recording card shown: \(cardId), correct: \(isCorrect)")
        guard let cardIndex = flashCards.firstIndex(where: { $0.id == cardId }) else { 
            print("❌ Card not found: \(cardId)")
            return 
        }
        
        // Update statistics
        flashCards[cardIndex].timesShown += 1
        if isCorrect {
            flashCards[cardIndex].timesCorrect += 1
        }
        
        // Mark as modified for CloudKit (but don't trigger sync immediately)
        flashCards[cardIndex].markAsModified()
        
        // Save changes to local storage (but CloudKit sync is paused during study)
        saveCards()
        
        print("📊 Card '\(flashCards[cardIndex].word)' stats updated: \(flashCards[cardIndex].timesCorrect)/\(flashCards[cardIndex].timesShown) = \(flashCards[cardIndex].learningPercentage ?? 0)%")
        
        // Force UI update by triggering objectWillChange (non-blocking)
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func resetLearningStatistics() {
        // Reset all card statistics
        for index in flashCards.indices {
            flashCards[index].timesShown = 0
            flashCards[index].timesCorrect = 0
            // Remove cards from learning decks (no longer needed)
        }
        // Update deck associations and save
        updateCardDeckAssociations()
        saveCards()
    }
    
    func addCardToReview(_ cardId: UUID) {
        print("📋 addCardToReview - Starting for cardId: \(cardId)")
        guard let reviewDeckId = reviewDeckId,
              let cardIndex = flashCards.firstIndex(where: { $0.id == cardId }) else { 
            print("📋 addCardToReview - Guard failed: reviewDeckId=\(String(describing: reviewDeckId)), cardFound=\(flashCards.firstIndex(where: { $0.id == cardId }) != nil)")
            return 
        }
        
        // Add card to review deck if not already there
        flashCards[cardIndex].deckIds.insert(reviewDeckId)
        print("📋 addCardToReview - Card deck IDs updated")
        
        // Save changes (defer heavy deck associations update until study session ends)
        print("📋 addCardToReview - About to save...")
        saveCards()
        print("📋 addCardToReview - saveCards complete")
        
        print("📋 Card '\(flashCards[cardIndex].word)' added to Review deck")
        
        // Force UI update
        DispatchQueue.main.async {
            print("📋 addCardToReview - Triggering UI update")
            self.objectWillChange.send()
        }
        print("📋 addCardToReview - Complete")
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
        // Prevent deletion of special decks
        return deck.name != "Uncategorized" && deck.name != "Review"
    }
    
    func canRenameDeck(_ deck: Deck) -> Bool {
        // Prevent renaming of special decks
        return deck.name != "Uncategorized" && deck.name != "Review"
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
        
        guard let existingCard = flashCards.first(where: { $0.word == trimmedWord }) else {
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
    
    // MARK: - CloudKit Integration
    
    private func setupCloudKitSync() {
        print("☁️ CloudKit setup starting...")
        
        // Set up periodic sync every 30 minutes (much less aggressive)
        #if !targetEnvironment(simulator)
        print("☁️ Setting up periodic sync timer (30-minute intervals)")
        syncTimer = Timer.scheduledTimer(withTimeInterval: minimumSyncInterval, repeats: true) { [weak self] _ in
            self?.conditionalCloudKitSync()
        }
        #else
        print("☁️ Skipping periodic sync timer (simulator mode)")
        #endif
        
        // Set up app lifecycle notifications for proper sync timing
        setupAppLifecycleObservers()
        
        // Defer initial sync to avoid blocking startup
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2.0) { [weak self] in
            if self?.isCloudSyncEnabled == true {
                print("☁️ CloudKit enabled, performing deferred initial sync...")
                self?.performInitialCloudKitSync()
            } else {
                print("☁️ CloudKit disabled in settings")
            }
        }
        
        print("☁️ CloudKit setup method complete")
    }
    
    private func setupAppLifecycleObservers() {
        #if !targetEnvironment(simulator)
        // Sync when app goes to background
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("📱 App entering background - triggering CloudKit sync")
            self?.conditionalCloudKitSync()
        }
        
        // Sync when app becomes active
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("📱 App became active - checking for CloudKit sync")
            self?.conditionalCloudKitSync()
        }
        #endif
    }
    
    private func conditionalCloudKitSync() {
        guard isCloudSyncEnabled else { 
            print("☁️ CloudKit sync skipped - disabled")
            return 
        }
        
        // Check if enough time has passed since last sync
        let timeSinceLastSync = Date().timeIntervalSince(lastSyncTime)
        if timeSinceLastSync < minimumSyncInterval {
            print("☁️ CloudKit sync skipped - too soon (last sync \(Int(timeSinceLastSync))s ago)")
            return
        }
        
        print("☁️ Performing conditional CloudKit sync")
        performCloudKitSync()
    }
    
    private func performInitialCloudKitSync() {
        print("☁️ Initial CloudKit sync starting...")
        guard isCloudSyncEnabled else { 
            print("☁️ Sync disabled, returning early")
            return 
        }
        
        #if targetEnvironment(simulator)
        print("📱 Skipping CloudKit sync - running on simulator")
        return
        #endif
        
        print("☁️ Creating detached async task for CloudKit sync...")
        // Use Task.detached to prevent blocking the UI
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            print("☁️ Inside detached async task, calling CloudKit manager...")
            do {
                let currentCards = await MainActor.run { self.flashCards }
                let currentDecks = await MainActor.run { self.decks }
                
                print("☁️ Starting CloudKit sync with \(currentCards.count) cards and \(currentDecks.count) decks")
                
                let (syncedCards, syncedDecks) = await self.cloudKitManager.syncData(
                    flashCards: currentCards,
                    decks: currentDecks
                )
                
                print("☁️ CloudKit sync completed with \(syncedCards.count) cards and \(syncedDecks.count) decks")
                
                await MainActor.run {
                    // Check if this was a new device download (more cloud data than local)
                    let wasNewDeviceDownload = syncedCards.count > currentCards.count || syncedDecks.count > currentDecks.count
                    
                    if wasNewDeviceDownload {
                        print("🆕 New device detected - downloaded \(syncedCards.count - currentCards.count) new cards and \(syncedDecks.count - currentDecks.count) new decks")
                    }
                    
                    // Temporarily disable CloudKit sync to prevent recursion
                    let originalSyncEnabled = self.isCloudSyncEnabled
                    self.isCloudSyncEnabled = false
                    
                    // Update data with synced results
                    self.flashCards = syncedCards
                    self.decks = syncedDecks
                    self.updateCardDeckAssociations()
                    
                    // Re-enable sync
                    self.isCloudSyncEnabled = originalSyncEnabled
                    
                    // Mark sync time
                    self.lastSyncTime = Date()
                    
                    if wasNewDeviceDownload {
                        print("✅ Initial CloudKit download completed - your data has been restored!")
                    } else {
                        print("✅ Initial CloudKit sync completed")
                    }
                }
            } catch {
                print("❌ Initial CloudKit sync failed: \(error)")
                
                // Provide user-friendly error handling
                await MainActor.run {
                    // Don't reset sync time on first failure to allow quick retry
                    if let ckError = error as? CKError {
                        switch ckError.code {
                        case .quotaExceeded:
                            print("⚠️ CloudKit quota exceeded - will retry automatically")
                        case .networkUnavailable, .networkFailure:
                            print("📶 Network issue - will retry when connection improves")
                        case .notAuthenticated:
                            print("🔐 iCloud account issue - please check Settings > [Your Name] > iCloud")
                        default:
                            print("☁️ CloudKit error: \(ckError.localizedDescription)")
                        }
                    }
                }
            }
        }
        print("☁️ Initial CloudKit sync task created")
    }
    
    private func triggerCloudKitSync() {
        // This method now only triggers immediate sync for specific user actions
        guard isCloudSyncEnabled else { return }
        
        #if targetEnvironment(simulator)
        return
        #endif
        
        print("☁️ Manual sync triggered")
        performCloudKitSync()
    }
    
    private func performCloudKitSync() {
        guard isCloudSyncEnabled else { return }
        
        #if targetEnvironment(simulator)
        return
        #endif
        
        // Update last sync time to prevent too frequent syncing
        lastSyncTime = Date()
        
        // Use Task.detached to prevent blocking the UI
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                let currentCards = await MainActor.run { self.flashCards }
                let currentDecks = await MainActor.run { self.decks }
                
                let (syncedCards, syncedDecks) = await self.cloudKitManager.syncData(
                    flashCards: currentCards,
                    decks: currentDecks
                )
                
                await MainActor.run {
                    // Only update if data has significantly changed to prevent infinite loops
                    let cardsChanged = syncedCards.count != self.flashCards.count || 
                                     syncedCards.map(\.id).sorted() != self.flashCards.map(\.id).sorted()
                    let decksChanged = syncedDecks.count != self.decks.count ||
                                     syncedDecks.map(\.id).sorted() != self.decks.map(\.id).sorted()
                    
                    if cardsChanged || decksChanged {
                        // Temporarily disable CloudKit sync to prevent recursion
                        let originalSyncEnabled = self.isCloudSyncEnabled
                        self.isCloudSyncEnabled = false
                        
                        self.flashCards = syncedCards
                        self.decks = syncedDecks
                        self.updateCardDeckAssociations()
                        
                        self.isCloudSyncEnabled = originalSyncEnabled
                        print("🔄 CloudKit sync updated data")
                    } else {
                        print("☁️ CloudKit sync completed - no changes needed")
                    }
                }
            } catch {
                print("❌ CloudKit sync failed: \(error)")
                // Reset last sync time on failure so we can retry sooner if needed
                await MainActor.run {
                    self.lastSyncTime = .distantPast
                }
            }
        }
    }
    
    func manualSync() {
        #if targetEnvironment(simulator)
        print("📱 Manual sync skipped - running on simulator")
        return
        #endif
        
        print("👤 User requested manual sync")
        
        // Check CloudKit status first on main actor
        Task { @MainActor in
            guard cloudKitManager.isAccountAvailable else {
                print("❌ iCloud account not available")
                return
            }
            
            // Allow manual sync even if recent sync occurred
            lastSyncTime = .distantPast
            
            print("🔄 Starting manual sync...")
            performCloudKitSync()
        }
    }
    
    func forceFullSync() {
        #if targetEnvironment(simulator)
        print("📱 Force sync skipped - running on simulator")
        return
        #endif
        
        print("🔄 User requested force full sync")
        
        // Reset sync time to force immediate sync
        lastSyncTime = .distantPast
        
        // Perform sync with all current data
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                let currentCards = await MainActor.run { self.flashCards }
                let currentDecks = await MainActor.run { self.decks }
                
                print("🔄 Force syncing \(currentCards.count) cards and \(currentDecks.count) decks")
                
                let (syncedCards, syncedDecks) = await self.cloudKitManager.syncData(
                    flashCards: currentCards,
                    decks: currentDecks
                )
                
                await MainActor.run {
                    // Always update data on force sync
                    let originalSyncEnabled = self.isCloudSyncEnabled
                    self.isCloudSyncEnabled = false
                    
                    self.flashCards = syncedCards
                    self.decks = syncedDecks
                    self.updateCardDeckAssociations()
                    
                    self.isCloudSyncEnabled = originalSyncEnabled
                    self.lastSyncTime = Date()
                    
                    print("✅ Force sync completed - \(syncedCards.count) cards, \(syncedDecks.count) decks")
                }
            } catch {
                print("❌ Force sync failed: \(error)")
                await MainActor.run {
                    self.lastSyncTime = .distantPast // Allow retry
                }
            }
        }
    }
    
    func toggleCloudSync() {
        #if targetEnvironment(simulator)
        print("📱 CloudKit toggle ignored - running on simulator")
        return
        #endif
        
        isCloudSyncEnabled.toggle()
        if isCloudSyncEnabled {
            performInitialCloudKitSync()
        }
    }
    
    func getCloudSyncStatus() async -> String {
        #if targetEnvironment(simulator)
        return "Simulator mode - CloudKit disabled"
        #else
        return await MainActor.run { cloudKitManager.statusMessage }
        #endif
    }
    
    func getIsCloudSyncAvailable() async -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return await MainActor.run { cloudKitManager.isAccountAvailable }
        #endif
    }
    
    // Synchronous versions for UI that may not always be up to date but won't crash
    var cloudSyncStatus: String {
        #if targetEnvironment(simulator)
        return "Simulator mode"
        #else
        return "Sync status loading..."
        #endif
    }
    
    var isCloudSyncAvailable: Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        return false
        #endif
    }
    
    deinit {
        syncTimer?.invalidate()
    }
    
    // MARK: - CloudKit Sync Control
    
    func pauseCloudKitSync() {
        #if !targetEnvironment(simulator)
        print("⏸️ Pausing CloudKit sync during active session")
        syncTimer?.invalidate()
        syncTimer = nil
        #endif
    }
    
    func resumeCloudKitSync() {
        #if !targetEnvironment(simulator)
        print("▶️ Resuming CloudKit sync")
        
        // Update deck associations after study session (deferred for performance)
        print("🔄 Updating deck associations after study session")
        updateCardDeckAssociations()
        
        // Restart the periodic sync timer with 30-minute intervals
        syncTimer = Timer.scheduledTimer(withTimeInterval: minimumSyncInterval, repeats: true) { [weak self] _ in
            self?.conditionalCloudKitSync()
        }
        #endif
    }
    
    // Add method to force sync for important data changes (like bulk imports)
    func forceSyncAfterDataChange() {
        #if !targetEnvironment(simulator)
        print("🔄 Forcing sync after significant data change")
        // Reset last sync time and trigger immediate sync
        lastSyncTime = .distantPast
        triggerCloudKitSync()
        #endif
    }
    
    // MARK: - CloudKit Testing
    
    func testCloudKitQuota() {
        #if !targetEnvironment(simulator)
        print("🧪 CloudKit Quota Test - Starting")
        print("🧪 Current cards count: \(flashCards.count)")
        print("🧪 Current decks count: \(decks.count)")
        
        // Count cards that have been modified recently (last hour) as a proxy for "needs sync"
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let recentlyModifiedCards = flashCards.filter { $0.lastModified > oneHourAgo }
        let recentlyModifiedDecks = decks.filter { $0.lastModified > oneHourAgo }
        
        // Count cards/decks that don't have CloudKit record names (never synced)
        let unsyncedCards = flashCards.filter { $0.cloudKitRecordName == nil }
        let unsyncedDecks = decks.filter { $0.cloudKitRecordName == nil }
        
        print("🧪 Recently modified cards (last hour): \(recentlyModifiedCards.count)")
        print("🧪 Recently modified decks (last hour): \(recentlyModifiedDecks.count)")
        print("🧪 Never synced cards: \(unsyncedCards.count)")
        print("🧪 Never synced decks: \(unsyncedDecks.count)")
        print("🧪 Last sync time: \(lastSyncTime)")
        print("🧪 CloudKit enabled: \(isCloudSyncEnabled)")
        
        // Show some specific card details
        if !flashCards.isEmpty {
            let firstCard = flashCards[0]
            print("🧪 Sample card: '\(firstCard.word)' - lastModified: \(firstCard.lastModified), cloudKitRecordName: \(firstCard.cloudKitRecordName ?? "nil")")
        }
        
        // Show current CloudKit status
        Task { @MainActor in
            print("🧪 CloudKit status: \(cloudKitManager.statusMessage)")
            print("🧪 CloudKit account available: \(cloudKitManager.isAccountAvailable)")
        }
        
        // Test a minimal sync operation
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                print("🧪 Testing CloudKit sync with current data...")
                let currentCards = await MainActor.run { self.flashCards }
                let currentDecks = await MainActor.run { self.decks }
                
                let (syncedCards, syncedDecks) = await self.cloudKitManager.syncData(
                    flashCards: currentCards,
                    decks: currentDecks
                )
                
                await MainActor.run {
                    print("🧪 Test sync completed successfully")
                    print("🧪 Synced cards: \(syncedCards.count), Synced decks: \(syncedDecks.count)")
                    print("🧪 CloudKit manager status: \(self.cloudKitManager.statusMessage)")
                }
            } catch {
                await MainActor.run {
                    print("🧪 Test sync failed: \(error)")
                    if let ckError = error as? CKError {
                        print("🧪 CloudKit error code: \(ckError.code)")
                        print("🧪 CloudKit error description: \(ckError.localizedDescription)")
                        if let retryAfter = ckError.retryAfterSeconds {
                            print("🧪 CloudKit retry after: \(retryAfter) seconds")
                        }
                    }
                }
            }
        }
        #else
        print("🧪 CloudKit test skipped - running on simulator")
        #endif
    }
    
    // MARK: - Testing Helper Methods
    
    func createTestCards(count: Int = 50) {
        #if !targetEnvironment(simulator)
        print("🧪 Creating \(count) test cards for quota testing...")
        
        let testDeck = createDeck(name: "Test Quota Deck")
        
        for i in 1...count {
            addCard(
                word: "TestWord\(i)",
                definition: "Test definition for word \(i)",
                example: "This is test example \(i) for quota testing.",
                deckIds: [testDeck.id],
                article: i % 2 == 0 ? "de" : "het",
                plural: "TestWord\(i)s"
            )
        }
        
        print("🧪 Created \(count) test cards - triggering sync...")
        forceSyncAfterDataChange()
        #else
        print("🧪 Test card creation skipped - running on simulator")
        #endif
    }
    
    private func validateCloudKitSchemaBeforeSync() {
        #if !targetEnvironment(simulator)
        Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                // Test if we can create a simple query to check schema
                try await self.cloudKitManager.validateSchema()
                await MainActor.run {
                    self.triggerCloudKitSync()
                }
            } catch {
                await MainActor.run {
                    print("⚠️ CloudKit schema validation failed: \(error)")
                    
                    // Check for production schema error
                    if let ckError = error as? CKError,
                       ckError.localizedDescription.contains("production schema") ||
                       ckError.localizedDescription.contains("Cannot create new type") {
                        print("🔧 CloudKit Schema Issue Detected:")
                        print("   The CloudKit schema needs to be deployed to production.")
                        print("   Please deploy the schema via CloudKit Console:")
                        print("   https://icloud.developer.apple.com/dashboard")
                        print("   Container: iCloud.Dutch.FlashCard")
                        
                        // Temporarily disable sync to prevent repeated errors
                        self.isCloudSyncEnabled = false
                    }
                }
            }
        }
        #else
        triggerCloudKitSync()
        #endif
    }
    
    // MARK: - Duplicate Card Management
    
    
    /// Check for duplicate cards in the flashCards array and log them
    func checkForDuplicateCards() -> (hasDuplicates: Bool, duplicateCount: Int) {
        var seenCardIds: Set<UUID> = []
        var seenWords: Set<String> = []
        var duplicateIds: [UUID] = []
        var duplicateWords: [String] = []
        
        for card in flashCards {
            // Check for duplicate IDs
            if seenCardIds.contains(card.id) {
                duplicateIds.append(card.id)
                print("⚠️ Found duplicate card ID: \(card.id) for word: '\(card.word)'")
            } else {
                seenCardIds.insert(card.id)
            }
            
            // Check for duplicate words (case-insensitive)
            let lowercasedWord = card.word.lowercased()
            if seenWords.contains(lowercasedWord) {
                duplicateWords.append(card.word)
                print("⚠️ Found duplicate word: '\(card.word)' with ID: \(card.id)")
            } else {
                seenWords.insert(lowercasedWord)
            }
        }
        
        let totalDuplicates = duplicateIds.count + duplicateWords.count
        if totalDuplicates > 0 {
            print("🔍 Found \(duplicateIds.count) duplicate IDs and \(duplicateWords.count) duplicate words")
        }
        
        return (totalDuplicates > 0, totalDuplicates)
    }
    
    /// Remove duplicate cards from the flashCards array
    func removeDuplicateCards() -> (removedCount: Int, message: String) {
        print("🧹 Removing duplicate cards from flashCards array")
        let originalCount = flashCards.count
        
        // Remove duplicates by ID (keep first occurrence)
        var uniqueCards: [FlashCard] = []
        var seenCardIds: Set<UUID> = []
        var removedCount = 0
        
        for card in flashCards {
            if !seenCardIds.contains(card.id) {
                uniqueCards.append(card)
                seenCardIds.insert(card.id)
            } else {
                removedCount += 1
                print("🗑️ Removed duplicate card: '\(card.word)' with ID: \(card.id)")
            }
        }
        
        // Update the flashCards array
        flashCards = uniqueCards
        
        // Update deck associations to ensure consistency
        updateCardDeckAssociations()
        
        // Save changes
        saveCards()
        
        let message = "Removed \(removedCount) duplicate cards. Total cards: \(originalCount) → \(flashCards.count)"
        print("✅ \(message)")
        
        return (removedCount, message)
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