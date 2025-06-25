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
    @State private var showingQuickGame = false
    @State private var selectedQuickGameCount: Int = 0
    
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
                // Quick Game Section
                Section {
                    VStack(spacing: 16) {
                        // Card count selection dropdown
                        Picker("Number of Cards", selection: $selectedQuickGameCount) {
                            Text("Select...").tag(0)
                            ForEach([5, 10, 15, 20, 25, 30], id: \.self) { count in
                                Text("\(count) cards").tag(count)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                        
                        // Start Quick Game button
                        Button(action: {
                            startQuickGame()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Start Quick \(mode.title)")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedQuickGameCount > 0 ? Color.orange : Color.gray)
                            .cornerRadius(10)
                        }
                        .disabled(selectedQuickGameCount == 0)
                    }
                } header: {
                    Text("Quick Start")
                } footer: {
                    Text("Start a quick session with automatically selected cards from all your decks.")
                }
                
                // Deck Selection Section
                Section {
                    DeckDropdownChecklist(
                        viewModel: viewModel,
                        selectedDeckIds: $selectedDeckIds
                    )
                } header: {
                    Text("Custom Selection")
                } footer: {
                    Text("Choose specific decks for your \(mode.title.lowercased()) session.")
                }
                
                // Game Buttons Section
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
        .navigationDestination(isPresented: $showingQuickGame) {
            destinationView
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
    
    private func startQuickGame() {
        print("startQuickGame() called with selectedQuickGameCount: \(selectedQuickGameCount)")
        HapticManager.shared.lightImpact()
        showingQuickGame = true
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
    
    @ViewBuilder
    private var destinationView: some View {
        let selectedCards = generateQuickGameCards()
        
        switch mode {
        case .study:
            StudyView(viewModel: viewModel, cards: selectedCards, deckIds: [])
        case .test:
            TestView(viewModel: viewModel, cards: selectedCards, deckIds: [])
        case .game:
            GameView(viewModel: viewModel, cards: selectedCards, deckIds: [])
        case .truefalse:
            TrueFalseView(viewModel: viewModel, cards: selectedCards, deckIds: [])
        case .writing:
            WritingView(viewModel: viewModel, cards: selectedCards, deckIds: [])
        case .wordScramble:
            WordScrambleView(viewModel: viewModel, cards: selectedCards, deckIds: [])
        }
    }
    
    private func generateQuickGameCards() -> [FlashCard] {
        let allCards = viewModel.flashCards.shuffled()
        let newCards = allCards.filter { $0.timesShown == 0 }
        let learningCards = allCards.filter { $0.timesShown > 0 && ($0.learningPercentage ?? 0) < 80 }
        let knownCards = allCards.filter { ($0.learningPercentage ?? 0) >= 80 }

        var selected: [FlashCard] = []

        // Add new cards (never shown)
        let newCount = min(newCards.count, selectedQuickGameCount / 3)
        selected.append(contentsOf: newCards.prefix(newCount))

        // Add learning cards (shown but not mastered)
        let learningCount = min(learningCards.count, selectedQuickGameCount / 3)
        selected.append(contentsOf: learningCards.prefix(learningCount))

        // Add known cards (well learned) - fill remaining slots
        let knownCount = min(knownCards.count, selectedQuickGameCount - selected.count)
        selected.append(contentsOf: knownCards.prefix(knownCount))

        // If still not enough, fill from any remaining cards not already selected
        if selected.count < selectedQuickGameCount {
            let alreadySelectedIds = Set(selected.map { $0.id })
            let remainingCards = allCards.filter { !alreadySelectedIds.contains($0.id) }
            let needed = selectedQuickGameCount - selected.count
            selected.append(contentsOf: remainingCards.prefix(needed))
        }

        // Ensure we never return more than requested
        return Array(selected.prefix(selectedQuickGameCount)).shuffled()
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