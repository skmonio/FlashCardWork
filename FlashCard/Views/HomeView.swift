import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @ObservedObject var streakManager: StreakManager
    @State private var selectedTab: BottomNavigationView.TabItem = .home
    
    // Cards page state variables
    @State private var showingAddCardView = false
    @State private var showingAddDeckView = false
    @State private var showingImageImportView = false
    
    // Settings manager for theme
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Show main content based on selected tab
                mainContent
                    .navigationTitle("") // Always empty title to use custom toolbar
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar(content: {
                        // Custom title layout for all pages
                        ToolbarItem(placement: .principal) {
                            Text("Taal Trek")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        if selectedTab == .home {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                // Flame icon with day streak
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
                        }
                    })
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
            // Reset navigation state when returning to home
            viewModel.resetNavigationToRoot()
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
    
    private var mainContent: some View {
        switch selectedTab {
        case .home:
            AnyView(ScrollView {
                homeContent
            })
        case .cards:
            AnyView(ScrollView {
                cardsContent
            })
        case .settings:
            AnyView(SettingsView(viewModel: viewModel, isSheet: false))
        }
    }
    
    private var homeContent: some View {
        VStack(spacing: 24) {
            // Study Modes Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Study Modes")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    // Main study modes
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .study)) {
                        MenuButton(title: "Study Your Cards", icon: "book.fill", color: .teal)
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .test)) {
                        MenuButton(title: "Test Your Cards", icon: "checkmark.circle.fill", color: .orange)
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .truefalse)) {
                        MenuButton(title: "True or False", icon: "questionmark.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.3))
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .writing)) {
                        MenuButton(title: "Write Your Card", icon: "pencil.and.scribble", color: Color(red: 1.0, green: 0.6, blue: 0.0))
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
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .game)) {
                        MenuButton(title: "Remember Your Cards", icon: "brain.fill", color: .orange)
                    }
                    
                    NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .wordScramble)) {
                        MenuButton(title: "Jumble Your Cards", icon: "textformat.abc", color: Color(red: 1.0, green: 0.4, blue: 0.3))
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
                    .background(Color(.systemBackground))
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
    
    private func handleNavigation(_ tab: BottomNavigationView.TabItem) {
        selectedTab = tab
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let color: Color
    
    init(title: String, icon: String, color: Color = .blue) {
        self.title = title
        self.icon = icon
        self.color = color
    }
    
    var body: some View {
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