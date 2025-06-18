import Foundation
import CloudKit

struct Deck: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var cards: [FlashCard]
    var parentId: UUID? = nil       // Parent deck ID for sub-decks
    var subDeckIds: Set<UUID> = []  // Child deck IDs
    var dateCreated: Date = Date()
    var lastModified: Date = Date()
    
    // CloudKit tracking (stored as string to avoid serialization issues)
    var cloudKitRecordName: String?
    
    init(name: String, cards: [FlashCard] = [], parentId: UUID? = nil) {
        self.name = name
        self.cards = cards
        self.parentId = parentId
        self.subDeckIds = []
        self.dateCreated = Date()
        self.lastModified = Date()
    }
    
    // Helper computed properties
    var isSubDeck: Bool {
        return parentId != nil
    }
    
    var displayName: String {
        return name
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Deck, rhs: Deck) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - CloudKit Support
    
    static let recordType = "Deck"
    
    // Convert to CloudKit record
    func toCKRecord() -> CKRecord {
        let record: CKRecord
        
        if let recordName = cloudKitRecordName {
            let recordID = CKRecord.ID(recordName: recordName)
            record = CKRecord(recordType: Self.recordType, recordID: recordID)
        } else {
            record = CKRecord(recordType: Self.recordType)
        }
        
        record["id"] = id.uuidString
        record["name"] = name
        record["parentId"] = parentId?.uuidString
        
        // Only set subDeckIds if it's not empty to avoid CloudKit empty array error
        let subDeckIdStrings = subDeckIds.map { $0.uuidString }
        if !subDeckIdStrings.isEmpty {
            record["subDeckIds"] = subDeckIdStrings
        }
        
        record["dateCreated"] = dateCreated
        record["lastModified"] = lastModified
        
        return record
    }
    
    // Create from CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> Deck? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let name = record["name"] as? String else {
            return nil
        }
        
        var deck = Deck(name: name)
        deck.id = id
        
        // Restore parent ID
        if let parentIdString = record["parentId"] as? String {
            deck.parentId = UUID(uuidString: parentIdString)
        }
        
        // Restore sub-deck IDs (field might not exist if it was empty)
        if let subDeckIdStrings = record["subDeckIds"] as? [String] {
            deck.subDeckIds = Set(subDeckIdStrings.compactMap { UUID(uuidString: $0) })
        } else {
            deck.subDeckIds = [] // Default to empty set if field doesn't exist
        }
        
        deck.dateCreated = record["dateCreated"] as? Date ?? Date()
        deck.lastModified = record["lastModified"] as? Date ?? Date()
        
        // Store CloudKit metadata
        deck.cloudKitRecordName = record.recordID.recordName
        
        return deck
    }
    
    // Update lastModified when deck changes
    mutating func markAsModified() {
        lastModified = Date()
    }
} 