import SwiftUI

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: StudyMode
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingDestination = false
    @State private var selectedCards: [FlashCard] = []
    
    enum StudyMode {
        case study, test, game
        
        var title: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .game: return "Memory Game"
            }
        }
    }
    
    var availableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            return []
        } else {
            // Get unique cards that belong to any of the selected decks
            var uniqueCards: Set<FlashCard> = []
            for deckId in selectedDeckIds {
                if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                    uniqueCards.formUnion(deck.cards)
                }
            }
            return Array(uniqueCards)
        }
    }
    
    var totalCardsInSelectedDecks: Int {
        availableCards.count // Use the actual unique cards count
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Select Decks")) {
                    Button(action: {
                        // Toggle all decks
                        if selectedDeckIds.count == viewModel.getSelectableDecks().count {
                            selectedDeckIds.removeAll()
                        } else {
                            selectedDeckIds = Set(viewModel.getSelectableDecks().map { $0.id })
                        }
                        selectedCards = availableCards
                    }) {
                        HStack {
                            Text(selectedDeckIds.isEmpty ? "Select All Decks" : "Selected Decks")
                                .foregroundColor(.primary)
                            Spacer()
                            if !selectedDeckIds.isEmpty {
                                Text("\(selectedDeckIds.count) selected (\(totalCardsInSelectedDecks) cards)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    ForEach(viewModel.decks) { deck in
                        Button(action: {
                            if selectedDeckIds.contains(deck.id) {
                                selectedDeckIds.remove(deck.id)
                            } else {
                                selectedDeckIds.insert(deck.id)
                            }
                            selectedCards = availableCards
                        }) {
                            HStack {
                                Text(deck.name)
                                Spacer()
                                if selectedDeckIds.contains(deck.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                                Text("\(deck.cards.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                if !selectedDeckIds.isEmpty {
                    Section {
                        Button(action: {
                            showingDestination = true
                        }) {
                            HStack {
                                Text("Start \(mode.title)")
                                Spacer()
                                Text("\(selectedCards.count) cards")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .disabled(selectedCards.isEmpty)
                    }
                }
            }
            .navigationTitle(mode.title)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .navigationDestination(isPresented: $showingDestination) {
                Group {
                    switch mode {
                    case .study:
                        StudyView(viewModel: viewModel, cards: selectedCards)
                    case .test:
                        TestView(viewModel: viewModel, cards: selectedCards)
                    case .game:
                        GameView(viewModel: viewModel, cards: selectedCards)
                    }
                }
            }
        }
    }
} 