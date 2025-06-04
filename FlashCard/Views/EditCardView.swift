import SwiftUI

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) private var presentationMode
    @ObservedObject var viewModel: FlashCardViewModel
    let card: FlashCard
    
    @State private var word: String
    @State private var definition: String
    @State private var example: String
    @State private var selectedDeckIds: Set<UUID>
    @State private var showingNewDeckSheet = false
    @State private var newDeckName = ""
    
    init(viewModel: FlashCardViewModel, card: FlashCard) {
        self.viewModel = viewModel
        self.card = card
        _word = State(initialValue: card.word)
        _definition = State(initialValue: card.definition)
        _example = State(initialValue: card.example)
        _selectedDeckIds = State(initialValue: card.deckIds)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Details")) {
                    TextField("Word", text: $word)
                    TextField("Definition", text: $definition)
                    TextField("Example (Optional)", text: $example)
                }

                Section(header: Text("Decks (Select one or more)")) {
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
            }
            .navigationTitle("Edit Card")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    viewModel.updateCard(
                        card,
                        word: word.trimmingCharacters(in: .whitespacesAndNewlines),
                        definition: definition.trimmingCharacters(in: .whitespacesAndNewlines),
                        example: example.trimmingCharacters(in: .whitespacesAndNewlines),
                        deckIds: selectedDeckIds
                    )
                    dismiss()
                }
                .disabled(word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                         definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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