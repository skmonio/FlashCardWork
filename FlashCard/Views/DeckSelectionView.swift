import SwiftUI

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: StudyMode
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingContinueGameOverlay = false
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingSaveOverwriteWarning = false
    
    enum StudyMode {
        case study, test, game, truefalse, hangman, dehet, writing
        
        var title: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .game: return "Memory Game"
            case .truefalse: return "True or False"
            case .hangman: return "Hangman"
            case .dehet: return "de of het"
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
                            .foregroundColor(selectedDeckIds.isEmpty || availableCards.isEmpty ? .gray : .blue)
                            .disabled(selectedDeckIds.isEmpty || availableCards.isEmpty)
                            .buttonStyle(PlainButtonStyle())
                            
                            // Continue Game Button (always present, grayed out if no save state)
                            Button(action: {
                                if hasSaveState {
                                    shouldContinueGame = true
                                    shouldStartGame = true
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
                    } else {
                        Section {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Start \(mode.title)")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Text("Select decks to continue")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Continue Game Button (always present, grayed out if no save state or no decks selected)
                            Button(action: {
                                // Do nothing when no decks selected
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Continue Saved Game")
                                            .font(.headline)
                                            .foregroundColor(.gray)
                                        
                                        HStack {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                            Text("Select decks to continue")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    Spacer()
                                    Image(systemName: "arrow.clockwise")
                                        .foregroundColor(.gray)
                                }
                            }
                            .disabled(true)
                            .buttonStyle(PlainButtonStyle())
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
                        print("🎮 User chose to continue game")
                        shouldContinueGame = true
                        shouldStartGame = true
                    },
                    onStartFresh: {
                        print("🆕 User chose to start fresh")
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
                .onAppear {
                    print("🎨 ContinueGameOverlay appeared")
                }
                .onDisappear {
                    print("🎨 ContinueGameOverlay disappeared")
                }
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
        .onChange(of: showingContinueGameOverlay) { oldValue, newValue in
            print("🎨 showingContinueGameOverlay changed from \(oldValue) to \(newValue)")
        }
        .alert("Overwrite Saved Game?", isPresented: $showingSaveOverwriteWarning) {
            Button("Start New Game", role: .destructive) {
                // Delete the save state and start fresh
                SaveStateManager.shared.deleteSaveState(
                    gameType: mode.saveStateType,
                    deckIds: Array(selectedDeckIds)
                )
                shouldContinueGame = false
                shouldStartGame = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Starting a new game will overwrite your current saved progress. Are you sure you want to continue?")
        }
        .onAppear {
            // Reset navigation state when view appears
            shouldStartGame = false
            shouldContinueGame = false
            showingContinueGameOverlay = false
            showingSaveOverwriteWarning = false
        }
    }
    
    private func handleStartGame() {
        print("🚀 handleStartGame called for \(mode.title)")
        print("📋 Selected decks: \(selectedDeckIds.count), Available cards: \(availableCards.count)")
        print("🔍 Checking save state...")
        
        // Skip save state check for Hangman
        if mode == .hangman {
            print("🎯 Hangman mode - starting directly")
            shouldContinueGame = false
            shouldStartGame = true
            return
        }
        
        let hasExistingSave = hasSaveState
        print("💾 Has existing save: \(hasExistingSave)")
        
        if hasExistingSave {
            print("⚠️ Showing save overwrite warning")
            showingSaveOverwriteWarning = true
        } else {
            print("✨ Starting fresh game")
            shouldContinueGame = false
            shouldStartGame = true
        }
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