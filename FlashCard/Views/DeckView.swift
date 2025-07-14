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
    @State private var showingDeckSpecificDeleteAlert = false
    @State private var sortOption: SortOption = .az(ascending: true)
    @State private var searchText = ""
    
    // Multi-select states for cards
    @State private var isSelectionMode = false
    @State private var selectedCards: Set<UUID> = []
    @State private var showingMoveSheet = false
    @State private var showingBulkDeleteAlert = false
    @State private var isDeletingCards = false // Add loading state for bulk delete
    
    // Navigation state for full-screen forms
    @State private var showingAddCardView = false
    @State private var showingEditCardView = false
    
    private let logger = Logger(subsystem: "com.flashcards", category: "DeckView")
    
    enum SortOption: Hashable {
        case az(ascending: Bool)
        case date(ascending: Bool)
        case strength(ascending: Bool) // Strongest first (descending) or Weakest first (ascending)
        
        var label: String {
            switch self {
            case .az(let ascending): return ascending ? "A-Z" : "Z-A"
            case .date(let ascending): return ascending ? "Oldest" : "Recent"
            case .strength(let ascending): return ascending ? "Weakest" : "Strongest"
            }
        }
        
        var icon: String {
            switch self {
            case .az(let ascending): return ascending ? "arrow.up" : "arrow.down"
            case .date(let ascending): return ascending ? "arrow.up" : "arrow.down"
            case .strength(let ascending): return ascending ? "arrow.up" : "arrow.down"
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
            case .az(let ascending):
                cards.sort { card1, card2 in
                    let comparison = card1.word.localizedCaseInsensitiveCompare(card2.word)
                    return ascending ? comparison == .orderedAscending : comparison == .orderedDescending
                }
            case .date(let ascending):
                cards.sort { card1, card2 in
                    let cmp = card1.dateCreated.compare(card2.dateCreated)
                    return ascending ? (cmp == .orderedAscending) : (cmp == .orderedDescending)
                }
            case .strength(let ascending):
                cards.sort { card1, card2 in
                    let percentage1 = card1.learningPercentage ?? 0
                    let percentage2 = card2.learningPercentage ?? 0
                    if ascending {
                        // Weakest first (ascending)
                        return percentage1 < percentage2
                    } else {
                        // Strongest first (descending)
                        return percentage1 > percentage2
                    }
                }
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
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Unified Header
            UnifiedHeader(
                title: deck.name,
                showBackButton: true,
                showProfileIcon: false,
                onBack: { dismiss() },
                trailing: {
                    AnyView(
                        Button(action: {
                            showingAddCardView = true
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    )
                }
            )
            
            VStack(spacing: 12) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search cards...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Sort and Select Options
                HStack(spacing: 8) {
                    // Sort Options
                    ForEach([
                        SortOption.az(ascending: true),
                        SortOption.date(ascending: true),
                        SortOption.strength(ascending: true)
                    ], id: \.self) { option in
                        Button(action: {
                            if sortOption.label == option.label { // Compare by label for toggle
                                // Toggle direction for all
                                switch sortOption {
                                case .az(let ascending):
                                    sortOption = .az(ascending: !ascending)
                                case .date(let ascending):
                                    sortOption = .date(ascending: !ascending)
                                case .strength(let ascending):
                                    sortOption = .strength(ascending: !ascending)
                                }
                            } else {
                                // Select new sort option
                                switch option {
                                case .az:
                                    sortOption = .az(ascending: true)
                                case .date:
                                    sortOption = .date(ascending: true)
                                case .strength:
                                    sortOption = .strength(ascending: true)
                                }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: {
                                    switch option {
                                    case .az:
                                        if case .az(let ascending) = sortOption { return ascending ? "arrow.up" : "arrow.down" } else { return "arrow.up" }
                                    case .date:
                                        if case .date(let ascending) = sortOption { return ascending ? "arrow.up" : "arrow.down" } else { return "arrow.up" }
                                    case .strength:
                                        if case .strength(let ascending) = sortOption { return ascending ? "arrow.up" : "arrow.down" } else { return "arrow.up" }
                                    }
                                }())
                                Text({
                                    switch option {
                                    case .az:
                                        if case .az(let ascending) = sortOption { return ascending ? "A-Z" : "Z-A" } else { return "A-Z" }
                                    case .date:
                                        return "Date"
                                    case .strength:
                                        return "%"
                                    }
                                }())
                            }
                            .font(.subheadline)
                            .foregroundColor({
                                switch option {
                                case .az:
                                    if case .az = sortOption { return .blue } else { return .primary }
                                case .date:
                                    if case .date = sortOption { return .blue } else { return .primary }
                                case .strength:
                                    if case .strength = sortOption { return .blue } else { return .primary }
                                }
                            }())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background({
                                switch option {
                                case .az:
                                    if case .az = sortOption { return Color(.systemGray5).opacity(0.2) } else { return Color.clear }
                                case .date:
                                    if case .date = sortOption { return Color(.systemGray5).opacity(0.2) } else { return Color.clear }
                                case .strength:
                                    if case .strength = sortOption { return Color(.systemGray5).opacity(0.2) } else { return Color.clear }
                                }
                            }())
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    // Select Button
                    Button(action: {
                        isSelectionMode.toggle()
                        if !isSelectionMode {
                            selectedCards.removeAll()
                        }
                        HapticManager.shared.lightImpact()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isSelectionMode ? "checkmark.circle.fill" : "checkmark.circle")
                            Text(isSelectionMode ? "Cancel" : "Select")
                        }
                        .font(.subheadline)
                        .foregroundColor(isSelectionMode ? .red : .blue)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray5).opacity(0.2))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            // Cards List
            if filteredAndSortedCards.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    
                    Text(searchText.isEmpty ? "No cards in this deck" : "No cards match your search")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if searchText.isEmpty {
                        Button(action: {
                            showingAddCardView = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Your First Card")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(filteredAndSortedCards) { currentCard in
                        HStack {
                            if isSelectionMode {
                                Button(action: {
                                    if selectedCards.contains(currentCard.id) {
                                        selectedCards.remove(currentCard.id)
                                    } else {
                                        selectedCards.insert(currentCard.id)
                                    }
                                    HapticManager.shared.multiSelectToggle()
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
                                    HapticManager.shared.multiSelectToggle()
                                } else {
                                    selectedCard = currentCard
                                    showingEditCardView = true
                                }
                            }) {
                                CardRowView(
                                    card: currentCard,
                                    viewModel: viewModel,
                                    onEdit: {
                                        if isSelectionMode {
                                            if selectedCards.contains(currentCard.id) {
                                                selectedCards.remove(currentCard.id)
                                            } else {
                                                selectedCards.insert(currentCard.id)
                                            }
                                        } else {
                                            selectedCard = currentCard
                                            showingEditCardView = true
                                        }
                                    },
                                    onDelete: {
                                        cardToDelete = currentCard
                                        if isCardInMultipleDecks(currentCard) {
                                            showingDeckSpecificDeleteAlert = true
                                        } else {
                                            showingDeleteAlert = true
                                        }
                                    },
                                    isCardInMultipleDecks: isCardInMultipleDecks(currentCard)
                                )
                                .disabled(isSelectionMode)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            
            // Bottom Navigation Bar (only show when in selection mode)
            if isSelectionMode {
                HStack {
                    if !selectedCards.isEmpty {
                        Button(action: {
                            showingBulkDeleteAlert = true
                        }) {
                            VStack {
                                Image(systemName: "trash")
                                Text("Delete (\(selectedCards.count))")
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .red.opacity(0.2), radius: 3, x: 0, y: 1)
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
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        // Show Select All when in selection mode but no cards selected
                        Button(action: {
                            selectedCards = Set(filteredAndSortedCards.map { $0.id })
                            HapticManager.shared.mediumImpact()
                        }) {
                            VStack {
                                Image(systemName: "checkmark.circle")
                                Text("Select All")
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
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
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
        .id(refreshID)
        .onAppear {
            logger.debug("DeckView appeared for deck: \(deck.name)")
        }
        
        // Navigation destinations
        NavigationLink(destination: 
            Group {
                if let card = selectedCard {
                    EditCardView(viewModel: viewModel, card: card)
                } else {
                    EmptyView()
                }
            }, isActive: $showingEditCardView) {
            EmptyView()
        }
        .hidden()
        .onChange(of: showingEditCardView) { newValue in
            // Refresh the view when returning from EditCardView
            if !newValue {
                logger.debug("Returned from EditCardView, refreshing DeckView")
                selectedCard = nil
            }
        }
        .sheet(isPresented: $showingAddCardView) {
            AddCardView(viewModel: viewModel, defaultDeck: deck)
        }
        .alert("Delete Card", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let card = cardToDelete {
                    if let index = viewModel.flashCards.firstIndex(where: { $0.id == card.id }) {
                        viewModel.deleteCard(at: IndexSet([index]))
                    }
                }
                cardToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                cardToDelete = nil
            }
        } message: {
            if let card = cardToDelete {
                Text("Are you sure you want to delete the card '\(card.word)'? This action cannot be undone.")
            }
        }
        .alert("Delete Card", isPresented: $showingDeckSpecificDeleteAlert) {
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
            if let card = cardToDelete {
                Text("This card exists in multiple decks. Would you like to remove it only from \(deck.name) or from all decks?")
            }
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
                }
            )
        }
    }
    
    private func dismissToRoot() {
        // Send notification to dismiss all views
        NotificationCenter.default.post(name: NSNotification.Name("DismissToRoot"), object: nil)
        
        // Also trigger ViewModel navigation
        viewModel.navigateToRoot()
        
        // Fallback with multiple dismissals
        dismiss()
        for i in 1...8 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                dismiss()
            }
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
        return viewModel.getAllDecksHierarchical().filter { deck in
            deck.id != currentDeck.id && 
            deck.name != "Uncategorized" && 
            deck.name != "Review"
        }
    }
    
    var body: some View {
        NavigationStack {
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyMove()
                        onComplete()
                        dismiss()
                    }
                    .disabled(selectedDeckIds.isEmpty)
                }
            }
        }
    }
    
    private func applyMove() {
        for cardId in selectedCardIds {
            guard let _ = viewModel.flashCards.first(where: { $0.id == cardId }) else { continue }
            
            // Update the card's deck associations
            if let cardIndex = viewModel.flashCards.firstIndex(where: { $0.id == cardId }) {
                var updatedCard = viewModel.flashCards[cardIndex]
                
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