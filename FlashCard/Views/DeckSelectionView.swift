import SwiftUI

struct DeckSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: FlashCardViewModel
    let mode: GameMode
    @State private var selectedDeckIds: Set<UUID> = []
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingSaveOverwriteWarning = false
    @State private var selectedStudyMode: StudyMode = .adaptive
    @State private var showingDeckPicker = false
    
    // Info popup states
    @State private var showingStudyInfo = false
    @State private var showingTestInfo = false
    @State private var showingTrueFalseInfo = false
    @State private var showingWritingInfo = false
    @State private var showingMemoryGameInfo = false
    @State private var showingWordScrambleInfo = false
    
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
        return Array(uniqueCards)
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
                                Text("\(availableCards.count)")
                                    .font(.title)
                                    .fontWeight(.bold)
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
                        Text("Game Mode")
                            .font(.title2)
                            .fontWeight(.bold)
                        
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
                    Button("Back") {
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
        
        switch mode {
        case .study:
            StudyViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame,
                selectedStudyMode: selectedStudyMode
            )
        case .test:
            TestViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .game:
            GameViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .truefalse:
            TrueFalseViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .writing:
            WritingViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
        case .wordScramble:
            WordScrambleViewWithSaveState(
                viewModel: viewModel, 
                cards: availableCards,
                deckIds: deckIdArray,
                shouldContinue: shouldContinueGame
            )
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
                Section(header: Text("Select Decks")) {
                    Button(action: {
                        if !selectedDeckIds.isEmpty {
                            selectedDeckIds.removeAll()
                        } else {
                            selectedDeckIds = Set(viewModel.getAllDecksHierarchical().map { $0.id })
                        }
                    }) {
                        HStack {
                            Text(selectedDeckIds.isEmpty ? "Select All Decks" : "Deselect All")
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(selectedDeckIds.count) selected")
                                .foregroundColor(.secondary)
                        }
                    }
                    
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
    
    var body: some View {
        Group {
            if shouldContinue {
                StudyView(
                    viewModel: viewModel, 
                    cards: cards,
                    deckIds: deckIds,
                    shouldLoadSaveState: true
                )
            } else {
                StudyView(
                    viewModel: viewModel,
                    cards: cards,
                    deckIds: deckIds,
                    shouldLoadSaveState: false
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
    
    var body: some View {
        GameView(
            viewModel: viewModel, 
            cards: cards,
            deckIds: deckIds,
            shouldLoadSaveState: shouldContinue
        )
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