//
//  ModelTests.swift
//  FlashCardTests
//
//  Created by Stephen Cook on 04/06/2025.
//

import Testing
import Foundation
import CloudKit
@testable import FlashCard

struct ModelTests {
    
    // MARK: - FlashCard Model Tests
    
    @Test func testFlashCardCoding() async throws {
        let originalCard = FlashCard(
            word: "test",
            definition: "test definition",
            example: "test example",
            deckIds: [UUID(), UUID()],
            article: "het",
            plural: "tests",
            pastTense: "tested",
            futureTense: "will test",
            pastParticiple: "tested"
        )
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalCard)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedCard = try decoder.decode(FlashCard.self, from: data)
        
        #expect(decodedCard.word == originalCard.word)
        #expect(decodedCard.definition == originalCard.definition)
        #expect(decodedCard.example == originalCard.example)
        #expect(decodedCard.deckIds == originalCard.deckIds)
        #expect(decodedCard.article == originalCard.article)
        #expect(decodedCard.plural == originalCard.plural)
        #expect(decodedCard.pastTense == originalCard.pastTense)
        #expect(decodedCard.futureTense == originalCard.futureTense)
        #expect(decodedCard.pastParticiple == originalCard.pastParticiple)
    }
    
    @Test func testFlashCardCloudKitConversion() async throws {
        let originalCard = FlashCard(
            word: "cloudkit",
            definition: "cloud kit",
            example: "Testing CloudKit",
            deckIds: [UUID()],
            article: "het",
            plural: "cloudkits"
        )
        
        // Convert to CloudKit record
        let record = originalCard.toCKRecord()
        
        #expect(record.recordType == "FlashCard")
        #expect(record["word"] as? String == "cloudkit")
        #expect(record["definition"] as? String == "cloud kit")
        #expect(record["example"] as? String == "Testing CloudKit")
        #expect(record["article"] as? String == "het")
        #expect(record["plural"] as? String == "cloudkits")
        
        // Convert back from CloudKit record
        let convertedCard = FlashCard.fromCKRecord(record)
        
        #expect(convertedCard != nil)
        #expect(convertedCard?.word == originalCard.word)
        #expect(convertedCard?.definition == originalCard.definition)
        #expect(convertedCard?.example == originalCard.example)
        #expect(convertedCard?.article == originalCard.article)
        #expect(convertedCard?.plural == originalCard.plural)
        #expect(convertedCard?.cloudKitRecordName == record.recordID.recordName)
    }
    
    @Test func testFlashCardWithExistingCloudKitRecord() async throws {
        let recordName = "test-record-name"
        var card = FlashCard(word: "test", definition: "test")
        card.cloudKitRecordName = recordName
        
        let record = card.toCKRecord()
        #expect(record.recordID.recordName == recordName)
    }
    
    @Test func testFlashCardEmptyDeckIds() async throws {
        let card = FlashCard(word: "test", definition: "test", deckIds: [])
        
        let record = card.toCKRecord()
        #expect(record["deckIds"] == nil) // Should not be set for empty arrays
        
        // Test conversion back
        let convertedCard = FlashCard.fromCKRecord(record)
        #expect(convertedCard?.deckIds.isEmpty == true)
    }
    
    // MARK: - Deck Model Tests
    
    @Test func testDeckCoding() async throws {
        let parentId = UUID()
        var originalDeck = Deck(name: "Test Deck")
        originalDeck.parentId = parentId
        originalDeck.subDeckIds = [UUID(), UUID()]
        
        // Test encoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalDeck)
        
        // Test decoding
        let decoder = JSONDecoder()
        let decodedDeck = try decoder.decode(Deck.self, from: data)
        
        #expect(decodedDeck.name == originalDeck.name)
        #expect(decodedDeck.parentId == originalDeck.parentId)
        #expect(decodedDeck.subDeckIds == originalDeck.subDeckIds)
    }
    
    @Test func testDeckCloudKitConversion() async throws {
        let parentId = UUID()
        var originalDeck = Deck(name: "CloudKit Test")
        originalDeck.parentId = parentId
        originalDeck.subDeckIds = [UUID()]
        
        // Convert to CloudKit record
        let record = originalDeck.toCKRecord()
        
        #expect(record.recordType == "Deck")
        #expect(record["name"] as? String == "CloudKit Test")
        #expect(record["parentId"] as? String == parentId.uuidString)
        
        // Convert back from CloudKit record
        let convertedDeck = Deck.fromCKRecord(record)
        
        #expect(convertedDeck != nil)
        #expect(convertedDeck?.name == originalDeck.name)
        #expect(convertedDeck?.parentId == originalDeck.parentId)
        #expect(convertedDeck?.subDeckIds == originalDeck.subDeckIds)
        #expect(convertedDeck?.cloudKitRecordName == record.recordID.recordName)
    }
    
    @Test func testDeckWithExistingCloudKitRecord() async throws {
        let recordName = "deck-record-name"
        var deck = Deck(name: "Test")
        deck.cloudKitRecordName = recordName
        
        let record = deck.toCKRecord()
        #expect(record.recordID.recordName == recordName)
    }
    
    @Test func testDeckEmptySubDeckIds() async throws {
        var deck = Deck(name: "Test")
        deck.subDeckIds = []
        
        let record = deck.toCKRecord()
        #expect(record["subDeckIds"] == nil) // Should not be set for empty arrays
        
        // Test conversion back
        let convertedDeck = Deck.fromCKRecord(record)
        #expect(convertedDeck?.subDeckIds.isEmpty == true)
    }
    
    // MARK: - CardEntry Model Tests
    
    @Test func testCardEntryInitialization() async throws {
        let entry = CardEntry(word: "test", definition: "test definition")
        
        #expect(entry.word == "test")
        #expect(entry.definition == "test definition")
    }
    
    // MARK: - Edge Cases and Error Handling
    
    @Test func testFlashCardInvalidCloudKitRecord() async throws {
        let record = CKRecord(recordType: "FlashCard")
        // Don't set required fields
        
        let convertedCard = FlashCard.fromCKRecord(record)
        #expect(convertedCard == nil) // Should fail to convert
    }
    
    @Test func testDeckInvalidCloudKitRecord() async throws {
        let record = CKRecord(recordType: "Deck")
        // Don't set required fields
        
        let convertedDeck = Deck.fromCKRecord(record)
        #expect(convertedDeck == nil) // Should fail to convert
    }
    
    @Test func testFlashCardInvalidUUID() async throws {
        let record = CKRecord(recordType: "FlashCard")
        record["id"] = "invalid-uuid"
        record["word"] = "test"
        record["definition"] = "test"
        record["example"] = "test"
        
        let convertedCard = FlashCard.fromCKRecord(record)
        #expect(convertedCard == nil) // Should fail due to invalid UUID
    }
    
    @Test func testDeckInvalidUUID() async throws {
        let record = CKRecord(recordType: "Deck")
        record["id"] = "invalid-uuid"
        record["name"] = "test"
        
        let convertedDeck = Deck.fromCKRecord(record)
        #expect(convertedDeck == nil) // Should fail due to invalid UUID
    }
    
    @Test func testFlashCardInvalidDeckIds() async throws {
        let record = CKRecord(recordType: "FlashCard")
        record["id"] = UUID().uuidString
        record["word"] = "test"
        record["definition"] = "test"
        record["example"] = "test"
        record["deckIds"] = ["invalid-uuid", UUID().uuidString] // Mix of valid and invalid
        
        let convertedCard = FlashCard.fromCKRecord(record)
        #expect(convertedCard != nil) // Should succeed but filter out invalid UUIDs
        #expect(convertedCard?.deckIds.count == 1) // Only valid UUID should remain
    }
    
    @Test func testDeckInvalidSubDeckIds() async throws {
        let record = CKRecord(recordType: "Deck")
        record["id"] = UUID().uuidString
        record["name"] = "test"
        record["subDeckIds"] = ["invalid-uuid", UUID().uuidString] // Mix of valid and invalid
        
        let convertedDeck = Deck.fromCKRecord(record)
        #expect(convertedDeck != nil) // Should succeed but filter out invalid UUIDs
        #expect(convertedDeck?.subDeckIds.count == 1) // Only valid UUID should remain
    }
    
    // MARK: - Performance Tests
    
    @Test func testFlashCardPerformance() async throws {
        let startTime = Date()
        
        // Create many cards
        for i in 0..<1000 {
            _ = FlashCard(
                word: "word\(i)",
                definition: "definition\(i)",
                example: "example\(i)",
                deckIds: [UUID()]
            )
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        #expect(duration < 1.0) // Should complete in less than 1 second
    }
    
    @Test func testDeckPerformance() async throws {
        let startTime = Date()
        
        // Create many decks
        for i in 0..<1000 {
            _ = Deck(name: "deck\(i)")
        }
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        #expect(duration < 1.0) // Should complete in less than 1 second
    }
} 