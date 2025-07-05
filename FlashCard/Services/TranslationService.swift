import Foundation
import os

/// Service for handling translations with fallback to local dictionary
class TranslationService: ObservableObject {
    static let shared = TranslationService()
    
    private let logger = Logger(subsystem: "com.flashcards", category: "TranslationService")
    
    // Access to our comprehensive vocabulary databases
    private let dutchDatabase = DutchVocabularyDatabase.shared
    
    private init() {
        // Initialize without TranslationSession for compatibility
        // Translation framework integration is handled in CompatibilityHelper
    }
    
    /// Get translation with comprehensive vocabulary database lookup first, then fallback to local dictionary
    func getTranslationWithFallback(for word: String) async -> String {
        // Ensure we're working with a clean word
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanWord.isEmpty else { return "" }
        
        do {
            // First, search our comprehensive Dutch vocabulary database
            if let vocabularyMatch = searchVocabularyDatabase(for: cleanWord) {
                logger.debug("✅ Found in vocabulary database for '\(cleanWord)': '\(vocabularyMatch.definition)'")
                return vocabularyMatch.definition
            }
            
            // Fallback to local dictionary
            if let dictionaryTranslation = getDictionaryTranslation(for: cleanWord) {
                logger.debug("✅ Found in local dictionary for '\(cleanWord)': '\(dictionaryTranslation)'")
                return dictionaryTranslation
            }
            
            logger.debug("❌ No translation found for '\(cleanWord)'")
            return ""
        } catch {
            logger.error("❌ Translation error for '\(cleanWord)': \(error.localizedDescription)")
            return ""
        }
    }
    
    /// Get comprehensive translation data from our vocabulary database
    func getComprehensiveTranslation(for word: String) async -> ComprehensiveTranslation? {
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanWord.isEmpty else { return nil }
        
        // Search our comprehensive vocabulary database
        if let vocabularyMatch = searchVocabularyDatabase(for: cleanWord) {
            logger.debug("✅ Found comprehensive data for '\(cleanWord)'")
            
            // Check if there are multiple versions of this word
            let allMatches = getAllMatches(for: cleanWord)
            let hasAlternatives = allMatches.count > 1
            
            return ComprehensiveTranslation(
                originalWord: cleanWord,
                definition: vocabularyMatch.definition,
                example: vocabularyMatch.example,
                article: vocabularyMatch.article.isEmpty ? nil : vocabularyMatch.article,
                plural: vocabularyMatch.plural.isEmpty ? nil : vocabularyMatch.plural,
                pastTense: vocabularyMatch.pastTense.isEmpty ? nil : vocabularyMatch.pastTense,
                futureTense: vocabularyMatch.futureTense.isEmpty ? nil : vocabularyMatch.futureTense,
                pastParticiple: vocabularyMatch.pastParticiple.isEmpty ? nil : vocabularyMatch.pastParticiple,
                wordType: vocabularyMatch.wordType,
                level: vocabularyMatch.level,
                category: vocabularyMatch.category,
                confidence: 0.95,
                hasAlternatives: hasAlternatives,
                alternativeCount: allMatches.count
            )
        }
        
        // Fallback to basic translation with enhanced info
        let basicTranslation = await getTranslationWithFallback(for: cleanWord)
        if !basicTranslation.isEmpty {
            let wordType = determineWordType(cleanWord)
            return ComprehensiveTranslation(
                originalWord: cleanWord,
                definition: basicTranslation,
                example: nil,
                article: wordType == .noun ? guessArticle(for: cleanWord) : nil,
                plural: wordType == .noun ? guessPluralForm(for: cleanWord) : nil,
                pastTense: nil,
                futureTense: nil,
                pastParticiple: nil,
                wordType: WordType.fromDutchWordType(wordType),
                level: nil,
                category: nil,
                confidence: 0.75,
                hasAlternatives: false,
                alternativeCount: 1
            )
        }
        
        return nil
    }
    
    /// Search through our comprehensive Dutch vocabulary database
    private func searchVocabularyDatabase(for word: String) -> DutchWord? {
        let searchWord = word.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !searchWord.isEmpty else { return nil }
        
        var exactMatches: [DutchWord] = []
        var partialMatches: [DutchWord] = []
        
        // Search main vocabulary database
        let allMainWords = dutchDatabase.getAllWords()
        for dutchWord in allMainWords {
            let wordLower = dutchWord.word.lowercased()
            if wordLower == searchWord {
                exactMatches.append(dutchWord)
            } else if shouldConsiderPartialMatch(searchWord: searchWord, databaseWord: wordLower) {
                partialMatches.append(dutchWord)
            }
        }
        
        // Search expanded vocabulary database through DutchVocabularyDatabase
        let allExpandedPacks = DutchVocabularyDatabase.expandedPacks
        for pack in allExpandedPacks {
            for dutchWord in pack.words {
                let wordLower = dutchWord.word.lowercased()
                if wordLower == searchWord {
                    exactMatches.append(dutchWord)
                } else if shouldConsiderPartialMatch(searchWord: searchWord, databaseWord: wordLower) {
                    partialMatches.append(dutchWord)
                }
            }
        }
        
        // If we found exact matches, return the best one
        if !exactMatches.isEmpty {
            return selectBestMatch(from: exactMatches)
        }
        
        // Only consider partial matches if they are meaningful
        if !partialMatches.isEmpty {
            // Filter partial matches to only include meaningful ones
            let meaningfulPartialMatches = partialMatches.filter { dutchWord in
                let wordLower = dutchWord.word.lowercased()
                // Only consider partial matches where the search word is at least 3 characters
                // and the database word is not significantly shorter
                return searchWord.count >= 3 && 
                       wordLower.count >= Int(Double(searchWord.count) * 0.7) && // Database word should be at least 70% of search word length
                       (wordLower.hasPrefix(searchWord) || searchWord.hasPrefix(wordLower))
            }
            
            if !meaningfulPartialMatches.isEmpty {
                return selectBestMatch(from: meaningfulPartialMatches)
            }
        }
        
        return nil
    }
    
    /// Determine if a partial match should be considered
    private func shouldConsiderPartialMatch(searchWord: String, databaseWord: String) -> Bool {
        // Don't consider partial matches for very short words (less than 3 characters)
        if searchWord.count < 3 || databaseWord.count < 3 {
            return false
        }
        
        // Don't consider partial matches where one word is much shorter than the other
        let lengthRatio = Double(min(searchWord.count, databaseWord.count)) / Double(max(searchWord.count, databaseWord.count))
        if lengthRatio < 0.7 {
            return false
        }
        
        // Only consider meaningful partial matches
        return databaseWord.hasPrefix(searchWord) || searchWord.hasPrefix(databaseWord)
    }
    
    /// Select the best match from multiple options - prioritizes higher levels and more complete information
    private func selectBestMatch(from matches: [DutchWord]) -> DutchWord {
        guard !matches.isEmpty else { return matches[0] }
        
        // Sort by priority: B1 > A2 > A1, then by completeness of information
        let sortedMatches = matches.sorted { match1, match2 in
            // First priority: level (B1 > A2 > A1)
            let level1Priority = levelPriority(match1.level)
            let level2Priority = levelPriority(match2.level)
            
            if level1Priority != level2Priority {
                return level1Priority > level2Priority
            }
            
            // Second priority: completeness of information
            let completeness1 = calculateCompleteness(match1)
            let completeness2 = calculateCompleteness(match2)
            
            return completeness1 > completeness2
        }
        
        return sortedMatches[0]
    }
    
    /// Get priority value for language level (higher = better)
    private func levelPriority(_ level: LanguageLevel) -> Int {
        switch level {
        case .b1: return 3
        case .a2: return 2
        case .a1: return 1
        }
    }
    
    /// Calculate completeness score based on how much information the word entry has
    private func calculateCompleteness(_ word: DutchWord) -> Int {
        var score = 0
        
        if !word.definition.isEmpty { score += 1 }
        if !word.example.isEmpty { score += 1 }
        if !word.article.isEmpty { score += 1 }
        if !word.plural.isEmpty { score += 1 }
        if !word.pastTense.isEmpty { score += 1 }
        if !word.futureTense.isEmpty { score += 1 }
        if !word.pastParticiple.isEmpty { score += 1 }
        
        return score
    }
    
    /// Get all matches for a word (useful for showing alternatives to users)
    func getAllMatches(for word: String) -> [DutchWord] {
        let searchWord = word.lowercased()
        var allMatches: [DutchWord] = []
        
        // Search main vocabulary database
        let allMainWords = dutchDatabase.getAllWords()
        for dutchWord in allMainWords {
            if dutchWord.word.lowercased() == searchWord {
                allMatches.append(dutchWord)
            }
        }
        
        // Search expanded vocabulary database
        let allExpandedPacks = DutchVocabularyDatabase.expandedPacks
        for pack in allExpandedPacks {
            for dutchWord in pack.words {
                if dutchWord.word.lowercased() == searchWord {
                    allMatches.append(dutchWord)
                }
            }
        }
        
        return allMatches
    }
    
    /// Batch translate multiple words
    func translateWords(_ words: [String]) async -> [String: String] {
        var translations: [String: String] = [:]
        
        for word in words {
            let translation = await getTranslationWithFallback(for: word)
            if !translation.isEmpty {
                translations[word] = translation
            }
        }
        
        return translations
    }
    
    /// Get comprehensive translations for multiple words
    func getComprehensiveTranslations(_ words: [String]) async -> [String: ComprehensiveTranslation] {
        var translations: [String: ComprehensiveTranslation] = [:]
        
        for word in words {
            if let translation = await getComprehensiveTranslation(for: word) {
                translations[word] = translation
            }
        }
        
        return translations
    }
    
    /// Local dictionary for common Dutch words
    private func getDictionaryTranslation(for word: String) -> String? {
        let localDictionary: [String: String] = [
            // Common nouns
            "huis": "house",
            "kat": "cat",
            "hond": "dog",
            "auto": "car",
            "fiets": "bicycle",
            "boek": "book",
            "tafel": "table",
            "stoel": "chair",
            "bed": "bed",
            "kamer": "room",
            "keuken": "kitchen",
            "badkamer": "bathroom",
            "tuin": "garden",
            "deur": "door",
            "raam": "window",
            "water": "water",
            "brood": "bread",
            "melk": "milk",
            "koffie": "coffee",
            "thee": "tea",
            "bier": "beer",
            "wijn": "wine",
            "appel": "apple",
            "banaan": "banana",
            "sinaasappel": "orange",
            "kaas": "cheese",
            "vlees": "meat",
            "vis": "fish",
            "kip": "chicken",
            "varken": "pig",
            "rundvlees": "beef",
            "rijst": "rice",
            "pasta": "pasta",
            "aardappel": "potato",
            "groente": "vegetable",
            "fruit": "fruit",
            "salade": "salad",
            "soep": "soup",
            "broodjes": "sandwiches",
            "ontbijt": "breakfast",
            "lunch": "lunch",
            "diner": "dinner",
            "school": "school",
            "universiteit": "university",
            "werk": "work",
            "kantoor": "office",
            "winkel": "shop",
            "restaurant": "restaurant",
            "ziekenhuis": "hospital",
            "dokter": "doctor",
            "tandarts": "dentist",
            "familie": "family",
            "ouders": "parents",
            "vader": "father",
            "moeder": "mother",
            "zoon": "son",
            "dochter": "daughter",
            "broer": "brother",
            "zus": "sister",
            "opa": "grandfather",
            "oma": "grandmother",
            "vriend": "friend",
            "vriendin": "girlfriend/female friend",
            "partner": "partner",
            "man": "man",
            "vrouw": "woman",
            "kind": "child",
            "baby": "baby",
            "persoon": "person",
            "mensen": "people",
            "stad": "city",
            "dorp": "village",
            "land": "country",
            "wereld": "world",
            "straat": "street",
            "weg": "road",
            "brug": "bridge",
            "park": "park",
            "bos": "forest",
            "zee": "sea",
            "strand": "beach",
            "berg": "mountain",
            "rivier": "river",
            "meer": "lake/more",
            "lucht": "sky/air",
            "zon": "sun",
            "maan": "moon",
            "ster": "star",
            "weer": "weather",
            "regen": "rain",
            "sneeuw": "snow",
            "wind": "wind",
            "wolken": "clouds",
            "geld": "money",
            "euro": "euro",
            "prijs": "price/prize",
            "kopen": "to buy",
            "verkopen": "to sell",
            "betalen": "to pay",
            "kosten": "to cost",
            "duur": "expensive",
            "goedkoop": "cheap",
            "gratis": "free",
            "muziek": "music",
            "film": "movie",
            "televisie": "television",
            "computer": "computer",
            "telefoon": "telephone",
            "internet": "internet",
            "email": "email",
            "foto": "photo",
            "camera": "camera",
            "sport": "sport",
            "voetbal": "football/soccer",
            "tennis": "tennis",
            "zwemmen": "swimming",
            "hardlopen": "running",
            "fietsen": "cycling",
            "wandelen": "walking",
            "reizen": "traveling",
            "vakantie": "vacation",
            "hotel": "hotel",
            "vliegtuig": "airplane",
            "trein": "train",
            "bus": "bus",
            "metro": "subway",
            "taxi": "taxi",
            "station": "station",
            "luchthaven": "airport",
            "kaart": "map/card",
            "ticket": "ticket",
            "paspoort": "passport",
            "bagage": "luggage",
            "kleren": "clothes",
            "shirt": "shirt",
            "broek": "pants",
            "jurk": "dress",
            "jas": "coat",
            "schoenen": "shoes",
            "sokken": "socks",
            "hoed": "hat",
            "tas": "bag",
            "portemonnee": "wallet",
            "sleutels": "keys",
            "bril": "glasses",
            "horloge": "watch",
            "ring": "ring",
            "ketting": "necklace",
            "cadeau": "gift/present",
            "feest": "party",
            "verjaardag": "birthday",
            "trouwen": "wedding",
            "liefde": "love",
            "geluk": "happiness/luck",
            "verdriet": "sadness",
            "angst": "fear",
            "woede": "anger",
            "stress": "stress",
            "rust": "rest/peace",
            "gezondheid": "health",
            "ziekte": "illness",
            "pijn": "pain",
            "medicijn": "medicine",
            "vitamines": "vitamins",
            "oefening": "exercise",
            "dieet": "diet",
            "slapen": "sleep/to sleep",
            "dromen": "dreams",
            "droom": "dream",
            "wakker": "awake",
            "moe": "tired",
            "energie": "energy",
            "kracht": "strength",
            "zwak": "weak",
            "sterk": "strong",
            "gezond": "healthy",
            "ziek": "sick",
            "jong": "young",
            "oud": "old",
            "nieuw": "new",
            "gebruikt": "used",
            "schoon": "clean",
            "vuil": "dirty",
            "vol": "full",
            "leeg": "empty",
            "open": "open",
            "dicht": "closed",
            "links": "left",
            "rechts": "right",
            "voor": "in front of",
            "achter": "behind",
            "boven": "above",
            "onder": "under",
            "naast": "next to",
            "tussen": "between",
            "binnen": "inside",
            "buiten": "outside",
            "vroeg": "early",
            "laat": "late",
            "snel": "fast",
            "langzaam": "slow",
            "hard": "hard/loud",
            "zacht": "soft/quiet",
            "stil": "quiet",
            "lawaai": "noise",
            "geluid": "sound",
            "stem": "voice",
            "praten": "to talk",
            "zeggen": "to say",
            "vragen": "to ask",
            "antwoorden": "to answer",
            "uitleggen": "to explain",
            "begrijpen": "to understand",
            "leren": "to learn",
            "studeren": "to study",
            "onderwijzen": "to teach",
            "kennis": "knowledge",
            "informatie": "information",
            "nieuws": "news",
            "verhaal": "story",
            "boeken": "books",
            "krant": "newspaper",
            "tijdschrift": "magazine",
            "artikel": "article",
            "pagina": "page",
            "woord": "word",
            "zin": "sentence",
            "taal": "language",
            "Nederlands": "Dutch",
            "Engels": "English",
            "Duits": "German",
            "Frans": "French",
            "Spaans": "Spanish",
            "Italiaans": "Italian",
            "Chinees": "Chinese",
            "Japans": "Japanese",
            "Russisch": "Russian",
            "Arabisch": "Arabic",
            "ademhaling": "breathing",
            "ophalen": "to pick up/to fetch",
            
            // Common verbs
            "eten": "to eat",
            "drinken": "to drink",
            "werken": "to work",
            "spelen": "to play",
            "lopen": "to walk",
            "rennen": "to run",
            "springen": "to jump",
            "vallen": "to fall",
            "staan": "to stand",
            "zitten": "to sit",
            "liggen": "to lie down",
            "spreken": "to speak",
            "luisteren": "to listen",
            "kijken": "to look",
            "zien": "to see",
            "lezen": "to read",
            "schrijven": "to write",
            "tekenen": "to draw",
            "schilderen": "to paint",
            "zingen": "to sing",
            "dansen": "to dance",
            "denken": "to think",
            "voelen": "to feel",
            "houden": "to hold",
            "pakken": "to grab",
            "geven": "to give",
            "nemen": "to take",
            "brengen": "to bring",
            "halen": "to fetch",
            "komen": "to come",
            "gaan": "to go",
            "vertrekken": "to leave",
            "aankomen": "to arrive",
            "bezoeken": "to visit",
            "ontmoeten": "to meet",
            "helpen": "to help",
            "zorgen": "to care",
            "redden": "to save",
            "beschermen": "to protect",
            "aanvallen": "to attack",
            "verdedigen": "to defend",
            "winnen": "to win",
            "verliezen": "to lose",
            "proberen": "to try",
            "slagen": "to succeed",
            "falen": "to fail",
            "beginnen": "to begin",
            "stoppen": "to stop",
            "eindigen": "to end",
            "doorgaan": "to continue",
            "wachten": "to wait",
            "hopen": "to hope",
            "verwachten": "to expect",
            "geloven": "to believe",
            "twijfelen": "to doubt",
            "vertrouwen": "to trust",
            "liegen": "to lie",
            "waarheid": "truth",
            "leugen": "lie",
            "eerlijk": "honest/fair",
            "oneerlijk": "dishonest/unfair",
            "zijn": "to be/his",
            "hebben": "to have",
            "doen": "to do",
            "maken": "to make",
            "bouwen": "to build",
            "breken": "to break",
            "repareren": "to repair",
            "schoonmaken": "to clean",
            "wassen": "to wash",
            "drogen": "to dry",
            "koken": "to cook",
            "bakken": "to bake",
            "snijden": "to cut",
            "weten": "to know",
            "kennen": "to know (person/place)",
            "herinneren": "to remember",
            "vergeten": "to forget",
            "kunnen": "can/to be able to",
            "mogen": "may/to be allowed to",
            "willen": "to want",
            "moeten": "must/to have to",
            "zullen": "will/shall",
            "horen": "to hear",
            "ruiken": "to smell",
            "proeven": "to taste",
            "aanraken": "to touch",
            "genezen": "to heal",
            "ademen": "to breathe",
            "leven": "to live",
            "sterven": "to die",
            "geboren": "born",
            "groeien": "to grow",
            "veranderen": "to change",
            "blijven": "to stay",
            "worden": "to become",
            "lijken": "to seem",
            "zoeken": "to search",
            "vinden": "to find",
            "gebruiken": "to use",
            "nodig": "necessary",
            "belangrijk": "important",
            "interessant": "interesting",
            "saai": "boring",
            "leuk": "fun/nice",
            "grappig": "funny",
            "serieus": "serious",
            "gemakkelijk": "easy",
            "moeilijk": "difficult",
            "mogelijk": "possible",
            "onmogelijk": "impossible",
            "zeker": "sure/certain/certainly",
            "onzeker": "uncertain",
            "veilig": "safe",
            "gevaarlijk": "dangerous",
            "rustig": "calm",
            "druk": "busy",
            "vrij": "free",
            "bezet": "occupied",
            "alleen": "alone",
            "samen": "together",
            "veel": "much/many",
            "weinig": "little/few",
            "genoeg": "enough",
            "te veel": "too much",
            "te weinig": "too little",
            "alles": "everything",
            "niets": "nothing",
            "iets": "something",
            "iedereen": "everyone",
            "niemand": "nobody",
            "iemand": "somebody",
            
            // Common adjectives
            "groot": "big",
            "klein": "small",
            "lang": "long",
            "kort": "short",
            "breed": "wide",
            "smal": "narrow",
            "dik": "thick/fat",
            "dun": "thin",
            "zwaar": "heavy",
            "licht": "light",
            "donker": "dark",
            "helder": "bright/clear",
            "goed": "good",
            "slecht": "bad",
            "beter": "better",
            "beste": "best",
            "slechter": "worse",
            "slechtste": "worst",
            "mooi": "beautiful",
            "lelijk": "ugly",
            "knap": "handsome",
            "schattig": "cute",
            "aardig": "nice/kind",
            "onaardig": "unkind",
            "vriendelijk": "friendly",
            "onvriendelijk": "unfriendly",
            "beleefd": "polite",
            "onbeleefd": "rude",
            "slim": "smart",
            "dom": "stupid",
            "intelligent": "intelligent",
            "creatief": "creative",
            "artistiek": "artistic",
            "muzikaal": "musical",
            "sportief": "sporty",
            "lui": "lazy",
            "hardwerkend": "hardworking",
            "geduldig": "patient",
            "ongeduldig": "impatient",
            "kalm": "calm",
            "nerveus": "nervous",
            "blij": "happy",
            "verdrietig": "sad",
            "boos": "angry",
            "bang": "scared",
            "trots": "proud",
            "beschaamd": "ashamed",
            "verlegen": "shy",
            "zelfverzekerd": "confident",
            "warm": "warm",
            "koud": "cold",
            "heet": "hot",
            "koel": "cool",
            "nat": "wet",
            "droog": "dry",
            "vies": "dirty",
            "fris": "fresh",
            "zoet": "sweet",
            "zuur": "sour",
            "bitter": "bitter",
            "zout": "salty",
            "scherp": "sharp",
            "bot": "blunt",
            "glad": "smooth",
            "ruw": "rough",
            "ongezond": "unhealthy",
            "actief": "active",
            "passief": "passive",
            "levendig": "lively",
            "opgewonden": "excited",
            "ontspannen": "relaxed",
            "gestrest": "stressed",
            "tevreden": "satisfied",
            "ontevreden": "dissatisfied",
            "gelukkig": "happy",
            "ongelukkig": "unhappy",
            "vrolijk": "cheerful",
            "somber": "gloomy",
            "optimistisch": "optimistic",
            "pessimistisch": "pessimistic",
            "positief": "positive",
            "negatief": "negative",
            "normaal": "normal",
            "abnormaal": "abnormal",
            "gewoon": "ordinary",
            "bijzonder": "special",
            "uniek": "unique",
            "algemeen": "general",
            "specifiek": "specific",
            "persoonlijk": "personal",
            "privé": "private",
            "openbaar": "public",
            "officieel": "official",
            "informeel": "informal",
            "formeel": "formal",
            "modern": "modern",
            "traditioneel": "traditional",
            "klassiek": "classic",
            "populair": "popular",
            "beroemd": "famous",
            "onbekend": "unknown",
            "bekend": "known/famous",
            "lokaal": "local",
            "internationaal": "international",
            "nationaal": "national",
            "regionaal": "regional",
            "stedelijk": "urban",
            "landelijk": "rural",
            "natuurlijk": "natural/of course",
            "kunstmatig": "artificial",
            "echt": "real",
            "nep": "fake",
            "waar": "true/where",
            "vals": "false",
            "juist": "correct",
            "fout": "wrong",
            "precies": "exact/exactly",
            "ongeveer": "approximately",
            "bijna": "almost",
            "helemaal": "completely",
            "gedeeltelijk": "partially",
            "volledig": "complete",
            "onvolledig": "incomplete",
            "perfect": "perfect",
            "imperfect": "imperfect",
            "ideaal": "ideal",
            "praktisch": "practical",
            "theoretisch": "theoretical",
            "logisch": "logical",
            "onlogisch": "illogical",
            "redelijk": "reasonable",
            "onredelijk": "unreasonable",
            "gelijk": "equal",
            "ongelijk": "unequal",
            "hetzelfde": "the same",
            "verschillend": "different",
            "soortgelijk": "similar",
            "tegenovergesteld": "opposite",
            "vergelijkbaar": "comparable",
            "onvergelijkbaar": "incomparable",
            
            // Colors
            "wit": "white",
            "zwart": "black",
            "grijs": "gray",
            "rood": "red",
            "blauw": "blue",
            "groen": "green",
            "geel": "yellow",
            "oranje": "orange",
            "paars": "purple",
            "roze": "pink",
            "bruin": "brown",
            "beige": "beige",
            "goud": "gold",
            "zilver": "silver",
            "doorzichtig": "transparent",
            "ondoorzichtig": "opaque",
            "troebel": "cloudy",
            "fel": "bright (color)",
            "mat": "matte",
            "glanzend": "shiny",
            
            // Common words and phrases
            "ja": "yes",
            "nee": "no",
            "misschien": "maybe",
            "waarschijnlijk": "probably",
            "absoluut": "absolutely",
            "totaal": "totally",
            "minder": "less/fewer",
            "meest": "most",
            "minst": "least",
            "hallo": "hello",
            "hoi": "hi",
            "dag": "day/goodbye",
            "doei": "bye",
            "tot ziens": "see you later",
            "welkom": "welcome",
            "dank": "thank",
            "dank je": "thank you",
            "dank je wel": "thank you very much",
            "bedankt": "thanks",
            "graag gedaan": "you're welcome",
            "geen probleem": "no problem",
            "alsjeblieft": "please",
            "sorry": "sorry",
            "excuses": "excuse me",
            "pardon": "pardon",
            "vergiffenis": "forgiveness",
            "help": "help",
            "hulp": "help",
            "assistentie": "assistance",
            "steun": "support",
            "advies": "advice",
            "suggestie": "suggestion",
            "idee": "idea",
            "plan": "plan",
            "doel": "goal/purpose",
            "wens": "wish",
            "hoop": "hope",
            "verwachting": "expectation",
            "verrassing": "surprise",
            "geschenk": "present",
            "beloning": "reward",
            "winst": "profit/win",
            "verlies": "loss",
            "succes": "success",
            "poging": "attempt",
            "kans": "chance/opportunity",
            "pech": "bad luck",
            "fortuin": "fortune",
            "rijkdom": "wealth",
            "armoede": "poverty",
            "hier": "here",
            "daar": "there",
            "ergens": "somewhere",
            "nergens": "nowhere",
            "overal": "everywhere",
            "nu": "now",
            "dan": "then",
            "wanneer": "when",
            "altijd": "always",
            "nooit": "never",
            "soms": "sometimes",
            "vaak": "often",
            "zelden": "rarely",
            "regelmatig": "regularly",
            "onregelmatig": "irregularly",
            "dagelijks": "daily",
            "wekelijks": "weekly",
            "maandelijks": "monthly",
            "jaarlijks": "yearly",
            "later": "later",
            "eerder": "earlier",
            "binnenkort": "soon",
            "onmiddellijk": "immediately",
            "direct": "directly",
            "indirect": "indirectly",
            "vandaag": "today",
            "gisteren": "yesterday",
            "morgen": "tomorrow",
            "overmorgen": "day after tomorrow",
            "eergisteren": "day before yesterday",
            "deze week": "this week",
            "vorige week": "last week",
            "volgende week": "next week",
            "deze maand": "this month",
            "vorige maand": "last month",
            "volgende maand": "next month",
            "dit jaar": "this year",
            "vorig jaar": "last year",
            "volgend jaar": "next year",
            "tijd": "time",
            "moment": "moment",
            "seconde": "second",
            "minuut": "minute",
            "uur": "hour",
            "week": "week",
            "maand": "month",
            "jaar": "year",
            "eeuw": "century",
            "millennium": "millennium",
            "verleden": "past",
            "heden": "present",
            "toekomst": "future",
            "geschiedenis": "history",
            "traditie": "tradition",
            "cultuur": "culture",
            "gewoonte": "habit",
            "routine": "routine", 
            "schema": "schedule",
            "agenda": "agenda",
            "afspraak": "appointment",
            "vergadering": "meeting",
            "evenement": "event",
            "gebeurtenis": "event/occurrence",
            "situatie": "situation",
            "omstandigheid": "circumstance",
            "conditie": "condition",
            "staat": "state",
            "positie": "position",
            "plaats": "place",
            "locatie": "location",
            "adres": "address",
            "richting": "direction",
            "afstand": "distance",
            "nabijheid": "proximity",
            "verte": "distance",
            "beweging": "movement",
            "snelheid": "speed",
            "tempo": "pace",
            "ritme": "rhythm",
            "patroon": "pattern",
            "structuur": "structure",
            "organisatie": "organization",
            "systeem": "system",
            "methode": "method",
            "manier": "way",
            "stijl": "style",
            "vorm": "form",
            "formaat": "format",
            "grootte": "size",
            "afmeting": "dimension",
            "lengte": "length",
            "breedte": "width",
            "hoogte": "height",
            "diepte": "depth",
            "dikte": "thickness",
            "gewicht": "weight",
            "massa": "mass",
            "volume": "volume",
            "capaciteit": "capacity",
            "ruimte": "space",
            "gebied": "area",
            "zone": "zone",
            "regio": "region",
            "district": "district",
            "buurt": "neighborhood",
            
            // Numbers
            "nul": "zero",
            "een": "one/a/an",
            "twee": "two",
            "drie": "three",
            "vier": "four",
            "vijf": "five",
            "zes": "six",
            "zeven": "seven",
            "acht": "eight",
            "negen": "nine",
            "tien": "ten",
            "elf": "eleven",
            "twaalf": "twelve",
            "dertien": "thirteen",
            "veertien": "fourteen",
            "vijftien": "fifteen",
            "zestien": "sixteen",
            "zeventien": "seventeen",
            "achttien": "eighteen",
            "negentien": "nineteen",
            "twintig": "twenty",
            "dertig": "thirty",
            "veertig": "forty",
            "vijftig": "fifty",
            "zestig": "sixty",
            "zeventig": "seventy",
            "tachtig": "eighty",
            "negentig": "ninety",
            "honderd": "hundred",
            "duizend": "thousand",
            "miljoen": "million",
            "miljard": "billion",
            "biljoen": "trillion",
            "eerste": "first",
            "tweede": "second",
            "derde": "third",
            "vierde": "fourth",
            "vijfde": "fifth",
            "zesde": "sixth",
            "zevende": "seventh",
            "achtste": "eighth",
            "negende": "ninth",
            "tiende": "tenth",
            "laatste": "last",
            "volgende": "next",
            "vorige": "previous",
            "huidige": "current",
            "toekomstige": "future",
            
            // Articles and pronouns
            "de": "the",
            "het": "the/it",
            "deze": "this/these",
            "die": "that/those",
            "dit": "this",
            "dat": "that",
            "alle": "all",
            "elke": "each",
            "iedere": "every",
            "sommige": "some",
            "andere": "other",
            "zelfde": "same",
            "verschillende": "different",
            "enkele": "several",
            "paar": "couple",
            "beide": "both",
            "geen": "no/none",
            "ik": "I",
            "jij": "you",
            "hij": "he",
            "zij": "she/they",
            "wij": "we",
            "jullie": "you (plural)",
            "me": "me",
            "mij": "me",
            "je": "you",
            "jou": "you",
            "hem": "him",
            "haar": "her",
            "ons": "us",
            "hun": "them",
            "hen": "them",
            "mijn": "my",
            "jouw": "your",
            "mezelf": "myself",
            "jezelf": "yourself",
            "zichzelf": "himself/herself/themselves",
            "onszelf": "ourselves",
            "wie": "who",
            "wat": "what",
            "waarom": "why",
            "hoe": "how",
            "welke": "which",
            "hoeveel": "how much/many",
            "hoeveelste": "which number",
            "eigen": "own",
            "eigenaar": "owner",
            "eigenlijk": "actually/really"
        ]
        
        return localDictionary[word.lowercased()]
    }
    
    /// Enhanced translation that provides context and grammar information
    func getEnhancedTranslation(for word: String) async -> EnhancedTranslation {
        let translation = await getTranslationWithFallback(for: word)
        let wordType = determineWordType(word)
        let grammarInfo = getGrammarInfo(for: word, type: wordType)
        
        return EnhancedTranslation(
            originalWord: word,
            translation: translation,
            wordType: wordType,
            grammarInfo: grammarInfo,
            confidence: translation.isEmpty ? 0.0 : 0.85
        )
    }
    
    private func determineWordType(_ word: String) -> DutchWordType {
        let verbEndings = ["en", "eren", "elen"]
        let nounIndicators = ["heid", "ing", "schap", "er", "aar"]
        
        // Check for verb endings
        for ending in verbEndings {
            if word.lowercased().hasSuffix(ending) {
                return .verb
            }
        }
        
        // Check for noun indicators
        for indicator in nounIndicators {
            if word.lowercased().contains(indicator) {
                return .noun
            }
        }
        
        // Check if it starts with capital (likely noun)
        if word.first?.isUppercase == true {
            return .noun
        }
        
        return .unknown
    }
    
    private func getGrammarInfo(for word: String, type: DutchWordType) -> GrammarInfo? {
        switch type {
        case .noun:
            return GrammarInfo(
                article: guessArticle(for: word),
                plural: guessPluralForm(for: word),
                additionalInfo: "Dutch nouns use 'de' or 'het' as articles"
            )
        case .verb:
            return GrammarInfo(
                conjugationPattern: guessConjugationPattern(for: word),
                additionalInfo: "Dutch verbs typically end in -en"
            )
        case .adjective:
            return GrammarInfo(
                additionalInfo: "Dutch adjectives may change form when used before nouns"
            )
        case .adverb:
            return GrammarInfo(
                additionalInfo: "Dutch adverbs often end in -lijk or are the same as adjectives"
            )
        case .pronoun:
            return GrammarInfo(
                additionalInfo: "Dutch pronouns change form based on their grammatical function"
            )
        case .preposition:
            return GrammarInfo(
                additionalInfo: "Dutch prepositions often combine with articles (e.g., van + de = van de)"
            )
        case .conjunction:
            return GrammarInfo(
                additionalInfo: "Dutch conjunctions connect words, phrases, or clauses"
            )
        case .unknown:
            return nil
        }
    }
    
    private func guessArticle(for word: String) -> String? {
        // Simple heuristics for Dutch articles
        let deWords = ["heid", "ing", "schap", "er", "aar", "en"]
        let hetWords = ["isme", "ment", "um"]
        
        for ending in hetWords {
            if word.lowercased().hasSuffix(ending) {
                return "het"
            }
        }
        
        for ending in deWords {
            if word.lowercased().hasSuffix(ending) {
                return "de"
            }
        }
        
        // Default to 'de' as it's more common
        return "de"
    }
    
    private func guessPluralForm(for word: String) -> String? {
        let lowerWord = word.lowercased()
        
        if lowerWord.hasSuffix("e") {
            return word + "n"
        } else if lowerWord.hasSuffix("el") || lowerWord.hasSuffix("er") || lowerWord.hasSuffix("en") {
            return word + "s"
        } else {
            return word + "en"
        }
    }
    
    private func guessConjugationPattern(for word: String) -> String? {
        if word.lowercased().hasSuffix("en") {
            let stem = String(word.dropLast(2))
            return "ik \(stem), jij \(stem)t, hij/zij \(stem)t"
        }
        return nil
    }
}

// MARK: - Supporting Types

struct ComprehensiveTranslation {
    let originalWord: String
    let definition: String
    let example: String?
    let article: String?
    let plural: String?
    let pastTense: String?
    let futureTense: String?
    let pastParticiple: String?
    let wordType: WordType?
    let level: LanguageLevel?
    let category: VocabularyCategory?
    let confidence: Float
    let hasAlternatives: Bool
    let alternativeCount: Int
}

struct EnhancedTranslation {
    let originalWord: String
    let translation: String
    let wordType: DutchWordType
    let grammarInfo: GrammarInfo?
    let confidence: Float
}

enum DutchWordType {
    case noun
    case verb
    case adjective
    case adverb
    case pronoun
    case preposition
    case conjunction
    case unknown
}

extension WordType {
    static func fromDutchWordType(_ dutchWordType: DutchWordType) -> WordType? {
        switch dutchWordType {
        case .noun: return .noun
        case .verb: return .verb
        case .adjective: return .adjective
        case .adverb: return .adverb
        case .pronoun: return .pronoun
        case .preposition: return .preposition
        case .conjunction: return .conjunction
        case .unknown: return nil
        }
    }
}

struct GrammarInfo {
    let article: String?
    let plural: String?
    let conjugationPattern: String?
    let additionalInfo: String?
    
    init(article: String? = nil, plural: String? = nil, conjugationPattern: String? = nil, additionalInfo: String? = nil) {
        self.article = article
        self.plural = plural
        self.conjugationPattern = conjugationPattern
        self.additionalInfo = additionalInfo
    }
} 