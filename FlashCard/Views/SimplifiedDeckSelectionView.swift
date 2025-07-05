import SwiftUI

struct SimplifiedDeckSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: GameMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingSaveOverwriteWarning = false
    @State private var selectedStudyMode: StudyMode = .adaptive
    @State private var selectedDifficulty: MemoryGameDifficulty = .medium
    @State private var showingDeckPicker = false
    
    var totalAvailableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            return []
        }
        var uniqueCards: Set<FlashCard> = []
        for deckId in selectedDeckIds {
            if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                uniqueCards.formUnion(deck.cards)
            }
        }
        return Array(uniqueCards)
    }
    
    var availableCards: [FlashCard] {
        let total = totalAvailableCards
        guard !total.isEmpty else { return [] }
        
        // For memory game, use all cards without study mode filtering
        if mode == .game {
            return total
        }
        
        // For other modes, apply study mode filtering
        switch selectedStudyMode {
        case .adaptive:
            // Check if this is a new deck (most cards have 0% learning)
            let unstudiedCards = total.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage == 0 && card.timesShown == 0
            }
            
            // If more than 70% of cards are unstudied, show all cards to establish baseline
            if Double(unstudiedCards.count) / Double(total.count) > 0.7 {
                return total
            }
            
            // For established decks, use adaptive filtering
            let strugglingCards = total.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage < 70 || card.consecutiveIncorrect > 0
            }
            
            // If we have enough struggling cards, use them. Otherwise, use all cards but prioritize struggling ones
            if strugglingCards.count >= Int(Double(total.count) * 0.3) {
                return Array(strugglingCards.prefix(Int(Double(total.count) * 0.3)))
            } else {
                // Sort by adaptive score and take top 30%
                let sortedCards = SmartStudyManager.shared.sortCardsForStudyMode(total, mode: .adaptive)
                return Array(sortedCards.prefix(Int(Double(total.count) * 0.3)))
            }
            
        case .cram:
            // For cram mode, use all cards
            return total
            
        case .maintenance:
            // For maintenance mode, only include cards that are learned but need maintenance (70-90% learning percentage)
            let maintenanceCards = total.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage >= 70 && percentage <= 90
            }
            
            // If we have enough maintenance cards, use them. Otherwise, use all cards but prioritize maintenance ones
            if maintenanceCards.count >= Int(Double(total.count) * 0.7) {
                return Array(maintenanceCards.prefix(Int(Double(total.count) * 0.7)))
            } else {
                // Sort by maintenance score and take top 70%
                let sortedCards = SmartStudyManager.shared.sortCardsForStudyMode(total, mode: .maintenance)
                return Array(sortedCards.prefix(Int(Double(total.count) * 0.7)))
            }
        }
    }
    
    var hasSaveState: Bool {
        return SaveStateManager.shared.hasSaveState(gameType: mode.saveStateType)
    }
    
    var selectedDeckNames: String {
        if selectedDeckIds.isEmpty {
            return "No decks selected"
        }
        let filteredDecks = viewModel.decks.filter { selectedDeckIds.contains($0.id) }
        if filteredDecks.count == 1 {
            return filteredDecks.first!.name
        } else {
            return "\(filteredDecks.count) decks selected"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Deck Selection Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Deck Selection")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 12) {
                        deckSelectionButton
                        
                        // Study Mode Selection for Deck Selection
                        VStack(alignment: .leading, spacing: 8) {
                            if mode == .game {
                                difficultySelectionView
                            } else {
                                studyModeSelectionView
                            }
                        }
                    }
                }
                
                // Start Button
                startButton
            }
            .padding()
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    dismiss()
                }
            }
        }
        
        NavigationLink(
            destination: destinationView,
            isActive: $shouldStartGame
        ) {
            EmptyView()
        }
        .opacity(0)
        .frame(height: 0)
        .sheet(isPresented: $showingDeckPicker) {
            SimplifiedDeckPickerView(
                viewModel: viewModel,
                selectedDeckIds: $selectedDeckIds
            )
        }
        .alert("Overwrite Saved Game?", isPresented: $showingSaveOverwriteWarning) {
            Button("Start New Game", role: .destructive) {
                HapticManager.shared.lightImpact()
                SaveStateManager.shared.deleteSaveState(gameType: mode.saveStateType)
                shouldContinueGame = false
                shouldStartGame = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Starting a new game will overwrite your current saved progress. Are you sure you want to continue?")
        }
        .onAppear {
            showingSaveOverwriteWarning = false
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        let deckIdArray = Array(selectedDeckIds)
        
        switch mode {
        case .study:
            SimplifiedStudyViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame,
                selectedStudyMode: selectedStudyMode
            )
        case .test:
            TestViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .game:
            GameViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame,
                difficulty: selectedDifficulty
            )
        case .truefalse:
            TrueFalseViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .writing:
            WritingViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .wordScramble:
            WordScrambleViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        }
    }
    
    private func handleStartGame() {
        HapticManager.shared.lightImpact()
        
        let hasExistingSave = hasSaveState
        
        if hasExistingSave {
            showingSaveOverwriteWarning = true
        } else {
            shouldContinueGame = false
            shouldStartGame = true
        }
    }
    
    // MARK: - Study Mode Helpers
    
    private func getCardCountForMode() -> Int {
        return availableCards.count
    }
    
    private func getModeDescription() -> String {
        switch selectedStudyMode {
        case .adaptive:
            return "Focus on cards you struggle with most"
        case .cram:
            return "Intensive review of all cards"
        case .maintenance:
            return "Keep your best cards fresh"
        }
    }
    
    // MARK: - Difficulty Helpers
    
    private func getDifficultyDescription() -> String {
        switch selectedDifficulty {
        case .easy:
            return "Plenty of time to find matches"
        case .medium:
            return "Balanced challenge for most players"
        case .hard:
            return "Quick thinking required"
        }
    }
    
    private var deckSelectionButton: some View {
        Button(action: {
            showingDeckPicker = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Decks:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(selectedDeckNames)
                        .font(.body)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var difficultySelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Difficulty:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(MemoryGameDifficulty.allCases, id: \.self) { difficulty in
                    Button(action: {
                        selectedDifficulty = difficulty
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: difficulty.icon)
                                .font(.title3)
                                .foregroundColor(selectedDifficulty == difficulty ? difficulty.color : .gray)
                            
                            Text(difficulty.displayName)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(selectedDifficulty == difficulty ? difficulty.color : .gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedDifficulty == difficulty ? difficulty.color.opacity(0.1) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedDifficulty == difficulty ? difficulty.color : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Difficulty Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Difficulty Summary:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: selectedDifficulty.icon)
                            .font(.caption)
                            .foregroundColor(selectedDifficulty.color)
                        Text(selectedDifficulty.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text(selectedDifficulty.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(getDifficultyDescription())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(8)
                .background(selectedDifficulty.color.opacity(0.05))
                .cornerRadius(6)
            }
        }
    }
    
    private var studyModeSelectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Study Mode:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                ForEach(StudyMode.allCases, id: \.self) { studyMode in
                    Button(action: {
                        selectedStudyMode = studyMode
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: studyMode.icon)
                                .font(.title3)
                                .foregroundColor(selectedStudyMode == studyMode ? studyMode.color : .gray)
                            
                            Text(studyMode.displayName)
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(selectedStudyMode == studyMode ? studyMode.color : .gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(selectedStudyMode == studyMode ? studyMode.color.opacity(0.1) : Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedStudyMode == studyMode ? studyMode.color : Color.clear, lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Mode Summary
            VStack(alignment: .leading, spacing: 8) {
                Text("Mode Summary:")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: selectedStudyMode.icon)
                            .font(.caption)
                            .foregroundColor(selectedStudyMode.color)
                        Text(selectedStudyMode.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                        Spacer()
                        Text("~\(getCardCountForMode()) cards")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(getModeDescription())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(8)
                .background(selectedStudyMode.color.opacity(0.05))
                .cornerRadius(6)
            }
        }
    }
    
    private var startButton: some View {
        Button(action: {
            handleStartGame()
        }) {
            Text("Start")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(availableCards.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(12)
        }
        .disabled(availableCards.isEmpty)
    }
}

// MARK: - Helper Views

struct SimplifiedDeckPickerView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Binding var selectedDeckIds: Set<UUID>
    @Environment(\.dismiss) private var dismiss
    
    // Search functionality
    @State private var searchText = ""
    
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
    
    // Computed property for sorted and filtered decks
    private var filteredDecks: [Deck] {
        let allDecks = viewModel.getAllDecksHierarchical()
        
        // Filter by search text
        let searchFiltered = searchText.isEmpty ? allDecks : allDecks.filter { deck in
            deck.name.localizedCaseInsensitiveContains(searchText)
        }
        
        // Separate parent decks and sub-decks
        let parentDecks = searchFiltered.filter { $0.parentId == nil }
        let subDecks = searchFiltered.filter { $0.parentId != nil }
        
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
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search decks...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // Sort and Select All options
                    HStack {
                        // Sort button
                        Menu {
                            Button(action: {
                                sortOption = .alphabetical(ascending: true)
                            }) {
                                Label("A-Z", systemImage: "arrow.up")
                            }
                            
                            Button(action: {
                                sortOption = .alphabetical(ascending: false)
                            }) {
                                Label("Z-A", systemImage: "arrow.down")
                            }
                        } label: {
                            HStack {
                                Image(systemName: sortOption.icon)
                                Text(sortOption.label)
                                Image(systemName: "chevron.down")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(6)
                        }
                        
                        Spacer()
                        
                        // Select All / Deselect All button
                        Button(action: {
                            if selectedDeckIds.count == filteredDecks.count {
                                // Deselect all
                                selectedDeckIds.removeAll()
                            } else {
                                // Select all filtered decks
                                selectedDeckIds = Set(filteredDecks.map { $0.id })
                            }
                        }) {
                            Text(selectedDeckIds.count == filteredDecks.count ? "Deselect All" : "Select All")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                Divider()
                
                // Deck list
                List {
                    ForEach(filteredDecks) { deck in
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
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SimplifiedStudyViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    let selectedStudyMode: StudyMode
    @State private var shouldLoadSaveState = false
    
    var body: some View {
        Group {
            if shouldContinue {
                StudyView(
                    viewModel: viewModel,
                    cards: cards,
                    deckIds: deckIds,
                    shouldLoadSaveState: true
                )
            } else {
                StudyView(
                    viewModel: viewModel,
                    cards: cards,
                    deckIds: deckIds,
                    shouldLoadSaveState: false
                )
            }
        }
        .onAppear {
            shouldLoadSaveState = shouldContinue
            if !shouldContinue {
                SmartStudyManager.shared.startStudySession(mode: selectedStudyMode)
            }
        }
    }
} 