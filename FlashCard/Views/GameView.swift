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
    @Environment(\.dismiss) private var dismiss
    @State private var cards: [Card] = []
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
            if viewModel.flashCards.isEmpty {
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
                    ForEach(cards) { card in
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
        cards = []
        for flashCard in viewModel.flashCards {
            cards.append(Card(content: flashCard.word, type: .word, originalCard: flashCard))
            cards.append(Card(content: flashCard.definition, type: .definition, originalCard: flashCard))
        }
        
        // Shuffle the cards
        cards.shuffle()
    }
    
    private func cardTapped(_ card: Card) {
        // Find the tapped card in our array
        guard let index = cards.firstIndex(where: { $0.id == card.id }),
              !cards[index].isMatched,
              !cards[index].isFaceUp else { return }
        
        // Flip the card
        cards[index].isFaceUp = true
        
        // If we already have a card selected
        if let selectedCard = selectedCard {
            moves += 1
            
            // Check if they match
            if selectedCard.originalCard.id == card.originalCard.id &&
               selectedCard.type != card.type {
                // Match found!
                cards[index].isMatched = true
                if let selectedIndex = cards.firstIndex(where: { $0.id == selectedCard.id }) {
                    cards[selectedIndex].isMatched = true
                }
                score += 1
                
                // Show match animation
                matchAnimation = card
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    matchAnimation = nil
                }
                
                // Check if game is complete
                if score == viewModel.flashCards.count {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showingGameOver = true
                    }
                }
            } else {
                // No match - flip both cards back
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    cards[index].isFaceUp = false
                    if let selectedIndex = cards.firstIndex(where: { $0.id == selectedCard.id }) {
                        cards[selectedIndex].isFaceUp = false
                    }
                }
            }
            self.selectedCard = nil
        } else {
            // First card selected
            selectedCard = card
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