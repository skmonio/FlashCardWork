import SwiftUI
import os

struct AllCardsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var sortOption: SortOption = .alphabeticalByWord
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
    
    private let logger = Logger(subsystem: "com.flashcards", category: "AllCardsView")
    
    enum SortOption: CaseIterable {
        case alphabeticalByWord
        case reverseAlphabeticalByWord
        case alphabeticalByDefinition
        case reverseAlphabeticalByDefinition
        case dateCreatedNewest
        case dateCreatedOldest
        case successCount
        
        var label: String {
            switch self {
            case .alphabeticalByWord: return "Word A-Z"
            case .reverseAlphabeticalByWord: return "Word Z-A"
            case .alphabeticalByDefinition: return "Definition A-Z"
            case .reverseAlphabeticalByDefinition: return "Definition Z-A"
            case .dateCreatedNewest: return "Newest First"
            case .dateCreatedOldest: return "Oldest First"
            case .successCount: return "Most Practiced"
            }
        }
        
        var icon: String {
            switch self {
            case .alphabeticalByWord, .alphabeticalByDefinition: return "textformat.abc"
            case .reverseAlphabeticalByWord, .reverseAlphabeticalByDefinition: return "textformat.abc"
            case .dateCreatedNewest: return "calendar.badge.plus"
            case .dateCreatedOldest: return "calendar"
            case .successCount: return "chart.bar.fill"
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
            case .alphabeticalByWord:
                return card1.word.localizedCaseInsensitiveCompare(card2.word) == .orderedAscending
            case .reverseAlphabeticalByWord:
                return card1.word.localizedCaseInsensitiveCompare(card2.word) == .orderedDescending
            case .alphabeticalByDefinition:
                return card1.definition.localizedCaseInsensitiveCompare(card2.definition) == .orderedAscending
            case .reverseAlphabeticalByDefinition:
                return card1.definition.localizedCaseInsensitiveCompare(card2.definition) == .orderedDescending
            case .dateCreatedNewest:
                return card1.dateCreated > card2.dateCreated
            case .dateCreatedOldest:
                return card1.dateCreated < card2.dateCreated
            case .successCount:
                return card1.successCount > card2.successCount
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
            // Only remove from the first deck it's found in (since this is "All Cards" view)
            if let firstDeck = viewModel.decks.first(where: { $0.cards.contains(where: { $0.id == card.id }) }) {
                viewModel.removeCardFromDeck(card: card, deck: firstDeck)
            }
        }
        
        cardToDelete = nil
        refreshID = UUID()
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
        refreshID = UUID()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and Sort Controls
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
            }
            .padding(.vertical, 8)
            .background(Color(.systemGroupedBackground))
            
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
        .navigationTitle("All Cards (\(filteredAndSortedCards.count))")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
            // Back button - TOP LEFT
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if isSelectionMode {
                        isSelectionMode = false
                        selectedCards.removeAll()
                    } else {
                        dismiss()
                    }
                }) {
                    Text(isSelectionMode ? "Cancel" : "Back")
                }
            }
            
            // Select button - MIDDLE
            ToolbarItem(placement: .principal) {
                if !isSelectionMode {
                    Button("Select") {
                        isSelectionMode = true
                    }
                } else {
                    Text("Select Cards")
                        .font(.headline)
                        .bold()
                }
            }
            
            // Sort button - TOP RIGHT
            ToolbarItem(placement: .navigationBarTrailing) {
                if !isSelectionMode {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                sortOption = option
                            }) {
                                HStack {
                                    Image(systemName: option.icon)
                                    Text(option.label)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        })
        .alert("Delete Card", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let card = cardToDelete {
                    if let index = viewModel.flashCards.firstIndex(where: { $0.id == card.id }) {
                        viewModel.deleteCard(at: IndexSet([index]))
                    }
                    refreshID = UUID()
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
            Button("Remove from One Deck", role: .destructive) {
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
                Text("This card exists in multiple decks. Would you like to remove it from one deck or from all decks?")
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
                    refreshID = UUID()
                }
            )
        }
        .sheet(isPresented: $showingEditCardView) {
            if let card = selectedCard {
                EditCardView(viewModel: viewModel, card: card)
            }
        }
        .onChange(of: showingEditCardView) { newValue in
            if !newValue {
                selectedCard = nil
                refreshID = UUID()
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
            deck.name != "Learning" && 
            deck.name != "Learnt" && 
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
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
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
            deck.name != "Learning" && 
            deck.name != "Learnt" && 
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