import Foundation

struct CardEntry: Identifiable {
    let id = UUID()
    var word: String = ""
    var definition: String = ""
    var example: String = ""
    
    // Dutch language features
    var isDeSelected: Bool = false
    var isHetSelected: Bool = false
    var pastTense: String = ""
    var futureTense: String = ""
} 