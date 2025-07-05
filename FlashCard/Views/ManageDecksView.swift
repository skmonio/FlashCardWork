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
    
    // Sort functionality
    @State private var sortOption: SortOption = .alphabetical(ascending: true)
    
    enum SortOption: Hashable {
        case alphabetical(ascending: Bool)
        
        var label: String {
            switch self {
            case .alphabetical(let ascending): return ascending ? "A-Z" : "Z-A"
            }
        }
        
        var icon: String {
            switch self {
            case .alphabetical(let ascending): return ascending ? "arrow.up" : "arrow.down"
            }
        }
    }
    
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
    
    // Computed property for sorted decks
    private var sortedDecks: [Deck] {
        let allDecks = viewModel.getAllDecksHierarchical()
        
        // Separate parent decks and sub-decks
        let parentDecks = allDecks.filter { $0.parentId == nil }
        let subDecks = allDecks.filter { $0.parentId != nil }
        
        var result: [Deck] = []
        
        // Sort parent decks
        let sortedParents: [Deck]
        switch sortOption {
        case .alphabetical(let ascending):
            sortedParents = parentDecks.sorted { ascending ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        }
        
        // For each parent deck, add it and its sorted sub-decks
        for parentDeck in sortedParents {
            result.append(parentDeck)
            
            // Find and sort sub-decks for this parent
            let parentSubDecks = subDecks.filter { $0.parentId == parentDeck.id }
            let sortedSubDecks: [Deck]
            switch sortOption {
            case .alphabetical(let ascending):
                sortedSubDecks = parentSubDecks.sorted { ascending ? $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending : $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
            }
            
            result.append(contentsOf: sortedSubDecks)
        }
        
        return result
    }
    
    // Computed property for system decks (protected)
    private var systemDecks: [Deck] {
        return sortedDecks.filter { deck in
            deck.name == "Uncategorized" || deck.name == "Review"
        }
    }
    
    // Computed property for user-created decks (editable)
    private var userDecks: [Deck] {
        return sortedDecks.filter { deck in
            deck.name != "Uncategorized" && deck.name != "Review"
        }
    }
    
    // Computed property for search results
    private var searchResults: [Deck] {
        guard !searchText.isEmpty else { return [] }
        
        let results = viewModel.getAllDecksHierarchical().filter { deck in
            deck.name.localizedCaseInsensitiveContains(searchText)
        }
        
        // Sort alphabetically by default
        return results.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            UnifiedHeader(
                title: "Manage Decks",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { NavigationCoordinator.shared.pop() },
                trailing: {
                    AnyView(
                        Button(action: {
                            showingAddDeck = true
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
                    TextField("Search decks...", text: $searchText)
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
                    Button(action: {
                        if case .alphabetical(let ascending) = sortOption {
                            sortOption = .alphabetical(ascending: !ascending)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: sortOption.icon)
                            Text(sortOption.label)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray5).opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    Spacer()
                    
                    // Select Button
                    Button(action: {
                        isSelectionMode.toggle()
                        if !isSelectionMode {
                            selectedDeckIds.removeAll()
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
            
            // Main Content
            if !searchText.isEmpty {
                // Search results
                if searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No Decks Found")
                            .font(.title2)
                            .bold()
                        
                        Text("Try a different search term.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section(header: Text("Search Results (\(searchResults.count) decks)")) {
                            ForEach(searchResults) { deck in
                                NavigationLink {
                                    DeckView(viewModel: viewModel, deck: deck)
                                } label: {
                                    HStack {
                                        if isSelectionMode {
                                            Button(action: {
                                                if selectedDeckIds.contains(deck.id) {
                                                    selectedDeckIds.remove(deck.id)
                                                } else {
                                                    selectedDeckIds.insert(deck.id)
                                                }
                                            }) {
                                                Image(systemName: selectedDeckIds.contains(deck.id) ? "checkmark.circle.fill" : "circle")
                                                    .foregroundColor(selectedDeckIds.contains(deck.id) ? .blue : .gray)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                        
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
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    // Only show swipe actions for user-created decks (not system decks)
                                    let canModify = deck.name != "Uncategorized" && deck.name != "Review"
                                    
                                    if canModify {
                                        Button(role: .destructive) {
                                            deckToDelete = deck
                                            showingDeleteDeckAlert = true
                                            HapticManager.shared.lightImpact()
                                        } label: {
                                            Image(systemName: "trash")
                                        }
                                        
                                        Button {
                                            deckToMove = deck
                                            showingMoveDeckSheet = true
                                            HapticManager.shared.lightImpact()
                                        } label: {
                                            Image(systemName: "folder")
                                        }
                                        .tint(.orange)
                                        
                                        Button {
                                            deckToRename = deck
                                            newDeckName = deck.name
                                            showingRenameDeckAlert = true
                                            HapticManager.shared.lightImpact()
                                        } label: {
                                            Image(systemName: "pencil")
                                        }
                                        .tint(.blue)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            } else {
                // Regular deck display when not searching
                List {
                    // My Decks Section (Editable) - Now First
                    if !userDecks.isEmpty {
                        Section(header: 
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                Text("My Decks")
                                Spacer()
                                Text("\(userDecks.count) decks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        ) {
                            ForEach(userDecks) { deck in
                                HStack {
                                    if isSelectionMode {
                                        Button(action: {
                                            if selectedDeckIds.contains(deck.id) {
                                                selectedDeckIds.remove(deck.id)
                                            } else {
                                                selectedDeckIds.insert(deck.id)
                                            }
                                        }) {
                                            Image(systemName: selectedDeckIds.contains(deck.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedDeckIds.contains(deck.id) ? .blue : .gray)
                                        }
                                        .buttonStyle(PlainButtonStyle())
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
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deckToDelete = deck
                                        showingDeleteDeckAlert = true
                                        HapticManager.shared.lightImpact()
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    
                                    Button {
                                        deckToMove = deck
                                        showingMoveDeckSheet = true
                                        HapticManager.shared.lightImpact()
                                    } label: {
                                        Image(systemName: "folder")
                                    }
                                    .tint(.orange)
                                    
                                    Button {
                                        deckToRename = deck
                                        newDeckName = deck.name
                                        showingRenameDeckAlert = true
                                        HapticManager.shared.lightImpact()
                                    } label: {
                                        Image(systemName: "pencil")
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                    
                    // System Decks Section (Protected)
                    if !systemDecks.isEmpty {
                        Section(header: 
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                                Text("System Decks")
                                Spacer()
                                Text("Protected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        ) {
                            ForEach(systemDecks) { deck in
                                HStack {
                                    if isSelectionMode {
                                        // System decks cannot be selected
                                        Image(systemName: "minus.circle")
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                    
                                    NavigationLink {
                                        DeckView(viewModel: viewModel, deck: deck)
                                    } label: {
                                        HStack {
                                            Text(deck.name)
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
                .listStyle(PlainListStyle())
            }
            
            // Bottom Navigation Bar (only show when in selection mode)
            if isSelectionMode {
                HStack {
                    if !selectedDeckIds.isEmpty {
                        let selectedDecks = viewModel.decks.filter { selectedDeckIds.contains($0.id) }
                        let canModifyDecks = selectedDecks.allSatisfy { deck in
                            deck.name != "Uncategorized" && deck.name != "Review"
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
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .shadow(color: .red.opacity(0.2), radius: 3, x: 0, y: 1)
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
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .shadow(color: .orange.opacity(0.2), radius: 3, x: 0, y: 1)
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
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        } else {
                            Text("Cannot modify system decks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        // Show Select All when in selection mode but no decks selected
                        Button(action: {
                            selectedDeckIds = Set(userDecks.map { $0.id })
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
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
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
        // Get top-level decks, excluding the deck being moved and all system decks
        return viewModel.getTopLevelDecks()
            .filter { 
            $0.name != "Uncategorized" && 
            $0.name != "Review" && 
            $0.id != deck.id 
        }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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
        // Get top-level decks, excluding the decks being moved and all system decks
        return viewModel.getTopLevelDecks()
            .filter {
            $0.name != "Uncategorized" && $0.name != "Review" && !deckIds.contains($0.id)
        }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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