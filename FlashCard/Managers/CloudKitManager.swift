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
            
            let syncResult: (cards: [FlashCard], decks: [Deck])
            
            if isNewDevice {
                logger.info("🆕 New device detected - performing initial download")
                syncResult = try await performInitialDownload()
            } else {
                logger.info("🔄 Existing device - performing bidirectional sync")
                syncResult = try await performBidirectionalSync(flashCards: flashCards, decks: decks)
            }
            
            // CRITICAL SAFEGUARD: Validate sync results before returning
            let (syncedCards, syncedDecks) = syncResult
            
            logger.info("🔍 SYNC VALIDATION: Local(\(flashCards.count) cards, \(decks.count) decks) → Synced(\(syncedCards.count) cards, \(syncedDecks.count) decks)")
            
            // Allow bypass for initial backup scenarios
            if bypassSafeguards {
                logger.warning("⚠️ BYPASSING SAFEGUARDS: Returning sync results without validation")
                return syncResult
            }
            
            // If user had local data but sync returns empty, something went wrong
            if !flashCards.isEmpty && syncedCards.isEmpty {
                logger.error("🚨 CRITICAL: Sync would remove all \(flashCards.count) cards - aborting!")
                logger.error("🔍 DEBUG: isNewDevice=\(isNewDevice), flashCards.count=\(flashCards.count), syncedCards.count=\(syncedCards.count)")
                await MainActor.run {
                    syncStatus = .error("Sync validation failed - local data preserved (cards). Try 'Force Initial Backup' if this is your first sync.")
                }
                return (flashCards, decks) // Return original data
            }
            
            if !decks.isEmpty && syncedDecks.isEmpty {
                logger.error("🚨 CRITICAL: Sync would remove all \(decks.count) decks - aborting!")
                logger.error("🔍 DEBUG: isNewDevice=\(isNewDevice), decks.count=\(decks.count), syncedDecks.count=\(syncedDecks.count)")
                await MainActor.run {
                    syncStatus = .error("Sync validation failed - local data preserved (decks). Try 'Force Initial Backup' if this is your first sync.")
                }
                return (flashCards, decks) // Return original data
            }
            
            // Additional validation: check for suspicious data loss
            let cardLossPercentage = flashCards.isEmpty ? 0 : Double(flashCards.count - syncedCards.count) / Double(flashCards.count)
            let deckLossPercentage = decks.isEmpty ? 0 : Double(decks.count - syncedDecks.count) / Double(decks.count)
            
            logger.info("🔍 DATA LOSS CHECK: Cards loss=\(Int(cardLossPercentage * 100))%, Decks loss=\(Int(deckLossPercentage * 100))%")
            
            // If we're losing more than 50% of data, something is likely wrong
            if cardLossPercentage > 0.5 {
                logger.warning("🚨 WARNING: Sync would remove \(Int(cardLossPercentage * 100))% of cards (\(flashCards.count) → \(syncedCards.count))")
                await MainActor.run {
                    syncStatus = .error("Sync would remove too much data - please check CloudKit manually")
                }
                return (flashCards, decks) // Return original data
            }
            
            if deckLossPercentage > 0.5 {
                logger.warning("🚨 WARNING: Sync would remove \(Int(deckLossPercentage * 100))% of decks (\(decks.count) → \(syncedDecks.count))")
                await MainActor.run {
                    syncStatus = .error("Sync would remove too much data - please check CloudKit manually")
                }
                return (flashCards, decks) // Return original data
            }
            
            logger.info("✅ Sync validation passed - returning \(syncedCards.count) cards, \(syncedDecks.count) decks")
            return syncResult
            
        } catch {
            await MainActor.run {
                if let ckError = error as? CKError, ckError.code == .quotaExceeded {
                    syncStatus = .error("CloudKit quota exceeded. Please try again in a few minutes.")
                } else {
                    syncStatus = .error(error.localizedDescription)
                }
            }
            logger.error("❌ Sync failed: \(error)")
            // IMPORTANT: Return original data on error, don't return empty arrays
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
            
            logger.info("🔍 Checking for existing CloudKit data...")
            
            let (deckResults, _) = try await database.records(matching: deckQuery, resultsLimit: 1)
            let (cardResults, _) = try await database.records(matching: cardQuery, resultsLimit: 1)
            
            let hasDeckData = !deckResults.isEmpty
            let hasCardData = !cardResults.isEmpty
            let hasCloudData = hasDeckData || hasCardData
            
            logger.info("🔍 CloudKit data check: hasDeckData=\(hasDeckData), hasCardData=\(hasCardData), hasCloudData=\(hasCloudData)")
            
            if hasCloudData {
                logger.info("🔄 Existing CloudKit data found - treating as existing device")
                return false
            } else {
                logger.info("🆕 No CloudKit data found - treating as new device")
                return true
            }
        } catch {
            // CRITICAL FIX: Be more conservative about new device detection
            // If we can't determine CloudKit status, assume it's NOT a new device
            // This prevents accidentally wiping local data due to network/quota issues
            if let ckError = error as? CKError {
                switch ckError.code {
                case .unknownItem, .invalidArguments:
                    // Schema doesn't exist - this could be a genuinely new account
                    logger.info("🆕 No CloudKit schema found - treating as new device")
                    return true
                case .quotaExceeded, .networkUnavailable, .networkFailure, .serviceUnavailable:
                    // Network/quota issues - assume existing device to protect local data
                    logger.warning("⚠️ CloudKit temporarily unavailable - treating as existing device to protect local data")
                    return false
                default:
                    // Other errors - be conservative and protect local data
                    logger.warning("⚠️ CloudKit error during device check - treating as existing device: \(ckError.localizedDescription)")
                    return false
                }
            }
            
            // For non-CloudKit errors, also be conservative
            logger.warning("⚠️ Unexpected error during device check - treating as existing device: \(error)")
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
        var hadDownloadErrors = false
        
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
                    hadDownloadErrors = true
                }
            }
            
            logger.info("📥 Downloaded \(cloudDecks.count) decks")
        } catch {
            if let ckError = error as? CKError {
                switch ckError.code {
                case .unknownItem:
                    logger.info("ℹ️ No decks found in CloudKit (new account)")
                case .quotaExceeded, .networkUnavailable, .networkFailure:
                    // CRITICAL: Don't proceed with empty data if there are network/quota issues
                    logger.error("❌ CloudKit unavailable during initial download - aborting to protect local data")
                    throw NSError(domain: "CloudKitManager", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "CloudKit temporarily unavailable. Please try syncing again later to avoid data loss."
                    ])
                default:
                    throw error
                }
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
                    hadDownloadErrors = true
                }
            }
            
            logger.info("📥 Downloaded \(cloudCards.count) cards")
        } catch {
            if let ckError = error as? CKError {
                switch ckError.code {
                case .unknownItem:
                    logger.info("ℹ️ No cards found in CloudKit (new account)")
                case .quotaExceeded, .networkUnavailable, .networkFailure:
                    // CRITICAL: Don't proceed with empty data if there are network/quota issues
                    logger.error("❌ CloudKit unavailable during initial download - aborting to protect local data")
                    throw NSError(domain: "CloudKitManager", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "CloudKit temporarily unavailable. Please try syncing again later to avoid data loss."
                    ])
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
        
        // SAFEGUARD: If we had download errors and got no data, don't return empty arrays
        if hadDownloadErrors && cloudDecks.isEmpty && cloudCards.isEmpty {
            logger.warning("⚠️ Download completed with errors and no data - this might indicate a problem")
            throw NSError(domain: "CloudKitManager", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "CloudKit download completed with errors. Please try again to ensure data safety."
            ])
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
        logger.info("🔄 Starting bidirectional sync with \(flashCards.count) local cards and \(decks.count) local decks")
        
        // Sync decks first (cards depend on decks)
        var syncedDecks: [Deck] = decks // Default to local data if sync fails
        do {
            syncedDecks = try await syncDecks(localDecks: decks)
            logger.info("✅ Deck sync completed: \(syncedDecks.count) decks")
        } catch {
            logger.warning("⚠️ Deck sync failed, keeping local decks: \(error)")
            // Continue with card sync even if deck sync fails
        }
        
        // Then sync cards with smaller batches to avoid quota issues
        var syncedCards: [FlashCard] = flashCards // Default to local data if sync fails
        do {
            syncedCards = try await syncCardsWithSmartBatching(localCards: flashCards)
            logger.info("✅ Card sync completed: \(syncedCards.count) cards")
        } catch {
            logger.warning("⚠️ Card sync failed, keeping local cards: \(error)")
            // If card sync fails but deck sync succeeded, we still want to return the synced decks
        }
        
        await MainActor.run {
            syncStatus = .success
            lastSyncDate = Date()
        }
        
        logger.info("✅ Bidirectional sync completed: \(syncedCards.count) cards, \(syncedDecks.count) decks")
        return (syncedCards, syncedDecks)
    }
    
    // MARK: - Deck Sync
    
    private func syncDecks(localDecks: [Deck]) async throws -> [Deck] {
        guard let database = database else { 
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        logger.info("🔄 Starting deck sync with \(localDecks.count) local decks")
        
        // Handle empty deck list - similar to card sync fix
        if localDecks.isEmpty {
            logger.info("📭 No local decks - downloading all decks from CloudKit")
            return try await downloadAllDecksFromCloudKit()
        }
        
        var cloudDecks: [Deck] = []
        var cloudDeckDict: [UUID: Deck] = [:]
        
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
                        cloudDeckDict[deck.id] = deck
                    } else {
                        logger.warning("⚠️ Failed to convert deck record: \(recordID)")
                    }
                case .failure(let error):
                    logger.error("❌ Failed to fetch deck record \(recordID): \(error)")
                }
            }
            
            logger.info("📥 Fetched \(cloudDecks.count) decks from CloudKit")
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
        
        // IMPROVED MERGE STRATEGY: Use a dictionary to prevent duplicates
        var mergedDecksDict: [UUID: Deck] = [:]
        
        // Define system deck names that should be merged by name
        let systemDeckNames = ["Uncategorized", "Learnt", "Learning", "Review"]
        
        // Start with all cloud decks
        for cloudDeck in cloudDecks {
            mergedDecksDict[cloudDeck.id] = cloudDeck
        }
        
        // Add/update with local decks (local wins if newer)
        for localDeck in localDecks {
            // Check if this is a system deck that should be merged by name
            if systemDeckNames.contains(localDeck.name) {
                // Find existing system deck with same name
                let existingSystemDeck = mergedDecksDict.values.first { $0.name == localDeck.name }
                
                if let existingDeck = existingSystemDeck {
                    // Merge system decks - use the newer version but preserve both card collections
                    if localDeck.lastModified > existingDeck.lastModified {
                        var updatedDeck = localDeck
                        // Merge card collections from both decks (avoid duplicates)
                        let localCardIds = Set(localDeck.cards.map { $0.id })
                        let cloudCardIds = Set(existingDeck.cards.map { $0.id })
                        let uniqueCloudCards = existingDeck.cards.filter { !localCardIds.contains($0.id) }
                        updatedDeck.cards = localDeck.cards + uniqueCloudCards
                        mergedDecksDict[existingDeck.id] = updatedDeck
                        logger.info("🔄 Merged system deck '\(localDeck.name)' - kept newer version with merged cards")
                    } else {
                        // Cloud version is newer, but merge card collections
                        var updatedDeck = existingDeck
                        let localCardIds = Set(localDeck.cards.map { $0.id })
                        let cloudCardIds = Set(existingDeck.cards.map { $0.id })
                        let uniqueLocalCards = localDeck.cards.filter { !cloudCardIds.contains($0.id) }
                        updatedDeck.cards = existingDeck.cards + uniqueLocalCards
                        mergedDecksDict[existingDeck.id] = updatedDeck
                        logger.info("🔄 Merged system deck '\(localDeck.name)' - kept cloud version with merged cards")
                    }
                } else {
                    // New system deck from local
                    mergedDecksDict[localDeck.id] = localDeck
                    logger.info("📝 Added new system deck '\(localDeck.name)' from local")
                }
            } else {
                // Regular deck - use normal UUID-based merging
                if let existingDeck = mergedDecksDict[localDeck.id] {
                    // Use the newer version
                    if localDeck.lastModified > existingDeck.lastModified {
                        var updatedDeck = localDeck
                        updatedDeck.cards = existingDeck.cards // Keep cloud card associations
                        mergedDecksDict[localDeck.id] = updatedDeck
                    }
                } else {
                    // New deck from local
                    mergedDecksDict[localDeck.id] = localDeck
                }
            }
        }
        
        let syncedDecks = Array(mergedDecksDict.values)
        
        // Upload new/modified local decks to CloudKit in batches
        let decksToUpload = syncedDecks.filter { deck in
            deck.cloudKitRecordName == nil || // New deck
            !cloudDeckDict.contains { $0.key == deck.id && $0.value.lastModified <= deck.lastModified }
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
        
        logger.info("🔄 Deck sync result: \(syncedDecks.count) total decks (\(cloudDecks.count) from cloud, \(localDecks.count) local, \(mergedDecksDict.count) after deduplication)")
        return syncedDecks
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
        
        // Handle empty card list - this is the key fix!
        if localCards.isEmpty {
            logger.info("📭 No local cards - downloading all cards from CloudKit")
            return try await downloadAllCardsFromCloudKit()
        }
        
        // Fetch all cloud cards ONCE at the beginning
        logger.info("📥 Fetching all cloud cards for sync...")
        let allCloudCards = try await downloadAllCardsFromCloudKit()
        let cloudCardDict = Dictionary(uniqueKeysWithValues: allCloudCards.map { ($0.id, $0) })
        
        logger.info("📥 Fetched \(allCloudCards.count) cloud cards for processing")
        
        // Determine batch size based on collection size
        let batchSize = determineBatchSize(for: localCards.count)
        logger.info("📦 Using batch size: \(batchSize)")
        
        var allResultCards: [FlashCard] = []
        var processedCount = 0
        
        // Process cards in batches to avoid quota limits
        let batches = localCards.chunked(into: batchSize)
        
        for (batchIndex, batch) in batches.enumerated() {
            logger.info("📦 Processing batch \(batchIndex + 1)/\(batches.count) (\(batch.count) cards)")
            
            do {
                let batchResults = try await syncCardBatch(batch, cloudCardDict: cloudCardDict)
                allResultCards.append(contentsOf: batchResults)
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
                let retryResults = try await syncCardBatch(Array(smallerBatch), cloudCardDict: cloudCardDict)
                allResultCards.append(contentsOf: retryResults)
                
                // Handle remaining items in this batch
                let remainingItems = Array(batch.dropFirst(smallerBatch.count))
                if !remainingItems.isEmpty {
                    let remainingResults = try await syncCardBatch(remainingItems, cloudCardDict: cloudCardDict)
                    allResultCards.append(contentsOf: remainingResults)
                }
                
                processedCount += batch.count
            }
        }
        
        // FINAL MERGE: Combine all cloud cards with local cards, preserving order
        var finalResult: [FlashCard] = []
        var processedIds: Set<UUID> = []
        
        // First, add all local cards in their original order (or newer cloud versions)
        for localCard in localCards {
            if let cloudCard = cloudCardDict[localCard.id] {
                // Use the newer version
                if localCard.lastModified > cloudCard.lastModified {
                    finalResult.append(localCard)
                } else {
                    finalResult.append(cloudCard)
                }
            } else {
                // Local card not in cloud
                finalResult.append(localCard)
            }
            processedIds.insert(localCard.id)
        }
        
        // Then add any cloud-only cards that weren't in local
        for cloudCard in allCloudCards {
            if !processedIds.contains(cloudCard.id) {
                finalResult.append(cloudCard)
            }
        }
        
        logger.info("✅ Smart card sync completed: processed \(processedCount) cards, final result \(finalResult.count) cards")
        return finalResult
    }
    
    private func syncCardBatch(_ cards: [FlashCard], cloudCardDict: [UUID: FlashCard]) async throws -> [FlashCard] {
        guard let database = database else { 
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        // Determine which local cards need to be uploaded
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
            var updatedCards: [FlashCard] = []
            for (recordID, result) in saveResults {
                switch result {
                case .success(let record):
                    if let updatedCard = FlashCard.fromCKRecord(record) {
                        updatedCards.append(updatedCard)
                    }
                case .failure(let error):
                    logger.error("❌ Failed to save card \(recordID): \(error)")
                }
            }
            
            logger.info("✅ Successfully uploaded \(updatedCards.count) cards")
        } else {
            logger.info("📭 No cards to upload in this batch")
        }
        
        // MERGE STRATEGY: Use the cloudCardDict and local cards
        var mergedCardsDict: [UUID: FlashCard] = [:]
        
        // Start with all cloud cards from the passed dictionary
        for cloudCard in cloudCardDict.values {
            mergedCardsDict[cloudCard.id] = cloudCard
        }
        
        // Add/update with local cards (local wins if newer)
        for localCard in cards {
            if let existingCard = mergedCardsDict[localCard.id] {
                // Use the newer version
                if localCard.lastModified > existingCard.lastModified {
                    mergedCardsDict[localCard.id] = localCard
                }
            } else {
                // New card from local
                mergedCardsDict[localCard.id] = localCard
            }
        }
        
        let resultCards = Array(mergedCardsDict.values)
        
        logger.info("🔄 Batch sync result: \(resultCards.count) total cards (\(cloudCardDict.count) from cloud, \(cards.count) local, \(mergedCardsDict.count) after deduplication)")
        return resultCards
    }
    
    // MARK: - Batch Size Optimization
    
    private func determineBatchSize(for totalCount: Int) -> Int {
        switch totalCount {
        case 0:
            return 1 // Return 1 instead of 0 to prevent chunked(into: 0) error
        case 1...10:
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
    
    // MARK: - Diagnostic and Recovery Functions
    
    private var bypassSafeguards = false
    
    func temporarilyBypassSafeguards() {
        bypassSafeguards = true
        logger.info("⚠️ Temporarily bypassing sync safeguards for initial backup")
        
        // Auto-reset after 5 minutes
        DispatchQueue.main.asyncAfter(deadline: .now() + 300) {
            self.bypassSafeguards = false
            self.logger.info("✅ Sync safeguards re-enabled")
        }
    }
    
    func diagnoseSyncIssue() async -> String {
        guard !isRunningOnSimulator else {
            return "Running on simulator - CloudKit disabled"
        }
        
        guard isAccountAvailable else {
            return "iCloud account not available - please sign in to iCloud in Settings"
        }
        
        guard let database = database else {
            return "CloudKit database not available"
        }
        
        var diagnostics: [String] = []
        
        // Check CloudKit schema
        do {
            let deckQuery = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
            let cardQuery = CKQuery(recordType: FlashCard.recordType, predicate: NSPredicate(value: true))
            
            let (deckResults, _) = try await database.records(matching: deckQuery, resultsLimit: 1)
            let (cardResults, _) = try await database.records(matching: cardQuery, resultsLimit: 1)
            
            diagnostics.append("✅ CloudKit schema exists")
            diagnostics.append("📊 CloudKit has data: \(!deckResults.isEmpty || !cardResults.isEmpty)")
            
        } catch {
            if let ckError = error as? CKError {
                switch ckError.code {
                case .unknownItem, .invalidArguments:
                    diagnostics.append("⚠️ CloudKit schema not found - first sync will create it")
                case .quotaExceeded:
                    diagnostics.append("❌ CloudKit quota exceeded - wait and try again")
                case .networkUnavailable, .networkFailure:
                    diagnostics.append("❌ Network issues - check internet connection")
                default:
                    diagnostics.append("❌ CloudKit error: \(ckError.localizedDescription)")
                }
            } else {
                diagnostics.append("❌ Unexpected error: \(error.localizedDescription)")
            }
        }
        
        // Check for recent quota hits
        if let lastHit = lastQuotaHit {
            let timeSince = Date().timeIntervalSince(lastHit)
            diagnostics.append("⏰ Last quota hit: \(Int(timeSince/60)) minutes ago (\(quotaHitCount) total hits)")
        }
        
        return diagnostics.joined(separator: "\n")
    }
    
    func forceUploadLocalData(flashCards: [FlashCard], decks: [Deck]) async -> (success: Bool, message: String) {
        guard !isRunningOnSimulator else {
            return (false, "Cannot force upload on simulator")
        }
        
        guard isAccountAvailable else {
            return (false, "iCloud account not available")
        }
        
        logger.info("🔄 FORCE UPLOAD: Starting with \(flashCards.count) cards and \(decks.count) decks")
        
        await MainActor.run {
            syncStatus = .syncing
        }
        
        var uploadedDecks = 0
        var uploadedCards = 0
        var errors: [String] = []
        
        // Force upload decks first
        for deck in decks {
            do {
                _ = try await uploadDeck(deck)
                uploadedDecks += 1
                logger.info("✅ Force uploaded deck: \(deck.name)")
            } catch {
                errors.append("Deck '\(deck.name)': \(error.localizedDescription)")
                logger.error("❌ Failed to force upload deck '\(deck.name)': \(error)")
            }
        }
        
        // Force upload cards in small batches
        let batchSize = 5
        let cardBatches = flashCards.chunked(into: batchSize)
        
        for (batchIndex, batch) in cardBatches.enumerated() {
            for card in batch {
                do {
                    _ = try await uploadCard(card)
                    uploadedCards += 1
                    logger.info("✅ Force uploaded card: \(card.word)")
                } catch {
                    errors.append("Card '\(card.word)': \(error.localizedDescription)")
                    logger.error("❌ Failed to force upload card '\(card.word)': \(error)")
                }
            }
            
            // Add delay between batches
            if batchIndex < cardBatches.count - 1 {
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
        }
        
        let successMessage = "Force upload completed: \(uploadedDecks)/\(decks.count) decks, \(uploadedCards)/\(flashCards.count) cards"
        let errorMessage = errors.isEmpty ? "" : "\nErrors: \(errors.joined(separator: ", "))"
        
        await MainActor.run {
            if errors.isEmpty {
                syncStatus = .success
                lastSyncDate = Date()
            } else {
                syncStatus = .error("Force upload completed with errors")
            }
        }
        
        logger.info("🔄 FORCE UPLOAD COMPLETE: \(successMessage)")
        return (errors.count < (flashCards.count + decks.count) / 2, successMessage + errorMessage)
    }
    
    // MARK: - Diagnostics
    
    func getCloudKitRecordCounts() async -> (cards: Int, decks: Int) {
        guard !isRunningOnSimulator, let database = database else {
            return (0, 0)
        }
        
        do {
            let cardQuery = CKQuery(recordType: FlashCard.recordType, predicate: NSPredicate(value: true))
            let deckQuery = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
            
            let (cardResults, _) = try await database.records(matching: cardQuery)
            let (deckResults, _) = try await database.records(matching: deckQuery)
            
            return (cardResults.count, deckResults.count)
        } catch {
            logger.error("❌ Failed to get record counts: \(error)")
            return (0, 0)
        }
    }
    
    func testCloudKitConnectivity() async -> Bool {
        guard !isRunningOnSimulator, let database = database else {
            return false
        }
        
        do {
            let testRecord = CKRecord(recordType: "TestRecord")
            testRecord["testField"] = "connectivity_test_\(Date().timeIntervalSince1970)"
            
            let savedRecord = try await database.save(testRecord)
            try await database.deleteRecord(withID: savedRecord.recordID)
            
            return true
        } catch {
            logger.error("❌ CloudKit connectivity test failed: \(error)")
            return false
        }
    }
    
    // MARK: - Data Reset
    
    func deleteAllCloudKitData() async -> (success: Bool, message: String) {
        guard !isRunningOnSimulator, let database = database else {
            return (false, "Cannot delete data on simulator")
        }
        
        logger.info("🗑️ DELETING ALL CLOUDKIT DATA")
        
        var deletedCards = 0
        var deletedDecks = 0
        var errors: [String] = []
        
        // Delete all cards
        do {
            let cardQuery = CKQuery(recordType: FlashCard.recordType, predicate: NSPredicate(value: true))
            let (cardResults, _) = try await database.records(matching: cardQuery)
            
            let cardRecordIDs = cardResults.compactMap { (recordID, result) -> CKRecord.ID? in
                switch result {
                case .success:
                    return recordID
                case .failure(let error):
                    errors.append("Card fetch error: \(error.localizedDescription)")
                    return nil
                }
            }
            
            if !cardRecordIDs.isEmpty {
                let (deleteResults, _) = try await database.modifyRecords(saving: [], deleting: cardRecordIDs)
                
                for (recordID, result) in deleteResults {
                    switch result {
                    case .success:
                        deletedCards += 1
                    case .failure(let error):
                        errors.append("Card delete error: \(error.localizedDescription)")
                    }
                }
            }
            
            logger.info("🗑️ Deleted \(deletedCards) cards")
        } catch {
            errors.append("Card deletion failed: \(error.localizedDescription)")
        }
        
        // Delete all decks
        do {
            let deckQuery = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
            let (deckResults, _) = try await database.records(matching: deckQuery)
            
            let deckRecordIDs = deckResults.compactMap { (recordID, result) -> CKRecord.ID? in
                switch result {
                case .success:
                    return recordID
                case .failure(let error):
                    errors.append("Deck fetch error: \(error.localizedDescription)")
                    return nil
                }
            }
            
            if !deckRecordIDs.isEmpty {
                let (deleteResults, _) = try await database.modifyRecords(saving: [], deleting: deckRecordIDs)
                
                for (recordID, result) in deleteResults {
                    switch result {
                    case .success:
                        deletedDecks += 1
                    case .failure(let error):
                        errors.append("Deck delete error: \(error.localizedDescription)")
                    }
                }
            }
            
            logger.info("🗑️ Deleted \(deletedDecks) decks")
        } catch {
            errors.append("Deck deletion failed: \(error.localizedDescription)")
        }
        
        let success = errors.isEmpty || (deletedCards > 0 || deletedDecks > 0)
        let message = "Deleted \(deletedCards) cards and \(deletedDecks) decks" + 
                     (errors.isEmpty ? "" : ". Errors: \(errors.joined(separator: ", "))")
        
        logger.info("🗑️ CLOUDKIT DATA DELETION COMPLETE: \(message)")
        return (success, message)
    }
    
    // NEW METHOD: Download all cards from CloudKit
    private func downloadAllCardsFromCloudKit() async throws -> [FlashCard] {
        guard let database = database else {
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        logger.info("📥 Downloading all cards from CloudKit")
        
        var allCloudCards: [FlashCard] = []
        
        do {
            let query = CKQuery(recordType: FlashCard.recordType, predicate: NSPredicate(value: true))
            let (results, _) = try await database.records(matching: query)
            
            for (_, result) in results {
                switch result {
                case .success(let record):
                    if let card = FlashCard.fromCKRecord(record) {
                        allCloudCards.append(card)
                    }
                case .failure(let error):
                    logger.warning("⚠️ Failed to download card: \(error)")
                }
            }
            
            logger.info("📥 Downloaded \(allCloudCards.count) cards from CloudKit")
            
        } catch {
            if let ckError = error as? CKError {
                switch ckError.code {
                case .unknownItem:
                    logger.info("ℹ️ No cards found in CloudKit (new account)")
                    return []
                case .quotaExceeded, .networkUnavailable, .networkFailure:
                    logger.error("❌ CloudKit unavailable during card download - aborting to protect local data")
                    throw NSError(domain: "CloudKitManager", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "CloudKit temporarily unavailable. Please try syncing again later to avoid data loss."
                    ])
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
        
        return allCloudCards
    }
    
    // MARK: - Public Download Methods
    
    func downloadAllDataFromCloudKit() async -> (cards: [FlashCard], decks: [Deck]) {
        guard !isRunningOnSimulator else {
            logger.info("📱 Skipping download - simulator mode")
            return ([], [])
        }
        
        guard isAccountAvailable else {
            logger.info("📵 Skipping download - no iCloud account")
            return ([], [])
        }
        
        logger.info("📥 DOWNLOADING ALL DATA FROM CLOUDKIT")
        
        do {
            let cards = try await downloadAllCardsFromCloudKit()
            let decks = try await downloadAllDecksFromCloudKit()
            
            logger.info("✅ Download completed: \(cards.count) cards, \(decks.count) decks")
            return (cards, decks)
        } catch {
            logger.error("❌ Download failed: \(error)")
            return ([], [])
        }
    }
    
    private func downloadAllDecksFromCloudKit() async throws -> [Deck] {
        guard let database = database else {
            throw NSError(domain: "CloudKitManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Database not available"])
        }
        
        logger.info("📥 Downloading all decks from CloudKit")
        
        var allCloudDecks: [Deck] = []
        
        do {
            let query = CKQuery(recordType: Deck.recordType, predicate: NSPredicate(value: true))
            let (results, _) = try await database.records(matching: query)
            
            for (_, result) in results {
                switch result {
                case .success(let record):
                    if let deck = Deck.fromCKRecord(record) {
                        allCloudDecks.append(deck)
                    }
                case .failure(let error):
                    logger.warning("⚠️ Failed to download deck: \(error)")
                }
            }
            
            logger.info("📥 Downloaded \(allCloudDecks.count) decks from CloudKit")
            
        } catch {
            if let ckError = error as? CKError {
                switch ckError.code {
                case .unknownItem:
                    logger.info("ℹ️ No decks found in CloudKit (new account)")
                    return []
                case .quotaExceeded, .networkUnavailable, .networkFailure:
                    logger.error("❌ CloudKit unavailable during deck download - aborting to protect local data")
                    throw NSError(domain: "CloudKitManager", code: -2, userInfo: [
                        NSLocalizedDescriptionKey: "CloudKit temporarily unavailable. Please try syncing again later to avoid data loss."
                    ])
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
        
        return allCloudDecks
    }
} 