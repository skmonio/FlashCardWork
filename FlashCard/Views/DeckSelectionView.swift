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
    @State private var showingCardsContent = false
    @State private var showingSettingsContent = false
    
    // Cards page state variables (same as HomeView)
    @State private var showingAddCardView = false
    @State private var showingAddDeckView = false
    @State private var showingImageImportView = false
    
    enum StudyMode {
        case study, test, game, truefalse, writing, wordScramble
        
        var title: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .game: return "Memory Game"
            case .truefalse: return "True or False"
            case .writing: return "Write Your Card"
            case .wordScramble: return "Jumble Your Cards"
            }
        }
        
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
        let saveExists = SaveStateManager.shared.hasSaveState(gameType: mode.saveStateType)
        
        print("💾 Save state check for \(mode.title): \(saveExists)")
        if saveExists {
            if let saveDate = SaveStateManager.shared.getSaveStateInfo(gameType: mode.saveStateType) {
                print("💾 Save info: saved \(saveDate)")
            }
        }
        
        return saveExists
    }
    
    private var deckSelectionContent: some View {
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
                            // Play game start sound
                            // SoundManager.shared.playGameStartSound()
                            HapticManager.shared.lightImpact()
                            
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
    }
    
    private var cardsContent: some View {
        VStack(spacing: 16) {
            if viewModel.flashCards.isEmpty && viewModel.decks.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    
                    Text("No Cards Yet")
                        .font(.title2)
                        .bold()
                    
                    Text("Start building your flashcard collection by adding your first card or creating a deck.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 60)
                
                // Quick action buttons
                VStack(spacing: 12) {
                    Button(action: {
                        showingAddCardView = true
                    }) {
                        MenuButton(title: "Add Your First Card", icon: "plus.rectangle.fill", color: .orange)
                    }
                    
                    Button(action: {
                        showingAddDeckView = true
                    }) {
                        MenuButton(title: "Create Your First Deck", icon: "folder.badge.plus", color: .teal)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            } else {
                // Quick stats
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Total Cards")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.flashCards.count)")
                                .font(.title2)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Total Decks")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.decks.count)")
                                .font(.title2)
                                .bold()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Navigate to manage cards
                VStack(spacing: 12) {
                    NavigationLink(destination: ManageDecksView(viewModel: viewModel)) {
                        MenuButton(title: "Manage Your Decks", icon: "folder.fill", color: .teal)
                    }
                    
                    Button(action: {
                        showingAddCardView = true
                    }) {
                        MenuButton(title: "Add New Card", icon: "plus.rectangle.fill", color: .orange)
                    }
                    
                    Button(action: {
                        showingAddDeckView = true
                    }) {
                        MenuButton(title: "Create New Deck", icon: "folder.badge.plus", color: Color(red: 1.0, green: 0.4, blue: 0.3))
                    }
                    
                    Button(action: {
                        showingImageImportView = true
                    }) {
                        MenuButton(title: "Import from Image", icon: "photo.on.rectangle.angled", color: Color(red: 1.0, green: 0.6, blue: 0.0))
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Show different content based on selection
                if showingCardsContent {
                    ScrollView {
                        cardsContent
                    }
                } else if showingSettingsContent {
                    SettingsView(viewModel: viewModel, isSheet: false)
                } else {
                    deckSelectionContent
                }
                
                // Bottom Navigation
                BottomNavigationView(
                    viewModel: viewModel,
                    selectedTab: showingCardsContent ? .constant(.cards) : 
                                 showingSettingsContent ? .constant(.settings) : .constant(.home),
                    onNavigate: handleBottomNavigation
                )
            }
            .navigationTitle(mode.title)
            .navigationBarBackButtonHidden(true)
            
            .navigationDestination(isPresented: Binding(
                get: { viewModel.shouldNavigateToManageDecks },
                set: { if !$0 { viewModel.resetNavigationToManageDecks() } }
            )) {
                ManageDecksView(viewModel: viewModel)
            }
            .navigationDestination(isPresented: Binding(
                get: { viewModel.shouldNavigateToSettings },
                set: { if !$0 { viewModel.resetNavigationToSettings() } }
            )) {
                SettingsView(viewModel: viewModel, isSheet: false)
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
                        // SoundManager.shared.playGameStartSound()
                        HapticManager.shared.lightImpact()
                        shouldContinueGame = true
                        shouldStartGame = true
                    },
                    onStartFresh: {
                        print("🆕 User chose to start fresh")
                        // SoundManager.shared.playGameStartSound()
                        HapticManager.shared.lightImpact()
                        // Delete the save state and start fresh
                        SaveStateManager.shared.deleteSaveState(gameType: mode.saveStateType)
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
        .onChange(of: shouldStartGame) { newValue in
            if newValue {
                // Game will start automatically via NavigationLink
                print("🎮 shouldStartGame changed to: \(newValue)")
            }
        }
        .onChange(of: showingContinueGameOverlay) { newValue in
            if !newValue {
                // Reset the flag when overlay is dismissed
                shouldStartGame = false
            }
        }
        .alert("Overwrite Saved Game?", isPresented: $showingSaveOverwriteWarning) {
            Button("Start New Game", role: .destructive) {
                // Play game start sound
                // SoundManager.shared.playGameStartSound()
                HapticManager.shared.lightImpact()
                // Delete the save state and start fresh
                SaveStateManager.shared.deleteSaveState(gameType: mode.saveStateType)
                shouldContinueGame = false
                shouldStartGame = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Starting a new game will overwrite your current saved progress. Are you sure you want to continue?")
        }
        .sheet(isPresented: $showingAddCardView) {
            AddCardView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddDeckView) {
            AddDeckView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingImageImportView) {
            ImageImportView(viewModel: viewModel)
        }
        .onAppear {
            // Reset navigation state when view appears
            shouldStartGame = false
            shouldContinueGame = false
            showingContinueGameOverlay = false
            showingSaveOverwriteWarning = false
            showingCardsContent = false
            showingSettingsContent = false
        }
    }
    
    private func handleStartGame() {
        print("🚀 handleStartGame called for \(mode.title)")
        print("📋 Selected decks: \(selectedDeckIds.count), Available cards: \(availableCards.count)")
        
        // Play game start sound - DISABLED FOR TESTING
        // SoundManager.shared.playGameStartSound()
        HapticManager.shared.lightImpact()
        
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
    
    private func handleBottomNavigation(_ tab: BottomNavigationView.TabItem) {
        // Handle navigation from bottom bar
        switch tab {
        case .home:
            // Always go back to actual HomeView, not just deck selection
            dismiss()
        case .cards:
            // Show cards content instead of navigating to ManageDecksView
            showingCardsContent = true
            showingSettingsContent = false
        case .settings:
            // Show settings content instead of navigating to SettingsView
            showingCardsContent = false
            showingSettingsContent = true
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

struct WordScrambleViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        WordScrambleView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
        .onAppear {
            print("🎲 WordScrambleViewWithSaveState appearing - Cards: \(cards.count), DeckIds: \(deckIds.count), ShouldContinue: \(shouldContinue)")
        }
    }
} 