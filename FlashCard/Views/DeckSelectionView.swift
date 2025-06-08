import SwiftUI

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: StudyMode
    @State private var selectedDeckIds: Set<UUID> = []
    
    enum StudyMode {
        case study, test, game, truefalse, hangman, dehet, lookcovercheck, writing
        
        var title: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .game: return "Memory Game"
            case .truefalse: return "True or False"
            case .hangman: return "Hangman"
            case .dehet: return "de of het"
            case .lookcovercheck: return "Look Cover Check"
            case .writing: return "Write Your Card"
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
                            selectedDeckIds = Set(viewModel.getAllDecksHierarchical().map { $0.id })
                        }
                    }) {
                        HStack {
                            Text(selectedDeckIds.isEmpty ? "Select All Decks" : "Deselect All")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(availableCards.count) cards")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ForEach(viewModel.getAllDecksHierarchical()) { deck in
                        Button(action: {
                            if selectedDeckIds.contains(deck.id) {
                                selectedDeckIds.remove(deck.id)
                            } else {
                                selectedDeckIds.insert(deck.id)
                            }
                        }) {
                            HStack {
                                // Show indentation for sub-decks
                                if deck.isSubDeck {
                                    HStack(spacing: 4) {
                                        Text("    ↳")
                                            .foregroundColor(.secondary)
                                        Text(deck.name)
                                    }
                                } else {
                                    Text(deck.name)
                                }
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
                        NavigationLink(destination: destinationView) {
                            HStack {
                                Text("Start \(mode.title)")
                                    .foregroundColor(.blue)
                                    .font(.headline)
                                Spacer()
                                Text("\(availableCards.count) cards")
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
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
            // Dismiss this view when dismiss to root is requested
            dismiss()
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch mode {
        case .study:
            StudyView(viewModel: viewModel, cards: availableCards)
        case .test:
            TestView(viewModel: viewModel, cards: availableCards)
        case .game:
            GameView(viewModel: viewModel, cards: availableCards)
        case .truefalse:
            TrueFalseView(viewModel: viewModel, cards: availableCards)
        case .hangman:
            HangmanView(viewModel: viewModel, cards: availableCards)
        case .dehet:
            DeHetGameView(viewModel: viewModel, cards: availableCards)
        case .lookcovercheck:
            LookCoverCheckView(viewModel: viewModel, cards: availableCards)
        case .writing:
            WritingView(viewModel: viewModel, cards: availableCards)
        }
    }
} 