import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FlashCardViewModel()
    @State private var showingAddCard = false
    @State private var showingRPG = false
    
    var body: some View {
        NavigationView {
            List {
                // RPG Button Section
                Section {
                    Button(action: { showingRPG = true }) {
                        HStack {
                            Image(systemName: "crossed.swords")
                                .foregroundColor(.red)
                                .font(.title2)
                            Text("Play RPG Battle Mode")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .disabled(viewModel.flashCards.isEmpty)
                } header: {
                    Text("Game Modes")
                }
                
                // Flash Cards Section
                Section {
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
                } header: {
                    Text("Flash Cards")
                }
            }
            .navigationTitle("Flash Cards")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        NavigationLink(destination: GameView(viewModel: viewModel)) {
                            Image(systemName: "gamecontroller.fill")
                        }
                        .disabled(viewModel.flashCards.isEmpty)
                        
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
            .sheet(isPresented: $showingRPG) {
                NavigationView {
                    RPGView(viewModel: viewModel)
                }
            }
        }
    }
} 
