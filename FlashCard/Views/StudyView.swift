import SwiftUI

struct StudyView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cards: [FlashCard]
    @State private var currentIndex = 0
    @State private var knownCards: Set<UUID> = []
    @State private var unknownCards: Set<UUID> = []
    @State private var showingResults = false
    @State private var isShowingFront = true
    @State private var isShowingExample = false
    @State private var dragOffset: CGFloat = 0
    @State private var nextCardActive = false
    @State private var selectedCardForEdit: FlashCard?
    @State private var showingCloseConfirmation = false
    @State private var refreshID = UUID()
    @Environment(\.dismiss) private var dismiss
    
    // Save state properties
    private var deckIds: [UUID]
    private var shouldLoadSaveState: Bool
    
    // Computed property to check if user has seen any cards
    private var hasSeenCards: Bool {
        return !knownCards.isEmpty || !unknownCards.isEmpty
    }
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return currentIndex > 0 || hasSeenCards
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard], deckIds: [UUID] = [], shouldLoadSaveState: Bool = false) {
        self.viewModel = viewModel
        _cards = State(initialValue: cards)
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
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    handleBackButton()
                }) {
                    VStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    setupStudySession()
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Reset")
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Save progress button
                if hasSignificantProgress && !showingResults {
                    Button(action: {
                        saveCurrentProgress()
                        HapticManager.shared.successNotification()
                    }) {
                        VStack {
                            Image(systemName: "bookmark.fill")
                            Text("Save")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .opacity(0.2),
                alignment: .top
            )
        }
        .navigationBarHidden(true)
        .alert("Close Study Session?", isPresented: $showingCloseConfirmation) {
            Button("Save & Close", role: .destructive) {
                saveProgressAndDismiss()
            }
            Button("Close Without Saving") {
                dismissToRoot()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text(hasSignificantProgress ? 
                "Would you like to save your progress?" : 
                "Are you sure you want to close?")
        }
        .sheet(item: $selectedCardForEdit) { card in
            EditCardView(viewModel: viewModel, card: card)
                .onAppear {
                    print("📝 Edit sheet appeared for card: \(card.word)")
                }
                .onDisappear {
                    print("📝 Edit sheet disappeared")
                }
        }
        .onChange(of: selectedCardForEdit) { oldValue, newValue in
            // Just print when edit is done - don't try to update game state
            if oldValue != nil && newValue == nil {
                print("📝 Edit completed - card saved in viewModel")
            }
        }
        .onChange(of: cards) { oldCards, newCards in
            print("📚 Cards array changed - Count: \(newCards.count), Current card: \(currentIndex < newCards.count ? newCards[currentIndex].word : "N/A")")
        }
        .onAppear {
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
                nextCardActive = false
                knownCards.removeAll()
                unknownCards.removeAll()
                cards = cards.shuffled() // Reshuffle cards for new session
                // Don't clear saved progress here - only when explicitly resetting
            }
        }
        .onDisappear {
            // Auto-save when view disappears (if user navigates away without using back button)
            if hasSignificantProgress && !showingResults {
                saveCurrentProgress()
            }
        }
    }
    
    private var studyView: some View {
        ZStack {
            // Background color for swipe feedback
            Color.white  // Add default white background
                .ignoresSafeArea()
            
            Color.green
                .opacity(dragOffset > 0 ? min(dragOffset / 500, 0.3) : 0)
                .ignoresSafeArea()
            
            Color.red
                .opacity(dragOffset < 0 ? min(-dragOffset / 500, 0.3) : 0)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Progress indicator with edit button - with top padding for status bar
                HStack {
                    Text("\(currentIndex + 1) of \(cards.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    
                    HStack(spacing: 20) {
                        Label("\(knownCards.count)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Label("\(unknownCards.count)", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 50) // Add top padding for status bar
                
                Spacer()
                
                // Single card view
                if currentIndex < cards.count {
                    ZStack {
                        CardView(
                            card: cards[currentIndex],
                            isShowingFront: $isShowingFront,
                            isShowingExample: $isShowingExample,
                            viewModel: viewModel,
                            onSwipeLeft: {
                                handleSwipeLeft()
                            },
                            onSwipeRight: {
                                handleSwipeRight()
                            },
                            onDragChanged: { offset in
                                dragOffset = offset
                            }
                        )
                        .transition(AnyTransition.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity.combined(with: .offset(x: dragOffset, y: 0))
                        ))
                        .id("\(cards[currentIndex].id)-\(refreshID)")
                        .onAppear {
                            print("🎴 CardView appeared - Showing: \(cards[currentIndex].word) - \(cards[currentIndex].definition)")
                        }
                        .blur(radius: 0)
                    }
                }
                
                Spacer()
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
    
    private func handleBackButton() {
        if hasSeenCards && !showingResults {
            showingCloseConfirmation = true
        } else {
            dismiss()
        }
    }
    
    private func saveCurrentProgress() {
        guard !deckIds.isEmpty && hasSignificantProgress else { return }
        
        let gameState = StudyGameState(
            currentIndex: currentIndex,
            knownCards: knownCards,
            unknownCards: unknownCards,
            isShowingFront: isShowingFront,
            isShowingExample: isShowingExample,
            cards: cards
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .study,
            deckIds: deckIds,
            gameData: gameState
        )
        
        print("💾 Study progress saved - Index: \(currentIndex), Known: \(knownCards.count), Unknown: \(unknownCards.count)")
    }
    
    private func loadSavedProgress() {
        guard !deckIds.isEmpty else { 
            // If no deckIds, just start normally
            setupStudySession()
            return 
        }
        
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .study,
            deckIds: deckIds,
            as: StudyGameState.self
        ) {
            // Restore state
            currentIndex = savedState.currentIndex
            knownCards = savedState.knownCards
            unknownCards = savedState.unknownCards
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
            
            print("📖 Study progress loaded - Index: \(currentIndex), Known: \(knownCards.count), Unknown: \(unknownCards.count)")
            
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("📖 No saved state found, starting fresh study session")
            setupStudySession()
        }
    }
    
    private func clearSavedProgress() {
        guard !deckIds.isEmpty else { return }
        
        SaveStateManager.shared.deleteSaveState(
            gameType: .study,
            deckIds: deckIds
        )
    }
    
    private func resetForNewSession() {
        currentIndex = 0
        showingResults = false
        isShowingFront = true
        isShowingExample = false
        dragOffset = 0
        nextCardActive = false
        knownCards.removeAll()
        unknownCards.removeAll()
        
        // Clear any saved progress when starting fresh
        clearSavedProgress()
    }
    
    private func setupStudySession() {
        currentIndex = 0
        showingResults = false
        isShowingFront = true
        isShowingExample = false
        dragOffset = 0
        nextCardActive = false
        knownCards.removeAll()
        unknownCards.removeAll()
        cards = cards.shuffled() // Reshuffle cards for new session
        
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
    
    private func handleSwipeRight() {
        HapticManager.shared.cardSwipeRight() // Success haptic for "I know this"
        let cardId = cards[currentIndex].id
        knownCards.insert(cardId)
        unknownCards.remove(cardId)
        
        // Track progress - swipe right means correct answer
        viewModel.recordCardShown(cardId)
        viewModel.recordCardCorrect(cardId)
        viewModel.setCardStatus(cardId: cardId, status: .known)
        
        withAnimation(.easeOut(duration: 0.3)) {
            moveToNextCard()
        }
    }
    
    private func handleSwipeLeft() {
        HapticManager.shared.cardSwipeLeft() // Warning haptic for "I don't know this"
        let cardId = cards[currentIndex].id
        unknownCards.insert(cardId)
        knownCards.remove(cardId)
        
        // Track progress - swipe left means incorrect answer
        viewModel.recordCardShown(cardId)
        viewModel.recordCardIncorrect(cardId)
        viewModel.setCardStatus(cardId: cardId, status: .unknown)
        
        withAnimation(.easeOut(duration: 0.3)) {
            moveToNextCard()
        }
    }
    
    private func moveToNextCard() {
        if currentIndex < cards.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentIndex += 1
                isShowingFront = true
                isShowingExample = false
                dragOffset = 0
                
                // Auto-save progress periodically (every 5 cards)
                if currentIndex % 5 == 0 {
                    saveCurrentProgress()
                }
            }
        } else {
            HapticManager.shared.gameComplete() // Strong haptic for session completion
            
            // Clear saved progress since session is complete
            clearSavedProgress()
            
            withAnimation {
                showingResults = true
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
} 