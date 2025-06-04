import Foundation

class FlashCardViewModel: ObservableObject {
    @Published var flashCards: [FlashCard] = [] {
        didSet {
            saveCards()
        }
    }
    
    private let userDefaultsKey = "SavedFlashCards"
    
    init() {
        loadSampleCards()
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
    
    private func loadSampleCards() {
        let sampleCards = [
            ("Huis", "House", "Ik woon in een groot huis - I live in a big house"),
            ("Kat", "Cat", "De kat slaapt - The cat is sleeping"),
            ("Boek", "Book", "Ik lees een boek - I am reading a book"),
            ("Water", "Water", "Ik drink water - I drink water"),
            ("Fiets", "Bicycle", "Ik ga met de fiets - I go by bicycle"),
            ("Brood", "Bread", "Vers brood - Fresh bread"),
            ("Kaas", "Cheese", "Nederlandse kaas - Dutch cheese"),
            ("Rood", "Red", "De appel is rood - The apple is red"),
            ("Boom", "Tree", "Een grote boom - A big tree"),
            ("Zon", "Sun", "De zon schijnt - The sun is shining")
        ]
        
        flashCards = sampleCards.map { word, definition, example in
            FlashCard(word: word, definition: definition, example: example)
        }
    }
} 