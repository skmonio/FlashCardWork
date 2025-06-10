import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var showingExportImport = false
    
    // Navigation state for full-screen forms
    @State private var showingAddCardView = false
    @State private var showingAddDeckView = false
    
    var body: some View {
        NavigationView {
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
                    // Show main content
                    mainContent
                        .navigationTitle("FlashCards")
                        .toolbar {
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
                                        showingExportImport = true
                                    }) {
                                        Label("Export & Import", systemImage: "square.and.arrow.up.on.square")
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                }
                            }
                        }
                }
            }
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingExportImport) {
            ExportImportView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddCardView) {
            AddCardView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddDeckView) {
            AddDeckView(viewModel: viewModel)
        }
        .onAppear {
            // Reset navigation state when returning to home
            viewModel.resetNavigationToRoot()
            // Explicitly reset all modal states
            showingAddCardView = false
            showingAddDeckView = false
            showingExportImport = false
        }
        .onChange(of: viewModel.shouldNavigateToRoot) { oldValue, newValue in
            if newValue {
                // Navigation to root is handled by dismissing all presented views
                // The state will be reset when we return to HomeView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissToRoot"))) { _ in
            // Reset any navigation state when dismiss to root is requested
            viewModel.resetNavigationToRoot()
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Game Modes Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Study Modes")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .study)) {
                            MenuButton(title: "Study Your Cards", icon: "book.fill")
                        }
                        
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .test)) {
                            MenuButton(title: "Test Your Cards", icon: "checkmark.circle.fill")
                        }
                        
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .truefalse)) {
                            MenuButton(title: "True or False", icon: "questionmark.circle.fill")
                        }
                        
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .lookcovercheck)) {
                            MenuButton(title: "Look Cover Check", icon: "eye.slash.fill")
                        }
                        
                        NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .writing)) {
                            MenuButton(title: "Write Your Card", icon: "pencil.and.scribble")
                        }
                        
                        NavigationLink(destination: MoreGamesView(viewModel: viewModel)) {
                            MenuButton(title: "More Games", icon: "gamecontroller.fill")
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
                    
                    NavigationLink(destination: ManageDecksView(viewModel: viewModel)) {
                        MenuButton(title: "View Your Cards", icon: "folder.fill")
                    }
                }
            }
            .padding(.horizontal)
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