import SwiftUI

struct MoreGamesView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Additional Games Section
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
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle("More Games")
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
            }
        }
    }
} 