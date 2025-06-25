import SwiftUI
import Combine

// MARK: - Navigation Coordinator
class NavigationCoordinator: ObservableObject {
    static let shared = NavigationCoordinator()
    
    // MARK: - Published Properties
    @Published var currentTab: BottomNavigationView.TabItem = .home
    @Published var navigationPath = NavigationPath()
    @Published var presentedSheet: SheetType?
    @Published var showingAlert: AlertType?
    
    // MARK: - Navigation State
    @Published var shouldDismissToRoot = false
    
    private init() {}
    
    // MARK: - Sheet Types
    enum SheetType: Identifiable {
        case addCard(deck: Deck? = nil)
        case addDeck
        case imageImport
        case editCard(FlashCard)
        case moveCards([UUID], Deck?)
        case settings
        case savedGames
        case exportImport
        case gameInfo(GameInfoType)
        case cardsInfo
        case dutchGrammarInfo
        
        var id: String {
            switch self {
            case .addCard: return "addCard"
            case .addDeck: return "addDeck"
            case .imageImport: return "imageImport"
            case .editCard: return "editCard"
            case .moveCards: return "moveCards"
            case .settings: return "settings"
            case .savedGames: return "savedGames"
            case .exportImport: return "exportImport"
            case .gameInfo: return "gameInfo"
            case .cardsInfo: return "cardsInfo"
            case .dutchGrammarInfo: return "dutchGrammarInfo"
            }
        }
    }
    
    enum GameInfoType {
        case study, test, truefalse, writing, memoryGame, wordScramble
    }
    
    // MARK: - Alert Types
    enum AlertType: Identifiable {
        case deleteCard(FlashCard)
        case deleteDeck(Deck)
        case resetStats
        case closeGame(hasProgress: Bool)
        
        var id: String {
            switch self {
            case .deleteCard: return "deleteCard"
            case .deleteDeck: return "deleteDeck"
            case .resetStats: return "resetStats"
            case .closeGame: return "closeGame"
            }
        }
    }
    
    // MARK: - Navigation Methods
    func navigate(to tab: BottomNavigationView.TabItem) {
        currentTab = tab
    }
    
    func presentSheet(_ sheet: SheetType) {
        presentedSheet = sheet
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func showAlert(_ alert: AlertType) {
        showingAlert = alert
    }
    
    func dismissToRoot() {
        shouldDismissToRoot = true
        navigationPath = NavigationPath()
        presentedSheet = nil
        showingAlert = nil
        
        // Reset flag after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldDismissToRoot = false
        }
    }
    
    func push<T: Hashable>(_ value: T) {
        navigationPath.append(value)
    }
    
    func pop() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }
    
    func reset() {
        currentTab = .home
        navigationPath = NavigationPath()
        presentedSheet = nil
        showingAlert = nil
        shouldDismissToRoot = false
    }
}

// MARK: - Game Mode Enum
enum GameMode: String, CaseIterable {
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
    
    var gameInfoType: NavigationCoordinator.GameInfoType {
        switch self {
        case .study:
            return .study
        case .test:
            return .test
        case .truefalse:
            return .truefalse
        case .writing:
            return .writing
        case .game:
            return .memoryGame
        case .wordScramble:
            return .wordScramble
        }
    }
}

// MARK: - Navigation Destination Enum
enum NavigationDestination: Hashable {
    case deckSelection(GameMode)
    case studyModeSelection(GameMode)
    case studyTypeSelection(GameMode, StudyMode)
    case quickStudy(GameMode, StudyMode, Int)
    case normalStudy(GameMode, StudyMode)
    case deck(Deck)
    case allCards
    case manageDecks
    case studyView([FlashCard], [UUID])
    case testView([FlashCard], [UUID])
    case gameView([FlashCard], [UUID])
    case trueFalseView([FlashCard], [UUID])
    case writingView([FlashCard], [UUID])
    case wordScrambleView([FlashCard], [UUID])
    case dutchVocabulary
    case dutchGrammar
}

// MARK: - Simplified Navigation Extensions
extension View {
    func withNavigationCoordinator() -> some View {
        self.environmentObject(NavigationCoordinator.shared)
    }
    
    func handleDismissToRoot() -> some View {
        self.onReceive(NavigationCoordinator.shared.$shouldDismissToRoot) { shouldDismiss in
            if shouldDismiss {
                // The navigation path clearing is handled in dismissToRoot()
                // This is just for any additional cleanup if needed
            }
        }
    }
} 