import SwiftUI
import os
#if canImport(Translation)
@preconcurrency import Translation
#endif

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let defaultDeck: Deck?
    let initialDeckIds: [UUID]?
    
    @State private var word: String = ""
    @State private var definition: String = ""
    @State private var example: String = ""
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var showingDeckSelection = false
    @State private var newDeckName: String = ""
    
    // Additional grammatical fields (matching EditCardView)
    @State private var article: String = ""
    @State private var plural: String = ""
    @State private var pastTense: String = ""
    @State private var futureTense: String = ""
    @State private var pastParticiple: String = ""
    
    // Audio recording state
    @State private var temporaryCardId = UUID()
    
    // Validation state
    @State private var showingValidationAlert = false
    @State private var validationMessage = ""
    
    // Compatibility tracking
    @State private var compatibilityFeature: UnavailableFeature?
    @State private var showingCompatibilityAlert = false
    
    // Translation state (only used on iOS 18.0+)
    @State private var translationConfiguration: Any?
    @State private var lastTranslatedWord: String = ""
    @State private var showingTranslationError = false
    @State private var translationErrorMessage = ""
    
    // Session tracking for summary notification
    @State private var wordsAddedThisSession = 0
    @State private var hasShownSummaryNotification = false
    
    private let logger = Logger(subsystem: "com.flashcards", category: "AddCardView")
    
    private var canSave: Bool {
        !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(viewModel: FlashCardViewModel, defaultDeck: Deck? = nil, initialDeckIds: [UUID]? = nil, initialWord: String? = nil, initialDefinition: String? = nil) {
        self.viewModel = viewModel
        self.defaultDeck = defaultDeck
        self.initialDeckIds = initialDeckIds
        
        // Pre-fill word if provided
        if let initialWord = initialWord {
            _word = State(initialValue: initialWord)
        }
        
        // Pre-fill definition if provided
        if let initialDefinition = initialDefinition {
            _definition = State(initialValue: initialDefinition)
        }
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
                        // Show summary notification if words were added
                        if wordsAddedThisSession > 1 && !hasShownSummaryNotification {
                            logger.debug("Cancel: Showing summary notification for \(wordsAddedThisSession) words")
                            showSummaryNotification()
                        } else if wordsAddedThisSession == 1 && !hasShownSummaryNotification {
                            // Show single word notification if only one word was added
                            logger.debug("Cancel: Showing single word notification")
                            NotificationManager.shared.showNotification(
                                AppNotification(
                                    type: .info,
                                    title: "✅ Word Added",
                                    message: "Added 1 new word to your collection",
                                    duration: 3.0
                                )
                            )
                        }
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
                            // Word field with speech controls
                            HStack(spacing: 8) {
                                TextField("e.g., eten", text: $word)
                                    .onChange(of: word) { newValue in
                                        logger.debug("Word changed: \(newValue)")
                                        if newValue.count > 50 {
                                            word = String(newValue.prefix(50))
                                        }
                                    }
                                
                                #if !LITE_VERSION
                                if !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    DutchSpeechControlView(text: word, mode: .minimal)
                                }
                                #endif
                            }
                            Text("\(word.count)/50 characters")
                                .font(.caption)
                                .foregroundColor(word.count > 50 ? .red : .secondary)
                            
                            // Persistent translation button - always available when word has 3+ characters
                            if !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && word.count >= 3 {
                                HStack {
                                    Button {
                                        manualTranslationRequest()
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "translate")
                                            Text(BuildConfiguration.isFeatureAvailable(.dutchTranslation) ? "Get Translation" : "Translation (Lite)")
                                        }
                                        .font(.caption)
                                        .foregroundColor(BuildConfiguration.isFeatureAvailable(.dutchTranslation) ? .blue : .gray)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                    .disabled(!BuildConfiguration.isFeatureAvailable(.dutchTranslation))
                                    
                                    // Show compatibility info for older iOS versions
                                    if !CompatibilityHelper.isTranslationFrameworkAvailable && BuildConfiguration.isFeatureAvailable(.dutchTranslation) {
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
                            
                            // Compatibility notice for older iOS versions or lite version
                            if (!CompatibilityHelper.isTranslationFrameworkAvailable || !BuildConfiguration.isFeatureAvailable(.dutchTranslation)) && !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && word.count >= 3 {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.orange)
                                        Text(BuildConfiguration.isFeatureAvailable(.dutchTranslation) ? "Limited Translation" : "Translation Unavailable")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Text(BuildConfiguration.isFeatureAvailable(.dutchTranslation) ? 
                                         "Using local dictionary only. For full translation features, update to iOS 18.0+" :
                                         "Translation features are only available in the full version of \(BuildConfiguration.appName).")
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(8)
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        
                        TextField("e.g., to eat", text: $definition)
                            .onChange(of: definition) { newValue in
                                logger.debug("Definition changed: \(newValue)")
                                if newValue.count > 50 {
                                    definition = String(newValue.prefix(50))
                                }
                            }
                            .onChange(of: definition) { newValue in
                                logger.debug("Definition changed: \(newValue)")
                            }
                        Text("\(definition.count)/50 characters")
                            .font(.caption)
                            .foregroundColor(definition.count > 50 ? .red : .secondary)
                        
                        // Example field with speech controls
                        HStack(spacing: 8) {
                            TextField("e.g., Ik wil eten.", text: $example)
                                .onChange(of: example) { newValue in
                                    logger.debug("Example changed: \(newValue)")
                                }
                            
                            #if !LITE_VERSION
                            if !example.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                DutchSpeechControlView(text: example, mode: .minimal)
                            }
                            #endif
                        }
                    }
                    
                    Section(header: Text("Additional Grammar (Optional)")) {
                        if BuildConfiguration.isFeatureAvailable(.additionalGrammar) {
                            TextField("Article (de/het)", text: $article)
                                .onChange(of: article) { newValue in
                                    logger.debug("Article changed: \(newValue)")
                                }
                            
                            TextField("Plural form", text: $plural)
                                .onChange(of: plural) { newValue in
                                    logger.debug("Plural changed: \(newValue)")
                                }
                            
                            TextField("Past tense", text: $pastTense)
                                .onChange(of: pastTense) { newValue in
                                    logger.debug("Past tense changed: \(newValue)")
                                }
                            
                            TextField("Future tense", text: $futureTense)
                                .onChange(of: futureTense) { newValue in
                                    logger.debug("Future tense changed: \(newValue)")
                                }
                            
                            TextField("Past participle", text: $pastParticiple)
                                .onChange(of: pastParticiple) { newValue in
                                    logger.debug("Past participle changed: \(newValue)")
                                }
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lock.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Advanced Grammar Features")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text("Advanced grammar fields (articles, tenses, etc.) are only available in the full version of \(BuildConfiguration.appName).")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.orange.opacity(0.1))
                                    .cornerRadius(8)
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                            .padding(.vertical, 8)
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
                            showingDeckSelection = true
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingDeckSelection) {
            VStack(spacing: 0) {
                // Custom navigation bar for sheet
                HStack {
                    Button("Cancel") {
                        showingDeckSelection = false
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
                        showingDeckSelection = false
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
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            logger.debug("AddCardView appeared")
            
            // Pre-select decks if provided
            if let providedDeckIds = initialDeckIds {
                selectedDeckIds = Set(providedDeckIds)
                logger.debug("Pre-selected decks: \(selectedDeckIds)")
            } else if let defaultDeck = defaultDeck {
                selectedDeckIds.insert(defaultDeck.id)
                logger.debug("Pre-selected default deck: \(defaultDeck.name)")
            }
            
            // Reset session tracking for new session
            wordsAddedThisSession = 0
            hasShownSummaryNotification = false
            logger.debug("Session tracking reset for new AddCardView session")
        }
        .onDisappear {
            logger.debug("AddCardView disappeared")
            // Stop any ongoing recording when view disappears
            AudioManager.shared.stopRecording()
            AudioManager.shared.stopPlayback()
            
            // Show summary notification if words were added and no summary was shown yet
            if wordsAddedThisSession > 1 && !hasShownSummaryNotification {
                logger.debug("onDisappear: Showing summary notification for \(wordsAddedThisSession) words")
                showSummaryNotification()
            } else if wordsAddedThisSession == 1 && !hasShownSummaryNotification {
                // Show single word notification if only one word was added
                logger.debug("onDisappear: Showing single word notification")
                NotificationManager.shared.showNotification(
                    AppNotification(
                        type: .info,
                        title: "✅ Word Added",
                        message: "Added 1 new word to your collection",
                        duration: 3.0
                    )
                )
            }
        }
        .alert("Word Found", isPresented: $showingValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .featureUnavailableAlert(
            isPresented: $showingCompatibilityAlert,
            feature: compatibilityFeature ?? .translation
        )
        .modifier(TranslationTaskModifier(
            translationConfiguration: translationConfiguration,
            lastTranslatedWord: lastTranslatedWord,
            onTranslationComplete: { translation in
                self.definition = translation
                self.validationMessage = "✅ Apple Translation found: '\(translation)'"
                self.showingValidationAlert = true
                self.logger.debug("✅ Apple Translation found: '\(translation)'")
            },
            onTranslationError: { error in
                self.translationErrorMessage = error
                self.showingTranslationError = true
                self.logger.debug("❌ Apple Translation failed: \(error)")
            }
        ))
        .alert("Translation Error", isPresented: $showingTranslationError) {
            Button("OK") { }
        } message: {
            Text(translationErrorMessage)
        }
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
            // No duplicates, save the card
            saveCardWithoutDuplicateCheck(shouldResetForm: shouldResetForm)
            
        case .exactMatch:
            // Show positive confirmation for exact match
            showingValidationAlert = true
            validationMessage = "✅ Great! The word \"\(trimmedWord)\" already exists in your collection with identical information."
            
        case .partialMatch:
            // Show resolution view for partial match
            showingValidationAlert = true
            validationMessage = "The word \"\(trimmedWord)\" already exists with similar information."
        }
    }
    
    private func saveCardWithoutDuplicateCheck(shouldResetForm: Bool = false) {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDefinition = definition.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedExample = example.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedArticle = article.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlural = plural.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastTense = pastTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedFutureTense = futureTense.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPastParticiple = pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines)
        
        logger.debug("Attempting to save card...")
        
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
        
        // Increment session counter
        wordsAddedThisSession += 1
        logger.debug("Session counter incremented to: \(wordsAddedThisSession)")
        
        // Explicitly save the cards to ensure persistence
        viewModel.saveAllData()
        logger.debug("ViewModel data saved after adding card: '\(trimmedWord)'")
        
        // Force a save to UserDefaults
        UserDefaults.standard.synchronize()
        logger.debug("UserDefaults synchronized")
        
        // Show updating notification for "Save & Add Another" mode
        if shouldResetForm {
            // Show updating notification that shows total words added so far
            NotificationManager.shared.showNotification(
                AppNotification(
                    type: .info,
                    title: "✅ Card Added",
                    message: "Added '\(trimmedWord)' (\(wordsAddedThisSession) total this session)",
                    duration: 2.0
                )
            )
        } else {
            // Show individual notification for single save
            NotificationManager.shared.showNotification(
                AppNotification(
                    type: .info,
                    title: "✅ Card Saved",
                    message: "Added '\(trimmedWord)' to your collection",
                    duration: 3.0
                )
            )
        }
        
        if shouldResetForm {
            resetForm()
        } else {
            // Show summary notification before dismissing
            showSummaryNotification()
            dismiss()
        }
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
        
        // Clear translation state
        translationConfiguration = nil
        lastTranslatedWord = ""
        
        // Keep deck selection but clear other fields
        // selectedDeckIds remains the same for convenience
        
        // Generate new temporary ID for audio recordings
        temporaryCardId = UUID()
        
        logger.debug("Form reset for adding another card")
    }
    
    private func manualTranslationRequest() {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedWord.count >= 3 else { return }
        
        // Check if translation features are available
        guard BuildConfiguration.isFeatureAvailable(.dutchTranslation) else {
            self.validationMessage = "Translation features are only available in the full version of \(BuildConfiguration.appName)."
            self.showingValidationAlert = true
            return
        }
        
        logger.debug("🔄 Manual translation request for: '\(trimmedWord)'")
        
        // Try Apple's Translation framework first (iOS 18.0+)
        if #available(iOS 18.0, *), CompatibilityHelper.isTranslationFrameworkAvailable {
            #if canImport(Translation)
            // Set up translation configuration and trigger translation
            translationConfiguration = TranslationSession.Configuration(
                source: Locale.Language(identifier: "nl"),
                target: Locale.Language(identifier: "en")
            )
            lastTranslatedWord = trimmedWord
            return
            #endif
        }
        
        // Use comprehensive translation service to get rich vocabulary data
        Task { @MainActor in
            do {
                // First try to get comprehensive translation from our vocabulary database
                if let comprehensiveTranslation = await TranslationService.shared.getComprehensiveTranslation(for: trimmedWord) {
                    // Auto-fill all available fields from our vocabulary database
                    self.definition = comprehensiveTranslation.definition
                    
                    if let example = comprehensiveTranslation.example, !example.isEmpty {
                        self.example = example
                    }
                    
                    if let article = comprehensiveTranslation.article, !article.isEmpty {
                        self.article = article
                    }
                    
                    if let plural = comprehensiveTranslation.plural, !plural.isEmpty {
                        self.plural = plural
                    }
                    
                    if let pastTense = comprehensiveTranslation.pastTense, !pastTense.isEmpty {
                        self.pastTense = pastTense
                    }
                    
                    if let futureTense = comprehensiveTranslation.futureTense, !futureTense.isEmpty {
                        self.futureTense = futureTense
                    }
                    
                    if let pastParticiple = comprehensiveTranslation.pastParticiple, !pastParticiple.isEmpty {
                        self.pastParticiple = pastParticiple
                    }
                    
                    // Create user-friendly success message
                    var successMessage = "Nice addition! I have filled in remaining fields for you."
                    
                    if let level = comprehensiveTranslation.level, let category = comprehensiveTranslation.category {
                        successMessage += "\n\nCheck out similar words in the following pack:\n\(level.rawValue) - \(category.rawValue)"
                    }
                    
                    // Inform user about alternative versions if they exist
                    if comprehensiveTranslation.hasAlternatives {
                        successMessage += "\n\n💡 Note: This word appears in \(comprehensiveTranslation.alternativeCount) different levels/contexts. I've selected the most advanced version (\(comprehensiveTranslation.level?.rawValue ?? "Unknown"))."
                    }
                    
                    self.validationMessage = successMessage
                    self.showingValidationAlert = true
                    
                    logger.debug("✅ Comprehensive translation found with 95% confidence")
                } else {
                    // Fallback to basic translation from local dictionary
                let translation = await TranslationService.shared.getTranslationWithFallback(for: trimmedWord)
                
                if !translation.isEmpty {
                    self.definition = translation
                        self.validationMessage = "✅ Basic translation found\nConsider adding more details manually"
                        self.showingValidationAlert = true
                        logger.debug("✅ Basic translation found: '\(translation)'")
                } else {
                        self.validationMessage = "❌ No translation found for: '\(trimmedWord)'\n\nTip: Check spelling or try a different form of the word"
                    self.showingValidationAlert = true
                    logger.debug("❌ No translation found for: '\(trimmedWord)'")
                    }
                }
            } catch {
                logger.error("❌ Translation error: \(error.localizedDescription)")
                self.validationMessage = "Translation failed: \(error.localizedDescription)"
                self.showingValidationAlert = true
            }
        }
        
        HapticManager.shared.lightImpact()
        logger.debug("✅ Manual translation request initiated")
    }
    
    private func showSummaryNotification() {
        guard wordsAddedThisSession > 1 && !hasShownSummaryNotification else { return }
        
        logger.debug("Showing summary notification for \(wordsAddedThisSession) words added this session")
        hasShownSummaryNotification = true
        
        // Show summary notification with delay to avoid conflicts with individual card notifications
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            NotificationManager.shared.showNotification(
                AppNotification(
                    type: .info,
                    title: "✅ Session Complete",
                    message: "Great job! Added \(wordsAddedThisSession) new words to your collection",
                    duration: 4.0
                )
            )
        }
    }
}

struct AddCardView_Previews: PreviewProvider {
    static var previews: some View {
        AddCardView(viewModel: FlashCardViewModel())
    }
} 