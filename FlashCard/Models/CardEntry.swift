import Foundation

struct CardEntry: Identifiable {
    let id = UUID()
    var word: String = ""
    var definition: String = ""
    var example: String = ""
    
    // Additional grammatical fields
    var article: String = ""
    var plural: String = ""
    var pastTense: String = ""
    var futureTense: String = ""
    var pastParticiple: String = ""
} 