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
    
    // Computed property to check if user has seen any cards
    private var hasSeenCards: Bool {
        return !knownCards.isEmpty || !unknownCards.isEmpty
    }
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard]) {
        self.viewModel = viewModel
        _cards = State(initialValue: cards)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if cards.isEmpty {
                emptyStateView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if showingResults {
                resultsView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                studyView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    if hasSeenCards && !showingResults {
                        showingCloseConfirmation = true
                    } else {
                        dismiss()
                    }
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
            Button("Close", role: .destructive) {
                saveProgressAndDismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to close? Your progress will be saved.")
        }
        .sheet(item: $selectedCardForEdit) { card in
            EditCardView(viewModel: viewModel, card: card)
        }
        .onChange(of: selectedCardForEdit) { oldValue, newValue in
            // Refresh the cards when returning from EditCardView
            if oldValue != nil && newValue == nil {
                // Update the current card with the latest data from viewModel
                if currentIndex < cards.count {
                    let cardId = cards[currentIndex].id
                    if let updatedCard = viewModel.flashCards.first(where: { $0.id == cardId }) {
                        cards[currentIndex] = updatedCard
                        refreshID = UUID() // Force CardView refresh
                    }
                }
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
                    
                    // Edit button
                    if currentIndex < cards.count {
                        Button(action: {
                            selectedCardForEdit = cards[currentIndex]
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                        .padding(.trailing, 8)
                    }
                    
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
                    CardView(
                        card: cards[currentIndex],
                        isShowingFront: $isShowingFront,
                        isShowingExample: $isShowingExample,
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
                    .id("\(currentIndex)-\(refreshID)")
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
    
    private func resetForNewSession() {
        currentIndex = 0
        showingResults = false
        isShowingFront = true
        isShowingExample = false
        dragOffset = 0
        nextCardActive = false
        knownCards.removeAll()
        unknownCards.removeAll()
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
    }
    
    private func saveProgressAndDismiss() {
        // Save the status of all cards
        for cardId in knownCards {
            viewModel.setCardStatus(cardId: cardId, status: .known)
        }
        for cardId in unknownCards {
            viewModel.setCardStatus(cardId: cardId, status: .unknown)
        }
        dismissToRoot()
    }
    
    private func handleSwipeRight() {
        HapticManager.shared.cardSwipeRight() // Success haptic for "I know this"
        let cardId = cards[currentIndex].id
        knownCards.insert(cardId)
        unknownCards.remove(cardId)
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
            }
        } else {
            HapticManager.shared.gameComplete() // Strong haptic for session completion
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