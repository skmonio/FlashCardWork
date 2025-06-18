import SwiftUI

struct StudyView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var knownCards: Set<UUID> = []
    @State private var unknownCards: Set<UUID> = []
    @State private var skippedCards: Set<UUID> = []
    @State private var showingResults = false
    @State private var isShowingFront = true
    @State private var isShowingExample = false
    @State private var dragOffset: CGFloat = 0
    @State private var verticalDragOffset: CGFloat = 0
    @State private var nextCardActive = false
    @State private var selectedCardForEdit: FlashCard?
    @State private var refreshID = UUID()
    @State private var forceRefreshID = UUID()
    @State private var showingCloseConfirmation = false
    @Environment(\.dismiss) private var dismiss
    
    // Add speech service for pronunciation
    @ObservedObject private var speechService = DutchSpeechService.shared
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Get the text to speak for current card
    private var textToSpeak: String {
        guard let card = currentCard else { return "" }
        return card.article.isEmpty ? card.word : "\(card.article) \(card.word)"
    }
    
    // Check if current word is being spoken
    private var isCurrentTextSpeaking: Bool {
        return speechService.isSpeaking && speechService.currentlySpeaking == textToSpeak
    }
    
    // Speech function
    private func speakCurrentText(_ text: String) {
        guard !text.isEmpty else { return }
        speechService.speakDutch(text, rate: 0.4)
    }
    
    // Computed property to check if user has seen any cards
    private var hasSeenCards: Bool {
        return !knownCards.isEmpty || !unknownCards.isEmpty || !skippedCards.isEmpty
    }
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return currentIndex > 0 || hasSeenCards
    }
    
    // Computed property for score (known cards)
    private var score: Int {
        return knownCards.count * 10
    }
    
    // Computed property for combo (consecutive known cards)
    private var combo: Int {
        // Simple combo calculation - could be enhanced
        return knownCards.count >= 3 ? knownCards.count : 0
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        // Apply intelligent ordering: less-known cards first, well-known cards later
        _cards = State(initialValue: viewModel.sortCardsForLearning(cards))
        self.deckIds = deckIds
        self.shouldLoadSaveState = shouldLoadSaveState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if cards.isEmpty {
                emptyStateView
            } else if showingResults {
                resultsView
            } else {
                studyView
            }
            
            // Unified footer
            GameFooterView(
                hasSignificantProgress: hasSignificantProgress,
                showingResults: showingResults,
                onClose: dismissToRoot,
                onSaveAndClose: saveProgressAndDismiss,
                onPrevious: nil,
                canGoPrevious: false
            )
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedCardForEdit) { card in
            EditCardView(viewModel: viewModel, card: card)
                .onAppear {
                    print("📝 Edit sheet appeared for card: \(card.word)")
                }
                .onDisappear {
                    print("📝 Edit sheet disappeared")
                }
        }
        .onChange(of: selectedCardForEdit) { newValue in
            // Just print when edit is done - don't try to update game state
            if newValue == nil {
                print("📝 Edit completed - card saved in viewModel")
            }
        }
        .onChange(of: cards) { newCards in
            print("📚 Cards array changed - Count: \(newCards.count), Current card: \(currentIndex < newCards.count ? newCards[currentIndex].word : "N/A")")
        }
        .onChange(of: currentIndex) { newIndex in
            print("📇 Current index changed to: \(newIndex)")
            if newIndex < cards.count {
                print("📇 Now showing card: \(cards[newIndex].word)")
            }
        }
        .onAppear {
            // Pause CloudKit sync during active study session to prevent interference
            viewModel.pauseCloudKitSync()
            
            if shouldLoadSaveState {
                loadSavedProgress()  
            } else {
                // Initialize normally if not loading save state
                // Don't call setupStudySession() as it deletes save states
                currentIndex = 0
                showingResults = false
                isShowingFront = true
                isShowingExample = false
                dragOffset = 0
                verticalDragOffset = 0
                nextCardActive = false
                knownCards.removeAll()
                unknownCards.removeAll()
                skippedCards.removeAll()
                cards = viewModel.sortCardsForLearning(cards) // Use intelligent ordering for new session
                // Don't clear saved progress here - only when explicitly resetting
            }
        }
        .onDisappear {
            // Resume CloudKit sync when leaving study session
            viewModel.resumeCloudKitSync()
            
            // Auto-save when view disappears (if user navigates away without using back button)
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
    }
    
    // Computed property for current card to make SwiftUI detect changes better
    private var currentCard: FlashCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }
    
    private var studyView: some View {
        ZStack {
            // Default background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // Green radial gradient for swipe right (Know it)
            if dragOffset > 0 {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.green.opacity(min(dragOffset / 200, 0.8)),
                        Color.green.opacity(min(dragOffset / 300, 0.5)),
                        Color.green.opacity(min(dragOffset / 500, 0.2)),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 800
                )
                .ignoresSafeArea(.all)
                .animation(.easeOut(duration: 0.3), value: dragOffset)
            }
            
            // Red radial gradient for swipe left (Don't know)
            if dragOffset < 0 {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.red.opacity(min(-dragOffset / 200, 0.8)),
                        Color.red.opacity(min(-dragOffset / 300, 0.5)),
                        Color.red.opacity(min(-dragOffset / 500, 0.2)),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 800
                )
                .ignoresSafeArea(.all)
                .animation(.easeOut(duration: 0.3), value: dragOffset)
            }
            
            // Yellow radial gradient for swipe up (Review)
            if verticalDragOffset < 0 {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.yellow.opacity(min(-verticalDragOffset / 200, 0.8)),
                        Color.yellow.opacity(min(-verticalDragOffset / 300, 0.5)),
                        Color.yellow.opacity(min(-verticalDragOffset / 500, 0.2)),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 800
                )
                .ignoresSafeArea(.all)
                .animation(.easeOut(duration: 0.3), value: verticalDragOffset)
            }
            
            // Blue radial gradient for swipe down (Skip)
            if verticalDragOffset > 0 {
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(min(verticalDragOffset / 200, 0.8)),
                        Color.blue.opacity(min(verticalDragOffset / 300, 0.5)),
                        Color.blue.opacity(min(verticalDragOffset / 500, 0.2)),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 800
                )
                .ignoresSafeArea(.all)
                .animation(.easeOut(duration: 0.3), value: verticalDragOffset)
            }
            
            VStack(spacing: 0) {
                // Unified header with progress bar
                GameHeaderView(
                    currentIndex: currentIndex + 1,
                    totalCards: cards.count,
                    score: score,
                    combo: combo,
                    knownCount: nil,
                    unknownCount: nil,
                    skippedCount: nil
                )
                
                Spacer()
                
                // Single card view using unified component
                if let card = currentCard {
                    GameCardView(
                        card: card,
                        isShowingFront: $isShowingFront,
                        isShowingExample: $isShowingExample,
                        onSwipeLeft: {
                            handleSwipeLeft()
                        },
                        onSwipeRight: {
                            handleSwipeRight()
                        },
                        onSwipeUp: {
                            handleSwipeUp() // Now review
                        },
                        onSwipeDown: {
                            handleSwipeDown() // Now skip
                        },
                        onDragChanged: { offset in
                            dragOffset = offset
                        },
                        onVerticalDragChanged: { offset in
                            verticalDragOffset = offset
                        }
                    )
                    .id("\(card.id)-\(forceRefreshID)") // Combined unique ID to force refresh
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
                
                Spacer()
                
                // Swipe hint with updated directions
                // swipeHintView
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.stack.3d.up.slash")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to study")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 20) {
            Text("Study Session Complete! 🎉")
                .font(.title)
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Known: \(knownCards.count) cards")
                        .foregroundColor(.green)
                }
                
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("Need Review: \(unknownCards.count) cards")
                        .foregroundColor(.red)
                }
                
                HStack {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.blue)
                    Text("Skipped: \(skippedCards.count) cards")
                        .foregroundColor(.blue)
                }
            }
            .font(.title3)
            
            VStack(spacing: 16) {
                Button(action: {
                    // Save the status of all cards
                    for cardId in knownCards {
                        viewModel.setCardStatus(cardId: cardId, status: .known)
                    }
                    for cardId in unknownCards {
                        viewModel.setCardStatus(cardId: cardId, status: .unknown)
                    }
                    
                    // Explicitly save all ViewModel data to ensure statistics persist
                    viewModel.saveAllData()
                    
                    // Force UI refresh
                    DispatchQueue.main.async {
                        viewModel.objectWillChange.send()
                    }
                    
                    // Reset all states for new session
                    resetForNewSession()
                }) {
                    Text("Study All Cards Again")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                if !unknownCards.isEmpty {
                    Button(action: {
                        // Save the status of all cards
                        for cardId in knownCards {
                            viewModel.setCardStatus(cardId: cardId, status: .known)
                        }
                        for cardId in unknownCards {
                            viewModel.setCardStatus(cardId: cardId, status: .unknown)
                        }
                        
                        // Explicitly save all ViewModel data to ensure statistics persist
                        viewModel.saveAllData()
                        
                        // Force UI refresh
                        DispatchQueue.main.async {
                            viewModel.objectWillChange.send()
                        }
                        
                        // Filter cards to only unknown ones and restart
                        cards = cards.filter { unknownCards.contains($0.id) }
                        resetForNewSession()
                    }) {
                        Text("Review Unknown Cards")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                }
                
                Button(action: {
                    // Save the status of all cards before dismissing
                    for cardId in knownCards {
                        viewModel.setCardStatus(cardId: cardId, status: .known)
                    }
                    for cardId in unknownCards {
                        viewModel.setCardStatus(cardId: cardId, status: .unknown)
                    }
                    dismissToRoot()
                }) {
                    Text("Done")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top)
        }
        .padding()
    }
    
    private func handleSwipeRight() {
        print("👆 SWIPE RIGHT - Starting handler")
        print("👆 Current state: index=\(currentIndex), card='\(cards[currentIndex].word)'")
        
        HapticManager.shared.cardSwipeRight() // Success haptic for "I know this"
        let cardId = cards[currentIndex].id
        knownCards.insert(cardId)
        unknownCards.remove(cardId)
        viewModel.setCardStatus(cardId: cardId, status: .known)
        
        print("👆 About to record card shown...")
        // Record learning statistics - card was shown and answered correctly
        viewModel.recordCardShown(cardId, isCorrect: true)
        print("👆 Card shown recorded, about to move to next card...")
        
        withAnimation(.easeOut(duration: 0.3)) {
            moveToNextCard()
        }
        print("👆 SWIPE RIGHT - Handler complete")
    }
    
    private func handleSwipeLeft() {
        print("👈 SWIPE LEFT - Starting handler")
        print("👈 Current state: index=\(currentIndex), card='\(cards[currentIndex].word)'")
        
        HapticManager.shared.cardSwipeLeft() // Warning haptic for "I don't know this"
        let cardId = cards[currentIndex].id
        unknownCards.insert(cardId)
        knownCards.remove(cardId)
        viewModel.setCardStatus(cardId: cardId, status: .unknown)
        
        print("👈 About to record card shown...")
        // Record learning statistics - card was shown and answered incorrectly
        viewModel.recordCardShown(cardId, isCorrect: false)
        print("👈 Card shown recorded, about to move to next card...")
        
        withAnimation(.easeOut(duration: 0.3)) {
            moveToNextCard()
        }
        print("👈 SWIPE LEFT - Handler complete")
    }
    
    private func handleSwipeUp() {
        print("👆 SWIPE UP - Starting handler")
        print("👆 Current state: index=\(currentIndex), card='\(cards[currentIndex].word)'")
        
        HapticManager.shared.mediumImpact() // Medium haptic for "review this"
        let cardId = cards[currentIndex].id
        skippedCards.insert(cardId)
        knownCards.remove(cardId)
        unknownCards.remove(cardId)
        
        print("👆 About to add card to review...")
        // Add card to review deck
        viewModel.addCardToReview(cardId)
        print("👆 Card added to review, about to move to next card...")
        
        // Record as skipped (not counted in learning statistics)
        print("📋 Card '\(cards[currentIndex].word)' added to review - skipped")
        
        withAnimation(.easeOut(duration: 0.3)) {
            moveToNextCard()
        }
        print("👆 SWIPE UP - Handler complete")
    }
    
    private func handleSwipeDown() {
        print("👇 SWIPE DOWN - Starting handler")
        print("👇 Current state: index=\(currentIndex), card='\(cards[currentIndex].word)'")
        
        HapticManager.shared.lightImpact() // Light haptic for "skip"
        let cardId = cards[currentIndex].id
        skippedCards.insert(cardId)
        knownCards.remove(cardId)
        unknownCards.remove(cardId)
        
        // Just skip without adding to review deck
        print("⏭️ Card '\(cards[currentIndex].word)' skipped")
        
        withAnimation(.easeOut(duration: 0.3)) {
            moveToNextCard()
        }
        print("👇 SWIPE DOWN - Handler complete")
    }
    
    private func moveToNextCard() {
        print("🃏 moveToNextCard called - currentIndex: \(currentIndex), cards.count: \(cards.count)")
        
        if currentIndex < cards.count - 1 {
            print("🃏 Moving to next card: \(currentIndex) -> \(currentIndex + 1)")
            
            // Reset card display state BEFORE changing index
            isShowingFront = true
            isShowingExample = false
            dragOffset = 0
            verticalDragOffset = 0
            
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
            }
            
            // Force UI refresh
            forceRefreshID = UUID()
            
            print("🃏 Card updated - now showing: \(cards[currentIndex].word)")
            print("🃏 Current card ID: \(cards[currentIndex].id)")
            print("🃏 isShowingFront: \(isShowingFront)")
            print("🃏 forceRefreshID updated: \(forceRefreshID)")
            
            // Auto-save progress periodically (every 5 cards)
            if currentIndex % 5 == 0 {
                saveCurrentProgress()
            }
        } else {
            print("🃏 Reached end of cards - showing results")
            HapticManager.shared.gameComplete() // Strong haptic for session completion
            
            // Clear saved progress since session is complete
            clearSavedProgress()
            
            // Resume CloudKit sync when session completes
            viewModel.resumeCloudKitSync()
            
            withAnimation {
                StreakManager.shared.recordGameCompletion(); showingResults = true
            }
        }
    }
    
    private func goToPreviousCard() {
        if currentIndex > 0 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex -= 1
                isShowingFront = true
                isShowingExample = false
                dragOffset = 0
                verticalDragOffset = 0
                
                // Auto-save progress periodically (every 5 cards)
                if currentIndex % 5 == 0 {
                    saveCurrentProgress()
                }
            }
        }
    }
    
    private func dismissToRoot() {
        // Send notification to dismiss all views
        NotificationCenter.default.post(name: NSNotification.Name("DismissToRoot"), object: nil)
        
        // Also trigger ViewModel navigation
        viewModel.navigateToRoot()
        
        // Fallback with multiple dismissals
        dismiss()
        for i in 1...8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                dismiss()
            }
        }
    }
    
    private func saveCurrentProgress() {
        guard hasSignificantProgress else { return }
        
        let gameState = StudyGameState(
            currentIndex: currentIndex,
            knownCards: knownCards,
            unknownCards: unknownCards,
            skippedCards: skippedCards,
            isShowingFront: isShowingFront,
            isShowingExample: isShowingExample,
            cards: cards
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .study,
            gameData: gameState
        )
        
        print("💾 Study progress saved - Index: \(currentIndex), Known: \(knownCards.count), Unknown: \(unknownCards.count), Skipped: \(skippedCards.count)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .study,
            as: StudyGameState.self
        ) {
            // Restore state
            currentIndex = savedState.currentIndex
            knownCards = savedState.knownCards
            unknownCards = savedState.unknownCards
            skippedCards = savedState.skippedCards
            isShowingFront = savedState.isShowingFront
            isShowingExample = savedState.isShowingExample
            
            // Update cards to match saved order if they exist
            if !savedState.cards.isEmpty {
                // Filter to only include cards that still exist in the current deck selection
                let currentCardIds = Set(cards.map { $0.id })
                let savedCards = savedState.cards.filter { currentCardIds.contains($0.id) }
                
                if !savedCards.isEmpty {
                    cards = savedCards
                }
            }
            
            // Ensure currentIndex is valid
            if currentIndex >= cards.count {
                currentIndex = max(0, cards.count - 1)
            }
            
            print("📖 Study progress loaded - Index: \(currentIndex), Known: \(knownCards.count), Unknown: \(unknownCards.count), Skipped: \(skippedCards.count)")
            
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("📖 No saved state found, starting fresh study session")
            setupStudySession()
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .study)
    }
    
    private func resetForNewSession() {
        currentIndex = 0
        showingResults = false
        isShowingFront = true
        isShowingExample = false
        dragOffset = 0
        verticalDragOffset = 0
        nextCardActive = false
        knownCards.removeAll()
        unknownCards.removeAll()
        skippedCards.removeAll()
        
        // Clear any saved progress when starting fresh
        clearSavedProgress()
    }
    
    private func setupStudySession() {
        currentIndex = 0
        showingResults = false
        isShowingFront = true
        isShowingExample = false
        dragOffset = 0
        verticalDragOffset = 0
        nextCardActive = false
        knownCards.removeAll()
        unknownCards.removeAll()
        skippedCards.removeAll()
        cards = viewModel.sortCardsForLearning(cards) // Use intelligent ordering for new session
        
        // Clear any saved progress when resetting
        clearSavedProgress()
    }
    
    private func saveProgressAndDismiss() {
        // Save the status of all cards
        for cardId in knownCards {
            viewModel.setCardStatus(cardId: cardId, status: .known)
        }
        for cardId in unknownCards {
            viewModel.setCardStatus(cardId: cardId, status: .unknown)
        }
        
        // Save current progress
        if hasSignificantProgress && !showingResults {
            saveCurrentProgress()
        }
        
        dismissToRoot()
    }
} 