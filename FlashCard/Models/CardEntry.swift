import Foundation

struct CardEntry: Identifiable {
    let id = UUID()
    var word: String = ""
    var definition: String = ""
    var example: String = ""
} 