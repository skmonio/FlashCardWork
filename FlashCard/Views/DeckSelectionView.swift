import SwiftUI

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: StudyMode
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingContinueGameOverlay = false
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    
    enum StudyMode {
        case study, test, game, truefalse, hangman, dehet, lookcovercheck, writing
        
        var title: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .game: return "Memory Game"
            case .truefalse: return "True or False"
            case .hangman: return "Hangman"
            case .dehet: return "de of het"
            case .lookcovercheck: return "Look Cover Check"
            case .writing: return "Write Your Card"
            }
        }
        
        var saveStateType: GameSaveState.SavedGameType {
            switch self {
            case .study: return .study
            case .test: return .test
            case .game: return .memoryGame
            case .truefalse: return .trueFalse
            case .hangman: return .hangman
            case .dehet: return .dehet
            case .lookcovercheck: return .lookCoverCheck
            case .writing: return .writing
            }
        }
    }
    
    var availableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            return []  // Return empty array when no decks are selected
        } else {
            // Get unique cards that belong to any of the selected decks
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
        guard !selectedDeckIds.isEmpty else { return false }
        return SaveStateManager.shared.hasSaveState(
            gameType: mode.saveStateType,
            deckIds: Array(selectedDeckIds)
        )
    }

    var body: some View {
        ZStack {
            VStack {
                List {
                    Section(header: Text("Select Decks")) {
                        Button(action: {
                            // Toggle all decks
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
                            Button(action: {
                                handleStartGame()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Start \(mode.title)")
                                            .foregroundColor(.blue)
                                            .font(.headline)
                                        
                                        if hasSaveState {
                                            HStack {
                                                Image(systemName: "clock.fill")
                                                    .foregroundColor(.green)
                                                    .font(.caption)
                                                Text("Saved game available")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                    Spacer()
                                    Text("\(availableCards.count) cards")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                .navigationTitle(mode.title)
                .navigationBarBackButtonHidden(true)
                
                Spacer()
                
                // Bottom Navigation Bar
                HStack {
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
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
                // Dismiss this view when dismiss to root is requested
                dismiss()
            }
            
            // Continue Game Overlay
            if showingContinueGameOverlay {
                ContinueGameOverlay(
                    gameType: mode.saveStateType,
                    deckIds: Array(selectedDeckIds),
                    cardCount: availableCards.count,
                    onContinue: {
                        shouldContinueGame = true
                        shouldStartGame = true
                    },
                    onStartFresh: {
                        // Delete the save state and start fresh
                        SaveStateManager.shared.deleteSaveState(
                            gameType: mode.saveStateType,
                            deckIds: Array(selectedDeckIds)
                        )
                        shouldContinueGame = false
                        shouldStartGame = true
                    },
                    isPresented: $showingContinueGameOverlay
                )
            }
        }
        .navigationDestination(isPresented: $shouldStartGame) {
            destinationView
        }
    }
    
    private func handleStartGame() {
        if hasSaveState {
            showingContinueGameOverlay = true
        } else {
            shouldContinueGame = false
            shouldStartGame = true
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch mode {
        case .study:
            StudyViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        case .test:
            TestViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        case .game:
            GameViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        case .truefalse:
            TrueFalseViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        case .hangman:
            HangmanViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        case .dehet:
            DeHetGameViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        case .lookcovercheck:
            LookCoverCheckViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        case .writing:
            WritingViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: Array(selectedDeckIds),
                shouldContinue: shouldContinueGame
            )
        }
    }
}

// MARK: - Wrapper Views for Save State Integration
struct StudyViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        StudyView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
    }
}

struct TestViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        TestView(viewModel: viewModel, cards: cards)
            .onAppear {
                if shouldContinue {
                    // Load saved state logic will be implemented in TestView
                }
            }
    }
}

struct GameViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        GameView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
    }
}

struct TrueFalseViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        TrueFalseView(viewModel: viewModel, cards: cards)
            .onAppear {
                if shouldContinue {
                    // Load saved state logic will be implemented in TrueFalseView
                }
            }
    }
}

struct HangmanViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        HangmanView(viewModel: viewModel, cards: cards)
            .onAppear {
                if shouldContinue {
                    // Load saved state logic will be implemented in HangmanView
                }
            }
    }
}

struct DeHetGameViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        DeHetGameView(viewModel: viewModel, cards: cards)
            .onAppear {
                if shouldContinue {
                    // Load saved state logic will be implemented in DeHetGameView
                }
            }
    }
}

struct LookCoverCheckViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        LookCoverCheckView(viewModel: viewModel, cards: cards)
            .onAppear {
                if shouldContinue {
                    // Load saved state logic will be implemented in LookCoverCheckView
                }
            }
    }
}

struct WritingViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        WritingView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
    }
} 