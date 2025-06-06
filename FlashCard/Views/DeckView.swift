import SwiftUI
import os

struct DeckView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    let deck: Deck
    @State private var showingAddCard = false
    @State private var refreshID = UUID()
    @State private var selectedCard: FlashCard?
    @State private var cardToDelete: FlashCard?
    @State private var showingDeleteAlert = false
    
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
    
    private func isCardInMultipleDecks(_ card: FlashCard) -> Bool {
        var count = 0
        for deck in viewModel.decks {
            if deck.cards.contains(where: { $0.id == card.id }) {
                count += 1
                if count > 1 {
                    return true
                }
            }
        }
        return false
    }
    
    private func deleteCard(fromAllDecks: Bool) {
        guard let card = cardToDelete else { return }
        
        if fromAllDecks {
            // Delete from all decks and flash cards
            if let index = viewModel.flashCards.firstIndex(where: { $0.id == card.id }) {
                viewModel.deleteCard(at: IndexSet([index]))
            }
        } else {
            // Only remove from this deck
            viewModel.removeCardFromDeck(card: card, deck: deck)
        }
        
        cardToDelete = nil
    }
    
    var body: some View {
        VStack {
            List {
                Button(action: {
                    showingAddCard = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add New Card")
                    }
                    .foregroundColor(.blue)
                }
                
                ForEach(deckCards) { currentCard in
                    Button(action: {
                        selectedCard = currentCard
                    }) {
                        CardRow(card: currentCard)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            cardToDelete = currentCard
                            if isCardInMultipleDecks(currentCard) {
                                showingDeleteAlert = true
                            } else {
                                deleteCard(fromAllDecks: true)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(deck.name)
            .navigationBarBackButtonHidden(true)
            .alert("Delete Card", isPresented: $showingDeleteAlert) {
                Button("Remove from \(deck.name)", role: .destructive) {
                    deleteCard(fromAllDecks: false)
                }
                Button("Remove from All Decks", role: .destructive) {
                    deleteCard(fromAllDecks: true)
                }
                Button("Cancel", role: .cancel) {
                    cardToDelete = nil
                }
            } message: {
                Text("This card exists in multiple decks. Would you like to remove it only from \(deck.name) or from all decks?")
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
        .sheet(isPresented: $showingAddCard) {
            AddCardView(viewModel: viewModel)
        }
        .sheet(item: $selectedCard) { card in
            EditCardView(viewModel: viewModel, card: card)
        }
        .id(refreshID)
        .onAppear {
            logger.debug("DeckView appeared for deck: \(deck.name)")
            refreshID = UUID()
        }
    }
} 