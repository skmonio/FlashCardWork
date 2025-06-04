import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    
    @State private var word: String = ""
    @State private var definition: String = ""
    @State private var example: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Word")) {
                    TextField("Enter word", text: $word)
                }
                
                Section(header: Text("Definition")) {
                    TextField("Enter definition", text: $definition)
                        .frame(height: 100)
                }
                
                Section(header: Text("Example")) {
                    TextField("Enter example", text: $example)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add New Card")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Save") {
                    viewModel.addCard(word: word, definition: definition, example: example)
                    dismiss()
                }
                .disabled(word.isEmpty || definition.isEmpty)
            )
        }
    }
} 