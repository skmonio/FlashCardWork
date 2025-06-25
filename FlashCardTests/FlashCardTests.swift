//
//  FlashCardTests.swift
//  FlashCardTests
//
//  Created by Stephen Cook on 04/06/2025.
//

import Testing
import Foundation
@testable import FlashCard

struct FlashCardTests {
    
    // MARK: - FlashCard Model Tests
    
    @Test func testFlashCardInitialization() async throws {
        let card = FlashCard(
            word: "hallo",
            definition: "hello",
            example: "Hallo, hoe gaat het?",
            deckIds: [UUID()],
            article: "het",
            plural: "hallo's"
        )
        
        #expect(card.word == "hallo")
        #expect(card.definition == "hello")
        #expect(card.example == "Hallo, hoe gaat het?")
        #expect(card.article == "het")
        #expect(card.plural == "hallo's")
        #expect(card.timesShown == 0)
        #expect(card.timesCorrect == 0)
        #expect(card.successCount == 0)
        #expect(card.learningPercentage == nil) // No times shown yet
    }
    
    @Test func testFlashCardLearningPercentage() async throws {
        var card = FlashCard(word: "test", definition: "test")
        
        // Test with no times shown
        #expect(card.learningPercentage == nil)
        
        // Test with some correct answers
        card.timesShown = 10
        card.timesCorrect = 7
        #expect(card.learningPercentage == 70)
        
        // Test with all correct
        card.timesCorrect = 10
        #expect(card.learningPercentage == 100)
        
        // Test with no correct
        card.timesCorrect = 0
        #expect(card.learningPercentage == 0)
    }
    
    @Test func testFlashCardIsFullyLearned() async throws {
        var card = FlashCard(word: "test", definition: "test")
        
        // Test not fully learned
        card.timesCorrect = 3
        #expect(card.isFullyLearned == false)
        
        // Test fully learned
        card.timesCorrect = 5
        #expect(card.isFullyLearned == true)
        
        // Test more than fully learned
        card.timesCorrect = 10
        #expect(card.isFullyLearned == true)
    }
    
    @Test func testFlashCardMarkAsModified() async throws {
        var card = FlashCard(word: "test", definition: "test")
        let originalDate = card.lastModified
        
        // Wait a bit to ensure time difference
        try await Task.sleep(nanoseconds: 1_000_000) // 1ms
        
        card.markAsModified()
        #expect(card.lastModified > originalDate)
    }
    
    @Test func testFlashCardEquality() async throws {
        let id = UUID()
        let card1 = FlashCard(word: "test", definition: "test", cardId: id)
        let card2 = FlashCard(word: "different", definition: "different", cardId: id)
        let card3 = FlashCard(word: "test", definition: "test", cardId: UUID())
        
        #expect(card1 == card2) // Same ID
        #expect(card1 != card3) // Different ID
    }
    
    // MARK: - Deck Model Tests
    
    @Test func testDeckInitialization() async throws {
        let deck = Deck(name: "Test Deck")
        
        #expect(deck.name == "Test Deck")
        #expect(deck.cards.isEmpty)
        #expect(deck.parentId == nil)
        #expect(deck.subDeckIds.isEmpty)
        #expect(deck.isSubDeck == false)
        #expect(deck.displayName == "Test Deck")
    }
    
    @Test func testDeckWithParent() async throws {
        let parentId = UUID()
        let deck = Deck(name: "Sub Deck", parentId: parentId)
        
        #expect(deck.parentId == parentId)
        #expect(deck.isSubDeck == true)
    }
    
    @Test func testDeckEquality() async throws {
        let id = UUID()
        let deck1 = Deck(name: "Test", cards: [], parentId: nil)
        deck1.id = id
        let deck2 = Deck(name: "Different", cards: [], parentId: UUID())
        deck2.id = id
        let deck3 = Deck(name: "Test", cards: [], parentId: nil)
        deck3.id = UUID()
        
        #expect(deck1 == deck2) // Same ID
        #expect(deck1 != deck3) // Different ID
    }
    
    @Test func testDeckMarkAsModified() async throws {
        var deck = Deck(name: "Test")
        let originalDate = deck.lastModified
        
        // Wait a bit to ensure time difference
        try await Task.sleep(nanoseconds: 1_000_000) // 1ms
        
        deck.markAsModified()
        #expect(deck.lastModified > originalDate)
    }
    
    // MARK: - FlashCardViewModel Tests
    
    @Test func testViewModelInitialization() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization to complete
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Check that system decks were created
        let deckNames = viewModel.decks.map { $0.name }
        #expect(deckNames.contains("Uncategorized"))
        #expect(deckNames.contains("Learnt"))
        #expect(deckNames.contains("Learning"))
        #expect(deckNames.contains("Review"))
        
        // Check that example cards were created if no cards existed
        #expect(viewModel.flashCards.count > 0)
    }
    
    @Test func testAddCard() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        let initialCount = viewModel.flashCards.count
        
        // Add a new card
        viewModel.addCard(
            word: "nieuwe",
            definition: "new",
            example: "Dit is een nieuwe auto.",
            deckIds: []
        )
        
        #expect(viewModel.flashCards.count == initialCount + 1)
        
        let newCard = viewModel.flashCards.last
        #expect(newCard?.word == "nieuwe")
        #expect(newCard?.definition == "new")
        #expect(newCard?.example == "Dit is een nieuwe auto.")
    }
    
    @Test func testCreateDeck() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        let initialCount = viewModel.decks.count
        
        // Create a new deck
        let newDeck = viewModel.createDeck(name: "Test Deck")
        
        #expect(viewModel.decks.count == initialCount + 1)
        #expect(newDeck.name == "Test Deck")
        #expect(viewModel.decks.contains { $0.id == newDeck.id })
    }
    
    @Test func testDeleteCard() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        let initialCount = viewModel.flashCards.count
        guard let firstCard = viewModel.flashCards.first else {
            throw TestError("No cards available for testing")
        }
        
        // Delete the first card
        viewModel.deleteCard(firstCard)
        
        #expect(viewModel.flashCards.count == initialCount - 1)
        #expect(!viewModel.flashCards.contains { $0.id == firstCard.id })
    }
    
    @Test func testDeleteDeck() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Create a test deck
        let testDeck = viewModel.createDeck(name: "Test Deck")
        let initialCount = viewModel.decks.count
        
        // Delete the deck
        viewModel.deleteDeck(testDeck)
        
        #expect(viewModel.decks.count == initialCount - 1)
        #expect(!viewModel.decks.contains { $0.id == testDeck.id })
    }
    
    @Test func testUpdateCard() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        guard let firstCard = viewModel.flashCards.first else {
            throw TestError("No cards available for testing")
        }
        
        var updatedCard = firstCard
        updatedCard.word = "updated"
        updatedCard.definition = "updated definition"
        
        viewModel.updateCard(updatedCard)
        
        let foundCard = viewModel.flashCards.first { $0.id == firstCard.id }
        #expect(foundCard?.word == "updated")
        #expect(foundCard?.definition == "updated definition")
    }
    
    @Test func testUpdateDeck() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Create a test deck
        let testDeck = viewModel.createDeck(name: "Original Name")
        
        var updatedDeck = testDeck
        updatedDeck.name = "Updated Name"
        
        viewModel.updateDeck(updatedDeck)
        
        let foundDeck = viewModel.decks.first { $0.id == testDeck.id }
        #expect(foundDeck?.name == "Updated Name")
    }
    
    @Test func testCardStatusTracking() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        guard let firstCard = viewModel.flashCards.first else {
            throw TestError("No cards available for testing")
        }
        
        // Test marking card as known
        viewModel.markCardAsKnown(firstCard)
        #expect(viewModel.getCardStatus(firstCard) == .known)
        
        // Test marking card as unknown
        viewModel.markCardAsUnknown(firstCard)
        #expect(viewModel.getCardStatus(firstCard) == .unknown)
    }
    
    @Test func testCardStatistics() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        guard let firstCard = viewModel.flashCards.first else {
            throw TestError("No cards available for testing")
        }
        
        // Test recording correct answer
        viewModel.recordCorrectAnswer(for: firstCard)
        
        let updatedCard = viewModel.flashCards.first { $0.id == firstCard.id }
        #expect(updatedCard?.timesShown == 1)
        #expect(updatedCard?.timesCorrect == 1)
        #expect(updatedCard?.learningPercentage == 100)
        
        // Test recording incorrect answer
        viewModel.recordIncorrectAnswer(for: firstCard)
        
        let finalCard = viewModel.flashCards.first { $0.id == firstCard.id }
        #expect(finalCard?.timesShown == 2)
        #expect(finalCard?.timesCorrect == 1)
        #expect(finalCard?.learningPercentage == 50)
    }
    
    @Test func testDeckCardAssociation() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Create a test deck
        let testDeck = viewModel.createDeck(name: "Test Deck")
        
        // Add a card to the deck
        let card = viewModel.addCard(
            word: "test",
            definition: "test",
            example: "test example",
            deckIds: [testDeck.id]
        )
        
        #expect(card.deckIds.contains(testDeck.id))
        
        // Check that the deck contains the card
        let deckCards = viewModel.getCardsForDeck(testDeck)
        #expect(deckCards.contains { $0.id == card.id })
    }
    
    @Test func testSearchFunctionality() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Add a specific test card
        viewModel.addCard(
            word: "specifieke",
            definition: "specific",
            example: "Dit is een specifieke test.",
            deckIds: []
        )
        
        // Test search by word
        let wordResults = viewModel.searchCards(query: "specifieke")
        #expect(wordResults.count > 0)
        #expect(wordResults.contains { $0.word.contains("specifieke") })
        
        // Test search by definition
        let definitionResults = viewModel.searchCards(query: "specific")
        #expect(definitionResults.count > 0)
        #expect(definitionResults.contains { $0.definition.contains("specific") })
    }
    
    @Test func testCloudKitIntegration() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Test CloudKit sync state
        #expect(viewModel.isCloudSyncEnabled == false) // Default should be false
        
        // Test enabling CloudKit sync
        viewModel.isCloudSyncEnabled = true
        #expect(viewModel.isCloudSyncEnabled == true)
        
        // Test disabling CloudKit sync
        viewModel.isCloudSyncEnabled = false
        #expect(viewModel.isCloudSyncEnabled == false)
    }
    
    @Test func testDataPersistence() async throws {
        let viewModel1 = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Add a test card
        let testCard = viewModel1.addCard(
            word: "persistent",
            definition: "persistent",
            example: "This should persist",
            deckIds: []
        )
        
        // Create a new view model instance (simulating app restart)
        let viewModel2 = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Check that the card persisted
        let persistedCard = viewModel2.flashCards.first { $0.word == "persistent" }
        #expect(persistedCard != nil)
        #expect(persistedCard?.definition == "persistent")
    }
    
    // MARK: - Integration Tests
    
    @Test func testCompleteWorkflow() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // 1. Create a deck
        let deck = viewModel.createDeck(name: "Workflow Test")
        
        // 2. Add cards to the deck
        let card1 = viewModel.addCard(
            word: "workflow",
            definition: "workflow",
            example: "Testing workflow",
            deckIds: [deck.id]
        )
        
        let card2 = viewModel.addCard(
            word: "integration",
            definition: "integration",
            example: "Integration test",
            deckIds: [deck.id]
        )
        
        // 3. Verify deck contains cards
        let deckCards = viewModel.getCardsForDeck(deck)
        #expect(deckCards.count >= 2)
        #expect(deckCards.contains { $0.id == card1.id })
        #expect(deckCards.contains { $0.id == card2.id })
        
        // 4. Test learning workflow
        viewModel.recordCorrectAnswer(for: card1)
        viewModel.recordIncorrectAnswer(for: card2)
        
        let updatedCard1 = viewModel.flashCards.first { $0.id == card1.id }
        let updatedCard2 = viewModel.flashCards.first { $0.id == card2.id }
        
        #expect(updatedCard1?.timesShown == 1)
        #expect(updatedCard1?.timesCorrect == 1)
        #expect(updatedCard2?.timesShown == 1)
        #expect(updatedCard2?.timesCorrect == 0)
        
        // 5. Test card status
        viewModel.markCardAsKnown(card1)
        viewModel.markCardAsUnknown(card2)
        
        #expect(viewModel.getCardStatus(card1) == .known)
        #expect(viewModel.getCardStatus(card2) == .unknown)
        
        // 6. Test search
        let searchResults = viewModel.searchCards(query: "workflow")
        #expect(searchResults.contains { $0.id == card1.id })
        
        // 7. Test update
        var updatedCard = card1
        updatedCard.word = "updated workflow"
        viewModel.updateCard(updatedCard)
        
        let finalCard = viewModel.flashCards.first { $0.id == card1.id }
        #expect(finalCard?.word == "updated workflow")
        
        // 8. Test deletion
        viewModel.deleteCard(card2)
        #expect(!viewModel.flashCards.contains { $0.id == card2.id })
    }
    
    @Test func testErrorHandling() async throws {
        let viewModel = FlashCardViewModel()
        
        // Wait for initialization
        try await Task.sleep(nanoseconds: 100_000_000) // 100ms
        
        // Test with empty strings
        let emptyCard = viewModel.addCard(
            word: "",
            definition: "",
            example: "",
            deckIds: []
        )
        
        #expect(emptyCard.word.isEmpty)
        #expect(emptyCard.definition.isEmpty)
        
        // Test with very long strings
        let longWord = String(repeating: "a", count: 1000)
        let longCard = viewModel.addCard(
            word: longWord,
            definition: "test",
            example: "test",
            deckIds: []
        )
        
        #expect(longCard.word == longWord)
        
        // Test deck with empty name
        let emptyDeck = viewModel.createDeck(name: "")
        #expect(emptyDeck.name.isEmpty)
    }
}

// MARK: - Helper Types

struct TestError: Error, CustomStringConvertible {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var description: String {
        return message
    }
}
