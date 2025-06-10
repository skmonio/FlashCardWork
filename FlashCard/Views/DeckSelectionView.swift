import SwiftUI

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: StudyMode
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingNewGameWarning = false
    
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
            case .dehet: return .dehet
            case .lookcovercheck: return .lookCoverCheck
            case .writing: return .writing
            case .hangman:
                fatalError("Hangman game does not support save states")
            }
        }
    }
    
    var availableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            print("⚠️ No decks selected - returning empty cards array")
            return []  // Return empty array when no decks are selected
        } else {
            // Get unique cards that belong to any of the selected decks
            var uniqueCards: Set<FlashCard> = []
            for deckId in selectedDeckIds {
                if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                    print("📦 Found deck '\(deck.name)' with \(deck.cards.count) cards")
                    uniqueCards.formUnion(deck.cards)
                } else {
                    print("❌ Deck with ID \(deckId) not found")
                }
            }
            let finalCards = Array(uniqueCards)
            print("🎯 Total unique cards available: \(finalCards.count)")
            return finalCards
        }
    }
    
    private var hasSaveState: Bool {
        guard !selectedDeckIds.isEmpty else { 
            print("💾 No decks selected - no save state")
            return false 
        }
        
        // Skip save state for Hangman game
        if mode == .hangman {
            print("💾 Hangman mode - no save state support")
            return false
        }
        
        let saveExists = SaveStateManager.shared.hasSaveState(
            gameType: mode.saveStateType,
            deckIds: Array(selectedDeckIds)
        )
        
        print("💾 Save state check for \(mode.title): \(saveExists)")
        if saveExists {
            if let info = SaveStateManager.shared.getSaveStateInfo(gameType: mode.saveStateType, deckIds: Array(selectedDeckIds)) {
                print("💾 Save info: saved \(info.date), \(info.deckCount) decks")
            }
        }
        
        return saveExists
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
                    
                    if !availableCards.isEmpty || selectedDeckIds.isEmpty {
                        Section {
                            // Start Game Button
                            Button(action: {
                                handleStartGame()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Start \(mode.title)")
                                            .font(.headline)
                                        Text("Begin a new game")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if !selectedDeckIds.isEmpty {
                                        Text("\(availableCards.count) cards")
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .foregroundColor(selectedDeckIds.isEmpty ? .gray : .blue)
                            .disabled(selectedDeckIds.isEmpty)
                            .buttonStyle(PlainButtonStyle())
                            
                            // Continue Game Button
                            Button(action: {
                                handleContinueGame()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Continue Game")
                                            .font(.headline)
                                        if hasSaveState {
                                            HStack {
                                                Image(systemName: "clock.fill")
                                                    .font(.caption)
                                                Text("Resume saved progress")
                                                    .font(.caption)
                                            }
                                        } else {
                                            Text("No saved game available")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .foregroundColor(hasSaveState ? .green : .gray)
                            .disabled(!hasSaveState)
                            .buttonStyle(PlainButtonStyle())
                            
                            // Hidden NavigationLink for programmatic navigation
                            NavigationLink(
                                destination: destinationView,
                                isActive: $shouldStartGame
                            ) {
                                EmptyView()
                            }
                            .opacity(0)
                            .frame(height: 0)
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
        }
        .onChange(of: shouldStartGame) { oldValue, newValue in
            if newValue {
                print("🎮 Starting game: \(mode.title), Continue: \(shouldContinueGame), Decks: \(selectedDeckIds.count)")
                print("📊 Available cards: \(availableCards.count)")
                print("🔗 Deck IDs: \(Array(selectedDeckIds))")
            }
            if oldValue && !newValue {
                print("🔄 Game navigation state reset")
            }
        }
        .onAppear {
            // Reset navigation state when view appears
            shouldStartGame = false
            shouldContinueGame = false
        }
        .alert("Clear Saved Game?", isPresented: $showingNewGameWarning) {
            Button("Start New Game", role: .destructive) {
                startFreshGame()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Starting a new game will clear your current saved progress. Are you sure you want to continue?")
        }
    }
    
    private func handleStartGame() {
        print("🚀 handleStartGame called for \(mode.title)")
        print("📋 Selected decks: \(selectedDeckIds.count), Available cards: \(availableCards.count)")
        
        // Check if there's existing save state and warn user
        if hasSaveState {
            print("⚠️ Existing save state found - showing warning")
            showingNewGameWarning = true
        } else {
            print("🔍 No existing save state - starting fresh game")
            startFreshGame()
        }
    }
    
    private func startFreshGame() {
        print("🔍 Starting fresh game...")
        
        // Always start fresh when using Start Game button
        if mode != .hangman {
            // Delete any existing save state to ensure fresh start
            SaveStateManager.shared.deleteSaveState(
                gameType: mode.saveStateType,
                deckIds: Array(selectedDeckIds)
            )
        }
        
        shouldContinueGame = false
        shouldStartGame = true
    }
    
    private func handleContinueGame() {
        print("🔄 handleContinueGame called for \(mode.title)")
        print("📋 Selected decks: \(selectedDeckIds.count), Available cards: \(availableCards.count)")
        print("🔍 Continuing saved game...")
        
        // Continue with existing save state
        shouldContinueGame = true
        shouldStartGame = true
    }
    
    @ViewBuilder
    private var destinationView: some View {
        let deckIdArray = Array(selectedDeckIds)
        
        switch mode {
        case .study:
            StudyViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
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
        case .hangman:
            HangmanViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .dehet:
            DeHetGameViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .lookcovercheck:
            LookCoverCheckViewWithSaveState(
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
        .onAppear {
            print("📖 StudyViewWithSaveState appearing - Cards: \(cards.count), DeckIds: \(deckIds.count), ShouldContinue: \(shouldContinue)")
        }
    }
}

struct TestViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        TestView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
        .onAppear {
            print("✅ TestViewWithSaveState appearing - Cards: \(cards.count), DeckIds: \(deckIds.count), ShouldContinue: \(shouldContinue)")
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
        .onAppear {
            print("🧠 GameViewWithSaveState appearing - Cards: \(cards.count), DeckIds: \(deckIds.count), ShouldContinue: \(shouldContinue)")
        }
    }
}

struct TrueFalseViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        TrueFalseView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
        .onAppear {
            print("🔥 TrueFalseViewWithSaveState appearing - Cards: \(cards.count), DeckIds: \(deckIds.count), ShouldContinue: \(shouldContinue)")
        }
    }
}

struct HangmanViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        // Hangman doesn't support save states, so just use regular view
        HangmanView(viewModel: viewModel, cards: cards)
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
        LookCoverCheckView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
        .onAppear {
            print("👁️ LookCoverCheckViewWithSaveState appearing - Cards: \(cards.count), DeckIds: \(deckIds.count), ShouldContinue: \(shouldContinue)")
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
        .onAppear {
            print("✏️ WritingViewWithSaveState appearing - Cards: \(cards.count), DeckIds: \(deckIds.count), ShouldContinue: \(shouldContinue)")
        }
    }
} 