import SwiftUI

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: StudyMode
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingDestination = false
    @State private var selectedCards: [FlashCard] = []
    
    enum StudyMode {
        case study, test, game, truefalse
        
        var title: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .game: return "Memory Game"
            case .truefalse: return "True or False"
            }
        }
    }
    
    var availableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            return []  // Return empty array when no decks are selected
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
    
    var body: some View {
        VStack {
            List {
                Section(header: Text("Select Decks")) {
                    Button(action: {
                        // Toggle all decks
                        if !selectedDeckIds.isEmpty {
                            selectedDeckIds.removeAll()
                        } else {
                            selectedDeckIds = Set(viewModel.decks.map { $0.id })
                        }
                        selectedCards = availableCards
                    }) {
                        HStack {
                            Text(selectedDeckIds.isEmpty ? "Select All Decks" : "Deselect All")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(availableCards.count) cards")
                                .foregroundColor(.secondary)
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
                
                if !selectedDeckIds.isEmpty && !availableCards.isEmpty {
                    Section {
                        Button(action: {
                            selectedCards = availableCards
                            showingDestination = true
                        }) {
                            HStack {
                                Text("Start \(mode.title)")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                Spacer()
                                Text("\(selectedCards.count) cards")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(mode.title)
            .navigationBarBackButtonHidden(true)
            
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
        .sheet(isPresented: $showingDestination) {
            let _ = print("Showing mode: \(mode)")
            Group {
                switch mode {
                case .study:
                    StudyView(viewModel: viewModel, cards: selectedCards)
                case .test:
                    TestView(viewModel: viewModel, cards: selectedCards)
                case .game:
                    GameView(viewModel: viewModel, cards: selectedCards)
                case .truefalse:
                    TrueFalseView(viewModel: viewModel, cards: selectedCards)
                }
            }
        }
    }
} 