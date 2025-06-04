import SwiftUI

struct AddDeckView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var deckName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("New Deck")) {
                    TextField("Deck Name", text: $deckName)
                }
            }
            .navigationTitle("Create Deck")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Create") {
                    _ = viewModel.createDeck(name: deckName.trimmingCharacters(in: .whitespacesAndNewlines))
                    dismiss()
                }
                .disabled(deckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
} 