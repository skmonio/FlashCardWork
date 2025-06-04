import Foundation

class FlashCardViewModel: ObservableObject {
    @Published var flashCards: [FlashCard] = []
    
    func addCard(word: String, definition: String, example: String) {
        let newCard = FlashCard(word: word, definition: definition, example: example)
        flashCards.append(newCard)
    }
    
    func deleteCard(at indices: IndexSet) {
        flashCards.remove(atOffsets: indices)
    }
} 