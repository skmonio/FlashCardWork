import SwiftUI
import os
import Translation

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
    
    // Dutch language features
    @State private var isDeSelected: Bool = false
    @State private var isHetSelected: Bool = false
    @State private var pastTense: String = ""
    @State private var futureTense: String = ""
    
    // Translation features
    @State private var translationConfiguration: TranslationSession.Configuration?
    @State private var suggestedTranslation: String = ""
    @State private var isTranslating: Bool = false
    @State private var showTranslationSuggestion: Bool = false
    @State private var lastTranslatedWord: String = ""
    
    private let logger = Logger(subsystem: "com.flashcards", category: "EditCardView")
    
    init(viewModel: FlashCardViewModel, card: FlashCard) {
        logger.debug("Initializing EditCardView for card: \(card.id)")
        self.viewModel = viewModel
        self.cardId = card.id
        _word = State(initialValue: card.word)
        _definition = State(initialValue: card.definition)
        _example = State(initialValue: card.example)
        _selectedDeckIds = State(initialValue: card.deckIds)
        
        // Initialize Dutch language fields
        _isDeSelected = State(initialValue: card.article == "de")
        _isHetSelected = State(initialValue: card.article == "het")
        _pastTense = State(initialValue: card.pastTense ?? "")
        _futureTense = State(initialValue: card.futureTense ?? "")
    }
    
    private var card: FlashCard? {
        let foundCard = viewModel.flashCards.first(where: { $0.id == cardId })
        logger.debug("Retrieved card from viewModel: \(foundCard != nil)")
        return foundCard
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom navigation bar
            HStack {
                Button("Cancel") {
                    logger.debug("Cancel button tapped")
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Edit Card")
                    .font(.headline)
                    .bold()
                
                Spacer()
                
                Button("Save") {
                    logger.debug("Save button tapped")
                    guard let currentCard = card else {
                        logger.error("Failed to find card with ID: \(cardId)")
                        return
                    }
                    
                    let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedPastTense = pastTense.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedFutureTense = futureTense.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    logger.debug("Updating card with values - Word: \(trimmedWord), Definition: \(trimmedDefinition)")
                    
                    // Update the card
                    viewModel.updateCard(
                        currentCard,
                        word: trimmedWord,
                        definition: trimmedDefinition,
                        example: trimmedExample,
                        deckIds: selectedDeckIds,
                        article: isDeSelected ? "de" : (isHetSelected ? "het" : nil),
                        pastTense: trimmedPastTense.isEmpty ? nil : trimmedPastTense,
                        futureTense: trimmedFutureTense.isEmpty ? nil : trimmedFutureTense
                    )
                    
                    // Force a save to UserDefaults
                    UserDefaults.standard.synchronize()
                    logger.debug("UserDefaults synchronized")
                    
                    dismiss()
                }
                .disabled(word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                         definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .foregroundColor((word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                               definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? .gray : .blue)
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
                Section(header: Text("Card Details")) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Word field with speech controls
                        HStack(spacing: 8) {
                            TextField("Word (Dutch)", text: $word)
                                .onChange(of: word) { oldValue, newValue in
                                    logger.debug("Word changed from '\(oldValue)' to '\(newValue)'")
                                    // Trigger translation suggestion for Dutch words
                                    if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                                       newValue != lastTranslatedWord {
                                        triggerTranslationSuggestion(for: newValue)
                                    } else if newValue.isEmpty {
                                        showTranslationSuggestion = false
                                        suggestedTranslation = ""
                                    }
                                }
                            
                            if !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                DutchSpeechControlView(text: word, mode: .minimal)
                            }
                        }
                        
                        // Translation suggestion
                        if showTranslationSuggestion && !suggestedTranslation.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "translate")
                                        .foregroundColor(.blue)
                                    Text("Suggested translation:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    if isTranslating {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                    }
                                }
                                
                                HStack {
                                    Text(suggestedTranslation)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                        .font(.body)
                                    
                                    Button("Use") {
                                        definition = suggestedTranslation
                                        showTranslationSuggestion = false
                                        HapticManager.shared.lightImpact()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    
                                    Button("Dismiss") {
                                        showTranslationSuggestion = false
                                        HapticManager.shared.lightImpact()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    TextField("Definition (English)", text: $definition)
                        .onChange(of: definition) { oldValue, newValue in
                            logger.debug("Definition changed from '\(oldValue)' to '\(newValue)'")
                        }
                    
                    // Example field with speech controls
                    HStack(spacing: 8) {
                        TextField("Example (Optional)", text: $example)
                            .onChange(of: example) { oldValue, newValue in
                                logger.debug("Example changed from '\(oldValue)' to '\(newValue)'")
                            }
                        
                        if !example.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            DutchSpeechControlView(text: example, mode: .minimal)
                        }
                    }
                }
                
                // New section for Dutch Pronunciation
                Section(header: Text("Dutch Pronunciation")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Listen to pronunciation while you edit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Compact speech controls for the main word
                        if !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            DutchSpeechControlView(text: word, mode: .compact)
                        } else {
                            Text("Enter a Dutch word above to hear pronunciation")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                }
                
                Section(header: Text("Pronunciation (Optional)")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Record pronunciation for this word")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        AudioControlView(cardId: cardId, mode: .full)
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
                    
                    // Tense fields with speech controls
                    HStack(spacing: 8) {
                        TextField("Past Tense (Optional)", text: $pastTense)
                        
                        if !pastTense.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            DutchSpeechControlView(text: pastTense, mode: .minimal)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        TextField("Future Tense (Optional)", text: $futureTense)
                        
                        if !futureTense.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            DutchSpeechControlView(text: futureTense, mode: .minimal)
                        }
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
            logger.debug("EditCardView appeared")
        }
        .translationTask(translationConfiguration) { session in
            let wordToTranslate = lastTranslatedWord.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !wordToTranslate.isEmpty else { return }
            
            do {
                logger.debug("Translating word: \(wordToTranslate)")
                let response = try await session.translate(wordToTranslate)
                
                await MainActor.run {
                    suggestedTranslation = response.targetText
                    isTranslating = false
                    showTranslationSuggestion = true
                    logger.debug("Translation completed: \(response.targetText)")
                }
            } catch {
                await MainActor.run {
                    isTranslating = false
                    logger.error("Translation failed: \(error.localizedDescription)")
                }
            }
        }
        .onDisappear {
            logger.debug("EditCardView disappeared")
            // Stop any ongoing recording when view disappears
            AudioManager.shared.stopRecording()
            AudioManager.shared.stopPlayback()
        }
    }
    
    private func triggerTranslationSuggestion(for word: String) {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Only translate if word has meaningful content and isn't too short
        guard trimmedWord.count >= 2 else { return }
        
        // Reset state
        showTranslationSuggestion = false
        suggestedTranslation = ""
        isTranslating = true
        lastTranslatedWord = trimmedWord
        
        // Debounce translation requests
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Only proceed if the word hasn't changed
            guard self.word.trimmingCharacters(in: .whitespacesAndNewlines) == trimmedWord else {
                self.isTranslating = false
                return
            }
            
            // Configure translation from Dutch to English
            if self.translationConfiguration == nil {
                self.translationConfiguration = TranslationSession.Configuration(
                    source: Locale.Language(identifier: "nl"), // Dutch
                    target: Locale.Language(identifier: "en")  // English
                )
            } else {
                // Invalidate to trigger new translation
                self.translationConfiguration?.invalidate()
            }
        }
    }
} 