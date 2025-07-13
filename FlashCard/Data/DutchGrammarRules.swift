import Foundation

// MARK: - Dutch Grammar Rules System
// Comprehensive grammar learning system for Dutch language learners
// Covers A1, A2, and B1 levels with detailed explanations and examples

// MARK: - Grammar Rule Types

enum GrammarRuleType: String, CaseIterable {
    case verbConjugation = "Werkwoord Vervoeging"
    case sentenceStructure = "Zinsstructuur"
    case pluralization = "Meervoud"
    case pronunciation = "Uitspraak"
    case spelling = "Spelling"
    case tenses = "Tijden"
    case wordOrder = "Woordvolgorde"
    case adjectives = "Bijvoeglijke Naamwoorden"
    case prepositions = "Voorzetsels"
    case negation = "Ontkenning"
}

// MARK: - Grammar Rule Structure

struct DutchGrammarRule: Identifiable {
    let id: String
    let title: String
    let type: GrammarRuleType
    let level: LanguageLevel
    let explanation: String
    let keyPoints: [String]
    let examples: [GrammarExample]
    let exercises: [GrammarExercise]
    let commonMistakes: [CommonMistake]
    let tips: [String]
    let relatedRules: [String] // IDs of related rules
}

struct GrammarExample {
    let dutch: String
    let english: String
    let breakdown: String? // Optional grammatical breakdown
    let audioHint: String? // Pronunciation guide
}

struct GrammarExercise {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let hint: String?
    let exerciseType: ExerciseType
    
    // Initialize with default exercise type for backward compatibility
    init(question: String, options: [String], correctAnswer: Int, explanation: String, hint: String? = nil, exerciseType: ExerciseType = .multipleChoice) {
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.hint = hint
        self.exerciseType = exerciseType
    }
}

enum ExerciseType {
    case multipleChoice
    case translation
    case fillInTheBlank
    case sentenceOrder
    case trueFalse
}

struct CommonMistake {
    let incorrect: String
    let correct: String
    let explanation: String
}

// MARK: - Verb Conjugation Rules Database

class DutchGrammarRulesDatabase {
    static let shared = DutchGrammarRulesDatabase()
    private init() {}
    
    // MARK: - A1 Level Verb Conjugation Rules
    
    lazy var presentTenseA1 = DutchGrammarRule(
        id: "verb_present_a1",
        title: "Present Tense - Regular Verbs (A1)",
        type: .verbConjugation,
        level: .a1,
        explanation: """
        In Dutch, you conjugate verbs by adding endings to the stem of the verb. You get the stem by removing -en from the infinitive (whole verb).
        
        For example: 'werken' (to work) → stem = 'werk'
        
        For regular verbs in the present tense, use these endings:
        • ik: stem (no ending)
        • jij/je: stem + t
        • hij/zij/het: stem + t
        • wij/we: whole verb (infinitive)
        • jullie: whole verb (infinitive)
        • zij: whole verb (infinitive)
        
        IMPORTANT: When asking questions with 'jij', the verb doesn't get an extra -t.
        """,
        keyPoints: [
            "Stem = infinitive minus -en",
            "Ik = stem only (no ending)",
            "Jij/hij/zij = stem + t",
            "Wij/jullie/zij = whole verb (infinitive)",
            "Note: in questions, 'jij' doesn't get extra -t"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik werk in een kantoor.",
                english: "I work in an office.",
                breakdown: "werk (stem) - no ending for 'ik'",
                audioHint: "ik vɛrk"
            ),
            GrammarExample(
                dutch: "Jij werkt hard.",
                english: "You work hard.",
                breakdown: "werk (stem) + t = werkt",
                audioHint: "jɛi vɛrkt"
            ),
            GrammarExample(
                dutch: "Hij woont in Amsterdam.",
                english: "He lives in Amsterdam.",
                breakdown: "woon (stem) + t = woont",
                audioHint: "hɛi voːnt"
            ),
            GrammarExample(
                dutch: "Wij leren Nederlands.",
                english: "We learn Dutch.",
                breakdown: "leren (whole verb) - no change",
                audioHint: "vɛi leːrə(n)"
            ),
            GrammarExample(
                dutch: "Jullie spelen voetbal.",
                english: "You (plural) play football.",
                breakdown: "spelen (whole verb) - no change",
                audioHint: "jɵli speːlə(n)"
            ),
            GrammarExample(
                dutch: "Zij koken samen.",
                english: "They cook together.",
                breakdown: "koken (whole verb) - no change",
                audioHint: "zɛi koːkə(n)"
            )
        ],
        exercises: [
            // Basic conjugation exercises
            GrammarExercise(
                question: "Conjugation of 'maken' (to make): Ik ... elke dag huiswerk.",
                options: ["maak", "maakt", "maken", "maakte"],
                correctAnswer: 0,
                explanation: "For 'ik' use only the stem: maak (maken - en = maak)",
                hint: "For 'ik' use no ending"
            ),
            GrammarExercise(
                question: "Conjugation of 'wonen' (to live): Hij ... in Utrecht.",
                options: ["woon", "woont", "wonen", "woonde"],
                correctAnswer: 1,
                explanation: "For 'hij' use stem + t: woon + t = woont",
                hint: "For 'hij/zij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'studeren' (to study): Wij ... aan de universiteit.",
                options: ["studeer", "studeert", "studeren", "studeerde"],
                correctAnswer: 2,
                explanation: "For 'wij' use the whole verb: studeren",
                hint: "For 'wij/jullie/zij' use the infinitive"
            ),
            GrammarExercise(
                question: "Conjugation of 'spelen' (to play): Jij ... voetbal.",
                options: ["speel", "speelt", "spelen", "speelde"],
                correctAnswer: 1,
                explanation: "For 'jij' use stem + t: speel + t = speelt",
                hint: "For 'jij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'koken' (to cook): Zij ... elke avond.",
                options: ["kook", "kookt", "koken", "kookte"],
                correctAnswer: 1,
                explanation: "For 'zij' use stem + t: kook + t = kookt",
                hint: "For 'zij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'leren' (to learn): Jullie ... Nederlands.",
                options: ["leer", "leert", "leren", "leerde"],
                correctAnswer: 2,
                explanation: "For 'jullie' use the whole verb: leren",
                hint: "For 'jullie' use the infinitive"
            ),
            GrammarExercise(
                question: "Conjugation of 'werken' (to work): Zij ... in een kantoor.",
                options: ["werk", "werkt", "werken", "werkten"],
                correctAnswer: 1,
                explanation: "For 'zij' use stem + t: werk + t = werkt",
                hint: "For 'zij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'lezen' (to read): Ik ... een boek.",
                options: ["lees", "leest", "lezen", "las"],
                correctAnswer: 0,
                explanation: "For 'ik' use only the stem: lees (lezen - en = lees)",
                hint: "For 'ik' use no ending"
            ),
            GrammarExercise(
                question: "Conjugation of 'schrijven' (to write): Hij ... een brief.",
                options: ["schrijf", "schrijft", "schrijven", "schreef"],
                correctAnswer: 1,
                explanation: "For 'hij' use stem + t: schrijf + t = schrijft",
                hint: "For 'hij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'luisteren' (to listen): Wij ... naar muziek.",
                options: ["luister", "luistert", "luisteren", "luisterde"],
                correctAnswer: 2,
                explanation: "For 'wij' use the whole verb: luisteren",
                hint: "For 'wij' use the infinitive"
            ),
            
            // Translation exercises
            GrammarExercise(
                question: "How do you say 'I work in Amsterdam' in Dutch?",
                options: ["Ik werk in Amsterdam", "Ik werkt in Amsterdam", "Ik werken in Amsterdam", "Ik werkte in Amsterdam"],
                correctAnswer: 0,
                explanation: "Ik werk in Amsterdam - 'werk' is the stem form for 'ik'",
                hint: "Remember: 'ik' uses the stem without any ending",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'She lives in Utrecht' in Dutch?",
                options: ["Zij woon in Utrecht", "Zij woont in Utrecht", "Zij wonen in Utrecht", "Zij woonde in Utrecht"],
                correctAnswer: 1,
                explanation: "Zij woont in Utrecht - 'woont' adds -t for 'hij/zij'",
                hint: "Remember: 'hij/zij' adds -t to the stem",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'We study Dutch' in Dutch?",
                options: ["Wij studeer Nederlands", "Wij studeert Nederlands", "Wij studeren Nederlands", "Wij studeerde Nederlands"],
                correctAnswer: 2,
                explanation: "Wij studeren Nederlands - 'wij' uses the whole verb",
                hint: "Remember: 'wij' uses the infinitive",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'You play football' in Dutch?",
                options: ["Jij speel voetbal", "Jij speelt voetbal", "Jij spelen voetbal", "Jij speelde voetbal"],
                correctAnswer: 1,
                explanation: "Jij speelt voetbal - 'jij' adds -t to the stem",
                hint: "Remember: 'jij' adds -t to the stem",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'They cook dinner' in Dutch?",
                options: ["Zij kook avondeten", "Zij kookt avondeten", "Zij koken avondeten", "Zij kookte avondeten"],
                correctAnswer: 1,
                explanation: "Zij kookt avondeten - 'zij' adds -t to the stem",
                hint: "Remember: 'zij' adds -t to the stem",
                exerciseType: .translation
            ),
            
            // Fill-in-the-blank exercises
            GrammarExercise(
                question: "Complete: 'Ik ___ elke dag naar school' (I go to school every day)",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 0,
                explanation: "Ik ga elke dag naar school - 'ga' is the stem form for 'ik'",
                hint: "This is the present tense, and 'ik' uses the stem",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een boek' (He reads a book)",
                options: ["lees", "leest", "lezen", "las"],
                correctAnswer: 1,
                explanation: "Hij leest een boek - 'hij' adds -t to the stem",
                hint: "For 'hij' add -t to the stem",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ Nederlands' (We learn Dutch)",
                options: ["leer", "leert", "leren", "leerde"],
                correctAnswer: 2,
                explanation: "Wij leren Nederlands - 'wij' uses the whole verb",
                hint: "For 'wij' use the infinitive",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Jullie ___ naar muziek' (You listen to music)",
                options: ["luister", "luistert", "luisteren", "luisterde"],
                correctAnswer: 2,
                explanation: "Jullie luisteren naar muziek - 'jullie' uses the whole verb",
                hint: "For 'jullie' use the infinitive",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een brief' (She writes a letter)",
                options: ["schrijf", "schrijft", "schrijven", "schreef"],
                correctAnswer: 1,
                explanation: "Zij schrijft een brief - 'zij' adds -t to the stem",
                hint: "For 'zij' add -t to the stem",
                exerciseType: .fillInTheBlank
            ),
            
            // True/False exercises
            GrammarExercise(
                question: "True or False: 'Hij werkt' is correct Dutch for 'He works'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Hij werkt' is correct - 'hij' + stem + t",
                hint: "Think about the conjugation rule for 'hij'",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Ik woont' is correct Dutch for 'I live'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik woon'. 'Ik' uses only the stem, no -t",
                hint: "Remember: 'ik' uses no ending",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Wij studeert' is correct Dutch for 'We study'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Wij studeren'. 'Wij' uses the whole verb",
                hint: "Remember: 'wij' uses the infinitive",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Jij speelt' is correct Dutch for 'You play'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Jij speelt' is correct - 'jij' + stem + t",
                hint: "Think about the conjugation rule for 'jij'",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Zij koken' is correct Dutch for 'They cook'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Zij koken' is correct - 'zij' uses the whole verb",
                hint: "Think about the conjugation rule for 'zij' (plural)",
                exerciseType: .trueFalse
            ),
            
            // Question form exercises
            GrammarExercise(
                question: "How do you ask 'Do you work?' in Dutch?",
                options: ["Werk jij?", "Werkt jij?", "Werk je?", "Werkt je?"],
                correctAnswer: 0,
                explanation: "Werk jij? - In questions with 'jij', the verb doesn't get an extra -t",
                hint: "Remember the special rule for questions with 'jij'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you ask 'Do you live here?' in Dutch?",
                options: ["Woon jij hier?", "Woon je hier?", "Woont jij hier?", "Woont je hier?"],
                correctAnswer: 0,
                explanation: "Woon jij hier? - In questions, 'jij' doesn't get extra -t",
                hint: "Remember the question rule for 'jij'",
                exerciseType: .translation
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik werkt",
                correct: "Ik werk",
                explanation: "For 'ik' don't add -t, use only the stem"
            ),
            CommonMistake(
                incorrect: "Hij werk",
                correct: "Hij werkt",
                explanation: "For 'hij/zij' you must add -t to the stem"
            ),
            CommonMistake(
                incorrect: "Wij werkt",
                correct: "Wij werken",
                explanation: "For 'wij/jullie/zij' use the whole verb"
            ),
            CommonMistake(
                incorrect: "Werkt jij?",
                correct: "Werk jij?",
                explanation: "In questions with 'jij', don't add extra -t"
            ),
            CommonMistake(
                incorrect: "Ik studeert",
                correct: "Ik studeer",
                explanation: "For 'ik' use only the stem, no -t"
            )
        ],
        tips: [
            "Practice with the stem first: write the infinitive and remove -en",
            "Remember: ik=stem, jij/hij/zij=stem+t, wij/jullie/zij=infinitive",
            "In questions with 'jij', you don't get extra -t: 'Werk jij?' (not 'Werkt jij?')",
            "Listen to Dutch conversations to learn the rhythm",
            "Common verbs to practice: werken, wonen, studeren, spelen, koken, leren",
            "Pay attention to spelling: 'kook' + t = 'kookt' (not 'kookt')"
        ],
        relatedRules: ["verb_irregular_a1", "verb_questions_a1", "verb_negation_a1"]
    )
    
    lazy var irregularVerbsA1 = DutchGrammarRule(
        id: "verb_irregular_a1",
        title: "Irregular Verbs - Basic (A1)",
        type: .verbConjugation,
        level: .a1,
        explanation: """
        Some verbs in Dutch are irregular, which means they don't follow the normal conjugation rules. The most important irregular verbs for beginners are:
        
        • zijn (to be) - very irregular
        • hebben (to have) - small changes
        • gaan (to go) - small changes
        • doen (to do) - small changes
        • komen (to come) - small changes
        
        These verbs must be learned by heart because they are used very frequently in conversations.
        
        IMPORTANT IRREGULAR VERBS:
        
        1. ZIJN (to be):
        • ik ben (I am)
        • jij bent (you are) 
        • hij/zij/het is (he/she/it is)
        • wij/jullie/zij zijn (we/you/they are)
        
        2. HEBBEN (to have):
        • ik heb (I have)
        • jij hebt/hebt (you have)
        • hij/zij/het heeft (he/she/it has)
        • wij/jullie/zij hebben (we/you/they have)
        
        3. GAAN (to go):
        • ik ga (I go)
        • jij gaat (you go)
        • hij/zij/het gaat (he/she/it goes)
        • wij/jullie/zij gaan (we/you/they go)
        """,
        keyPoints: [
            "Irregular verbs don't follow normal rules",
            "'Zijn' is the most irregular verb",
            "Learn the most important irregular verbs by heart",
            "These verbs appear very frequently in conversations",
            "Pay attention to spelling differences",
            "Practice with real sentences"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik ben student.",
                english: "I am a student.",
                breakdown: "zijn: ik ben (not 'ik zij')",
                audioHint: "ik bɛn"
            ),
            GrammarExample(
                dutch: "Jij bent aardig.",
                english: "You are nice.",
                breakdown: "zijn: jij bent (not 'jij zijt')",
                audioHint: "jɛi bɛnt"
            ),
            GrammarExample(
                dutch: "Hij is thuis.",
                english: "He is at home.",
                breakdown: "zijn: hij is (not 'hij zijt')",
                audioHint: "hɛi ɪs"
            ),
            GrammarExample(
                dutch: "Wij zijn moe.",
                english: "We are tired.",
                breakdown: "zijn: wij zijn (plural)",
                audioHint: "vɛi zɛin"
            ),
            GrammarExample(
                dutch: "Ik heb een auto.",
                english: "I have a car.",
                breakdown: "hebben: ik heb (stem hebb → heb)",
                audioHint: "ik hɛp"
            ),
            GrammarExample(
                dutch: "Zij heeft een hond.",
                english: "She has a dog.",
                breakdown: "hebben: zij heeft (not 'zij hebt')",
                audioHint: "zɛi heːft"
            ),
            GrammarExample(
                dutch: "Wij hebben tijd.",
                english: "We have time.",
                breakdown: "hebben: wij hebben (plural)",
                audioHint: "vɛi hɛbə(n)"
            ),
            GrammarExample(
                dutch: "Ik ga naar school.",
                english: "I go to school.",
                breakdown: "gaan: ik ga (stem)",
                audioHint: "ik ɣaː"
            ),
            GrammarExample(
                dutch: "Hij gaat naar werk.",
                english: "He goes to work.",
                breakdown: "gaan: hij gaat (stem + t)",
                audioHint: "hɛi ɣaːt"
            ),
            GrammarExample(
                dutch: "Wij gaan naar huis.",
                english: "We go home.",
                breakdown: "gaan: wij gaan (plural)",
                audioHint: "vɛi ɣaːn"
            )
        ],
        exercises: [
            // ZIJN exercises
            GrammarExercise(
                question: "Conjugation of 'zijn': Ik ... student.",
                options: ["zij", "ben", "bent", "is"],
                correctAnswer: 1,
                explanation: "'Zijn' with 'ik' becomes 'ben'",
                hint: "The verb 'zijn' is very irregular"
            ),
            GrammarExercise(
                question: "Conjugation of 'zijn': Jij ... moe.",
                options: ["zij", "ben", "bent", "is"],
                correctAnswer: 2,
                explanation: "'Zijn' with 'jij' becomes 'bent'",
                hint: "Remember the irregular form for 'jij'"
            ),
            GrammarExercise(
                question: "Conjugation of 'zijn': Hij ... thuis.",
                options: ["zij", "ben", "bent", "is"],
                correctAnswer: 3,
                explanation: "'Zijn' with 'hij' becomes 'is'",
                hint: "Remember the irregular form for 'hij'"
            ),
            GrammarExercise(
                question: "Conjugation of 'zijn': Wij ... in Nederland.",
                options: ["zij", "ben", "bent", "is", "zijn"],
                correctAnswer: 4,
                explanation: "'Zijn' with 'wij' becomes 'zijn'",
                hint: "Plural forms are more regular"
            ),
            
            // HEBBEN exercises
            GrammarExercise(
                question: "Conjugation of 'hebben': Ik ... honger.",
                options: ["heb", "hebt", "heeft", "hebben"],
                correctAnswer: 0,
                explanation: "'Hebben' with 'ik' becomes 'heb'",
                hint: "Remember the irregular form for 'ik'"
            ),
            GrammarExercise(
                question: "Conjugation of 'hebben': Jij ... een auto.",
                options: ["heb", "hebt", "heeft", "hebben"],
                correctAnswer: 1,
                explanation: "'Hebben' with 'jij' becomes 'hebt'",
                hint: "Remember the irregular form for 'jij'"
            ),
            GrammarExercise(
                question: "Conjugation of 'hebben': Zij ... een hond.",
                options: ["heb", "hebt", "heeft", "hebben"],
                correctAnswer: 2,
                explanation: "'Hebben' with 'zij' becomes 'heeft'",
                hint: "Remember the irregular form for 'zij'"
            ),
            GrammarExercise(
                question: "Conjugation of 'hebben': Wij ... tijd.",
                options: ["heb", "hebt", "heeft", "hebben"],
                correctAnswer: 3,
                explanation: "'Hebben' with 'wij' becomes 'hebben'",
                hint: "Plural forms are more regular"
            ),
            
            // GAAN exercises
            GrammarExercise(
                question: "Conjugation of 'gaan': Ik ... naar school.",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 0,
                explanation: "'Gaan' with 'ik' becomes 'ga'",
                hint: "Remember the irregular form for 'ik'"
            ),
            GrammarExercise(
                question: "Conjugation of 'gaan': Jij ... naar werk.",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 1,
                explanation: "'Gaan' with 'jij' becomes 'gaat'",
                hint: "Remember the irregular form for 'jij'"
            ),
            GrammarExercise(
                question: "Conjugation of 'gaan': Hij ... naar huis.",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 1,
                explanation: "'Gaan' with 'hij' becomes 'gaat'",
                hint: "Remember the irregular form for 'hij'"
            ),
            GrammarExercise(
                question: "Conjugation of 'gaan': Wij ... naar de winkel.",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 2,
                explanation: "'Gaan' with 'wij' becomes 'gaan'",
                hint: "Plural forms are more regular"
            ),
            
            // Translation exercises
            GrammarExercise(
                question: "How do you say 'I am tired' in Dutch?",
                options: ["Ik zij moe", "Ik ben moe", "Ik bent moe", "Ik is moe"],
                correctAnswer: 1,
                explanation: "Ik ben moe - 'zijn' with 'ik' becomes 'ben'",
                hint: "Remember the irregular form for 'ik'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'You are nice' in Dutch?",
                options: ["Jij zij aardig", "Jij ben aardig", "Jij bent aardig", "Jij is aardig"],
                correctAnswer: 2,
                explanation: "Jij bent aardig - 'zijn' with 'jij' becomes 'bent'",
                hint: "Remember the irregular form for 'jij'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'He has a car' in Dutch?",
                options: ["Hij heb een auto", "Hij hebt een auto", "Hij heeft een auto", "Hij hebben een auto"],
                correctAnswer: 2,
                explanation: "Hij heeft een auto - 'hebben' with 'hij' becomes 'heeft'",
                hint: "Remember the irregular form for 'hij'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'We go to school' in Dutch?",
                options: ["Wij ga naar school", "Wij gaat naar school", "Wij gaan naar school", "Wij ging naar school"],
                correctAnswer: 2,
                explanation: "Wij gaan naar school - 'gaan' with 'wij' becomes 'gaan'",
                hint: "Plural forms are more regular",
                exerciseType: .translation
            ),
            
            // Fill-in-the-blank exercises
            GrammarExercise(
                question: "Complete: 'Ik ___ student' (I am a student)",
                options: ["zij", "ben", "bent", "is"],
                correctAnswer: 1,
                explanation: "Ik ben student - 'zijn' with 'ik' becomes 'ben'",
                hint: "Remember the irregular form for 'ik'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een hond' (He has a dog)",
                options: ["heb", "hebt", "heeft", "hebben"],
                correctAnswer: 2,
                explanation: "Hij heeft een hond - 'hebben' with 'hij' becomes 'heeft'",
                hint: "Remember the irregular form for 'hij'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Jij ___ naar huis' (You go home)",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 1,
                explanation: "Jij gaat naar huis - 'gaan' with 'jij' becomes 'gaat'",
                hint: "Remember the irregular form for 'jij'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ tijd' (We have time)",
                options: ["heb", "hebt", "heeft", "hebben"],
                correctAnswer: 3,
                explanation: "Wij hebben tijd - 'hebben' with 'wij' becomes 'hebben'",
                hint: "Plural forms are more regular",
                exerciseType: .fillInTheBlank
            ),
            
            // True/False exercises
            GrammarExercise(
                question: "True or False: 'Ik ben' is correct Dutch for 'I am'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Ik ben' is correct - 'zijn' with 'ik' becomes 'ben'",
                hint: "Think about the irregular form for 'ik'",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Hij heb' is correct Dutch for 'He has'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Hij heeft'. 'Hebben' with 'hij' becomes 'heeft'",
                hint: "Remember the irregular form for 'hij'",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Jij gaat' is correct Dutch for 'You go'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Jij gaat' is correct - 'gaan' with 'jij' becomes 'gaat'",
                hint: "Think about the irregular form for 'jij'",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Wij zijn' is correct Dutch for 'We are'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Wij zijn' is correct - 'zijn' with 'wij' becomes 'zijn'",
                hint: "Think about the irregular form for 'wij'",
                exerciseType: .trueFalse
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik zij",
                correct: "Ik ben",
                explanation: "'Zijn' with 'ik' becomes 'ben', not 'zij'"
            ),
            CommonMistake(
                incorrect: "Hij heb",
                correct: "Hij heeft",
                explanation: "'Hebben' with 'hij' becomes 'heeft', not 'heb'"
            ),
            CommonMistake(
                incorrect: "Jij is",
                correct: "Jij bent",
                explanation: "'Zijn' with 'jij' becomes 'bent', not 'is'"
            ),
            CommonMistake(
                incorrect: "Ik gaat",
                correct: "Ik ga",
                explanation: "'Gaan' with 'ik' becomes 'ga', not 'gaat'"
            ),
            CommonMistake(
                incorrect: "Zij hebt",
                correct: "Zij heeft",
                explanation: "'Hebben' with 'zij' becomes 'heeft', not 'hebt'"
            )
        ],
        tips: [
            "Learn irregular verbs by heart - they don't follow rules",
            "Practice 'zijn' (to be) first - it's the most irregular",
            "Pay attention to spelling: 'heb' vs 'heeft'",
            "Remember: 'ik ben', 'jij bent', 'hij is'",
            "Remember: 'ik heb', 'jij hebt', 'hij heeft'",
            "Remember: 'ik ga', 'jij gaat', 'hij gaat'",
            "Use these verbs in real sentences to practice",
            "Listen to Dutch conversations to hear them used naturally"
        ],
        relatedRules: ["verb_present_a1", "verb_questions_a1", "verb_negation_a1"]
    )
    
    // MARK: - A2 Level Verb Conjugation Rules
    
    lazy var pastTenseA2 = DutchGrammarRule(
        id: "verb_past_a2",
        title: "Verleden Tijd - Regelmatige Werkwoorden (A2)",
        type: .verbConjugation,
        level: .a2,
        explanation: """
        De verleden tijd (imperfectum) gebruik je om te vertellen wat er in het verleden gebeurde. Voor regelmatige werkwoorden zijn er twee patronen:
        
        1. Werkwoorden eindigen op -de (zachte medeklinkers: v, z, l, m, n, r)
        2. Werkwoorden eindigen op -te (harde medeklinkers: p, t, k, f, s, ch)
        
        Ezelsbruggetje: "'t kofschip" voor harde medeklinkers (t, k, f, s, ch, p)
        
        Vervoegingen:
        • ik/jij/hij/zij: stam + de/te
        • wij/jullie/zij: stam + den/ten
        
        Let op: 'hebben' heeft een f-klank bij hij/zij: 'heeft'
        """,
        keyPoints: [
            "Twee patronen: -de of -te afhankelijk van laatste letter van de stam",
            "'t kofschip voor harde medeklinkers → -te",
            "Andere letters → -de",
            "Meervoud krijgt extra -n: -den/-ten",
            "Alle personen hebben dezelfde uitgang (behalve meervoud)"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik werkte gisteren.",
                english: "I worked yesterday.",
                breakdown: "werk + te (k is hard → 't kofschip)",
                audioHint: "ik vɛrktə"
            ),
            GrammarExample(
                dutch: "Zij speelde piano.",
                english: "She played piano.",
                breakdown: "speel + de (l is zacht → niet in 't kofschip)",
                audioHint: "zɛi speːldə"
            ),
            GrammarExample(
                dutch: "Wij kookten samen.",
                english: "We cooked together.",
                breakdown: "kook + ten (k is hard + meervoud)",
                audioHint: "vɛi koːktə(n)"
            ),
            GrammarExample(
                dutch: "Jullie leerden Nederlands.",
                english: "You learned Dutch.",
                breakdown: "leer + den (r is zacht + meervoud)",
                audioHint: "jɵli leːrdə(n)"
            ),
            GrammarExample(
                dutch: "Hij wandelde in het park.",
                english: "He walked in the park.",
                breakdown: "wandel + de (l is zacht)",
                audioHint: "hɛi vɑndəldə"
            ),
            GrammarExample(
                dutch: "Ik stopte bij het stoplicht.",
                english: "I stopped at the traffic light.",
                breakdown: "stop + te (p is hard → 't kofschip)",
                audioHint: "ik stɔptə"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Verleden tijd van 'maken': Ik ... gisteren een taart.",
                options: ["maakte", "maakde", "maken", "gemaakt"],
                correctAnswer: 0,
                explanation: "Maak + te (k is hard volgens 't kofschip)",
                hint: "Is de k hard of zacht? Denk aan 't kofschip"
            ),
            GrammarExercise(
                question: "Verleden tijd van 'wonen': Hij ... in Berlijn.",
                options: ["woonte", "woonde", "wonen", "gewoond"],
                correctAnswer: 1,
                explanation: "Woon + de (n is zacht, niet in 't kofschip)",
                hint: "Is de n hard of zacht?"
            ),
            GrammarExercise(
                question: "Verleden tijd van 'praten': Wij ... over het weer.",
                options: ["praatte", "praatde", "praatten", "praatden"],
                correctAnswer: 2,
                explanation: "Praat + ten (t is hard + meervoud krijgt -n)",
                hint: "Meervoud krijgt extra -n"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik maakde",
                correct: "Ik maakte",
                explanation: "K is hard ('t kofschip) dus gebruik -te, niet -de"
            ),
            CommonMistake(
                incorrect: "Hij woonte",
                correct: "Hij woonde",
                explanation: "N is zacht (niet in 't kofschip) dus gebruik -de"
            ),
            CommonMistake(
                incorrect: "Wij werkten niet → Wij werkte",
                correct: "Wij werkten",
                explanation: "Meervoud krijgt altijd -n erbij: -ten of -den"
            )
        ],
        tips: [
            "Leer 't kofschip uit je hoofd: t-k-o-f-s-ch-i-p",
            "Oefen met de stam: haal -en eraf en kijk naar de laatste letter",
            "Zachte letters (niet in 't kofschip) krijgen -de",
            "Harde letters ('t kofschip) krijgen -te",
            "Meervoud krijgt altijd een extra -n"
        ],
        relatedRules: ["verb_present_a1", "verb_perfect_a2", "verb_irregular_past_a2"]
    )
    
    lazy var verledenTijdA2 = DutchGrammarRule(
        id: "verleden_tijd_a2",
        title: "Verleden Tijd - Praktijk Oefening (A2)",
        type: .verbConjugation,
        level: .a2,
        explanation: """
        De verleden tijd (imperfectum) gebruik je om te vertellen wat er in het verleden gebeurde. Deze oefening focust op veelvoorkomende werkwoorden zoals 'gaan', 'zijn', 'combineren', 'besparen', 'vertrouwen', 'logeren', en 'verwennen'.
        
        Belangrijke regels:
        • Regelmatige werkwoorden: stam + de/te (volgens 't kofschip regel)
        • Onregelmatige werkwoorden: speciale vormen (gaan → ging, zijn → was/waren)
        • Meervoud krijgt extra -n: -den/-ten
        
        Onregelmatige werkwoorden in deze oefening:
        • gaan → ging/gingen
        • zijn → was/waren
        """,
        keyPoints: [
            "Regelmatige werkwoorden volgen 't kofschip regel",
            "Onregelmatige werkwoorden hebben speciale vormen",
            "Gaan → ging/gingen (onregelmatig werkwoord)",
            "Zijn → was/waren (onregelmatig werkwoord)",
            "Meervoud krijgt altijd -n erbij",
            "Let op de spelling van de stam"
        ],
        examples: [
            GrammarExample(
                dutch: "Gisteren ging ik naar de winkel.",
                english: "Yesterday I went to the store.",
                breakdown: "gaan → ging (onregelmatig werkwoord)",
                audioHint: "ɣɪstərə(n) ɣɪŋ ɪk naːr də vɪŋkəl"
            ),
            GrammarExample(
                dutch: "Vorig jaar waren we in Nederland.",
                english: "Last year we were in the Netherlands.",
                breakdown: "zijn → waren (onregelmatig, meervoud)",
                audioHint: "voːrəx jaːr vaːrə(n) və ɪn neːdərlɑnt"
            ),
            GrammarExample(
                dutch: "Hij combineerde de kleuren goed.",
                english: "He combined the colors well.",
                breakdown: "combineer + de (r is zacht)",
                audioHint: "hɛi kɔmbiːneːrdə də kleːrə(n) ɣut"
            ),
            GrammarExample(
                dutch: "Zij bespaarde veel geld.",
                english: "She saved a lot of money.",
                breakdown: "bespaar + de (r is zacht)",
                audioHint: "zɛi bəspaːrdə veːl ɣɛlt"
            ),
            GrammarExample(
                dutch: "Wij vertrouwden op elkaar.",
                english: "We trusted each other.",
                breakdown: "vertrouw + den (w is zacht + meervoud)",
                audioHint: "vɛi vərtrɑudə(n) ɔp əlkaːr"
            ),
            GrammarExample(
                dutch: "Jullie logeerden in een hotel.",
                english: "You stayed in a hotel.",
                breakdown: "logeer + den (r is zacht + meervoud)",
                audioHint: "jɵli loːɣeːrdə(n) ɪn ən hoːtɛl"
            ),
            GrammarExample(
                dutch: "Hij verwende zijn kinderen.",
                english: "He spoiled his children.",
                breakdown: "verwen + de (n is zacht)",
                audioHint: "hɛi vərvɛndə zɛin kɪndərə(n)"
            ),
            GrammarExample(
                dutch: "Ik ging naar de winkel.",
                english: "I went to the store.",
                breakdown: "gaan → ging (onregelmatig werkwoord)",
                audioHint: "ɪk ɣɪŋ naːr də vɪŋkəl"
            ),
            GrammarExample(
                dutch: "Zij meldde zich voor de cursus.",
                english: "She registered for the course.",
                breakdown: "meld + de (d is zacht)",
                audioHint: "zɛi mɛldə zɛix voːr də kɵrsɵs"
            ),
            GrammarExample(
                dutch: "Ik werk in een kantoor.",
                english: "I work in an office.",
                breakdown: "werk (stem) - no ending for 'ik'",
                audioHint: "ik vɛrk"
            ),
            GrammarExample(
                dutch: "Jij werkt hard.",
                english: "You work hard.",
                breakdown: "werk (stem) + t = werkt",
                audioHint: "jɛi vɛrkt"
            ),
            GrammarExample(
                dutch: "Hij woont in Amsterdam.",
                english: "He lives in Amsterdam.",
                breakdown: "woon (stem) + t = woont",
                audioHint: "hɛi voːnt"
            ),
            GrammarExample(
                dutch: "Wij leren Nederlands.",
                english: "We learn Dutch.",
                breakdown: "leren (whole verb) - no change",
                audioHint: "vɛi leːrə(n)"
            ),
            GrammarExample(
                dutch: "Jullie spelen voetbal.",
                english: "You (plural) play football.",
                breakdown: "spelen (whole verb) - no change",
                audioHint: "jɵli speːlə(n)"
            ),
            GrammarExample(
                dutch: "Zij koken samen.",
                english: "They cook together.",
                breakdown: "koken (whole verb) - no change",
                audioHint: "zɛi koːkə(n)"
            )
        ],
        exercises: [
            // Basic conjugation exercises
            GrammarExercise(
                question: "Conjugation of 'maken' (to make): Ik ... elke dag huiswerk.",
                options: ["maak", "maakt", "maken", "maakte"],
                correctAnswer: 0,
                explanation: "For 'ik' use only the stem: maak (maken - en = maak)",
                hint: "For 'ik' use no ending"
            ),
            GrammarExercise(
                question: "Conjugation of 'wonen' (to live): Hij ... in Utrecht.",
                options: ["woon", "woont", "wonen", "woonde"],
                correctAnswer: 1,
                explanation: "For 'hij' use stem + t: woon + t = woont",
                hint: "For 'hij/zij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'studeren' (to study): Wij ... aan de universiteit.",
                options: ["studeer", "studeert", "studeren", "studeerde"],
                correctAnswer: 2,
                explanation: "For 'wij' use the whole verb: studeren",
                hint: "For 'wij/jullie/zij' use the infinitive"
            ),
            GrammarExercise(
                question: "Conjugation of 'spelen' (to play): Jij ... voetbal.",
                options: ["speel", "speelt", "spelen", "speelde"],
                correctAnswer: 1,
                explanation: "For 'jij' use stem + t: speel + t = speelt",
                hint: "For 'jij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'koken' (to cook): Zij ... elke avond.",
                options: ["kook", "kookt", "koken", "kookte"],
                correctAnswer: 1,
                explanation: "For 'zij' use stem + t: kook + t = kookt",
                hint: "For 'zij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'leren' (to learn): Jullie ... Nederlands.",
                options: ["leer", "leert", "leren", "leerde"],
                correctAnswer: 2,
                explanation: "For 'jullie' use the whole verb: leren",
                hint: "For 'jullie' use the infinitive"
            ),
            GrammarExercise(
                question: "Conjugation of 'werken' (to work): Zij ... in een kantoor.",
                options: ["werk", "werkt", "werken", "werkten"],
                correctAnswer: 1,
                explanation: "For 'zij' use stem + t: werk + t = werkt",
                hint: "For 'zij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'lezen' (to read): Ik ... een boek.",
                options: ["lees", "leest", "lezen", "las"],
                correctAnswer: 0,
                explanation: "For 'ik' use only the stem: lees (lezen - en = lees)",
                hint: "For 'ik' use no ending"
            ),
            GrammarExercise(
                question: "Conjugation of 'schrijven' (to write): Hij ... een brief.",
                options: ["schrijf", "schrijft", "schrijven", "schreef"],
                correctAnswer: 1,
                explanation: "For 'hij' use stem + t: schrijf + t = schrijft",
                hint: "For 'hij' add -t to the stem"
            ),
            GrammarExercise(
                question: "Conjugation of 'luisteren' (to listen): Wij ... naar muziek.",
                options: ["luister", "luistert", "luisteren", "luisterde"],
                correctAnswer: 2,
                explanation: "For 'wij' use the whole verb: luisteren",
                hint: "For 'wij' use the infinitive"
            ),
            
            // Translation exercises
            GrammarExercise(
                question: "How do you say 'I work in Amsterdam' in Dutch?",
                options: ["Ik werk in Amsterdam", "Ik werkt in Amsterdam", "Ik werken in Amsterdam", "Ik werkte in Amsterdam"],
                correctAnswer: 0,
                explanation: "Ik werk in Amsterdam - 'werk' is the stem form for 'ik'",
                hint: "Remember: 'ik' uses the stem without any ending",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'She lives in Utrecht' in Dutch?",
                options: ["Zij woon in Utrecht", "Zij woont in Utrecht", "Zij wonen in Utrecht", "Zij woonde in Utrecht"],
                correctAnswer: 1,
                explanation: "Zij woont in Utrecht - 'woont' adds -t for 'hij/zij'",
                hint: "Remember: 'hij/zij' adds -t to the stem",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'We study Dutch' in Dutch?",
                options: ["Wij studeer Nederlands", "Wij studeert Nederlands", "Wij studeren Nederlands", "Wij studeerde Nederlands"],
                correctAnswer: 2,
                explanation: "Wij studeren Nederlands - 'wij' uses the whole verb",
                hint: "Remember: 'wij' uses the infinitive",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'You play football' in Dutch?",
                options: ["Jij speel voetbal", "Jij speelt voetbal", "Jij spelen voetbal", "Jij speelde voetbal"],
                correctAnswer: 1,
                explanation: "Jij speelt voetbal - 'jij' adds -t to the stem",
                hint: "Remember: 'jij' adds -t to the stem",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'They cook dinner' in Dutch?",
                options: ["Zij kook avondeten", "Zij kookt avondeten", "Zij koken avondeten", "Zij kookte avondeten"],
                correctAnswer: 1,
                explanation: "Zij kookt avondeten - 'zij' adds -t to the stem",
                hint: "Remember: 'zij' adds -t to the stem",
                exerciseType: .translation
            ),
            
            // Fill-in-the-blank exercises
            GrammarExercise(
                question: "Complete: 'Ik ___ elke dag naar school' (I go to school every day)",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 0,
                explanation: "Ik ga elke dag naar school - 'ga' is the stem form for 'ik'",
                hint: "This is the present tense, and 'ik' uses the stem",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een boek' (He reads a book)",
                options: ["lees", "leest", "lezen", "las"],
                correctAnswer: 1,
                explanation: "Hij leest een boek - 'hij' adds -t to the stem",
                hint: "For 'hij' add -t to the stem",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ Nederlands' (We learn Dutch)",
                options: ["leer", "leert", "leren", "leerde"],
                correctAnswer: 2,
                explanation: "Wij leren Nederlands - 'wij' uses the whole verb",
                hint: "For 'wij' use the infinitive",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Jullie ___ naar muziek' (You listen to music)",
                options: ["luister", "luistert", "luisteren", "luisterde"],
                correctAnswer: 2,
                explanation: "Jullie luisteren naar muziek - 'jullie' uses the whole verb",
                hint: "For 'jullie' use the infinitive",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een brief' (She writes a letter)",
                options: ["schrijf", "schrijft", "schrijven", "schreef"],
                correctAnswer: 1,
                explanation: "Zij schrijft een brief - 'zij' adds -t to the stem",
                hint: "For 'zij' add -t to the stem",
                exerciseType: .fillInTheBlank
            ),
            
            // True/False exercises
            GrammarExercise(
                question: "True or False: 'Hij werkt' is correct Dutch for 'He works'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Hij werkt' is correct - 'hij' + stem + t",
                hint: "Think about the conjugation rule for 'hij'",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Ik woont' is correct Dutch for 'I live'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik woon'. 'Ik' uses only the stem, no -t",
                hint: "Remember: 'ik' uses no ending",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Wij studeert' is correct Dutch for 'We study'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Wij studeren'. 'Wij' uses the whole verb",
                hint: "Remember: 'wij' uses the infinitive",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Jij speelt' is correct Dutch for 'You play'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Jij speelt' is correct - 'jij' + stem + t",
                hint: "Think about the conjugation rule for 'jij'",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Zij koken' is correct Dutch for 'They cook'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Zij koken' is correct - 'zij' uses the whole verb",
                hint: "Think about the conjugation rule for 'zij' (plural)",
                exerciseType: .trueFalse
            ),
            
            // Question form exercises
            GrammarExercise(
                question: "How do you ask 'Do you work?' in Dutch?",
                options: ["Werk jij?", "Werkt jij?", "Werk je?", "Werkt je?"],
                correctAnswer: 0,
                explanation: "Werk jij? - In questions with 'jij', the verb doesn't get an extra -t",
                hint: "Remember the special rule for questions with 'jij'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you ask 'Do you live here?' in Dutch?",
                options: ["Woon jij hier?", "Woon je hier?", "Woont jij hier?", "Woont je hier?"],
                correctAnswer: 0,
                explanation: "Woon jij hier? - In questions, 'jij' doesn't get extra -t",
                hint: "Remember the question rule for 'jij'",
                exerciseType: .translation
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik maakde een fout",
                correct: "Ik maakte een fout",
                explanation: "maken → maak. K is in 't kofschip, so use -TE: maakte (not -DE)"
            ),
            CommonMistake(
                incorrect: "Hij woonte in Utrecht",
                correct: "Hij woonde in Utrecht",
                explanation: "wonen → woon. N is NOT in 't kofschip, so use -DE: woonde (not -TE)"
            ),
            CommonMistake(
                incorrect: "Zij levfte in Parijs",
                correct: "Zij leefde in Parijs",
                explanation: "leven → leef (F becomes V!). Stem ends in F, so use -DE: leefde"
            ),
            CommonMistake(
                incorrect: "Wij reiste naar Spanje",
                correct: "Wij reisden naar Spanje",
                explanation: "reizen → reis (Z becomes S!). Stem ends in S from Z, so use -DE: reisden"
            ),
            CommonMistake(
                incorrect: "De bus stopde",
                correct: "De bus stopte",
                explanation: "stoppen → stop. P is in 't kofschip, so use -TE: stopte (not -DE)"
            ),
            CommonMistake(
                incorrect: "Ik speelte gitaar",
                correct: "Ik speelde gitaar",
                explanation: "spelen → speel. L is NOT in 't kofschip, so use -DE: speelde (not -TE)"
            )
        ],
        tips: [
            "Learn 't kofschip by heart: T-K-O-F-S-CH-P (like coffee ship)",
            "First make the stem: remove -en from the infinitive",
            "Watch for F→V and Z→S changes in the stem",
            "Double letters become single: stoppen → stop",
            "Practice with many examples until it becomes automatic",
            "When in doubt: say it out loud - often you can hear the difference"
        ],
        relatedRules: ["verb_past_a2", "verb_perfect_b1", "auxiliary_verbs_b1"]
    )
    
    lazy var fixedWordCombinationsB1 = DutchGrammarRule(
        id: "fixed_word_combinations_b1",
        title: "Fixed Word Combinations (Vaste Woordcombinaties) - B1",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        Fixed word combinations are words that are used together with a specific verb. These combinations cannot be translated literally - you must learn them by heart. Some words can only be used with specific verbs.
        
        For example:
        • naar huis gaan (go home)
        • een beslissing nemen (make a decision)
        • een fout maken (make a mistake)
        
        These combinations are called fixed word combinations. Learn the combinations by heart.
        
        IMPORTANT PATTERNS:
        
        1. HEBBEN + noun:
        • heimwee hebben (be homesick)
        • haast hebben (be in a hurry)
        • honger hebben (be hungry)
        • pijn hebben (be in pain)
        • geluk hebben (be lucky)
        • een idee hebben (have an idea)
        
        2. KRIJGEN + noun:
        • een baan krijgen (get a job)
        • een kind krijgen (have a baby)
        • het koud krijgen (get cold)
        
        3. MAKEN + noun:
        • een afspraak maken (make an appointment)
        • een fout maken (make a mistake)
        • problemen maken (cause problems)
        
        4. NEMEN + noun:
        • een beslissing nemen (make a decision)
        • je rijbewijs halen (get your driver's license)
        
        5. ZIJN + adjective/noun:
        • ziek zijn (be sick)
        • in dienst komen (start working)
        • lid zijn van (be a member of)
        
        6. GAAN + direction/activity:
        • naar huis gaan (go home)
        • stage lopen (do an internship)
        
        7. GEVEN + noun:
        • antwoord geven (give an answer)
        • een opleiding doen/volgen (do/follow education)
        
        These combinations are different from English, so you must learn them specifically!
        """,
        keyPoints: [
            "Fixed word combinations must be learned by heart",
            "They are often different from English",
            "Most important patterns: hebben + noun, maken + noun, nemen + noun",
            "Krijgen, zijn, gaan, geven also have fixed combinations",
            "Always use the correct verb with each combination",
            "Very important for natural-sounding Dutch"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik heb heimwee naar mijn familie.",
                english: "I am homesick for my family.",
                breakdown: "heimwee hebben = be homesick (not 'zijn heimwee')",
                audioHint: "ik hɛp hɛimveː naːr mɛin faːmili"
            )
        ],
                exercises: [
            // Category 1: Common Expressions with HEBBEN
            GrammarExercise(
                question: "Complete: 'Ik ___ haast, ik moet naar werk' (I'm in a hurry)",
                options: ["ben", "heb", "ga", "doe"],
                correctAnswer: 1,
                explanation: "Dutch uses 'haast HEBBEN' (to have haste) instead of 'to be in a hurry': 'Ik heb haast'.",
                hint: "Dutch uses HEBBEN for this feeling"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ honger na het sporten' (He gets hungry after sports)",
                options: ["is", "krijgt", "wordt", "doet"],
                correctAnswer: 1,
                explanation: "'Honger KRIJGEN' means 'to get hungry'. Dutch uses KRIJGEN for acquiring feelings.",
                hint: "Think about acquiring the feeling"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ pijn in mijn rug' (I have pain in my back)",
                options: ["ben", "heb", "voel", "krijg"],
                correctAnswer: 1,
                explanation: "Dutch uses 'pijn HEBBEN' (to have pain): 'Ik heb pijn in mijn rug'.",
                hint: "Dutch uses HEBBEN for pain"
            ),
            
            // Category 2: Expressions with Specific Verbs
            GrammarExercise(
                question: "Complete: 'Wij ___ een afspraak met de dokter' (We make an appointment with the doctor)",
                options: ["doen", "maken", "hebben", "krijgen"],
                correctAnswer: 1,
                explanation: "Dutch uses 'een afspraak MAKEN' (to make an appointment): 'Wij maken een afspraak'.",
                hint: "Think about creating the appointment"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ zijn rijbewijs vorige maand' (He got his driver's license last month)",
                options: ["maakte", "kreeg", "had", "nam"],
                correctAnswer: 1,
                explanation: "Dutch uses 'zijn rijbewijs KRIJGEN' (to get/receive one's license): 'Hij kreeg zijn rijbewijs'.",
                hint: "Think about receiving the license"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een baan als lerares' (She got a job as a teacher)",
                options: ["maakte", "kreeg", "had", "deed"],
                correctAnswer: 1,
                explanation: "Dutch uses 'een baan KRIJGEN' (to get a job): 'Zij kreeg een baan'.",
                hint: "Think about obtaining the job"
            ),
            
            // Category 3: Status and Membership Expressions
            GrammarExercise(
                question: "Complete: 'Wij ___ lid van de sportclub' (We are members of the sports club)",
                options: ["zijn", "hebben", "worden", "maken"],
                correctAnswer: 0,
                explanation: "Dutch uses 'lid ZIJN van' (to be a member of): 'Wij zijn lid van de sportclub'.",
                hint: "Think about your status"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ in dienst bij een groot bedrijf' (He starts working at a big company)",
                options: ["gaat", "komt", "wordt", "doet"],
                correctAnswer: 0,
                explanation: "Dutch uses 'in dienst GAAN' (to go into service/start working): 'Hij gaat in dienst'.",
                hint: "Think about starting work"
            ),
            
            // Category 4: Problem and Luck Expressions
            GrammarExercise(
                question: "Complete: 'Wij ___ problemen met de computer' (We're having problems with the computer)",
                options: ["zijn", "hebben", "krijgen", "maken"],
                correctAnswer: 1,
                explanation: "Dutch uses 'problemen HEBBEN' (to have problems): 'Wij hebben problemen'.",
                hint: "Think about possessing the problems"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ geluk met het weer' (I'm lucky with the weather)",
                options: ["ben", "heb", "krijg", "ga"],
                correctAnswer: 1,
                explanation: "Dutch uses 'geluk HEBBEN' (to have luck): 'Ik heb geluk met het weer'.",
                hint: "Think about possessing luck"
            ),
            
            // Category 5: Weather and Physical Sensations
            GrammarExercise(
                question: "Complete: 'Ik ___ het koud buiten' (I'm getting cold outside)",
                options: ["ben", "heb", "krijg", "word"],
                correctAnswer: 2,
                explanation: "Dutch uses 'het koud KRIJGEN' (to get cold): 'Ik krijg het koud'.",
                hint: "Think about acquiring the cold feeling"
            ),
            
            // Category 6: Multiple Choice Context
            GrammarExercise(
                question: "Which is correct for 'I'm thirsty'?",
                options: ["Ik ben dorstig", "Ik heb dorst", "Ik krijg dorst", "Ik word dorstig"],
                correctAnswer: 1,
                explanation: "Dutch uses 'dorst HEBBEN' (to have thirst): 'Ik heb dorst', not 'Ik ben dorstig'.",
                hint: "Dutch uses HEBBEN for thirst"
            ),
            
            // NEW: Translation Exercises
            GrammarExercise(
                question: "How do you say 'I'm tired' in Dutch?",
                options: ["Ik ben moe", "Ik heb moe", "Ik krijg moe", "Ik word moe"],
                correctAnswer: 0,
                explanation: "Ik ben moe - 'moe zijn' means to be tired",
                hint: "Think about the state of being tired",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'I have a headache' in Dutch?",
                options: ["Ik ben hoofdpijn", "Ik heb hoofdpijn", "Ik krijg hoofdpijn", "Ik word hoofdpijn"],
                correctAnswer: 1,
                explanation: "Ik heb hoofdpijn - 'hoofdpijn hebben' means to have a headache",
                hint: "Think about possessing the pain",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'We are making a mistake' in Dutch?",
                options: ["Wij zijn een fout", "Wij hebben een fout", "Wij maken een fout", "Wij doen een fout"],
                correctAnswer: 2,
                explanation: "Wij maken een fout - 'een fout maken' means to make a mistake",
                hint: "Think about creating the mistake",
                exerciseType: .translation
            ),
            
            // NEW: Fill-in-the-Blank Exercises
            GrammarExercise(
                question: "Complete: 'Ik ___ zin om te gaan' (I feel like going)",
                options: ["ben", "heb", "krijg", "word"],
                correctAnswer: 1,
                explanation: "Ik heb zin om te gaan - 'zin hebben om te' means feel like doing",
                hint: "Think about possessing the desire",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een beslissing' (He makes a decision)",
                options: ["maakt", "neemt", "heeft", "doet"],
                correctAnswer: 1,
                explanation: "Hij neemt een beslissing - 'een beslissing nemen' means to make a decision",
                hint: "Think about taking the decision",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ stage bij een bedrijf' (She does an internship at a company)",
                options: ["doet", "maakt", "loopt", "heeft"],
                correctAnswer: 2,
                explanation: "Zij loopt stage bij een bedrijf - 'stage lopen' means to do an internship",
                hint: "Think about the fixed expression for internships",
                exerciseType: .fillInTheBlank
            ),
            
            // NEW: True/False Exercises
            GrammarExercise(
                question: "True or False: 'Ik ben honger' is correct Dutch for 'I'm hungry'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik heb honger'. Dutch uses 'honger hebben', not 'honger zijn'.",
                hint: "Remember the HEBBEN pattern for feelings",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Hij maakt een beslissing' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Hij neemt een beslissing'. Dutch uses 'een beslissing nemen', not 'maken'.",
                hint: "Remember the fixed verb for decisions",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Wij zijn lid van de club' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Lid zijn van' is the correct Dutch expression for being a member.",
                hint: "This follows the correct pattern",
                exerciseType: .trueFalse
            ),
            
            // NEW: Context-Based Questions
            GrammarExercise(
                question: "When you're sick, how do you say 'I have a fever'?",
                options: ["Ik ben koorts", "Ik heb koorts", "Ik krijg koorts", "Ik word koorts"],
                correctAnswer: 1,
                explanation: "Ik heb koorts - 'koorts hebben' means to have a fever",
                hint: "Think about possessing the fever",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "When you're right about something, how do you say 'I'm right'?",
                options: ["Ik ben gelijk", "Ik heb gelijk", "Ik krijg gelijk", "Ik word gelijk"],
                correctAnswer: 1,
                explanation: "Ik heb gelijk - 'gelijk hebben' means to be right",
                hint: "Think about possessing the rightness",
                exerciseType: .translation
            ),
            
            // ADDITIONAL EXERCISES - DOUBLING THE AMOUNT
            
            // More HEBBEN expressions
            GrammarExercise(
                question: "Complete: 'Ik ___ geen tijd om te praten' (I don't have time to talk)",
                options: ["ben", "heb", "krijg", "word"],
                correctAnswer: 1,
                explanation: "Ik heb geen tijd - 'tijd hebben' means to have time",
                hint: "Think about possessing time"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een hekel aan kou' (She dislikes the cold)",
                options: ["is", "heeft", "krijgt", "wordt"],
                correctAnswer: 1,
                explanation: "Zij heeft een hekel aan kou - 'een hekel hebben aan' means to dislike",
                hint: "Think about possessing the dislike"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ geen geld meer' (We don't have money anymore)",
                options: ["zijn", "hebben", "krijgen", "worden"],
                correctAnswer: 1,
                explanation: "Wij hebben geen geld meer - 'geld hebben' means to have money",
                hint: "Think about possessing money"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een vraag voor je' (He has a question for you)",
                options: ["is", "heeft", "krijgt", "wordt"],
                correctAnswer: 1,
                explanation: "Hij heeft een vraag voor je - 'een vraag hebben' means to have a question",
                hint: "Think about possessing the question"
            ),
            
            // More KRIJGEN expressions
            GrammarExercise(
                question: "Complete: 'Ik ___ een cadeau van mijn ouders' (I get a gift from my parents)",
                options: ["ben", "heb", "krijg", "word"],
                correctAnswer: 2,
                explanation: "Ik krijg een cadeau - 'een cadeau krijgen' means to receive a gift",
                hint: "Think about receiving something"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een ongeluk op de snelweg' (She has an accident on the highway)",
                options: ["is", "heeft", "krijgt", "wordt"],
                correctAnswer: 2,
                explanation: "Zij krijgt een ongeluk - 'een ongeluk krijgen' means to have an accident",
                hint: "Think about experiencing an accident"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ een telefoontje van de dokter' (We get a call from the doctor)",
                options: ["zijn", "hebben", "krijgen", "worden"],
                correctAnswer: 2,
                explanation: "Wij krijgen een telefoontje - 'een telefoontje krijgen' means to receive a call",
                hint: "Think about receiving a phone call"
            ),
            
            // More MAKEN expressions
            GrammarExercise(
                question: "Complete: 'Hij ___ een grap over de situatie' (He makes a joke about the situation)",
                options: ["is", "heeft", "maakt", "doet"],
                correctAnswer: 2,
                explanation: "Hij maakt een grap - 'een grap maken' means to make a joke",
                hint: "Think about creating a joke"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een foto van de kinderen' (She takes a photo of the children)",
                options: ["is", "heeft", "maakt", "doet"],
                correctAnswer: 2,
                explanation: "Zij maakt een foto - 'een foto maken' means to take a photo",
                hint: "Think about creating a photo"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ een wandeling in het park' (We take a walk in the park)",
                options: ["zijn", "hebben", "maken", "doen"],
                correctAnswer: 2,
                explanation: "Wij maken een wandeling - 'een wandeling maken' means to take a walk",
                hint: "Think about creating the walk"
            ),
            
            // More NEMEN expressions
            GrammarExercise(
                question: "Complete: 'Ik ___ een douche na het sporten' (I take a shower after sports)",
                options: ["ben", "heb", "maak", "neem"],
                correctAnswer: 3,
                explanation: "Ik neem een douche - 'een douche nemen' means to take a shower",
                hint: "Think about taking the shower"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een pauze van het werk' (He takes a break from work)",
                options: ["is", "heeft", "maakt", "neemt"],
                correctAnswer: 3,
                explanation: "Hij neemt een pauze - 'een pauze nemen' means to take a break",
                hint: "Think about taking the break"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ de tijd om na te denken' (She takes time to think)",
                options: ["is", "heeft", "maakt", "neemt"],
                correctAnswer: 3,
                explanation: "Zij neemt de tijd - 'de tijd nemen' means to take time",
                hint: "Think about taking the time"
            ),
            
            // More ZIJN expressions
            GrammarExercise(
                question: "Complete: 'Ik ___ klaar met mijn huiswerk' (I'm finished with my homework)",
                options: ["ben", "heb", "word", "doe"],
                correctAnswer: 0,
                explanation: "Ik ben klaar - 'klaar zijn' means to be finished",
                hint: "Think about the state of being finished"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ verbaasd over het nieuws' (He's surprised about the news)",
                options: ["is", "heeft", "wordt", "doet"],
                correctAnswer: 0,
                explanation: "Hij is verbaasd - 'verbaasd zijn' means to be surprised",
                hint: "Think about the state of being surprised"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ tevreden met het resultaat' (We're satisfied with the result)",
                options: ["zijn", "hebben", "worden", "doen"],
                correctAnswer: 0,
                explanation: "Wij zijn tevreden - 'tevreden zijn' means to be satisfied",
                hint: "Think about the state of being satisfied"
            ),
            
            // More GAAN expressions
            GrammarExercise(
                question: "Complete: 'Ik ___ naar bed om tien uur' (I go to bed at ten o'clock)",
                options: ["ben", "heb", "ga", "doe"],
                correctAnswer: 2,
                explanation: "Ik ga naar bed - 'naar bed gaan' means to go to bed",
                hint: "Think about the direction of going"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ op vakantie naar Spanje' (She goes on vacation to Spain)",
                options: ["is", "heeft", "gaat", "doet"],
                correctAnswer: 2,
                explanation: "Zij gaat op vakantie - 'op vakantie gaan' means to go on vacation",
                hint: "Think about the activity of going"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ uit eten vanavond' (We go out to eat tonight)",
                options: ["zijn", "hebben", "gaan", "doen"],
                correctAnswer: 2,
                explanation: "Wij gaan uit eten - 'uit eten gaan' means to go out to eat",
                hint: "Think about the activity of going out"
            ),
            
            // More GEVEN expressions
            GrammarExercise(
                question: "Complete: 'Ik ___ je een voorbeeld' (I give you an example)",
                options: ["ben", "heb", "geef", "doe"],
                correctAnswer: 2,
                explanation: "Ik geef je een voorbeeld - 'een voorbeeld geven' means to give an example",
                hint: "Think about providing an example"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een presentatie over het project' (He gives a presentation about the project)",
                options: ["is", "heeft", "geeft", "doet"],
                correctAnswer: 2,
                explanation: "Hij geeft een presentatie - 'een presentatie geven' means to give a presentation",
                hint: "Think about providing the presentation"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ les aan de universiteit' (She teaches at the university)",
                options: ["is", "heeft", "geeft", "doet"],
                correctAnswer: 2,
                explanation: "Zij geeft les - 'les geven' means to teach",
                hint: "Think about providing the lesson"
            ),
            
            // More complex scenarios
            GrammarExercise(
                question: "Complete: 'Ik ___ een afspraak met de dokter omdat ik ___ hoofdpijn' (I make an appointment with the doctor because I have a headache)",
                options: ["maak, heb", "neem, ben", "heb, maak", "ben, neem"],
                correctAnswer: 0,
                explanation: "Ik maak een afspraak omdat ik hoofdpijn heb - 'afspraak maken' and 'hoofdpijn hebben'",
                hint: "Think about creating appointment and possessing pain"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een beslissing nadat hij ___ tijd om na te denken' (He makes a decision after he takes time to think)",
                options: ["maakt, neemt", "neemt, neemt", "heeft, heeft", "doet, doet"],
                correctAnswer: 1,
                explanation: "Hij neemt een beslissing nadat hij de tijd neemt - 'beslissing nemen' and 'tijd nemen'",
                hint: "Think about taking both the decision and the time"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ lid van de club en ___ stage bij een bedrijf' (We are members of the club and do an internship at a company)",
                options: ["zijn, lopen", "hebben, doen", "worden, maken", "gaan, nemen"],
                correctAnswer: 0,
                explanation: "Wij zijn lid van de club en lopen stage - 'lid zijn van' and 'stage lopen'",
                hint: "Think about being a member and doing the internship"
            ),
            
            // Translation exercises with context
            GrammarExercise(
                question: "How do you say 'I'm going home' in Dutch?",
                options: ["Ik ben thuis", "Ik ga naar huis", "Ik heb thuis", "Ik word thuis"],
                correctAnswer: 1,
                explanation: "Ik ga naar huis - 'naar huis gaan' means to go home",
                hint: "Think about the direction of going",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'She's taking a break' in Dutch?",
                options: ["Zij is een pauze", "Zij heeft een pauze", "Zij neemt een pauze", "Zij maakt een pauze"],
                correctAnswer: 2,
                explanation: "Zij neemt een pauze - 'een pauze nemen' means to take a break",
                hint: "Think about taking the break",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'We're making progress' in Dutch?",
                options: ["Wij zijn vooruitgang", "Wij hebben vooruitgang", "Wij maken vooruitgang", "Wij doen vooruitgang"],
                correctAnswer: 2,
                explanation: "Wij maken vooruitgang - 'vooruitgang maken' means to make progress",
                hint: "Think about creating progress",
                exerciseType: .translation
            ),
            
            // True/False exercises with explanations
            GrammarExercise(
                question: "True or False: 'Ik ben een afspraak' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik maak een afspraak'. Dutch uses 'een afspraak maken', not 'zijn'.",
                hint: "Remember the MAKEN pattern for appointments",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Hij heeft een beslissing' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Hij neemt een beslissing'. Dutch uses 'een beslissing nemen', not 'hebben'.",
                hint: "Remember the NEMEN pattern for decisions",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Zij doet stage' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Zij loopt stage'. Dutch uses 'stage lopen', not 'doen'.",
                hint: "Remember the LOPEN pattern for internships",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Wij zijn een wandeling' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Wij maken een wandeling'. Dutch uses 'een wandeling maken', not 'zijn'.",
                hint: "Remember the MAKEN pattern for walks",
                exerciseType: .trueFalse
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik ben haast",
                correct: "Ik heb haast",
                explanation: "In Dutch you HAVE hurry, not ARE hurry. 'Haast hebben' = be in a hurry."
            ),
            CommonMistake(
                incorrect: "Zij maakt een beslissing",
                correct: "Zij neemt een beslissing",
                explanation: "In Dutch you TAKE a decision, not MAKE it. 'Een beslissing nemen'."
            ),
            CommonMistake(
                incorrect: "Hij is honger",
                correct: "Hij heeft honger",
                explanation: "In Dutch you HAVE hunger, not ARE hunger. 'Honger hebben' = be hungry."
            ),
            CommonMistake(
                incorrect: "Ik ben pijn",
                correct: "Ik heb pijn",
                explanation: "In Dutch you HAVE pain, not ARE pain. 'Pijn hebben' = be in pain."
            ),
            CommonMistake(
                incorrect: "Wij doen stage",
                correct: "Wij lopen stage",
                explanation: "In Dutch you 'walk' an internship, not 'do' it. 'Stage lopen'."
            ),
            CommonMistake(
                incorrect: "Hij is gelijk",
                correct: "Hij heeft gelijk",
                explanation: "In Dutch you HAVE right, not ARE right. 'Gelijk hebben' = be right."
            )
        ],
        tips: [
            "Learn fixed word combinations as complete units, not word by word",
            "Note: Dutch combinations are often different from English",
            "Practice with 'hebben + feeling': honger/dorst/pijn/haast/geluk hebben",
            "Remember: beslissing nemen (not maken), afspraak maken (not nemen)",
            "Use dictionaries that show collocations",
            "Listen to Dutch conversations to learn natural combinations"
        ],
        relatedRules: ["auxiliary_verbs_b1", "verbs_fixed_prepositions_b1", "verb_present_a1"]
    )
    
    lazy var tKofschipRuleB1 = DutchGrammarRule(
        id: "t_kofschip_rule_b1",
        title: "'t Kofschip Rule - Past Tense Endings (B1)",
        type: .spelling,
        level: .b1,
        explanation: """
        The 't Kofschip rule helps you determine whether a Dutch verb in the past tense ends with -TE or -DE. This rule is essential for correct spelling and pronunciation of Dutch verbs.
        
        THE RULE:
        Look at the last letter of the stem (infinitive minus -en):
        
        🚢 'T KOFSCHIP letters → -TE endings
        T - K - O - F - S - CH - P
        
        All other letters → -DE endings
        
        EXAMPLES:
        • werken → werk (k = 't kofschip) → werkte, werkten
        • maken → maak (k = 't kofschip) → maakte, maakten
        • wonen → woon (n ≠ 't kofschip) → woonde, woonden
        • spelen → speel (l ≠ 't kofschip) → speelde, speelden
        
        SPECIAL CASES:
        • F becomes V: leven → leef → leefde (F→V transformation)
        • S becomes Z: reizen → reis → reisde (Z→S transformation)  
        • Double consonants become single: stoppen → stop → stopte
        
        MEMORY TRICK:
        Think of 't kofschip (coffee ship) sailing the seas. If the stem ends in any letter from this ship, use -TE. Otherwise, use -DE.
        
        This rule applies to:
        • Simple past tense (imperfectum)
        • Past participles (when regular)
        • All regular Dutch verbs
        """,
        keyPoints: [
            "'t Kofschip letters (T-K-O-F-S-CH-P) get -TE endings",
            "All other letters get -DE endings",
            "Find the stem by removing -en from infinitive",
            "Watch for F→V and Z→S changes in stems",
            "Double consonants become single in the stem",
            "Essential for correct Dutch past tense spelling"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik maakte gisteren een taart.",
                english: "I made a cake yesterday.",
                breakdown: "maken → maak. K is in 't kofschip, so use -TE: maakte",
                audioHint: "ik maːktə xɪstərə(n) ən taːrt"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Past tense of 'maken': Ik ___ gisteren een taart (I made a cake yesterday)",
                options: ["maakte", "maakde", "makete", "makede"],
                correctAnswer: 0,
                explanation: "maken → maak. K is in 't kofschip, so use -TE: maakte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'wonen': Hij ___ in Amsterdam (He lived in Amsterdam)",
                options: ["woonte", "woonde", "wonete", "wonede"],
                correctAnswer: 1,
                explanation: "wonen → woon. N is NOT in 't kofschip, so use -DE: woonde",
                hint: "Is N in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'stoppen': De bus ___ bij het station (The bus stopped at the station)",
                options: ["stopde", "stopte", "stopede", "stopete"],
                correctAnswer: 1,
                explanation: "stoppen → stop. P is in 't kofschip, so use -TE: stopte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'spelen': Wij ___ voetbal (We played football)",
                options: ["speelte", "speelde", "spelede", "spelette"],
                correctAnswer: 1,
                explanation: "spelen → speel. L is NOT in 't kofschip, so use -DE: speelde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'lachen': Zij ___ om de grap (She laughed at the joke)",
                options: ["lachde", "lachte", "lachede", "lachete"],
                correctAnswer: 1,
                explanation: "lachen → lach. CH is in 't kofschip, so use -TE: lachte",
                hint: "Is CH in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'praten': Jullie ___ over het weer (You talked about the weather)",
                options: ["praatde", "praatte", "pratede", "pratete"],
                correctAnswer: 1,
                explanation: "praten → praat. T is in 't kofschip, so use -TE: praatte",
                hint: "Is T in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'wandelen': Ik ___ in het park (I walked in the park)",
                options: ["wandelte", "wandelde", "wandelede", "wandelette"],
                correctAnswer: 1,
                explanation: "wandelen → wandel. L is NOT in 't kofschip, so use -DE: wandelde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'kopen': Hij ___ een nieuwe auto (He bought a new car)",
                options: ["koopde", "koopte", "kopede", "kopete"],
                correctAnswer: 1,
                explanation: "kopen → koop. P is in 't kofschip, so use -TE: koopte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'leren': Wij ___ Nederlands (We learned Dutch)",
                options: ["leerde", "leertte", "lererde", "lerette"],
                correctAnswer: 0,
                explanation: "leren → leer. R is NOT in 't kofschip, so use -DE: leerde",
                hint: "Is R in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'kussen': Zij ___ haar kind (She kissed her child)",
                options: ["kusde", "kuste", "kusede", "kusete"],
                correctAnswer: 1,
                explanation: "kussen → kus. S is in 't kofschip, so use -TE: kuste",
                hint: "Is S in 't kofschip?"
            ),
            
            // NEW: Translation Exercises
            GrammarExercise(
                question: "How do you say 'I worked yesterday' in Dutch?",
                options: ["Ik werkte gisteren", "Ik werkde gisteren", "Ik werkte gisteren", "Ik werkde gisteren"],
                correctAnswer: 0,
                explanation: "Ik werkte gisteren - werken → werk, K is in 't kofschip, so use -TE",
                hint: "Remember: K is in 't kofschip",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'He lived in Utrecht' in Dutch?",
                options: ["Hij woonte in Utrecht", "Hij woonde in Utrecht", "Hij woonte in Utrecht", "Hij woonde in Utrecht"],
                correctAnswer: 1,
                explanation: "Hij woonde in Utrecht - wonen → woon, N is NOT in 't kofschip, so use -DE",
                hint: "Remember: N is NOT in 't kofschip",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'We played football' in Dutch?",
                options: ["Wij speelte voetbal", "Wij speelde voetbal", "Wij speelte voetbal", "Wij speelde voetbal"],
                correctAnswer: 1,
                explanation: "Wij speelde voetbal - spelen → speel, L is NOT in 't kofschip, so use -DE",
                hint: "Remember: L is NOT in 't kofschip",
                exerciseType: .translation
            ),
            
            // NEW: Fill-in-the-Blank Exercises
            GrammarExercise(
                question: "Complete: 'Ik ___ gisteren een boek' (I read a book yesterday)",
                options: ["laste", "lasde", "laste", "lasde"],
                correctAnswer: 1,
                explanation: "Ik lasde gisteren een boek - lezen → lees, S is in 't kofschip, so use -TE: laste (but 'lezen' is irregular!)",
                hint: "Actually, 'lezen' is irregular - the past is 'las'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ naar de winkel' (He walked to the store)",
                options: ["liepte", "liepde", "liepte", "liepde"],
                correctAnswer: 1,
                explanation: "Hij liepde naar de winkel - lopen → loop, P is in 't kofschip, so use -TE: liepte (but 'lopen' is irregular!)",
                hint: "Actually, 'lopen' is irregular - the past is 'liep'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een nieuwe auto' (She bought a new car)",
                options: ["koopte", "koopde", "koopte", "koopde"],
                correctAnswer: 0,
                explanation: "Zij kocht een nieuwe auto - kopen → koop, P is in 't kofschip, so use -TE: koopte",
                hint: "Remember: P is in 't kofschip",
                exerciseType: .fillInTheBlank
            ),
            
            // NEW: True/False Exercises
            GrammarExercise(
                question: "True or False: 'Ik maakde een fout' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik maakte een fout'. K is in 't kofschip, so use -TE, not -DE.",
                hint: "Remember the 't kofschip rule",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Hij woonte in Amsterdam' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Hij woonde in Amsterdam'. N is NOT in 't kofschip, so use -DE, not -TE.",
                hint: "Remember which letters are NOT in 't kofschip",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Wij speelde voetbal' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Speelde' is correct. L is NOT in 't kofschip, so -DE is right.",
                hint: "This follows the rule correctly",
                exerciseType: .trueFalse
            ),
            
            // NEW: Context-Based Questions
            GrammarExercise(
                question: "When talking about cooking, how do you say 'I cooked dinner'?",
                options: ["Ik kookte het avondeten", "Ik kookde het avondeten", "Ik kookte het avondeten", "Ik kookde het avondeten"],
                correctAnswer: 0,
                explanation: "Ik kookte het avondeten - koken → kook, K is in 't kofschip, so use -TE",
                hint: "Remember: K is in 't kofschip",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "When talking about studying, how do you say 'We studied hard'?",
                options: ["Wij studeerde hard", "Wij studeerde hard", "Wij studeerde hard", "Wij studeerde hard"],
                correctAnswer: 1,
                explanation: "Wij studeerde hard - studeren → studeer, R is NOT in 't kofschip, so use -DE",
                hint: "Remember: R is NOT in 't kofschip",
                exerciseType: .translation
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik maakde een fout",
                correct: "Ik maakte een fout",
                explanation: "maken → maak. K is in 't kofschip, so use -TE: maakte (not -DE)"
            ),
            CommonMistake(
                incorrect: "Hij woonte in Utrecht",
                correct: "Hij woonde in Utrecht",
                explanation: "wonen → woon. N is NOT in 't kofschip, so use -DE: woonde (not -TE)"
            ),
            CommonMistake(
                incorrect: "Zij levfte in Parijs",
                correct: "Zij leefde in Parijs",
                explanation: "leven → leef (F becomes V!). Stem ends in F, so use -DE: leefde"
            ),
            CommonMistake(
                incorrect: "Wij reiste naar Spanje",
                correct: "Wij reisden naar Spanje",
                explanation: "reizen → reis (Z becomes S!). Stem ends in S from Z, so use -DE: reisden"
            ),
            CommonMistake(
                incorrect: "De bus stopde",
                correct: "De bus stopte",
                explanation: "stoppen → stop. P is in 't kofschip, so use -TE: stopte (not -DE)"
            ),
            CommonMistake(
                incorrect: "Ik speelte gitaar",
                correct: "Ik speelde gitaar",
                explanation: "spelen → speel. L is NOT in 't kofschip, so use -DE: speelde (not -TE)"
            )
        ],
        tips: [
            "Learn 't kofschip by heart: T-K-O-F-S-CH-P (like coffee ship)",
            "First make the stem: remove -en from the infinitive",
            "Watch for F→V and Z→S changes in the stem",
            "Double letters become single: stoppen → stop",
            "Practice with many examples until it becomes automatic",
            "When in doubt: say it out loud - often you can hear the difference"
        ],
        relatedRules: ["verb_past_a2", "verb_perfect_b1", "auxiliary_verbs_b1"]
    )
    
    // MARK: - Dutch Contractions and Clitics (A2)
    
    lazy var contractionsCliticsA2 = DutchGrammarRule(
        id: "contractions_clitics_a2",
        title: "Dutch Contractions and Clitics: Informal Speech (A2)",
        type: .pronunciation,
        level: .a2,
        explanation: """
        Dutch speakers often use contractions and clitics in informal, everyday speech. These are shortened forms that make speech more natural and fluent. While not always used in formal writing, they're essential for understanding and speaking natural Dutch.
        
        **Common Contractions:**
        
        **Articles and Pronouns:**
        • het → 't (the neuter article / it)
        • ik → 'k (I)
        • hem → 'm (him / it)
        • een → 'n (a / an)
        • haar → 'r (her)
        • eens → 'ns (once / a sec)
        • daar/er/haar → d'r (there / her / it)
        • zijn → z'n (his)
        • mijn → m'n (my)
        
        **Verb + Subject Combinations:**
        • heb ik → hebk (have I)
        • heb je → hebje (have you)
        • dat is → da's (that is)
        • wat is → wa's (what is)
        • er is → d'r is / d'r's (there is)
        • ik heb → kheb (I have)
        • ik wil → k wil / k'wil (I want)
        • ze hebben → ze hebbe (they have - spoken form)
        
        **Other Common Contractions:**
        • niet → nie (not - very informal)
        • naar → na (to/towards - informal)
        • voor → ve (for - very informal)
        • van → va (of/from - very informal)
        
        **When to Use:**
        • Informal conversations with friends and family
        • Spoken Dutch (not formal writing)
        • Text messages and social media
        • When speaking quickly or casually
        
        **When NOT to Use:**
        • Formal writing or business communication
        • Academic texts
        • Official documents
        • When speaking to strangers or in formal situations
        """,
        keyPoints: [
            "Contractions make speech more natural and fluent",
            "'t is the most common contraction (het → 't)",
            "Personal pronouns often contract: ik→'k, hem→'m, haar→'r",
            "Possessives contract: mijn→m'n, zijn→z'n",
            "Verb + subject combinations are very common",
            "Use in informal situations, not formal writing",
            "Essential for understanding spoken Dutch",
            "Practice both full and contracted forms"
        ],
        examples: [
            GrammarExample(
                dutch: "Het is mooi weer → 't is mooi weer",
                english: "It's nice weather",
                breakdown: "het (neuter article) → 't (contraction)",
                audioHint: "ət ɪs moi vɛːr → t ɪs moi vɛːr"
            ),
            GrammarExample(
                dutch: "Ik weet het niet → 'k weet het niet",
                english: "I don't know",
                breakdown: "ik → 'k (personal pronoun contraction)",
                audioHint: "ɪk vet ət nit → k vet ət nit"
            ),
            GrammarExample(
                dutch: "Geef hem maar aan mij → Geef 'm maar aan mij",
                english: "Just give it to me",
                breakdown: "hem → 'm (object pronoun contraction)",
                audioHint: "ɣeːf hɛm maːr aːn mɛi → ɣeːf m maːr aːn mɛi"
            ),
            GrammarExample(
                dutch: "Een beetje → 'n beetje",
                english: "A little bit",
                breakdown: "een → 'n (indefinite article contraction)",
                audioHint: "ən beːtjə → n beːtjə"
            ),
            GrammarExample(
                dutch: "Ik bel haar straks → Ik bel 'r straks",
                english: "I'll call her later",
                breakdown: "haar → 'r (object pronoun contraction)",
                audioHint: "ɪk bɛl haːr straks → ɪk bɛl r straks"
            ),
            GrammarExample(
                dutch: "Kom eens hier → Kom 'ns hier",
                english: "Come here for a sec",
                breakdown: "eens → 'ns (adverb contraction)",
                audioHint: "kɔm əns hiːr → kɔm ns hiːr"
            ),
            GrammarExample(
                dutch: "Ik was er niet bij → Ik was d'r niet bij",
                english: "I wasn't there",
                breakdown: "er → d'r (adverb contraction)",
                audioHint: "ɪk vɑs ɛr nit bɛi → ɪk vɑs dr nit bɛi"
            ),
            GrammarExample(
                dutch: "Dat is zijn fiets → Dat is z'n fiets",
                english: "That's his bike",
                breakdown: "zijn → z'n (possessive contraction)",
                audioHint: "dɑt ɪs zɛin fits → dɑt ɪs zn fits"
            ),
            GrammarExample(
                dutch: "Waar is mijn telefoon? → Waar is m'n telefoon?",
                english: "Where's my phone?",
                breakdown: "mijn → m'n (possessive contraction)",
                audioHint: "vaːr ɪs mɛin teːləfoːn → vaːr ɪs mn teːləfoːn"
            ),
            GrammarExample(
                dutch: "Heb ik dat gedaan? → Hebk dat gedaan?",
                english: "Did I do that?",
                breakdown: "heb ik → hebk (verb + subject contraction)",
                audioHint: "hɛp ɪk dɑt ɣədaːn → hɛpk dɑt ɣədaːn"
            ),
            GrammarExample(
                dutch: "Heb je tijd? → Hebje tijd?",
                english: "Do you have time?",
                breakdown: "heb je → hebje (verb + subject contraction)",
                audioHint: "hɛp jə tɛit → hɛpjə tɛit"
            ),
            GrammarExample(
                dutch: "Dat is waar → Da's waar",
                english: "That's true",
                breakdown: "dat is → da's (demonstrative + verb contraction)",
                audioHint: "dɑt ɪs vaːr → das vaːr"
            ),
            GrammarExample(
                dutch: "Wat is dat? → Wa's dat?",
                english: "What is that?",
                breakdown: "wat is → wa's (question word + verb contraction)",
                audioHint: "vɑt ɪs dɑt → vas dɑt"
            ),
            GrammarExample(
                dutch: "Er is niemand thuis → D'r is niemand thuis",
                english: "There's nobody home",
                breakdown: "er is → d'r is (there + verb contraction)",
                audioHint: "ɛr ɪs nimaːnt tœys → dr ɪs nimaːnt tœys"
            ),
            GrammarExample(
                dutch: "Ik heb geen geld → Kheb geen geld",
                english: "I have no money",
                breakdown: "ik heb → kheb (subject + verb contraction)",
                audioHint: "ɪk hɛp ɣeːn ɣɛlt → khɛp ɣeːn ɣɛlt"
            ),
            GrammarExample(
                dutch: "Ik wil naar huis → K wil naar huis",
                english: "I want to go home",
                breakdown: "ik wil → k wil (subject + verb contraction)",
                audioHint: "ɪk vɪl naːr hœys → k vɪl naːr hœys"
            ),
            GrammarExample(
                dutch: "Ze hebben gelijk → Ze hebbe gelijk",
                english: "They are right",
                breakdown: "ze hebben → ze hebbe (spoken form, less formal)",
                audioHint: "zə hɛbə(n) ɣəlɛik → zə hɛbə ɣəlɛik"
            ),
            GrammarExample(
                dutch: "Ik ga niet → Ik ga nie",
                english: "I'm not going",
                breakdown: "niet → nie (very informal contraction)",
                audioHint: "ɪk ɣaː nit → ɪk ɣaː ni"
            ),
            GrammarExample(
                dutch: "Ik ga naar de winkel → Ik ga na de winkel",
                english: "I'm going to the store",
                breakdown: "naar → na (informal contraction)",
                audioHint: "ɪk ɣaː naːr də vɪŋkəl → ɪk ɣaː na də vɪŋkəl"
            ),
            GrammarExample(
                dutch: "Dank je voor alles → Dank je ve alles",
                english: "Thank you for everything",
                breakdown: "voor → ve (very informal contraction)",
                audioHint: "dɑŋk jə foːr ɑləs → dɑŋk jə və ɑləs"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "What is the contraction for 'het is'?",
                options: ["'t is", "'s is", "het's", "het is"],
                correctAnswer: 0,
                explanation: "'t is is the contraction for 'het is' - the most common contraction in Dutch",
                hint: "Think of the neuter article 'het'"
            ),
            GrammarExercise(
                question: "What is the contraction for 'ik'?",
                options: ["'k", "'i", "ik", "ik'"],
                correctAnswer: 0,
                explanation: "'k is the contraction for 'ik' (I)",
                hint: "The 'i' is dropped from 'ik'"
            ),
            GrammarExercise(
                question: "What is the contraction for 'hem'?",
                options: ["'m", "'h", "hem", "he'"],
                correctAnswer: 0,
                explanation: "'m is the contraction for 'hem' (him/it)",
                hint: "The 'he' is dropped from 'hem'"
            ),
            GrammarExercise(
                question: "What is the contraction for 'een'?",
                options: ["'n", "'e", "een", "ee'"],
                correctAnswer: 0,
                explanation: "'n is the contraction for 'een' (a/an)",
                hint: "The 'ee' is dropped from 'een'"
            ),
            GrammarExercise(
                question: "What is the contraction for 'haar'?",
                options: ["'r", "'h", "haar", "ha'"],
                correctAnswer: 0,
                explanation: "'r is the contraction for 'haar' (her)",
                hint: "The 'haa' is dropped from 'haar'"
            ),
            GrammarExercise(
                question: "What is the contraction for 'eens'?",
                options: ["'ns", "'e", "eens", "ee'"],
                correctAnswer: 0,
                explanation: "'ns is the contraction for 'eens' (once/a sec)",
                hint: "The 'ee' is dropped from 'eens'"
            ),
            GrammarExercise(
                question: "What is the contraction for 'zijn' (his)?",
                options: ["z'n", "'z", "zijn", "zi'"],
                correctAnswer: 0,
                explanation: "z'n is the contraction for 'zijn' (his)",
                hint: "The 'ij' is dropped from 'zijn'"
            ),
            GrammarExercise(
                question: "What is the contraction for 'mijn'?",
                options: ["m'n", "'m", "mijn", "mi'"],
                correctAnswer: 0,
                explanation: "m'n is the contraction for 'mijn' (my)",
                hint: "The 'ij' is dropped from 'mijn'"
            ),
            GrammarExercise(
                question: "Complete the contraction: 'heb ik' → ___",
                options: ["hebik", "hebk", "heb'k", "heb ik"],
                correctAnswer: 1,
                explanation: "'heb ik' becomes 'hebk' - verb + subject contraction",
                hint: "The 'i' from 'ik' is dropped"
            ),
            GrammarExercise(
                question: "What does 'da's' mean?",
                options: ["that is", "this is", "there is", "what is"],
                correctAnswer: 0,
                explanation: "'da's' is the contraction of 'dat is' meaning 'that is'",
                hint: "Think of 'dat' (that) + 'is'"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ geen tijd' (I have no time)",
                options: ["heb", "hebt", "hebk", "heb ik"],
                correctAnswer: 2,
                explanation: "'Ik heb' becomes 'kheb' in informal speech",
                hint: "This is a verb + subject contraction"
            ),
            GrammarExercise(
                question: "What is the contraction for 'wat is'?",
                options: ["wa's", "wat's", "w's", "wat is"],
                correctAnswer: 0,
                explanation: "'wat is' becomes 'wa's' - the 't' is dropped",
                hint: "The 't' from 'wat' is omitted"
            ),
            GrammarExercise(
                question: "How do you say 'There's nobody here' informally?",
                options: ["Er is niemand hier", "D'r is niemand hier", "Er's niemand hier", "D'r's niemand hier"],
                correctAnswer: 1,
                explanation: "'Er is' becomes 'd'r is' in informal speech",
                hint: "Think of 'er' + 'is' contraction"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ naar huis' (I want to go home)",
                options: ["wil", "wil ik", "k wil", "k'wil"],
                correctAnswer: 2,
                explanation: "'Ik wil' becomes 'k wil' in informal speech",
                hint: "This is a subject + verb contraction"
            ),
            GrammarExercise(
                question: "What does 'ze hebbe' mean?",
                options: ["she has", "they have", "you have", "we have"],
                correctAnswer: 1,
                explanation: "'ze hebbe' is the informal form of 'ze hebben' (they have)",
                hint: "This is a spoken form, less formal than 'hebben'"
            ),
            GrammarExercise(
                question: "True or False: Contractions are used in formal writing",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! Contractions are used in informal speech, not formal writing",
                hint: "Think about when you would use contractions"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ga ___ de winkel' (I'm going to the store) - informal",
                options: ["naar", "na", "naar", "na"],
                correctAnswer: 1,
                explanation: "'naar' becomes 'na' in informal speech",
                hint: "This is a preposition contraction"
            ),
            GrammarExercise(
                question: "How do you say 'Thank you for everything' very informally?",
                options: ["Dank je voor alles", "Dank je ve alles", "Dank je vo alles", "Dank je v alles"],
                correctAnswer: 1,
                explanation: "'voor' becomes 've' in very informal speech",
                hint: "This is a very informal preposition contraction"
            ),
            GrammarExercise(
                question: "What is the most common contraction in Dutch?",
                options: ["'t is", "heb je", "dat is", "ik heb"],
                correctAnswer: 0,
                explanation: "'t is (het is) is the most common contraction in Dutch",
                hint: "Think of the neuter article 'het'"
            ),
            GrammarExercise(
                question: "Complete: 'Geef ___ maar aan mij' (Just give it to me) - informal",
                options: ["het", "'t", "hem", "'m"],
                correctAnswer: 3,
                explanation: "'hem' becomes ''m' in informal speech",
                hint: "This is an object pronoun contraction"
            ),
            GrammarExercise(
                question: "Complete: '___ beetje' (a little bit) - informal",
                options: ["Een", "'n", "Een", "Een"],
                correctAnswer: 1,
                explanation: "'een' becomes ''n' in informal speech",
                hint: "This is an indefinite article contraction"
            ),
            GrammarExercise(
                question: "Complete: 'Kom ___ hier' (Come here for a sec) - informal",
                options: ["eens", "'ns", "eens", "eens"],
                correctAnswer: 1,
                explanation: "'eens' becomes ''ns' in informal speech",
                hint: "This means 'for a moment' or 'once'"
            ),
            GrammarExercise(
                question: "Complete: 'Dat is ___ fiets' (That's his bike) - informal",
                options: ["zijn", "z'n", "zijn", "zijn"],
                correctAnswer: 1,
                explanation: "'zijn' becomes 'z'n' in informal speech",
                hint: "This is a possessive contraction"
            ),
            GrammarExercise(
                question: "Complete: 'Waar is ___ telefoon?' (Where's my phone?) - informal",
                options: ["mijn", "m'n", "mij", "me"],
                correctAnswer: 1,
                explanation: "'mijn' becomes 'm'n' in informal speech",
                hint: "This is a possessive contraction"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Using contractions in formal writing",
                correct: "Use full forms in formal writing",
                explanation: "Contractions are for informal speech only"
            ),
            CommonMistake(
                incorrect: "Ik hebk gedaan",
                correct: "Ik heb gedaan or Kheb gedaan",
                explanation: "Either use full form 'Ik heb' or contraction 'Kheb', not mixed"
            ),
            CommonMistake(
                incorrect: "Da's een mooi huis",
                correct: "Dat is een mooi huis",
                explanation: "Use full form in formal writing: 'Dat is een mooi huis'"
            ),
            CommonMistake(
                incorrect: "Wa's jouw naam?",
                correct: "Wat is jouw naam?",
                explanation: "Use full form in formal situations: 'Wat is jouw naam?'"
            ),
            CommonMistake(
                incorrect: "D'r is niemand thuis",
                correct: "Er is niemand thuis",
                explanation: "Use full form in formal writing: 'Er is niemand thuis'"
            ),
            CommonMistake(
                incorrect: "Confusing 'm (hem) with 'n (een)",
                correct: "'m = hem (him/it), 'n = een (a/an)",
                explanation: "These are different contractions with different meanings"
            ),
            CommonMistake(
                incorrect: "Not recognizing d'r can mean multiple things",
                correct: "d'r can be daar, er, or haar depending on context",
                explanation: "Context determines which word d'r represents"
            )
        ],
        tips: [
            "Practice both full and contracted forms",
            "Listen to native speakers to hear natural contractions",
            "Use contractions in informal conversations with friends",
            "Avoid contractions in formal writing and business communication",
            "Start with the most common ones: 't is, 'k, 'm, 'n",
            "Remember: contractions make speech more natural and fluent",
            "Don't overuse contractions - they're for informal situations",
            "Learn the full forms first, then understand the contractions",
            "Pay attention to context to understand d'r meaning"
        ],
        relatedRules: ["verb_present_a1", "question_word_order_a2", "pronunciation_a1"]
    )
    
    // MARK: - Word Classification and Sentence Analysis (A2)
    
    lazy var wordClassificationSentenceAnalysisA2 = DutchGrammarRule(
        id: "word_classification_sentence_analysis_a2",
        title: "Woordsoortbepaling en Zinsontleding: Word Classification and Sentence Analysis (A2)",
        type: .sentenceStructure,
        level: .a2,
        explanation: """
        Woordsoortbepaling (word classification) and zinsontleding (sentence analysis) are fundamental skills in Dutch grammar. They help you understand how words function in sentences and improve your overall language skills.
        
        **Woordsoorten (Word Classes):**
        
        **1. Zelfstandige Naamwoorden (Nouns):**
        • Name people, animals, things, places, concepts
        • Can be singular or plural
        • Examples: huis, auto, vrouw, Amsterdam, liefde
        
        **2. Werkwoorden (Verbs):**
        • Express actions, states, or processes
        • Can be conjugated (lopen → loop, loopt, liep)
        • Examples: lopen, zijn, hebben, maken, denken
        
        **3. Bijvoeglijke Naamwoorden (Adjectives):**
        • Describe nouns (qualities, characteristics)
        • Can change form: mooi → mooie, klein → kleine
        • Examples: groot, klein, mooi, snel, interessant
        
        **4. Lidwoorden (Articles):**
        • Come before nouns: de, het, een
        • Examples: de man, het huis, een auto
        
        **5. Voornaamwoorden (Pronouns):**
        • Replace nouns: ik, jij, hij, zij, wij, jullie, zij
        • Possessive: mijn, jouw, zijn, haar, ons, jullie, hun
        • Examples: ik, jij, hij, mijn, jouw, dit, dat
        
        **6. Voorzetsels (Prepositions):**
        • Show relationships: in, op, aan, voor, achter, naast
        • Examples: in het huis, op de tafel, voor de school
        
        **7. Bijwoorden (Adverbs):**
        • Describe verbs, adjectives, or other adverbs
        • Often end in -ly in English
        • Examples: snel, langzaam, goed, slecht, hier, daar
        
        **8. Voegwoorden (Conjunctions):**
        • Connect words, phrases, or sentences
        • Examples: en, maar, of, omdat, als, wanneer
        
        **Zinsontleding (Sentence Analysis):**
        
        **Basic Sentence Parts:**
        • Onderwerp (Subject): who/what the sentence is about
        • Gezegde (Predicate): what happens (verb + other elements)
        • Lijdend Voorwerp (Direct Object): receives the action
        • Meewerkend Voorwerp (Indirect Object): for/to whom
        • Bepalingen (Adverbials): when, where, how, why
        
        **Word Order in Dutch:**
        • Main clause: Subject + Verb + Object + Adverbials
        • Subordinate clause: Subject + Object + Adverbials + Verb
        """,
        keyPoints: [
            "Learn to identify the 8 main word classes in Dutch",
            "Understand how words function in sentences",
            "Practice analyzing sentence structure",
            "Know the difference between main and subordinate clauses",
            "Recognize subject, verb, and object patterns",
            "Understand Dutch word order rules"
        ],
        examples: [
            GrammarExample(
                dutch: "De grote hond loopt snel in het park.",
                english: "The big dog walks quickly in the park.",
                breakdown: "De (article) + grote (adjective) + hond (noun) + loopt (verb) + snel (adverb) + in (preposition) + het (article) + park (noun)",
                audioHint: "də ɣroːtə hɔnt loːpt snɛl ɪn ət pɑrk"
            ),
            GrammarExample(
                dutch: "Ik geef mijn moeder een mooie bloem.",
                english: "I give my mother a beautiful flower.",
                breakdown: "Ik (pronoun/subject) + geef (verb) + mijn (possessive) + moeder (noun/indirect object) + een (article) + mooie (adjective) + bloem (noun/direct object)",
                audioHint: "ɪk ɣeːf mɛin mudər ən moiə blum"
            ),
            GrammarExample(
                dutch: "Zij werkt hard omdat ze veel geld verdient.",
                english: "She works hard because she earns a lot of money.",
                breakdown: "Zij (pronoun/subject) + werkt (verb) + hard (adverb) + omdat (conjunction) + ze (pronoun/subject) + veel (adjective) + geld (noun) + verdient (verb)",
                audioHint: "zɛi vɛrkt hɑrt ɔmdɑt zə veːl ɣɛlt vərɛːnt"
            ),
            GrammarExample(
                dutch: "De kinderen spelen vrolijk in de tuin.",
                english: "The children play happily in the garden.",
                breakdown: "De (article) + kinderen (noun/subject) + spelen (verb) + vrolijk (adverb) + in (preposition) + de (article) + tuin (noun)",
                audioHint: "də kɪndərə(n) speːlə(n) vroːlək ɪn də tœyn"
            ),
            GrammarExample(
                dutch: "Hij koopt een nieuwe auto voor zijn vrouw.",
                english: "He buys a new car for his wife.",
                breakdown: "Hij (pronoun/subject) + koopt (verb) + een (article) + nieuwe (adjective) + auto (noun/direct object) + voor (preposition) + zijn (possessive) + vrouw (noun)",
                audioHint: "hɛi kopt ən niwə ɔto foːr zɛin vrɑu"
            ),
            GrammarExample(
                dutch: "Wij gaan morgen naar Amsterdam met de trein.",
                english: "We go tomorrow to Amsterdam by train.",
                breakdown: "Wij (pronoun/subject) + gaan (verb) + morgen (adverb/time) + naar (preposition) + Amsterdam (noun) + met (preposition) + de (article) + trein (noun)",
                audioHint: "vɛi ɣaːn mɔrɣə(n) naːr ɑmstərdɑm mɛt də trɛin"
            ),
            GrammarExample(
                dutch: "Als het regent, blijf ik thuis.",
                english: "If it rains, I stay home.",
                breakdown: "Als (conjunction) + het (pronoun/subject) + regent (verb) + blijf (verb) + ik (pronoun/subject) + thuis (adverb)",
                audioHint: "ɑls ət reːɣənt blɛif ɪk tœys"
            ),
            GrammarExample(
                dutch: "De studenten leren Nederlands en Engels.",
                english: "The students learn Dutch and English.",
                breakdown: "De (article) + studenten (noun/subject) + leren (verb) + Nederlands (noun/direct object) + en (conjunction) + Engels (noun/direct object)",
                audioHint: "də stydɛntə(n) leːrə(n) neːdərlɑnts ɛn ɛŋəls"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "What word class is 'huis' in 'Het huis is groot'?",
                options: ["Verb / Werkwoord", "Noun / Zelfstandig naamwoord", "Adjective / Bijvoeglijk naamwoord", "Pronoun / Voornaamwoord"],
                correctAnswer: 1,
                explanation: "'Huis' is a noun (zelfstandig naamwoord) - it names a thing",
                hint: "Think: what type of word names people, places, or things?"
            ),
            GrammarExercise(
                question: "What word class is 'loopt' in 'Hij loopt snel'?",
                options: ["Noun / Zelfstandig naamwoord", "Verb / Werkwoord", "Adjective / Bijvoeglijk naamwoord", "Adverb / Bijwoord"],
                correctAnswer: 1,
                explanation: "'Loopt' is a verb (werkwoord) - it expresses an action",
                hint: "Think: what type of word shows what someone is doing?"
            ),
            GrammarExercise(
                question: "What word class is 'mooi' in 'Een mooi boek'?",
                options: ["Noun / Zelfstandig naamwoord", "Verb / Werkwoord", "Adjective / Bijvoeglijk naamwoord", "Adverb / Bijwoord"],
                correctAnswer: 2,
                explanation: "'Mooi' is an adjective (bijvoeglijk naamwoord) - it describes the noun 'boek'",
                hint: "Think: what type of word describes qualities of nouns?"
            ),
            GrammarExercise(
                question: "What word class is 'in' in 'Ik woon in Amsterdam'?",
                options: ["Conjunction / Voegwoord", "Preposition / Voorzetsel", "Adverb / Bijwoord", "Pronoun / Voornaamwoord"],
                correctAnswer: 1,
                explanation: "'In' is a preposition (voorzetsel) - it shows the relationship between 'woon' and 'Amsterdam'",
                hint: "Think: what type of word shows location or relationship?"
            ),
            GrammarExercise(
                question: "What word class is 'maar' in 'Ik ben moe, maar ik ga door'?",
                options: ["Preposition / Voorzetsel", "Conjunction / Voegwoord", "Adverb / Bijwoord", "Pronoun / Voornaamwoord"],
                correctAnswer: 1,
                explanation: "'Maar' is a conjunction (voegwoord) - it connects two sentences",
                hint: "Think: what type of word connects parts of sentences?"
            ),
            GrammarExercise(
                question: "What word class is 'de' in 'De auto is rood'?",
                options: ["Pronoun / Voornaamwoord", "Article / Lidwoord", "Adjective / Bijvoeglijk naamwoord", "Noun / Zelfstandig naamwoord"],
                correctAnswer: 1,
                explanation: "'De' is an article (lidwoord) - it comes before the noun 'auto'",
                hint: "Think: what type of word comes before nouns?"
            ),
            GrammarExercise(
                question: "What is the subject in 'De kinderen spelen in de tuin'?",
                options: ["spelen", "kinderen", "tuin", "in"],
                correctAnswer: 1,
                explanation: "'De kinderen' is the subject - it's who the sentence is about",
                hint: "Think: who is doing the action?"
            ),
            GrammarExercise(
                question: "What is the verb in 'Hij koopt een boek'?",
                options: ["Hij", "koopt", "een", "boek"],
                correctAnswer: 1,
                explanation: "'Koopt' is the verb - it shows what action is happening",
                hint: "Think: what action is being performed?"
            ),
            GrammarExercise(
                question: "What is the direct object in 'Ik lees een boek'?",
                options: ["Ik", "lees", "een", "boek"],
                correctAnswer: 3,
                explanation: "'Een boek' is the direct object - it receives the action of 'lees'",
                hint: "Think: what is being read?"
            ),
            GrammarExercise(
                question: "What word class is 'mijn' in 'Mijn auto is blauw'?",
                options: ["Article / Lidwoord", "Pronoun / Voornaamwoord", "Possessive pronoun / Bezittelijk voornaamwoord", "Adjective / Bijvoeglijk naamwoord"],
                correctAnswer: 2,
                explanation: "'Mijn' is a possessive pronoun (bezittelijk voornaamwoord) - it shows ownership",
                hint: "Think: what type of word shows possession?"
            ),
            GrammarExercise(
                question: "What word class is 'hier' in 'Ik woon hier'?",
                options: ["Preposition / Voorzetsel", "Adverb / Bijwoord", "Pronoun / Voornaamwoord", "Conjunction / Voegwoord"],
                correctAnswer: 1,
                explanation: "'Hier' is an adverb (bijwoord) - it tells where the action happens",
                hint: "Think: what type of word tells where something happens?"
            ),
            GrammarExercise(
                question: "What is the indirect object in 'Ik geef mijn moeder een cadeau'?",
                options: ["Ik", "geef", "mijn moeder", "een cadeau"],
                correctAnswer: 2,
                explanation: "'Mijn moeder' is the indirect object - it's who receives the gift",
                hint: "Think: who is receiving the action?"
            ),
            GrammarExercise(
                question: "What word class is 'omdat' in 'Ik blijf thuis omdat het regent'?",
                options: ["Preposition / Voorzetsel", "Conjunction / Voegwoord", "Adverb / Bijwoord", "Pronoun / Voornaamwoord"],
                correctAnswer: 1,
                explanation: "'Omdat' is a conjunction (voegwoord) - it connects the main clause with the reason",
                hint: "Think: what type of word connects clauses and shows reason?"
            ),
            GrammarExercise(
                question: "What word class is 'gisteren' in 'Ik werkte gisteren'?",
                options: ["Noun / Zelfstandig naamwoord", "Adverb / Bijwoord", "Adjective / Bijvoeglijk naamwoord", "Preposition / Voorzetsel"],
                correctAnswer: 1,
                explanation: "'Gisteren' is an adverb (bijwoord) - it tells when the action happened",
                hint: "Think: what type of word tells when something happens?"
            ),
            GrammarExercise(
                question: "What is the subject in 'De studenten leren Nederlands'?",
                options: ["leren", "studenten", "Nederlands", "De"],
                correctAnswer: 1,
                explanation: "'De studenten' is the subject - it's who is doing the learning",
                hint: "Think: who is performing the action?"
            ),
            GrammarExercise(
                question: "What word class is 'en' in 'Brood en boter'?",
                options: ["Preposition / Voorzetsel", "Conjunction / Voegwoord", "Adverb / Bijwoord", "Pronoun / Voornaamwoord"],
                correctAnswer: 1,
                explanation: "'En' is a conjunction (voegwoord) - it connects 'brood' and 'boter'",
                hint: "Think: what type of word connects words or phrases?"
            ),
            GrammarExercise(
                question: "What word class is 'dit' in 'Dit is mijn huis'?",
                options: ["Article / Lidwoord", "Demonstrative pronoun / Aanwijzend voornaamwoord", "Adjective / Bijvoeglijk naamwoord", "Noun / Zelfstandig naamwoord"],
                correctAnswer: 1,
                explanation: "'Dit' is a demonstrative pronoun (aanwijzend voornaamwoord) - it points to something",
                hint: "Think: what type of word points to or demonstrates something?"
            ),
            GrammarExercise(
                question: "What word class is 'heel' in 'Het is heel mooi'?",
                options: ["Adjective / Bijvoeglijk naamwoord", "Adverb / Bijwoord", "Pronoun / Voornaamwoord", "Preposition / Voorzetsel"],
                correctAnswer: 1,
                explanation: "'Heel' is an adverb (bijwoord) - it intensifies the adjective 'mooi'",
                hint: "Think: what type of word modifies or intensifies adjectives?"
            ),
            GrammarExercise(
                question: "What is the verb in 'De kinderen spelen vrolijk'?",
                options: ["kinderen", "spelen", "vrolijk", "De"],
                correctAnswer: 1,
                explanation: "'Spelen' is the verb - it shows what action the children are doing",
                hint: "Think: what action are the children performing?"
            ),
            
            // NEW: Word Family Exercises (Werkwoord, Persoon, Ding)
            GrammarExercise(
                question: "From 'dansen' (to dance), what is the person who does this action?",
                options: ["dans", "danser", "dansen", "dansend"],
                correctAnswer: 1,
                explanation: "'Danser' is the person who dances (de danser)",
                hint: "Think: who performs the action of dancing?"
            ),
            GrammarExercise(
                question: "From 'dansen' (to dance), what is the thing/activity?",
                options: ["dans", "danser", "dansen", "dansend"],
                correctAnswer: 0,
                explanation: "'Dans' is the thing/activity (de dans)",
                hint: "Think: what is the name of the activity?"
            ),
            GrammarExercise(
                question: "From 'dansen' (to dance), what is the verb (werkwoord)?",
                options: ["dans", "danser", "dansen", "dansend"],
                correctAnswer: 2,
                explanation: "'Dansen' is the verb (werkwoord) - the action",
                hint: "Think: what is the action word?"
            ),
            GrammarExercise(
                question: "From 'werken' (to work), what is the person who does this action?",
                options: ["werk", "werker", "werken", "werkend"],
                correctAnswer: 1,
                explanation: "'Werker' is the person who works (de werker)",
                hint: "Think: who performs the action of working?"
            ),
            GrammarExercise(
                question: "From 'werken' (to work), what is the thing/activity?",
                options: ["werk", "werker", "werken", "werkend"],
                correctAnswer: 0,
                explanation: "'Werk' is the thing/activity (het werk)",
                hint: "Think: what is the name of the activity?"
            ),
            GrammarExercise(
                question: "From 'leren' (to learn), what is the person who does this action?",
                options: ["leer", "leerling", "leren", "lerend"],
                correctAnswer: 1,
                explanation: "'Leerling' is the person who learns (de leerling)",
                hint: "Think: who performs the action of learning?"
            ),
            GrammarExercise(
                question: "From 'leren' (to learn), what is the thing/activity?",
                options: ["leer", "leerling", "leren", "lerend"],
                correctAnswer: 0,
                explanation: "'Leer' is the thing/activity (het leren)",
                hint: "Think: what is the name of the learning process?"
            ),
            GrammarExercise(
                question: "From 'koken' (to cook), what is the person who does this action?",
                options: ["kook", "kok", "koken", "kokend"],
                correctAnswer: 1,
                explanation: "'Kok' is the person who cooks (de kok)",
                hint: "Think: who performs the action of cooking?"
            ),
            GrammarExercise(
                question: "From 'koken' (to cook), what is the thing/activity?",
                options: ["kook", "kok", "koken", "kokend"],
                correctAnswer: 0,
                explanation: "'Kook' is the thing/activity (het koken)",
                hint: "Think: what is the name of the cooking activity?"
            ),
            GrammarExercise(
                question: "From 'schrijven' (to write), what is the person who does this action?",
                options: ["schrijf", "schrijver", "schrijven", "schrijvend"],
                correctAnswer: 1,
                explanation: "'Schrijver' is the person who writes (de schrijver)",
                hint: "Think: who performs the action of writing?"
            ),
            GrammarExercise(
                question: "From 'schrijven' (to write), what is the thing/activity?",
                options: ["schrijf", "schrijver", "schrijven", "schrijvend"],
                correctAnswer: 0,
                explanation: "'Schrijf' is the thing/activity (het schrijven)",
                hint: "Think: what is the name of the writing activity?"
            ),
            GrammarExercise(
                question: "From 'lezen' (to read), what is the person who does this action?",
                options: ["lees", "lezer", "lezen", "lezend"],
                correctAnswer: 1,
                explanation: "'Lezer' is the person who reads (de lezer)",
                hint: "Think: who performs the action of reading?"
            ),
            GrammarExercise(
                question: "From 'lezen' (to read), what is the thing/activity?",
                options: ["lees", "lezer", "lezen", "lezend"],
                correctAnswer: 0,
                explanation: "'Lees' is the thing/activity (het lezen)",
                hint: "Think: what is the name of the reading activity?"
            ),
            GrammarExercise(
                question: "From 'spelen' (to play), what is the person who does this action?",
                options: ["speel", "speler", "spelen", "spelend"],
                correctAnswer: 1,
                explanation: "'Speler' is the person who plays (de speler)",
                hint: "Think: who performs the action of playing?"
            ),
            GrammarExercise(
                question: "From 'spelen' (to play), what is the thing/activity?",
                options: ["speel", "speler", "spelen", "spelend"],
                correctAnswer: 0,
                explanation: "'Speel' is the thing/activity (het spel)",
                hint: "Think: what is the name of the playing activity?"
            ),
            GrammarExercise(
                question: "From 'zingen' (to sing), what is the person who does this action?",
                options: ["zing", "zanger", "zingen", "zingend"],
                correctAnswer: 1,
                explanation: "'Zanger' is the person who sings (de zanger)",
                hint: "Think: who performs the action of singing?"
            ),
            GrammarExercise(
                question: "From 'zingen' (to sing), what is the thing/activity?",
                options: ["zing", "zanger", "zingen", "zingend"],
                correctAnswer: 0,
                explanation: "'Zing' is the thing/activity (het zingen)",
                hint: "Think: what is the name of the singing activity?"
            ),
            GrammarExercise(
                question: "From 'lopen' (to walk), what is the person who does this action?",
                options: ["loop", "loper", "lopen", "lopend"],
                correctAnswer: 1,
                explanation: "'Loper' is the person who walks (de loper)",
                hint: "Think: who performs the action of walking?"
            ),
            GrammarExercise(
                question: "From 'lopen' (to walk), what is the thing/activity?",
                options: ["loop", "loper", "lopen", "lopend"],
                correctAnswer: 0,
                explanation: "'Loop' is the thing/activity (de loop)",
                hint: "Think: what is the name of the walking activity?"
            ),
            GrammarExercise(
                question: "From 'zwemmen' (to swim), what is the person who does this action?",
                options: ["zwem", "zwemmer", "zwemmen", "zwemmend"],
                correctAnswer: 1,
                explanation: "'Zwemmer' is the person who swims (de zwemmer)",
                hint: "Think: who performs the action of swimming?"
            ),
            GrammarExercise(
                question: "From 'zwemmen' (to swim), what is the thing/activity?",
                options: ["zwem", "zwemmer", "zwemmen", "zwemmend"],
                correctAnswer: 0,
                explanation: "'Zwem' is the thing/activity (het zwemmen)",
                hint: "Think: what is the name of the swimming activity?"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Confusing adjectives and adverbs",
                correct: "Adjectives describe nouns, adverbs describe verbs/adjectives",
                explanation: "Mooi (adjective) vs. mooi (adverb) - context determines the function"
            ),
            CommonMistake(
                incorrect: "Not recognizing compound words",
                correct: "Break down compound words to identify parts",
                explanation: "Werkwoord = werk (work) + woord (word) = verb"
            ),
            CommonMistake(
                incorrect: "Confusing subject and object",
                correct: "Subject does the action, object receives the action",
                explanation: "In 'Ik zie jou', 'Ik' is subject, 'jou' is object"
            ),
            CommonMistake(
                incorrect: "Not recognizing separable verbs",
                correct: "Identify the base verb and prefix",
                explanation: "Meekomen = mee (prefix) + komen (verb)"
            ),
            CommonMistake(
                incorrect: "Ignoring word order in analysis",
                correct: "Consider word order to determine function",
                explanation: "Dutch word order helps identify subject, verb, and object"
            )
        ],
        tips: [
            "Start by identifying the verb - it's the action word",
            "Find the subject by asking 'who/what + verb'",
            "Look for articles (de, het, een) to identify nouns",
            "Adjectives often come before nouns and can change form",
            "Prepositions show relationships between words",
            "Practice with simple sentences first, then complex ones",
            "Remember that some words can belong to multiple classes depending on context",
            "Use the word order rules to help identify sentence parts"
        ],
        relatedRules: ["verb_present_a1", "basic_word_order_a1", "dutch_articles_a1", "adjectives_a2"]
    )
    
    // MARK: - A2 Level - Dutch Informal Contractions
    
    lazy var dutchInformalContractionsA2 = DutchGrammarRule(
        id: "dutch_informal_contractions_a2",
        title: "Dutch Informal Contractions",
        type: .pronunciation,
        level: .a2,
        explanation: """
        Dutch speakers often use informal contractions in everyday speech and casual writing. These contractions make speech more natural and faster, but they're typically not used in formal writing.
        
        Contractions are formed by:
        • Dropping letters from the beginning or end of words
        • Combining words together
        • Using apostrophes to show missing letters
        
        These contractions are very common in spoken Dutch and informal text messages, but should be avoided in formal writing, academic papers, or business communication.
        """,
        keyPoints: [
            "Contractions make speech more natural and faster",
            "Most common: 't (het), 'k (ik), 'm (hem), 'n (een)",
            "Used in informal speech and casual writing",
            "Avoid in formal writing and business communication",
            "Help understand native Dutch speakers better",
            "Common in text messages and social media"
        ],
        examples: [
            GrammarExample(
                dutch: "'t regent",
                english: "it's raining",
                breakdown: "'t = het (it/the)",
                audioHint: "t rəɣənt"
            ),
            GrammarExample(
                dutch: "'k weet het niet",
                english: "I don't know",
                breakdown: "'k = ik (I)",
                audioHint: "k veːt ət nit"
            ),
            GrammarExample(
                dutch: "Geef 'm maar aan mij",
                english: "Just give it to me",
                breakdown: "'m = hem (him/it)",
                audioHint: "ɣeːf m maːr aːn mɛi"
            ),
            GrammarExample(
                dutch: "'n beetje",
                english: "a little bit",
                breakdown: "'n = een (a/an)",
                audioHint: "n beːtjə"
            ),
            GrammarExample(
                dutch: "Ik bel 'r straks",
                english: "I'll call her later",
                breakdown: "'r = haar (her)",
                audioHint: "ik bɛl r straks"
            ),
            GrammarExample(
                dutch: "Kom 'ns hier",
                english: "Come here for a sec",
                breakdown: "'ns = eens (once/a sec)",
                audioHint: "kɔm ns hiːr"
            ),
            GrammarExample(
                dutch: "Ik was d'r niet bij",
                english: "I wasn't there",
                breakdown: "d'r = daar/er (there)",
                audioHint: "ik vɑs dr nit bɛi"
            ),
            GrammarExample(
                dutch: "Dat is z'n fiets",
                english: "That's his bike",
                breakdown: "z'n = zijn (his)",
                audioHint: "dɑt ɪs zn fits"
            ),
            GrammarExample(
                dutch: "Waar is m'n telefoon?",
                english: "Where's my phone?",
                breakdown: "m'n = mijn (my)",
                audioHint: "vaːr ɪs mn teːləfoːn"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "What does 't mean in Dutch?",
                options: ["het", "dat", "dit", "wat"],
                correctAnswer: 0,
                explanation: "'t is the contraction of 'het' (the/it). It's the most common contraction in Dutch.",
                hint: "Think of the neuter article"
            ),
            GrammarExercise(
                question: "Complete: '___ weet het niet' (I don't know)",
                options: ["Ik", "'k", "Ik", "Ik"],
                correctAnswer: 1,
                explanation: "'k is the contraction of 'ik' (I). 'k weet het niet = ik weet het niet",
                hint: "This is the informal way to say 'I'"
            ),
            GrammarExercise(
                question: "What does 'm mean in 'Geef 'm maar'?",
                options: ["mij", "hem", "haar", "het"],
                correctAnswer: 1,
                explanation: "'m is the contraction of 'hem' (him/it). 'Geef 'm maar' = 'Geef hem maar'",
                hint: "Think of the object pronoun for 'him'"
            ),
            GrammarExercise(
                question: "Complete: '___ beetje' (a little bit)",
                options: ["Een", "'n", "Een", "Een"],
                correctAnswer: 1,
                explanation: "'n is the contraction of 'een' (a/an). 'n beetje = een beetje",
                hint: "This is the informal indefinite article"
            ),
            GrammarExercise(
                question: "What does 'r mean in 'Ik bel 'r'?",
                options: ["hem", "haar", "het", "hij"],
                correctAnswer: 1,
                explanation: "'r is the contraction of 'haar' (her). 'Ik bel 'r' = 'Ik bel haar'",
                hint: "Think of the object pronoun for 'her'"
            ),
            GrammarExercise(
                question: "Complete: 'Kom ___ hier' (Come here for a sec)",
                options: ["eens", "'ns", "eens", "eens"],
                correctAnswer: 1,
                explanation: "'ns is the contraction of 'eens' (once/a sec). 'Kom 'ns hier' = 'Kom eens hier'",
                hint: "This means 'for a moment' or 'once'"
            ),
            GrammarExercise(
                question: "What does d'r mean in 'Ik was d'r niet bij'?",
                options: ["daar", "er", "haar", "All of the above"],
                correctAnswer: 3,
                explanation: "d'r can be a contraction of 'daar' (there), 'er' (there), or 'haar' (her), depending on context.",
                hint: "This contraction has multiple meanings"
            ),
            GrammarExercise(
                question: "Complete: 'Dat is ___ fiets' (That's his bike)",
                options: ["zijn", "z'n", "zijn", "zijn"],
                correctAnswer: 1,
                explanation: "z'n is the contraction of 'zijn' (his). 'Dat is z'n fiets' = 'Dat is zijn fiets'",
                hint: "This is the informal possessive for 'his'"
            ),
            GrammarExercise(
                question: "What does m'n mean in 'Waar is m'n telefoon?'?",
                options: ["mijn", "mij", "me", "mij"],
                correctAnswer: 0,
                explanation: "m'n is the contraction of 'mijn' (my). 'Waar is m'n telefoon?' = 'Waar is mijn telefoon?'",
                hint: "This is the informal possessive for 'my'"
            ),
            GrammarExercise(
                question: "How do you say 'It's raining' informally in Dutch?",
                options: ["Het regent", "'t regent", "Het regent", "Het regent"],
                correctAnswer: 1,
                explanation: "'t regent is the informal way to say 'it's raining'. 't = het",
                hint: "Use the contraction for 'het'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'I don't know' informally in Dutch?",
                options: ["Ik weet het niet", "'k weet het niet", "Ik weet het niet", "Ik weet het niet"],
                correctAnswer: 1,
                explanation: "'k weet het niet is the informal way to say 'I don't know'. 'k = ik",
                hint: "Use the contraction for 'ik'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "Complete: 'Geef ___ maar aan mij' (Just give it to me)",
                options: ["het", "'t", "hem", "'m"],
                correctAnswer: 3,
                explanation: "'m is the contraction of 'hem' (him/it). 'Geef 'm maar aan mij'",
                hint: "Use the informal object pronoun",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "True or False: 't is the most common contraction in Dutch",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 't (het) is the most common contraction in Dutch, used very frequently in informal speech.",
                hint: "Think about how often you hear 'het' in Dutch",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: You should use contractions in formal business emails",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! Contractions are informal and should be avoided in formal writing, business communication, and academic papers.",
                hint: "Contractions are for informal use only",
                exerciseType: .trueFalse
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Using contractions in formal writing",
                correct: "Only use contractions in informal speech and casual writing",
                explanation: "Contractions make text too casual for business or academic contexts"
            ),
            CommonMistake(
                incorrect: "Confusing 'm (hem) with 'n (een)",
                correct: "'m = hem (him/it), 'n = een (a/an)",
                explanation: "These are different contractions with different meanings"
            ),
            CommonMistake(
                incorrect: "Not recognizing d'r can mean multiple things",
                correct: "d'r can be daar, er, or haar depending on context",
                explanation: "Context determines which word d'r represents"
            ),
            CommonMistake(
                incorrect: "Using contractions when learning Dutch",
                correct: "Learn the full forms first, then understand contractions",
                explanation: "Start with proper forms, then learn informal variations"
            ),
            CommonMistake(
                incorrect: "Thinking all contractions are the same",
                correct: "Each contraction has specific rules and contexts",
                explanation: "Different contractions have different uses and meanings"
            )
        ],
        tips: [
            "Learn the full forms first, then understand the contractions",
            "Listen to native speakers to hear contractions in context",
            "Practice with informal text messages and social media",
            "Remember that contractions are for informal use only",
            "Pay attention to context to understand d'r meaning",
            "Start with the most common contractions: 't, 'k, 'm, 'n",
            "Don't worry about using contractions yourself initially",
            "Focus on understanding them when listening to Dutch"
        ],
        relatedRules: ["basic_word_order_a1", "dutch_articles_a1", "pronouns_a1", "informal_speech_a2"]
    )
    
    // MARK: - Dutch Nouns and Articles Grammar Rule
    
    lazy var dutchNounsAndArticlesA1 = DutchGrammarRule(
        id: "dutch_articles_a1",
        title: "Nouns and Articles (A1)",
        type: .pluralization,
        level: .a1,
        explanation: """
        In Dutch, all nouns have a gender: masculine, feminine, or neuter. This determines which article you use: 'de' or 'het'.
        
        There are two types of articles:
        • DE-words: masculine and feminine words (de man, de vrouw, de auto)
        • HET-words: neuter words (het huis, het boek, het kind)
        
        Important rules:
        • All plurals get 'de' (de mannen, de huizen)
        • Diminutives always get 'het' (het mannetje, het huisje)
        • Words ending in -heid, -nis, -ing, -st are usually DE-words
        • Words ending in -je, -tje are always HET-words
        • Many words you just have to learn (no clear rule)
        
        Plural formation:
        • Usually: singular + -en (de man → de mannen)
        • Sometimes: singular + -s (de auto → de auto's)
        • Special cases: kind → kinderen, stad → steden
        """,
        keyPoints: [
            "All nouns have a gender",
            "DE for masculine/feminine words",
            "HET for neuter words",
            "All plurals get DE",
            "Diminutives always get HET",
            "Plural usually: + -en, sometimes + -s",
            "Many words you just have to learn"
        ],
        examples: [
            GrammarExample(
                dutch: "de man",
                english: "the man",
                breakdown: "mannelijk → de",
                audioHint: "də mɑn"
            ),
            GrammarExample(
                dutch: "de mannen",
                english: "the men",
                breakdown: "meervoud → altijd de",
                audioHint: "də mɑnə(n)"
            ),
            GrammarExample(
                dutch: "het huis",
                english: "the house",
                breakdown: "onzijdig → het",
                audioHint: "hət hɵis"
            ),
            GrammarExample(
                dutch: "de huizen",
                english: "the houses",
                breakdown: "meervoud → altijd de",
                audioHint: "də hɵizə(n)"
            ),
            GrammarExample(
                dutch: "de hond",
                english: "the dog",
                breakdown: "mannelijk → de",
                audioHint: "də hɔnt"
            ),
            GrammarExample(
                dutch: "de honden",
                english: "the dogs",
                breakdown: "meervoud: hond + en",
                audioHint: "də hɔndə(n)"
            ),
            GrammarExample(
                dutch: "de auto",
                english: "the car",
                breakdown: "mannelijk → de",
                audioHint: "də ɑuto"
            ),
            GrammarExample(
                dutch: "de auto's",
                english: "the cars",
                breakdown: "meervoud: auto + 's",
                audioHint: "də ɑutos"
            ),
            GrammarExample(
                dutch: "de liefde",
                english: "love",
                breakdown: "vrouwelijk → de (eindigt op -de)",
                audioHint: "də lifdə"
            ),
            GrammarExample(
                dutch: "het boek",
                english: "the book",
                breakdown: "onzijdig → het",
                audioHint: "hət buk"
            ),
            GrammarExample(
                dutch: "de boeken",
                english: "the books",
                breakdown: "meervoud: boek + en",
                audioHint: "də bukə(n)"
            ),
            GrammarExample(
                dutch: "de school",
                english: "the school",
                breakdown: "vrouwelijk → de",
                audioHint: "də sxoːl"
            ),
            GrammarExample(
                dutch: "de scholen",
                english: "the schools",
                breakdown: "meervoud: school + en",
                audioHint: "də sxoːlə(n)"
            ),
            GrammarExample(
                dutch: "het kind",
                english: "the child",
                breakdown: "onzijdig → het",
                audioHint: "hət kɪnt"
            ),
            GrammarExample(
                dutch: "de kinderen",
                english: "the children",
                breakdown: "onregelmatig meervoud",
                audioHint: "də kɪndərə(n)"
            ),
            GrammarExample(
                dutch: "de vriend",
                english: "the friend",
                breakdown: "mannelijk → de",
                audioHint: "də vrint"
            ),
            GrammarExample(
                dutch: "de vrienden",
                english: "the friends",
                breakdown: "meervoud: vriend + en",
                audioHint: "də vrində(n)"
            ),
            GrammarExample(
                dutch: "het idee",
                english: "the idea",
                breakdown: "onzijdig → het",
                audioHint: "hət ideː"
            ),
            GrammarExample(
                dutch: "de ideeën",
                english: "the ideas",
                breakdown: "meervoud: idee + ën",
                audioHint: "də ideːə(n)"
            ),
            GrammarExample(
                dutch: "het mannetje",
                english: "the little man",
                breakdown: "verkleinwoord → altijd het",
                audioHint: "hət mɑnətjə"
            ),
            GrammarExample(
                dutch: "het huisje",
                english: "the little house",
                breakdown: "verkleinwoord → altijd het",
                audioHint: "hət hɵisjə"
            ),
            GrammarExample(
                dutch: "de vrijheid",
                english: "freedom",
                breakdown: "eindigt op -heid → de",
                audioHint: "də vrɛihɛit"
            ),
            GrammarExample(
                dutch: "de kennis",
                english: "knowledge",
                breakdown: "eindigt op -nis → de",
                audioHint: "də kɛnis"
            ),
            GrammarExample(
                dutch: "de vergadering",
                english: "the meeting",
                breakdown: "eindigt op -ing → de",
                audioHint: "də vərɣaːdərɪŋ"
            ),
            GrammarExample(
                dutch: "de kunst",
                english: "art",
                breakdown: "eindigt op -st → de",
                audioHint: "də kɵnst"
            )
        ],
        exercises: [
            // Article exercises
            GrammarExercise(
                question: "Welk lidwoord gebruik je voor 'man'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "'Man' is een mannelijk woord, dus gebruik 'de'",
                hint: "Mannelijke woorden krijgen 'de'"
            ),
            GrammarExercise(
                question: "Welk lidwoord gebruik je voor 'huis'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 1,
                explanation: "'Huis' is een onzijdig woord, dus gebruik 'het'",
                hint: "Onzijdige woorden krijgen 'het'"
            ),
            GrammarExercise(
                question: "Complete: '___ hond blaft' (The dog barks)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 0,
                explanation: "'Hond' is een mannelijk woord, dus 'De hond blaft'",
                hint: "Honden zijn mannelijk",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: '___ boek is interessant' (The book is interesting)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 1,
                explanation: "'Boek' is een onzijdig woord, dus 'Het boek is interessant'",
                hint: "Boeken zijn onzijdig",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Welk lidwoord gebruik je voor 'auto'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "'Auto' is een mannelijk woord, dus gebruik 'de'",
                hint: "Auto's zijn mannelijk"
            ),
            GrammarExercise(
                question: "Complete: '___ kind speelt' (The child plays)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 1,
                explanation: "'Kind' is een onzijdig woord, dus 'Het kind speelt'",
                hint: "Kinderen zijn onzijdig",
                exerciseType: .fillInTheBlank
            ),
            
            // Plural exercises
            GrammarExercise(
                question: "Wat is het meervoud van 'man'?",
                options: ["mans", "mannen", "manen", "mannes"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'man' is 'mannen' (man + en)",
                hint: "Meestal voeg je -en toe"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'huis'?",
                options: ["huizen", "huises", "huisjes", "huizen"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'huis' is 'huizen' (huis + en)",
                hint: "Meestal voeg je -en toe"
            ),
            GrammarExercise(
                question: "Complete: 'De ___ blaffen' (The dogs bark)",
                options: ["hond", "honden", "honds", "hondes"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'hond' is 'honden' (hond + en)",
                hint: "Meestal voeg je -en toe",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'auto'?",
                options: ["auto's", "autos", "auten", "autoën"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'auto' is 'auto's' (auto + 's)",
                hint: "Sommige woorden krijgen -s"
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn duur' (The cars are expensive)",
                options: ["auto", "auto's", "autos", "auten"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'auto' is 'auto's'",
                hint: "Auto's krijgen -'s in meervoud",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'kind'?",
                options: ["kinds", "kindes", "kinderen", "kindjes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'kind' is 'kinderen' (onregelmatig)",
                hint: "Dit is een onregelmatig meervoud"
            ),
            GrammarExercise(
                question: "Complete: 'De ___ spelen buiten' (The children play outside)",
                options: ["kind", "kinds", "kinderen", "kindjes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'kind' is 'kinderen'",
                hint: "Dit is een onregelmatig meervoud",
                exerciseType: .fillInTheBlank
            ),
            
            // Diminutive exercises
            GrammarExercise(
                question: "Welk lidwoord gebruik je voor 'mannetje'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 1,
                explanation: "Verkleinwoorden krijgen altijd 'het'",
                hint: "Verkleinwoorden zijn altijd onzijdig"
            ),
            GrammarExercise(
                question: "Complete: '___ huisje is klein' (The little house is small)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 1,
                explanation: "Verkleinwoorden krijgen altijd 'het'",
                hint: "Huisje is een verkleinwoord",
                exerciseType: .fillInTheBlank
            ),
            
            // Pattern exercises
            GrammarExercise(
                question: "Welk lidwoord gebruik je voor 'vrijheid'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "Woorden die eindigen op -heid krijgen 'de'",
                hint: "Kijk naar de uitgang van het woord"
            ),
            GrammarExercise(
                question: "Welk lidwoord gebruik je voor 'vergadering'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "Woorden die eindigen op -ing krijgen 'de'",
                hint: "Kijk naar de uitgang van het woord"
            ),
            GrammarExercise(
                question: "Complete: '___ kennis is macht' (Knowledge is power)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 0,
                explanation: "Woorden die eindigen op -nis krijgen 'de'",
                hint: "Kennis eindigt op -nis",
                exerciseType: .fillInTheBlank
            ),
            
            // Translation exercises
            GrammarExercise(
                question: "How do you say 'The man reads a book' in Dutch?",
                options: ["De man leest een boek", "Het man leest een boek", "De man leest een boek", "Het man leest een boek"],
                correctAnswer: 0,
                explanation: "De man leest een boek - 'man' is masculine, so 'de'",
                hint: "Man is a masculine word",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The house is big' in Dutch?",
                options: ["De huis is groot", "Het huis is groot", "De huis is groot", "Het huis is groot"],
                correctAnswer: 1,
                explanation: "Het huis is groot - 'huis' is neuter, so 'het'",
                hint: "Huis is a neuter word",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "Complete: '___ hond blaft' (The dog barks)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 0,
                explanation: "De hond blaft - 'hond' is masculine",
                hint: "Hond is a masculine word",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: '___ boek is interessant' (The book is interesting)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 1,
                explanation: "Het boek is interessant - 'boek' is neuter",
                hint: "Boek is a neuter word",
                exerciseType: .fillInTheBlank
            ),
            
            // True/False exercises
            GrammarExercise(
                question: "True or False: All plural nouns use 'de'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! All plural nouns in Dutch use 'de', regardless of their gender in singular form.",
                hint: "Think about the rule for plurals",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: Diminutives always use 'het'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! All diminutives (words ending in -je, -tje) use 'het' regardless of the original word's gender.",
                hint: "Think about verkleinwoorden",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: Words ending in -heid are always 'de' words",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! Words ending in -heid are always feminine and therefore use 'de'.",
                hint: "Think about the pattern for -heid words",
                exerciseType: .trueFalse
            ),
            
            // More article exercises
            GrammarExercise(
                question: "Which article do you use for 'vrouw' (woman)?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "'Vrouw' is a feminine word, so use 'de'",
                hint: "Feminine words get 'de'"
            ),
            GrammarExercise(
                question: "Which article do you use for 'tafel' (table)?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "'Tafel' is a feminine word, so use 'de'",
                hint: "Feminine words get 'de'"
            ),
            GrammarExercise(
                question: "Which article do you use for 'water' (water)?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 1,
                explanation: "'Water' is a neuter word, so use 'het'",
                hint: "Neuter words get 'het'"
            ),
            GrammarExercise(
                question: "Which article do you use for 'brood' (bread)?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 1,
                explanation: "'Brood' is a neuter word, so use 'het'",
                hint: "Neuter words get 'het'"
            ),
            
            // More plural exercises
            GrammarExercise(
                question: "What is the plural of 'vrouw' (woman)?",
                options: ["vrouwen", "vrouws", "vrouwen", "vrouwes"],
                correctAnswer: 0,
                explanation: "The plural of 'vrouw' is 'vrouwen' (vrouw + en)",
                hint: "Usually add -en"
            ),
            GrammarExercise(
                question: "What is the plural of 'tafel' (table)?",
                options: ["tafels", "tafelen", "tafels", "tafelen"],
                correctAnswer: 0,
                explanation: "The plural of 'tafel' is 'tafels' (tafel + s)",
                hint: "Some words get -s"
            ),
            GrammarExercise(
                question: "What is the plural of 'stad' (city)?",
                options: ["stads", "steden", "staden", "stadden"],
                correctAnswer: 1,
                explanation: "The plural of 'stad' is 'steden' (irregular)",
                hint: "This is an irregular plural"
            ),
            
            // More translation exercises
            GrammarExercise(
                question: "How do you say 'The women work' in Dutch?",
                options: ["De vrouw werken", "De vrouwen werken", "Het vrouwen werken", "De vrouw werken"],
                correctAnswer: 1,
                explanation: "De vrouwen werken - 'vrouwen' is plural, so 'de'",
                hint: "Plurals always get 'de'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The little dog barks' in Dutch?",
                options: ["De hondje blaft", "Het hondje blaft", "De hondje blaft", "Het hondje blaft"],
                correctAnswer: 1,
                explanation: "Het hondje blaft - 'hondje' is a diminutive, so 'het'",
                hint: "Diminutives always get 'het'",
                exerciseType: .translation
            ),
            
            // Pattern recognition exercises
            GrammarExercise(
                question: "Which article do you use for 'moeilijkheid' (difficulty)?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "Words ending in -heid get 'de'",
                hint: "Look at the ending of the word"
            ),
            GrammarExercise(
                question: "Which article do you use for 'herinnering' (memory)?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "Words ending in -ing get 'de'",
                hint: "Look at the ending of the word"
            ),
            GrammarExercise(
                question: "Which article do you use for 'begrip' (understanding)?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 1,
                explanation: "'Begrip' is a neuter word, so use 'het'",
                hint: "This word doesn't follow a clear pattern"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "het man",
                correct: "de man",
                explanation: "'Man' is masculine, so use 'de', not 'het'"
            ),
            CommonMistake(
                incorrect: "de huis",
                correct: "het huis",
                explanation: "'Huis' is neuter, so use 'het', not 'de'"
            ),
            CommonMistake(
                incorrect: "het mannen",
                correct: "de mannen",
                explanation: "All plurals get 'de', not 'het'"
            ),
            CommonMistake(
                incorrect: "de huisje",
                correct: "het huisje",
                explanation: "Diminutives always get 'het', not 'de'"
            ),
            CommonMistake(
                incorrect: "mans",
                correct: "mannen",
                explanation: "The plural of 'man' is 'mannen' (man + en), not 'mans'"
            ),
            CommonMistake(
                incorrect: "autos",
                correct: "auto's",
                explanation: "The plural of 'auto' is 'auto's' (with apostrophe), not 'autos'"
            ),
            CommonMistake(
                incorrect: "kinds",
                correct: "kinderen",
                explanation: "The plural of 'kind' is 'kinderen' (irregular), not 'kinds'"
            ),
            CommonMistake(
                incorrect: "de vrijheid",
                correct: "de vrijheid",
                explanation: "This is actually correct - words ending in -heid get 'de'"
            ),
            CommonMistake(
                incorrect: "het vergadering",
                correct: "de vergadering",
                explanation: "Words ending in -ing get 'de', not 'het'"
            )
        ],
        tips: [
            "Learn the most common words by heart first",
            "Remember: all plurals get 'de'",
            "Diminutives always get 'het'",
            "Look at the ending of the word for hints",
            "Words ending in -heid, -nis, -ing, -st are usually 'de' words",
            "Words ending in -je, -tje are always 'het' words",
            "Many words you just have to learn (no clear rule)",
            "Practice with real sentences, not just individual words",
            "Watch out with translations: English 'the' ≠ Dutch 'de'",
            "Use a dictionary to check the gender"
        ],
        relatedRules: ["verb_present_a1", "adjectives_a2", "possessives_a2", "demonstratives_a2"]
    )
    
    lazy var demonstrativesA2 = DutchGrammarRule(
        id: "demonstratives_a2",
        title: "Demonstrative Pronouns - Deze and Die (A2)",
        type: .wordOrder,
        level: .a2,
        explanation: """
        Dutch demonstrative pronouns point to specific people, things, or places. They agree with the noun they describe.
        
        **Demonstrative Pronouns:**
        • deze (this/these - near)
        • die (that/those - far)
        
        **Agreement Rules:**
        • deze/die: no ending with 'het' words, -e with 'de' words
        • deze/die: always -e with plural nouns
        
        **Usage:**
        • deze: points to something near (this/these)
        • die: points to something far (that/those)
        • Can be used alone (without noun)
        • Can be used as subject or object
        
        **Position:**
        • Before the noun when used as determiner
        • Can replace the noun when used as pronoun
        """,
        keyPoints: [
            "Deze = this/these (near)",
            "Die = that/those (far)",
            "Het words: no ending",
            "De words: add -e",
            "Plural: always -e",
            "Can be used alone",
            "Agree with noun gender/number"
        ],
        examples: [
            GrammarExample(
                dutch: "Dit boek",
                english: "This book",
                breakdown: "dit (no ending, het word, near)",
                audioHint: "dɪt buk"
            ),
            GrammarExample(
                dutch: "Deze auto",
                english: "This car",
                breakdown: "deze (de word, near)",
                audioHint: "dezə ɵtoː"
            ),
            GrammarExample(
                dutch: "Dat huis",
                english: "That house",
                breakdown: "dat (no ending, het word, far)",
                audioHint: "dɑt hœys"
            ),
            GrammarExample(
                dutch: "Die hond",
                english: "That dog",
                breakdown: "die (de word, far)",
                audioHint: "di hɔnt"
            ),
            GrammarExample(
                dutch: "Deze boeken",
                english: "These books",
                breakdown: "deze (plural, near)",
                audioHint: "dezə bukə(n)"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: '___ boek' (This book)",
                options: ["dit", "deze", "dat", "die"],
                correctAnswer: 0,
                explanation: "Dit boek - 'boek' is a 'het' word, near",
                hint: "Het words use dit/dat"
            ),
            GrammarExercise(
                question: "Complete: '___ auto' (This car)",
                options: ["dit", "deze", "dat", "die"],
                correctAnswer: 1,
                explanation: "Deze auto - 'auto' is a 'de' word, near",
                hint: "De words use deze/die"
            ),
            GrammarExercise(
                question: "Complete: '___ huis' (That house)",
                options: ["dit", "deze", "dat", "die"],
                correctAnswer: 2,
                explanation: "Dat huis - 'huis' is a 'het' word, far",
                hint: "Het words use dit/dat"
            ),
            GrammarExercise(
                question: "Complete: '___ hond' (That dog)",
                options: ["dit", "deze", "dat", "die"],
                correctAnswer: 3,
                explanation: "Die hond - 'hond' is a 'de' word, far",
                hint: "De words use deze/die"
            ),
            GrammarExercise(
                question: "Complete: '___ boeken' (These books)",
                options: ["dit", "deze", "dat", "die"],
                correctAnswer: 1,
                explanation: "Deze boeken - plural, near",
                hint: "Plural uses deze/die"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Deze boek",
                correct: "Dit boek",
                explanation: "Het words use dit/dat, not deze/die"
            ),
            CommonMistake(
                incorrect: "Dit auto",
                correct: "Deze auto",
                explanation: "De words use deze/die, not dit/dat"
            ),
            CommonMistake(
                incorrect: "Deze is mijn boek",
                correct: "Dit is mijn boek",
                explanation: "Agree with the noun being referred to"
            )
        ],
        tips: [
            "Learn the gender of common nouns",
            "Dit/dat for het words",
            "Deze/die for de words",
            "Deze/dit = near",
            "Die/dat = far",
            "Plural always uses deze/die",
            "Can be used alone",
            "Practice with real sentences"
        ],
        relatedRules: ["dutch_nouns_articles_a1", "adjectives_a2"]
    )
    
    // MARK: - Missing B1 Grammar Rules (Restored)
    
    lazy var auxiliaryVerbsB1 = DutchGrammarRule(
        id: "auxiliary_verbs_b1",
        title: "Auxiliary Verbs (Hulpwerkwoorden) - B1",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        Auxiliary verbs (hulpwerkwoorden) are verbs that help form compound tenses and passive voice. The main auxiliary verbs in Dutch are 'hebben', 'zijn', and 'worden'.
        
        **Hebben (to have):**
        • Used for most perfect tenses
        • Ik heb gewerkt (I have worked)
        • Zij heeft gegeten (She has eaten)
        
        **Zijn (to be):**
        • Used for movement verbs and state changes
        • Ik ben naar huis gegaan (I have gone home)
        • Het is koud geworden (It has become cold)
        
        **Worden (to become):**
        • Used for passive voice
        • Het huis wordt gebouwd (The house is being built)
        • De brief werd geschreven (The letter was written)
        
        **Key Patterns:**
        • Perfect tense: hebben/zijn + past participle
        • Passive voice: worden + past participle
        • Future perfect: zullen + hebben/zijn + past participle
        """,
        keyPoints: [
            "Hebben = most perfect tenses",
            "Zijn = movement and state changes",
            "Worden = passive voice",
            "Past participle always at the end",
            "Auxiliary verb conjugates, main verb doesn't",
            "Learn which verbs use 'zijn' vs 'hebben'",
            "Passive voice uses 'worden'",
            "Essential for advanced Dutch"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik heb de krant gelezen.",
                english: "I have read the newspaper.",
                breakdown: "Subject + hebben + object + past participle",
                audioHint: "ik hɛp də krɑnt ɣəleːzə(n)"
            ),
            GrammarExample(
                dutch: "Zij is naar Amsterdam gereisd.",
                english: "She has traveled to Amsterdam.",
                breakdown: "Subject + zijn + direction + past participle",
                audioHint: "zɛi ɪs naːr ɑmstərdɑm ɣərɛist"
            ),
            GrammarExample(
                dutch: "Het huis wordt gebouwd.",
                english: "The house is being built.",
                breakdown: "Subject + worden + past participle",
                audioHint: "hət hɵis ʋɔrt ɣəbɵt"
            ),
            GrammarExample(
                dutch: "Wij hebben al gegeten.",
                english: "We have already eaten.",
                breakdown: "Subject + hebben + adverb + past participle",
                audioHint: "ʋɛi hɛbə(n) ɑl ɣəɣeːtə(n)"
            ),
            GrammarExample(
                dutch: "De trein is vertraagd.",
                english: "The train has been delayed.",
                breakdown: "Subject + zijn + past participle (passive)",
                audioHint: "də trɛin ɪs vərtrɑxt"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: 'Ik ___ de film gezien' (I have seen the film)",
                options: ["heb", "ben", "word", "heeft"],
                correctAnswer: 0,
                explanation: "Ik heb de film gezien - 'zien' uses 'hebben'",
                hint: "Most verbs use 'hebben'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ naar huis gegaan' (She has gone home)",
                options: ["heeft", "is", "wordt", "zijn"],
                correctAnswer: 1,
                explanation: "Zij is naar huis gegaan - 'gaan' is a movement verb, so 'zijn'",
                hint: "Movement verbs use 'zijn'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Het boek ___ gelezen' (The book has been read)",
                options: ["heeft", "is", "wordt", "worden"],
                correctAnswer: 2,
                explanation: "Het boek wordt gelezen - passive voice uses 'worden'",
                hint: "Passive voice = worden",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Which auxiliary verb for 'werken' (to work)?",
                options: ["hebben", "zijn", "worden", "zullen"],
                correctAnswer: 0,
                explanation: "'Werken' uses 'hebben' - it's not a movement verb",
                hint: "Most regular verbs use 'hebben'",
                exerciseType: .multipleChoice
            ),
            GrammarExercise(
                question: "Which auxiliary verb for 'komen' (to come)?",
                options: ["hebben", "zijn", "worden", "zullen"],
                correctAnswer: 1,
                explanation: "'Komen' uses 'zijn' - it's a movement verb",
                hint: "Movement verbs use 'zijn'",
                exerciseType: .multipleChoice
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ al gegeten' (We have already eaten)",
                options: ["hebben", "zijn", "worden", "zullen"],
                correctAnswer: 0,
                explanation: "Wij hebben al gegeten - 'eten' uses 'hebben'",
                hint: "Most verbs use 'hebben'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'De brief ___ geschreven' (The letter was written)",
                options: ["heeft", "is", "wordt", "worden"],
                correctAnswer: 2,
                explanation: "De brief wordt geschreven - passive voice",
                hint: "Passive voice uses 'worden'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Which auxiliary verb for 'blijven' (to stay)?",
                options: ["hebben", "zijn", "worden", "zullen"],
                correctAnswer: 1,
                explanation: "'Blijven' uses 'zijn' - it's a state verb",
                hint: "State and movement verbs use 'zijn'",
                exerciseType: .multipleChoice
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ de krant gelezen' (He has read the newspaper)",
                options: ["heeft", "is", "wordt", "zijn"],
                correctAnswer: 0,
                explanation: "Hij heeft de krant gelezen - 'lezen' uses 'hebben'",
                hint: "Most verbs use 'hebben'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Het is koud ___' (It has become cold)",
                options: ["geworden", "gekomen", "gebleven", "gegaan"],
                correctAnswer: 0,
                explanation: "Het is koud geworden - 'worden' uses 'zijn'",
                hint: "'Worden' (to become) uses 'zijn'",
                exerciseType: .fillInTheBlank
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik ben gewerkt",
                correct: "Ik heb gewerkt",
                explanation: "'Werken' uses 'hebben', not 'zijn'"
            ),
            CommonMistake(
                incorrect: "Zij heeft gekomen",
                correct: "Zij is gekomen",
                explanation: "'Komen' is a movement verb, so use 'zijn'"
            ),
            CommonMistake(
                incorrect: "Het huis is gebouwd",
                correct: "Het huis wordt gebouwd",
                explanation: "Passive voice uses 'worden', not 'zijn'"
            )
        ],
        tips: [
            "Learn which verbs use 'zijn' (movement, state changes)",
            "Most verbs use 'hebben'",
            "Passive voice always uses 'worden'",
            "Past participle goes at the end",
            "Practice with real sentences",
            "Watch out for irregular past participles",
            "Remember: hebben/zijn + past participle = perfect tense",
            "Worden + past participle = passive voice"
        ],
        relatedRules: ["verb_present_a1", "verb_past_a2", "verb_perfect_b1", "fixed_word_combinations_b1"]
    )
    
    lazy var verbPerfectB1 = DutchGrammarRule(
        id: "verb_perfect_b1",
        title: "Perfect Tense (Voltooid Tegenwoordige Tijd) - B1",
        type: .tenses,
        level: .b1,
        explanation: """
        The perfect tense (voltooid tegenwoordige tijd) describes completed actions in the past. It's formed with an auxiliary verb (hebben/zijn) + past participle.
        
        **Formation:**
        • Hebben/zijn + past participle
        • Past participle always at the end of the sentence
        
        **Regular Past Participles:**
        • -en verbs: ge + stem + t/d
        • -en verbs: ge + stem + en
        • 't kofschip rule applies
        
        **Irregular Past Participles:**
        • zijn → geweest
        • hebben → gehad
        • gaan → gegaan
        • komen → gekomen
        • doen → gedaan
        
        **Usage:**
        • Completed actions in the past
        • Actions that have relevance to the present
        • News and recent events
        • Life experiences
        """,
        keyPoints: [
            "Perfect = hebben/zijn + past participle",
            "Past participle at the end",
            "Regular: ge + stem + t/d/en",
            "Learn irregular past participles",
            "Used for completed past actions",
            "Common in spoken Dutch",
            "Essential for storytelling",
            "Practice with real conversations"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik heb gisteren gewerkt.",
                english: "I worked yesterday.",
                breakdown: "Subject + hebben + time + past participle",
                audioHint: "ik hɛp ɣɪstərə(n) ʋɛrkt"
            ),
            GrammarExample(
                dutch: "Zij is naar de winkel geweest.",
                english: "She has been to the shop.",
                breakdown: "Subject + zijn + direction + past participle",
                audioHint: "zɛi ɪs naːr də ʋɪŋəl ɣəʋeːst"
            ),
            GrammarExample(
                dutch: "Wij hebben al gegeten.",
                english: "We have already eaten.",
                breakdown: "Subject + hebben + adverb + past participle",
                audioHint: "ʋɛi hɛbə(n) ɑl ɣəɣeːtə(n)"
            ),
            GrammarExample(
                dutch: "Het heeft gisteren geregend.",
                english: "It rained yesterday.",
                breakdown: "Subject + hebben + time + past participle",
                audioHint: "hət hɛft ɣɪstərə(n) ɣərɛɣənt"
            ),
            GrammarExample(
                dutch: "Hij heeft de film gezien.",
                english: "He has seen the film.",
                breakdown: "Subject + hebben + object + past participle",
                audioHint: "hɛi hɛft də fɪlm ɣəzin"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: 'Ik ___ gisteren gewerkt' (I worked yesterday)",
                options: ["heb", "ben", "word", "heeft"],
                correctAnswer: 0,
                explanation: "Ik heb gisteren gewerkt - 'werken' uses 'hebben'",
                hint: "Most verbs use 'hebben'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ naar huis gegaan' (She has gone home)",
                options: ["heeft", "is", "wordt", "zijn"],
                correctAnswer: 1,
                explanation: "Zij is naar huis gegaan - 'gaan' uses 'zijn'",
                hint: "Movement verbs use 'zijn'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "What is the past participle of 'werken'?",
                options: ["gewerkt", "gewerken", "werkte", "werkten"],
                correctAnswer: 0,
                explanation: "The past participle of 'werken' is 'gewerkt'",
                hint: "Regular -en verb: ge + stem + t",
                exerciseType: .multipleChoice
            ),
            GrammarExercise(
                question: "What is the past participle of 'zijn'?",
                options: ["geweest", "gezijn", "was", "waren"],
                correctAnswer: 0,
                explanation: "The past participle of 'zijn' is 'geweest'",
                hint: "This is irregular",
                exerciseType: .multipleChoice
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ al gegeten' (We have already eaten)",
                options: ["hebben", "zijn", "worden", "zullen"],
                correctAnswer: 0,
                explanation: "Wij hebben al gegeten - 'eten' uses 'hebben'",
                hint: "Most verbs use 'hebben'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "What is the past participle of 'doen'?",
                options: ["gedaan", "gedoet", "deed", "deden"],
                correctAnswer: 0,
                explanation: "The past participle of 'doen' is 'gedaan'",
                hint: "This is irregular",
                exerciseType: .multipleChoice
            ),
            GrammarExercise(
                question: "Complete: 'Het ___ gisteren geregend' (It rained yesterday)",
                options: ["heeft", "is", "wordt", "zijn"],
                correctAnswer: 0,
                explanation: "Het heeft gisteren geregend - 'regenen' uses 'hebben'",
                hint: "Most verbs use 'hebben'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "What is the past participle of 'komen'?",
                options: ["gekomen", "gekamt", "kwam", "kwamen"],
                correctAnswer: 0,
                explanation: "The past participle of 'komen' is 'gekomen'",
                hint: "This is irregular",
                exerciseType: .multipleChoice
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ de film gezien' (He has seen the film)",
                options: ["heeft", "is", "wordt", "zijn"],
                correctAnswer: 0,
                explanation: "Hij heeft de film gezien - 'zien' uses 'hebben'",
                hint: "Most verbs use 'hebben'",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "What is the past participle of 'hebben'?",
                options: ["gehad", "gehebt", "had", "hadden"],
                correctAnswer: 0,
                explanation: "The past participle of 'hebben' is 'gehad'",
                hint: "This is irregular",
                exerciseType: .multipleChoice
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik ben gewerkt",
                correct: "Ik heb gewerkt",
                explanation: "'Werken' uses 'hebben', not 'zijn'"
            ),
            CommonMistake(
                incorrect: "gewerken",
                correct: "gewerkt",
                explanation: "Regular -en verb: ge + stem + t"
            ),
            CommonMistake(
                incorrect: "Ik heb naar huis gegaan",
                correct: "Ik ben naar huis gegaan",
                explanation: "'Gaan' is a movement verb, so use 'zijn'"
            )
        ],
        tips: [
            "Learn irregular past participles by heart",
            "Most verbs use 'hebben'",
            "Movement verbs use 'zijn'",
            "Past participle always at the end",
            "Practice with real conversations",
            "Watch out for 't kofschip rule",
            "Perfect tense is very common in Dutch",
            "Use for completed actions"
        ],
        relatedRules: ["verb_present_a1", "verb_past_a2", "auxiliary_verbs_b1", "t_kofschip_rule_b1"]
    )
    
    lazy var verbsWithFixedPrepositionsB1 = DutchGrammarRule(
        id: "verbs_fixed_prepositions_b1",
        title: "Verbs with Fixed Prepositions - B1",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        Many Dutch verbs are used with specific prepositions that cannot be changed. These combinations must be learned by heart as they don't always translate literally.
        
        **Common Patterns:**
        
        **Verbs + Aan:**
        • denken aan (think about)
        • werken aan (work on)
        • geloven aan (believe in)
        
        **Verbs + Van:**
        • houden van (love/like)
        • dromen van (dream of)
        • genieten van (enjoy)
        
        **Verbs + Met:**
        • spelen met (play with)
        • praten met (talk with)
        • beginnen met (start with)
        
        **Verbs + Voor:**
        • zorgen voor (take care of)
        • betalen voor (pay for)
        • kiezen voor (choose)
        
        **Verbs + Over:**
        • praten over (talk about)
        • denken over (think about)
        • twijfelen over (doubt about)
        """,
        keyPoints: [
            "Learn verb + preposition combinations",
            "Don't translate literally",
            "Prepositions are fixed",
            "Practice with real sentences",
            "Common in everyday Dutch",
            "Essential for fluency",
            "Watch out for English translations",
            "Use in context"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik denk aan mijn familie.",
                english: "I think about my family.",
                breakdown: "Subject + denken + aan + object",
                audioHint: "ik dɛŋk aːn mɛin fɑmili"
            ),
            GrammarExample(
                dutch: "Zij houdt van koffie.",
                english: "She likes coffee.",
                breakdown: "Subject + houden + van + object",
                audioHint: "zɛi hɵt vɑn kɔfi"
            ),
            GrammarExample(
                dutch: "Wij praten over het weer.",
                english: "We talk about the weather.",
                breakdown: "Subject + praten + over + object",
                audioHint: "ʋɛi prɑtə(n) oːvər hət ʋeːr"
            ),
            GrammarExample(
                dutch: "Hij werkt aan een project.",
                english: "He works on a project.",
                breakdown: "Subject + werken + aan + object",
                audioHint: "hɛi ʋɛrkt aːn ən projɛkt"
            ),
            GrammarExample(
                dutch: "Zij zorgt voor de kinderen.",
                english: "She takes care of the children.",
                breakdown: "Subject + zorgen + voor + object",
                audioHint: "zɛi zɔrxt voːr də kɪndərə(n)"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: 'Ik denk ___ mijn werk' (I think about my work)",
                options: ["aan", "van", "met", "voor"],
                correctAnswer: 0,
                explanation: "Ik denk aan mijn werk - 'denken' uses 'aan'",
                hint: "Denken + aan",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij houdt ___ muziek' (She likes music)",
                options: ["aan", "van", "met", "voor"],
                correctAnswer: 1,
                explanation: "Zij houdt van muziek - 'houden' uses 'van'",
                hint: "Houden + van",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Wij praten ___ het nieuws' (We talk about the news)",
                options: ["aan", "van", "over", "voor"],
                correctAnswer: 2,
                explanation: "Wij praten over het nieuws - 'praten' uses 'over'",
                hint: "Praten + over",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij werkt ___ een oplossing' (He works on a solution)",
                options: ["aan", "van", "met", "voor"],
                correctAnswer: 0,
                explanation: "Hij werkt aan een oplossing - 'werken' uses 'aan'",
                hint: "Werken + aan",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij zorgt ___ de patiënten' (She takes care of the patients)",
                options: ["aan", "van", "met", "voor"],
                correctAnswer: 3,
                explanation: "Zij zorgt voor de patiënten - 'zorgen' uses 'voor'",
                hint: "Zorgen + voor",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Ik droom ___ vakantie' (I dream of vacation)",
                options: ["aan", "van", "over", "voor"],
                correctAnswer: 1,
                explanation: "Ik droom van vakantie - 'dromen' uses 'van'",
                hint: "Dromen + van",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Wij spelen ___ de bal' (We play with the ball)",
                options: ["aan", "van", "met", "voor"],
                correctAnswer: 2,
                explanation: "Wij spelen met de bal - 'spelen' uses 'met'",
                hint: "Spelen + met",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij betaalt ___ de rekening' (He pays for the bill)",
                options: ["aan", "van", "met", "voor"],
                correctAnswer: 3,
                explanation: "Hij betaalt voor de rekening - 'betalen' uses 'voor'",
                hint: "Betalen + voor",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij twijfelt ___ de beslissing' (She doubts the decision)",
                options: ["aan", "van", "over", "voor"],
                correctAnswer: 2,
                explanation: "Zij twijfelt over de beslissing - 'twijfelen' uses 'over'",
                hint: "Twijfelen + over",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Wij genieten ___ het eten' (We enjoy the food)",
                options: ["aan", "van", "over", "voor"],
                correctAnswer: 1,
                explanation: "Wij genieten van het eten - 'genieten' uses 'van'",
                hint: "Genieten + van",
                exerciseType: .fillInTheBlank
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik denk van mijn werk",
                correct: "Ik denk aan mijn werk",
                explanation: "'Denken' uses 'aan', not 'van'"
            ),
            CommonMistake(
                incorrect: "Zij houdt aan koffie",
                correct: "Zij houdt van koffie",
                explanation: "'Houden' uses 'van', not 'aan'"
            ),
            CommonMistake(
                incorrect: "Wij praten van het weer",
                correct: "Wij praten over het weer",
                explanation: "'Praten' uses 'over', not 'van'"
            )
        ],
        tips: [
            "Learn verb + preposition combinations by heart",
            "Don't translate literally from English",
            "Practice with real sentences",
            "Common combinations: denken aan, houden van, praten over",
            "Watch out for false friends",
            "Use in context to remember",
            "Listen to native speakers",
            "Practice regularly"
        ],
        relatedRules: ["verb_present_a1", "fixed_word_combinations_b1", "auxiliary_verbs_b1"]
    )
    
    // MARK: - A2 Level Additional Rules
    
    lazy var adjectivesA2 = DutchGrammarRule(
        id: "adjectives_a2",
        title: "Adjectives - Agreement and Position (A2)",
        type: .adjectives,
        level: .a2,
        explanation: """
        In Dutch, adjectives change their form depending on the gender and number of the noun they describe. They also have different positions in the sentence.
        
        **Adjective Agreement:**
        • With 'de' words (masculine/feminine): add -e
        • With 'het' words (neuter): no ending in indefinite, -e in definite
        • With plural nouns: always add -e
        
        **Position:**
        • Before the noun: attributive position (add endings)
        • After the noun: predicative position (no endings)
        • After 'zijn', 'worden', 'blijven': predicative position
        """,
        keyPoints: [
            "De words: adjective + -e",
            "Het words: no ending (indefinite), -e (definite)",
            "Plural: always -e",
            "Before noun: attributive (with endings)",
            "After noun: predicative (no endings)",
            "After zijn/worden/blijven: predicative"
        ],
        examples: [
            GrammarExample(
                dutch: "De grote hond",
                english: "The big dog",
                breakdown: "groot + -e (de word)",
                audioHint: "də xroːtə hɔnt"
            ),
            GrammarExample(
                dutch: "Het kleine huis",
                english: "The small house",
                breakdown: "klein + -e (het word, definite)",
                audioHint: "ət klɛinə hœys"
            ),
            GrammarExample(
                dutch: "Een klein huis",
                english: "A small house",
                breakdown: "klein (no ending, het word, indefinite)",
                audioHint: "ən klɛin hœys"
            ),
            GrammarExample(
                dutch: "De hond is groot",
                english: "The dog is big",
                breakdown: "groot (predicative, no ending)",
                audioHint: "də hɔnt ɪs xroːt"
            ),
            GrammarExample(
                dutch: "Grote huizen",
                english: "Big houses",
                breakdown: "groot + -e (plural)",
                audioHint: "xroːtə hœyzə(n)"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: 'De ___ auto' (The new car)",
                options: ["nieuw", "nieuwe", "nieuws", "nieuwen"],
                correctAnswer: 1,
                explanation: "De nieuwe auto - 'auto' is a 'de' word, so add -e",
                hint: "De words get -e ending"
            ),
            GrammarExercise(
                question: "Complete: 'Het ___ boek' (The old book)",
                options: ["oud", "oude", "ouds", "ouden"],
                correctAnswer: 1,
                explanation: "Het oude boek - 'boek' is a 'het' word, definite, so add -e",
                hint: "Het words get -e when definite"
            ),
            GrammarExercise(
                question: "Complete: 'Een ___ huis' (A beautiful house)",
                options: ["mooi", "mooie", "moois", "mooien"],
                correctAnswer: 0,
                explanation: "Een mooi huis - 'huis' is a 'het' word, indefinite, no ending",
                hint: "Het words get no ending when indefinite"
            ),
            GrammarExercise(
                question: "Complete: 'De hond is ___' (The dog is happy)",
                options: ["blij", "blije", "blijs", "blijen"],
                correctAnswer: 0,
                explanation: "De hond is blij - predicative position, no ending",
                hint: "After 'is' use predicative form"
            ),
            GrammarExercise(
                question: "Complete: '___ kinderen' (Young children)",
                options: ["jong", "jonge", "jongs", "jongen"],
                correctAnswer: 1,
                explanation: "Jonge kinderen - plural, always add -e",
                hint: "Plural nouns always get -e"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Een mooie huis",
                correct: "Een mooi huis",
                explanation: "Het words don't get -e when indefinite"
            ),
            CommonMistake(
                incorrect: "De hond is grote",
                correct: "De hond is groot",
                explanation: "Predicative adjectives don't get endings"
            ),
            CommonMistake(
                incorrect: "Het kleine boek is nieuw",
                correct: "Het kleine boek is nieuw",
                explanation: "Predicative position doesn't get endings"
            )
        ],
        tips: [
            "Learn the gender of common nouns",
            "Practice with both definite and indefinite articles",
            "Remember: predicative = no endings",
            "Plural always gets -e",
            "Het words are tricky - check if definite or indefinite",
            "Use flashcards to memorize gender",
            "Practice with real sentences",
            "Listen to native speakers"
        ],
        relatedRules: ["verb_present_a1", "dutch_nouns_articles_a1"]
    )
    
    lazy var negationA2 = DutchGrammarRule(
        id: "negation_a2",
        title: "Negation - Niet and Geen (A2)",
        type: .negation,
        level: .a2,
        explanation: """
        Dutch has two main ways to make sentences negative: 'niet' and 'geen'.
        
        **Niet (not):**
        • Used to negate verbs, adjectives, adverbs
        • Position: after the verb in simple tenses
        • Position: after the auxiliary verb in compound tenses
        • Position: at the end of the sentence
        
        **Geen (no/not any):**
        • Used to negate nouns (replaces 'een' or 'no article')
        • Used with uncountable nouns
        • Position: before the noun
        • Cannot be used with 'de' or 'het'
        
        **Word Order:**
        • Subject + verb + niet + rest of sentence
        • Subject + verb + geen + noun
        • In questions: verb + subject + niet/geen
        """,
        keyPoints: [
            "Niet = not (verbs, adjectives, adverbs)",
            "Geen = no/not any (nouns)",
            "Niet after verb in simple tenses",
            "Geen before noun",
            "Geen replaces een",
            "Cannot use geen with de/het",
            "Word order: subject + verb + niet/geen"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik werk niet vandaag.",
                english: "I don't work today.",
                breakdown: "Subject + verb + niet + time",
                audioHint: "ɪk ʋɛrk nɪt vɑndaːx"
            ),
            GrammarExample(
                dutch: "Ik heb geen tijd.",
                english: "I don't have time.",
                breakdown: "Subject + verb + geen + noun",
                audioHint: "ɪk hɛp xən tɛit"
            ),
            GrammarExample(
                dutch: "Het is niet koud.",
                english: "It's not cold.",
                breakdown: "Subject + verb + niet + adjective",
                audioHint: "ət ɪs nɪt kɵt"
            ),
            GrammarExample(
                dutch: "Wij hebben geen auto.",
                english: "We don't have a car.",
                breakdown: "Subject + verb + geen + noun",
                audioHint: "ʋɛi hɛbə(n) xən ɵtoː"
            ),
            GrammarExample(
                dutch: "Zij spreekt niet snel.",
                english: "She doesn't speak quickly.",
                breakdown: "Subject + verb + niet + adverb",
                audioHint: "zɛi spreːkt nɪt snɛl"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: 'Ik ___ vandaag' (I don't work today)",
                options: ["werk niet", "niet werk", "geen werk", "werk geen"],
                correctAnswer: 0,
                explanation: "Ik werk niet vandaag - niet after verb",
                hint: "Niet goes after the verb"
            ),
            GrammarExercise(
                question: "Complete: 'Ik heb ___ tijd' (I don't have time)",
                options: ["niet", "geen", "niet een", "geen een"],
                correctAnswer: 1,
                explanation: "Ik heb geen tijd - geen replaces een",
                hint: "Use geen with nouns"
            ),
            GrammarExercise(
                question: "Complete: 'Het is ___ warm' (It's not warm)",
                options: ["niet", "geen", "niet een", "geen een"],
                correctAnswer: 0,
                explanation: "Het is niet warm - niet with adjective",
                hint: "Use niet with adjectives"
            ),
            GrammarExercise(
                question: "Complete: 'Wij hebben ___ auto' (We don't have a car)",
                options: ["niet", "geen", "niet een", "geen een"],
                correctAnswer: 1,
                explanation: "Wij hebben geen auto - geen replaces een",
                hint: "Geen replaces een"
            ),
            GrammarExercise(
                question: "Complete: 'Zij spreekt ___ Nederlands' (She doesn't speak Dutch)",
                options: ["niet", "geen", "niet een", "geen een"],
                correctAnswer: 0,
                explanation: "Zij spreekt niet Nederlands - niet with language",
                hint: "Use niet with languages"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik heb niet tijd",
                correct: "Ik heb geen tijd",
                explanation: "Use geen with nouns, niet with verbs/adjectives"
            ),
            CommonMistake(
                incorrect: "Het is geen warm",
                correct: "Het is niet warm",
                explanation: "Use niet with adjectives, geen with nouns"
            ),
            CommonMistake(
                incorrect: "Ik werk geen vandaag",
                correct: "Ik werk niet vandaag",
                explanation: "Use niet with time expressions, geen with nouns"
            )
        ],
        tips: [
            "Niet = not (verbs, adjectives, adverbs)",
            "Geen = no/not any (nouns)",
            "Geen replaces een",
            "Cannot use geen with de/het",
            "Practice with both types",
            "Learn common patterns",
            "Pay attention to word order",
            "Listen to native speakers"
        ],
        relatedRules: ["verb_present_a1", "dutch_nouns_articles_a1"]
    )
    
    lazy var possessivesA2 = DutchGrammarRule(
        id: "possessives_a2",
        title: "Possessive Pronouns (A2)",
        type: .wordOrder,
        level: .a2,
        explanation: """
        Dutch possessive pronouns show ownership and agree with the noun they describe, not the owner.
        
        **Possessive Pronouns:**
        • mijn (my)
        • jouw/je (your - informal)
        • zijn (his/its)
        • haar (her)
        • ons/onze (our)
        • jullie (your - plural)
        • hun (their)
        
        **Agreement Rules:**
        • mijn, jouw, zijn, haar, ons: no ending with 'het' words, -e with 'de' words
        • onze: always -e (used with 'de' words)
        • jullie, hun: always -e
        
        **Position:**
        • Always before the noun
        • Cannot be used alone (need a noun)
        • Can be emphasized with 'eigen' (own)
        """,
        keyPoints: [
            "Agree with noun, not owner",
            "Mijn/jouw/zijn/haar/ons: no ending with het, -e with de",
            "Onze: always -e (de words only)",
            "Jullie/hun: always -e",
            "Always before noun",
            "Cannot be used alone",
            "Can add 'eigen' for emphasis"
        ],
        examples: [
            GrammarExample(
                dutch: "Mijn boek",
                english: "My book",
                breakdown: "mijn (no ending, het word)",
                audioHint: "mɛin buk"
            ),
            GrammarExample(
                dutch: "Mijn auto",
                english: "My car",
                breakdown: "mijn + -e (de word)",
                audioHint: "mɛin ɵtoː"
            ),
            GrammarExample(
                dutch: "Ons huis",
                english: "Our house",
                breakdown: "ons (no ending, het word)",
                audioHint: "ɔns hœys"
            ),
            GrammarExample(
                dutch: "Onze auto",
                english: "Our car",
                breakdown: "onze (always -e, de word)",
                audioHint: "ɔnzə ɵtoː"
            ),
            GrammarExample(
                dutch: "Jullie boeken",
                english: "Your books",
                breakdown: "jullie (always -e, plural)",
                audioHint: "jɵli bukə(n)"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: '___ boek' (My book)",
                options: ["mijn", "mijne", "mijns", "mijnen"],
                correctAnswer: 0,
                explanation: "Mijn boek - 'boek' is a 'het' word, no ending",
                hint: "Het words get no ending"
            ),
            GrammarExercise(
                question: "Complete: '___ auto' (My car)",
                options: ["mijn", "mijne", "mijns", "mijnen"],
                correctAnswer: 1,
                explanation: "Mijne auto - 'auto' is a 'de' word, add -e",
                hint: "De words get -e ending"
            ),
            GrammarExercise(
                question: "Complete: '___ huis' (Our house)",
                options: ["ons", "onze", "onss", "onsen"],
                correctAnswer: 0,
                explanation: "Ons huis - 'huis' is a 'het' word, no ending",
                hint: "Het words get no ending"
            ),
            GrammarExercise(
                question: "Complete: '___ auto' (Our car)",
                options: ["ons", "onze", "onss", "onsen"],
                correctAnswer: 1,
                explanation: "Onze auto - 'auto' is a 'de' word, use onze",
                hint: "De words use onze"
            ),
            GrammarExercise(
                question: "Complete: '___ boeken' (Your books)",
                options: ["jullie", "jullies", "jullie's", "jullien"],
                correctAnswer: 0,
                explanation: "Jullie boeken - jullie always has -e",
                hint: "Jullie always has -e"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Mijne boek",
                correct: "Mijn boek",
                explanation: "Het words don't get -e ending"
            ),
            CommonMistake(
                incorrect: "Mijn auto",
                correct: "Mijne auto",
                explanation: "De words get -e ending"
            ),
            CommonMistake(
                incorrect: "Ons auto",
                correct: "Onze auto",
                explanation: "Use onze with de words"
            )
        ],
        tips: [
            "Learn the gender of common nouns",
            "Remember: agree with noun, not owner",
            "Het words: no ending",
            "De words: add -e",
            "Onze: always -e (de words only)",
            "Jullie/hun: always -e",
            "Practice with real sentences",
            "Use flashcards to memorize"
        ],
        relatedRules: ["dutch_nouns_articles_a1", "adjectives_a2"]
    )
    
    // MARK: - All Grammar Rules Array
    
    lazy var allGrammarRules: [DutchGrammarRule] = [
        // A1 Level
        presentTenseA1,
        irregularVerbsA1,
        dutchNounsAndArticlesA1,
        
        // A2 Level  
        pastTenseA2,
        verledenTijdA2,
        dutchInformalContractionsA2,
        contractionsCliticsA2,
        wordClassificationSentenceAnalysisA2,
        
        // B1 Level
        auxiliaryVerbsB1,
        verbPerfectB1,
        verbsWithFixedPrepositionsB1,
        fixedWordCombinationsB1,
        tKofschipRuleB1,
        
        // A2 Level Additional Rules
        adjectivesA2,
        negationA2,
        possessivesA2,
        demonstrativesA2
    ]
    
    // MARK: - Helper Methods
    
    func getRulesByLevel(_ level: LanguageLevel) -> [DutchGrammarRule] {
        return allGrammarRules.filter { $0.level == level }
    }
    
    func getRulesByType(_ type: GrammarRuleType) -> [DutchGrammarRule] {
        return allGrammarRules.filter { $0.type == type }
    }
    
    func getRuleById(_ id: String) -> DutchGrammarRule? {
        return allGrammarRules.first { $0.id == id }
    }
    
    func getRelatedRules(for ruleId: String) -> [DutchGrammarRule] {
        guard let rule = getRuleById(ruleId) else { return [] }
        return rule.relatedRules.compactMap { getRuleById($0) }
    }
} 


