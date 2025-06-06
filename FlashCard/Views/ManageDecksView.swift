import SwiftUI
import os

struct ManageDecksView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    private let logger = Logger(subsystem: "com.flashcards", category: "ManageDecksView")
    @State private var showingAddDeck = false
    @State private var showingAddCard = false
    
    var body: some View {
        VStack {
            List {
                Section {
                    Button(action: {
                        showingAddCard = true
                    }) {
                        HStack {
                            Image(systemName: "plus.card.fill")
                            Text("Add New Card")
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Button(action: {
                        showingAddDeck = true
                    }) {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("Add New Deck")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section {
                    ForEach(viewModel.decks) { deck in
                        NavigationLink {
                            DeckView(viewModel: viewModel, deck: deck)
                        } label: {
                            HStack {
                                Text(deck.name)
                                Spacer()
                                Text("\(deck.cards.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            let deck = viewModel.decks[index]
                            if deck.name != "Uncategorized" {
                                viewModel.deleteDeck(deck)
                            }
                        }
                    }
                }
            }
            .navigationTitle("View Your Cards")
            .navigationBarBackButtonHidden(true)
            
            Spacer()
            
            // Bottom Navigation Bar
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    VStack {
                        Image(systemName: "chevron.backward")
                        Text("Back")
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    dismiss()
                }) {
                    VStack {
                        Image(systemName: "house")
                        Text("Home")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .opacity(0.2),
                alignment: .top
            )
        }
        .sheet(isPresented: $showingAddDeck) {
            AddDeckView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAddCard) {
            AddCardView(viewModel: viewModel)
        }
    }
} 