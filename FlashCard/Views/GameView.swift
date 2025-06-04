import SwiftUI

struct Card: Identifiable {
    let id = UUID()
    let content: String
    let type: CardType
    let originalCard: FlashCard
    var isMatched = false
    var isFaceUp = false
    
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
    @State private var selectedCard: Card?
    @State private var score = 0
    @State private var moves = 0
    @State private var showingGameOver = false
    @State private var matchAnimation: Card?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            if cards.isEmpty {
                emptyStateView
            } else {
                gameView
            }
        }
        .navigationTitle("Memory Game")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: setupGame)
        .alert("Game Complete! 🎉", isPresented: $showingGameOver) {
            Button("Play Again") {
                setupGame()
            }
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("You completed the game in \(moves) moves!")
        }
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
                    ForEach(gameCards) { card in
                        GameCardView(card: card) {
                            cardTapped(card)
                        }
                        .rotation3DEffect(
                            .degrees(card.isFaceUp ? 0 : 180),
                            axis: (x: 0, y: 1, z: 0)
                        )
                        .opacity(card.isMatched ? 0.5 : 1)
                        .scaleEffect(matchAnimation?.id == card.id ? 1.2 : 1)
                        .animation(.easeInOut(duration: 0.3), value: card.isFaceUp)
                        .animation(.easeInOut(duration: 0.3), value: card.isMatched)
                        .animation(.spring(response: 0.3, dampingFraction: 0.3), value: matchAnimation?.id == card.id)
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
        gameCards = []
        for flashCard in cards {
            gameCards.append(Card(content: flashCard.word, type: .word, originalCard: flashCard))
            gameCards.append(Card(content: flashCard.definition, type: .definition, originalCard: flashCard))
        }
        
        // Shuffle the cards
        gameCards.shuffle()
    }
    
    private func cardTapped(_ card: Card) {
        // Ignore taps on matched or face-up cards
        if card.isMatched || card.isFaceUp {
            return
        }
        
        // Find the index of the tapped card
        guard let index = gameCards.firstIndex(where: { $0.id == card.id }) else { return }
        
        // Flip the card face up
        gameCards[index].isFaceUp = true
        
        // If this is the first card of the pair
        if selectedCard == nil {
            selectedCard = card
            return
        }
        
        // This is the second card
        moves += 1
        
        // Check if it's a match
        if selectedCard?.originalCard.id == card.originalCard.id &&
           selectedCard?.type != card.type {
            // It's a match!
            score += 1
            
            // Mark both cards as matched
            if let selectedIndex = gameCards.firstIndex(where: { $0.id == selectedCard?.id }) {
                gameCards[selectedIndex].isMatched = true
                gameCards[index].isMatched = true
                
                // Show match animation
                matchAnimation = card
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    matchAnimation = nil
                }
            }
            
            // Check if game is complete
            if score == cards.count {
                showingGameOver = true
            }
        } else {
            // Not a match - flip both cards face down after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                if let selectedIndex = gameCards.firstIndex(where: { $0.id == selectedCard?.id }) {
                    gameCards[selectedIndex].isFaceUp = false
                }
                gameCards[index].isFaceUp = false
            }
        }
        
        // Reset selected card
        selectedCard = nil
    }
}

struct GameCardView: View {
    let card: Card
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(card.type == .word ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                    .shadow(radius: 3)
                
                if card.isFaceUp {
                    VStack {
                        Text(card.type == .word ? "Word" : "Definition")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(card.content)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 8)
                    }
                    .padding()
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.2))
                        .overlay(
                            Image(systemName: "questionmark")
                                .font(.title)
                                .foregroundColor(.blue)
                        )
                }
            }
        }
        .frame(height: 120)
    }
} 