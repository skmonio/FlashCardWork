import SwiftUI

struct SimplifiedDeckSelectionView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: StudyMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingContinueGameOverlay = false
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingSaveOverwriteWarning = false
    
    var availableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            return []
        } else {
            var uniqueCards: Set<FlashCard> = []
            for deckId in selectedDeckIds {
                if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                    uniqueCards.formUnion(deck.cards)
                }
            }
            return Array(uniqueCards)
        }
    }
    
    private var hasSaveState: Bool {
        return SaveStateManager.shared.hasSaveState(gameType: mode.saveStateType)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Select Decks")) {
                    Button(action: {
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
                        // Start Game Button
                        Button(action: {
                            handleStartGame()
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Start \(mode.title)")
                                        .font(.headline)
                                }
                                Spacer()
                                Text("\(availableCards.count) cards")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.blue)
                        .buttonStyle(PlainButtonStyle())
                        
                        // Continue Game Button
                        Button(action: {
                            if hasSaveState {
                                HapticManager.shared.lightImpact()
                                shouldContinueGame = true
                                startGame()
                            }
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Continue Saved Game")
                                        .font(.headline)
                                        .foregroundColor(hasSaveState ? .green : .gray)
                                    
                                    HStack {
                                        Image(systemName: "clock.fill")
                                            .foregroundColor(hasSaveState ? .green : .gray)
                                            .font(.caption)
                                        Text(hasSaveState ? "Pick up where you left off" : "No saved game available")
                                            .font(.caption)
                                            .foregroundColor(hasSaveState ? .green : .gray)
                                    }
                                }
                                Spacer()
                                Image(systemName: "arrow.clockwise")
                                    .foregroundColor(hasSaveState ? .green : .gray)
                            }
                        }
                        .disabled(!hasSaveState)
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    navigationCoordinator.presentSheet(.gameInfo(mode.gameInfoType))
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "questionmark.circle")
                            .font(.caption)
                        Text("How to Play")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .alert("Overwrite Saved Game?", isPresented: $showingSaveOverwriteWarning) {
            Button("Start New Game", role: .destructive) {
                HapticManager.shared.lightImpact()
                SaveStateManager.shared.deleteSaveState(gameType: mode.saveStateType)
                shouldContinueGame = false
                startGame()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Starting a new game will overwrite your current saved progress. Are you sure you want to continue?")
        }
        .onAppear {
            // Show appropriate info popup only on first visit
            if isFirstVisit(for: mode) {
                navigationCoordinator.presentSheet(.gameInfo(mode.gameInfoType))
                markAsVisited(for: mode)
            }
        }
    }
    
    private func handleStartGame() {
        HapticManager.shared.lightImpact()
        
        if hasSaveState {
            showingSaveOverwriteWarning = true
        } else {
            shouldContinueGame = false
            startGame()
        }
    }
    
    private func startGame() {
        let deckIdArray = Array(selectedDeckIds)
        
        switch mode {
        case .study:
            navigationCoordinator.push(NavigationDestination.studyView(availableCards, deckIdArray))
        case .test:
            navigationCoordinator.push(NavigationDestination.testView(availableCards, deckIdArray))
        case .game:
            navigationCoordinator.push(NavigationDestination.gameView(availableCards, deckIdArray))
        case .truefalse:
            navigationCoordinator.push(NavigationDestination.trueFalseView(availableCards, deckIdArray))
        case .writing:
            navigationCoordinator.push(NavigationDestination.writingView(availableCards, deckIdArray))
        case .wordScramble:
            navigationCoordinator.push(NavigationDestination.wordScrambleView(availableCards, deckIdArray))
        }
    }
    
    // Helper function to check if it's the first time visiting this mode
    private func isFirstVisit(for mode: StudyMode) -> Bool {
        let key = "hasVisited_\(mode.rawValue)"
        return !UserDefaults.standard.bool(forKey: key)
    }
    
    // Helper function to mark mode as visited
    private func markAsVisited(for mode: StudyMode) {
        let key = "hasVisited_\(mode.rawValue)"
        UserDefaults.standard.set(true, forKey: key)
    }
}

// MARK: - StudyMode Extensions
extension StudyMode {
    var saveStateType: GameSaveState.SavedGameType {
        switch self {
        case .study: return .study
        case .test: return .test
        case .game: return .memoryGame
        case .truefalse: return .trueFalse
        case .writing: return .writing
        case .wordScramble: return .wordScramble
        }
    }
    
    var gameInfoType: NavigationCoordinator.GameInfoType {
        switch self {
        case .study: return .study
        case .test: return .test
        case .truefalse: return .truefalse
        case .writing: return .writing
        case .game: return .memoryGame
        case .wordScramble: return .wordScramble
        }
    }
} 