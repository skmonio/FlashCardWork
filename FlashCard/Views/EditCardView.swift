import SwiftUI
import os

struct EditCardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let cardId: UUID
    
    @State private var word: String = ""
    @State private var definition: String = ""
    @State private var example: String = ""
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingNewDeckSheet = false
    @State private var newDeckName = ""
    
    private let logger = Logger(subsystem: "com.flashcards", category: "EditCardView")
    
    init(viewModel: FlashCardViewModel, card: FlashCard) {
        logger.debug("Initializing EditCardView for card: \(card.id)")
        self.viewModel = viewModel
        self.cardId = card.id
        _word = State(initialValue: card.word)
        _definition = State(initialValue: card.definition)
        _example = State(initialValue: card.example)
        _selectedDeckIds = State(initialValue: card.deckIds)
    }
    
    private var card: FlashCard? {
        let foundCard = viewModel.flashCards.first(where: { $0.id == cardId })
        logger.debug("Retrieved card from viewModel: \(foundCard != nil)")
        return foundCard
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Card Details")) {
                    TextField("Word", text: $word)
                        .onChange(of: word) { oldValue, newValue in
                            logger.debug("Word changed from '\(oldValue)' to '\(newValue)'")
                        }
                    
                    TextField("Definition", text: $definition)
                        .onChange(of: definition) { oldValue, newValue in
                            logger.debug("Definition changed from '\(oldValue)' to '\(newValue)'")
                        }
                    
                    TextField("Example (Optional)", text: $example)
                        .onChange(of: example) { oldValue, newValue in
                            logger.debug("Example changed from '\(oldValue)' to '\(newValue)'")
                        }
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
            .navigationTitle("Edit Card")
            .navigationBarItems(
                leading: Button("Cancel") {
                    logger.debug("Cancel button tapped")
                    dismiss()
                },
                trailing: Button("Save") {
                    logger.debug("Save button tapped")
                    guard let currentCard = card else {
                        logger.error("Failed to find card with ID: \(cardId)")
                        return
                    }
                    
                    let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    logger.debug("Updating card with values - Word: \(trimmedWord), Definition: \(trimmedDefinition)")
                    
                    // Update the card
                    viewModel.updateCard(
                        currentCard,
                        word: trimmedWord,
                        definition: trimmedDefinition,
                        example: trimmedExample,
                        deckIds: selectedDeckIds
                    )
                    
                    // Force a save to UserDefaults
                    UserDefaults.standard.synchronize()
                    logger.debug("UserDefaults synchronized")
                    
                    // Dismiss the view
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
        }
        .onAppear {
            logger.debug("EditCardView appeared")
        }
        .onDisappear {
            logger.debug("EditCardView disappeared")
        }
    }
} 