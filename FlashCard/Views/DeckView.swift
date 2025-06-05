import SwiftUI
import os

struct DeckView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let deck: Deck
    @State private var showingAddCard = false
    @State private var refreshID = UUID() // Add a refresh ID to force view updates
    
    private let logger = Logger(subsystem: "com.flashcards", category: "DeckView")
    
    private var deckCards: [FlashCard] {
        // Get the current deck's cards from the view model
        if let updatedDeck = viewModel.decks.first(where: { $0.id == deck.id }) {
            logger.debug("Found \(updatedDeck.cards.count) cards in deck: \(deck.name)")
            return updatedDeck.cards
        }
        logger.debug("No cards found in deck: \(deck.name)")
        return []
    }
    
    var body: some View {
        List {
            NavigationLink(isActive: $showingAddCard) {
                AddCardView(viewModel: viewModel)
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Card")
                }
                .foregroundColor(.blue)
            }
            
            ForEach(deckCards) { card in
                NavigationLink(destination: EditCardView(viewModel: viewModel, card: card)) {
                    CardRow(card: card)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        if let index = viewModel.flashCards.firstIndex(where: { $0.id == card.id }) {
                            viewModel.deleteCard(at: IndexSet([index]))
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .id(refreshID) // Force view refresh when refreshID changes
        .navigationTitle(deck.name)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddCard = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .onAppear {
            logger.debug("DeckView appeared for deck: \(deck.name)")
            // Force a refresh when the view appears
            refreshID = UUID()
        }
    }
} 