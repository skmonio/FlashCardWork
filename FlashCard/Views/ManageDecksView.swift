import SwiftUI
import os

struct ManageDecksView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    private let logger = Logger(subsystem: "com.flashcards", category: "ManageDecksView")
    @State private var showingAddDeck = false
    @State private var showingAddCard = false
    @State private var showingAddMultipleCards = false
    
    // Multi-select states for decks
    @State private var isSelectionMode = false
    @State private var selectedDecks: Set<UUID> = []
    @State private var showingMoveDecksSheet = false
    @State private var showingBulkDeleteAlert = false
    
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
                        showingAddMultipleCards = true
                    }) {
                        HStack {
                            Image(systemName: "plus.rectangle.stack.fill")
                            Text("Add Multiple Cards")
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
                    ForEach(viewModel.getAllDecksHierarchical()) { deck in
                        HStack {
                            if isSelectionMode {
                                Button(action: {
                                    if selectedDecks.contains(deck.id) {
                                        selectedDecks.remove(deck.id)
                                    } else {
                                        selectedDecks.insert(deck.id)
                                    }
                                    HapticManager.shared.multiSelectToggle()
                                }) {
                                    Image(systemName: selectedDecks.contains(deck.id) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(selectedDecks.contains(deck.id) ? .blue : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            NavigationLink {
                                DeckView(viewModel: viewModel, deck: deck)
                            } label: {
                                HStack {
                                    // Show indentation for sub-decks
                                    if deck.isSubDeck {
                                        HStack(spacing: 4) {
                                            Text("    ↳")
                                                .foregroundColor(.secondary)
                                            Text(deck.name)
                                        }
                                    } else {
                                        Text(deck.name)
                                    }
                                    Spacer()
                                    Text("\(deck.cards.count)")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .onDelete { indices in
                        let allDecks = viewModel.getAllDecksHierarchical()
                        indices.forEach { index in
                            let deck = allDecks[index]
                            if deck.name != "Uncategorized" {
                                viewModel.deleteDeck(deck)
                            }
                        }
                    }
                }
            }
            .navigationTitle("View Your Cards")
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isSelectionMode {
                        Button("Cancel") {
                            isSelectionMode = false
                            selectedDecks.removeAll()
                        }
                    } else {
                        EmptyView()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !isSelectionMode {
                        Button("Select") {
                            isSelectionMode = true
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            
            Spacer()
            
            // Bottom Navigation Bar
            HStack {
                if isSelectionMode && !selectedDecks.isEmpty {
                    Button(action: {
                        showingBulkDeleteAlert = true
                    }) {
                        VStack {
                            Image(systemName: "trash")
                            Text("Delete (\(selectedDecks.count))")
                        }
                        .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        showingMoveDecksSheet = true
                    }) {
                        VStack {
                            Image(systemName: "folder.badge.gearshape")
                            Text("Move (\(selectedDecks.count))")
                        }
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                } else {
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
        .sheet(isPresented: $showingAddMultipleCards) {
            AddMultipleCardsView(viewModel: viewModel)
        }
        .alert("Delete Decks", isPresented: $showingBulkDeleteAlert) {
            Button("Delete \(selectedDecks.count) decks", role: .destructive) {
                for deckId in selectedDecks {
                    if let deck = viewModel.decks.first(where: { $0.id == deckId && $0.name != "Uncategorized" }) {
                        viewModel.deleteDeck(deck)
                    }
                }
                isSelectionMode = false
                selectedDecks.removeAll()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete \(selectedDecks.count) selected decks? This will also delete all their cards.")
        }
    }
} 