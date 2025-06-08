import SwiftUI
import os

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let defaultDeck: Deck?
    
    @State private var word: String = ""
    @State private var definition: String = ""
    @State private var example: String = ""
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingNewDeckSheet = false
    @State private var newDeckName: String = ""
    
    // Dutch language features
    @State private var isDeSelected: Bool = false
    @State private var isHetSelected: Bool = false
    @State private var pastTense: String = ""
    @State private var futureTense: String = ""
    
    // Audio recording
    @State private var temporaryCardId: UUID = UUID()
    
    private let logger = Logger(subsystem: "com.flashcards", category: "AddCardView")
    
    private var canSave: Bool {
        !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(viewModel: FlashCardViewModel, defaultDeck: Deck? = nil) {
        self.viewModel = viewModel
        self.defaultDeck = defaultDeck
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            HStack {
                Button("Cancel") {
                    logger.debug("Cancel button tapped")
                    // Clean up any temporary audio recording
                    AudioManager.shared.deleteAudio(for: temporaryCardId)
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Add Card")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button("Save & Add Another") {
                        logger.debug("Save & Add Another button tapped")
                        saveCurrentCard()
                        resetForm()
                    }
                    .disabled(!canSave)
                    .foregroundColor(canSave ? .blue : .gray)
                    
                    Button("Save") {
                        logger.debug("Save button tapped")
                        saveCurrentCard()
                        dismiss()
                    }
                    .disabled(!canSave)
                    .foregroundColor(canSave ? .blue : .gray)
                    .fontWeight(.semibold)
                }
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
                
                Section(header: Text("Pronunciation (Optional)")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Record pronunciation for this word")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        AudioControlView(cardId: temporaryCardId, mode: .full)
                    }
                }
                
                Section(header: Text("Dutch Language Features (Optional)")) {
                    // Article selection
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Article")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            // De checkbox
                            Button(action: {
                                if isDeSelected {
                                    isDeSelected = false // Uncheck if already selected
                                } else {
                                    isDeSelected = true
                                    isHetSelected = false // Uncheck het if de is selected
                                }
                            }) {
                                HStack {
                                    Image(systemName: isDeSelected ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isDeSelected ? .blue : .gray)
                                    Text("de")
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Het checkbox
                            Button(action: {
                                if isHetSelected {
                                    isHetSelected = false // Uncheck if already selected
                                } else {
                                    isHetSelected = true
                                    isDeSelected = false // Uncheck de if het is selected
                                }
                            }) {
                                HStack {
                                    Image(systemName: isHetSelected ? "checkmark.square.fill" : "square")
                                        .foregroundColor(isHetSelected ? .blue : .gray)
                                    Text("het")
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                    }
                    
                    // Tense fields
                    TextField("Past Tense (Optional)", text: $pastTense)
                    TextField("Future Tense (Optional)", text: $futureTense)
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
                                // Show indentation for sub-decks
                                if deck.isSubDeck {
                                    HStack(spacing: 4) {
                                        Text("    ↳")
                                            .foregroundColor(.secondary)
                                        Text(deck.name)
                                    }
                                } else {
                                    Text(deck.name)
                                }
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
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingNewDeckSheet) {
            VStack(spacing: 0) {
                // Custom navigation bar for sheet
                HStack {
                    Button("Cancel") {
                        showingNewDeckSheet = false
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("Create Deck")
                        .font(.headline)
                        .bold()
                    
                    Spacer()
                    
                    Button("Create") {
                        logger.debug("Creating new deck: \(newDeckName)")
                        let newDeck = viewModel.createDeck(name: newDeckName.trimmingCharacters(in: .whitespacesAndNewlines))
                        selectedDeckIds.insert(newDeck.id)
                        showingNewDeckSheet = false
                        newDeckName = ""
                    }
                    .disabled(newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .foregroundColor(newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
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
                
                Form {
                    Section(header: Text("New Deck")) {
                        TextField("Deck Name", text: $newDeckName)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            logger.debug("AddCardView appeared")
            
            // Auto-select the default deck if provided
            if let defaultDeck = defaultDeck {
                selectedDeckIds.insert(defaultDeck.id)
                logger.debug("Auto-selected default deck: \(defaultDeck.name)")
            }
        }
        .onDisappear {
            logger.debug("AddCardView disappeared")
            // Stop any ongoing recording when view disappears
            AudioManager.shared.stopRecording()
            AudioManager.shared.stopPlayback()
        }
    }
    
    private func saveCurrentCard() {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastTense = pastTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFutureTense = futureTense.trimmingCharacters(in: .whitespacesAndNewlines)
        
        logger.debug("Adding card - Word: \(trimmedWord), Definition: \(trimmedDefinition)")
        
        // Create the card with the temporary ID so audio gets associated correctly
        let newCard = viewModel.addCard(
            word: trimmedWord,
            definition: trimmedDefinition,
            example: trimmedExample,
            deckIds: selectedDeckIds,
            article: isDeSelected ? "de" : (isHetSelected ? "het" : nil),
            pastTense: trimmedPastTense.isEmpty ? nil : trimmedPastTense,
            futureTense: trimmedFutureTense.isEmpty ? nil : trimmedFutureTense,
            cardId: temporaryCardId // Pass the temporary ID so audio gets linked
        )
        
        // Force a save to UserDefaults
        UserDefaults.standard.synchronize()
        logger.debug("UserDefaults synchronized")
    }
    
    private func resetForm() {
        word = ""
        definition = ""
        example = ""
        // Keep selectedDeckIds so user doesn't have to reselect decks
        isDeSelected = false
        isHetSelected = false
        pastTense = ""
        futureTense = ""
        
        // Generate new temporary ID for next card
        temporaryCardId = UUID()
    }
} 