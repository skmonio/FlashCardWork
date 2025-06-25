import SwiftUI

struct QuickStudyView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    let gameMode: GameMode
    let selectedStudyMode: StudyMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @State private var selectedCardCount: Int = 10
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
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        
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
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Starting a new game will overwrite your current saved progress. Are you sure you want to continue?")
        }
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch gameMode {
        case .study:
            StudyView(
                viewModel: viewModel,
                cards: availableCards,
                deckIds: [], // Empty for quick study
                shouldLoadSaveState: shouldContinueGame
            )
        case .test:
            TestView(
                viewModel: viewModel,
                cards: availableCards,
                deckIds: [],
                shouldLoadSaveState: shouldContinueGame
            )
        case .game:
            GameView(
                viewModel: viewModel,
                cards: availableCards,
                deckIds: [],
                shouldLoadSaveState: shouldContinueGame
            )
        case .truefalse:
            TrueFalseView(
                viewModel: viewModel,
                cards: availableCards,
                deckIds: [],
                shouldLoadSaveState: shouldContinueGame
            )
        case .writing:
            WritingView(
                viewModel: viewModel,
                cards: availableCards,
                deckIds: [],
                shouldLoadSaveState: shouldContinueGame
            )
        case .wordScramble:
            WordScrambleView(
                viewModel: viewModel,
                cards: availableCards,
                deckIds: [],
                shouldLoadSaveState: shouldContinueGame
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
} 