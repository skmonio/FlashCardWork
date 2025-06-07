import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var deckName = ""
    @State private var selectedParentId: UUID? = nil
    @State private var createAsSubDeck = false
    
    var availableParentDecks: [Deck] {
        return viewModel.getTopLevelDecks().filter { $0.name != "Uncategorized" }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Deck")) {
                    TextField("Deck Name", text: $deckName)
                    
                    Toggle("Create as Sub-Deck", isOn: $createAsSubDeck)
                    
                    if createAsSubDeck && !availableParentDecks.isEmpty {
                        Picker("Parent Deck", selection: $selectedParentId) {
                            Text("Select Parent Deck").tag(nil as UUID?)
                            ForEach(availableParentDecks) { deck in
                                Text(deck.name).tag(deck.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    } else if createAsSubDeck && availableParentDecks.isEmpty {
                        Text("No parent decks available")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                if createAsSubDeck {
                    Section {
                        Text("Sub-decks help organize your cards into more specific categories under a main deck.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Create Deck")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    let trimmedName = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if createAsSubDeck, let parentId = selectedParentId {
                        _ = viewModel.createSubDeck(name: trimmedName, parentId: parentId)
                    } else {
                        _ = viewModel.createDeck(name: trimmedName)
                    }
                    dismiss()
                }
                .disabled(deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || 
                         (createAsSubDeck && selectedParentId == nil && !availableParentDecks.isEmpty))
            )
        }
    }
} 