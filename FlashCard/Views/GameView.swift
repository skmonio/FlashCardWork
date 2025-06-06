import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let content: String
    let type: CardType
    let originalCard: FlashCard
    var isMatched = false
    var isSelected = false
    var showWrongAnimation = false
    
    enum CardType {
        case word
        case definition
    }
}

struct GameView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    @Environment(\.dismiss) private var dismiss
    @State private var gameCards: [Card] = []
    @State private var displayedCards: [Card] = []
    @State private var remainingCards: [Card] = []
    @State private var selectedCard: Card?
    @State private var score = 0
    @State private var moves = 0
    @State private var showingGameOver = false
    @State private var incorrectMatches: Set<FlashCard> = []
    @State private var showingReview = false
    @State private var reviewCards: [FlashCard] = []
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                if cards.isEmpty {
                    emptyStateView
                } else {
                    gameView
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
                        setupGame()
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
            
            if showingGameOver {
                // Semi-transparent background
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                // Game over popup
                VStack(spacing: 20) {
                    // Score summary
                    VStack(spacing: 10) {
                        Text("Game Complete! 🎉")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("You completed the game in \(moves) moves!")
                            .font(.headline)
                    }
                    .padding(.top)
                    
                    // Action buttons
                    VStack(spacing: 15) {
                        Button(action: {
                            setupGame()
                            showingGameOver = false
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Return to Home")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
            }
        }
        .navigationBarHidden(true)
        .onAppear(perform: setupGame)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            Text("No cards to play")
                .font(.title2)
            Text("Add some cards to get started!")
                .foregroundColor(.secondary)
        }
    }
    
    private var gameView: some View {
        VStack {
            // Score and moves
            HStack {
                Text("Matches: \(score)")
                    .font(.headline)
                Spacer()
                Text("Moves: \(moves)")
                    .font(.headline)
            }
            .padding()
            
            // Game grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<8) { index in
                        if index < displayedCards.count {
                            GameCardView(card: displayedCards[index]) {
                                cardTapped(displayedCards[index])
                            }
                            .opacity(displayedCards[index].isMatched ? 0 : 1)
                        } else {
                            // Empty space to maintain grid
                            Color.clear
                                .frame(height: 110)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    private func setupGame() {
        // Reset game state
        score = 0
        moves = 0
        selectedCard = nil
        
        // Create pairs of cards (word and definition)
        var allPairs: [(Card, Card)] = cards.map { flashCard in
            let wordCard = Card(content: flashCard.word, type: .word, originalCard: flashCard)
            let defCard = Card(content: flashCard.definition, type: .definition, originalCard: flashCard)
            return (wordCard, defCard)
        }
        
        // Shuffle the pairs
        allPairs.shuffle()
        
        // Take first 4 pairs for display (8 cards total)
        displayedCards = Array(allPairs.prefix(4)).flatMap { [$0.0, $0.1] }
        // Store remaining pairs
        remainingCards = Array(allPairs.dropFirst(4)).flatMap { [$0.0, $0.1] }
        // Shuffle the displayed cards
        displayedCards.shuffle()
        
        gameCards = displayedCards + remainingCards
    }
    
    private func replaceMatchedCards() {
        // If we still have cards to add
        if !remainingCards.isEmpty {
            // Find indices of matched cards
            let matchedIndices = displayedCards.enumerated()
                .filter { $0.element.isMatched }
                .map { $0.offset }
            
            // Create new cards
            var newCards: [Card] = []
            for _ in matchedIndices {
                guard !remainingCards.isEmpty else { break }
                var newCard = remainingCards.removeFirst()
                newCard.isSelected = false
                newCard.isMatched = false
                newCard.showWrongAnimation = false
                newCards.append(newCard)
            }
            
            // Replace all matched cards at once
            for (index, matchedIndex) in matchedIndices.enumerated() {
                guard index < newCards.count else { break }
                displayedCards[matchedIndex] = newCards[index]
            }
        }
    }
    
    private func cardTapped(_ tappedCard: Card) {
        guard let index = displayedCards.firstIndex(where: { $0.id == tappedCard.id }) else { return }
        
        // Ignore tapped card if it's already matched or selected, or if two cards are already selected
        if displayedCards[index].isMatched || displayedCards[index].isSelected || 
           displayedCards.filter({ $0.isSelected }).count >= 2 {
            return
        }
        
        // If this is the first card of the pair
        if selectedCard == nil {
            displayedCards[index].isSelected = true
            selectedCard = displayedCards[index]
            return
        }
        
        // This is the second card
        moves += 1
        
        if let selectedIndex = displayedCards.firstIndex(where: { $0.id == selectedCard?.id }) {
            if selectedCard?.originalCard.id == tappedCard.originalCard.id &&
               selectedCard?.type != tappedCard.type {
                // It's a match! Show second card as green
                displayedCards[index].isSelected = true
                
                // After a brief delay, mark them as matched
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // Clear selection and set matched state
                    displayedCards[selectedIndex].isSelected = false
                    displayedCards[index].isSelected = false
                    displayedCards[selectedIndex].isMatched = true
                    displayedCards[index].isMatched = true
                    
                    // Replace matched cards after fade out
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        replaceMatchedCards()
                        
                        // Check if this was the last pair
                        let unmatchedCards = displayedCards.filter { !$0.isMatched }
                        if unmatchedCards.isEmpty && remainingCards.isEmpty {
                            showingGameOver = true
                        }
                    }
                }
            } else {
                // Not a match - show wrong animation immediately
                displayedCards[index].showWrongAnimation = true
                
                // Track incorrect matches
                incorrectMatches.insert(selectedCard!.originalCard)
                incorrectMatches.insert(tappedCard.originalCard)
                
                // Reset both cards after a brief delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    displayedCards[selectedIndex].isSelected = false
                    displayedCards[index].showWrongAnimation = false
                }
            }
            
            // Reset selected card
            selectedCard = nil
        }
    }
}

struct GameCardView: View {
    let card: Card
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .shadow(radius: 3)
                
                if !card.isMatched {
                    Text(card.content)
                        .font(.body)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .padding()
                        .opacity(card.isMatched ? 0 : 1)
                }
            }
        }
        .frame(height: 110)
        .animation(nil, value: card.isSelected)
        .animation(nil, value: card.showWrongAnimation)
    }
    
    private var backgroundColor: Color {
        if card.isSelected {
            return .green.opacity(0.3)
        } else if card.showWrongAnimation {
            return .red.opacity(0.3)
        } else {
            return .white
        }
    }
} 