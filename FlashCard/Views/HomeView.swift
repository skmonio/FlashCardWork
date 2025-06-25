import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @ObservedObject var streakManager: StreakManager
    @State private var selectedTab: BottomNavigationView.TabItem = .home
    
    // Cards page state variables
    @State private var showingAddCardView = false
    @State private var showingAddDeckView = false
    @State private var showingImageImportView = false
    @State private var showingCardsInfoView = false
    
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
                        // Streak in top left
                        ToolbarItem(placement: .navigationBarLeading) {
                        if selectedTab == .home {
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
                        
                        // Custom title layout for all pages
                        ToolbarItem(placement: .principal) {
                            Text("Taal Trek")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        // What is Taal Trek button in top right
                        ToolbarItem(placement: .navigationBarTrailing) {
                            if selectedTab == .cards {
                                Button("How to Add Cards") {
                                    showingCardsInfoView = true
                                }
                                .font(.caption)
                                .foregroundColor(.blue)
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
        .sheet(isPresented: $showingCardsInfoView) {
            CardsInfoView()
        }
        .onAppear {
            // Reset navigation state when returning to home
            viewModel.resetNavigationToRoot()
            // Reset to home tab
            selectedTab = .home
            
            // Show welcome popup on first launch
            if isFirstLaunch() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    // Show WelcomeView from SettingsView now, or keep this for first launch only
                    markFirstLaunchComplete()
                }
            }
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
                    NavigationLink(destination: SimplifiedDeckSelectionView(viewModel: viewModel, mode: .study)) {
                        MenuButton(title: "Study Your Cards", icon: "book.fill", color: .teal)
                    }
                    
                    NavigationLink(destination: SimplifiedDeckSelectionView(viewModel: viewModel, mode: .test)) {
                        MenuButton(title: "Test Your Cards", icon: "checkmark.circle.fill", color: .orange)
                    }
                    
                    NavigationLink(destination: SimplifiedDeckSelectionView(viewModel: viewModel, mode: .truefalse)) {
                        MenuButton(title: "True or False", icon: "questionmark.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.3))
                    }
                    
                    NavigationLink(destination: SimplifiedDeckSelectionView(viewModel: viewModel, mode: .writing)) {
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
                    NavigationLink(destination: SimplifiedDeckSelectionView(viewModel: viewModel, mode: .game)) {
                        MenuButton(title: "Remember Your Cards", icon: "brain.fill", color: .orange)
                    }
                    
                    NavigationLink(destination: SimplifiedDeckSelectionView(viewModel: viewModel, mode: .wordScramble)) {
                        MenuButton(title: "Jumble Your Cards", icon: "textformat.abc", color: Color(red: 1.0, green: 0.4, blue: 0.3))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var cardsContent: some View {
        CardsManagementView(
            viewModel: viewModel,
            showingAddCardView: $showingAddCardView,
            showingAddDeckView: $showingAddDeckView,
            showingImageImportView: $showingImageImportView
        )
            }
    
    private func handleNavigation(_ tab: BottomNavigationView.TabItem) {
        selectedTab = tab
        
        // Check for first-time visit to Cards tab
        if tab == .cards && isFirstVisitCards() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showingCardsInfoView = true
                markCardsAsVisited()
            }
        }
                }
                
    // MARK: - Cards Info Helpers
    private func isFirstVisitCards() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasVisited_cards")
                    }
    
    private func markCardsAsVisited() {
        UserDefaults.standard.set(true, forKey: "hasVisited_cards")
                }
                
    // MARK: - First Launch Helpers
    private func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasLaunched")
    }
    
    private func markFirstLaunchComplete() {
        UserDefaults.standard.set(true, forKey: "hasLaunched")
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

struct CardsInfoView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(edges: .top)
                
                VStack(spacing: 12) {
                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal)
                    
                    // Hero section
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "rectangle.stack.fill")
                                .font(.system(size: 35))
                                .foregroundColor(.white)
                        }
                        
                        Text("Cards & Decks Guide")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Everything you need to know about managing your flashcards")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.bottom, 20)
            }
            .frame(height: 200)
            
            ScrollView {
                VStack(spacing: 20) {
                    // What are Cards?
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "rectangle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            Text("What are Cards?")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("Flashcards contain a word, definition, and example. Each card shows:")
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            CardInfoRow(icon: "textformat", title: "Word/Phrase", description: "The main term you're learning")
                            CardInfoRow(icon: "text.alignleft", title: "Definition", description: "Meaning or translation")
                            CardInfoRow(icon: "quote.bubble", title: "Example", description: "Usage in context (optional)")
                            CardInfoRow(icon: "percent", title: "Learning Progress", description: "How well you know this card")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // What are Decks?
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("What are Decks?")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("Decks organize your cards by topic, subject, or category. You can:")
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            CardInfoRow(icon: "folder.badge.plus", title: "Create Custom Decks", description: "Organize cards by topic")
                            CardInfoRow(icon: "folder", title: "Move Cards", description: "Between different decks")
                            CardInfoRow(icon: "rectangle.stack", title: "Nested Organization", description: "Create sub-decks within decks")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // System Decks
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.orange)
                                .font(.title2)
                            Text("Protected System Decks")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("These special decks are managed automatically and cannot be deleted:")
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            SystemDeckRow(name: "Learning", icon: "brain", color: .blue, description: "Cards you're currently practicing")
                            SystemDeckRow(name: "Learnt", icon: "checkmark.circle", color: .green, description: "Cards you've mastered")
                            SystemDeckRow(name: "Review", icon: "arrow.clockwise", color: .orange, description: "Cards marked for review")
                            SystemDeckRow(name: "Uncategorized", icon: "tray", color: .gray, description: "Cards not assigned to any deck")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Card Management
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.purple)
                                .font(.title2)
                            Text("Card Management")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("Powerful tools to organize and manage your cards:")
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            CardInfoRow(icon: "magnifyingglass", title: "Search", description: "Find cards by word, definition, or example")
                            CardInfoRow(icon: "arrow.up.arrow.down", title: "Sort Options", description: "By word, definition, date, or practice count")
                            CardInfoRow(icon: "checkmark.circle", title: "Bulk Actions", description: "Select multiple cards to move or delete")
                            CardInfoRow(icon: "arrow.left.arrow.right", title: "Swipe Actions", description: "Swipe cards for quick edit/delete")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Advanced Features
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.pink)
                                .font(.title2)
                            Text("Advanced Features")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("Powerful tools to enhance your learning:")
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            CardInfoRow(icon: "speaker.wave.2", title: "Pronunciation", description: "Tap cards to hear pronunciation")
                            CardInfoRow(icon: "translate", title: "Translation", description: "Built-in translation tools")
                            CardInfoRow(icon: "camera.viewfinder", title: "Import from Image", description: "Extract text from photos")
                            CardInfoRow(icon: "square.and.arrow.up", title: "Export/Import", description: "Share decks with others")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    
                    // Quick Tips
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            Text("Quick Tips")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        VStack(spacing: 8) {
                            TipRow(text: "Create focused decks for specific topics or subjects")
                            TipRow(text: "Use examples to provide context for better learning")
                            TipRow(text: "Regularly review cards in the Review deck")
                            TipRow(text: "Import vocabulary from images using the camera feature")
                            TipRow(text: "Practice cards in different study modes for better retention")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .padding()
            }
        }
    }
}

struct CardInfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct SystemDeckRow: View {
    let name: String
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct TipRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.caption)
                .padding(.top, 2)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
} 