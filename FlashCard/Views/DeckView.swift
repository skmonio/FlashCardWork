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
    @State private var sortOption: SortOption = .default
    @State private var searchText = ""
    
    private let logger = Logger(subsystem: "com.flashcards", category: "DeckView")
    
    enum SortOption {
        case `default`
        case alphabeticalByWord
        case reverseAlphabeticalByWord
        
        var label: String {
            switch self {
            case .default: return "Default"
            case .alphabeticalByWord: return "A-Z"
            case .reverseAlphabeticalByWord: return "Z-A"
            }
        }
    }
    
    private var filteredCards: [FlashCard] {
        let cards = deckCards
        if searchText.isEmpty {
            return cards
        }
        return cards.filter { card in
            card.word.localizedCaseInsensitiveContains(searchText) ||
            card.definition.localizedCaseInsensitiveContains(searchText) ||
            card.example.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var deckCards: [FlashCard] {
        // Get the current deck's cards from the view model
        if let updatedDeck = viewModel.decks.first(where: { $0.id == deck.id }) {
            logger.debug("Found \(updatedDeck.cards.count) cards in deck: \(deck.name)")
            var cards = updatedDeck.cards
            
            // Apply sorting
            switch sortOption {
            case .default:
                break // Keep original order
            case .alphabeticalByWord:
                cards.sort { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedAscending }
            case .reverseAlphabeticalByWord:
                cards.sort { $0.word.localizedCaseInsensitiveCompare($1.word) == .orderedDescending }
            }
            
            return cards
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
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search cards...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
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
                
                if filteredCards.isEmpty && !searchText.isEmpty {
                    Text("No cards match your search")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(filteredCards) { currentCard in
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
            }
            .navigationTitle(deck.name)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach([
                            SortOption.default,
                            SortOption.alphabeticalByWord,
                            SortOption.reverseAlphabeticalByWord
                        ], id: \.self) { option in
                            Button(action: {
                                sortOption = option
                            }) {
                                HStack {
                                    Text(option.label)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .imageScale(.large)
                    }
                }
            }
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