import SwiftUI

struct SimplifiedDeckSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: GameMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingSaveOverwriteWarning = false
    @State private var selectedStudyMode: StudyMode = .adaptive
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
        return totalAvailableCards
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
                        
                        Button(action: {
                            // Select all decks
                            selectedDeckIds = Set(viewModel.decks.map { $0.id })
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Select All Decks")
                                    .font(.body)
                                    .foregroundColor(.blue)
                                Spacer()
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            // Clear all deck selections
                            selectedDeckIds.removeAll()
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Cancel Selection")
                                    .font(.body)
                                    .foregroundColor(.red)
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Study Mode Selection for Deck Selection
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
                }
                
                // Start Button
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
            .padding()
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.large)
        
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
            
            if isFirstVisit(for: mode) {
                navigationCoordinator.presentSheet(.gameInfo(mode.gameInfoType))
                markAsVisited(for: mode)
            }
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
                shouldContinue: shouldContinueGame
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
    
    private func isFirstVisit(for mode: GameMode) -> Bool {
        let key = "hasVisited_\(mode.rawValue)"
        return !UserDefaults.standard.bool(forKey: key)
    }
    
    private func markAsVisited(for mode: GameMode) {
        let key = "hasVisited_\(mode.rawValue)"
        UserDefaults.standard.set(true, forKey: key)
    }
    
    // MARK: - Study Mode Helpers
    
    private func getCardCountForMode() -> Int {
        let total = totalAvailableCards.count
        guard total > 0 else { return 0 } // Return 0 if no cards available
        
        switch selectedStudyMode {
        case .adaptive:
            return max(1, Int(Double(total) * 0.3)) // ~30% of cards
        case .cram:
            return total // 100% of cards
        case .maintenance:
            return max(1, Int(Double(total) * 0.7)) // ~70% of cards
        }
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
}

// MARK: - Helper Views

struct SimplifiedDeckPickerView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Binding var selectedDeckIds: Set<UUID>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.decks) { deck in
                    Button(action: {
                        if selectedDeckIds.contains(deck.id) {
                            selectedDeckIds.remove(deck.id)
                        } else {
                            selectedDeckIds.insert(deck.id)
                        }
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(deck.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
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