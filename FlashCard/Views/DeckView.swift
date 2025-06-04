import SwiftUI

struct DeckView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let deck: Deck
    @State private var showingAddCard = false
    
    var body: some View {
        List {
            ForEach(deck.cards) { card in
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
        .sheet(isPresented: $showingAddCard) {
            NavigationView {
                AddCardView(viewModel: viewModel)
            }
        }
    }
} 