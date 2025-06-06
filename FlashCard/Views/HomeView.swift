import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var showingAddDeck = false
    @State private var showingAddCard = false
    
    var body: some View {
        NavigationView {
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
                            
                            NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .game)) {
                                MenuButton(title: "Remember Your Cards", icon: "brain.fill")
                            }
                            
                            NavigationLink(destination: DeckSelectionView(viewModel: viewModel, mode: .truefalse)) {
                                MenuButton(title: "True or False", icon: "questionmark.circle.fill")
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
            .navigationTitle("FlashCards")
            .background(Color(.systemGroupedBackground))
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