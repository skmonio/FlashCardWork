import Foundation

class FlashCardViewModel: ObservableObject {
    @Published var flashCards: [FlashCard] = [] {
        didSet {
            saveCards()
        }
    }
    
    private let userDefaultsKey = "SavedFlashCards"
    
    init() {
        loadCards()
    }
    
    func addCard(word: String, definition: String, example: String) {
        let newCard = FlashCard(word: word, definition: definition, example: example)
        flashCards.append(newCard)
    }
    
    func deleteCard(at indices: IndexSet) {
        flashCards.remove(atOffsets: indices)
    }
    
    private func saveCards() {
        if let encoded = try? JSONEncoder().encode(flashCards) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadCards() {
        if let savedCards = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedCards = try? JSONDecoder().decode([FlashCard].self, from: savedCards) {
            flashCards = decodedCards
        }
    }
} 