import Foundation

struct FlashCard: Identifiable, Codable {
    var id = UUID()
    var word: String
    var definition: String
    var example: String
    
    init(word: String = "", definition: String = "", example: String = "") {
        self.word = word
        self.definition = definition
        self.example = example
    }
} 