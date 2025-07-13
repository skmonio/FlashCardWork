import SwiftUI

struct QuickStudyView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let gameMode: GameMode
    let selectedStudyMode: StudyMode
    let startFlipped: Bool // NEW: for study flipped
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedCardCount: Int = 10
    @State private var selectedDifficulty: MemoryGameDifficulty = .medium
    @State private var shouldStartGame = false
    @State private var shouldContinueGame = false
    @State private var showingSaveOverwriteWarning = false
    
    var allCards: [FlashCard] {
        var uniqueCards: Set<FlashCard> = []
        for deck in viewModel.decks {
            uniqueCards.formUnion(deck.cards)
        }
        return Array(uniqueCards)
    }
    
    var availableCards: [FlashCard] {
        let total = allCards
        guard !total.isEmpty else { return [] }
        
        // Simply return the user's selected number of cards randomly
        return Array(total.shuffled().prefix(selectedCardCount))
    }
    
    var cardCountOptions: [Int] {
        return [5, 10, 15, 20, 25, 30]
    }
    
    var hasSaveState: Bool {
        return SaveStateManager.shared.hasSaveState(gameType: gameMode.saveStateType)
    }
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Text("Quick Study")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Select how many cards to study")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)
            
            // Card Count Selection
            VStack(spacing: 20) {
                // Card Count Buttons
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(cardCountOptions, id: \.self) { count in
                        Button(action: {
                            selectedCardCount = count
                        }) {
                            Text("\(count)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedCardCount == count ? .white : .blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedCardCount == count ? Color.blue : Color.blue.opacity(0.1))
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            // Difficulty Selection (only for memory game)
            if gameMode == .game {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(MemoryGameDifficulty.allCases, id: \.self) { difficulty in
                            Button(action: {
                                selectedDifficulty = difficulty
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: difficulty.icon)
                                        .font(.title3)
                                        .foregroundColor(selectedDifficulty == difficulty ? difficulty.color : .gray)
                                    
                                    Text(difficulty.displayName)
                                        .font(.caption2)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedDifficulty == difficulty ? difficulty.color : .gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(selectedDifficulty == difficulty ? difficulty.color.opacity(0.1) : Color(.systemGray6))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 6)
                                                .stroke(selectedDifficulty == difficulty ? difficulty.color : Color.clear, lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // Difficulty Summary
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty Summary:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: selectedDifficulty.icon)
                                    .font(.caption)
                                    .foregroundColor(selectedDifficulty.color)
                                Text(selectedDifficulty.displayName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(selectedDifficulty.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(getDifficultyDescription())
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        .padding(8)
                        .background(selectedDifficulty.color.opacity(0.05))
                        .cornerRadius(6)
                    }
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            // Start Button
            Button(action: {
                handleStartGame()
            }) {
                Text("Start Quick Study")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(availableCards.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(availableCards.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .navigationTitle("Quick Study")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                UnifiedBackButton(style: .toolbar) {
                    navigationCoordinator.pop()
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
        .alert("Overwrite Saved Game?", isPresented: $showingSaveOverwriteWarning) {
            Button("Start New Game", role: .destructive) {
                HapticManager.shared.lightImpact()
                SaveStateManager.shared.deleteSaveState(gameType: gameMode.saveStateType)
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
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if shouldContinueGame {
            // Load saved state for continue game
            switch gameMode {
            case .study:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .study, as: StudyGameState.self) {
                    StudyView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: [],
                        shouldLoadSaveState: true,
                        startFlipped: startFlipped
                    )
                } else {
                    // Fallback if no save state found
                    StudyView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: [],
                        shouldLoadSaveState: false,
                        startFlipped: startFlipped
                    )
                }
            case .test:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .test, as: TestGameState.self) {
                    TestView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: [],
                        shouldLoadSaveState: true,
                        startFlipped: startFlipped
                    )
                } else {
                    // Fallback if no save state found
                    TestView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: [],
                        shouldLoadSaveState: false,
                        startFlipped: startFlipped
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
                        deckIds: [],
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    GameView(
                        viewModel: viewModel,
                        cards: availableCards,
                        difficulty: selectedDifficulty,
                        deckIds: [],
                        shouldLoadSaveState: false
                    )
                }
            case .truefalse:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .trueFalse, as: TrueFalseGameState.self) {
                    TrueFalseView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: [],
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    TrueFalseView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: [],
                        shouldLoadSaveState: false
                    )
                }
            case .writing:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .writing, as: WritingGameState.self) {
                    WritingView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: [],
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    WritingView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: [],
                        shouldLoadSaveState: false
                    )
                }
            case .wordScramble:
                if let savedState = SaveStateManager.shared.loadGameState(gameType: .wordScramble, as: WordScrambleGameState.self) {
                    WordScrambleView(
                        viewModel: viewModel,
                        cards: savedState.cards,
                        deckIds: [],
                        shouldLoadSaveState: true
                    )
                } else {
                    // Fallback if no save state found
                    WordScrambleView(
                        viewModel: viewModel,
                        cards: availableCards,
                        deckIds: [],
                        shouldLoadSaveState: false
                    )
                }
            }
        } else {
            // Normal new game logic
            switch gameMode {
            case .study:
                StudyView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: [],
                    shouldLoadSaveState: false,
                    startFlipped: startFlipped
                )
            case .test:
                TestView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: [],
                    shouldLoadSaveState: false,
                    startFlipped: startFlipped
                )
            case .game:
                GameView(
                    viewModel: viewModel,
                    cards: availableCards,
                    difficulty: selectedDifficulty,
                    deckIds: [],
                    shouldLoadSaveState: false
                )
            case .truefalse:
                TrueFalseView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: [],
                    shouldLoadSaveState: false
                )
            case .writing:
                WritingView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: [],
                    shouldLoadSaveState: false
                )
            case .wordScramble:
                WordScrambleView(
                    viewModel: viewModel,
                    cards: availableCards,
                    deckIds: [],
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
    
    // MARK: - Difficulty Helpers
    
    private func getDifficultyDescription() -> String {
        switch selectedDifficulty {
        case .easy:
            return "Take your time, no pressure"
        case .medium:
            return "Balanced challenge for most players"
        case .hard:
            return "Quick thinking required"
        }
    }
} 