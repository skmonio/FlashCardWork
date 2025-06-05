import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlashCardViewModel()
    @State private var showingAddCard = false
    @State private var showingAddDeck = false
    @State private var showingDeckSelection = false
    @State private var selectedMode: DeckSelectionView.StudyMode = .study
    @State private var showingViewCards = false
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Study Options")) {
                    Button(action: {
                        showingViewCards = true
                    }) {
                        Label("View Cards", systemImage: "rectangle.stack.fill")
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        selectedMode = .study
                        showingDeckSelection = true
                    }) {
                        Label("Study Cards", systemImage: "book.fill")
                    }
                    
                    Button(action: {
                        selectedMode = .test
                        showingDeckSelection = true
                    }) {
                        Label("Test Mode", systemImage: "checkmark.circle.fill")
                    }
                    
                    Button(action: {
                        selectedMode = .game
                        showingDeckSelection = true
                    }) {
                        Label("Memory Game", systemImage: "gamecontroller.fill")
                    }
                }
            }
            .navigationTitle("FlashCards")
            .background(
                NavigationLink(isActive: $showingViewCards,
                             destination: { DecksView(viewModel: viewModel) },
                             label: { EmptyView() })
            )
        }
        .sheet(isPresented: $showingDeckSelection) {
            DeckSelectionView(viewModel: viewModel, mode: selectedMode)
        }
    }
}

struct DecksView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var showingAddCard = false
    @State private var showingAddDeck = false
    
    var body: some View {
        List {
            Section(header: Text("Actions")) {
                NavigationLink(isActive: $showingAddCard) {
                    AddCardView(viewModel: viewModel)
                } label: {
                    HStack {
                        Image(systemName: "plus.card.fill")
                        Text("Add New Card")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
                
                NavigationLink(isActive: $showingAddDeck) {
                    AddDeckView(viewModel: viewModel)
                } label: {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                        Text("Add New Deck")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section(header: Text("Decks")) {
                ForEach(viewModel.decks) { deck in
                    NavigationLink(destination: DeckView(viewModel: viewModel, deck: deck)) {
                        HStack {
                            Text(deck.name)
                            Spacer()
                            Text("\(deck.cards.count)")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete { indices in
                    indices.forEach { index in
                        viewModel.deleteDeck(viewModel.decks[index])
                    }
                }
            }
        }
        .navigationTitle("View Cards")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct CardRow: View {
    let card: FlashCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.word)
                .font(.headline)
            Text(card.definition)
                .font(.subheadline)
                .foregroundColor(.secondary)
            if !card.example.isEmpty {
                Text("Example: \(card.example)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
} 
