import SwiftUI
import os

struct WordSelectionView: View {
    let image: UIImage
    @Binding var extractedWords: [ImageImportView.ExtractedWord]
    @Binding var selectedDeckIds: Set<UUID>
    @ObservedObject var viewModel: FlashCardViewModel
    let onComplete: () -> Void
    
    @State private var showingDeckSelection = false
    @State private var editingWordIndex: Int?
    @State private var editingTranslation = ""
    @State private var showingBatchImport = false
    @State private var filterOption: FilterOption = .all
    @State private var showingImportSuccess = false
    @State private var importedCardsCount = 0
    
    private let logger = Logger(subsystem: "com.flashcards", category: "WordSelectionView")
    
    enum FilterOption: String, CaseIterable {
        case all = "All Words"
        case unknown = "Unknown Only"
        case selected = "Selected Only"
    }
    
    private var filteredWords: [ImageImportView.ExtractedWord] {
        switch filterOption {
        case .all:
            return extractedWords
        case .unknown:
            return extractedWords.filter { !$0.isKnownWord }
        case .selected:
            return extractedWords.filter { $0.isSelected }
        }
    }
    
    private var selectedWordsCount: Int {
        extractedWords.filter { $0.isSelected }.count
    }
    
    private var unknownWordsCount: Int {
        extractedWords.filter { !$0.isKnownWord }.count
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with stats
            VStack(spacing: 12) {
                HStack(spacing: 20) {
                    StatCard(
                        icon: "textformat.abc",
                        title: "Total Words",
                        subtitle: "\(extractedWords.count) found",
                        color: .blue
                    )
                    
                    StatCard(
                        icon: "questionmark.circle.fill",
                        title: "Unknown",
                        subtitle: "\(unknownWordsCount) new",
                        color: .orange
                    )
                    
                    StatCard(
                        icon: "checkmark.circle.fill",
                        title: "Selected",
                        subtitle: "\(selectedWordsCount) to add",
                        color: .green
                    )
                }
                
                // Filter and actions
                HStack {
                    // Filter picker
                    Picker("Filter", selection: $filterOption) {
                        ForEach(FilterOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Spacer()
                    
                    // Quick actions
                    Menu {
                        Button("Select All Unknown") {
                            selectAllUnknown()
                        }
                        
                        Button("Select All") {
                            selectAll()
                        }
                        
                        Button("Deselect All") {
                            deselectAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            
            // Words list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(filteredWords.enumerated()), id: \.element.id) { index, word in
                        WordSelectionRow(
                            word: binding(for: word),
                            onTranslationEdit: { wordId in
                                if let globalIndex = extractedWords.firstIndex(where: { $0.id == wordId }) {
                                    editingWordIndex = globalIndex
                                    editingTranslation = extractedWords[globalIndex].suggestedTranslation
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            
            // Bottom action bar
            VStack(spacing: 12) {
                if selectedWordsCount > 0 {
                    // Deck selection
                    HStack {
                        Text("Add to decks:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button("Select Decks") {
                            showingDeckSelection = true
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                    
                    if !selectedDeckIds.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedDeckIds.compactMap { deckId in
                                    viewModel.decks.first { $0.id == deckId }
                                }, id: \.id) { deck in
                                    Text(deck.name)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                // Action buttons
                HStack(spacing: 12) {
                    Button("Cancel") {
                        onComplete()
                    }
                    .buttonStyle(.bordered)
                    
                    Spacer()
                    
                    if selectedWordsCount > 0 {
                        Button("Review & Import (\(selectedWordsCount))") {
                            showingBatchImport = true
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Text("Select words to import")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .opacity(0.2),
                alignment: .top
            )
        }
        .navigationTitle("Select Words")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingDeckSelection) {
            ImageImportDeckSelectionView(
                selectedDeckIds: $selectedDeckIds,
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $showingBatchImport) {
            BatchImportView(
                selectedWords: extractedWords.filter { $0.isSelected },
                selectedDeckIds: selectedDeckIds,
                viewModel: viewModel
            ) { importCount in
                importedCardsCount = importCount
                showingImportSuccess = true
                onComplete()
            }
        }
        .alert("Import Successful", isPresented: $showingImportSuccess) {
            Button("OK") {
                // Alert will dismiss automatically
            }
        } message: {
            Text("Successfully imported \(importedCardsCount) card\(importedCardsCount == 1 ? "" : "s") to your flashcard collection!")
        }
        .sheet(isPresented: Binding<Bool>(
            get: { editingWordIndex != nil },
            set: { if !$0 { editingWordIndex = nil } }
        )) {
            if let index = editingWordIndex, index < extractedWords.count {
                TranslationEditView(
                    word: extractedWords[index].text,
                    translation: $editingTranslation
                ) { newTranslation in
                    extractedWords[index].suggestedTranslation = newTranslation
                    editingWordIndex = nil
                }
            }
        }
        .onAppear {
            // Auto-select unknown words
            for index in extractedWords.indices {
                if !extractedWords[index].isKnownWord {
                    extractedWords[index].isSelected = true
                }
            }
            
            logger.debug("WordSelectionView appeared with \(extractedWords.count) words")
        }
    }
    
    private func binding(for word: ImageImportView.ExtractedWord) -> Binding<ImageImportView.ExtractedWord> {
        guard let index = extractedWords.firstIndex(where: { $0.id == word.id }) else {
            fatalError("Word not found in extractedWords")
        }
        
        return Binding(
            get: { extractedWords[index] },
            set: { extractedWords[index] = $0 }
        )
    }
    
    private func selectAllUnknown() {
        for index in extractedWords.indices {
            if !extractedWords[index].isKnownWord {
                extractedWords[index].isSelected = true
            }
        }
        HapticManager.shared.lightImpact()
    }
    
    private func selectAll() {
        for index in extractedWords.indices {
            extractedWords[index].isSelected = true
        }
        HapticManager.shared.lightImpact()
    }
    
    private func deselectAll() {
        for index in extractedWords.indices {
            extractedWords[index].isSelected = false
        }
        HapticManager.shared.lightImpact()
    }
}

struct WordSelectionRow: View {
    @Binding var word: ImageImportView.ExtractedWord
    let onTranslationEdit: (UUID) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button {
                word.isSelected.toggle()
                HapticManager.shared.lightImpact()
            } label: {
                Image(systemName: word.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(word.isSelected ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Word with status indicator
                HStack(spacing: 8) {
                    Text(word.text)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if word.isKnownWord {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    // Confidence indicator
                    if word.confidence < 0.8 {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                    
                    Spacer()
                }
                
                // Translation
                if word.isLoadingTranslation {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 14, height: 14)
                        
                        Text("Loading translation...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else if !word.suggestedTranslation.isEmpty {
                    HStack {
                        Text(word.suggestedTranslation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !word.isKnownWord {
                            Button("Edit") {
                                onTranslationEdit(word.id)
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                } else if !word.isKnownWord {
                    Button("Add translation") {
                        onTranslationEdit(word.id)
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                // Confidence score
                if word.confidence < 1.0 {
                    Text("Confidence: \(Int(word.confidence * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(word.isSelected ? Color.blue.opacity(0.1) : Color(UIColor.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            word.isSelected ? Color.blue : Color.gray.opacity(0.3),
                            lineWidth: word.isSelected ? 2 : 1
                        )
                )
        )
    }
}

struct ImageImportDeckSelectionView: View {
    @Binding var selectedDeckIds: Set<UUID>
    @ObservedObject var viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Select Decks") {
                    ForEach(viewModel.getSelectableDecks()) { deck in
                        Button(action: {
                            if selectedDeckIds.contains(deck.id) {
                                selectedDeckIds.remove(deck.id)
                            } else {
                                selectedDeckIds.insert(deck.id)
                            }
                        }) {
                            HStack {
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
                }
            }
            .navigationTitle("Select Decks")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Done") { dismiss() }
            )
        }
    }
}

struct TranslationEditView: View {
    let word: String
    @Binding var translation: String
    let onSave: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Edit Translation") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Word: \(word)")
                            .font(.headline)
                        
                        TextField("Translation", text: $translation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }
            .navigationTitle("Edit Translation")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") {
                    onSave(translation)
                    dismiss()
                }
                .disabled(translation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
}

struct BatchImportView: View {
    let selectedWords: [ImageImportView.ExtractedWord]
    let selectedDeckIds: Set<UUID>
    @ObservedObject var viewModel: FlashCardViewModel
    let onComplete: (Int) -> Void
    
    @State private var duplicateResults: [Int: FlashCardViewModel.DuplicateCheckResult] = [:]
    @State private var showingDuplicateSummary = false
    @State private var isProcessing = false
    @State private var importedCount = 0
    
    private let logger = Logger(subsystem: "com.flashcards", category: "BatchImportView")
    
    var body: some View {
        NavigationView {
            VStack {
                if isProcessing {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        
                        Text("Checking for duplicates...")
                            .font(.headline)
                        
                        Text("Analyzing \(selectedWords.count) words")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(selectedWords.enumerated()), id: \.element.id) { index, word in
                                ImportPreviewRow(word: word)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Import \(selectedWords.count) Words")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { onComplete(0) },
                trailing: Button("Import") {
                    checkForDuplicatesAndImport()
                }
                .disabled(isProcessing)
            )
        }
        .sheet(isPresented: $showingDuplicateSummary) {
            // Convert ExtractedWords to CardEntries for the duplicate summary
            let cardEntries = selectedWords.map { word in
                var entry = CardEntry()
                entry.word = word.text
                entry.definition = word.suggestedTranslation
                return entry
            }
            
            DuplicateSummaryView(
                viewModel: viewModel,
                cardEntries: cardEntries,
                duplicateResults: duplicateResults,
                selectedDeckIds: selectedDeckIds
            ) { finalEntries in
                importFinalWords(finalEntries)
                onComplete(importedCount)
            }
        }
    }
    
    private func checkForDuplicatesAndImport() {
        isProcessing = true
        duplicateResults.removeAll()
        
        for (index, word) in selectedWords.enumerated() {
            let result = viewModel.checkForDuplicateCard(
                word: word.text,
                definition: word.suggestedTranslation,
                example: "",
                article: "",
                plural: "",
                pastTense: "",
                futureTense: "",
                pastParticiple: ""
            )
            
            switch result {
            case .noDuplicate:
                break
            case .exactMatch, .partialMatch:
                duplicateResults[index] = result
            }
        }
        
        isProcessing = false
        
        if duplicateResults.isEmpty {
            // No duplicates, import directly
            importWordsDirectly()
            onComplete(importedCount)
        } else {
            // Show duplicate resolution
            showingDuplicateSummary = true
        }
    }
    
    private func importWordsDirectly() {
        importedCount = 0
        for word in selectedWords {
            if !word.suggestedTranslation.isEmpty {
                let _ = viewModel.addCard(
                    word: word.text,
                    definition: word.suggestedTranslation,
                    example: "",
                    deckIds: selectedDeckIds
                )
                importedCount += 1
            }
        }
        
        logger.debug("Imported \(importedCount) words directly out of \(selectedWords.count) selected")
    }
    
    private func importFinalWords(_ entries: [CardEntry]) {
        importedCount = 0
        for entry in entries {
            if !entry.definition.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let _ = viewModel.addCard(
                    word: entry.word,
                    definition: entry.definition,
                    example: entry.example,
                    deckIds: selectedDeckIds,
                    article: entry.article,
                    plural: entry.plural,
                    pastTense: entry.pastTense,
                    futureTense: entry.futureTense,
                    pastParticiple: entry.pastParticiple
                )
                importedCount += 1
            }
        }
        
        logger.debug("Imported \(importedCount) words after duplicate resolution out of \(entries.count) entries")
    }
}

struct ImportPreviewRow: View {
    let word: ImageImportView.ExtractedWord
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.text)
                    .font(.headline)
                
                if !word.suggestedTranslation.isEmpty {
                    Text(word.suggestedTranslation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                } else {
                    Text("No translation")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .italic()
                }
            }
            
            Spacer()
            
            if word.isKnownWord {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Known")
                        .font(.caption2)
                        .foregroundColor(.green)
                }
            } else {
                VStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                    Text("New")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let mockWords = [
        ImageImportView.ExtractedWord(
            text: "huis",
            boundingBox: CGRect.zero,
            confidence: 0.95,
            isSelected: true,
            isKnownWord: false,
            suggestedTranslation: "house"
        ),
        ImageImportView.ExtractedWord(
            text: "kat",
            boundingBox: CGRect.zero,
            confidence: 0.88,
            isSelected: false,
            isKnownWord: true,
            suggestedTranslation: "cat"
        )
    ]
    
    return WordSelectionView(
        image: UIImage(),
        extractedWords: .constant(mockWords),
        selectedDeckIds: .constant([]),
        viewModel: FlashCardViewModel()
    ) {
        print("Complete")
    }
} 