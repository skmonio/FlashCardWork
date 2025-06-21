import SwiftUI

struct DutchVocabularyImportView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @State private var selectedLevel: LanguageLevel = .a1
    @State private var selectedPacksA1: Set<UUID> = []
    @State private var selectedPacksA2: Set<UUID> = []
    @State private var selectedPacksB1: Set<UUID> = []
    @State private var showingImportSuccess = false
    @State private var importedWordCount = 0
    @State private var searchText = ""
    @State private var selectedCategory: VocabularyCategory? = nil
    @State private var showingPackDetails: DutchVocabularyPack? = nil
    @State private var importProgress: Double = 0
    @State private var isImporting = false
    
    private let database = DutchVocabularyDatabase.shared
    
    // Get the appropriate selection set for current level
    private var currentSelectedPacks: Binding<Set<UUID>> {
        switch selectedLevel {
        case .a1: return $selectedPacksA1
        case .a2: return $selectedPacksA2
        case .b1: return $selectedPacksB1
        }
    }
    
    private var allSelectedPacks: Set<UUID> {
        selectedPacksA1.union(selectedPacksA2).union(selectedPacksB1)
    }
    
    private var filteredPacks: [DutchVocabularyPack] {
        let levelPacks = database.getPacksByLevel(selectedLevel)
        
        var filtered = levelPacks
        
        // Filter by category if selected
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { pack in
                pack.name.localizedCaseInsensitiveContains(searchText) ||
                pack.description.localizedCaseInsensitiveContains(searchText) ||
                pack.words.contains { word in
                    word.word.localizedCaseInsensitiveContains(searchText) ||
                    word.definition.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
        
        return filtered
    }
    
    private var totalSelectedWords: Int {
        allSelectedPacks.compactMap { packId in
            database.allPacks.first { $0.id == packId }
        }.reduce(0) { $0 + $1.words.count }
    }
    
    private var availableCategories: [VocabularyCategory] {
        let levelPacks = database.getPacksByLevel(selectedLevel)
        return Array(Set(levelPacks.map { $0.category })).sorted { $0.rawValue < $1.rawValue }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar with X button
            HStack {
                Text("🇳🇱 Import Dutch Vocabulary")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search packs, categories, or words...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Level Selection Tabs
            HStack(spacing: 0) {
                ForEach(LanguageLevel.allCases, id: \.self) { level in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedLevel = level
                            selectedCategory = nil
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(level.rawValue)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("\(database.getWordsForLevel(level).count)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            
                            // Selection indicator
                            let selectedCount = getSelectedCountForLevel(level)
                            if selectedCount > 0 {
                                Text("\(selectedCount) selected")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedLevel == level ? Color.blue : Color.clear)
                        .foregroundColor(selectedLevel == level ? .white : .primary)
                    }
                }
            }
            .background(Color(.systemGray6))
            .padding(.top, 8)
            
            // Select All / Clear All
            HStack {
                Button("Select All") {
                    for pack in filteredPacks {
                        currentSelectedPacks.wrappedValue.insert(pack.id)
                    }
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Clear All") {
                    currentSelectedPacks.wrappedValue.removeAll()
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
            .padding()
            
            // Packs List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(filteredPacks, id: \.id) { pack in
                        CompactVocabularyPackCard(
                            pack: pack,
                            isSelected: currentSelectedPacks.wrappedValue.contains(pack.id)
                        ) {
                            // Toggle selection
                            if currentSelectedPacks.wrappedValue.contains(pack.id) {
                                currentSelectedPacks.wrappedValue.remove(pack.id)
                            } else {
                                currentSelectedPacks.wrappedValue.insert(pack.id)
                            }
                        } onDetails: {
                            showingPackDetails = pack
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Import Button (only when packs selected)
            if totalSelectedWords > 0 {
                VStack(spacing: 8) {
                    if isImporting {
                        ProgressView(value: importProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .padding(.horizontal)
                    }
                    
                    Button(action: importSelectedVocabulary) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("Import \(totalSelectedWords) Words")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isImporting)
                    .padding(.horizontal)
                }
                .padding(.bottom)
                .background(Color(.systemBackground))
            }
        }
        .alert("Import Successful! 🎉", isPresented: $showingImportSuccess) {
            Button("Continue Learning") {
                dismiss()
            }
        } message: {
            Text("Successfully imported \(importedWordCount) Dutch words organized into level-specific folders. Start studying now!")
        }
        .sheet(item: $showingPackDetails) { pack in
            VocabularyPackDetailView(pack: pack, isSelected: currentSelectedPacks.wrappedValue.contains(pack.id)) { isSelected in
                if isSelected {
                    currentSelectedPacks.wrappedValue.insert(pack.id)
                } else {
                    currentSelectedPacks.wrappedValue.remove(pack.id)
                }
            }
        }
    }
    
    private func getSelectedCountForLevel(_ level: LanguageLevel) -> Int {
        let packs = database.getPacksByLevel(level)
        let selectedSet: Set<UUID>
        
        switch level {
        case .a1: selectedSet = selectedPacksA1
        case .a2: selectedSet = selectedPacksA2
        case .b1: selectedSet = selectedPacksB1
        }
        
        return packs.filter { selectedSet.contains($0.id) }.count
    }
    
    private func categoryIcon(for category: VocabularyCategory) -> String {
        switch category {
        case .family: return "👨‍👩‍👧‍👦"
        case .food: return "🍎"
        case .home: return "🏠"
        case .work: return "💼"
        case .travel: return "✈️"
        case .time: return "⏰"
        case .weather: return "🌤️"
        case .body: return "👤"
        case .clothing: return "👕"
        case .animals: return "🐕"
        case .colors: return "🎨"
        case .numbers: return "🔢"
        case .verbs: return "⚡"
        case .adjectives: return "✨"
        case .emotions: return "😊"
        case .education: return "📚"
        case .technology: return "💻"
        case .sports: return "⚽"
        case .shopping: return "🛒"
        case .nature: return "🌿"
        // New A2-B1 Categories
        case .business: return "💼"
        case .medical: return "🏥"
        case .politics: return "🏛️"
        case .culture: return "🎭"
        case .media: return "📺"
        case .science: return "🔬"
        case .environment: return "🌱"
        case .finance: return "💰"
        case .relationships: return "❤️"
        case .personality: return "🧠"
        case .cooking: return "👨‍🍳"
        case .transportation: return "🚗"
        case .housing: return "🏘️"
        case .entertainment: return "🎬"
        case .crime: return "🚔"
        case .religion: return "⛪"
        case .geography: return "🌍"
        case .history: return "📜"
        case .law: return "⚖️"
        case .agriculture: return "🚜"
        case .construction: return "🏗️"
        case .automotive: return "🚙"
        case .telecommunications: return "📡"
        case .hospitality: return "🏨"
        case .retail: return "🛍️"
        case .logistics: return "📦"
        case .banking: return "🏦"
        case .insurance: return "🛡️"
        case .realEstate: return "🏢"
        case .energy: return "⚡"
        case .textiles: return "🧵"
        case .daily: return "📅"
        }
    }
    
    private func importSelectedVocabulary() {
        isImporting = true
        importProgress = 0
        
        let selectedPacksData = allSelectedPacks.compactMap { packId in
            database.allPacks.first { $0.id == packId }
        }
        
        let allWords = selectedPacksData.flatMap { $0.words }
        importedWordCount = allWords.count
        
        // Simulate import progress
        let totalSteps = Double(allWords.count)
        var currentStep = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            currentStep += 1
            importProgress = currentStep / totalSteps
            
            if currentStep >= totalSteps {
                timer.invalidate()
                
                // Group packs by level and create level-specific folders
                let packsByLevel = Dictionary(grouping: selectedPacksData) { $0.level }
                
                for (level, packs) in packsByLevel {
                    for pack in packs {
                        // Create folder name like "A1-Familie" or "B1-Technologie"
                        let folderName = "\(level.rawValue)-\(pack.category.rawValue)"
                        
                        // Create or find the deck
                        let deck: Deck
                        if let existingDeck = viewModel.decks.first(where: { $0.name == folderName }) {
                            deck = existingDeck
                        } else {
                            deck = viewModel.createDeck(name: folderName)
                        }
                        
                        // Add words to the deck
                        for word in pack.words {
                            viewModel.addCard(
                                word: word.word,
                                definition: word.definition,
                                example: word.example,
                                deckIds: Set([deck.id]),
                                article: word.article,
                                plural: word.plural,
                                pastTense: word.pastTense,
                                futureTense: word.futureTense,
                                pastParticiple: word.pastParticiple
                            )
                        }
                    }
                }
                
                isImporting = false
                // Clear all selections after successful import
                selectedPacksA1.removeAll()
                selectedPacksA2.removeAll()
                selectedPacksB1.removeAll()
                showingImportSuccess = true
            }
        }
    }
}

// MARK: - Supporting Views

private struct CompactVocabularyPackCard: View {
    let pack: DutchVocabularyPack
    let isSelected: Bool
    let onToggle: () -> Void
    let onDetails: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Selection checkbox
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .green : .gray)
                    .font(.title3)
            }
            
            // Pack icon
            Text(categoryIcon(for: pack.category))
                .font(.title2)
            
            // Pack info - tappable for details
            Button(action: onDetails) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(pack.name)
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text("\(pack.words.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Text(pack.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
    
    private func categoryIcon(for category: VocabularyCategory) -> String {
        switch category {
        case .family: return "👨‍👩‍👧‍👦"
        case .food: return "🍎"
        case .home: return "🏠"
        case .work: return "💼"
        case .travel: return "✈️"
        case .time: return "⏰"
        case .weather: return "🌤️"
        case .body: return "👤"
        case .clothing: return "👕"
        case .animals: return "🐕"
        case .colors: return "🎨"
        case .numbers: return "🔢"
        case .verbs: return "⚡"
        case .adjectives: return "✨"
        case .emotions: return "😊"
        case .education: return "📚"
        case .technology: return "💻"
        case .sports: return "⚽"
        case .shopping: return "🛒"
        case .nature: return "🌿"
        // New A2-B1 Categories
        case .business: return "💼"
        case .medical: return "🏥"
        case .politics: return "🏛️"
        case .culture: return "🎭"
        case .media: return "📺"
        case .science: return "🔬"
        case .environment: return "🌱"
        case .finance: return "💰"
        case .relationships: return "❤️"
        case .personality: return "🧠"
        case .cooking: return "👨‍🍳"
        case .transportation: return "🚗"
        case .housing: return "🏘️"
        case .entertainment: return "🎬"
        case .crime: return "🚔"
        case .religion: return "⛪"
        case .geography: return "🌍"
        case .history: return "📜"
        case .law: return "⚖️"
        case .agriculture: return "🚜"
        case .construction: return "🏗️"
        case .automotive: return "🚙"
        case .telecommunications: return "📡"
        case .hospitality: return "🏨"
        case .retail: return "🛍️"
        case .logistics: return "📦"
        case .banking: return "🏦"
        case .insurance: return "🛡️"
        case .realEstate: return "🏢"
        case .energy: return "⚡"
        case .textiles: return "🧵"
        case .daily: return "📅"
        }
    }
}

private struct VocabularyPackDetailView: View {
    let pack: DutchVocabularyPack
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Pack Header
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(categoryIcon(for: pack.category))
                                .font(.largeTitle)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pack.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("\(pack.words.count) words • \(pack.level.rawValue) Level")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Text(pack.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Word List
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Words in this pack:")
                            .font(.headline)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(pack.words.prefix(20), id: \.word) { word in
                                WordPreviewCard(word: word)
                            }
                            
                            if pack.words.count > 20 {
                                Text("... and \(pack.words.count - 20) more words")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding()
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Pack Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isSelected ? "Remove" : "Add Pack") {
                        onToggle(!isSelected)
                        dismiss()
                    }
                    .foregroundColor(isSelected ? .red : .blue)
                }
            }
        }
    }
    
    private func categoryIcon(for category: VocabularyCategory) -> String {
        switch category {
        case .family: return "👨‍👩‍👧‍👦"
        case .food: return "🍎"
        case .home: return "🏠"
        case .work: return "💼"
        case .travel: return "✈️"
        case .time: return "⏰"
        case .weather: return "🌤️"
        case .body: return "👤"
        case .clothing: return "👕"
        case .animals: return "🐕"
        case .colors: return "🎨"
        case .numbers: return "🔢"
        case .verbs: return "⚡"
        case .adjectives: return "✨"
        case .emotions: return "😊"
        case .education: return "📚"
        case .technology: return "💻"
        case .sports: return "⚽"
        case .shopping: return "🛒"
        case .nature: return "🌿"
        // New A2-B1 Categories
        case .business: return "💼"
        case .medical: return "🏥"
        case .politics: return "🏛️"
        case .culture: return "🎭"
        case .media: return "📺"
        case .science: return "🔬"
        case .environment: return "🌱"
        case .finance: return "💰"
        case .relationships: return "❤️"
        case .personality: return "🧠"
        case .cooking: return "👨‍🍳"
        case .transportation: return "🚗"
        case .housing: return "🏘️"
        case .entertainment: return "🎬"
        case .crime: return "🚔"
        case .religion: return "⛪"
        case .geography: return "🌍"
        case .history: return "📜"
        case .law: return "⚖️"
        case .agriculture: return "🚜"
        case .construction: return "🏗️"
        case .automotive: return "🚙"
        case .telecommunications: return "📡"
        case .hospitality: return "🏨"
        case .retail: return "🛍️"
        case .logistics: return "📦"
        case .banking: return "🏦"
        case .insurance: return "🛡️"
        case .realEstate: return "🏢"
        case .energy: return "⚡"
        case .textiles: return "🧵"
        case .daily: return "📅"
        }
    }
}

private struct WordPreviewCard: View {
    let word: DutchWord
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if !word.article.isEmpty {
                        Text(word.article)
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    Text(word.word)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Spacer()
                }
                
                Text(word.definition)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(word.example)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
            
            Spacer()
            
            Text(word.wordType.rawValue)
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.systemGray5))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
} 