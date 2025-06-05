import SwiftUI
import os

struct AddMultipleCardsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var cardEntries: [CardEntry] = [CardEntry()]
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingNewDeckSheet = false
    @State private var newDeckName = ""
    
    private let logger = Logger(subsystem: "com.flashcards", category: "AddMultipleCardsView")
    
    private var canSave: Bool {
        !cardEntries.isEmpty && cardEntries.allSatisfy { entry in
            !entry.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !entry.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private var canAddAnotherCard: Bool {
        guard let lastEntry = cardEntries.last else { return true }
        return !lastEntry.word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !lastEntry.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        Form {
            ForEach($cardEntries.indices, id: \.self) { index in
                Section(header: Text(cardEntries.count > 1 ? "Card \(index + 1)" : "Card Details")) {
                    TextField("Word", text: $cardEntries[index].word)
                        .onChange(of: cardEntries[index].word) { _, newValue in
                            logger.debug("Word changed for card \(index): \(newValue)")
                        }
                    
                    TextField("Definition", text: $cardEntries[index].definition)
                        .onChange(of: cardEntries[index].definition) { _, newValue in
                            logger.debug("Definition changed for card \(index): \(newValue)")
                        }
                    
                    TextField("Example (Optional)", text: $cardEntries[index].example)
                        .onChange(of: cardEntries[index].example) { _, newValue in
                            logger.debug("Example changed for card \(index): \(newValue)")
                        }
                    
                    if cardEntries.count > 1 {
                        Button(role: .destructive, action: {
                            logger.debug("Removing card at index \(index)")
                            cardEntries.remove(at: index)
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove Card")
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            
            Section {
                Button(action: {
                    logger.debug("Adding new card entry")
                    cardEntries.append(CardEntry())
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Another Card")
                    }
                    .foregroundColor(.blue)
                }
                .disabled(!canAddAnotherCard)
            }

            Section(header: Text("Decks (Select one or more)")) {
                ForEach(viewModel.getSelectableDecks()) { deck in
                    Button(action: {
                        if selectedDeckIds.contains(deck.id) {
                            selectedDeckIds.remove(deck.id)
                        } else {
                            selectedDeckIds.insert(deck.id)
                        }
                        logger.debug("Selected deck IDs changed: \(selectedDeckIds)")
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
        .navigationTitle("Add Multiple Cards")
        .navigationBarItems(
            leading: Button("Cancel") {
                logger.debug("Cancel button tapped")
                dismiss()
            },
            trailing: Button("Save") {
                logger.debug("Save button tapped with \(cardEntries.count) cards")
                
                for entry in cardEntries {
                    let trimmedWord = entry.word.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedDefinition = entry.definition.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedExample = entry.example.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    logger.debug("Adding card - Word: \(trimmedWord), Definition: \(trimmedDefinition)")
                    
                    viewModel.addCard(
                        word: trimmedWord,
                        definition: trimmedDefinition,
                        example: trimmedExample,
                        deckIds: selectedDeckIds
                    )
                }
                
                // Force a save to UserDefaults
                UserDefaults.standard.synchronize()
                logger.debug("UserDefaults synchronized")
                
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
                        logger.debug("Creating new deck: \(newDeckName)")
                        let newDeck = viewModel.createDeck(name: newDeckName.trimmingCharacters(in: .whitespacesAndNewlines))
                        selectedDeckIds.insert(newDeck.id)
                        showingNewDeckSheet = false
                        newDeckName = ""
                    }
                    .disabled(newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                )
            }
        }
        .onAppear {
            logger.debug("AddMultipleCardsView appeared")
        }
        .onDisappear {
            logger.debug("AddMultipleCardsView disappeared")
        }
    }
} 