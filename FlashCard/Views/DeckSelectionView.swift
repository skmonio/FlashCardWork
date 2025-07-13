import SwiftUI

// MARK: - Memory Game Difficulty Enum
enum MemoryGameDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var description: String {
        switch self {
        case .easy: return "No time pressure"
        case .medium: return "4 seconds per set"
        case .hard: return "2 seconds per set"
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "tortoise.fill"
        case .medium: return "hare.fill"
        case .hard: return "bolt.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
    
    var timePerCardSet: Int {
        switch self {
        case .easy: return 0
        case .medium: return 2
        case .hard: return 1
        }
    }
}

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: GameMode
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingSaveOverwriteWarning = false
    @State private var selectedStudyMode: StudyMode = .adaptive
    @State private var selectedDifficulty: MemoryGameDifficulty = .medium
    @State private var showingDeckPicker = false
    
    // Info popup states
    @State private var showingStudyInfo = false
    @State private var showingTestInfo = false
    @State private var showingTrueFalseInfo = false
    @State private var showingWritingInfo = false
    @State private var showingMemoryGameInfo = false
    @State private var showingWordScrambleInfo = false
    @State private var startFlipped = false // NEW: for study flipped
    
    enum GameMode: String {
        case study = "study"
        case test = "test" 
        case game = "game"
        case truefalse = "truefalse"
        case writing = "writing"
        case wordScramble = "wordScramble"
        
        var title: String {
            switch self {
            case .study: return "Study Cards"
            case .test: return "Test Mode"
            case .game: return "Memory Game"
            case .truefalse: return "True or False"
            case .writing: return "Write Your Card"
            case .wordScramble: return "Jumble Your Cards"
            }
        }
        
        var saveStateType: GameSaveState.SavedGameType {
            switch self {
            case .study: return .study
            case .test: return .test
            case .game: return .memoryGame
            case .truefalse: return .trueFalse
            case .writing: return .writing
            case .wordScramble: return .wordScramble
            }
        }
    }
    
    var availableCards: [FlashCard] {
        if selectedDeckIds.isEmpty {
            return []
        }
        var uniqueCards: Set<FlashCard> = []
        for deckId in selectedDeckIds {
            if let deck = viewModel.decks.first(where: { $0.id == deckId }) {
                uniqueCards.formUnion(deck.cards)
            }
        }
        let total = Array(uniqueCards)
        guard !total.isEmpty else { return [] }
        
        switch selectedStudyMode {
        case .adaptive:
            // Check if this is a new deck (most cards have 0% learning)
            let unstudiedCards = total.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage == 0 && card.timesShown == 0
            }
            
            // If more than 70% of cards are unstudied, show all cards to establish baseline
            if Double(unstudiedCards.count) / Double(total.count) > 0.7 {
                return total
            }
            
            // For established decks, use adaptive filtering
            let strugglingCards = total.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage < 70 || card.consecutiveIncorrect > 0
            }
            
            // If we have enough struggling cards, use them. Otherwise, use all cards but prioritize struggling ones
            if strugglingCards.count >= Int(Double(total.count) * 0.3) {
                return Array(strugglingCards.prefix(Int(Double(total.count) * 0.3)))
            } else {
                // Sort by adaptive score and take top 30%
                let sortedCards = SmartStudyManager.shared.sortCardsForStudyMode(total, mode: .adaptive)
                return Array(sortedCards.prefix(Int(Double(total.count) * 0.3)))
            }
            
        case .cram:
            // For cram mode, use all cards
            return total
            
        case .maintenance:
            // For maintenance mode, only include cards that are learned but need maintenance (70-90% learning percentage)
            let maintenanceCards = total.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage >= 70 && percentage <= 90
            }
            
            // If we have enough maintenance cards, use them. Otherwise, use all cards but prioritize maintenance ones
            if maintenanceCards.count >= Int(Double(total.count) * 0.7) {
                return Array(maintenanceCards.prefix(Int(Double(total.count) * 0.7)))
            } else {
                // Sort by maintenance score and take top 70%
                let sortedCards = SmartStudyManager.shared.sortCardsForStudyMode(total, mode: .maintenance)
                return Array(sortedCards.prefix(Int(Double(total.count) * 0.7)))
            }
        }
    }
    
    var hasSaveState: Bool {
        return SaveStateManager.shared.hasSaveState(gameType: mode.saveStateType)
    }
    
    var selectedDeckNames: String {
        if selectedDeckIds.isEmpty {
            return "No decks selected"
        }
        let names = viewModel.decks
            .filter { selectedDeckIds.contains($0.id) }
            .map { $0.name }
        return names.joined(separator: ", ")
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Quick Start Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Quick Start")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Number of Cards:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                // Show filtered count vs total count
                                let totalCards = selectedDeckIds.isEmpty ? 0 : viewModel.decks
                                    .filter { selectedDeckIds.contains($0.id) }
                                    .reduce(0) { $0 + $1.cards.count }
                                
                                Text("\(availableCards.count) of \(totalCards)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                
                                // Add study mode info
                                Text(selectedStudyMode.displayName)
                                    .font(.caption)
                                    .foregroundColor(selectedStudyMode.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(selectedStudyMode.color.opacity(0.1))
                                    .cornerRadius(4)
                            }
                            Spacer()
                            Button(action: {
                                handleStartGame()
                            }) {
                                Text("Start")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                            .disabled(availableCards.isEmpty)
                        }
                        // NEW: Start Flipped toggle
                        if mode == .study {
                            Toggle(isOn: $startFlipped) {
                                Label("Start Flipped", systemImage: "arrow.2.circlepath")
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Deck Selection Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Deck Selection")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Button(action: {
                            showingDeckPicker = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Selected Decks:")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text(selectedDeckNames)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                        .lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // Game Mode Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text(mode == .game ? "Difficulty" : "Game Mode")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if mode == .game {
                            // Memory Game Difficulty Options
                            HStack(spacing: 12) {
                                ForEach(MemoryGameDifficulty.allCases, id: \.self) { difficulty in
                                    DeckSelectionDifficultyButton(
                                        difficulty: difficulty,
                                        isSelected: selectedDifficulty == difficulty,
                                        action: { selectedDifficulty = difficulty }
                                    )
                                }
                            }
                        } else {
                            // Study Mode Options (for other game types)
                            HStack(spacing: 12) {
                                ForEach(StudyMode.allCases, id: \.self) { studyMode in
                                    Button(action: {
                                        selectedStudyMode = studyMode
                                    }) {
                                        VStack(spacing: 8) {
                                            Image(systemName: studyMode.icon)
                                                .font(.title2)
                                                .foregroundColor(selectedStudyMode == studyMode ? studyMode.color : .gray)
                                            
                                            Text(studyMode.displayName)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(selectedStudyMode == studyMode ? studyMode.color : .gray)
                                                .multilineTextAlignment(.center)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(selectedStudyMode == studyMode ? studyMode.color.opacity(0.1) : Color(.systemGray6))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .stroke(selectedStudyMode == studyMode ? studyMode.color : Color.clear, lineWidth: 2)
                                                )
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    
                    // Start Button
                    Button(action: {
                        handleStartGame()
                    }) {
                        Text("Start")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(availableCards.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(availableCards.isEmpty)
                }
                .padding()
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    UnifiedBackButton(style: .toolbar) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showInfoPopup()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "questionmark.circle")
                                .font(.caption)
                            Text("How to Play")
                                .font(.caption)
                        }
                        .foregroundColor(.blue)
                    }
                }
            }
            
            NavigationLink(
                destination: destinationView,
                isActive: $shouldStartGame
            ) {
                EmptyView()
            }
            .opacity(0)
            .frame(height: 0)
        }
        .sheet(isPresented: $showingDeckPicker) {
            DeckPickerView(
                viewModel: viewModel,
                selectedDeckIds: $selectedDeckIds
            )
        }
        .alert("Overwrite Saved Game?", isPresented: $showingSaveOverwriteWarning) {
            Button("Start New Game", role: .destructive) {
                HapticManager.shared.lightImpact()
                SaveStateManager.shared.deleteSaveState(gameType: mode.saveStateType)
                shouldContinueGame = false
                shouldStartGame = true
            }
            Button("Continue from saved game") {
                HapticManager.shared.lightImpact()
                shouldContinueGame = true
                shouldStartGame = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Starting a new game will overwrite your current saved progress. Are you sure you want to continue?")
        }
        .sheet(isPresented: $showingStudyInfo) {
            StudyInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingTestInfo) {
            TestInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingTrueFalseInfo) {
            TrueFalseInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingWritingInfo) {
            WritingInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingMemoryGameInfo) {
            MemoryGameInfoView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingWordScrambleInfo) {
            WordScrambleInfoView(viewModel: viewModel)
        }
        .onAppear {
            shouldStartGame = false
            shouldContinueGame = false
            showingSaveOverwriteWarning = false
            
            if isFirstVisit(for: mode) {
                showInfoPopup()
                markAsVisited(for: mode)
            }
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        let deckIdArray = Array(selectedDeckIds)
        
        if shouldContinueGame {
            // Load saved state for continue game
            switch mode {
            case .study:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .study, as: StudyGameState.self) {
                    StudyView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: true,
                        startFlipped: startFlipped
                    )
                } else {
                    // Fallback if no save state found
                    StudyView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: false,
                        startFlipped: startFlipped
                    )
                }
            case .test:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .test, as: TestGameState.self) {
                    TestView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    TestView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: false
                    )
                }
            case .game:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .memoryGame, as: MemoryGameState.self) {
                    // For memory game, we need to reconstruct the cards from the saved state
                    let allCards = savedState.gameCards.compactMap { savedCard in
                        // Find the original card in the viewModel
                        viewModel.flashCards.first { $0.id == savedCard.originalCardId }
                    }
                    GameView(
                        viewModel: viewModel,
                        cards: allCards,
                        difficulty: selectedDifficulty,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    GameView(
                        viewModel: viewModel,
                        cards: availableCards,
                        difficulty: selectedDifficulty,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: false
                    )
                }
            case .truefalse:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .trueFalse, as: TrueFalseGameState.self) {
                    TrueFalseView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    TrueFalseView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: false
                    )
                }
            case .writing:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .writing, as: WritingGameState.self) {
                    WritingView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    WritingView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: false
                    )
                }
            case .wordScramble:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .wordScramble, as: WordScrambleGameState.self) {
                    WordScrambleView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    WordScrambleView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: deckIdArray,
                        shouldLoadSaveState: false
                    )
                }
            }
        } else {
            // Normal new game logic
            switch mode {
            case .study:
                StudyView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: deckIdArray,
                    shouldLoadSaveState: false,
                    startFlipped: startFlipped
                )
            case .test:
                TestView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: deckIdArray,
                    shouldLoadSaveState: false
                )
            case .game:
                GameView(
                    viewModel: viewModel,
                    cards: availableCards,
                    difficulty: selectedDifficulty,
                    deckIds: deckIdArray,
                    shouldLoadSaveState: false
                )
            case .truefalse:
                TrueFalseView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: deckIdArray,
                    shouldLoadSaveState: false
                )
            case .writing:
                WritingView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: deckIdArray,
                    shouldLoadSaveState: false
                )
            case .wordScramble:
                WordScrambleView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: deckIdArray,
                    shouldLoadSaveState: false
                )
            }
        }
    }
    
    private func handleStartGame() {
        HapticManager.shared.lightImpact()
        
        let hasExistingSave = hasSaveState
        
        if hasExistingSave {
            showingSaveOverwriteWarning = true
        } else {
            shouldContinueGame = false
            shouldStartGame = true
        }
    }
    
    private func isFirstVisit(for mode: GameMode) -> Bool {
        let key = "hasVisited_\(mode.rawValue)"
        return !UserDefaults.standard.bool(forKey: key)
    }
    
    private func markAsVisited(for mode: GameMode) {
        let key = "hasVisited_\(mode.rawValue)"
        UserDefaults.standard.set(true, forKey: key)
    }
    
    private func showInfoPopup() {
        switch mode {
        case .study:
            showingStudyInfo = true
        case .test:
            showingTestInfo = true
        case .truefalse:
            showingTrueFalseInfo = true
        case .writing:
            showingWritingInfo = true
        case .game:
            showingMemoryGameInfo = true
        case .wordScramble:
            showingWordScrambleInfo = true
        }
    }
}

// MARK: - Deck Picker View
struct DeckPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    @Binding var selectedDeckIds: Set<UUID>
    
    var body: some View {
        NavigationStack {
            List {
                // Select All / Cancel Selection Section
                Section {
                    Button(action: {
                        // Select all decks
                            selectedDeckIds = Set(viewModel.getAllDecksHierarchical().map { $0.id })
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                            Text("Select All Decks")
                                .font(.body)
                                .foregroundColor(.blue)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        // Clear all deck selections
                        selectedDeckIds.removeAll()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                            Text("Cancel Selection")
                                .font(.body)
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    }
                    
                // Deck List Section
                Section(header: Text("Select Decks")) {
                    ForEach(viewModel.getAllDecksHierarchical()) { deck in
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
                                Text("\(deck.cards.count)")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(.primary)
                    }
                }
            }
            .navigationTitle("Select Decks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Wrapper Views for Save State Integration
struct StudyViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    let selectedStudyMode: StudyMode
    let startFlipped: Bool // NEW
    var body: some View {
        Group {
            if shouldContinue {
                StudyView(
                    viewModel: viewModel,
                    cards: cards,
                    deckIds: deckIds,
                    shouldLoadSaveState: true,
                    startFlipped: startFlipped // pass
                )
            } else {
                StudyView(
                    viewModel: viewModel,
                    cards: cards,
                    deckIds: deckIds,
                    shouldLoadSaveState: false,
                    startFlipped: startFlipped // pass
                )
            }
        }
        .onAppear {
            if !shouldContinue {
                SmartStudyManager.shared.startStudySession(mode: selectedStudyMode)
            }
        }
    }
}

struct TestViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        TestView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
    }
}

struct GameViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    let difficulty: MemoryGameDifficulty
    
    var body: some View {
        Group {
            if shouldContinue {
                GameView(
                    viewModel: viewModel, 
                    cards: cards,
                    difficulty: difficulty,
                    deckIds: deckIds,
                    shouldLoadSaveState: true
                )
            } else {
                GameView(
                    viewModel: viewModel,
                    cards: cards,
                    difficulty: difficulty,
                    deckIds: deckIds,
                    shouldLoadSaveState: false
                )
            }
        }
    }
}

struct TrueFalseViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        TrueFalseView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
    }
}

struct WritingViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        WritingView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
    }
}

struct WordScrambleViewWithSaveState: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let cards: [FlashCard]
    let deckIds: [UUID]
    let shouldContinue: Bool
    
    var body: some View {
        WordScrambleView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
    }
}

// MARK: - Helper Views

struct DeckSelectionDifficultyButton: View {
    let difficulty: MemoryGameDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: difficulty.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? difficulty.color : .gray)
                
                Text(difficulty.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? difficulty.color : .gray)
                    .multilineTextAlignment(.center)
                
                Text(difficulty.description)
                    .font(.caption2)
                    .foregroundColor(isSelected ? difficulty.color : .gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.vertical, 12)
            .background(backgroundView)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isSelected ? difficulty.color.opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? difficulty.color : Color.clear, lineWidth: 2)
        )
    }
} 