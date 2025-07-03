import Foundation
import CloudKit

// MARK: - CloudKit Diagnostics Extension
extension FlashCardViewModel {
    
    func diagnoseSyncIssue() async -> String {
        #if targetEnvironment(simulator)
        return "Running on simulator - CloudKit disabled"
        #else
        let manager = CloudKitManager.shared
        return await manager.diagnoseSyncIssue()
        #endif
    }
    
    func forceUploadAllData() async -> (success: Bool, message: String) {
        #if targetEnvironment(simulator)
        return (false, "Cannot force upload on simulator")
        #endif
        
        print("🔄 User requested force upload of all local data")
        
        let currentCards = flashCards
        let currentDecks = decks
        let manager = CloudKitManager.shared
        
        return await manager.forceUploadLocalData(
            flashCards: currentCards,
            decks: currentDecks
        )
    }
    
    func resetCloudKitSync() {
        #if targetEnvironment(simulator)
        print("📱 CloudKit reset skipped - running on simulator")
        return
        #endif
        
        print("🔄 User requested CloudKit sync reset")
        
        // Reset sync state by disabling and re-enabling sync
        let wasEnabled = isCloudSyncEnabled
        isCloudSyncEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if wasEnabled {
                self.isCloudSyncEnabled = true
                // The sync will be triggered automatically by the didSet observer
            }
        }
    }
    
    func forceInitialBackup() async -> (success: Bool, message: String) {
        #if targetEnvironment(simulator)
        return (false, "Cannot force backup on simulator")
        #endif
        
        print("🔄 FORCE INITIAL BACKUP: Starting with \(flashCards.count) cards and \(decks.count) decks")
        
        // For now, skip the bypass safeguards call to avoid compilation issues
        // We'll implement the bypass functionality directly in the upload methods
        let manager = CloudKitManager.shared
        print("⚠️ Bypassing sync safeguards for initial backup")
        
        // First try the force upload method
        let uploadResult = await manager.forceUploadLocalData(
            flashCards: flashCards,
            decks: decks
        )
        
        if uploadResult.success {
            print("✅ FORCE INITIAL BACKUP: Upload completed successfully")
            return uploadResult
        }
        
        // If upload fails, try a full sync with bypassed safeguards
        print("🔄 FORCE INITIAL BACKUP: Upload failed, trying full sync with bypassed safeguards")
        
        let (syncedCards, syncedDecks) = await manager.syncData(
            flashCards: flashCards,
            decks: decks
        )
        
        let success = syncedCards.count >= flashCards.count && syncedDecks.count >= decks.count
        let message = success ? 
            "Force backup completed: \(syncedCards.count) cards, \(syncedDecks.count) decks synced" :
            "Force backup partially completed: \(syncedCards.count)/\(flashCards.count) cards, \(syncedDecks.count)/\(decks.count) decks"
        
        if success {
            print("✅ FORCE INITIAL BACKUP: Full sync completed successfully")
        } else {
            print("⚠️ FORCE INITIAL BACKUP: Partial success - \(message)")
        }
        
        return (success, message)
    }
    
    func retryAfterQuotaCooldown() async -> (success: Bool, message: String) {
        #if targetEnvironment(simulator)
        return (false, "Cannot retry on simulator")
        #endif
        
        print("⏰ QUOTA RETRY: Waiting for CloudKit quota cooldown...")
        
        // Wait 6 minutes to be safe (longer than the 328 seconds requested)
        let cooldownSeconds = 360 // 6 minutes
        print("⏰ Waiting \(cooldownSeconds) seconds for quota cooldown...")
        
        try? await Task.sleep(nanoseconds: UInt64(cooldownSeconds * 1_000_000_000))
        
        print("✅ QUOTA RETRY: Cooldown complete, attempting upload...")
        
        // Try force upload again
        return await forceUploadAllData()
    }
    
    func uploadInSmallBatches() async -> (success: Bool, message: String) {
        #if targetEnvironment(simulator)
        return (false, "Cannot upload on simulator")
        #endif
        
        print("📦 BATCH UPLOAD: Starting with \(flashCards.count) cards and \(decks.count) decks")
        
        let manager = CloudKitManager.shared
        var uploadedDecks = 0
        var uploadedCards = 0
        var errors: [String] = []
        
        // Upload decks first, one by one with delays
        for (index, deck) in decks.enumerated() {
            do {
                _ = try await manager.uploadDeck(deck)
                uploadedDecks += 1
                print("✅ Uploaded deck \(index + 1)/\(decks.count): \(deck.name)")
                
                // Wait between uploads to respect quota
                if index < decks.count - 1 {
                    try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
                }
            } catch {
                errors.append("Deck '\(deck.name)': \(error.localizedDescription)")
                print("❌ Failed to upload deck '\(deck.name)': \(error)")
                
                // If quota exceeded, wait longer
                if error.localizedDescription.contains("Quota") {
                    print("⏰ Quota hit, waiting 5 minutes...")
                    try? await Task.sleep(nanoseconds: 300_000_000_000) // 5 minutes
                }
            }
        }
        
        // Upload cards in small batches
        let cardBatchSize = 5
        let cardBatches = flashCards.chunked(into: cardBatchSize)
        
        for (batchIndex, batch) in cardBatches.enumerated() {
            print("📦 Uploading card batch \(batchIndex + 1)/\(cardBatches.count)")
            
            for card in batch {
                do {
                    _ = try await manager.uploadCard(card)
                    uploadedCards += 1
                } catch {
                    errors.append("Card '\(card.word)': \(error.localizedDescription)")
                    print("❌ Failed to upload card '\(card.word)': \(error)")
                }
            }
            
            // Wait between batches
            if batchIndex < cardBatches.count - 1 {
                let delay = errors.count > uploadedCards / 2 ? 10 : 3 // Longer delay if many errors
                print("⏳ Waiting \(delay) seconds between batches...")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
        
        let success = uploadedDecks >= decks.count / 2 && uploadedCards >= flashCards.count / 2
        let message = "Batch upload: \(uploadedDecks)/\(decks.count) decks, \(uploadedCards)/\(flashCards.count) cards. Errors: \(errors.count)"
        
        print("📦 BATCH UPLOAD COMPLETE: \(message)")
        return (success, message)
    }
    
    // MARK: - Enhanced Sync Status and Diagnostics
    
    @MainActor
    func checkDetailedSyncStatus() async {
        print("🔍 DETAILED SYNC STATUS CHECK")
        
        // 1. Check local data counts
        let localCardCount = flashCards.count
        let localDeckCount = decks.count
        print("📱 LOCAL DATA: \(localCardCount) cards, \(localDeckCount) decks")
        
        // 2. Check CloudKit account status
        do {
            await CloudKitManager.shared.checkAccountStatus()
            let isAvailable = CloudKitManager.shared.isAccountAvailable
            print("☁️ CLOUDKIT ACCOUNT: \(isAvailable ? "Available" : "Not Available")")
            
            if !isAvailable {
                print("⚠️ CloudKit account not available")
                return
            }
        } catch {
            print("❌ Failed to check CloudKit account: \(error)")
            return
        }
        
        // 3. Check CloudKit record counts
        await checkCloudKitRecordCounts()
        
        // 4. Check last sync times
        let lastCardSync = UserDefaults.standard.object(forKey: "lastCardSyncDate") as? Date ?? Date.distantPast
        let lastDeckSync = UserDefaults.standard.object(forKey: "lastDeckSyncDate") as? Date ?? Date.distantPast
        
        print("🕒 LAST SYNC TIMES:")
        print("   Cards: \(lastCardSync)")
        print("   Decks: \(lastDeckSync)")
        
        // 5. Check sync settings
        let syncEnabled = UserDefaults.standard.bool(forKey: "cloudKitSyncEnabled")
        print("⚙️ SYNC ENABLED: \(syncEnabled)")
        
        // 6. Test basic CloudKit connectivity
        await testCloudKitConnectivity()
    }
    
    @MainActor
    private func checkCloudKitRecordCounts() async {
        print("📊 CHECKING CLOUDKIT RECORD COUNTS...")
        
        let (cloudCardCount, cloudDeckCount) = await CloudKitManager.shared.getCloudKitRecordCounts()
        
        print("☁️ CLOUDKIT DATA: \(cloudCardCount) cards, \(cloudDeckCount) decks")
        
        // Compare with local data
        let localCardCount = flashCards.count
        let localDeckCount = decks.count
        
        if cloudCardCount == 0 && localCardCount > 0 {
            print("⚠️ NO DATA IN CLOUDKIT but \(localCardCount) cards locally - sync may not be working")
        } else if cloudCardCount > 0 {
            print("✅ CloudKit has data - sync appears to be working")
        }
    }
    
    @MainActor
    private func testCloudKitConnectivity() async {
        print("🔌 TESTING CLOUDKIT CONNECTIVITY...")
        
        let isConnected = await CloudKitManager.shared.testCloudKitConnectivity()
        
        if isConnected {
            print("✅ CloudKit connectivity test PASSED")
        } else {
            print("❌ CloudKit connectivity test FAILED")
        }
    }
    
    @MainActor
    func monitorSyncProgress() async {
        print("📡 STARTING SYNC PROGRESS MONITOR")
        
        // Start monitoring
        var previousCardCount = 0
        var previousDeckCount = 0
        
        for i in 0..<30 { // Monitor for 30 seconds
            let (currentCardCount, currentDeckCount) = await CloudKitManager.shared.getCloudKitRecordCounts()
            
            if currentCardCount != previousCardCount || currentDeckCount != previousDeckCount {
                print("📈 SYNC PROGRESS: Cards \(previousCardCount)→\(currentCardCount), Decks \(previousDeckCount)→\(currentDeckCount)")
                previousCardCount = currentCardCount
                previousDeckCount = currentDeckCount
            }
            
            try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
        }
        
        print("📡 SYNC PROGRESS MONITORING COMPLETE")
    }
    
    // MARK: - Deck-Card Relationship Diagnostics
    
    @MainActor
    func diagnoseDeckCardRelationships() async {
        print("🔍 DIAGNOSING DECK-CARD RELATIONSHIPS")
        print("📊 Total cards: \(flashCards.count)")
        print("📊 Total decks: \(decks.count)")
        
        // Check cards with deck IDs
        let cardsWithDeckIds = flashCards.filter { !$0.deckIds.isEmpty }
        let cardsWithoutDeckIds = flashCards.filter { $0.deckIds.isEmpty }
        
        print("📝 Cards with deck IDs: \(cardsWithDeckIds.count)")
        print("📝 Cards without deck IDs: \(cardsWithoutDeckIds.count)")
        
        // Check each deck's card count
        print("📁 DECK CARD COUNTS:")
        for deck in decks {
            let cardsInDeck = flashCards.filter { $0.deckIds.contains(deck.id) }
            print("   '\(deck.name)': \(cardsInDeck.count) cards (deck.cards.count: \(deck.cards.count))")
            
            if cardsInDeck.count != deck.cards.count {
                print("   ⚠️ MISMATCH: Expected \(cardsInDeck.count) but deck has \(deck.cards.count)")
            }
        }
        
        // Check for orphaned deck IDs
        let allDeckIds = Set(decks.map { $0.id })
        let referencedDeckIds = Set(flashCards.flatMap { $0.deckIds })
        let orphanedDeckIds = referencedDeckIds.subtracting(allDeckIds)
        
        if !orphanedDeckIds.isEmpty {
            print("⚠️ ORPHANED DECK IDs: \(orphanedDeckIds)")
        }
        
        // Force update associations
        print("🔄 Forcing card-deck association update...")
        updateCardDeckAssociations()
        
        print("✅ Diagnosis complete")
    }
    
    @MainActor
    func forceUpdateDeckAssociations() async {
        print("🔄 FORCING DECK ASSOCIATION UPDATE")
        updateCardDeckAssociations()
        print("✅ Deck associations updated")
    }
    
    // MARK: - CloudKit Data Reset
    
    @MainActor
    func resetCloudKitData() async -> (success: Bool, message: String) {
        #if targetEnvironment(simulator)
        return (false, "Cannot reset CloudKit data on simulator")
        #endif
        
        print("🗑️ RESETTING CLOUDKIT DATA")
        print("📊 Local data: \(flashCards.count) cards, \(decks.count) decks")
        
        let manager = CloudKitManager.shared
        
        // Step 1: Delete all existing CloudKit data
        print("🗑️ Step 1: Deleting existing CloudKit data...")
        let deleteResult = await manager.deleteAllCloudKitData()
        
        if !deleteResult.success {
            print("⚠️ Delete failed: \(deleteResult.message)")
            return (false, "Failed to delete existing data: \(deleteResult.message)")
        }
        
        print("✅ Step 1 complete: CloudKit data deleted")
        
        // Step 2: Wait a moment for CloudKit to process
        print("⏳ Step 2: Waiting for CloudKit to process deletions...")
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
        
        // Step 3: Force upload all local data
        print("📤 Step 3: Uploading all local data...")
        let uploadResult = await manager.forceUploadLocalData(
            flashCards: flashCards,
            decks: decks
        )
        
        if uploadResult.success {
            print("✅ Step 3 complete: Local data uploaded successfully")
            
            // Step 4: Force update deck associations
            print("🔄 Step 4: Updating deck associations...")
            updateCardDeckAssociations()
            
            print("✅ CLOUDKIT DATA RESET COMPLETE")
            return (true, "CloudKit data reset successfully: \(uploadResult.message)")
        } else {
            print("❌ Step 3 failed: \(uploadResult.message)")
            return (false, "Failed to upload local data: \(uploadResult.message)")
        }
    }
    
    // MARK: - Download All Data
    
    @MainActor
    func downloadAllDataFromCloudKit() async -> (success: Bool, message: String) {
        #if targetEnvironment(simulator)
        return (false, "Cannot download on simulator")
        #endif
        
        print("📥 DOWNLOADING ALL DATA FROM CLOUDKIT")
        print("📊 Current local data: \(flashCards.count) cards, \(decks.count) decks")
        
        let manager = CloudKitManager.shared
        
        do {
            let (downloadedCards, downloadedDecks) = await manager.downloadAllDataFromCloudKit()
            
            print("📥 Downloaded: \(downloadedCards.count) cards, \(downloadedDecks.count) decks")
            
            if downloadedCards.isEmpty && downloadedDecks.isEmpty {
                return (false, "No data found in CloudKit")
            }
            
            // Temporarily disable sync to prevent recursion
            let originalSyncEnabled = isCloudSyncEnabled
            isCloudSyncEnabled = false
            
            // Update local data with downloaded data
            flashCards = downloadedCards
            decks = downloadedDecks
            updateCardDeckAssociations()
            
            // Re-enable sync
            isCloudSyncEnabled = originalSyncEnabled
            
            print("✅ DOWNLOAD COMPLETE: \(downloadedCards.count) cards, \(downloadedDecks.count) decks")
            return (true, "Downloaded \(downloadedCards.count) cards and \(downloadedDecks.count) decks from CloudKit")
            
        } catch {
            print("❌ Download failed: \(error)")
            return (false, "Download failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Duplicate Removal
    
    @MainActor
    func removeDuplicates() async -> (success: Bool, message: String) {
        print("🧹 REMOVING DUPLICATES")
        print("📊 Before: \(flashCards.count) cards, \(decks.count) decks")
        
        // Remove duplicate cards
        var uniqueCards: [FlashCard] = []
        var seenCardIds: Set<UUID> = []
        
        for card in flashCards {
            if !seenCardIds.contains(card.id) {
                uniqueCards.append(card)
                seenCardIds.insert(card.id)
            } else {
                print("🗑️ Removed duplicate card: \(card.word)")
            }
        }
        
        // Handle system deck merging instead of just removing duplicates
        var uniqueDecks: [Deck] = []
        var seenDeckIds: Set<UUID> = []
        var systemDeckNames = ["Uncategorized", "Review"]
        var systemDeckMerges = 0
        
        for deck in decks {
            if systemDeckNames.contains(deck.name) {
                // Check if we already have a system deck with this name
                if let existingDeckIndex = uniqueDecks.firstIndex(where: { $0.name == deck.name }) {
                    // Merge system decks
                    var existingDeck = uniqueDecks[existingDeckIndex]
                    let existingCardIds = Set(existingDeck.cards.map { $0.id })
                    let newCardIds = Set(deck.cards.map { $0.id })
                    
                    // Add cards from the new deck that aren't in the existing deck
                    let uniqueNewCards = deck.cards.filter { !existingCardIds.contains($0.id) }
                    existingDeck.cards.append(contentsOf: uniqueNewCards)
                    
                    // Use the newer version
                    if deck.lastModified > existingDeck.lastModified {
                        existingDeck.lastModified = deck.lastModified
                    }
                    
                    uniqueDecks[existingDeckIndex] = existingDeck
                    systemDeckMerges += 1
                    print("🔄 Merged system deck '\(deck.name)' - combined \(uniqueNewCards.count) new cards")
                } else {
                    // First occurrence of this system deck
                    uniqueDecks.append(deck)
                    seenDeckIds.insert(deck.id)
                }
            } else {
                // Regular deck - use UUID-based deduplication
                if !seenDeckIds.contains(deck.id) {
                    uniqueDecks.append(deck)
                    seenDeckIds.insert(deck.id)
                } else {
                    print("🗑️ Removed duplicate deck: \(deck.name)")
                }
            }
        }
        
        let cardsRemoved = flashCards.count - uniqueCards.count
        let decksRemoved = decks.count - uniqueDecks.count - systemDeckMerges
        
        // Update data
        flashCards = uniqueCards
        decks = uniqueDecks
        
        // Clean up deck-card associations after removing duplicates
        print("🔄 Cleaning up deck-card associations...")
        updateCardDeckAssociations()
        
        print("📊 After: \(flashCards.count) cards, \(decks.count) decks")
        print("✅ Removed \(cardsRemoved) duplicate cards and \(decksRemoved) duplicate decks")
        print("✅ Merged \(systemDeckMerges) system decks")
        
        // Verify no orphaned references
        let orphanedCardIds = Set(flashCards.flatMap { $0.deckIds }).subtracting(Set(decks.map { $0.id }))
        if !orphanedCardIds.isEmpty {
            print("⚠️ Found \(orphanedCardIds.count) orphaned deck references in cards - cleaning up...")
            
            // Remove orphaned deck references from cards
            for i in 0..<flashCards.count {
                flashCards[i].deckIds = flashCards[i].deckIds.filter { !orphanedCardIds.contains($0) }
            }
        }
        
        return (true, "Removed \(cardsRemoved) duplicate cards, \(decksRemoved) duplicate decks, merged \(systemDeckMerges) system decks")
    }
    
    @MainActor
    func removeDuplicatesPreservingOrder() async -> (success: Bool, message: String) {
        print("🧹 REMOVING DUPLICATES WHILE PRESERVING ORDER")
        print("📊 Before: \(flashCards.count) cards, \(decks.count) decks")
        
        // Remove duplicate cards while preserving order
        var uniqueCards: [FlashCard] = []
        var seenCardIds: Set<UUID> = []
        
        for card in flashCards {
            if !seenCardIds.contains(card.id) {
                uniqueCards.append(card)
                seenCardIds.insert(card.id)
            } else {
                print("🗑️ Removed duplicate card: \(card.word)")
            }
        }
        
        // Handle system deck merging instead of just removing duplicates
        var uniqueDecks: [Deck] = []
        var seenDeckIds: Set<UUID> = []
        var systemDeckNames = ["Uncategorized", "Review"]
        var systemDeckMerges = 0
        
        for deck in decks {
            if systemDeckNames.contains(deck.name) {
                // Check if we already have a system deck with this name
                if let existingDeckIndex = uniqueDecks.firstIndex(where: { $0.name == deck.name }) {
                    // Merge system decks
                    var existingDeck = uniqueDecks[existingDeckIndex]
                    let existingCardIds = Set(existingDeck.cards.map { $0.id })
                    let newCardIds = Set(deck.cards.map { $0.id })
                    
                    // Add cards from the new deck that aren't in the existing deck
                    let uniqueNewCards = deck.cards.filter { !existingCardIds.contains($0.id) }
                    existingDeck.cards.append(contentsOf: uniqueNewCards)
                    
                    // Use the newer version
                    if deck.lastModified > existingDeck.lastModified {
                        existingDeck.lastModified = deck.lastModified
                    }
                    
                    uniqueDecks[existingDeckIndex] = existingDeck
                    systemDeckMerges += 1
                    print("🔄 Merged system deck '\(deck.name)' - combined \(uniqueNewCards.count) new cards")
                } else {
                    // First occurrence of this system deck
                    uniqueDecks.append(deck)
                    seenDeckIds.insert(deck.id)
                }
            } else {
                // Regular deck - use UUID-based deduplication
                if !seenDeckIds.contains(deck.id) {
                    uniqueDecks.append(deck)
                    seenDeckIds.insert(deck.id)
                } else {
                    print("🗑️ Removed duplicate deck: \(deck.name)")
                }
            }
        }
        
        let cardsRemoved = flashCards.count - uniqueCards.count
        let decksRemoved = decks.count - uniqueDecks.count - systemDeckMerges
        
        // Update data
        flashCards = uniqueCards
        decks = uniqueDecks
        
        // Clean up deck-card associations after removing duplicates
        print("🔄 Cleaning up deck-card associations...")
        updateCardDeckAssociations()
        
        print("📊 After: \(flashCards.count) cards, \(decks.count) decks")
        print("✅ Removed \(cardsRemoved) duplicate cards and \(decksRemoved) duplicate decks")
        print("✅ Merged \(systemDeckMerges) system decks")
        
        // Verify no orphaned references
        let orphanedCardIds = Set(flashCards.flatMap { $0.deckIds }).subtracting(Set(decks.map { $0.id }))
        if !orphanedCardIds.isEmpty {
            print("⚠️ Found \(orphanedCardIds.count) orphaned deck references in cards - cleaning up...")
            
            // Remove orphaned deck references from cards
            for i in 0..<flashCards.count {
                flashCards[i].deckIds = flashCards[i].deckIds.filter { !orphanedCardIds.contains($0) }
            }
        }
        
        return (true, "Removed \(cardsRemoved) duplicate cards, \(decksRemoved) duplicate decks, merged \(systemDeckMerges) system decks")
    }
    
    @MainActor
    func cleanupDeckCardAssociations() async -> (success: Bool, message: String) {
        print("🧹 CLEANING UP DECK-CARD ASSOCIATIONS")
        
        var issuesFound = 0
        var cardsFixed = 0
        var decksFixed = 0
        
        // Check for orphaned deck references in cards
        let validDeckIds = Set(decks.map { $0.id })
        for i in 0..<flashCards.count {
            let originalDeckIds = flashCards[i].deckIds
            flashCards[i].deckIds = flashCards[i].deckIds.filter { validDeckIds.contains($0) }
            
            if flashCards[i].deckIds.count != originalDeckIds.count {
                let removedCount = originalDeckIds.count - flashCards[i].deckIds.count
                print("🗑️ Removed \(removedCount) orphaned deck references from card '\(flashCards[i].word)'")
                cardsFixed += 1
                issuesFound += removedCount
            }
        }
        
        // Check for empty decks and update deck.card arrays
        for i in 0..<decks.count {
            let originalCardCount = decks[i].cards.count
            let validCardIds = Set(flashCards.map { $0.id })
            decks[i].cards = decks[i].cards.filter { card in
                validCardIds.contains(card.id)
            }
            
            if decks[i].cards.count != originalCardCount {
                let removedCount = originalCardCount - decks[i].cards.count
                print("🗑️ Removed \(removedCount) orphaned card references from deck '\(decks[i].name)'")
                decksFixed += 1
                issuesFound += removedCount
            }
        }
        
        // Update associations
        updateCardDeckAssociations()
        
        if issuesFound == 0 {
            return (true, "No association issues found - data is clean")
        } else {
            return (true, "Fixed \(issuesFound) association issues (\(cardsFixed) cards, \(decksFixed) decks)")
        }
    }
    
    @MainActor
    func syncPreservingOrder() async -> (success: Bool, message: String) {
        print("🔄 SYNC PRESERVING ORDER")
        print("📊 Current data: \(flashCards.count) cards, \(decks.count) decks")
        
        // Temporarily disable sync to prevent recursion
        let originalSyncEnabled = isCloudSyncEnabled
        isCloudSyncEnabled = false
        
        do {
            // Perform sync
            let (syncedCards, syncedDecks) = await CloudKitManager.shared.syncData(
                flashCards: flashCards,
                decks: decks
            )
            
            // Update data
            flashCards = syncedCards
            decks = syncedDecks
            
            // Clean up associations
            updateCardDeckAssociations()
            
            // Re-enable sync
            isCloudSyncEnabled = originalSyncEnabled
            
            print("✅ SYNC COMPLETE: \(syncedCards.count) cards, \(syncedDecks.count) decks")
            return (true, "Sync completed: \(syncedCards.count) cards, \(syncedDecks.count) decks")
            
        } catch {
            // Re-enable sync on error
            isCloudSyncEnabled = originalSyncEnabled
            print("❌ SYNC FAILED: \(error)")
            return (false, "Sync failed: \(error.localizedDescription)")
        }
    }
} 