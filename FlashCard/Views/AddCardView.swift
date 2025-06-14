import SwiftUI
import os
#if canImport(Translation)
@preconcurrency import Translation
#endif

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
    
    // Additional grammatical fields
    @State private var article: String = ""
    @State private var plural: String = ""
    @State private var pastTense: String = ""
    @State private var futureTense: String = ""
    @State private var pastParticiple: String = ""
    
    // Audio recording
    @State private var temporaryCardId: UUID = UUID()
    
    // Translation features
    @State private var suggestedTranslation: String = ""
    @State private var isTranslating: Bool = false
    @State private var lastTranslatedWord: String = ""
    @State private var translationDismissed: Bool = false
    
    // Compatibility
    @State private var showingCompatibilityAlert = false
    @State private var compatibilityFeature: UnavailableFeature?
    
    // Duplicate handling
    @State private var showingDuplicateResolution = false
    @State private var duplicateCheckResult: FlashCardViewModel.DuplicateCheckResult?
    
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
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
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
                            attemptToSaveCard(shouldResetForm: true)
                        }
                        .disabled(!canSave)
                        .foregroundColor(canSave ? .blue : .gray)
                        
                        Button("Save") {
                            logger.debug("Save button tapped")
                            attemptToSaveCard()
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
                    Section(header: Text("Basic Information")) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Word field
                            TextField("e.g., eten", text: $word)
                                .onChange(of: word) { oldValue, newValue in
                                    logger.debug("Word changed from '\(oldValue)' to '\(newValue)'")
                                    
                                    // Clear translation results when word changes
                                    if newValue.trimmingCharacters(in: .whitespacesAndNewlines) != lastTranslatedWord {
                                        suggestedTranslation = ""
                                        translationDismissed = false
                                    }
                                }
                            
                            // Manual translation button - always available when word has 3+ characters
                            if !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && word.count >= 3 {
                                HStack {
                                    Button {
                                        manualTranslationRequest()
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "translate")
                                            Text("Get Translation")
                                            if isTranslating {
                                                ProgressView()
                                                    .scaleEffect(0.7)
                                                    .frame(width: 14, height: 14)
                                            }
                                        }
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .disabled(isTranslating)
                                    
                                    // Show compatibility info for older iOS versions
                                    if !CompatibilityHelper.isTranslationFrameworkAvailable {
                                        Button {
                                            compatibilityFeature = .translation
                                            showingCompatibilityAlert = true
                                        } label: {
                                            Image(systemName: "info.circle")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.top, 4)
                            }
                            
                            // Compatibility notice for older iOS versions
                            if !CompatibilityHelper.isTranslationFrameworkAvailable && !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && word.count >= 3 {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.orange)
                                        Text("Limited Translation")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("Using local dictionary only. For full translation features, update to iOS 17.4+")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // Translation result
                            if !suggestedTranslation.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                        Text("Translation found:")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Text(suggestedTranslation)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.green.opacity(0.1))
                                            .cornerRadius(8)
                                            .font(.body)
                                        
                                        Button("Use") {
                                            logger.debug("🎯 Use translation button tapped: '\(suggestedTranslation)'")
                                            definition = suggestedTranslation
                                            logger.debug("🔄 Translation used")
                                            HapticManager.shared.lightImpact()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .controlSize(.small)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // No translation found message
                            if translationDismissed && suggestedTranslation.isEmpty && !isTranslating {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "exclamationmark.circle.fill")
                                            .foregroundColor(.orange)
                                        Text("No translation found")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text("No translation available for '\(lastTranslatedWord)'")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                        .font(.body)
                                        .foregroundColor(.orange)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        TextField("e.g., to eat", text: $definition)
                            .onChange(of: definition) { oldValue, newValue in
                                logger.debug("Definition changed from '\(oldValue)' to '\(newValue)'")
                            }
                        
                        // Example field with speech controls
                        HStack(spacing: 8) {
                            TextField("e.g., Ik wil eten.", text: $example)
                                .onChange(of: example) { oldValue, newValue in
                                    logger.debug("Example changed from '\(oldValue)' to '\(newValue)'")
                                }
                            
                            if !example.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                DutchSpeechControlView(text: example, mode: .minimal)
                            }
                        }
                    }
                    
                    Section(header: Text("Additional Grammar (Optional)")) {
                        TextField("Article (de/het)", text: $article)
                            .onChange(of: article) { oldValue, newValue in
                                logger.debug("Article changed from '\(oldValue)' to '\(newValue)'")
                            }
                        
                        TextField("Plural form", text: $plural)
                            .onChange(of: plural) { oldValue, newValue in
                                logger.debug("Plural changed from '\(oldValue)' to '\(newValue)'")
                            }
                        
                        TextField("Past tense", text: $pastTense)
                            .onChange(of: pastTense) { oldValue, newValue in
                                logger.debug("Past tense changed from '\(oldValue)' to '\(newValue)'")
                            }
                        
                        TextField("Future tense", text: $futureTense)
                            .onChange(of: futureTense) { oldValue, newValue in
                                logger.debug("Future tense changed from '\(oldValue)' to '\(newValue)'")
                            }
                        
                        TextField("Past participle", text: $pastParticiple)
                            .onChange(of: pastParticiple) { oldValue, newValue in
                                logger.debug("Past participle changed from '\(oldValue)' to '\(newValue)'")
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
        .sheet(isPresented: $showingDuplicateResolution) {
            if case .partialMatch(let existingCard, let comparison) = duplicateCheckResult {
                let newCardData = DuplicateCardResolutionView.NewCardData(
                    word: word.trimmingCharacters(in: .whitespacesAndNewlines),
                    definition: definition.trimmingCharacters(in: .whitespacesAndNewlines),
                    example: example.trimmingCharacters(in: .whitespacesAndNewlines),
                    deckIds: selectedDeckIds,
                    article: article.trimmingCharacters(in: .whitespacesAndNewlines),
                    plural: plural.trimmingCharacters(in: .whitespacesAndNewlines),
                    pastTense: pastTense.trimmingCharacters(in: .whitespacesAndNewlines),
                    futureTense: futureTense.trimmingCharacters(in: .whitespacesAndNewlines),
                    pastParticiple: pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                
                DuplicateCardResolutionView(
                    viewModel: viewModel,
                    existingCard: existingCard,
                    newCardData: newCardData,
                    comparison: comparison
                ) { action in
                    handleDuplicateResolution(action, existingCard: existingCard)
                }
            }
        }
        .alert("Card Already Exists", isPresented: .constant(duplicateCheckResult != nil && showingExactMatchAlert)) {
            Button("OK") {
                duplicateCheckResult = nil
            }
        } message: {
            Text("The word \"\(word)\" already exists with identical information.")
        }
        .featureUnavailableAlert(
            isPresented: $showingCompatibilityAlert,
            feature: compatibilityFeature ?? .translation
        )
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
    
    private var showingExactMatchAlert: Bool {
        if case .exactMatch = duplicateCheckResult {
            return true
        }
        return false
    }
    
    private func attemptToSaveCard(shouldResetForm: Bool = false) {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArticle = article.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlural = plural.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastTense = pastTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFutureTense = futureTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastParticiple = pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check for duplicates
        let result = viewModel.checkForDuplicateCard(
            word: trimmedWord,
            definition: trimmedDefinition,
            example: trimmedExample,
            article: trimmedArticle,
            plural: trimmedPlural,
            pastTense: trimmedPastTense,
            futureTense: trimmedFutureTense,
            pastParticiple: trimmedPastParticiple
        )
        
        switch result {
        case .noDuplicate:
            // No duplicate, proceed with adding the card
            saveCurrentCard()
            if shouldResetForm {
                resetForm()
            } else {
                dismiss()
            }
            
        case .exactMatch:
            // Show alert for exact match
            duplicateCheckResult = result
            
        case .partialMatch:
            // Show resolution view for partial match
            duplicateCheckResult = result
            showingDuplicateResolution = true
        }
    }
    
    private func handleDuplicateResolution(_ action: DuplicateCardResolutionView.ResolutionAction, existingCard: FlashCard, shouldResetForm: Bool = false) {
        let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArticle = article.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlural = plural.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastTense = pastTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFutureTense = futureTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastParticiple = pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch action {
        case .keepExisting:
            // Just dismiss, don't add anything
            duplicateCheckResult = nil
            if shouldResetForm {
                resetForm()
            } else {
                dismiss()
            }
            
        case .replaceWithNew:
            // Replace the existing card with new data
            viewModel.mergeCardData(
                existingCard: existingCard,
                newDefinition: trimmedDefinition,
                newExample: trimmedExample,
                newDeckIds: selectedDeckIds,
                newArticle: trimmedArticle,
                newPlural: trimmedPlural,
                newPastTense: trimmedPastTense,
                newFutureTense: trimmedFutureTense,
                newPastParticiple: trimmedPastParticiple,
                mergeStrategy: .replaceWithNew
            )
            duplicateCheckResult = nil
            if shouldResetForm {
                resetForm()
            } else {
                dismiss()
            }
            
        case .mergeAdditionalFields:
            // Merge only additional fields
            viewModel.mergeCardData(
                existingCard: existingCard,
                newDefinition: trimmedDefinition,
                newExample: trimmedExample,
                newDeckIds: selectedDeckIds,
                newArticle: trimmedArticle,
                newPlural: trimmedPlural,
                newPastTense: trimmedPastTense,
                newFutureTense: trimmedFutureTense,
                newPastParticiple: trimmedPastParticiple,
                mergeStrategy: .mergeAdditionalFields
            )
            duplicateCheckResult = nil
            if shouldResetForm {
                resetForm()
            } else {
                dismiss()
            }
            
        case .cancel:
            // Cancel the operation
            duplicateCheckResult = nil
        }
    }
    
    private func saveCurrentCard() {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArticle = article.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlural = plural.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastTense = pastTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFutureTense = futureTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastParticiple = pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines)
        
        logger.debug("Adding card - Word: \(trimmedWord), Definition: \(trimmedDefinition)")
        
        // Create the card with the temporary ID so audio gets associated correctly
        let newCard = viewModel.addCard(
            word: trimmedWord,
            definition: trimmedDefinition,
            example: trimmedExample,
            deckIds: selectedDeckIds,
            article: trimmedArticle,
            plural: trimmedPlural,
            pastTense: trimmedPastTense,
            futureTense: trimmedFutureTense,
            pastParticiple: trimmedPastParticiple,
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
        article = ""
        plural = ""
        pastTense = ""
        futureTense = ""
        pastParticiple = ""
        
        // Keep deck selection but clear other fields
        // selectedDeckIds remains the same for convenience
        
        // Generate new temporary ID for audio recordings
        temporaryCardId = UUID()
        
        // Clear translation state
        suggestedTranslation = ""
        lastTranslatedWord = ""
        translationDismissed = false
        isTranslating = false
        
        logger.debug("Form reset for adding another card")
    }
    
    private func manualTranslationRequest() {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedWord.count >= 3 else { return }
        
        logger.debug("🔄 Manual translation request for: '\(trimmedWord)'")
        
        // Set loading state
        isTranslating = true
        lastTranslatedWord = trimmedWord
        suggestedTranslation = ""
        translationDismissed = false
        
        // Use compatibility wrapper for translation
        Task {
            let translation = await TranslationCompatibility.getTranslation(for: trimmedWord)
            
            await MainActor.run {
                isTranslating = false
                
                if !translation.isEmpty {
                    suggestedTranslation = translation
                    logger.debug("✅ Translation found: '\(translation)'")
                } else {
                    suggestedTranslation = ""
                    translationDismissed = true // This will show "no translation found"
                    logger.debug("❌ No translation found for: '\(trimmedWord)'")
                }
            }
        }
        
        HapticManager.shared.lightImpact()
        logger.debug("✅ Manual translation request initiated")
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView(viewModel: FlashCardViewModel())
    }
} 