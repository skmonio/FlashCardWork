import SwiftUI
import os

struct ManageDecksView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    private let logger = Logger(subsystem: "com.flashcards", category: "ManageDecksView")
    @State private var showingAddDeck = false
    @State private var showingExportImport = false
    
    // Search functionality
    @State private var searchText = ""
    @State private var showingSearch = false
    @State private var selectedCardForEdit: FlashCard?
    
    @State private var showingEditCardView = false
    
    // Deck editing
    @State private var showingRenameDeckAlert = false
    @State private var deckToRename: Deck?
    @State private var newDeckName = ""
    
    // Deck deletion confirmation
    @State private var showingDeleteDeckAlert = false
    @State private var deckToDelete: Deck?
    
    // Deck moving
    @State private var showingMoveDeckSheet = false
    @State private var deckToMove: Deck?
    
    // Selection mode for decks
    @State private var isSelectionMode = false
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingBulkDeleteAlert = false
    @State private var showingBulkMoveSheet = false
    
    // Navigation state for full-screen forms
    
    // Computed property for search results
    private var searchResults: [(card: FlashCard, deckName: String)] {
        guard !searchText.isEmpty else { return [] }
        
        var results: [(FlashCard, String)] = []
        
        for deck in viewModel.decks {
            for card in deck.cards {
                if card.word.localizedCaseInsensitiveContains(searchText) ||
                   card.definition.localizedCaseInsensitiveContains(searchText) ||
                   card.example.localizedCaseInsensitiveContains(searchText) {
                    results.append((card, deck.name))
                }
            }
        }
        
        // Sort alphabetically by default
        results.sort { $0.0.word.localizedCaseInsensitiveCompare($1.0.word) == .orderedAscending }
        
        return results
    }
    
    var body: some View {
        VStack {
            List {
                // Search bar
                Section {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search cards...", text: $searchText)
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                
                // Search results
                if !searchText.isEmpty {
                    Section(header: Text("Search Results (\(searchResults.count) cards)")) {
                        if searchResults.isEmpty {
                            Text("No cards found")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            ForEach(searchResults, id: \.card.id) { result in
                                Button(action: {
                                    // Open EditCardView for the selected card
                                    selectedCardForEdit = result.card
                                    showingEditCardView = true
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(result.card.word)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)
                                                Text(result.card.definition)
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Text("in \(result.deckName)")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(8)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                } else {
                    // Regular deck display when not searching
                    Section {
                        Button(action: {
                            showingAddDeck = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add New Deck")
                            }
                            .foregroundColor(.blue)
                        }
                        
                        ForEach(viewModel.getAllDecksHierarchical()) { deck in
                            HStack {
                                if isSelectionMode {
                                    let canSelect = deck.name != "Uncategorized" && deck.name != "Learning" && deck.name != "Learnt"
                                    Button(action: {
                                        if canSelect {
                                            if selectedDeckIds.contains(deck.id) {
                                                selectedDeckIds.remove(deck.id)
                                            } else {
                                                selectedDeckIds.insert(deck.id)
                                            }
                                            HapticManager.shared.multiSelectToggle()
                                        }
                                    }) {
                                        if canSelect {
                                            Image(systemName: selectedDeckIds.contains(deck.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedDeckIds.contains(deck.id) ? .blue : .gray)
                                        } else {
                                            Image(systemName: "minus.circle")
                                                .foregroundColor(.gray.opacity(0.5))
                                        }
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(!canSelect)
                                }
                                
                                NavigationLink {
                                    DeckView(viewModel: viewModel, deck: deck)
                                } label: {
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
                                        Text("\(deck.cards.count)")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .disabled(isSelectionMode)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Manage Decks")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelectionMode {
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedDeckIds.removeAll()
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
                        
                        Button("Add Deck") {
                            showingAddDeck = true
                        }
                        .disabled(isSelectionMode)
                    }
                }
            })
            
            Spacer()
            
            // Bottom Navigation Bar
            HStack {
                if isSelectionMode && !selectedDeckIds.isEmpty {
                    let selectedDecks = viewModel.decks.filter { selectedDeckIds.contains($0.id) }
                    let canModifyDecks = selectedDecks.allSatisfy { deck in
                        deck.name != "Uncategorized" && deck.name != "Learning" && deck.name != "Learnt"
                    }
                    
                    if canModifyDecks {
                        Button(action: {
                            showingBulkDeleteAlert = true
                        }) {
                            VStack {
                                Image(systemName: "trash")
                                Text("Delete (\(selectedDeckIds.count))")
                            }
                            .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Button(action: {
                            showingBulkMoveSheet = true
                        }) {
                            VStack {
                                Image(systemName: "folder")
                                Text("Move (\(selectedDeckIds.count))")
                            }
                            .foregroundColor(.orange)
                        }
                        .frame(maxWidth: .infinity)
                        
                        if selectedDeckIds.count == 1 {
                            Button(action: {
                                if let deck = selectedDecks.first {
                                    deckToRename = deck
                                    newDeckName = deck.name
                                    showingRenameDeckAlert = true
                                }
                            }) {
                                VStack {
                                    Image(systemName: "pencil")
                                    Text("Edit")
                                }
                                .foregroundColor(.blue)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    } else {
                        Text("Cannot modify system decks")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                } else if isSelectionMode {
                    // Show Select All when in selection mode but no decks selected
                    Button(action: {
                        let selectableDecks = viewModel.getAllDecksHierarchical().filter { deck in
                            deck.name != "Uncategorized" && deck.name != "Learning" && deck.name != "Learnt"
                        }
                        selectedDeckIds = Set(selectableDecks.map { $0.id })
                        HapticManager.shared.mediumImpact()
                    }) {
                        VStack {
                            Image(systemName: "checkmark.circle")
                            Text("Select All")
                        }
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        VStack {
                            Image(systemName: "chevron.backward")
                            Text("Back")
                        }
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
        .sheet(isPresented: $showingExportImport) {
            ExportImportView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddDeck) {
            AddDeckView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingMoveDeckSheet) {
            if let deck = deckToMove {
                MoveDeckSheet(viewModel: viewModel, deck: deck) {
                    deckToMove = nil
                }
            }
        }
        .sheet(isPresented: $showingBulkMoveSheet) {
            BulkMoveDeckSheet(viewModel: viewModel, deckIds: selectedDeckIds) {
                isSelectionMode = false
                selectedDeckIds.removeAll()
            }
        }
        .alert("Rename Deck", isPresented: $showingRenameDeckAlert) {
            TextField("Deck Name", text: $newDeckName)
            Button("Cancel", role: .cancel) {
                deckToRename = nil
                newDeckName = ""
            }
            Button("Rename") {
                if let deck = deckToRename {
                    viewModel.renameDeck(deck, newName: newDeckName)
                }
                deckToRename = nil
                newDeckName = ""
                // Exit selection mode after editing
                if isSelectionMode {
                    isSelectionMode = false
                    selectedDeckIds.removeAll()
                }
            }
            .disabled(newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } message: {
            Text("Enter a new name for the deck")
        }
        .alert("Delete Deck", isPresented: $showingDeleteDeckAlert) {
            Button("Cancel", role: .cancel) {
                deckToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let deck = deckToDelete {
                    viewModel.deleteDeck(deck)
                }
                deckToDelete = nil
            }
        } message: {
            if let deck = deckToDelete {
                Text("Are you sure you want to delete '\(deck.name)'? This will also delete all \(deck.cards.count) cards in this deck.")
            } else {
                Text("Are you sure you want to delete this deck?")
            }
        }
        .alert("Delete Selected Decks", isPresented: $showingBulkDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                let selectedDecks = viewModel.decks.filter { selectedDeckIds.contains($0.id) }
                for deck in selectedDecks {
                    viewModel.deleteDeck(deck)
                }
                isSelectionMode = false
                selectedDeckIds.removeAll()
                HapticManager.shared.mediumImpact()
            }
        } message: {
            let selectedDecks = viewModel.decks.filter { selectedDeckIds.contains($0.id) }
            let totalCards = selectedDecks.reduce(0) { $0 + $1.cards.count }
            Text("Are you sure you want to delete \(selectedDeckIds.count) decks? This will also delete \(totalCards) cards.")
        }
        
        // Navigation destinations
        NavigationLink(destination: 
            Group {
                if let card = selectedCardForEdit {
                    EditCardView(viewModel: viewModel, card: card)
                } else {
                    EmptyView()
                }
            }, isActive: $showingEditCardView) {
            EmptyView()
        }
        .hidden()
        .onChange(of: showingEditCardView) { newValue in
            // Refresh search results when returning from EditCardView
            if !newValue {
                // Force a refresh by temporarily clearing and resetting search
                let currentSearch = searchText
                searchText = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    searchText = currentSearch
                }
                // Clear the selected card
                selectedCardForEdit = nil
            }
        }
    }
}

struct MoveDeckSheet: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let deck: Deck
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedParentId: UUID?
    
    private var availableParentDecks: [Deck] {
        // Get top-level decks, excluding the deck being moved and Uncategorized
        return viewModel.getTopLevelDecks().filter { 
            $0.name != "Uncategorized" && $0.id != deck.id 
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Move '\(deck.name)' to:")) {
                    // Option for top level
                    Button(action: {
                        selectedParentId = nil
                    }) {
                        HStack {
                            Text("Top Level (Main Deck)")
                            Spacer()
                            if selectedParentId == nil && deck.parentId == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            } else if selectedParentId == nil {
                                Image(systemName: deck.parentId == nil ? "checkmark" : "circle")
                                    .foregroundColor(deck.parentId == nil ? .blue : .gray)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    // Options for under other decks
                    ForEach(availableParentDecks) { parentDeck in
                        Button(action: {
                            selectedParentId = parentDeck.id
                        }) {
                            HStack {
                                Text("Under \(parentDeck.name)")
                                Spacer()
                                if selectedParentId == parentDeck.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                } else if deck.parentId == parentDeck.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section {
                    if deck.parentId == nil {
                        Text("Currently a top-level deck")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if let parentDeck = viewModel.decks.first(where: { $0.id == deck.parentId }) {
                        Text("Currently under \(parentDeck.name)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Move Deck")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Move") {
                        moveDeck()
                        onComplete()
                        dismiss()
                    }
                    .disabled(!hasChanges())
                }
            })
            .onAppear {
                // Initialize with current parent
                selectedParentId = deck.parentId
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func hasChanges() -> Bool {
        if let selectedId = selectedParentId {
            return deck.parentId != selectedId
        } else {
            return deck.parentId != nil
        }
    }
    
    private func moveDeck() {
        // Remove from current parent if it has one
        if let currentParentId = deck.parentId,
           let currentParentIndex = viewModel.decks.firstIndex(where: { $0.id == currentParentId }) {
            viewModel.decks[currentParentIndex].subDeckIds.remove(deck.id)
        }
        
        // Update the deck's parent
        if let deckIndex = viewModel.decks.firstIndex(where: { $0.id == deck.id }) {
            viewModel.decks[deckIndex].parentId = selectedParentId
        }
        
        // Add to new parent if selected
        if let newParentId = selectedParentId,
           let newParentIndex = viewModel.decks.firstIndex(where: { $0.id == newParentId }) {
            viewModel.decks[newParentIndex].subDeckIds.insert(deck.id)
        }
        
        // Haptic feedback for successful move
        HapticManager.shared.mediumImpact()
    }
}

struct BulkMoveDeckSheet: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let deckIds: Set<UUID>
    let onComplete: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedParentId: UUID?
    
    private var selectedDecks: [Deck] {
        return viewModel.decks.filter { deckIds.contains($0.id) }
    }
    
    private var availableParentDecks: [Deck] {
        // Get top-level decks, excluding the decks being moved and Uncategorized
        return viewModel.getTopLevelDecks().filter { 
            $0.name != "Uncategorized" && !deckIds.contains($0.id)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Move \(deckIds.count) decks to:")) {
                    // Option for top level
                    Button(action: {
                        selectedParentId = nil
                    }) {
                        HStack {
                            Text("Top Level (Main Deck)")
                            Spacer()
                            if selectedParentId == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    
                    // Options for under other decks
                    ForEach(availableParentDecks) { parentDeck in
                        Button(action: {
                            selectedParentId = parentDeck.id
                        }) {
                            HStack {
                                Text("Under \(parentDeck.name)")
                                Spacer()
                                if selectedParentId == parentDeck.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
                
                Section(header: Text("Decks to move")) {
                    ForEach(selectedDecks) { deck in
                        Text(deck.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Move Decks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Move") {
                        bulkMoveDecks()
                        onComplete()
                        dismiss()
                    }
                }
            })
        }
        .presentationDetents([.medium, .large])
    }
    
    private func bulkMoveDecks() {
        for deckId in deckIds {
            // Remove from current parent if it has one
            if let deckIndex = viewModel.decks.firstIndex(where: { $0.id == deckId }),
               let currentParentId = viewModel.decks[deckIndex].parentId,
               let currentParentIndex = viewModel.decks.firstIndex(where: { $0.id == currentParentId }) {
                viewModel.decks[currentParentIndex].subDeckIds.remove(deckId)
            }
            
            // Update the deck's parent
            if let deckIndex = viewModel.decks.firstIndex(where: { $0.id == deckId }) {
                viewModel.decks[deckIndex].parentId = selectedParentId
            }
            
            // Add to new parent if selected
            if let newParentId = selectedParentId,
               let newParentIndex = viewModel.decks.firstIndex(where: { $0.id == newParentId }) {
                viewModel.decks[newParentIndex].subDeckIds.insert(deckId)
            }
        }
        
        // Haptic feedback for successful move
        HapticManager.shared.mediumImpact()
    }
} 