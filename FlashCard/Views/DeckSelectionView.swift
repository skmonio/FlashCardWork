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
    @State private var showingStudyInfo = false
    @State private var showingTestInfo = false
    @State private var showingTrueFalseInfo = false
    @State private var showingWritingInfo = false
    @State private var showingMemoryGameInfo = false
    @State private var showingWordScrambleInfo = false
    @State private var showingCardsInfo = false
    
    enum StudyMode: String {
        case study = "study"
        case test = "test" 
        case game = "game"
        case truefalse = "truefalse"
        case writing = "writing"
        case wordScramble = "wordScramble"
        
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

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Show different content based on selection
                if showingCardsContent {
                    ScrollView {
                        CardsManagementView(
                            viewModel: viewModel,
                            showingAddCardView: $showingAddCardView,
                            showingAddDeckView: $showingAddDeckView,
                            showingImageImportView: $showingImageImportView
                        )
                    }
                } else if showingSettingsContent {
                    SettingsView(viewModel: viewModel, isSheet: false)
                } else {
                    deckSelectionContent
                }
                
                // Bottom Navigation - always show for consistent UX
                BottomNavigationView(
                    viewModel: viewModel,
                    selectedTab: .constant(showingCardsContent ? .cards : showingSettingsContent ? .settings : .home),
                    onNavigate: handleBottomNavigation
                )
            }
            .background(showingCardsContent ? Color(.systemGroupedBackground) : Color(.systemBackground))
            .navigationTitle(showingCardsContent ? "" : 
                           showingSettingsContent ? "Settings" : mode.title)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !showingCardsContent && !showingSettingsContent {
                        // Show back button only in main deck selection view
                        Button("Back") {
                            dismiss()
                        }
                    }
                }
                
                // Custom title for cards content (like HomeView)
                if showingCardsContent {
                    ToolbarItem(placement: .principal) {
                        Text("Taal Trek")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if showingCardsContent {
                        // Show "How to Add Cards" button when in cards content (like HomeView)
                        Button("How to Add Cards") {
                            showingCardsInfo = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    } else if !showingSettingsContent {
                        // Show "How to Play" button when in deck selection mode (not in settings or cards)
                        Button(action: {
                            showInfoPopup()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "questionmark.circle")
                                    .font(.caption)
                                Text("How to Play")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                        }
                        .onLongPressGesture {
                            // Debug function: reset first-visit flags
                            resetFirstVisitFlags()
                        }
                    }
                    // No button shown when in settings content
                }
            }
            
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
        .sheet(isPresented: $showingStudyInfo) {
            StudyInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingTestInfo) {
            TestInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingTrueFalseInfo) {
            TrueFalseInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingWritingInfo) {
            WritingInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingMemoryGameInfo) {
            MemoryGameInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingWordScrambleInfo) {
            WordScrambleInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCardsInfo) {
            CardsInfoView()
        }
        .onAppear {
            // Reset navigation state when view appears
            shouldStartGame = false
            shouldContinueGame = false
            showingContinueGameOverlay = false
            showingSaveOverwriteWarning = false
            showingCardsContent = false
            showingSettingsContent = false
            
            // Show appropriate info popup only on first visit
            if isFirstVisit(for: mode) {
                showInfoPopup()
                markAsVisited(for: mode)
            }
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
            // Reset all popup states when navigating to cards
            resetAllPopupStates()
            // Show AllCardsView content like from home screen
            showingCardsContent = true
            showingSettingsContent = false
        case .settings:
            // Reset all popup states when navigating to settings
            resetAllPopupStates()
            // Show settings content instead of navigating to SettingsView
            showingCardsContent = false
            showingSettingsContent = true
        }
    }
    
    // Helper function to reset all popup states
    private func resetAllPopupStates() {
        showingStudyInfo = false
        showingTestInfo = false
        showingTrueFalseInfo = false
        showingWritingInfo = false
        showingMemoryGameInfo = false
        showingWordScrambleInfo = false
        showingCardsInfo = false
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
    
    // Helper function to show info popup for current mode
    private func showInfoPopup() {
        switch mode {
        case .study:
            showingStudyInfo = true
        case .test:
            showingTestInfo = true
        case .truefalse:
            showingTrueFalseInfo = true
        case .writing:
            showingWritingInfo = true
        case .game:
            showingMemoryGameInfo = true
        case .wordScramble:
            showingWordScrambleInfo = true
        }
    }
    
    // Debug function to reset first-visit flags
    private func resetFirstVisitFlags() {
        let allModes = [StudyMode.study, .test, .game, .truefalse, .writing, .wordScramble]
        for mode in allModes {
            let key = "hasVisited_\(mode.rawValue)"
            UserDefaults.standard.set(false, forKey: key)
        }
        print("🆕 First-visit flags reset")
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