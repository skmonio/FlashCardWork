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
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: FlashCardViewModel, cards: [FlashCard]) {
        self.viewModel = viewModel
        _cards = State(initialValue: cards)
    }
    
    var body: some View {
        VStack {
            if cards.isEmpty {
                emptyStateView
            } else if showingResults {
                resultsView
            } else {
                studyView
            }
            
            Spacer()
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    VStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    dismiss()
                }) {
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    knownCards.removeAll()
                    unknownCards.removeAll()
                    currentIndex = 0
                    showingResults = false
                    isShowingFront = true
                    isShowingExample = false
                    nextCardActive = false
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
            
            VStack {
                // Progress indicator
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
                    .id(currentIndex)
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
                    dismiss()
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
} 