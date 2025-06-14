import SwiftUI
import os
#if canImport(Translation)
@preconcurrency import Translation
#endif

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
    
    // Additional grammatical fields
    @State private var article: String = ""
    @State private var plural: String = ""
    @State private var pastTense: String = ""
    @State private var futureTense: String = ""
    @State private var pastParticiple: String = ""
    
    // Translation features (only used on iOS 17.4+)
    #if canImport(Translation)
    @available(iOS 17.4, *)
    @State private var translationConfiguration: TranslationSession.Configuration?
    #endif
    @State private var suggestedTranslation: String = ""
    @State private var isTranslating: Bool = false
    @State private var showTranslationSuggestion: Bool = false
    @State private var lastTranslatedWord: String = ""
    @State private var translationDismissed: Bool = false
    
    // Compatibility
    @State private var showingCompatibilityAlert = false
    @State private var compatibilityFeature: UnavailableFeature?
    
    private let logger = Logger(subsystem: "com.flashcards", category: "EditCardView")
    
    init(viewModel: FlashCardViewModel, card: FlashCard) {
        logger.debug("Initializing EditCardView for card: \(card.id)")
        self.viewModel = viewModel
        self.cardId = card.id
        _word = State(initialValue: card.word)
        _definition = State(initialValue: card.definition)
        _example = State(initialValue: card.example)
        _selectedDeckIds = State(initialValue: card.deckIds)
        
        // Initialize grammatical fields
        _article = State(initialValue: card.article)
        _plural = State(initialValue: card.plural)
        _pastTense = State(initialValue: card.pastTense)
        _futureTense = State(initialValue: card.futureTense)
        _pastParticiple = State(initialValue: card.pastParticiple)
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
                    let trimmedArticle = article.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedPlural = plural.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedPastTense = pastTense.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedFutureTense = futureTense.trimmingCharacters(in: .whitespacesAndNewlines)
                    let trimmedPastParticiple = pastParticiple.trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    logger.debug("Updating card with values - Word: \(trimmedWord), Translation: \(trimmedDefinition)")
                    
                    // Update the card
                    viewModel.updateCard(
                        currentCard,
                        word: trimmedWord,
                        definition: trimmedDefinition,
                        example: trimmedExample,
                        deckIds: selectedDeckIds,
                        article: trimmedArticle,
                        plural: trimmedPlural,
                        pastTense: trimmedPastTense,
                        futureTense: trimmedFutureTense,
                        pastParticiple: trimmedPastParticiple
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
                Section(header: Text("Basic Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        // Word field with speech controls
                        HStack(spacing: 8) {
                            TextField("e.g., eten", text: $word)
                                .onChange(of: word) { oldValue, newValue in
                                    logger.debug("Word changed from '\(oldValue)' to '\(newValue)'")
                                    
                                    let trimmedWord = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    
                                    // Only trigger automatic translation if:
                                    // 1. Word has 3+ characters
                                    // 2. Word is different from last translated
                                    // 3. User hasn't dismissed suggestions
                                    // 4. We're not currently translating
                                    if trimmedWord.count >= 3 && 
                                       trimmedWord != lastTranslatedWord && 
                                       !translationDismissed && 
                                       !isTranslating {
                                        triggerTranslationSuggestion(for: trimmedWord)
                                    } else if trimmedWord.isEmpty {
                                        showTranslationSuggestion = false
                                        suggestedTranslation = ""
                                        translationDismissed = false
                                        lastTranslatedWord = ""
                                    } else if trimmedWord.count < 3 {
                                        showTranslationSuggestion = false
                                        suggestedTranslation = ""
                                        isTranslating = false
                                        lastTranslatedWord = ""
                                    }
                                }
                            
                            if !word.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                DutchSpeechControlView(text: word, mode: .minimal)
                            }
                        }
                        
                        // Persistent translation button - always available when word has 3+ characters
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
                        
                        // Automatic translation suggestion (can be dismissed)
                        if showTranslationSuggestion && !suggestedTranslation.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.blue)
                                    Text("Auto-suggested translation:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
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
                                        translationDismissed = true
                                        HapticManager.shared.lightImpact()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                    
                                    Button("Dismiss") {
                                        showTranslationSuggestion = false
                                        translationDismissed = true
                                        HapticManager.shared.lightImpact()
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Manual translation result (from button press)
                        if !showTranslationSuggestion && !suggestedTranslation.isEmpty && !isTranslating {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "translate")
                                        .foregroundColor(.green)
                                    Text("Translation:")
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
                                        definition = suggestedTranslation
                                        HapticManager.shared.lightImpact()
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    TextField("e.g., to eat", text: $definition)
                        .onChange(of: definition) { oldValue, newValue in
                            logger.debug("Translation changed from '\(oldValue)' to '\(newValue)'")
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
            // New deck creation sheet
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
        .compatibleTranslationTask()
        .featureUnavailableAlert(
            isPresented: $showingCompatibilityAlert,
            feature: compatibilityFeature ?? .translation
        )
        .onAppear {
            loadCardData()
        }
        .onDisappear {
            // Stop any ongoing recording when view disappears
            AudioManager.shared.stopRecording()
            AudioManager.shared.stopPlayback()
        }
    }
    
    @ViewBuilder
    private func compatibleTranslationTask() -> some View {
        if #available(iOS 17.4, *) {
            self.translationTask(translationConfiguration) { session in
                guard let config = translationConfiguration else { return }
                
                let wordToTranslate = lastTranslatedWord
                
                do {
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
        } else {
            // No translation task needed for older iOS versions
            self
        }
    }
    
    private func triggerTranslationSuggestion(for word: String) {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Only translate if word has meaningful content and isn't too short
        guard trimmedWord.count >= 3 else { return }
        
        // Reset state
        showTranslationSuggestion = false
        suggestedTranslation = ""
        isTranslating = true
        lastTranslatedWord = trimmedWord
        translationDismissed = false
        
        // Set up translation configuration
        translationConfiguration = TranslationSession.Configuration(
            source: Locale.Language(identifier: "nl"),
            target: Locale.Language(identifier: "en")
        )
    }
    
    private func manualTranslationRequest() {
        let trimmedWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedWord.count >= 3 else { return }
        
        logger.debug("🔄 Manual translation request for: '\(trimmedWord)'")
        
        // Set loading state
        isTranslating = true
        showTranslationSuggestion = false
        suggestedTranslation = ""
        lastTranslatedWord = trimmedWord
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
                    translationDismissed = true
                    logger.debug("❌ No translation found for: '\(trimmedWord)'")
                }
            }
        }
        
        HapticManager.shared.lightImpact()
        logger.debug("✅ Manual translation request initiated")
    }
    
    private func loadCardData() {
        logger.debug("EditCardView appeared")
        
        guard let card = viewModel.getCard(by: cardId) else {
            logger.error("Card not found with ID: \(cardId)")
            dismiss()
            return
        }
        
        // Load card data into state variables
        word = card.word
        definition = card.definition
        example = card.example
        selectedDeckIds = Set(card.deckIds)
        article = card.article
        plural = card.plural
        pastTense = card.pastTense
        futureTense = card.futureTense
        pastParticiple = card.pastParticiple
        
        logger.debug("Loaded card data - Word: \(card.word), Definition: \(card.definition)")
    }
}

struct EditCardView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = FlashCardViewModel()
        let sampleCard = FlashCard(word: "eten", definition: "to eat", example: "Ik wil eten.")
        EditCardView(viewModel: viewModel, card: sampleCard)
    }
} 