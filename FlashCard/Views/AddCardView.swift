import SwiftUI
import os
import Translation

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
    
    // New verb form structure
    @State private var selectedVerbForm: VerbForm = .infinitive
    
    // Dutch language features (keeping article for nouns)
    @State private var isDeSelected: Bool = false
    @State private var isHetSelected: Bool = false
    
    // Audio recording
    @State private var temporaryCardId: UUID = UUID()
    
    // Translation features
    @State private var translationConfiguration: TranslationSession.Configuration?
    @State private var suggestedTranslation: String = ""
    @State private var isTranslating: Bool = false
    @State private var showTranslationSuggestion: Bool = false
    @State private var lastTranslatedWord: String = ""
    
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
                    // Verb Form Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Word Type")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Verb Form", selection: $selectedVerbForm) {
                            ForEach(VerbForm.allCases, id: \.self) { form in
                                Text(form.description).tag(form)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: selectedVerbForm) { oldValue, newValue in
                            logger.debug("Verb form changed from \(oldValue.description) to \(newValue.description)")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Word field with speech controls and dynamic placeholder
                        HStack(spacing: 8) {
                            TextField(selectedVerbForm.placeholder, text: $word)
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
                    
                    TextField(selectedVerbForm.translationPlaceholder, text: $definition)
                        .onChange(of: definition) { oldValue, newValue in
                            logger.debug("Definition changed from '\(oldValue)' to '\(newValue)'")
                        }
                    
                    // Example field with speech controls and dynamic placeholder
                    HStack(spacing: 8) {
                        TextField(selectedVerbForm.examplePlaceholder, text: $example)
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
                        Text("Listen to pronunciation while you type")
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
                        
                        AudioControlView(cardId: temporaryCardId, mode: .full)
                    }
                }
                
                Section(header: Text("Dutch Language Features (Optional)")) {
                    // Article selection (only show for nouns/infinitives)
                    if selectedVerbForm == .infinitive {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Article (for nouns)")
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
    }
    
    private func saveCurrentCard() {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
        
        logger.debug("Adding card - Word: \(trimmedWord), Definition: \(trimmedDefinition), Verb Form: \(selectedVerbForm.description)")
        
        // Create the card with the temporary ID so audio gets associated correctly
        let newCard = viewModel.addCard(
            word: trimmedWord,
            definition: trimmedDefinition,
            example: trimmedExample,
            deckIds: selectedDeckIds,
            verbForm: selectedVerbForm,
            article: isDeSelected ? "de" : (isHetSelected ? "het" : nil),
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
        // Keep selectedVerbForm so user doesn't have to reselect
        isDeSelected = false
        isHetSelected = false
        
        // Generate new temporary ID for next card
        temporaryCardId = UUID()
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
        
        // Set up translation configuration
        translationConfiguration = TranslationSession.Configuration(
            source: Locale.Language(identifier: "nl"),
            target: Locale.Language(identifier: "en")
        )
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView(viewModel: FlashCardViewModel())
    }
} 