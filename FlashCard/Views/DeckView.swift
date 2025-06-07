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
    
    // Multi-select states
    @State private var isSelectionMode = false
    @State private var selectedCards: Set<UUID> = []
    @State private var showingMoveSheet = false
    @State private var showingBulkDeleteAlert = false
    
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
    
    private var filteredAndSortedCards: [FlashCard] {
        // Get the current deck's cards from the view model
        if let updatedDeck = viewModel.decks.first(where: { $0.id == deck.id }) {
            logger.debug("Found \(updatedDeck.cards.count) cards in deck: \(deck.name)")
            var cards = updatedDeck.cards
            
            // Apply search filter
            if !searchText.isEmpty {
                cards = cards.filter { card in
                    card.word.localizedCaseInsensitiveContains(searchText) ||
                    card.definition.localizedCaseInsensitiveContains(searchText) ||
                    card.example.localizedCaseInsensitiveContains(searchText)
                }
            }
            
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
    
    private func deleteSelectedCards(fromAllDecks: Bool) {
        for cardId in selectedCards {
            if let card = viewModel.flashCards.first(where: { $0.id == cardId }) {
                if fromAllDecks {
                    if let index = viewModel.flashCards.firstIndex(where: { $0.id == cardId }) {
                        viewModel.deleteCard(at: IndexSet([index]))
                    }
                } else {
                    viewModel.removeCardFromDeck(card: card, deck: deck)
                }
            }
        }
        
        HapticManager.shared.bulkActionComplete() // Feedback for bulk operation completion
        isSelectionMode = false
        selectedCards.removeAll()
        refreshID = UUID()
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
                
                if filteredAndSortedCards.isEmpty && !searchText.isEmpty {
                    Text("No cards match your search")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(filteredAndSortedCards) { currentCard in
                        HStack {
                            if isSelectionMode {
                                Button(action: {
                                    if selectedCards.contains(currentCard.id) {
                                        selectedCards.remove(currentCard.id)
                                    } else {
                                        selectedCards.insert(currentCard.id)
                                    }
                                    HapticManager.shared.multiSelectToggle() // Selection feedback
                                }) {
                                    Image(systemName: selectedCards.contains(currentCard.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedCards.contains(currentCard.id) ? .blue : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Button(action: {
                                if isSelectionMode {
                                    if selectedCards.contains(currentCard.id) {
                                        selectedCards.remove(currentCard.id)
                                    } else {
                                        selectedCards.insert(currentCard.id)
                                    }
                                    HapticManager.shared.multiSelectToggle() // Selection feedback
                                } else {
                                    selectedCard = currentCard
                                }
                            }) {
                                CardRow(card: currentCard)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .swipeActions(edge: .trailing) {
                            if !isSelectionMode {
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
            }
            .navigationTitle(deck.name)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelectionMode {
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedCards.removeAll()
                        }
                    } else {
                        EmptyView()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        if !isSelectionMode {
                            Button("Select") {
                                isSelectionMode = true
                            }
                        }
                        
                        Menu {
                            Picker("Sort", selection: $sortOption) {
                                Label("Default", systemImage: "list.bullet")
                                    .tag(SortOption.default)
                                Label("A-Z", systemImage: "arrow.up")
                                    .tag(SortOption.alphabeticalByWord)
                                Label("Z-A", systemImage: "arrow.down")
                                    .tag(SortOption.reverseAlphabeticalByWord)
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        .disabled(isSelectionMode)
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
            .alert("Delete Selected Cards", isPresented: $showingBulkDeleteAlert) {
                Button("Delete from \(deck.name)", role: .destructive) {
                    deleteSelectedCards(fromAllDecks: false)
                }
                Button("Delete from All Decks", role: .destructive) {
                    deleteSelectedCards(fromAllDecks: true)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Do you want to delete \(selectedCards.count) selected cards from just this deck or from all decks?")
            }
            .sheet(isPresented: $showingMoveSheet) {
                MoveCardsSheet(
                    viewModel: viewModel,
                    selectedCardIds: selectedCards,
                    currentDeck: deck,
                    onComplete: {
                        isSelectionMode = false
                        selectedCards.removeAll()
                        refreshID = UUID()
                    }
                )
            }
            
            Spacer()
            
            // Bottom Navigation Bar
            HStack {
                if isSelectionMode && !selectedCards.isEmpty {
                    Button(action: {
                        showingBulkDeleteAlert = true
                    }) {
                        VStack {
                            Image(systemName: "trash")
                            Text("Delete (\(selectedCards.count))")
                        }
                        .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        showingMoveSheet = true
                    }) {
                        VStack {
                            Image(systemName: "folder")
                            Text("Move (\(selectedCards.count))")
                        }
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                } else {
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

struct MoveCardsSheet: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let selectedCardIds: Set<UUID>
    let currentDeck: Deck
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var moveOption: MoveOption = .copy
    
    enum MoveOption {
        case copy, move
        
        var title: String {
            switch self {
            case .copy: return "Copy to selected decks"
            case .move: return "Move to selected decks"
            }
        }
        
        var description: String {
            switch self {
            case .copy: return "Cards will remain in current deck and be added to selected decks"
            case .move: return "Cards will be removed from current deck and added to selected decks"
            }
        }
    }
    
    var availableDecks: [Deck] {
        return viewModel.getAllDecksHierarchical().filter { $0.id != currentDeck.id }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Move Option")) {
                    Picker("Option", selection: $moveOption) {
                        Text(MoveOption.copy.title).tag(MoveOption.copy)
                        Text(MoveOption.move.title).tag(MoveOption.move)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Text(moveOption.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Select Destination Decks")) {
                    if availableDecks.isEmpty {
                        Text("No other decks available")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(availableDecks) { deck in
                            Button(action: {
                                if selectedDeckIds.contains(deck.id) {
                                    selectedDeckIds.remove(deck.id)
                                } else {
                                    selectedDeckIds.insert(deck.id)
                                }
                            }) {
                                HStack {
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
                                }
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                
                Section {
                    Text("Moving \(selectedCardIds.count) cards")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Move Cards")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Apply") {
                    applyMove()
                    onComplete()
                    dismiss()
                }
                .disabled(selectedDeckIds.isEmpty)
            )
        }
    }
    
    private func applyMove() {
        for cardId in selectedCardIds {
            guard let card = viewModel.flashCards.first(where: { $0.id == cardId }) else { continue }
            
            // Update the card's deck associations
            if let cardIndex = viewModel.flashCards.firstIndex(where: { $0.id == cardId }) {
                var updatedCard = card
                
                if moveOption == .move {
                    // Remove from current deck
                    updatedCard.deckIds.remove(currentDeck.id)
                }
                
                // Add to selected decks
                updatedCard.deckIds.formUnion(selectedDeckIds)
                
                // Update the card in the view model
                viewModel.flashCards[cardIndex] = updatedCard
            }
        }
        
        // Update deck associations
        viewModel.updateCardDeckAssociations()
        
        // Haptic feedback for successful move operation
        HapticManager.shared.bulkActionComplete()
    }
} 