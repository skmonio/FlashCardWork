import SwiftUI
import os

struct AllCardsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var sortOption: SortOption = .az(ascending: true)
    @State private var selectedCard: FlashCard?
    @State private var showingEditCardView = false
    @State private var cardToDelete: FlashCard?
    @State private var showingDeleteAlert = false
    @State private var showingDeckSpecificDeleteAlert = false
    @State private var showingBulkDeleteAlert = false
    @State private var refreshID = UUID()
    
    // Selection mode for cards
    @State private var isSelectionMode = false
    @State private var selectedCards: Set<UUID> = []
    @State private var showingMoveSheet = false
    @State private var isDeletingCards = false // Add loading state for bulk delete
    
    // Deck selection for removal
    @State private var showingDeckSelectionSheet = false
    
    // Deck selection for multiple deck removal
    @State private var selectedDecksForRemoval: Set<UUID> = []
    
    private let logger = Logger(subsystem: "com.flashcards", category: "AllCardsView")
    
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
        let filtered = viewModel.flashCards.filter { card in
            searchText.isEmpty || 
            card.word.localizedCaseInsensitiveContains(searchText) ||
            card.definition.localizedCaseInsensitiveContains(searchText) ||
            card.example.localizedCaseInsensitiveContains(searchText)
        }
        
        return filtered.sorted { card1, card2 in
            switch sortOption {
            case .az(let ascending):
                let cmp = card1.word.localizedCaseInsensitiveCompare(card2.word)
                return ascending ? (cmp == .orderedAscending) : (cmp == .orderedDescending)
            case .date(let ascending):
                let cmp = card1.dateCreated.compare(card2.dateCreated)
                return ascending ? (cmp == .orderedAscending) : (cmp == .orderedDescending)
            case .strength(let ascending):
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
            // Show deck selection sheet for single deck removal
            showingDeckSelectionSheet = true
            return
        }
        
        cardToDelete = nil
        // Remove refreshID to prevent jumping to top
        // refreshID = UUID()
    }
    
    private func removeCardFromSelectedDecks() {
        guard let card = cardToDelete else {
            cardToDelete = nil
            selectedDecksForRemoval.removeAll()
            return
        }
        
        // Get all decks that contain this card
        let cardDecks = viewModel.getAllDecksHierarchical().filter { deck in
            card.deckIds.contains(deck.id) &&
            deck.name != "Review" &&
            deck.name != "Uncategorized"
        }
        
        // Remove card from selected decks
        for deck in cardDecks {
            if selectedDecksForRemoval.contains(deck.id) {
                viewModel.removeCardFromDeck(card: card, deck: deck)
            }
        }
        
        cardToDelete = nil
        selectedDecksForRemoval.removeAll()
        // Remove refreshID to prevent jumping to top
        // refreshID = UUID()
    }
    
    private func deleteSelectedCards(fromAllDecks: Bool) {
        for cardId in selectedCards {
            if let card = viewModel.flashCards.first(where: { $0.id == cardId }) {
                if fromAllDecks {
                    if let index = viewModel.flashCards.firstIndex(where: { $0.id == cardId }) {
                        viewModel.deleteCard(at: IndexSet([index]))
                    }
                } else {
                    // Only remove from the first deck it's found in
                    if let firstDeck = viewModel.decks.first(where: { $0.cards.contains(where: { $0.id == cardId }) }) {
                        viewModel.removeCardFromDeck(card: card, deck: firstDeck)
                    }
                }
            }
        }
        
        isSelectionMode = false
        selectedCards.removeAll()
        // Remove refreshID to prevent jumping to top
        // refreshID = UUID()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            UnifiedHeader(
                title: "All Cards",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { NavigationCoordinator.shared.pop() },
                trailing: {
                    AnyView(
                        Button(action: {
                            NavigationCoordinator.shared.presentSheet(.addCard())
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
                // Sort Picker
                HStack(spacing: 8) {
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
                // Empty State
                VStack(spacing: 16) {
                    Image(systemName: searchText.isEmpty ? "rectangle.stack" : "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    
                    Text(searchText.isEmpty ? "No Cards Yet" : "No Matching Cards")
                        .font(.title2)
                        .bold()
                    
                    Text(searchText.isEmpty ? 
                         "Start adding cards to see them here." : 
                         "Try a different search term.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Cards List
                List {
                    ForEach(filteredAndSortedCards) { card in
                    HStack {
                        if isSelectionMode {
                            Button(action: {
                                if selectedCards.contains(card.id) {
                                    selectedCards.remove(card.id)
                                } else {
                                    selectedCards.insert(card.id)
                                }
                            }) {
                                Image(systemName: selectedCards.contains(card.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(selectedCards.contains(card.id) ? .blue : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        CardRowView(
                            card: card,
                            viewModel: viewModel,
                            onEdit: {
                                if isSelectionMode {
                                    if selectedCards.contains(card.id) {
                                        selectedCards.remove(card.id)
                                    } else {
                                        selectedCards.insert(card.id)
                                    }
                                } else {
                                selectedCard = card
                                showingEditCardView = true
                                }
                            },
                            onDelete: {
                                cardToDelete = card
                                if isCardInMultipleDecks(card) {
                                    showingDeckSpecificDeleteAlert = true
                                } else {
                                showingDeleteAlert = true
                            }
                            },
                            isCardInMultipleDecks: isCardInMultipleDecks(card)
                        )
                        .disabled(isSelectionMode)
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
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
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
            Button("Remove from Selected Decks", role: .destructive) {
                deleteCard(fromAllDecks: false)
            }
            Button("Remove from All Decks", role: .destructive) {
                deleteCard(fromAllDecks: true)
            }
            Button("Cancel", role: .cancel) {
                cardToDelete = nil
            }
        } message: {
            if let _ = cardToDelete {
                Text("This card exists in multiple decks. Would you like to remove it from selected decks or from all decks?")
            }
        }
        .alert("Delete Selected Cards", isPresented: $showingBulkDeleteAlert) {
            Button("Delete from One Deck Each", role: .destructive) {
                deleteSelectedCards(fromAllDecks: false)
            }
            Button("Delete from All Decks", role: .destructive) {
                deleteSelectedCards(fromAllDecks: true)
            }
            Button("Cancel", role: .cancel) { 
                selectedCards.removeAll()
            }
        } message: {
            Text("Do you want to delete \(selectedCards.count) selected cards from one deck each or from all decks?")
        }
        .sheet(isPresented: $showingMoveSheet) {
            AllCardsMoveSheet(
                viewModel: viewModel,
                selectedCardIds: selectedCards,
                onComplete: {
                    isSelectionMode = false
                    selectedCards.removeAll()
                }
            )
        }
        .sheet(isPresented: $showingEditCardView) {
            if let card = selectedCard {
                EditCardView(viewModel: viewModel, card: card)
            }
        }
        .sheet(isPresented: $showingDeckSelectionSheet) {
            if let card = cardToDelete {
                DeckSelectionForRemovalSheet(
                    viewModel: viewModel,
                    card: card,
                    selectedDeckIds: $selectedDecksForRemoval,
                    onRemove: removeCardFromSelectedDecks
                )
            }
        }
        .onChange(of: showingEditCardView) { newValue in
            if !newValue {
                selectedCard = nil
            }
        }
        .id(refreshID)
        .onAppear {
            logger.debug("AllCardsView appeared with \(viewModel.flashCards.count) cards")
        }
    }
}

struct CardRowView: View {
    let card: FlashCard
    @ObservedObject var viewModel: FlashCardViewModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    let isCardInMultipleDecks: Bool
    
    private var cardDecks: [Deck] {
        return viewModel.decks.filter { deck in
            card.deckIds.contains(deck.id) &&
            deck.name != "Review" &&
            deck.name != "Uncategorized"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left side content
                VStack(alignment: .leading, spacing: 4) {
                // Word and Article
                    HStack {
                        Text(card.word)
                            .font(.headline)
                            .bold()
                        
                        if !card.article.isEmpty {
                            Text(card.article)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .cornerRadius(4)
                                .foregroundColor(.blue)
                        }
                }
                        
                // Definition
                    Text(card.definition)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                // Example
                    if !card.example.isEmpty {
                        Text(card.example)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .italic()
                    }
            
                // Deck info
            if !cardDecks.isEmpty {
                HStack {
                    Image(systemName: "folder")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(cardDecks.map { $0.name }.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    }
                }
            }
                    
                    Spacer()
                    
            // Right side content
            VStack(alignment: .trailing, spacing: 0) {
                // Success indicator (checkmark) - TOP RIGHT
                if card.successCount > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text("\(card.successCount)")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                } else {
                    // Empty space to maintain alignment
                    Text("")
                        .font(.caption)
                }
                
                Spacer()
                
                // Learning percentage - MIDDLE RIGHT
                LearningPercentageView(percentage: card.learningPercentage)
                
                Spacer()
                
                // Date - BOTTOM RIGHT
                Text(card.dateCreated.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                        .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: cardOutlineColor.opacity(0.2), radius: 3, x: 0, y: 1)
        .contentShape(Rectangle())
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            
            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
            }
            .tint(.blue)
        }
        .onTapGesture {
            onEdit()
        }
    }
    
    private var cardOutlineColor: Color {
        let percentage = card.learningPercentage ?? 0
        if percentage >= 80 {
            return .green
        } else if percentage >= 40 {
            return .orange
        } else {
            return .blue
        }
    }
}

struct AllCardsMoveSheet: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let selectedCardIds: Set<UUID>
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
            case .copy: return "Cards will remain in current decks and be added to selected decks"
            case .move: return "Cards will be removed from current decks and moved to selected decks"
            }
        }
    }
    
    var availableDecks: [Deck] {
        return viewModel.getAllDecksHierarchical().filter { deck in
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
                        Text("No decks available")
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
                                    Image(systemName: selectedDeckIds.contains(deck.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedDeckIds.contains(deck.id) ? .blue : .gray)
                                    
                                    if deck.isSubDeck {
                                        HStack(spacing: 4) {
                                            Text("    ↳")
                                                .foregroundColor(.secondary)
                                            Text(deck.name)
                                                .foregroundColor(.primary)
                                        }
                                    } else {
                                        Text(deck.name)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(deck.cards.count)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Section(header: Text("Selected Cards (\(selectedCardIds.count))")) {
                    ForEach(viewModel.flashCards.filter { selectedCardIds.contains($0.id) }) { card in
                        HStack {
                            Text(card.word)
                                .font(.headline)
                            Spacer()
                            Text(card.definition)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .navigationTitle("Move \(selectedCardIds.count) Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Move") {
                        performMove()
                        onComplete()
                        dismiss()
                    }
                    .disabled(selectedDeckIds.isEmpty)
                }
            })
        }
        .presentationDetents([.medium, .large])
    }
    
    private func performMove() {
        for cardId in selectedCardIds {
            guard let cardIndex = viewModel.flashCards.firstIndex(where: { $0.id == cardId }) else { continue }
            
            if moveOption == .move {
                // Remove from all current decks first
                viewModel.flashCards[cardIndex].deckIds.removeAll()
            }
            
            // Add to selected decks
            for deckId in selectedDeckIds {
                viewModel.flashCards[cardIndex].deckIds.insert(deckId)
            }
        }
        
        // Update the associations to reflect the changes
        viewModel.updateCardDeckAssociations()
    }
}

struct AllCardsView_Previews: PreviewProvider {
    static var previews: some View {
        AllCardsView(viewModel: FlashCardViewModel())
    }
}

struct DeckSelectionForRemovalSheet: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let card: FlashCard
    @Binding var selectedDeckIds: Set<UUID>
    let onRemove: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    // Get decks that contain this card
    private var cardDecks: [Deck] {
        return viewModel.getAllDecksHierarchical().filter { deck in
            card.deckIds.contains(deck.id) &&
            deck.name != "Review" &&
            deck.name != "Uncategorized"
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Remove Card from Decks")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Select which decks to remove '\(card.word)' from:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Deck list
                List {
                    ForEach(cardDecks) { deck in
                        Button(action: {
                            if selectedDeckIds.contains(deck.id) {
                                selectedDeckIds.remove(deck.id)
                            } else {
                                selectedDeckIds.insert(deck.id)
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        if deck.isSubDeck {
                                            HStack(spacing: 4) {
                                                Text("    ↳")
                                                    .foregroundColor(.secondary)
                                                Text(deck.name)
                                            }
                                        } else {
                                            Text(deck.name)
                                                .fontWeight(.medium)
                                        }
                                    }
                                    Text("\(deck.cards.count) cards")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if selectedDeckIds.contains(deck.id) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select Decks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Remove") {
                        onRemove()
                        dismiss()
                    }
                    .disabled(selectedDeckIds.isEmpty)
                    .foregroundColor(.red)
                }
            }
            .onAppear {
                // Initialize with all decks that contain this card
                selectedDeckIds = Set(cardDecks.map { $0.id })
            }
        }
    }
} 