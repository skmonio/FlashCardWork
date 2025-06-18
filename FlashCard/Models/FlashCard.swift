import Foundation
import CloudKit

struct FlashCard: Identifiable, Codable, Hashable {
    var id = UUID()
    var word: String
    var definition: String // Translation
    var example: String
    var deckIds: Set<UUID>
    var successCount: Int = 0
    var dateCreated: Date = Date()
    var lastModified: Date = Date()
    
    // CloudKit tracking (stored as string to avoid serialization issues)
    var cloudKitRecordName: String?
    
    // Learning statistics
    var timesShown: Int = 0
    var timesCorrect: Int = 0
    
    // Additional grammatical fields
    var article: String = "" // "het" or "de" for nouns
    var plural: String = "" // Plural form for nouns
    var pastTense: String = "" // Past tense form
    var futureTense: String = "" // Future tense form
    var pastParticiple: String = "" // Past participle form
    
    // Computed property for learning percentage
    var learningPercentage: Int? {
        guard timesShown > 0 else { return nil }
        return Int((Double(timesCorrect) / Double(timesShown)) * 100)
    }
    
    // Check if card is fully learned (5+ correct answers)
    var isFullyLearned: Bool {
        return timesCorrect >= 5
    }
    
    init(word: String = "", definition: String = "", example: String = "", deckIds: Set<UUID> = [], article: String = "", plural: String = "", pastTense: String = "", futureTense: String = "", pastParticiple: String = "", cardId: UUID? = nil, dateCreated: Date? = nil) {
        if let cardId = cardId {
            self.id = cardId
        }
        self.word = word
        self.definition = definition
        self.example = example
        self.deckIds = deckIds
        self.article = article
        self.plural = plural
        self.pastTense = pastTense
        self.futureTense = futureTense
        self.pastParticiple = pastParticiple
        self.successCount = 0
        self.timesShown = 0
        self.timesCorrect = 0
        self.dateCreated = dateCreated ?? Date()
        self.lastModified = Date()
    }
    
    // Migration initializer to handle old cards
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        word = try container.decode(String.self, forKey: .word)
        definition = try container.decode(String.self, forKey: .definition)
        example = try container.decode(String.self, forKey: .example)
        deckIds = try container.decode(Set<UUID>.self, forKey: .deckIds)
        successCount = try container.decodeIfPresent(Int.self, forKey: .successCount) ?? 0
        dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated) ?? Date()
        lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified) ?? Date()
        timesShown = try container.decodeIfPresent(Int.self, forKey: .timesShown) ?? 0
        timesCorrect = try container.decodeIfPresent(Int.self, forKey: .timesCorrect) ?? 0
        
        // CloudKit properties
        cloudKitRecordName = try container.decodeIfPresent(String.self, forKey: .cloudKitRecordName)
        
        // Handle new fields with defaults for backward compatibility
        article = try container.decodeIfPresent(String.self, forKey: .article) ?? ""
        plural = try container.decodeIfPresent(String.self, forKey: .plural) ?? ""
        pastTense = try container.decodeIfPresent(String.self, forKey: .pastTense) ?? ""
        futureTense = try container.decodeIfPresent(String.self, forKey: .futureTense) ?? ""
        pastParticiple = try container.decodeIfPresent(String.self, forKey: .pastParticiple) ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, word, definition, example, deckIds, successCount, dateCreated, lastModified
        case timesShown, timesCorrect, article, plural, pastTense, futureTense, pastParticiple
        case cloudKitRecordName
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: FlashCard, rhs: FlashCard) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - CloudKit Support
    
    static let recordType = "FlashCard"
    
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
        record["word"] = word
        record["definition"] = definition
        record["example"] = example
        
        // Only set deckIds if it's not empty to avoid CloudKit empty array error
        let deckIdStrings = deckIds.map { $0.uuidString }
        if !deckIdStrings.isEmpty {
            record["deckIds"] = deckIdStrings
        }
        
        record["successCount"] = successCount
        record["dateCreated"] = dateCreated
        record["lastModified"] = lastModified
        record["timesShown"] = timesShown
        record["timesCorrect"] = timesCorrect
        record["article"] = article
        record["plural"] = plural
        record["pastTense"] = pastTense
        record["futureTense"] = futureTense
        record["pastParticiple"] = pastParticiple
        
        return record
    }
    
    // Create from CloudKit record
    static func fromCKRecord(_ record: CKRecord) -> FlashCard? {
        guard let idString = record["id"] as? String,
              let id = UUID(uuidString: idString),
              let word = record["word"] as? String,
              let definition = record["definition"] as? String,
              let example = record["example"] as? String else {
            return nil
        }
        
        var card = FlashCard(
            word: word,
            definition: definition,
            example: example,
            cardId: id
        )
        
        // Restore deck IDs (field might not exist if it was empty)
        if let deckIdStrings = record["deckIds"] as? [String] {
            card.deckIds = Set(deckIdStrings.compactMap { UUID(uuidString: $0) })
        } else {
            card.deckIds = [] // Default to empty set if field doesn't exist
        }
        
        // Restore other properties
        card.successCount = record["successCount"] as? Int ?? 0
        card.dateCreated = record["dateCreated"] as? Date ?? Date()
        card.lastModified = record["lastModified"] as? Date ?? Date()
        card.timesShown = record["timesShown"] as? Int ?? 0
        card.timesCorrect = record["timesCorrect"] as? Int ?? 0
        card.article = record["article"] as? String ?? ""
        card.plural = record["plural"] as? String ?? ""
        card.pastTense = record["pastTense"] as? String ?? ""
        card.futureTense = record["futureTense"] as? String ?? ""
        card.pastParticiple = record["pastParticiple"] as? String ?? ""
        
        // Store CloudKit metadata
        card.cloudKitRecordName = record.recordID.recordName
        
        return card
    }
    
    // Update lastModified when card changes
    mutating func markAsModified() {
        lastModified = Date()
    }
} 