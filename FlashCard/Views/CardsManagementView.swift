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
                HStack(spacing: 8) {
                    Text("\(viewModel.flashCards.count)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.blue)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cards")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                // Total Decks
                HStack(spacing: 8) {
                    Text("\(viewModel.decks.count)")
                        .font(.title)
                        .bold()
                        .foregroundColor(.green)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Decks")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        Text("Total")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Action Buttons
            VStack(spacing: 20) {
                // Add Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Add")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        // Add New Card
                        Button(action: {
                            navigationCoordinator.presentSheet(.addCard())
                        }) {
                            HStack {
                                Image(systemName: "plus.rectangle")
                                    .font(.title2)
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                Text("Add New Card")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
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
                                    .frame(width: 30)
                                Text("Add New Deck")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .purple.opacity(0.2), radius: 3, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // View Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("View")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        // View All Cards
                        Button(action: {
                            navigationCoordinator.push(NavigationDestination.allCards)
                        }) {
                            HStack {
                                Image(systemName: "rectangle.stack")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 30)
                                Text("View All Cards")
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
                        
                        // View All Decks
                        Button(action: {
                            navigationCoordinator.push(NavigationDestination.manageDecks)
                        }) {
                            HStack {
                                Image(systemName: "folder")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .frame(width: 30)
                                Text("View All Decks")
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
                
                // Import Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Import")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        // Import From Image
                        Button(action: {
                            navigationCoordinator.push(NavigationDestination.imageImport)
                        }) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                Text("Import From Image")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .red.opacity(0.2), radius: 3, x: 0, y: 1)
                        }
                        
                        // Dutch Vocabulary Import
                        Button(action: {
                            navigationCoordinator.push(NavigationDestination.dutchVocabulary)
                        }) {
                            HStack {
                                Image(systemName: "textformat.abc")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                    .frame(width: 30)
                                Text("Dutch Vocabulary Import")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                            .shadow(color: .purple.opacity(0.2), radius: 3, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 20)
    }
} 