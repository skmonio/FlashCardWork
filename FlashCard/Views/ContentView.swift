import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlashCardViewModel()
    @State private var showingAddCard = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.flashCards) { card in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(card.word)
                            .font(.headline)
                        Text(card.definition)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if !card.example.isEmpty {
                            Text("Example: \(card.example)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onDelete(perform: viewModel.deleteCard)
            }
            .navigationTitle("Flash Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: TestView(viewModel: viewModel)) {
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .disabled(viewModel.flashCards.isEmpty)
                        
                        NavigationLink(destination: StudyView(viewModel: viewModel)) {
                            Image(systemName: "book.fill")
                        }
                        .disabled(viewModel.flashCards.isEmpty)
                        
                        Button(action: {
                            showingAddCard = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddCard) {
                AddCardView(viewModel: viewModel)
            }
        }
    }
} 
