import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var deckName = ""
    @State private var selectedParentId: UUID? = nil
    
    var availableParentDecks: [Deck] {
        return viewModel.getTopLevelDecks().filter { $0.name != "Uncategorized" }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Create Deck")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                Button("Create") {
                    let trimmedName = deckName.trimmingCharacters(in: .whitespacesAndNewlines)
                    if let parentId = selectedParentId {
                        _ = viewModel.createSubDeck(name: trimmedName, parentId: parentId)
                    } else {
                        _ = viewModel.createDeck(name: trimmedName)
                    }
                    dismiss()
                }
                .disabled(deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .foregroundColor(deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                .fontWeight(.semibold)
            }
            .padding()
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .opacity(0.2),
                alignment: .bottom
            )
            
            // Main content
            Form {
                Section(header: Text("New Deck")) {
                    TextField("Deck Name", text: $deckName)
                    
                    if !availableParentDecks.isEmpty {
                        Picker("Location", selection: $selectedParentId) {
                            Text("Top Level (Main Deck)").tag(nil as UUID?)
                            ForEach(availableParentDecks) { deck in
                                Text("Under \(deck.name)").tag(deck.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section {
                    if selectedParentId == nil {
                        Text("This will create a main deck that can contain sub-decks.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("This will create a sub-deck for more specific organization.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
} 