import SwiftUI

struct MainNavigationView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @ObservedObject var streakManager: StreakManager
    @StateObject private var navigationCoordinator = NavigationCoordinator.shared
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.navigationPath) {
            VStack(spacing: 0) {
                // Main content based on selected tab
                mainContent
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.large)
                    .background(backgroundColor)
                
                // Bottom Navigation - always show
                BottomNavigationView(
                    viewModel: viewModel,
                    selectedTab: $navigationCoordinator.currentTab,
                    onNavigate: { tab in
                        // Clear navigation path when switching tabs
                        if navigationCoordinator.currentTab != tab {
                            navigationCoordinator.navigationPath = NavigationPath()
                        }
                        navigationCoordinator.navigate(to: tab)
                    }
                )
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                destinationView(for: destination)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: navigationCoordinator.currentTab)
        .preferredColorScheme(settingsManager.getCurrentColorScheme())
        .sheet(item: $navigationCoordinator.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .alert(item: $navigationCoordinator.showingAlert) { alert in
            alertView(for: alert)
        }
        .withNavigationCoordinator()
        .handleDismissToRoot()
        .overlay(
            GlobalNotificationOverlay()
        )
        .onAppear {
            // Reset navigation state when app appears
            viewModel.resetNavigationToRoot()
            
            // Show welcome popup on first launch
            if isFirstLaunch() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    markFirstLaunchComplete()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var navigationTitle: String {
        switch navigationCoordinator.currentTab {
        case .home: return ""
        case .cards: return ""
        case .settings: return ""
        }
    }
    
    private var backgroundColor: Color {
        switch navigationCoordinator.currentTab {
        case .cards: return Color(.systemGroupedBackground)
        default: return Color(.systemBackground)
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch navigationCoordinator.currentTab {
        case .home:
            VStack(spacing: 0) {
                UnifiedHeader(
                    title: BuildConfiguration.appName,
                    showBackButton: false,
                    onProfile: { navigationCoordinator.presentSheet(.userProfile) }
                )
                ScrollView {
                    VStack(spacing: 24) {
                        // Study Modes Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Flash Card Studies")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            VStack(spacing: 12) {
                                NavigationButton(
                                    title: "Study Your Cards",
                                    icon: "book.fill",
                                    color: .teal,
                                    gameMode: .study,
                                    action: {
                                        navigationCoordinator.push(NavigationDestination.studyTypeSelection(.study, .adaptive))
                                    }
                                )
                                
                                NavigationButton(
                                    title: "Test Your Cards",
                                    icon: "checkmark.circle.fill",
                                    color: .orange,
                                    gameMode: .test,
                                    action: {
                                        navigationCoordinator.push(NavigationDestination.studyTypeSelection(.test, .adaptive))
                                    }
                                )
                                
                                NavigationButton(
                                    title: "True or False",
                                    icon: "questionmark.circle.fill",
                                    color: Color(red: 1.0, green: 0.4, blue: 0.3),
                                    gameMode: .truefalse,
                                    action: {
                                        navigationCoordinator.push(NavigationDestination.studyTypeSelection(.truefalse, .adaptive))
                                    }
                                )
                                
                                NavigationButton(
                                    title: "Write Your Card",
                                    icon: "pencil.and.scribble",
                                    color: Color(red: 1.0, green: 0.6, blue: 0.0),
                                    gameMode: .writing,
                                    action: {
                                        navigationCoordinator.push(NavigationDestination.studyTypeSelection(.writing, .adaptive))
                                    }
                                )
                                
                                NavigationButton(
                                    title: "Remember Your Cards",
                                    icon: "brain.fill",
                                    color: .orange,
                                    gameMode: .game,
                                    action: {
                                        navigationCoordinator.push(NavigationDestination.studyTypeSelection(.game, .adaptive))
                                    }
                                )
                                
                                NavigationButton(
                                    title: "Jumble Your Cards",
                                    icon: "textformat.abc",
                                    color: Color(red: 1.0, green: 0.4, blue: 0.3),
                                    gameMode: .wordScramble,
                                    action: {
                                        navigationCoordinator.push(NavigationDestination.studyTypeSelection(.wordScramble, .adaptive))
                                    }
                                )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                        
                        // Resources Section - Only show if there are available features
                        if BuildConfiguration.isFeatureAvailable(.dutchLessons) || BuildConfiguration.isFeatureAvailable(.dutchGrammar) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Resources")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                VStack(spacing: 12) {
                                    // Only show Dutch Lessons in full version
                                    if BuildConfiguration.isFeatureAvailable(.dutchLessons) {
                                        NavigationLink(destination: LessonsListView(viewModel: viewModel)) {
                                            HStack {
                                                Image(systemName: "book.closed.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.blue)
                                                    .frame(width: 30)
                                                Text("Dutch Lessons")
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(12)
                                            .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
                                        }
                                    }
                                    
                                    // Only show Dutch Grammar in full version
                                    if BuildConfiguration.isFeatureAvailable(.dutchGrammar) {
                                        Button(action: {
                                            navigationCoordinator.push(NavigationDestination.dutchGrammar)
                                        }) {
                                            HStack {
                                                Image(systemName: "book.pages.fill")
                                                    .font(.title2)
                                                    .foregroundStyle(
                                                        LinearGradient(
                                                            colors: [.blue, .purple],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                                    .frame(width: 30)
                                                Text("Dutch Grammar")
                                                    .font(.body)
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding()
                                            .frame(maxWidth: .infinity)
                                            .background(Color(.secondarySystemGroupedBackground))
                                            .cornerRadius(12)
                                            .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
                                        }
                                    }
                                    
                                    Button(action: {
                                        navigationCoordinator.push(NavigationDestination.bubbleWordMapSelection)
                                    }) {
                                        HStack {
                                            Image(systemName: "bubble.left.and.bubble.right")
                                                .font(.title2)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.green, .teal],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 30)
                                            Text("Bubble Word")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .green.opacity(0.2), radius: 3, x: 0, y: 1)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            // Show only Bubble Word in lite version
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Features")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                                VStack(spacing: 12) {
                                    Button(action: {
                                        navigationCoordinator.push(NavigationDestination.bubbleWordMapSelection)
                                    }) {
                                        HStack {
                                            Image(systemName: "bubble.left.and.bubble.right")
                                                .font(.title2)
                                                .foregroundStyle(
                                                    LinearGradient(
                                                        colors: [.green, .teal],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: 30)
                                            Text("Bubble Word")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            Spacer()
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .cornerRadius(12)
                                        .shadow(color: .green.opacity(0.2), radius: 3, x: 0, y: 1)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarHidden(true)
        case .cards:
            VStack(spacing: 0) {
                UnifiedHeader(
                    title: "Cards",
                    showBackButton: false,
                    onProfile: { navigationCoordinator.presentSheet(.userProfile) },
                    leading: {
                        AnyView(
                            Button(action: {
                                navigationCoordinator.presentSheet(.cardsInfo)
                            }) {
                                Image(systemName: "info.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        )
                    }
                )
                ScrollView {
                    CardsManagementView(
                        viewModel: viewModel,
                        showingAddCardView: .constant(false),
                        showingAddDeckView: .constant(false),
                        showingImageImportView: .constant(false)
                    )
                }
                .background(Color(.systemBackground))
            }
            .navigationBarHidden(true)
        case .settings:
            SettingsView(viewModel: viewModel, isSheet: false)
        }
    }
    
    // MARK: - Navigation Destinations
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .deckSelection(let mode):
            SimplifiedDeckSelectionView(viewModel: viewModel, mode: mode, startFlipped: false)
        case .studyModeSelection(let gameMode):
            StudyModeSelectionView(viewModel: viewModel, gameMode: gameMode)
        case .studyTypeSelection(let gameMode, let studyMode):
            StudyTypeSelectionView(viewModel: viewModel, gameMode: gameMode)
        case .quickStudy(let gameMode, let studyMode, let cardCount, let startFlipped):
            QuickStudyView(viewModel: viewModel, gameMode: gameMode, selectedStudyMode: studyMode, startFlipped: startFlipped)
        case .normalStudy(let gameMode, let studyMode, let startFlipped):
            SimplifiedDeckSelectionView(viewModel: viewModel, mode: gameMode, startFlipped: startFlipped)
        case .progressiveStudy(let gameMode, let startFlipped):
            ProgressiveStudyView(viewModel: viewModel, gameMode: gameMode, startFlipped: startFlipped)
        case .continueGame(let gameMode):
            continueGameView(for: gameMode)
        case .deck(let deck):
            DeckView(viewModel: viewModel, deck: deck)
        case .allCards:
            AllCardsView(viewModel: viewModel)
        case .manageDecks:
            ManageDecksView(viewModel: viewModel)
        case .imageImport:
            ImageImportView(viewModel: viewModel)
        case .studyView(let cards, let deckIds):
            StudyView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .testView(let cards, let deckIds):
            TestView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false, startFlipped: false)
        case .gameView(let cards, let deckIds):
            GameView(viewModel: viewModel, cards: cards, difficulty: .medium, deckIds: deckIds, shouldLoadSaveState: false)
        case .trueFalseView(let cards, let deckIds):
            TrueFalseView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .writingView(let cards, let deckIds):
            WritingView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .wordScrambleView(let cards, let deckIds):
            WordScrambleView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .dutchVocabulary:
            // Only show in full version
            if BuildConfiguration.isFeatureAvailable(.dutchVocabulary) {
                DutchVocabularyImportView(viewModel: viewModel)
            } else {
                FeatureNotAvailableView(feature: "Dutch Vocabulary Import")
            }
        case .dutchGrammar:
            // Only show in full version
            if BuildConfiguration.isFeatureAvailable(.dutchGrammar) {
                DutchGrammarRulesView()
            } else {
                FeatureNotAvailableView(feature: "Dutch Grammar")
            }
        case .bubbleWord:
            BubbleWordView(viewModel: viewModel)
                .navigationBarHidden(true)
        case .bubbleWordMapSelection:
            BubbleWordMapSelectionView(viewModel: viewModel, bubbleManager: BubbleWordManager.shared)
                .navigationBarHidden(true)
        case .custom(let key):
            if key == "lessons" {
                // Only show in full version
                if BuildConfiguration.isFeatureAvailable(.dutchLessons) {
                    LessonsListView(viewModel: viewModel)
                } else {
                    FeatureNotAvailableView(feature: "Dutch Lessons")
                }
            }
        }
    }
    
    // MARK: - Continue Game View
    @ViewBuilder
    private func continueGameView(for gameMode: GameMode) -> some View {
        switch gameMode {
        case .study:
            if let savedState = SaveStateManager.shared.loadGameState(gameType: .study, as: StudyGameState.self) {
                StudyView(viewModel: viewModel, cards: savedState.cards, deckIds: [], shouldLoadSaveState: true)
            } else {
                // Fallback if no save state found
                StudyView(viewModel: viewModel, cards: [], deckIds: [], shouldLoadSaveState: false)
            }
        case .test:
            if let savedState = SaveStateManager.shared.loadGameState(gameType: .test, as: TestGameState.self) {
                TestView(viewModel: viewModel, cards: savedState.cards, deckIds: [], shouldLoadSaveState: true, startFlipped: false)
            } else {
                // Fallback if no save state found
                TestView(viewModel: viewModel, cards: [], deckIds: [], shouldLoadSaveState: false, startFlipped: false)
            }
        case .game:
            if let savedState = SaveStateManager.shared.loadGameState(gameType: .memoryGame, as: MemoryGameState.self) {
                // For memory game, we need to reconstruct the cards from the saved state
                let allCards = savedState.gameCards.compactMap { savedCard in
                    // Find the original card in the viewModel
                    viewModel.flashCards.first { $0.id == savedCard.originalCardId }
                }
                GameView(viewModel: viewModel, cards: allCards, difficulty: .medium, deckIds: [], shouldLoadSaveState: true)
            } else {
                // Fallback if no save state found
                GameView(viewModel: viewModel, cards: [], difficulty: .medium, deckIds: [], shouldLoadSaveState: false)
            }
        case .truefalse:
            if let savedState = SaveStateManager.shared.loadGameState(gameType: .trueFalse, as: TrueFalseGameState.self) {
                TrueFalseView(viewModel: viewModel, cards: savedState.cards, deckIds: [], shouldLoadSaveState: true)
            } else {
                // Fallback if no save state found
                TrueFalseView(viewModel: viewModel, cards: [], deckIds: [], shouldLoadSaveState: false)
            }
        case .writing:
            if let savedState = SaveStateManager.shared.loadGameState(gameType: .writing, as: WritingGameState.self) {
                WritingView(viewModel: viewModel, cards: savedState.cards, deckIds: [], shouldLoadSaveState: true)
            } else {
                // Fallback if no save state found
                WritingView(viewModel: viewModel, cards: [], deckIds: [], shouldLoadSaveState: false)
            }
        case .wordScramble:
            if let savedState = SaveStateManager.shared.loadGameState(gameType: .wordScramble, as: WordScrambleGameState.self) {
                WordScrambleView(viewModel: viewModel, cards: savedState.cards, deckIds: [], shouldLoadSaveState: true)
            } else {
                // Fallback if no save state found
                WordScrambleView(viewModel: viewModel, cards: [], deckIds: [], shouldLoadSaveState: false)
            }
        }
    }
    
    // MARK: - Sheet Views
    @ViewBuilder
    private func sheetView(for sheet: NavigationCoordinator.SheetType) -> some View {
        switch sheet {
        case .addCard(let deck, let initialWord, let initialDefinition):
            AddCardView(viewModel: viewModel, defaultDeck: deck, initialWord: initialWord, initialDefinition: initialDefinition)
        case .addDeck:
            AddDeckView(viewModel: viewModel)
        case .editCard(let card):
            EditCardView(viewModel: viewModel, card: card)
        case .moveCards(let cardIds, let deck):
            AllCardsMoveSheet(
                viewModel: viewModel,
                selectedCardIds: Set(cardIds),
                onComplete: {
                    navigationCoordinator.dismissSheet()
                }
            )
        case .settings:
            SettingsView(viewModel: viewModel, isSheet: true)
        case .savedGames:
            SavedGamesView(viewModel: viewModel)
        case .exportImport:
            ExportImportView(viewModel: viewModel)
        case .gameInfo(let gameType):
            gameInfoView(for: gameType)
        case .cardsInfo:
            CardsInfoView()
        case .dutchGrammarInfo:
            DutchGrammarInfoView()
        case .userProfile:
            UserProfileView()
        }
    }
    
    @ViewBuilder
    private func gameInfoView(for gameType: NavigationCoordinator.GameInfoType) -> some View {
        switch gameType {
        case .study:
            StudyInfoView(viewModel: viewModel)
        case .test:
            TestInfoView(viewModel: viewModel)
        case .truefalse:
            TrueFalseInfoView(viewModel: viewModel)
        case .writing:
            WritingInfoView(viewModel: viewModel)
        case .memoryGame:
            MemoryGameInfoView(viewModel: viewModel)
        case .wordScramble:
            WordScrambleInfoView(viewModel: viewModel)
        }
    }
    
    // MARK: - Alert Views
    private func alertView(for alert: NavigationCoordinator.AlertType) -> Alert {
        switch alert {
        case .deleteCard(let card):
            return Alert(
                title: Text("Delete Card"),
                message: Text("Are you sure you want to delete '\(card.word)'?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let index = viewModel.flashCards.firstIndex(where: { $0.id == card.id }) {
                        viewModel.deleteCard(at: IndexSet([index]))
                    }
                },
                secondaryButton: .cancel()
            )
        case .deleteDeck(let deck):
            return Alert(
                title: Text("Delete Deck"),
                message: Text("Are you sure you want to delete '\(deck.name)' and all its cards?"),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.deleteDeck(deck)
                },
                secondaryButton: .cancel()
            )
        case .resetStats:
            return Alert(
                title: Text("Reset Statistics"),
                message: Text("This will reset all learning progress. This action cannot be undone."),
                primaryButton: .destructive(Text("Reset")) {
                    viewModel.resetLearningStatistics()
                },
                secondaryButton: .cancel()
            )
        case .closeGame(let hasProgress):
            return Alert(
                title: Text("Close Game?"),
                message: Text(hasProgress ? "Would you like to save your progress?" : "Are you sure you want to close?"),
                primaryButton: .destructive(Text(hasProgress ? "Save & Close" : "Close")) {
                    navigationCoordinator.dismissToRoot()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    // MARK: - First Launch Helpers
    private func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasLaunched")
    }
    
    private func markFirstLaunchComplete() {
        UserDefaults.standard.set(true, forKey: "hasLaunched")
    }
}

// MARK: - Simplified Home Content
struct HomeContentView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 24) {
            // Study Modes Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Flash Card Studies")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    NavigationButton(
                        title: "Study Your Cards",
                        icon: "book.fill",
                        color: .teal,
                        gameMode: .study,
                        action: {
                            navigationCoordinator.push(NavigationDestination.studyTypeSelection(.study, .adaptive))
                        }
                    )
                    
                    NavigationButton(
                        title: "Test Your Cards",
                        icon: "checkmark.circle.fill",
                        color: .orange,
                        gameMode: .test,
                        action: {
                            navigationCoordinator.push(NavigationDestination.studyTypeSelection(.test, .adaptive))
                        }
                    )
                    
                    NavigationButton(
                        title: "True or False",
                        icon: "questionmark.circle.fill",
                        color: Color(red: 1.0, green: 0.4, blue: 0.3),
                        gameMode: .truefalse,
                        action: {
                            navigationCoordinator.push(NavigationDestination.studyTypeSelection(.truefalse, .adaptive))
                        }
                    )
                    
                    NavigationButton(
                        title: "Write Your Card",
                        icon: "pencil.and.scribble",
                        color: Color(red: 1.0, green: 0.6, blue: 0.0),
                        gameMode: .writing,
                        action: {
                            navigationCoordinator.push(NavigationDestination.studyTypeSelection(.writing, .adaptive))
                        }
                    )
                    
                    NavigationButton(
                        title: "Remember Your Cards",
                        icon: "brain.fill",
                        color: .orange,
                        gameMode: .game,
                        action: {
                            navigationCoordinator.push(NavigationDestination.studyTypeSelection(.game, .adaptive))
                        }
                    )
                    
                    NavigationButton(
                        title: "Jumble Your Cards",
                        icon: "textformat.abc",
                        color: Color(red: 1.0, green: 0.4, blue: 0.3),
                        gameMode: .wordScramble,
                        action: {
                            navigationCoordinator.push(NavigationDestination.studyTypeSelection(.wordScramble, .adaptive))
                        }
                    )
                }
            }
            .padding(.horizontal)
            
            // Resources Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Resources")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                VStack(spacing: 12) {
                    NavigationLink(destination: LessonsListView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "book.closed.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            Text("Dutch Lessons")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
                    }
                    Button(action: {
                        navigationCoordinator.push(NavigationDestination.dutchGrammar)
                    }) {
                        HStack {
                            Image(systemName: "book.pages.fill")
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 30)
                            Text("Dutch Grammar")
                                .font(.body)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Reusable Navigation Button
struct NavigationButton: View {
    let title: String
    let icon: String
    let color: Color
    let gameMode: GameMode
    let action: () -> Void
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        HStack(spacing: 12) {
            // Main button
            Button(action: action) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 30)
                    
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .shadow(color: color.opacity(0.2), radius: 3, x: 0, y: 1)
            }
            
            // Info button
            Button(action: {
                navigationCoordinator.presentSheet(.gameInfo(gameMode.gameInfoType))
            }) {
                Image(systemName: "info.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
} 