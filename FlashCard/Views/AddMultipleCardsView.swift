import SwiftUI

struct CardEntry: Identifiable {
    let id = UUID()
    var word: String = ""
    var definition: String = ""
    var example: String = ""
}

struct AddMultipleCardsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cardEntries: [CardEntry] = [CardEntry()]
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingNewDeckSheet = false
    @State private var newDeckName = ""
    
    private var canSave: Bool {
        !cardEntries.isEmpty && cardEntries.allSatisfy { entry in
            !entry.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !entry.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Decks")) {
                    ForEach(viewModel.getSelectableDecks()) { deck in
                        Button(action: {
                            if selectedDeckIds.contains(deck.id) {
                                selectedDeckIds.remove(deck.id)
                            } else {
                                selectedDeckIds.insert(deck.id)
                            }
                        }) {
                            HStack {
                                Text(deck.name)
                                Spacer()
                                if selectedDeckIds.contains(deck.id) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        showingNewDeckSheet = true
                    }) {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("Create New Deck")
                        }
                    }
                }
                
                Section(header: Text("Cards")) {
                    ForEach($cardEntries) { $entry in
                        VStack(spacing: 12) {
                            TextField("Word", text: $entry.word)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Definition", text: $entry.definition)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField("Example (Optional)", text: $entry.example)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if cardEntries.count > 1 {
                                Button(role: .destructive, action: {
                                    if let index = cardEntries.firstIndex(where: { $0.id == entry.id }) {
                                        cardEntries.remove(at: index)
                                    }
                                }) {
                                    Text("Remove Card")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            if entry.id == cardEntries.last?.id {
                                Button(action: {
                                    cardEntries.append(CardEntry())
                                }) {
                                    Text("Add Another Card")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if entry.id != cardEntries.last?.id {
                                Divider()
                                    .padding(.vertical, 8)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Add Multiple Cards")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    for entry in cardEntries {
                        viewModel.addCard(
                            word: entry.word.trimmingCharacters(in: .whitespacesAndNewlines),
                            definition: entry.definition.trimmingCharacters(in: .whitespacesAndNewlines),
                            example: entry.example.trimmingCharacters(in: .whitespacesAndNewlines),
                            deckIds: selectedDeckIds
                        )
                    }
                    dismiss()
                }
                .disabled(!canSave)
            )
            .sheet(isPresented: $showingNewDeckSheet) {
                NavigationView {
                    Form {
                        Section(header: Text("New Deck")) {
                            TextField("Deck Name", text: $newDeckName)
                        }
                    }
                    .navigationTitle("Create Deck")
                    .navigationBarItems(
                        leading: Button("Cancel") {
                            showingNewDeckSheet = false
                        },
                        trailing: Button("Create") {
                            let newDeck = viewModel.createDeck(name: newDeckName.trimmingCharacters(in: .whitespacesAndNewlines))
                            selectedDeckIds.insert(newDeck.id)
                            showingNewDeckSheet = false
                            newDeckName = ""
                        }
                        .disabled(newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    )
                }
            }
        }
    }
} 