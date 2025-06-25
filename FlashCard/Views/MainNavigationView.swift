import SwiftUI

struct MainNavigationView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @ObservedObject var streakManager: StreakManager
    @StateObject private var navigationCoordinator = NavigationCoordinator.shared
    @StateObject private var settingsManager = SettingsManager.shared
    
    // Welcome popup state
    @State private var showingWelcome = false
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.navigationPath) {
            VStack(spacing: 0) {
                // Main content based on selected tab
                mainContent
                    .navigationTitle(navigationTitle)
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        // Streak in top left
                        ToolbarItem(placement: .navigationBarLeading) {
                            if navigationCoordinator.currentTab == .home {
                                streakView
                            }
                        }
                        
                        // What is Taal Trek button in top right
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if navigationCoordinator.currentTab == .home {
                                Button("What is Taal Trek") {
                                    showingWelcome = true
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            } else if navigationCoordinator.currentTab == .cards {
                                Button("How to Add Cards") {
                                    navigationCoordinator.presentSheet(.cardsInfo)
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
                            }
                        }
                    }
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
        .sheet(isPresented: $showingWelcome) {
            WelcomeView(isPresented: $showingWelcome)
        }
        .alert(item: $navigationCoordinator.showingAlert) { alert in
            alertView(for: alert)
        }
        .withNavigationCoordinator()
        .handleDismissToRoot()
        .onAppear {
            // Reset navigation state when app appears
            viewModel.resetNavigationToRoot()
            
            // Show welcome popup on first launch
            if isFirstLaunch() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showingWelcome = true
                    markFirstLaunchComplete()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    private var navigationTitle: String {
        switch navigationCoordinator.currentTab {
        case .home: return "Taal Trek"
        case .cards: return "Cards"
        case .settings: return "Settings"
        }
    }
    
    private var backgroundColor: Color {
        switch navigationCoordinator.currentTab {
        case .cards: return Color(.systemGroupedBackground)
        default: return Color(.systemBackground)
        }
    }
    
    private var streakView: some View {
        HStack(spacing: 8) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundColor(streakManager.currentStreak > 0 ? .orange : .gray)
            
            Text("\(streakManager.currentStreak)")
                .font(.title2)
                .bold()
                .foregroundColor(streakManager.currentStreak > 0 ? .orange : .gray)
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private var mainContent: some View {
        switch navigationCoordinator.currentTab {
        case .home:
            ScrollView {
                HomeContentView(viewModel: viewModel)
            }
        case .cards:
            ScrollView {
                CardsManagementView(
                    viewModel: viewModel,
                    showingAddCardView: .constant(false),
                    showingAddDeckView: .constant(false),
                    showingImageImportView: .constant(false)
                )
            }
        case .settings:
            SettingsView(viewModel: viewModel, isSheet: false)
        }
    }
    
    // MARK: - Navigation Destinations
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .deckSelection(let mode):
            SimplifiedDeckSelectionView(viewModel: viewModel, mode: mode)
        case .deck(let deck):
            DeckView(viewModel: viewModel, deck: deck)
        case .allCards:
            AllCardsView(viewModel: viewModel)
        case .manageDecks:
            ManageDecksView(viewModel: viewModel)
        case .studyView(let cards, let deckIds):
            StudyView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .testView(let cards, let deckIds):
            TestView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .gameView(let cards, let deckIds):
            GameView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .trueFalseView(let cards, let deckIds):
            TrueFalseView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .writingView(let cards, let deckIds):
            WritingView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .wordScrambleView(let cards, let deckIds):
            WordScrambleView(viewModel: viewModel, cards: cards, deckIds: deckIds, shouldLoadSaveState: false)
        case .dutchVocabulary:
            NavigationView {
                DutchVocabularyImportView(
                    viewModel: viewModel
                )
            }
        case .dutchGrammar:
            NavigationView {
                DutchGrammarRulesView()
            }
        case .card3DShowcase:
            Card3DShowcaseView()
        }
    }
    
    // MARK: - Sheet Views
    @ViewBuilder
    private func sheetView(for sheet: NavigationCoordinator.SheetType) -> some View {
        switch sheet {
        case .addCard(let deck):
            AddCardView(viewModel: viewModel, defaultDeck: deck)
        case .addDeck:
            AddDeckView(viewModel: viewModel)
        case .imageImport:
            ImageImportView(viewModel: viewModel)
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
                Text("Study Modes")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    NavigationButton(
                        title: "Study Your Cards",
                        icon: "book.fill",
                        color: .teal
                    ) {
                        navigationCoordinator.push(NavigationDestination.deckSelection(.study))
                    }
                    
                    NavigationButton(
                        title: "Test Your Cards",
                        icon: "checkmark.circle.fill",
                        color: .orange
                    ) {
                        navigationCoordinator.push(NavigationDestination.deckSelection(.test))
                    }
                    
                    NavigationButton(
                        title: "True or False",
                        icon: "questionmark.circle.fill",
                        color: Color(red: 1.0, green: 0.4, blue: 0.3)
                    ) {
                        navigationCoordinator.push(NavigationDestination.deckSelection(.truefalse))
                    }
                    
                    NavigationButton(
                        title: "Write Your Card",
                        icon: "pencil.and.scribble",
                        color: Color(red: 1.0, green: 0.6, blue: 0.0)
                    ) {
                        navigationCoordinator.push(NavigationDestination.deckSelection(.writing))
                    }
                }
            }
            .padding(.top)
            
            // Games Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Games")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    NavigationButton(
                        title: "Remember Your Cards",
                        icon: "brain.fill",
                        color: .orange
                    ) {
                        navigationCoordinator.push(NavigationDestination.deckSelection(.game))
                    }
                    
                    NavigationButton(
                        title: "Jumble Your Cards",
                        icon: "textformat.abc",
                        color: Color(red: 1.0, green: 0.4, blue: 0.3)
                    ) {
                        navigationCoordinator.push(NavigationDestination.deckSelection(.wordScramble))
                    }
                    
                    NavigationButton(
                        title: "3D Card Experiments",
                        icon: "cube.fill",
                        color: .purple
                    ) {
                        navigationCoordinator.push(NavigationDestination.card3DShowcase)
                    }
                }
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
    let action: () -> Void
    
    var body: some View {
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
    }
} 