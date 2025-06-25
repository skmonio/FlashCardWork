import SwiftUI

struct CardsManagementView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Binding var showingAddCardView: Bool
    @Binding var showingAddDeckView: Bool
    @Binding var showingImageImportView: Bool
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    
    var body: some View {
        VStack(spacing: 20) {
            // Stats Section
            HStack(spacing: 20) {
                // Total Cards
                VStack {
                    Text("\(viewModel.flashCards.count)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.blue)
                    Text("Total Cards")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Total Decks
                VStack {
                    Text("\(viewModel.decks.count)")
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(.green)
                    Text("Total Decks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Action Buttons
            VStack(spacing: 16) {
                // View All Cards
                Button(action: {
                    navigationCoordinator.push(NavigationDestination.allCards)
                }) {
                    HStack {
                        Image(systemName: "rectangle.stack")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("View All Cards")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .blue.opacity(0.2), radius: 3, x: 0, y: 1)
                }
                
                // View All Decks
                Button(action: {
                    navigationCoordinator.push(NavigationDestination.manageDecks)
                }) {
                    HStack {
                        Image(systemName: "folder.stack")
                            .font(.title2)
                            .foregroundColor(.green)
                        Text("View All Decks")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .green.opacity(0.2), radius: 3, x: 0, y: 1)
                }
                
                // Add New Card
                Button(action: {
                    navigationCoordinator.presentSheet(.addCard())
                }) {
                    HStack {
                        Image(systemName: "plus.rectangle")
                            .font(.title2)
                            .foregroundColor(.orange)
                        Text("Add New Card")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.2), radius: 3, x: 0, y: 1)
                }
                
                // Add New Deck
                Button(action: {
                    navigationCoordinator.presentSheet(.addDeck)
                }) {
                    HStack {
                        Image(systemName: "folder.badge.plus")
                            .font(.title2)
                            .foregroundColor(.purple)
                        Text("Add New Deck")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .purple.opacity(0.2), radius: 3, x: 0, y: 1)
                }
                
                // Import From Image
                Button(action: {
                    navigationCoordinator.presentSheet(.imageImport)
                }) {
                    HStack {
                        Image(systemName: "camera.viewfinder")
                            .font(.title2)
                            .foregroundColor(.red)
                        Text("Import From Image")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .red.opacity(0.2), radius: 3, x: 0, y: 1)
                }
                
                // Dutch Vocabulary Import
                Button(action: {
                    navigationCoordinator.push(NavigationDestination.dutchVocabulary)
                }) {
                    HStack {
                        Image(systemName: "globe.europe.africa.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Dutch Vocabulary")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("A1-B1 Level Packs")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .shadow(color: .orange.opacity(0.2), radius: 3, x: 0, y: 1)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.top)
    }
} 