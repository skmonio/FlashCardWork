import Foundation
import CloudKit
import os

@MainActor
class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    private let container: CKContainer?
    private let database: CKDatabase?
    private let logger = Logger(subsystem: "com.flashcards.cloudkit", category: "CloudKitManager")
    
    @Published var syncStatus: SyncStatus = .unknown
    @Published var lastSyncDate: Date?
    @Published var isAccountAvailable = false
    
    // Retry mechanism for quota exceeded
    private var retryTimer: Timer?
    
    // Quota management
    private var quotaHitCount = 0
    private var lastQuotaHit: Date?
    private let quotaCooldownPeriod: TimeInterval = 600 // 10 minutes
    
    // Static simulator detection to avoid 'self' access during init
    private static var isRunningOnSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    // Instance property for convenience
    private var isRunningOnSimulator: Bool {
        Self.isRunningOnSimulator
    }
    
    enum SyncStatus {
        case unknown
        case syncing
        case success
        case error(String)
        case noAccount
        case offline
        case simulatorMode
        case idle
    }
    
    private init() {
        if Self.isRunningOnSimulator {
            // Disable CloudKit on simulator
            self.container = nil
            self.database = nil
            self.syncStatus = .simulatorMode
            self.isAccountAvailable = false
            logger.info("📱 Running on simulator - CloudKit disabled")
        } else {
            // Enable CloudKit on real device
            let container = CKContainer.default()
            self.container = container
            self.database = container.privateCloudDatabase
            logger.info("📱 Running on device - CloudKit enabled")
            
            // Check account status after initialization is complete
            Task {
                await checkAccountStatus()
            }
        }
    }
    
    // MARK: - Account Status
    
    func checkAccountStatus() async {
        guard !Self.isRunningOnSimulator, let container = container else {
            logger.info("📱 Skipping account check - simulator mode")
            return
        }
        
        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                switch status {
                case .available:
                    isAccountAvailable = true
                    syncStatus = .success
                    logger.info("✅ iCloud account available")
                case .noAccount:
                    isAccountAvailable = false
                    syncStatus = .noAccount
                    logger.info("⚠️ No iCloud account")
                case .restricted:
                    isAccountAvailable = false
                    syncStatus = .error("iCloud account restricted")
                    logger.warning("🔒 iCloud account restricted")
                case .couldNotDetermine:
                    isAccountAvailable = false
                    syncStatus = .error("Could not determine iCloud status")
                    logger.error("❓ Could not determine iCloud status")
                @unknown default:
                    isAccountAvailable = false
                    syncStatus = .error("Unknown iCloud status")
                    logger.error("❓ Unknown iCloud status")
                }
            }
        } catch {
            await MainActor.run {
                isAccountAvailable = false
                syncStatus = .error("Failed to check account: \(error.localizedDescription)")
            }
            logger.error("❌ Failed to check account status: \(error)")
        }
    }
    
    // MARK: - Sync Operations
    
    func syncData(flashCards: [FlashCard], decks: [Deck]) async -> (cards: [FlashCard], decks: [Deck]) {
        guard !isRunningOnSimulator else {
            logger.info("📱 Skipping sync - simulator mode")
            return (flashCards, decks)
        }
        
        guard isAccountAvailable else {
            logger.info("📵 Skipping sync - no iCloud account")
            return (flashCards, decks)
        }
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        do {
            // Check if this is a new device with no CloudKit data
            let isNewDevice = await checkIfNewDevice()
            
            if isNewDevice {
                logger.info("🆕 New device detected - performing initial download")
                return try await performInitialDownload()
            } else {
                logger.info("🔄 Existing device - performing bidirectional sync")
                return try await performBidirectionalSync(flashCards: flashCards, decks: decks)
            }
            
        } catch {
            await MainActor.run {
                if let ckError = error as? CKError, ckError.code == .quotaExceeded {
                    syncStatus = .error("CloudKit quota exceeded. Please try again in a few minutes.")
                } else {
                syncStatus = .error(error.localizedDescription)
                }
            }
            logger.error("❌ Sync failed: \(error)")
            return (flashCards, decks)
        }
    }
    
    // MARK: - New Device Detection
    
    private func checkIfNewDevice() async -> Bool {
        guard let database = database else { return false }
        
        do {
            // Quick check: try to fetch just one record of each type
            // Use a simple query that doesn't require special indexing
            let deckQuery = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
            let cardQuery = CKQuery(recordType: FlashCard.recordType, predicate: NSPredicate(value: true))
            
            let (deckResults, _) = try await database.records(matching: deckQuery, resultsLimit: 1)
            let (cardResults, _) = try await database.records(matching: cardQuery, resultsLimit: 1)
            
            let hasCloudData = !deckResults.isEmpty || !cardResults.isEmpty
            logger.info("🔍 CloudKit data check: hasCloudData=\(hasCloudData)")
            
            return !hasCloudData
        } catch {
            // Handle schema not existing yet (normal for new accounts)
            if let ckError = error as? CKError,
               ckError.code == .unknownItem || ckError.code == .invalidArguments {
                logger.info("🆕 No CloudKit schema found - treating as new device")
                return true // If schema doesn't exist, it's definitely a new device
            }
            
            // For other errors, assume it's not a new device to be safe (prefer bidirectional sync)
            logger.info("⚠️ Could not determine device status, assuming existing device: \(error)")
            return false
        }
    }
    
    // MARK: - Initial Download (New Device)
    
    private func performInitialDownload() async throws -> (cards: [FlashCard], decks: [Deck]) {
        guard let database = database else {
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        logger.info("📥 Starting initial download from CloudKit")
        
        var cloudDecks: [Deck] = []
        var cloudCards: [FlashCard] = []
        
        // Download all decks first
        do {
            let deckQuery = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
            let (deckResults, _) = try await database.records(matching: deckQuery)
            
            for (_, result) in deckResults {
                switch result {
                case .success(let record):
                    if let deck = Deck.fromCKRecord(record) {
                        cloudDecks.append(deck)
                    }
                case .failure(let error):
                    logger.warning("⚠️ Failed to download deck: \(error)")
                }
            }
            
            logger.info("📥 Downloaded \(cloudDecks.count) decks")
        } catch {
            if let ckError = error as? CKError, ckError.code == .unknownItem {
                logger.info("ℹ️ No decks found in CloudKit (new account)")
            } else {
                throw error
            }
        }
        
        // Download all cards
        do {
            let cardQuery = CKQuery(recordType: FlashCard.recordType, predicate: NSPredicate(value: true))
            let (cardResults, _) = try await database.records(matching: cardQuery)
            
            for (_, result) in cardResults {
                switch result {
                case .success(let record):
                    if let card = FlashCard.fromCKRecord(record) {
                        cloudCards.append(card)
                    }
                case .failure(let error):
                    logger.warning("⚠️ Failed to download card: \(error)")
                }
            }
            
            logger.info("📥 Downloaded \(cloudCards.count) cards")
        } catch {
            if let ckError = error as? CKError, ckError.code == .unknownItem {
                logger.info("ℹ️ No cards found in CloudKit (new account)")
            } else {
                throw error
            }
        }
        
        await MainActor.run {
            syncStatus = .success
            lastSyncDate = Date()
        }
        
        logger.info("✅ Initial download completed: \(cloudDecks.count) decks, \(cloudCards.count) cards")
        return (cloudCards, cloudDecks)
    }
    
    // MARK: - Bidirectional Sync (Existing Device)
    
    private func performBidirectionalSync(flashCards: [FlashCard], decks: [Deck]) async throws -> (cards: [FlashCard], decks: [Deck]) {
        // Sync decks first (cards depend on decks)
        let syncedDecks = try await syncDecks(localDecks: decks)
        
        // Then sync cards with smaller batches to avoid quota issues
        let syncedCards = try await syncCardsWithSmartBatching(localCards: flashCards)
        
        await MainActor.run {
            syncStatus = .success
            lastSyncDate = Date()
        }
        
        logger.info("✅ Bidirectional sync completed successfully")
        return (syncedCards, syncedDecks)
    }
    
    // MARK: - Deck Sync
    
    private func syncDecks(localDecks: [Deck]) async throws -> [Deck] {
        guard let database = database else { 
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        var cloudDecks: [Deck] = []
        var syncedDecks: [Deck] = localDecks
        
        // Fetch all deck records from CloudKit
        do {
            let query = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
            let (matchResults, _) = try await database.records(matching: query)
            
            // Convert CloudKit records to Deck objects
            for (recordID, result) in matchResults {
                switch result {
                case .success(let record):
                    if let deck = Deck.fromCKRecord(record) {
                        cloudDecks.append(deck)
                    } else {
                        logger.warning("⚠️ Failed to convert deck record: \(recordID)")
                    }
                case .failure(let error):
                    logger.error("❌ Failed to fetch deck record \(recordID): \(error)")
                }
            }
        } catch {
            // Handle "record type not found" error gracefully
            if let ckError = error as? CKError,
               ckError.code == .unknownItem || ckError.code == .invalidArguments {
                logger.info("ℹ️ Deck record type not found in CloudKit - will create schema on first upload")
                cloudDecks = []
            } else {
                throw error
            }
        }
        
        // Merge local and cloud decks
        syncedDecks = mergeDecks(local: localDecks, cloud: cloudDecks)
        
        // Upload new/modified local decks to CloudKit in batches
        let decksToUpload = syncedDecks.filter { deck in
            deck.cloudKitRecordName == nil || // New deck
            !cloudDecks.contains { $0.id == deck.id && $0.lastModified <= deck.lastModified }
        }
        
        if !decksToUpload.isEmpty {
            // Check if we should skip uploads due to recent quota hits
            if shouldSkipUploadDueToQuota() {
                logger.info("⏸️ Skipping deck uploads due to recent quota limits - will retry later")
                await MainActor.run {
                    syncStatus = .error("CloudKit quota limits active. Will retry automatically.")
                }
                return syncedDecks
            }
            
            // Upload in very small batches to avoid quota limits (especially for new accounts)
            let batchSize = min(2, decksToUpload.count) // Reduced to 2 decks at a time for better quota management
            logger.info("📤 Uploading \(decksToUpload.count) decks in batches of \(batchSize)")
            
            for (batchIndex, batch) in decksToUpload.chunked(into: batchSize).enumerated() {
                do {
                try await uploadDecks(batch)
                    logger.info("✅ Uploaded deck batch \(batchIndex + 1)")
                    
                    // Reset quota tracking on successful upload
                    resetQuotaTracking()
                    
                    // Longer delay between batches to be more CloudKit-friendly
                    if batchIndex < decksToUpload.chunked(into: batchSize).count - 1 {
                        try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds between batches
                    }
                } catch {
                    // Handle quota exceeded gracefully - don't fail entire sync
                    if let ckError = error as? CKError, ckError.code == .quotaExceeded {
                        recordQuotaHit()
                        logger.info("⏰ Deck upload quota reached - will retry later")
                        break // Stop uploading more decks for now
                    } else {
                        throw error // Re-throw other errors
                    }
                }
            }
        }
        
        logger.info("🔄 Synced \(syncedDecks.count) decks (\(decksToUpload.count) uploaded)")
        return syncedDecks
    }
    
    private func mergeDecks(local: [Deck], cloud: [Deck]) -> [Deck] {
        var merged: [UUID: Deck] = [:]
        
        // Start with local decks
        for deck in local {
            merged[deck.id] = deck
        }
        
        // Merge with cloud decks (cloud wins if newer)
        for cloudDeck in cloud {
            if let localDeck = merged[cloudDeck.id] {
                // Use the newer version
                if cloudDeck.lastModified > localDeck.lastModified {
                    var updatedDeck = cloudDeck
                    updatedDeck.cards = localDeck.cards // Keep local card associations
                    merged[cloudDeck.id] = updatedDeck
                }
            } else {
                // New deck from cloud
                merged[cloudDeck.id] = cloudDeck
            }
        }
        
        return Array(merged.values)
    }
    
    private func uploadDecks(_ decks: [Deck]) async throws {
        guard let database = database else { 
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        let records = decks.map { $0.toCKRecord() }
        
        do {
            let (saveResults, _) = try await database.modifyRecords(saving: records, deleting: [])
            
            var quotaExceededCount = 0
            
            for (recordID, result) in saveResults {
                switch result {
                case .success:
                    logger.debug("✅ Uploaded deck: \(recordID)")
                case .failure(let error):
                    // Handle quota exceeded error gracefully without throwing
                    if let ckError = error as? CKError, ckError.code == .quotaExceeded {
                        quotaExceededCount += 1
                        recordQuotaHit()
                        let retryAfter = ckError.retryAfterSeconds ?? 300
                        logger.info("⏰ Deck \(recordID) hit quota limit, will retry after \(retryAfter) seconds")
                        
                        // Schedule retry but don't block current operation
                        scheduleRetry(after: retryAfter)
                    } else {
                        logger.error("❌ Failed to upload deck \(recordID): \(error)")
                        throw error
                    }
                }
            }
            
            // If all uploads hit quota, update status but don't throw
            if quotaExceededCount == records.count {
                await MainActor.run {
                    syncStatus = .error("CloudKit quota exceeded. Will retry automatically.")
                }
                logger.info("⏰ All deck uploads hit quota - will retry later")
            }
            
        } catch {
            // Handle quota exceeded error gracefully
            if let ckError = error as? CKError, ckError.code == .quotaExceeded {
                recordQuotaHit()
                let retryAfter = ckError.retryAfterSeconds ?? 300
                logger.info("⏰ Deck batch upload quota exceeded, will retry after \(retryAfter) seconds")
                
                await MainActor.run {
                    syncStatus = .error("CloudKit quota exceeded. Will retry automatically.")
                }
                
                // Schedule retry but don't throw to allow app to continue working
                scheduleRetry(after: retryAfter)
                return // Don't throw, just return
            } else {
                throw error // Re-throw other errors
            }
        }
    }
    
    // MARK: - Card Sync
    
    private func syncCards(localCards: [FlashCard]) async throws -> [FlashCard] {
        // Use smart batching for large collections
        return try await syncCardsWithSmartBatching(localCards: localCards)
    }
    
    private func syncCardsWithSmartBatching(localCards: [FlashCard]) async throws -> [FlashCard] {
        guard let database = database else {
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        logger.info("🔄 Starting smart card sync with \(localCards.count) local cards")
        
        // Determine batch size based on collection size
        let batchSize = determineBatchSize(for: localCards.count)
        logger.info("📦 Using batch size: \(batchSize)")
        
        var allCloudCards: [FlashCard] = []
        var processedCount = 0
        
        // Process cards in batches to avoid quota limits
        let batches = localCards.chunked(into: batchSize)
        
        for (batchIndex, batch) in batches.enumerated() {
            logger.info("📦 Processing batch \(batchIndex + 1)/\(batches.count) (\(batch.count) cards)")
            
            do {
                let batchResults = try await syncCardBatch(batch)
                allCloudCards.append(contentsOf: batchResults)
                processedCount += batch.count
                
                // Add delay between batches to respect rate limits
                if batchIndex < batches.count - 1 {
                    let delay = calculateDelayBetweenBatches(batchSize: batchSize)
                    logger.info("⏳ Waiting \(delay)ms between batches...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000))
                }
                
            } catch let error as CKError where error.code == .quotaExceeded {
                logger.warning("⚠️ Quota exceeded in batch \(batchIndex + 1), implementing backoff...")
                
                // Exponential backoff for quota exceeded
                let backoffDelay = min(5000 * (batchIndex + 1), 30000) // Max 30 seconds
                try await Task.sleep(nanoseconds: UInt64(backoffDelay * 1_000_000))
                
                // Retry this batch with smaller size
                let smallerBatch = batch.prefix(max(1, batch.count / 2))
                let retryResults = try await syncCardBatch(Array(smallerBatch))
                allCloudCards.append(contentsOf: retryResults)
                
                // Handle remaining items in this batch
                let remainingItems = Array(batch.dropFirst(smallerBatch.count))
                if !remainingItems.isEmpty {
                    let remainingResults = try await syncCardBatch(remainingItems)
                    allCloudCards.append(contentsOf: remainingResults)
                }
                
                processedCount += batch.count
            }
        }
        
        logger.info("✅ Smart card sync completed: processed \(processedCount) cards, result \(allCloudCards.count) cards")
        return allCloudCards
    }
    
    private func syncCardBatch(_ cards: [FlashCard]) async throws -> [FlashCard] {
        guard let database = database else { 
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        // First, fetch existing cloud cards for this batch
        let cardIds = cards.map { $0.id.uuidString }
        let predicate = NSPredicate(format: "id IN %@", cardIds)
        let query = CKQuery(recordType: FlashCard.recordType, predicate: predicate)
        
        var cloudCards: [FlashCard] = []
        var cloudCardDict: [UUID: FlashCard] = [:]

        do {
            let (results, _) = try await database.records(matching: query)
            
            for (_, result) in results {
                switch result {
                case .success(let record):
                    if let card = FlashCard.fromCKRecord(record) {
                        cloudCards.append(card)
                        cloudCardDict[card.id] = card
                    }
                case .failure(let error):
                    logger.warning("⚠️ Failed to fetch card: \(error)")
                }
            }
        } catch {
            // If fetch fails, continue with upload only
            logger.warning("⚠️ Failed to fetch existing cards, continuing with upload: \(error)")
        }
        
        // Determine which cards need to be uploaded
        var cardsToUpload: [FlashCard] = []
        
        for localCard in cards {
            if let cloudCard = cloudCardDict[localCard.id] {
                // Compare modification dates
                if localCard.lastModified > cloudCard.lastModified {
                    cardsToUpload.append(localCard)
                }
            } else {
                // New card, needs to be uploaded
                cardsToUpload.append(localCard)
            }
        }
        
        // Upload cards that need updating
        if !cardsToUpload.isEmpty {
            logger.info("📤 Uploading \(cardsToUpload.count) cards in this batch")
            
            let recordsToSave = cardsToUpload.map { $0.toCKRecord() }
            let (saveResults, _) = try await database.modifyRecords(saving: recordsToSave, deleting: [])
            
            // Process save results
            for (recordID, result) in saveResults {
                switch result {
                case .success(let record):
                    if let updatedCard = FlashCard.fromCKRecord(record) {
                        // Update the cloud cards array
                        if let existingIndex = cloudCards.firstIndex(where: { $0.id == updatedCard.id }) {
                            cloudCards[existingIndex] = updatedCard
                        } else {
                            cloudCards.append(updatedCard)
                        }
                    }
                case .failure(let error):
                    logger.error("❌ Failed to save card \(recordID): \(error)")
                }
            }
        }
        
        // Return all cards for this batch (both existing and newly uploaded)
        var resultCards = cloudCards
        
        // Add any local cards that weren't in the cloud and couldn't be uploaded
        for localCard in cards {
            if !resultCards.contains(where: { $0.id == localCard.id }) {
                resultCards.append(localCard)
            }
        }
        
        return resultCards
    }
    
    // MARK: - Batch Size Optimization
    
    private func determineBatchSize(for totalCount: Int) -> Int {
        switch totalCount {
        case 0...10:
            return totalCount // Process all at once for small collections
        case 11...50:
            return 10 // Small batches for medium collections
        case 51...200:
            return 15 // Slightly larger batches
        case 201...500:
            return 20 // Medium batches for large collections
        default:
            return 25 // Conservative batch size for very large collections
        }
    }
    
    private func calculateDelayBetweenBatches(batchSize: Int) -> Int {
        // Calculate delay in milliseconds based on batch size
        // Larger batches need longer delays to respect rate limits
        switch batchSize {
        case 1...5:
            return 500 // 0.5 seconds
        case 6...15:
            return 1000 // 1 second
        case 16...25:
            return 2000 // 2 seconds
        default:
            return 3000 // 3 seconds
        }
    }
    
    // MARK: - Individual Operations
    
    func uploadCard(_ card: FlashCard) async throws -> FlashCard {
        guard !isRunningOnSimulator else { return card }
        guard isAccountAvailable else { return card }
        guard let database = database else { return card }
        
        let record = card.toCKRecord()
        let savedRecord = try await database.save(record)
        
        var updatedCard = card
        updatedCard.cloudKitRecordName = savedRecord.recordID.recordName
        
        logger.debug("✅ Uploaded individual card: \(card.word)")
        return updatedCard
    }
    
    func uploadDeck(_ deck: Deck) async throws -> Deck {
        guard !isRunningOnSimulator else { return deck }
        guard isAccountAvailable else { return deck }
        guard let database = database else { return deck }
        
        let record = deck.toCKRecord()
        let savedRecord = try await database.save(record)
        
        var updatedDeck = deck
        updatedDeck.cloudKitRecordName = savedRecord.recordID.recordName
        
        logger.debug("✅ Uploaded individual deck: \(deck.name)")
        return updatedDeck
    }
    
    func deleteCard(_ card: FlashCard) async throws {
        guard !isRunningOnSimulator else { return }
        guard isAccountAvailable, let recordName = card.cloudKitRecordName else { return }
        guard let database = database else { return }
        
        let recordID = CKRecord.ID(recordName: recordName)
        try await database.deleteRecord(withID: recordID)
        logger.debug("🗑️ Deleted card from CloudKit: \(card.word)")
    }
    
    func deleteDeck(_ deck: Deck) async throws {
        guard !isRunningOnSimulator else { return }
        guard isAccountAvailable, let recordName = deck.cloudKitRecordName else { return }
        guard let database = database else { return }
        
        let recordID = CKRecord.ID(recordName: recordName)
        try await database.deleteRecord(withID: recordID)
        logger.debug("🗑️ Deleted deck from CloudKit: \(deck.name)")
    }
    
    // MARK: - Utility Methods
    
    func validateSchema() async throws {
        guard let database = database else { 
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        // Test if we can query both record types with a simple predicate
        let deckQuery = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
        let cardQuery = CKQuery(recordType: FlashCard.recordType, predicate: NSPredicate(value: true))
        
        // Try a simple query with limit 1 to test schema
        do {
            _ = try await database.records(matching: deckQuery, resultsLimit: 1)
            _ = try await database.records(matching: cardQuery, resultsLimit: 1)
            logger.info("✅ CloudKit schema validation passed")
        } catch {
            // Handle schema not existing yet (which is normal for new accounts)
            if let ckError = error as? CKError,
               ckError.code == .unknownItem || ckError.code == .invalidArguments {
                logger.info("ℹ️ CloudKit schema not found - will be created on first upload")
                return // Don't throw error for missing schema
            }
            
            logger.error("❌ CloudKit schema validation failed: \(error)")
            throw error
        }
    }
    
    var statusMessage: String {
        switch syncStatus {
        case .unknown:
            return "Checking sync status..."
        case .syncing:
            return "Syncing with iCloud..."
        case .success:
            if let date = lastSyncDate {
                return "Last synced: \(formatDate(date))"
            } else {
                return "Sync ready"
            }
        case .error(let message):
            return "Sync error: \(message)"
        case .noAccount:
            return "Sign in to iCloud in Settings to sync"
        case .offline:
            return "Offline - will sync when connected"
        case .simulatorMode:
            return "Simulator mode - CloudKit disabled"
        case .idle:
            return "Ready for retry"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Retry Management
    
    private func scheduleRetry(after seconds: TimeInterval) {
        logger.info("⏰ Scheduling retry in \(seconds) seconds")
        
        Task {
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            
            await MainActor.run {
                // Reset status to allow retry
                if case .error = syncStatus {
                    syncStatus = .idle
                    logger.info("🔄 Ready for retry after quota limit")
                }
            }
        }
    }
    
    // MARK: - Quota Management
    
    private func shouldSkipUploadDueToQuota() -> Bool {
        guard let lastHit = self.lastQuotaHit else { return false }
        
        let timeSinceLastHit = Date().timeIntervalSince(lastHit)
        
        // If we've hit quota recently and multiple times, be more conservative
        if self.quotaHitCount >= 3 && timeSinceLastHit < self.quotaCooldownPeriod {
            logger.info("🛑 Skipping upload - recent quota hits (\(self.quotaHitCount) hits in last \(Int(self.quotaCooldownPeriod/60)) minutes)")
            return true
        }
        
        return false
    }
    
    private func recordQuotaHit() {
        self.lastQuotaHit = Date()
        self.quotaHitCount += 1
        
        // Reset counter after cooldown period
        if self.quotaHitCount > 5 {
            self.quotaHitCount = 3 // Keep some history but don't let it grow indefinitely
        }
        
        logger.info("📊 Quota hit recorded: \(self.quotaHitCount) total hits")
    }
    
    private func resetQuotaTracking() {
        // Reset quota tracking on successful operations
        if let lastHit = self.lastQuotaHit,
           Date().timeIntervalSince(lastHit) > self.quotaCooldownPeriod {
            self.quotaHitCount = 0
            self.lastQuotaHit = nil
            logger.info("✅ Quota tracking reset - cooldown period passed")
        }
    }
    
    private func handleQuotaExceeded(_ error: CKError) {
        recordQuotaHit()
        let retryAfter = error.retryAfterSeconds ?? 300 // Default 5 minutes
        
        logger.warning("⚠️ CloudKit quota exceeded, retry after \(retryAfter) seconds")
        
        Task { @MainActor in
            syncStatus = .error("CloudKit quota exceeded. Please try again in \(Int(retryAfter/60)) minutes.")
        }
        
        scheduleRetry(after: retryAfter)
    }
    
    // MARK: - Progress Tracking
    
    private func updateSyncProgress(_ current: Int, total: Int, operation: String) {
        let percentage = total > 0 ? Int((Double(current) / Double(total)) * 100) : 0
        
        Task { @MainActor in
            syncStatus = .syncing
        }
        
        logger.info("📊 \(operation): \(current)/\(total) (\(percentage)%)")
    }
} 