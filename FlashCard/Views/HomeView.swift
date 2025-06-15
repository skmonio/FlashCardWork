import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var showingExportImport = false
    @State private var showingResetAlert = false
    @State private var showingMoreGames = false
    @State private var showingSettings = false
    
    // Navigation state for full-screen forms
    @State private var showingAddCardView = false
    @State private var showingAddDeckView = false
    @State private var showingImageImportView = false
    
    // Bottom navigation state
    @State private var selectedTab: BottomNavigationView.TabItem = .home
    
    // Streak manager
    @StateObject private var streakManager = StreakManager.shared
    
    // Settings manager for theme
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Add loading check - show loading only for a brief moment during initialization
                Group {
                    if viewModel.decks.isEmpty && viewModel.flashCards.isEmpty {
                        // Show loading state briefly
                        VStack {
                            ProgressView()
                            Text("Loading FlashCards...")
                                .padding(.top)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // Show main content based on selected tab
                        mainContent
                            .navigationTitle(navigationTitle)
                            .navigationBarTitleDisplayMode(.large)
                            .toolbar(content: {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Menu {
                                        Button(action: {
                                            showingAddCardView = true
                                        }) {
                                            Label("Add Card", systemImage: "plus.rectangle.fill")
                                        }
                                        
                                        Button(action: {
                                            showingAddDeckView = true
                                        }) {
                                            Label("Add Deck", systemImage: "folder.badge.plus")
                                        }
                                        
                                        Button(action: {
                                            showingImageImportView = true
                                        }) {
                                            Label("Import from Image", systemImage: "photo.on.rectangle.angled")
                                        }
                                        
                                        Divider()
                                        
                                        Button(action: {
                                            showingExportImport = true
                                        }) {
                                            Label("Export & Import", systemImage: "square.and.arrow.up.on.square")
                                        }
                                        
                                        Divider()
                                        
                                        Button(action: {
                                            showingResetAlert = true
                                        }) {
                                            Label("Reset Statistics", systemImage: "chart.bar.xaxis")
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                    }
                                }
                            })
                    }
                }
                .background(Color(.systemGroupedBackground))
                
                // Bottom Navigation
                BottomNavigationView(
                    viewModel: viewModel,
                    selectedTab: $selectedTab,
                    onNavigate: handleNavigation
                )
            }
        }
        .preferredColorScheme(settingsManager.getCurrentColorScheme())
        .sheet(isPresented: $showingExportImport) {
            ExportImportView(viewModel: viewModel)
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
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .alert("Reset Learning Statistics", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                viewModel.resetLearningStatistics()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset all learning progress and percentages for all cards. This action cannot be undone.")
        }
        .onAppear {
            // Reset navigation state when returning to home
            viewModel.resetNavigationToRoot()
            // Explicitly reset all modal states
            showingAddCardView = false
            showingAddDeckView = false
            showingImageImportView = false
            showingExportImport = false
            showingResetAlert = false
            showingSettings = false
            // Reset to home tab
            selectedTab = .home
        }
        .onChange(of: viewModel.shouldNavigateToRoot) { newValue in
            if newValue {
                // Navigation to root is handled by dismissing all presented views
                // The state will be reset when we return to HomeView
                selectedTab = .home
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
            // Reset any navigation state when dismiss to root is requested
            viewModel.resetNavigationToRoot()
            selectedTab = .home
        }
    }
    
    private var navigationTitle: String {
        switch selectedTab {
        case .home:
            return "FlashCards"
        case .cards:
            return "Your Cards"
        case .games:
            return "More Games"
        case .settings:
            return "Settings"
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            switch selectedTab {
            case .home:
                homeContent
            case .cards:
                cardsContent
            case .games:
                gamesContent
            case .settings:
                settingsContent
            }
        }
    }
    
    private var homeContent: some View {
        VStack(spacing: 24) {
            // Streak Display at the top
            HStack {
                Spacer()
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.title2)
                            .foregroundColor(streakManager.currentStreak > 0 ? .orange : .gray)
                        
                        Text("\(streakManager.currentStreak)")
                            .font(.title2)
                            .bold()
                            .foregroundColor(streakManager.currentStreak > 0 ? .orange : .gray)
                    }
                    
                    Text(streakManager.currentStreak == 1 ? "day streak" : "days streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                )
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            // Game Modes Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Study Modes")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    // Main study modes
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .study)) {
                        MenuButton(title: "Study Your Cards", icon: "book.fill")
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .test)) {
                        MenuButton(title: "Test Your Cards", icon: "checkmark.circle.fill")
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .truefalse)) {
                        MenuButton(title: "True or False", icon: "questionmark.circle.fill")
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .writing)) {
                        MenuButton(title: "Write Your Card", icon: "pencil.and.scribble")
                    }
                    
                    // More Games section
                    Button(action: {
                        selectedTab = .games
                    }) {
                        MenuButton(title: "More Games", icon: "brain.fill")
                    }
                }
            }
            .padding(.top)
            
            // Card Management Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Manage Cards")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    Button(action: {
                        showingImageImportView = true
                    }) {
                        MenuButton(title: "Import from Image", icon: "photo.on.rectangle.angled")
                    }
                    
                    Button(action: {
                        selectedTab = .cards
                    }) {
                        MenuButton(title: "View Your Cards", icon: "folder.fill")
                    }
                }
            }
        }
        .padding(.horizontal)
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
                        MenuButton(title: "Add Your First Card", icon: "plus.rectangle.fill")
                    }
                    
                    Button(action: {
                        showingAddDeckView = true
                    }) {
                        MenuButton(title: "Create Your First Deck", icon: "folder.badge.plus")
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
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Navigate to manage cards
                VStack(spacing: 12) {
                    NavigationLink(destination: ManageDecksView(viewModel: viewModel)) {
                        MenuButton(title: "Manage Your Decks", icon: "folder.fill")
                    }
                    
                    Button(action: {
                        showingAddCardView = true
                    }) {
                        MenuButton(title: "Add New Card", icon: "plus.rectangle.fill")
                    }
                    
                    Button(action: {
                        showingAddDeckView = true
                    }) {
                        MenuButton(title: "Create New Deck", icon: "folder.badge.plus")
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
    
    private var gamesContent: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Additional Games")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .game)) {
                        MenuButton(title: "Remember Your Cards", icon: "brain.fill")
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .hangman)) {
                        MenuButton(title: "Hangman", icon: "person.fill")
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .dehet)) {
                        MenuButton(title: "de of het", icon: "questionmark.diamond.fill")
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .wordScramble)) {
                        MenuButton(title: "Jumble Your Cards", icon: "textformat.abc")
                    }
                }
            }
            .padding(.top)
        }
        .padding(.horizontal)
    }
    
    private var settingsContent: some View {
        VStack(spacing: 20) {
            // Settings placeholder - will show settings sheet
            VStack(spacing: 16) {
                Image(systemName: "gearshape.circle")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                
                Text("Settings")
                    .font(.title2)
                    .bold()
                
                Text("Tap the button below to open settings.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    showingSettings = true
                }) {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.top, 60)
            
            Spacer()
        }
    }
    
    private func handleNavigation(_ tab: BottomNavigationView.TabItem) {
        // Handle any special navigation logic here
        if tab == .settings {
            showingSettings = true
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.blue)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}

struct MoreGamesView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Additional Games")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .game)) {
                            MenuButton(title: "Remember Your Cards", icon: "brain.fill")
                        }
                        
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .hangman)) {
                            MenuButton(title: "Hangman", icon: "person.fill")
                        }
                        
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .dehet)) {
                            MenuButton(title: "de of het", icon: "questionmark.diamond.fill")
                        }
                    }
                }
                .padding(.top)
            }
            .padding(.horizontal)
        }
        .navigationTitle("More Games")
        .navigationBarTitleDisplayMode(.inline)
    }
} 