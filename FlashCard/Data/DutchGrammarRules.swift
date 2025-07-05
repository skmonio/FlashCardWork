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
        title: "Tegenwoordige Tijd - Regelmatige Werkwoorden (A1)",
        type: .verbConjugation,
        level: .a1,
        explanation: """
        In het Nederlands vervoeg je werkwoorden door uitgangen toe te voegen aan de stam van het werkwoord. De stam krijg je door -en van de infinitief (hele werkwoord) af te halen.
        
        Bijvoorbeeld: 'werken' → stam = 'werk'
        
        Voor regelmatige werkwoorden in de tegenwoordige tijd gebruik je deze uitgangen:
        • ik: stam (geen uitgang)
        • jij/je: stam + t
        • hij/zij/het: stam + t
        • wij/we: hele werkwoord (infinitief)
        • jullie: hele werkwoord (infinitief)
        • zij: hele werkwoord (infinitief)
        """,
        keyPoints: [
            "Stam = infinitief minus -en",
            "Ik = alleen de stam",
            "Jij/hij/zij = stam + t",
            "Wij/jullie/zij = hele werkwoord",
            "Let op: bij vragen draait 'jij' om naar 'jij' (zonder extra -t)"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik werk in een kantoor.",
                english: "I work in an office.",
                breakdown: "werk (stam) - geen uitgang bij 'ik'",
                audioHint: "ik vɛrk"
            ),
            GrammarExample(
                dutch: "Jij werkt hard.",
                english: "You work hard.",
                breakdown: "werk (stam) + t = werkt",
                audioHint: "jɛi vɛrkt"
            ),
            GrammarExample(
                dutch: "Hij woont in Amsterdam.",
                english: "He lives in Amsterdam.",
                breakdown: "woon (stam) + t = woont",
                audioHint: "hɛi voːnt"
            ),
            GrammarExample(
                dutch: "Wij leren Nederlands.",
                english: "We learn Dutch.",
                breakdown: "leren (hele werkwoord) - geen verandering",
                audioHint: "vɛi leːrə(n)"
            ),
            GrammarExample(
                dutch: "Jullie spelen voetbal.",
                english: "You (plural) play football.",
                breakdown: "spelen (hele werkwoord) - geen verandering",
                audioHint: "jɵli speːlə(n)"
            ),
            GrammarExample(
                dutch: "Zij koken samen.",
                english: "They cook together.",
                breakdown: "koken (hele werkwoord) - geen verandering",
                audioHint: "zɛi koːkə(n)"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Vervoeging van 'maken' (to make): Ik ... elke dag huiswerk.",
                options: ["maak", "maakt", "maken", "maakte"],
                correctAnswer: 0,
                explanation: "Bij 'ik' gebruik je alleen de stam: maak (maken - en = maak)",
                hint: "Bij 'ik' gebruik je geen uitgang"
            ),
            GrammarExercise(
                question: "Vervoeging van 'wonen' (to live): Hij ... in Utrecht.",
                options: ["woon", "woont", "wonen", "woonde"],
                correctAnswer: 1,
                explanation: "Bij 'hij' gebruik je stam + t: woon + t = woont",
                hint: "Bij 'hij/zij' voeg je -t toe aan de stam"
            ),
            GrammarExercise(
                question: "Vervoeging van 'studeren' (to study): Wij ... aan de universiteit.",
                options: ["studeer", "studeert", "studeren", "studeerde"],
                correctAnswer: 2,
                explanation: "Bij 'wij' gebruik je het hele werkwoord: studeren",
                hint: "Bij 'wij/jullie/zij' gebruik je de infinitief"
            ),
            // New translation exercises
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
                question: "Complete: 'Ik ___ elke dag naar school' (I go to school every day)",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 0,
                explanation: "Ik ga elke dag naar school - 'ga' is the stem form for 'ik'",
                hint: "This is the present tense, and 'ik' uses the stem",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "True or False: 'Hij werkt' is correct Dutch for 'He works'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Hij werkt' is correct - 'hij' + stem + t",
                hint: "Think about the conjugation rule for 'hij'",
                exerciseType: .trueFalse
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik werkt",
                correct: "Ik werk",
                explanation: "Bij 'ik' voeg je geen -t toe, alleen de stam"
            ),
            CommonMistake(
                incorrect: "Hij werk",
                correct: "Hij werkt",
                explanation: "Bij 'hij/zij' moet je -t toevoegen aan de stam"
            ),
            CommonMistake(
                incorrect: "Wij werkt",
                correct: "Wij werken",
                explanation: "Bij 'wij/jullie/zij' gebruik je het hele werkwoord"
            )
        ],
        tips: [
            "Oefen met de stam eerst: schrijf de infinitief op en haal -en eraf",
            "Onthoud: ik=stam, jij/hij/zij=stam+t, wij/jullie/zij=infinitief",
            "Bij vragen met 'jij' krijg je geen extra -t: 'Werk jij?' (niet 'Werkt jij?')",
            "Luister naar Nederlandse gesprekken om het ritme te leren"
        ],
        relatedRules: ["verb_irregular_a1", "verb_questions_a1", "verb_negation_a1"]
    )
    
    lazy var irregularVerbsA1 = DutchGrammarRule(
        id: "verb_irregular_a1",
        title: "Onregelmatige Werkwoorden - Basis (A1)",
        type: .verbConjugation,
        level: .a1,
        explanation: """
        Sommige werkwoorden zijn onregelmatig. Dit betekent dat ze niet de normale regels volgen. De belangrijkste onregelmatige werkwoorden voor beginners zijn:
        
        • zijn (to be) - heel onregelmatig
        • hebben (to have) - kleine veranderingen
        • gaan (to go) - kleine veranderingen
        • doen (to do) - kleine veranderingen
        • komen (to come) - kleine veranderingen
        
        Deze werkwoorden moet je uit je hoofd leren omdat ze heel vaak gebruikt worden.
        """,
        keyPoints: [
            "Onregelmatige werkwoorden volgen niet de normale regels",
            "'Zijn' is het meest onregelmatige werkwoord",
            "Leer de belangrijkste onregelmatige werkwoorden uit je hoofd",
            "Deze werkwoorden komen heel vaak voor in gesprekken"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik ben student.",
                english: "I am a student.",
                breakdown: "zijn: ik ben (niet 'ik zij')",
                audioHint: "ik bɛn"
            ),
            GrammarExample(
                dutch: "Jij bent aardig.",
                english: "You are nice.",
                breakdown: "zijn: jij bent (niet 'jij zijt')",
                audioHint: "jɛi bɛnt"
            ),
            GrammarExample(
                dutch: "Hij is thuis.",
                english: "He is at home.",
                breakdown: "zijn: hij is (niet 'hij zijt')",
                audioHint: "hɛi ɪs"
            ),
            GrammarExample(
                dutch: "Ik heb een auto.",
                english: "I have a car.",
                breakdown: "hebben: ik heb (stam hebb → heb)",
                audioHint: "ik hɛp"
            ),
            GrammarExample(
                dutch: "Zij heeft een hond.",
                english: "She has a dog.",
                breakdown: "hebben: zij heeft (niet 'zij hebt')",
                audioHint: "zɛi heːft"
            ),
            GrammarExample(
                dutch: "Wij gaan naar school.",
                english: "We go to school.",
                breakdown: "gaan: wij gaan (regelmatig in meervoud)",
                audioHint: "vɛi ɣaːn"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Vervoeging van 'zijn': Ik ... moe.",
                options: ["zij", "ben", "bent", "is"],
                correctAnswer: 1,
                explanation: "'Zijn' bij 'ik' wordt 'ben'",
                hint: "Het werkwoord 'zijn' is heel onregelmatig"
            ),
            GrammarExercise(
                question: "Vervoeging van 'hebben': Hij ... honger.",
                options: ["heb", "hebt", "heeft", "hebben"],
                correctAnswer: 2,
                explanation: "'Hebben' bij 'hij' wordt 'heeft'",
                hint: "Bij 'hij/zij' van 'hebben' gebruik je 'heeft'"
            ),
            GrammarExercise(
                question: "Vervoeging van 'gaan': Wij ... winkelen.",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 2,
                explanation: "Bij 'wij' gebruik je de infinitief 'gaan'",
                hint: "Bij 'wij/jullie/zij' blijft het werkwoord hetzelfde"
            ),
            // New translation exercises
            GrammarExercise(
                question: "How do you say 'I am tired' in Dutch?",
                options: ["Ik zij moe", "Ik ben moe", "Ik bent moe", "Ik is moe"],
                correctAnswer: 1,
                explanation: "Ik ben moe - 'zijn' becomes 'ben' for 'ik'",
                hint: "Remember: 'ik' uses 'ben' with 'zijn'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'She has a car' in Dutch?",
                options: ["Zij heb een auto", "Zij hebt een auto", "Zij heeft een auto", "Zij hebben een auto"],
                correctAnswer: 2,
                explanation: "Zij heeft een auto - 'hebben' becomes 'heeft' for 'hij/zij'",
                hint: "Remember: 'hij/zij' uses 'heeft' with 'hebben'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ naar de winkel' (We go to the store)",
                options: ["ga", "gaat", "gaan", "ging"],
                correctAnswer: 2,
                explanation: "Wij gaan naar de winkel - 'gaan' stays the same for 'wij'",
                hint: "For 'wij', use the infinitive form",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "True or False: 'Jij bent' is correct Dutch for 'You are'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Jij bent' is correct - 'zijn' becomes 'bent' for 'jij'",
                hint: "Think about the conjugation of 'zijn'",
                exerciseType: .trueFalse
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik zij",
                correct: "Ik ben",
                explanation: "'Zijn' bij 'ik' wordt altijd 'ben'"
            ),
            CommonMistake(
                incorrect: "Hij hebt",
                correct: "Hij heeft",
                explanation: "'Hebben' bij 'hij/zij' wordt 'heeft' (niet 'hebt')"
            ),
            CommonMistake(
                incorrect: "Jij bent niet → Jij ben niet",
                correct: "Jij bent niet",
                explanation: "In negatieve zinnen blijft 'bent' gewoon 'bent'"
            )
        ],
        tips: [
            "Leer 'zijn' eerst: ik ben, jij bent, hij/zij is, wij/jullie/zij zijn",
            "Oefen deze werkwoorden elke dag - ze komen heel vaak voor",
            "Maak zinnen met deze werkwoorden om ze te onthouden",
            "Let op: 'hebben' heeft een f-klank bij hij/zij: 'heeft'"
        ],
        relatedRules: ["verb_present_a1", "verb_negation_a1", "verb_questions_a1"]
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
    
    // MARK: - B1 Level Verb Conjugation Rules
    
    lazy var perfectTenseB1 = DutchGrammarRule(
        id: "verb_perfect_b1",
        title: "Voltooid Tegenwoordige Tijd (Perfectum) - B1",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        De voltooid tegenwoordige tijd (perfectum) gebruik je om te vertellen over iets dat in het verleden gebeurde maar nog effect heeft op nu, of om ervaringen te beschrijven.
        
        Vorm: hebben/zijn + voltooid deelwoord (past participle)
        
        Voltooid deelwoord vorming:
        • Regelmatige werkwoorden: ge- + stam + -d/-t (volgens 't kofschip regel)
        • Onregelmatige werkwoorden: speciale vormen (moet je leren)
        
        Hulpwerkwoord kiezen:
        • HEBBEN: de meeste werkwoorden
        • ZIJN: beweging, verandering van toestand, zijn/blijven/worden
        """,
        keyPoints: [
            "Perfectum = hebben/zijn + voltooid deelwoord",
            "Voltooid deelwoord: ge- + stam + d/t",
            "'t kofschip regel geldt ook hier",
            "ZIJN voor beweging en verandering",
            "HEBBEN voor alle andere werkwoorden",
            "Onregelmatige werkwoorden hebben speciale vormen"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik heb gewerkt.",
                english: "I have worked.",
                breakdown: "hebben + ge-werk-t (k is hard)",
                audioHint: "ik hɛp ɣəvɛrkt"
            ),
            GrammarExample(
                dutch: "Zij heeft gekookt.",
                english: "She has cooked.",
                breakdown: "hebben + ge-kook-t (k is hard)",
                audioHint: "zɛi heːft ɣəkoːkt"
            ),
            GrammarExample(
                dutch: "Wij zijn gegaan.",
                english: "We have gone.",
                breakdown: "zijn + gegaan (beweging + onregelmatig)",
                audioHint: "vɛi zɛin ɣəɣaːn"
            ),
            GrammarExample(
                dutch: "Hij is gevallen.",
                english: "He has fallen.",
                breakdown: "zijn + gevallen (beweging/verandering)",
                audioHint: "hɛi ɪs ɣəvɑlə(n)"
            ),
            GrammarExample(
                dutch: "Jullie hebben geleerd.",
                english: "You have learned.",
                breakdown: "hebben + ge-leer-d (r is zacht)",
                audioHint: "jɵli hɛbə(n) ɣəleːrt"
            ),
            GrammarExample(
                dutch: "Ik ben geweest.",
                english: "I have been.",
                breakdown: "zijn + geweest (zijn is onregelmatig)",
                audioHint: "ik bɛn ɣəveːst"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "What is the plural of 'het huis' (house)?",
                options: ["de huiss", "de huizen", "de huisen", "het huizen"],
                correctAnswer: 1,
                explanation: "Huis becomes huizen with vowel change (ui → ui) and -EN ending. Remember: all plurals use DE.",
                hint: "Think about vowel changes and which article plurals use"
            ),
            GrammarExercise(
                question: "What is the plural of 'de computer'?",
                options: ["de computeren", "de computers", "de computeres", "het computers"],
                correctAnswer: 1,
                explanation: "Foreign words like 'computer' typically add -S to form the plural.",
                hint: "Computer is a foreign/borrowed word"
            ),
            GrammarExercise(
                question: "What is the plural of 'de man' (man)?",
                options: ["de mans", "de mannen", "de manen", "het mannen"],
                correctAnswer: 1,
                explanation: "Man becomes mannen (double n + -EN). This is a common pattern for words ending in a single consonant.",
                hint: "Single consonants often double before -EN"
            ),
            GrammarExercise(
                question: "What is the plural of 'idee'?",
                options: ["idees", "ideeen", "ideeën", "ideëns"],
                correctAnswer: 2,
                explanation: "The correct plural is 'ideeën' (with trema).",
                hint: "Watch for the trema (¨) in Dutch plurals."
            ),
            GrammarExercise(
                question: "What is the plural of 'zee'?",
                options: ["zeeën", "zees", "zeeen", "zeeën"],
                correctAnswer: 0,
                explanation: "The correct plural is 'zeeën'.",
                hint: "Double e and trema."
            ),
            GrammarExercise(
                question: "What is the plural of 'vrijheid'?",
                options: ["vrijheden", "vrijheids", "vrijheiden", "vrijheeds"],
                correctAnswer: 0,
                explanation: "The correct plural is 'vrijheden'.",
                hint: "Words ending in -heid get -heden."
            ),
            GrammarExercise(
                question: "What is the plural of 'mogelijkheid'?",
                options: ["mogelijkheden", "mogelijks", "mogelijkheidens", "mogelijkheid"],
                correctAnswer: 0,
                explanation: "The correct plural is 'mogelijkheden'.",
                hint: "Words ending in -heid get -heden."
            ),
            GrammarExercise(
                question: "What is the plural of 'monteur'?",
                options: ["monteurs", "monteuren", "monteueren", "monteuurs"],
                correctAnswer: 0,
                explanation: "The correct plural is 'monteurs'.",
                hint: "Professions ending in -eur get -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'regisseur'?",
                options: ["regisseurs", "regisseuren", "regisseus", "regisseuren"],
                correctAnswer: 0,
                explanation: "The correct plural is 'regisseurs'.",
                hint: "Professions ending in -eur get -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'dak'?",
                options: ["daken", "daks", "dakenen", "dakkes"],
                correctAnswer: 0,
                explanation: "The correct plural is 'daken'.",
                hint: "Short vowel, just add -en."
            ),
            GrammarExercise(
                question: "What is the plural of 'glas'?",
                options: ["glazen", "glassen", "glass", "glazens"],
                correctAnswer: 0,
                explanation: "The correct plural is 'glazen'.",
                hint: "Irregular: vowel change."
            ),
            GrammarExercise(
                question: "What is the plural of 'bedrag'?",
                options: ["bedragen", "bedragenen", "bedraags", "bedraggen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'bedragen'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "What is the plural of 'verslag'?",
                options: ["verslagen", "verslags", "verslaggen", "verslaggen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'verslagen'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "What is the plural of 'weg'?",
                options: ["wegen", "wegs", "weggen", "weegen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'wegen'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "What is the plural of 'pad'?",
                options: ["paden", "pads", "padden", "padenen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'paden'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "What is the plural of 'slot'?",
                options: ["sloten", "slots", "slotten", "sloten"],
                correctAnswer: 0,
                explanation: "The correct plural is 'sloten'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "What is the plural of 'blad' (leaf)?",
                options: ["bladeren", "blads", "bladden", "bladens"],
                correctAnswer: 0,
                explanation: "The correct plural is 'bladeren'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "What is the plural of 'ei'?",
                options: ["eieren", "eis", "eien", "eier"],
                correctAnswer: 0,
                explanation: "The correct plural is 'eieren'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "What is the plural of 'kind'?",
                options: ["kinderen", "kinds", "kinden", "kinderen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'kinderen'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "What is the plural of 'lied'?",
                options: ["liederen", "lieds", "lieds", "liederenen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'liederen'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "What is the plural of 'broer'?",
                options: ["broers", "broeren", "broeren", "broerss"],
                correctAnswer: 0,
                explanation: "The correct plural is 'broers'.",
                hint: "Just add -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'cadeau'?",
                options: ["cadeaus", "cadeau's", "cadeauen", "cadeaunen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'cadeaus'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'café'?",
                options: ["cafés", "cafees", "cafe's", "cafes"],
                correctAnswer: 0,
                explanation: "The correct plural is 'cafés'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'datum'?",
                options: ["datums", "datumen", "datumsen", "datum's"],
                correctAnswer: 0,
                explanation: "The correct plural is 'datums'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'e-mail'?",
                options: ["e-mails", "e-mailen", "e-mailes", "e-mail's"],
                correctAnswer: 0,
                explanation: "The correct plural is 'e-mails'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'koe'?",
                options: ["koeien", "koes", "koeen", "koeën"],
                correctAnswer: 0,
                explanation: "The correct plural is 'koeien'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "What is the plural of 'restaurant'?",
                options: ["restaurants", "restauranten", "restaurant's", "restaurantenen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'restaurants'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'stad'?",
                options: ["steden", "stads", "staden", "stadden"],
                correctAnswer: 0,
                explanation: "The correct plural is 'steden'.",
                hint: "Vowel change."
            ),
            GrammarExercise(
                question: "What is the plural of 'oom'?",
                options: ["ooms", "oomen", "oomens", "oomes"],
                correctAnswer: 0,
                explanation: "The correct plural is 'ooms'.",
                hint: "Just add -s."
            ),
            GrammarExercise(
                question: "What is the plural of 'museum'?",
                options: ["museums", "musea", "museumsen", "museumen"],
                correctAnswer: 1,
                explanation: "The correct plural is 'musea'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "What is the plural of 'lid'?",
                options: ["leden", "lidden", "lids", "lidderen"],
                correctAnswer: 0,
                explanation: "The correct plural is 'leden'.",
                hint: "Irregular plural."
            ),
            // Fill in the blank exercises
            GrammarExercise(
                question: "het kind → ___ (the children)",
                options: ["kinderen", "kinds", "kinders", "kindes"],
                correctAnswer: 0,
                explanation: "The plural of 'het kind' is 'kinderen'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "het ei → ___ (the eggs)",
                options: ["eieren", "eis", "eien", "eiers"],
                correctAnswer: 0,
                explanation: "The plural of 'het ei' is 'eieren'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "het blad → ___ (the leaves)",
                options: ["bladeren", "blads", "bladden", "blades"],
                correctAnswer: 0,
                explanation: "The plural of 'het blad' is 'bladeren'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "de broer → ___ (the brothers)",
                options: ["broers", "broeren", "broeders", "broersen"],
                correctAnswer: 0,
                explanation: "The plural of 'de broer' is 'broers'.",
                hint: "Just add -s."
            ),
            GrammarExercise(
                question: "de datum → ___ (the dates)",
                options: ["datums", "datumen", "datumsen", "datum's"],
                correctAnswer: 0,
                explanation: "The plural of 'de datum' is 'datums'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "het café → ___ (the cafés)",
                options: ["cafés", "cafees", "cafe's", "cafesen"],
                correctAnswer: 0,
                explanation: "The plural of 'het café' is 'cafés'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "de koe → ___ (the cows)",
                options: ["koeien", "koes", "koeen", "koeën"],
                correctAnswer: 0,
                explanation: "The plural of 'de koe' is 'koeien'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "het restaurant → ___ (the restaurants)",
                options: ["restaurants", "restauranten", "restaurant's", "restaurantes"],
                correctAnswer: 0,
                explanation: "The plural of 'het restaurant' is 'restaurants'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "de stad → ___ (the cities)",
                options: ["steden", "stads", "staden", "stadden"],
                correctAnswer: 0,
                explanation: "The plural of 'de stad' is 'steden'.",
                hint: "Vowel change."
            ),
            GrammarExercise(
                question: "het lid → ___ (the members)",
                options: ["leden", "lids", "lidderen", "lidsen"],
                correctAnswer: 0,
                explanation: "The plural of 'het lid' is 'leden'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "het museum → ___ (the museums)",
                options: ["musea", "museums", "museumen", "museumsen"],
                correctAnswer: 0,
                explanation: "The plural of 'het museum' is 'musea'.",
                hint: "Irregular plural."
            ),
            GrammarExercise(
                question: "de e-mail → ___ (the emails)",
                options: ["e-mails", "e-mailen", "e-mailes", "e-mail's"],
                correctAnswer: 0,
                explanation: "The plural of 'de e-mail' is 'e-mails'.",
                hint: "Foreign word, add -s."
            ),
            GrammarExercise(
                question: "het slot → ___ (the locks)",
                options: ["sloten", "slots", "slotten", "slotenen"],
                correctAnswer: 0,
                explanation: "The plural of 'het slot' is 'sloten'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "het glas → ___ (the glasses)",
                options: ["glazen", "glassen", "glass", "glasen"],
                correctAnswer: 0,
                explanation: "The plural of 'het glas' is 'glazen'.",
                hint: "Irregular: vowel change."
            ),
            GrammarExercise(
                question: "het pad → ___ (the paths)",
                options: ["paden", "pads", "padden", "padenen"],
                correctAnswer: 0,
                explanation: "The plural of 'het pad' is 'paden'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "de weg → ___ (the roads)",
                options: ["wegen", "wegs", "weggen", "weegen"],
                correctAnswer: 0,
                explanation: "The plural of 'de weg' is 'wegen'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "het verslag → ___ (the reports)",
                options: ["verslagen", "verslags", "verslaggen", "verslagenen"],
                correctAnswer: 0,
                explanation: "The plural of 'het verslag' is 'verslagen'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "het bedrag → ___ (the amounts)",
                options: ["bedragen", "bedrags", "bedraggen", "bedragenen"],
                correctAnswer: 0,
                explanation: "The plural of 'het bedrag' is 'bedragen'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "het dak → ___ (the roofs)",
                options: ["daken", "daks", "dakken", "dakenen"],
                correctAnswer: 0,
                explanation: "The plural of 'het dak' is 'daken'.",
                hint: "Just add -en."
            ),
            GrammarExercise(
                question: "de vrijheid → ___ (the freedoms)",
                options: ["vrijheden", "vrijheids", "vrijheidens", "vrijhedens"],
                correctAnswer: 0,
                explanation: "The plural of 'de vrijheid' is 'vrijheden'.",
                hint: "Words ending in -heid get -heden."
            ),
            // --- END: Added pluralization exercises ---
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "het boeken (plural)",
                correct: "de boeken",
                explanation: "All plurals use DE, never HET"
            ),
            CommonMistake(
                incorrect: "de huiss",
                correct: "de huizen",
                explanation: "Don't just add -S to everything - many words need -EN with vowel changes"
            ),
            CommonMistake(
                incorrect: "de kinds",
                correct: "de kinderen",
                explanation: "Some words have completely irregular plurals that must be memorized"
            )
        ],
        tips: [
            "Learn common irregular plurals: kind→kinderen, ei→eieren, blad→bladeren, glas→glazen",
            "Words ending in -HEID always become -HEDEN: vrijheid→vrijheden, mogelijkheid→mogelijkheden",
            "Use apostrophe + S (-'s) for words ending in vowels: auto→auto's, café→café's, taxi→taxi's",
            "Words ending in -je (diminutives) always add -s: meisje→meisjes, boekje→boekjes",
            "Words ending in -f often change to -v: brief→brieven, wolf→wolven",
            "Practice saying plurals out loud to remember vowel changes",
            "When in doubt with Dutch words, try -EN first",
            "Remember: ALL plurals use DE as the article"
        ],
        relatedRules: ["articles_a1", "adjectives_a2", "demonstratives_a2"]
    )
    
    lazy var adjectivesA2 = DutchGrammarRule(
        id: "adjectives_a2",
        title: "Adjective Endings in Dutch (A2)",
        type: .adjectives,
        level: .a2,
        explanation: """
        Dutch adjectives change their form depending on the noun they describe. This is one of the trickier aspects of Dutch grammar, but there are clear rules.
        
        Basic rule: Adjectives get an -E ending EXCEPT:
        • Before HET-words that are singular and indefinite (een + het-word)
        • When the adjective already ends in -en
        
        Examples:
        • de grote hond (the big dog) - DE word gets -E
        • een grote hond (a big dog) - DE word gets -E  
        • het grote huis (the big house) - HET word + definite gets -E
        • een groot huis (a big house) - HET word + indefinite gets NO -E
        
        This system helps distinguish between DE and HET words!
        """,
        keyPoints: [
            "Adjectives usually add -E when describing nouns",
            "Exception: HET-words with EEN (indefinite) get no -E",
            "DE-words always get -E on their adjectives",
            "Definite HET-words (het grote huis) get -E",
            "This rule helps you identify DE vs HET words",
            "Adjectives ending in -en don't change"
        ],
        examples: [
            GrammarExample(
                dutch: "de kleine kat",
                english: "the small cat",
                breakdown: "DE-word: adjective gets -E (klein → kleine)",
                audioHint: "də klɛinə kɑt"
            ),
            GrammarExample(
                dutch: "een kleine kat",
                english: "a small cat",
                breakdown: "DE-word with EEN: adjective still gets -E",
                audioHint: "ən klɛinə kɑt"
            ),
            GrammarExample(
                dutch: "het kleine kind",
                english: "the small child",
                breakdown: "HET-word with definite article: adjective gets -E",
                audioHint: "ət klɛinə kɪnt"
            ),
            GrammarExample(
                dutch: "een klein kind",
                english: "a small child",
                breakdown: "HET-word with EEN: adjective gets NO -E",
                audioHint: "ən klɛin kɪnt"
            ),
            GrammarExample(
                dutch: "de mooie bloemen",
                english: "the beautiful flowers",
                breakdown: "Plural (always DE): adjective gets -E",
                audioHint: "də moiə blumə(n)"
            ),
            GrammarExample(
                dutch: "een duur boek vs het dure boek",
                english: "an expensive book vs the expensive book",
                breakdown: "Shows the difference: EEN+HET=no E, HET+definite=E",
                audioHint: "ən dyr buk vs ət dyrə buk"
            ),
            GrammarExample(
                dutch: "de gebroken raam",
                english: "the broken window",
                breakdown: "Adjective ending in -EN doesn't change",
                audioHint: "də ɣəbrokə(n) raːm"
            ),
            GrammarExample(
                dutch: "een open deur",
                english: "an open door",
                breakdown: "OPEN ends in -EN, so no change needed",
                audioHint: "ən opə(n) dør"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Choose the correct form: 'een ___ huis' (big house)",
                options: ["grote", "groot", "groten", "groote"],
                correctAnswer: 1,
                explanation: "Huis is a HET-word. With EEN (indefinite), the adjective gets no -E: een groot huis.",
                hint: "Is 'huis' a DE or HET word? Is it definite or indefinite?"
            ),
            GrammarExercise(
                question: "Choose the correct form: 'de ___ auto' (red car)",
                options: ["rood", "rode", "roden", "roode"],
                correctAnswer: 1,
                explanation: "Auto is a DE-word. DE-words always get -E on their adjectives: de rode auto.",
                hint: "DE-words always get -E on adjectives"
            ),
            GrammarExercise(
                question: "Choose the correct form: 'het ___ meisje' (sweet girl)",
                options: ["lief", "lieve", "lieven", "liefe"],
                correctAnswer: 1,
                explanation: "With definite article HET, the adjective gets -E: het lieve meisje.",
                hint: "This is definite (het), not indefinite (een)"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "een grote huis",
                correct: "een groot huis",
                explanation: "HET-words with EEN don't get -E on the adjective"
            ),
            CommonMistake(
                incorrect: "de groot auto",
                correct: "de grote auto",
                explanation: "DE-words always get -E on their adjectives"
            ),
            CommonMistake(
                incorrect: "het groot kind",
                correct: "het grote kind",
                explanation: "Definite HET-words (het + adjective + noun) get -E"
            )
        ],
        tips: [
            "Use this rule to test if a word is DE or HET: if 'een + adjective + noun' needs -E, it's a DE-word",
            "Practice with color adjectives: een rood huis, de rode auto",
            "Remember: definite = -E, indefinite HET-word = no -E",
            "Adjectives ending in -en (open, gebroken) never change",
            "When in doubt, listen to how Dutch speakers emphasize the adjective"
        ],
        relatedRules: ["articles_a1", "pluralization_a2", "demonstratives_a2"]
    )
    
    // MARK: - Additional B1 Level Rules
    
    lazy var modalVerbsB1 = DutchGrammarRule(
        id: "modal_verbs_b1",
        title: "Modal Verbs: Can, Must, Want, May (B1)",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        Modal verbs express ability, necessity, permission, or desire. They are followed by an infinitive verb at the end of the sentence. Dutch modal verbs are irregular and must be memorized.
        
        Main modal verbs:
        • KUNNEN (can/to be able to) - ability or possibility
        • MOETEN (must/to have to) - necessity or obligation  
        • WILLEN (want/to want to) - desire or intention
        • MOGEN (may/to be allowed to) - permission
        • ZULLEN (will/shall) - future tense helper
        
        Structure: Subject + modal verb + ... + infinitive (at the end)
        Example: Ik kan goed zwemmen (I can swim well)
        
        In questions and subordinate clauses, word order changes but the infinitive stays at the end.
        """,
        keyPoints: [
            "Modal verbs are irregular and must be memorized",
            "Always followed by infinitive at the end of sentence",
            "KUNNEN = can/able, MOETEN = must, WILLEN = want",
            "MOGEN = may/allowed, ZULLEN = will/future",
            "Word order: modal verb + middle + infinitive",
            "Modal verbs change the meaning of the main verb"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik kan Nederlands spreken.",
                english: "I can speak Dutch.",
                breakdown: "kan (modal) + Nederlands (object) + spreken (infinitive)",
                audioHint: "ik kɑn neːdərlɑnts spreːkə(n)"
            ),
            GrammarExample(
                dutch: "Zij moet morgen werken.",
                english: "She must work tomorrow.",
                breakdown: "moet (modal) + morgen (time) + werken (infinitive)",
                audioHint: "zɛi mut mɔrɣə(n) vɛrkə(n)"
            ),
            GrammarExample(
                dutch: "Wij willen een huis kopen.",
                english: "We want to buy a house.",
                breakdown: "willen (modal) + een huis (object) + kopen (infinitive)",
                audioHint: "vɛi vɪlə(n) ən hœys kopə(n)"
            ),
            GrammarExample(
                dutch: "Mag ik hier roken?",
                english: "May I smoke here?",
                breakdown: "Question: mag (modal) + ik (subject) + hier + roken (infinitive)",
                audioHint: "mɑx ik hir rokə(n)"
            ),
            GrammarExample(
                dutch: "Jullie zullen het begrijpen.",
                english: "You will understand it.",
                breakdown: "zullen (future modal) + het (object) + begrijpen (infinitive)",
                audioHint: "jɵli zɵlə(n) ət bəɣrɛipə(n)"
            ),
            GrammarExample(
                dutch: "Ik denk dat hij kan komen.",
                english: "I think that he can come.",
                breakdown: "Subordinate clause: hij (subject) + kan (modal) + komen (infinitive)",
                audioHint: "ik dɛŋk dɑt hɛi kɑn komə(n)"
            ),
            GrammarExample(
                dutch: "Kunnen jullie me helpen?",
                english: "Can you help me?",
                breakdown: "Question with modal: kunnen + jullie + me + helpen",
                audioHint: "kɵnə(n) jɵli mə hɛlpə(n)"
            ),
            GrammarExample(
                dutch: "Zij wil niet mee gaan.",
                english: "She doesn't want to come along.",
                breakdown: "wil (modal) + niet (negation) + mee gaan (separable verb)",
                audioHint: "zɛi vɪl nit meː ɣaːn"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Complete: 'Ik ___ morgen niet werken' (I don't have to work tomorrow)",
                options: ["kan", "moet", "hoef", "wil"],
                correctAnswer: 2,
                explanation: "For 'don't have to', Dutch uses 'hoef niet' rather than 'moet niet'. 'Moet niet' means 'must not' (forbidden).",
                hint: "Think about the difference between 'don't have to' and 'must not'"
            ),
            GrammarExercise(
                question: "Word order: 'Hij / kan / goed / zwemmen' - arrange correctly",
                options: ["Hij zwemmen kan goed", "Hij kan goed zwemmen", "Hij goed kan zwemmen", "Kan hij goed zwemmen"],
                correctAnswer: 1,
                explanation: "Correct order: Hij (subject) + kan (modal) + goed (adverb) + zwemmen (infinitive at end).",
                hint: "Modal verb comes early, infinitive comes at the end"
            ),
            GrammarExercise(
                question: "Choose the correct modal: 'Jij ___ hier niet parkeren' (You're not allowed to park here)",
                options: ["kunt", "moet", "mag", "wilt"],
                correctAnswer: 2,
                explanation: "'Mag niet' means 'not allowed to'. This is about permission, so we use MOGEN.",
                hint: "This is about permission/rules"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik moet niet werken (I must not work)",
                correct: "Ik hoef niet te werken (I don't have to work)",
                explanation: "'Moet niet' means forbidden, 'hoef niet' means not necessary"
            ),
            CommonMistake(
                incorrect: "Ik kan spreken Nederlands",
                correct: "Ik kan Nederlands spreken",
                explanation: "The infinitive (spreken) must come at the end of the sentence"
            ),
            CommonMistake(
                incorrect: "Wil jij komt morgen?",
                correct: "Wil jij morgen komen?",
                explanation: "Use infinitive (komen) not conjugated form (komt) after modal verbs"
            )
        ],
        tips: [
            "Practice modal verb conjugations: ik kan, jij kunt, hij kan, wij kunnen...",
            "Remember: infinitive always goes to the end",
            "MOET NIET = forbidden, HOEF NIET = not necessary",
            "MAG = permission, KAN = ability, WIL = desire",
            "In subordinate clauses, modal and infinitive can cluster at the end"
        ],
        relatedRules: ["word_order_complex_b1", "verb_perfect_b1", "negation_b1"]
    )
    
    lazy var separableVerbsB1 = DutchGrammarRule(
        id: "separable_verbs_b1",
        title: "Separable Verbs: Splitting and Combining (B1)",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        Dutch has many separable verbs - verbs that split into two parts in certain situations. The prefix separates from the main verb and moves to the end of the sentence.
        
        Common separable verbs:
        • MEEKOMEN (come along) → Kom je mee? (Are you coming along?)
        • UITSTAPPEN (get off/out) → Ik stap uit (I get off)
        • AANKOMEN (arrive) → De trein komt aan (The train arrives)
        • OPBELLEN (call up) → Ik bel je op (I'll call you)
        
        When they separate:
        - In main clauses (present/past tense)
        - In questions and commands
        
        When they stay together:
        - With modal verbs (infinitive form)
        - In subordinate clauses
        - In perfect tense (past participle)
        """,
        keyPoints: [
            "Separable verbs split in main clauses",
            "Prefix goes to the end of the sentence",
            "Stay together with modal verbs",
            "Stay together in subordinate clauses",
            "Past participle keeps prefix: meegenomen",
            "Very common in everyday Dutch"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik kom morgen mee.",
                english: "I'm coming along tomorrow.",
                breakdown: "meekomen splits: kom (verb) + mee (prefix at end)",
                audioHint: "ik kɔm mɔrɣə(n) meː"
            ),
            GrammarExample(
                dutch: "Stap je hier uit?",
                english: "Are you getting off here?",
                breakdown: "uitstappen splits: stap (verb) + uit (prefix at end)",
                audioHint: "stɑp jə hir œyt"
            ),
            GrammarExample(
                dutch: "Ik wil meekomen.",
                english: "I want to come along.",
                breakdown: "With modal 'wil': stays together as infinitive 'meekomen'",
                audioHint: "ik vɪl meːkomə(n)"
            ),
            GrammarExample(
                dutch: "Hij belt zijn moeder op.",
                english: "He calls his mother.",
                breakdown: "opbellen splits: belt (verb) + op (prefix after object)",
                audioHint: "hɛi bɛlt zɛin mudər ɔp"
            ),
            GrammarExample(
                dutch: "Ik denk dat hij meekomt.",
                english: "I think that he's coming along.",
                breakdown: "In subordinate clause: stays together 'meekomt'",
                audioHint: "ik dɛŋk dɑt hɛi meːkɔmt"
            ),
            GrammarExample(
                dutch: "Zij is gisteren aangekomen.",
                english: "She arrived yesterday.",
                breakdown: "Perfect tense: aangekomen (prefix stays with past participle)",
                audioHint: "zɛi ɪs ɣɪstərə(n) aːŋəkomə(n)"
            ),
            GrammarExample(
                dutch: "Doe je jas aan!",
                english: "Put on your coat!",
                breakdown: "aandoen (put on) splits in command: doe + aan",
                audioHint: "du jə jɑs aːn"
            ),
            GrammarExample(
                dutch: "De winkel gaat om 9 uur open.",
                english: "The store opens at 9 o'clock.",
                breakdown: "opengaan splits: gaat + open (at the end)",
                audioHint: "də vɪŋkəl ɣaːt ɔm neːɣən yr opə(n)"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "How do you say 'I'm calling you' with 'opbellen'?",
                options: ["Ik opbel je", "Ik bel je op", "Ik bel op je", "Ik opbellen je"],
                correctAnswer: 1,
                explanation: "Separable verb splits: 'Ik bel je op' (I call you up). The prefix 'op' goes to the end.",
                hint: "The prefix separates and goes to the end"
            ),
            GrammarExercise(
                question: "Complete with 'meegaan': 'Ik wil graag ___'",
                options: ["mee gaan", "meegaan", "gaan mee", "mee ga"],
                correctAnswer: 1,
                explanation: "With modal verbs, separable verbs stay together as infinitive: 'Ik wil graag meegaan'.",
                hint: "After modal verbs, use the infinitive form"
            ),
            GrammarExercise(
                question: "Past participle of 'uitstappen' (get off): 'Ik ben ___'",
                options: ["gestappen uit", "uitgestappen", "gestappt uit", "uit gestappen"],
                correctAnswer: 1,
                explanation: "Past participle keeps the prefix: 'uitgestappen'. 'Ik ben uitgestappen' (I have gotten off).",
                hint: "Past participles keep their prefixes attached"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik meekom morgen",
                correct: "Ik kom morgen mee",
                explanation: "In main clauses, separable verbs must split with prefix at the end"
            ),
            CommonMistake(
                incorrect: "Ik wil mee komen",
                correct: "Ik wil meekomen",
                explanation: "With modal verbs, keep separable verbs together as infinitive"
            ),
            CommonMistake(
                incorrect: "Hij heeft op gebeld",
                correct: "Hij heeft opgebeld",
                explanation: "Past participles keep the prefix attached to the main verb"
            )
        ],
        tips: [
            "Learn common separable verbs: aankomen, meegaan, uitstappen, opbellen",
            "Practice splitting: 'Ik ga mee' vs 'Ik wil meegaan'",
            "Listen for the stress: separable prefixes are usually stressed",
            "In dictionaries, separable verbs are shown with • : mee•komen",
            "Think of the prefix as 'jumping' to the end of the sentence"
        ],
        relatedRules: ["modal_verbs_b1", "word_order_complex_b1", "verb_perfect_b1"]
    )
    
    lazy var negationA2 = DutchGrammarRule(
        id: "negation_a2",
        title: "Negation: Niet, Geen, and No (A2)",
        type: .negation,
        level: .a2,
        explanation: """
        Dutch has two main ways to make sentences negative: NIET and GEEN. The choice depends on what you're negating.
        
        Use NIET:
        • To negate verbs, adjectives, and adverbs
        • With definite articles (de/het)
        • With possessive pronouns (mijn, jouw, etc.)
        • Generally placed after the main verb
        
        Use GEEN:
        • Instead of EEN (indefinite article)
        • With plural nouns that have no article
        • GEEN = not a/not any
        
        Word order matters: NIET usually comes late in the sentence, but there are specific rules for its placement.
        """,
        keyPoints: [
            "NIET = not (for verbs, adjectives, definite nouns)",
            "GEEN = not a/not any (replaces EEN or no article)",
            "NIET usually comes after the main verb",
            "GEEN directly replaces EEN in the sentence",
            "Never use NIET + EEN together",
            "Word order is crucial for NIET placement"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik heb een auto → Ik heb geen auto",
                english: "I have a car → I don't have a car",
                breakdown: "GEEN replaces EEN (indefinite article)",
                audioHint: "ik hɛp ən ɔto → ik hɛp ɣeːn ɔto"
            ),
            GrammarExample(
                dutch: "Ik zie de auto → Ik zie de auto niet",
                english: "I see the car → I don't see the car",
                breakdown: "NIET negates verb, comes at end with definite article",
                audioHint: "ik zi də ɔto → ik zi də ɔto nit"
            ),
            GrammarExample(
                dutch: "Hij werkt → Hij werkt niet",
                english: "He works → He doesn't work",
                breakdown: "NIET negates the verb, placed at the end",
                audioHint: "hɛi vɛrkt → hɛi vɛrkt nit"
            ),
            GrammarExample(
                dutch: "Wij hebben kinderen → Wij hebben geen kinderen",
                english: "We have children → We don't have children",
                breakdown: "GEEN with plural noun (no article)",
                audioHint: "vɛi hɛbə(n) kɪndərə(n) → vɛi hɛbə(n) ɣeːn kɪndərə(n)"
            ),
            GrammarExample(
                dutch: "Het is mooi → Het is niet mooi",
                english: "It's beautiful → It's not beautiful",
                breakdown: "NIET negates adjective",
                audioHint: "ət ɪs moːi → ət ɪs nit moːi"
            ),
            GrammarExample(
                dutch: "Ik ga naar huis → Ik ga niet naar huis",
                english: "I'm going home → I'm not going home",
                breakdown: "NIET comes before prepositional phrase",
                audioHint: "ik ɣaː naːr hœys → ik ɣaː nit naːr hœys"
            ),
            GrammarExample(
                dutch: "Dit is mijn boek → Dit is niet mijn boek",
                english: "This is my book → This is not my book",
                breakdown: "NIET with possessive pronoun",
                audioHint: "dɪt ɪs mɛin buk → dɪt ɪs nit mɛin buk"
            ),
            GrammarExample(
                dutch: "Ik kan zwemmen → Ik kan niet zwemmen",
                english: "I can swim → I can't swim",
                breakdown: "NIET comes before infinitive with modal verbs",
                audioHint: "ik kɑn zvɛmə(n) → ik kɑn nit zvɛmə(n)"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Make negative: 'Ik heb een hond' (I have a dog)",
                options: ["Ik heb niet een hond", "Ik heb geen hond", "Ik heb de hond niet", "Ik niet heb een hond"],
                correctAnswer: 1,
                explanation: "GEEN replaces EEN: 'Ik heb geen hond' (I don't have a dog). Never use 'niet een' together.",
                hint: "What article needs to be replaced?"
            ),
            GrammarExercise(
                question: "Make negative: 'Hij is thuis' (He is at home)",
                options: ["Hij is geen thuis", "Hij niet is thuis", "Hij is niet thuis", "Hij is thuis geen"],
                correctAnswer: 2,
                explanation: "NIET negates the verb 'is': 'Hij is niet thuis' (He is not at home).",
                hint: "You're negating the verb 'is'"
            ),
            GrammarExercise(
                question: "Make negative: 'Wij eten brood' (We eat bread)",
                options: ["Wij eten niet brood", "Wij eten geen brood", "Wij niet eten brood", "Wij eten brood niet"],
                correctAnswer: 1,
                explanation: "'Brood' has no article, so use GEEN: 'Wij eten geen brood' (We don't eat bread).",
                hint: "Is there an article with 'brood'?"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik heb niet een auto",
                correct: "Ik heb geen auto",
                explanation: "Never combine NIET with EEN - use GEEN instead"
            ),
            CommonMistake(
                incorrect: "Hij werkt geen",
                correct: "Hij werkt niet",
                explanation: "GEEN can't be used alone - it must be followed by a noun"
            ),
            CommonMistake(
                incorrect: "Ik niet kan komen",
                correct: "Ik kan niet komen",
                explanation: "NIET comes after the modal verb, before the infinitive"
            )
        ],
        tips: [
            "Think: EEN → GEEN, everything else → NIET",
            "NIET usually comes at the end, but before infinitives and prepositional phrases",
            "Practice: 'Ik heb een...' → 'Ik heb geen...'",
            "GEEN always needs a noun after it",
            "Listen to where Dutch speakers place NIET - it varies by sentence type"
        ],
        relatedRules: ["articles_a1", "modal_verbs_b1", "word_order_basic_a1"]
    )
    
    lazy var possessivesA2 = DutchGrammarRule(
        id: "possessives_a2",
        title: "Possessive Pronouns: My, Your, His, Her (A2)",
        type: .adjectives,
        level: .a2,
        explanation: """
        Dutch possessive pronouns show ownership and must agree with the noun they modify, not the owner. They follow the same adjective ending rules as other adjectives.
        
        Possessive pronouns:
        • MIJN (my) - always stays the same
        • JOUW/JE (your, informal) - jouw is stressed, je is unstressed
        • UW (your, formal) - always stays the same
        • ZIJN (his) - always stays the same
        • HAAR (her) - always stays the same
        • ONS/ONZE (our) - ONS before HET-words, ONZE before DE-words
        • JULLIE (your, plural) - always stays the same
        • HUN (their) - always stays the same
        
        Only ONS/ONZE changes based on the noun's gender!
        """,
        keyPoints: [
            "Most possessives don't change: mijn, jouw, zijn, haar, jullie, hun",
            "UW is formal 'your', JOUW/JE is informal 'your'",
            "Only ONS/ONZE changes: ONS + HET-words, ONZE + DE-words",
            "Possessives replace articles (don't use de/het with them)",
            "JE is unstressed version of JOUW",
            "Agreement is with the noun, not the owner"
        ],
        examples: [
            GrammarExample(
                dutch: "mijn huis, mijn auto, mijn kinderen",
                english: "my house, my car, my children",
                breakdown: "MIJN never changes regardless of the noun",
                audioHint: "mɛin hœys, mɛin ɔto, mɛin kɪndərə(n)"
            ),
            GrammarExample(
                dutch: "jouw boek vs je boek",
                english: "your book vs your book",
                breakdown: "JOUW is stressed (emphasis), JE is unstressed (normal)",
                audioHint: "jɑu buk vs jə buk"
            ),
            GrammarExample(
                dutch: "zijn vader, haar moeder",
                english: "his father, her mother",
                breakdown: "ZIJN and HAAR never change",
                audioHint: "zɛin vaːdər, haːr mudər"
            ),
            GrammarExample(
                dutch: "ons huis, onze auto",
                english: "our house, our car",
                breakdown: "ONS with HET-word (huis), ONZE with DE-word (auto)",
                audioHint: "ɔns hœys, ɔnzə ɔto"
            ),
            GrammarExample(
                dutch: "jullie hond, hun kat",
                english: "your dog (plural you), their cat",
                breakdown: "JULLIE and HUN never change",
                audioHint: "jɵli hɔnt, hɵn kɑt"
            ),
            GrammarExample(
                dutch: "Meneer, uw tas is hier",
                english: "Sir, your bag is here",
                breakdown: "UW is formal 'your' - used with strangers/older people",
                audioHint: "məneːr, yu tɑs ɪs hir"
            ),
            GrammarExample(
                dutch: "onze kinderen vs ons kind",
                english: "our children vs our child",
                breakdown: "ONZE with plural (always DE), ONS with singular HET-word",
                audioHint: "ɔnzə kɪndərə(n) vs ɔns kɪnt"
            ),
            GrammarExample(
                dutch: "Is dit jouw fiets of haar fiets?",
                english: "Is this your bike or her bike?",
                breakdown: "JOUW (stressed - contrasting), HAAR (her)",
                audioHint: "ɪs dɪt jɑu fits ɔf haːr fits"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Choose the correct form: '___ huis is groot' (our house is big)",
                options: ["Ons", "Onze", "Onzes", "Onsen"],
                correctAnswer: 0,
                explanation: "HUIS is a HET-word, so use ONS: 'Ons huis is groot'.",
                hint: "Is 'huis' a DE-word or HET-word?"
            ),
            GrammarExercise(
                question: "Choose the correct form: '___ kinderen spelen' (their children play)",
                options: ["Hun", "Hunne", "Huns", "Hune"],
                correctAnswer: 0,
                explanation: "HUN never changes: 'Hun kinderen spelen' (Their children play).",
                hint: "Does HUN change like ONS/ONZE?"
            ),
            GrammarExercise(
                question: "Formal vs informal: How do you say 'your book' to your teacher?",
                options: ["jouw boek", "je boek", "uw boek", "jullie boek"],
                correctAnswer: 2,
                explanation: "Use UW for formal situations: 'uw boek' when speaking to teachers, strangers, older people.",
                hint: "Teachers require formal language"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "de mijn auto",
                correct: "mijn auto",
                explanation: "Don't use articles (de/het) with possessive pronouns"
            ),
            CommonMistake(
                incorrect: "onze huis",
                correct: "ons huis",
                explanation: "HUIS is a HET-word, so use ONS, not ONZE"
            ),
            CommonMistake(
                incorrect: "mijne boek",
                correct: "mijn boek",
                explanation: "MIJN never changes - don't add endings to it"
            )
        ],
        tips: [
            "Only ONS/ONZE changes - all others stay the same",
            "Practice the ONS/ONZE rule with common words: ons huis, onze auto",
            "JE is more common than JOUW in everyday speech",
            "Use UW with anyone you'd call 'meneer' or 'mevrouw'",
            "Remember: possessives replace articles, don't add to them"
        ],
        relatedRules: ["articles_a1", "adjectives_a2", "formal_informal_b1"]
    )
    
    lazy var demonstrativesA2 = DutchGrammarRule(
        id: "demonstratives_a2",
        title: "Demonstratives: This, That, These, Those (A2)",
        type: .adjectives,
        level: .a2,
        explanation: """
        Dutch demonstratives (this, that, these, those) change based on distance and the gender/number of the noun. They're more complex than English because they must agree with Dutch articles.
        
        Close to speaker (this/these):
        • DEZE + DE-words (singular and plural)
        • DIT + HET-words (singular only)
        
        Far from speaker (that/those):
        • DIE + all nouns (DE-words and HET-words, singular and plural)
        
        As pronouns (standing alone):
        • DIT/DAT for things
        • DEZE/DIE for people and things
        
        The key is knowing whether a noun uses DE or HET!
        """,
        keyPoints: [
            "DEZE = this/these (with DE-words)",
            "DIT = this (with HET-words only)",
            "DIE = that/those (with all words)",
            "Must know if noun is DE or HET word",
            "Plural always uses DEZE (close) or DIE (far)",
            "Can be used as pronouns (standing alone)"
        ],
        examples: [
            GrammarExample(
                dutch: "deze man, deze mannen",
                english: "this man, these men",
                breakdown: "DE-word uses DEZE for both singular and plural",
                audioHint: "deːzə mɑn, deːzə mɑnə(n)"
            ),
            GrammarExample(
                dutch: "dit huis, deze huizen",
                english: "this house, these houses",
                breakdown: "HET-word: DIT (singular), DEZE (plural - all plurals use DE)",
                audioHint: "dɪt hœys, deːzə hœyzə(n)"
            ),
            GrammarExample(
                dutch: "die auto, die auto's",
                english: "that car, those cars",
                breakdown: "DIE works with all nouns for 'that/those'",
                audioHint: "di ɔto, di ɔtos"
            ),
            GrammarExample(
                dutch: "Wat is dit? Dit is een boek.",
                english: "What is this? This is a book.",
                breakdown: "DIT as pronoun (standing alone)",
                audioHint: "vɑt ɪs dɪt? dɪt ɪs ən buk"
            ),
            GrammarExample(
                dutch: "Wie is dat? Dat is mijn vader.",
                english: "Who is that? That is my father.",
                breakdown: "DAT as pronoun for people at distance",
                audioHint: "vi ɪs dɑt? dɑt ɪs mɛin vaːdər"
            ),
            GrammarExample(
                dutch: "Deze vrouw is aardig, maar die man niet.",
                english: "This woman is nice, but that man isn't.",
                breakdown: "Contrasting DEZE (close) with DIE (far/other)",
                audioHint: "deːzə vrɑu ɪs aːrdəx, maːr di mɑn nit"
            ),
            GrammarExample(
                dutch: "dit kleine kind vs deze kleine kinderen",
                english: "this small child vs these small children",
                breakdown: "Adjectives still follow normal rules with demonstratives",
                audioHint: "dɪt klɛinə kɪnt vs deːzə klɛinə kɪndərə(n)"
            ),
            GrammarExample(
                dutch: "Ik wil die boeken, niet deze.",
                english: "I want those books, not these.",
                breakdown: "DEZE used as pronoun (these ones)",
                audioHint: "ik vɪl di bukə(n), nit deːzə"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Choose the correct form: '___ huis is mooi' (this house is beautiful)",
                options: ["Deze", "Dit", "Die", "Dat"],
                correctAnswer: 1,
                explanation: "HUIS is a HET-word, so use DIT for 'this': 'Dit huis is mooi'.",
                hint: "Is 'huis' a DE-word or HET-word?"
            ),
            GrammarExercise(
                question: "Choose the correct form: '___ boeken zijn duur' (these books are expensive)",
                options: ["Dit", "Deze", "Die", "Dat"],
                correctAnswer: 1,
                explanation: "BOEKEN is plural, so use DEZE for 'these': 'Deze boeken zijn duur'.",
                hint: "All plurals work like DE-words"
            ),
            GrammarExercise(
                question: "Choose the correct form: 'Ik hou niet van ___ muziek' (I don't like that music)",
                options: ["deze", "dit", "die", "dat"],
                correctAnswer: 2,
                explanation: "MUZIEK is a DE-word, and we want 'that' (far), so use DIE: 'die muziek'.",
                hint: "Is this close or far? Is muziek DE or HET?"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "dit auto",
                correct: "deze auto",
                explanation: "AUTO is a DE-word, so use DEZE, not DIT"
            ),
            CommonMistake(
                incorrect: "deze huis",
                correct: "dit huis",
                explanation: "HUIS is a HET-word, so use DIT for 'this'"
            ),
            CommonMistake(
                incorrect: "dat kinderen",
                correct: "die kinderen",
                explanation: "DAT is only for pronouns; with nouns use DIE for 'those'"
            )
        ],
        tips: [
            "Learn the pattern: DEZE/DIT (this), DIE (that/those)",
            "Remember: DIT only with HET-words, DEZE with everything else close by",
            "DIE is the easiest - it works for all 'that/those'",
            "Practice with common words: dit huis, deze auto, die man",
            "When in doubt about distance, DIE is often the safe choice"
        ],
        relatedRules: ["articles_a1", "adjectives_a2", "pluralization_a2"]
    )
    
    lazy var comparativeAdjectivesB1 = DutchGrammarRule(
        id: "comparative_adjectives_b1",
        title: "Comparative and Superlative Adjectives (B1)",
        type: .adjectives,
        level: .b1,
        explanation: """
        Dutch forms comparatives and superlatives similarly to English, but with different patterns and some irregular forms.
        
        Regular pattern:
        • Comparative: adjective + -ER (bigger, more beautiful)
        • Superlative: HET + adjective + -ST (biggest, most beautiful)
        
        With 'dan' (than): Hij is groter dan ik (He is taller than me)
        With 'als' (as...as): Zij is zo groot als hij (She is as tall as he is)
        
        Irregular forms:
        • GOED → BETER → BEST (good → better → best)
        • VEEL → MEER → MEEST (much → more → most)
        • WEINIG → MINDER → MINST (little → less → least)
        
        Spelling changes often occur when adding -ER and -ST.
        """,
        keyPoints: [
            "Comparative: add -ER (groter, mooier)",
            "Superlative: HET + adjective + -ST (het grootst, het mooist)",
            "Use DAN for 'than' comparisons",
            "Use ALS for 'as...as' comparisons",
            "Many spelling changes with -ER/-ST",
            "Several important irregular forms"
        ],
        examples: [
            GrammarExample(
                dutch: "groot → groter → het grootst",
                english: "big → bigger → the biggest",
                breakdown: "Regular pattern: add -ER and -ST",
                audioHint: "ɣrot → ɣrotər → ət ɣrotst"
            ),
            GrammarExample(
                dutch: "Hij is groter dan zijn broer.",
                english: "He is taller than his brother.",
                breakdown: "Comparative with DAN (than)",
                audioHint: "hɛi ɪs ɣrotər dɑn zɛin brur"
            ),
            GrammarExample(
                dutch: "Dit is het mooiste huis.",
                english: "This is the most beautiful house.",
                breakdown: "Superlative: HET + adjective + -ST + noun",
                audioHint: "dɪt ɪs ət moistə hœys"
            ),
            GrammarExample(
                dutch: "Zij is zo slim als haar zus.",
                english: "She is as smart as her sister.",
                breakdown: "Equal comparison: ZO + adjective + ALS",
                audioHint: "zɛi ɪs zo slɪm ɑls haːr zɵs"
            ),
            GrammarExample(
                dutch: "goed → beter → het best",
                english: "good → better → the best",
                breakdown: "Irregular: completely different forms",
                audioHint: "ɣut → beːtər → ət bɛst"
            ),
            GrammarExample(
                dutch: "veel → meer → het meest",
                english: "much/many → more → the most",
                breakdown: "Irregular: VEEL changes to MEER",
                audioHint: "veːl → meːr → ət meːst"
            ),
            GrammarExample(
                dutch: "mooi → mooier → het mooist",
                english: "beautiful → more beautiful → most beautiful",
                breakdown: "Spelling: double vowel becomes single + -ER/-ST",
                audioHint: "moːi → moiər → ət moist"
            ),
            GrammarExample(
                dutch: "Ik heb minder geld dan jij.",
                english: "I have less money than you.",
                breakdown: "MINDER (less) - irregular comparative of WEINIG",
                audioHint: "ik hɛp mɪndər ɣɛlt dɑn jɛi"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "What is the comparative of 'klein' (small)?",
                options: ["kleiner", "kleinere", "kleinst", "het kleinst"],
                correctAnswer: 0,
                explanation: "Comparative adds -ER: klein → kleiner (smaller).",
                hint: "Comparatives end in -ER"
            ),
            GrammarExercise(
                question: "Complete: 'Dit boek is ___ interessant ___ dat boek' (more interesting than)",
                options: ["meer... dan", "meer... als", "interessanter... dan", "interessanter... als"],
                correctAnswer: 2,
                explanation: "Long adjectives can add -ER: interessant → interessanter dan (more interesting than).",
                hint: "Use DAN for 'than' comparisons"
            ),
            GrammarExercise(
                question: "What is the superlative of 'goed' (good)?",
                options: ["het goedst", "het beste", "het best", "het beter"],
                correctAnswer: 2,
                explanation: "GOED is irregular: het best (the best). Note: no -E ending when used predicatively.",
                hint: "GOED has an irregular superlative"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "meer groot dan",
                correct: "groter dan",
                explanation: "Don't use MEER with short adjectives - add -ER directly"
            ),
            CommonMistake(
                incorrect: "zo groot dan",
                correct: "zo groot als",
                explanation: "Use ALS with 'zo...als' (as...as), DAN with comparatives"
            ),
            CommonMistake(
                incorrect: "het beste huis (attributive)",
                correct: "het beste huis",
                explanation: "Actually this is correct - superlatives before nouns do get -E"
            )
        ],
        tips: [
            "Learn the big three irregulars: goed→beter→best, veel→meer→meest, weinig→minder→minst",
            "DAN = than, ALS = as (in comparisons)",
            "Double vowels often become single: mooi→mooier, groot→groter",
            "Practice common comparisons: groter dan, zo groot als",
            "Superlatives often need HET, even when English doesn't use 'the'"
        ],
        relatedRules: ["adjectives_a2", "spelling_patterns_b1", "word_order_complex_b1"]
    )
    
    lazy var verbsWithFixedPrepositionsB1 = DutchGrammarRule(
        id: "verbs_fixed_prepositions_b1",
        title: "Werkwoorden met Vaste Voorzetsels (B1)",
        type: .prepositions,
        level: .b1,
        explanation: """
        Many Dutch verbs have a fixed preposition that always goes with them. This preposition cannot be omitted or replaced with another preposition. These combinations must be memorized because they are often different from English.
        
        Important patterns:
        • Verb + fixed preposition + object: "Ik denk aan jou" (I think about you)
        • The preposition is fixed and cannot be changed
        • Often different from English: "denken aan" ≠ "think about"
        • In questions, the preposition often moves to the front: "Waar denk je aan?" (What are you thinking about?)
        
        These verb-preposition combinations are extremely common in daily Dutch conversations and are essential for fluent Dutch.
        
        Common patterns by preposition:
        • AAN: denken aan, ergeren aan, wennen aan, herinneren aan
        • VAN: houden van, dromen van, genieten van, schrikken van
        • OP: wachten op, letten op, rekenen op, vertrouwen op
        • VOOR: zorgen voor, kiezen voor, bedanken voor, bang zijn voor
        • NAAR: luisteren naar, kijken naar, verlangen naar, informeren naar
        • OVER: praten over, discussiëren over, nadenken over, klagen over
        • IN: geïnteresseerd zijn in, goed zijn in, geloven in, slagen in
        • MET: beginnen met, stoppen met, trouwen met, kennismaken met
        """,
        keyPoints: [
            "Fixed prepositions cannot be omitted or replaced",
            "Combinations are often different from English",
            "Must be memorized - there's no logical rule",
            "Preposition stays with the verb, even in questions",
            "Essential for natural-sounding Dutch",
            "Extremely common in daily conversations"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik denk aan mijn familie.",
                english: "I think about my family.",
                breakdown: "denken + AAN (fixed preposition) - not 'over' like English",
                audioHint: "ik dɛŋk aːn mɛin faːmili"
            )
        ],
                        exercises: [
            // Category 1: Thinking and Emotions (denken, voelen)
            GrammarExercise(
                question: "Complete: 'Ik denk ___ mijn vakantie' (I think about my vacation)",
                options: ["over", "aan", "van", "voor"],
                correctAnswer: 1,
                explanation: "Dutch uses 'denken AAN' (think of/about). Unlike English 'think about', Dutch connects thoughts with 'aan'.",
                hint: "This verb uses a different preposition than English"
            ),
            GrammarExercise(
                question: "Complete: 'Hij houdt ___ voetbal' (He loves football)",
                options: ["aan", "van", "voor", "met"],
                correctAnswer: 1,
                explanation: "'Houden VAN' means love/like. 'Van' shows the source of your feelings - you get pleasure FROM it.",
                hint: "This preposition shows affection"
            ),
            GrammarExercise(
                question: "Complete: 'Zij is bang ___ honden' (She is afraid of dogs)",
                options: ["voor", "van", "aan", "over"],
                correctAnswer: 0,
                explanation: "'Bang VOOR' means afraid OF something. 'Voor' shows what threatens you or causes fear.",
                hint: "Think about what you use for danger or threat"
            ),
            
            // Category 2: Communication and Senses (luisteren, kijken, praten)
            GrammarExercise(
                question: "Complete: 'Wij luisteren ___ muziek' (We listen to music)",
                options: ["naar", "aan", "voor", "bij"],
                correctAnswer: 0,
                explanation: "'Luisteren NAAR' means listen TO. 'Naar' shows direction - your attention goes toward the sound.",
                hint: "This preposition shows direction"
            ),
            GrammarExercise(
                question: "Complete: 'Hij kijkt ___ televisie' (He watches television)",
                options: ["naar", "aan", "op", "voor"],
                correctAnswer: 0,
                explanation: "'Kijken NAAR' means look/watch AT. 'Naar' shows direction - your eyes go TOWARD what you're watching.",
                hint: "Think about directing your eyes"
            ),
            GrammarExercise(
                question: "Complete: 'Zij praat ___ politiek' (She talks about politics)",
                options: ["over", "aan", "van", "met"],
                correctAnswer: 0,
                explanation: "'Praten OVER' means talk ABOUT a topic. 'Over' shows the subject spans OVER your conversation.",
                hint: "Think about discussing a subject"
            ),
            
            // Category 3: Actions and Activities (wachten, zorgen, beginnen)
            GrammarExercise(
                question: "Complete: 'Ik wacht ___ de bus' (I wait for the bus)",
                options: ["op", "voor", "aan", "naar"],
                correctAnswer: 0,
                explanation: "'Wachten OP' means wait FOR. 'Op' shows expectation - you're waiting ON something to happen.",
                hint: "Think about expecting something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij zorgt ___ zijn kinderen' (He takes care of his children)",
                options: ["voor", "van", "aan", "over"],
                correctAnswer: 0,
                explanation: "'Zorgen VOOR' means care FOR. 'Voor' shows benefit - you do things FOR someone's wellbeing.",
                hint: "Think about providing care"
            ),
            GrammarExercise(
                question: "Complete: 'Wij beginnen ___ de les' (We start with the lesson)",
                options: ["met", "aan", "van", "op"],
                correctAnswer: 0,
                explanation: "'Beginnen MET' means start WITH. 'Met' shows accompaniment - you start together WITH something.",
                hint: "Think about starting together with something"
            ),
            
            // Category 4: Question Formation with Prepositions
            GrammarExercise(
                question: "How do you ask 'What are you thinking about?' in Dutch?",
                options: ["Wat denk je over?", "Waar denk je aan?", "Waarover denk je?", "Waarvoor denk je?"],
                correctAnswer: 1,
                explanation: "'Waar...aan' is used for 'denken aan'. The preposition 'aan' splits: 'Waar denk je aan?'",
                hint: "The preposition splits in questions"
            ),
            
            // Category 5: Multiple Choice Context
            GrammarExercise(
                question: "Which sentence is correct?",
                options: [
                    "Ik ben geïnteresseerd voor fotografie",
                    "Ik ben geïnteresseerd in fotografie", 
                    "Ik ben geïnteresseerd aan fotografie",
                    "Ik ben geïnteresseerd van fotografie"
                ],
                correctAnswer: 1,
                explanation: "'Geïnteresseerd IN' means interested IN. Same as English - your interest goes INTO the subject.",
                hint: "Same preposition as in English"
            ),
            
            // Category 6: Common Mistakes
            GrammarExercise(
                question: "Choose the correct preposition: 'Ik ben trots ___ mijn zoon'",
                options: ["van", "op", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Trots OP' means proud OF. 'Op' shows the target of your pride - your feelings rest ON that person.",
                hint: "Think about feeling proud"
            ),
            
            // NEW: Translation Exercises
            GrammarExercise(
                question: "How do you say 'I'm thinking about my family' in Dutch?",
                options: ["Ik denk aan mijn familie", "Ik denk over mijn familie", "Ik denk van mijn familie", "Ik denk voor mijn familie"],
                correctAnswer: 0,
                explanation: "Ik denk aan mijn familie - 'denken aan' means think about/of",
                hint: "Remember: denken uses 'aan', not 'over' like English",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'She is waiting for the train' in Dutch?",
                options: ["Zij wacht op de trein", "Zij wacht voor de trein", "Zij wacht aan de trein", "Zij wacht naar de trein"],
                correctAnswer: 0,
                explanation: "Zij wacht op de trein - 'wachten op' means wait for",
                hint: "Remember: wachten uses 'op', not 'voor'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'We are talking about the weather' in Dutch?",
                options: ["Wij praten over het weer", "Wij praten aan het weer", "Wij praten van het weer", "Wij praten voor het weer"],
                correctAnswer: 0,
                explanation: "Wij praten over het weer - 'praten over' means talk about",
                hint: "Remember: praten uses 'over' like English 'about'",
                exerciseType: .translation
            ),
            
            // NEW: Fill-in-the-Blank Exercises
            GrammarExercise(
                question: "Complete: 'Ik ben bang ___ spinnen' (I'm afraid of spiders)",
                options: ["voor", "van", "aan", "over"],
                correctAnswer: 0,
                explanation: "Ik ben bang voor spinnen - 'bang voor' means afraid of",
                hint: "Think about what causes fear",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij luistert ___ de radio' (He listens to the radio)",
                options: ["naar", "aan", "voor", "op"],
                correctAnswer: 0,
                explanation: "Hij luistert naar de radio - 'luisteren naar' means listen to",
                hint: "Think about directing attention",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij zorgt ___ haar moeder' (She takes care of her mother)",
                options: ["voor", "van", "aan", "over"],
                correctAnswer: 0,
                explanation: "Zij zorgt voor haar moeder - 'zorgen voor' means take care of",
                hint: "Think about providing care",
                exerciseType: .fillInTheBlank
            ),
            
            // NEW: True/False Exercises
            GrammarExercise(
                question: "True or False: 'Ik denk over jou' is correct Dutch for 'I'm thinking about you'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik denk aan jou'. Dutch uses 'denken aan', not 'denken over'.",
                hint: "Remember the fixed preposition for denken",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Hij wacht voor de bus' is correct Dutch for 'He waits for the bus'",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Hij wacht op de bus'. Dutch uses 'wachten op', not 'wachten voor'.",
                hint: "Remember the fixed preposition for wachten",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Zij kijkt naar de film' is correct Dutch for 'She watches the film'",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Kijken naar' is correct Dutch for 'look at/watch'.",
                hint: "This one follows the expected pattern",
                exerciseType: .trueFalse
            ),
            
            // NEW: Context-Based Questions
            GrammarExercise(
                question: "In a restaurant, how do you say 'I'm interested in the menu'?",
                options: ["Ik ben geïnteresseerd voor het menu", "Ik ben geïnteresseerd in het menu", "Ik ben geïnteresseerd aan het menu", "Ik ben geïnteresseerd van het menu"],
                correctAnswer: 1,
                explanation: "Ik ben geïnteresseerd in het menu - 'geïnteresseerd in' means interested in",
                hint: "Think about the fixed preposition for 'geïnteresseerd'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "When asking about someone's health, how do you say 'How are you feeling?'",
                options: ["Hoe voel je je?", "Hoe voel je aan je?", "Hoe voel je van je?", "Hoe voel je voor je?"],
                correctAnswer: 0,
                explanation: "Hoe voel je je? - 'zich voelen' doesn't need a preposition in this context",
                hint: "This is a reflexive verb construction",
                exerciseType: .translation
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik denk over jou",
                correct: "Ik denk aan jou",
                explanation: "Dutch verbs have their own fixed prepositions. 'Denken' uses 'aan', not 'over' like English."
            ),
            CommonMistake(
                incorrect: "Hij luistert aan muziek",
                correct: "Hij luistert naar muziek",
                explanation: "'Luisteren' always uses 'naar'. Don't confuse with 'horen aan' (recognize by sound)."
            ),
            CommonMistake(
                incorrect: "Ik ben geïnteresseerd voor kunst",
                correct: "Ik ben geïnteresseerd in kunst",
                explanation: "'Geïnteresseerd' uses 'in', not 'voor'. 'Voor' is used with 'zorgen voor' or 'kiezen voor'."
            ),
            CommonMistake(
                incorrect: "Wat denk je over? (question)",
                correct: "Waar denk je aan?",
                explanation: "In questions, keep the fixed preposition. 'Denken aan' becomes 'Waar denk je aan?'."
            ),
            CommonMistake(
                incorrect: "Hij wacht voor de trein",
                correct: "Hij wacht op de trein",
                explanation: "'Wachten' uses 'op' for what you expect. 'Voor' is used for location: 'Hij staat voor het station'."
            ),
            CommonMistake(
                incorrect: "Ik hou aan muziek",
                correct: "Ik hou van muziek",
                explanation: "'Houden van' means 'to love/like'. Don't confuse with 'houden aan' (stick to rules)."
            )
        ],
        tips: [
            "Always learn verbs with their fixed preposition: 'denken aan', 'houden van'",
            "Make sentences with these combinations to remember them",
            "Note: Dutch prepositions are often different from English",
            "In questions: combine question words with prepositions (waar + van = waarvan)",
            "Practice with daily situations: 'Waar ben je bang voor?', 'Waar denk je aan?'",
            "Listen to Dutch conversations - these combinations are extremely common"
        ],
        relatedRules: ["prepositions_a2", "reflexive_verbs_b1", "question_formation_a2", "word_order_complex_b1"]
    )
    
    lazy var infinitiveConstructionsB1 = DutchGrammarRule(
        id: "infinitive_constructions_b1",
        title: "Infinitiefconstructies met 'te' en 'om...te' (B1)",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        Dutch uses infinitive constructions with "te" and "om...te" to express purpose, intention, and necessity. These constructions are essential for fluent Dutch and appear constantly in everyday conversation.
        
        TE + INFINITIVE:
        Used after certain verbs, adjectives, and expressions to connect actions:
        • After modal-like verbs: proberen te, vergeten te, beloven te
        • After adjectives: moeilijk te, makkelijk te, belangrijk te
        • After expressions: het is tijd om te, ik heb zin om te
        
        OM + TE + INFINITIVE:
        Used to express purpose (in order to), reason, or goal:
        • Purpose: "Ik ga naar de winkel om boodschappen te doen" (I go to the store in order to do shopping)
        • After certain verbs: proberen om te, vergeten om te, besluiten om te
        • After adjectives expressing difficulty/ease: te moeilijk om te, te duur om te
        
        KEY DIFFERENCES:
        • TE alone: direct connection between verbs/adjectives
        • OM...TE: expresses purpose, reason, or goal
        • Some verbs can use both, sometimes with slightly different meanings
        
        WORD ORDER:
        The infinitive with "te" always goes to the end of the sentence or clause.
        """,
        keyPoints: [
            "TE connects actions directly after certain verbs and adjectives",
            "OM...TE expresses purpose, reason, or goal ('in order to')",
            "Infinitive with TE always goes to the end",
            "Some verbs require TE, others require OM...TE, some allow both",
            "Essential for expressing complex ideas and intentions",
            "Very common in daily Dutch conversation"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik probeer Nederlands te leren.",
                english: "I try to learn Dutch.",
                breakdown: "proberen + te + infinitive (direct connection)",
                audioHint: "ik probeːr neːdərlɑnts tə leːrə(n)"
            )
        ],
                        exercises: [
            // Category 1: Purpose Expressions (om...te)
            GrammarExercise(
                question: "Complete: 'Ik ga naar de winkel ___ boodschappen ___ doen' (I go to the store to do shopping)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Om...te' expresses purpose - you go to the store IN ORDER TO do shopping. This shows the goal of your action.",
                hint: "This expresses purpose - why you're going"
            ),
            GrammarExercise(
                question: "Complete: 'Hij stopt met roken ___ gezonder ___ worden' (He stops smoking to become healthier)",
                options: ["om, te", "te, te", "om, om", "te, om"],
                correctAnswer: 0,
                explanation: "'Om...te' expresses the purpose or goal - he stops smoking IN ORDER TO become healthier.",
                hint: "This shows the purpose or goal of stopping"
            ),
            
            // Category 2: Direct Connections (te only)
            GrammarExercise(
                question: "Complete: 'Ik vergeet altijd mijn sleutels ___ meenemen' (I always forget to take my keys)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Vergeten' uses 'te' directly: 'vergeten te doen'. This is a direct connection between the verbs.",
                hint: "Vergeten connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Het boek is te duur ___ kopen' (The book is too expensive to buy)",
                options: ["te", "om te", "om", "voor te"],
                correctAnswer: 1,
                explanation: "After 'te + adjective', use 'om te': 'te duur om te kopen'. This shows something is TOO [adjective] TO do.",
                hint: "After 'te + adjective', use om te"
            ),
            GrammarExercise(
                question: "Complete: 'Het is belangrijk ___ sporten' (It's important to exercise)",
                options: ["om te", "te", "om", "voor te"],
                correctAnswer: 0,
                explanation: "After 'belangrijk' (important), use 'om te': 'belangrijk om te sporten'. This shows importance OF doing something.",
                hint: "After adjectives expressing importance, use om te"
            ),
            
            // Category 4: Time and Planning Expressions
            GrammarExercise(
                question: "Complete: 'Ik heb geen tijd ___ koken' (I don't have time to cook)",
                options: ["om te", "te", "voor te", "aan te"],
                correctAnswer: 0,
                explanation: "'Tijd hebben om te' - having time FOR doing something. 'Om te' shows the purpose of the time.",
                hint: "Think about having time FOR doing something"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ben van plan ___ verhuizen' (I plan to move)",
                options: ["om te", "te", "om", "naar te"],
                correctAnswer: 0,
                explanation: "'Van plan zijn om te' - planning TO do something. This expression always uses 'om te'.",
                hint: "Van plan zijn uses om te"
            ),
            
            // Category 5: Mixed Patterns (verbs that can use both)
            GrammarExercise(
                question: "Complete: 'Ik probeer ___ vroeg ___ zijn' (I try to be early)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Proberen' can use both, but 'om te' is more common: 'proberen om te zijn'. This shows effort TOWARD a goal.",
                hint: "Proberen often uses om te for efforts toward goals"
            ),
            
            // NEW: Translation Exercises
            GrammarExercise(
                question: "How do you say 'I want to learn Dutch' in Dutch?",
                options: ["Ik wil om Nederlands te leren", "Ik wil Nederlands te leren", "Ik wil leren Nederlands", "Ik wil Nederlands leren"],
                correctAnswer: 3,
                explanation: "Ik wil Nederlands leren - 'willen' is a modal verb, so no 'te' needed",
                hint: "Remember: modal verbs don't use 'te'",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'It's easy to understand' in Dutch?",
                options: ["Het is makkelijk te begrijpen", "Het is makkelijk om te begrijpen", "Het is makkelijk begrijpen", "Het is makkelijk voor te begrijpen"],
                correctAnswer: 1,
                explanation: "Het is makkelijk om te begrijpen - after adjectives, use 'om te'",
                hint: "Think about the pattern after adjectives",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'I forgot to call you' in Dutch?",
                options: ["Ik vergat om je te bellen", "Ik vergat je te bellen", "Ik vergat bellen je", "Ik vergat je bellen"],
                correctAnswer: 0,
                explanation: "Ik vergat om je te bellen - 'vergeten' uses 'te' directly",
                hint: "Remember: vergeten connects directly with te",
                exerciseType: .translation
            ),
            
            // NEW: Fill-in-the-Blank Exercises
            GrammarExercise(
                question: "Complete: 'Ik heb geen zin ___ werken' (I don't feel like working)",
                options: ["om te", "te", "om", "voor te"],
                correctAnswer: 0,
                explanation: "Ik heb geen zin om te werken - 'zin hebben om te' means feel like doing",
                hint: "Think about expressing desire or willingness",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Het is te laat ___ naar huis ___ gaan' (It's too late to go home)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "Het is te laat om naar huis te gaan - after 'te + adjective', use 'om te'",
                hint: "Remember the 'te + adjective + om te' pattern",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Zij besloot ___ een nieuwe baan ___ zoeken' (She decided to look for a new job)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "Zij besloot om een nieuwe baan te zoeken - 'besluiten' uses 'om te'",
                hint: "Think about decision-making verbs",
                exerciseType: .fillInTheBlank
            ),
            
            // NEW: True/False Exercises
            GrammarExercise(
                question: "True or False: 'Ik probeer te om Nederlands leren' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik probeer om Nederlands te leren' or 'Ik probeer Nederlands te leren'. Don't combine 'te' and 'om te'.",
                hint: "Don't mix the two patterns",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Het is moeilijk te begrijpen' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Het is moeilijk om te begrijpen'. After adjectives, use 'om te'.",
                hint: "Remember the adjective pattern",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Ik beloof om te komen' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Beloven' can use both 'te' and 'om te', though 'te' is more common.",
                hint: "Beloven is flexible with its pattern",
                exerciseType: .trueFalse
            ),
            
            // NEW: Context-Based Questions
            GrammarExercise(
                question: "When making plans, how do you say 'I'm planning to visit Amsterdam'?",
                options: ["Ik ben van plan Amsterdam te bezoeken", "Ik ben van plan om Amsterdam te bezoeken", "Ik ben van plan bezoeken Amsterdam", "Ik ben van plan te bezoeken Amsterdam"],
                correctAnswer: 1,
                explanation: "Ik ben van plan om Amsterdam te bezoeken - 'van plan zijn' always uses 'om te'",
                hint: "Think about the fixed expression for planning",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "When expressing difficulty, how do you say 'It's hard to explain'?",
                options: ["Het is moeilijk te uitleggen", "Het is moeilijk om te uitleggen", "Het is moeilijk uitleggen", "Het is moeilijk voor te uitleggen"],
                correctAnswer: 1,
                explanation: "Het is moeilijk om te uitleggen - after 'moeilijk', use 'om te'",
                hint: "Remember the adjective pattern",
                exerciseType: .translation
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik ga winkel te kopen brood",
                correct: "Ik ga naar de winkel om brood te kopen",
                explanation: "For purpose (why you go), use 'om...te'. Also need 'naar de' for direction."
            ),
            CommonMistake(
                incorrect: "Het is moeilijk te Nederlands spreken",
                correct: "Het is moeilijk om Nederlands te spreken",
                explanation: "After adjectives expressing difficulty/ease, use 'om...te', not just 'te'."
            ),
            CommonMistake(
                incorrect: "Ik vergeet om mijn huiswerk te maken",
                correct: "Ik vergeet mijn huiswerk te maken",
                explanation: "'Vergeten' uses 'te' directly, not 'om te'. Only some verbs use 'om te'."
            ),
            CommonMistake(
                incorrect: "Hij probeert te om Nederlands leren",
                correct: "Hij probeert om Nederlands te leren",
                explanation: "Don't combine 'te' and 'om te'. Choose one pattern and stick to it."
            ),
            CommonMistake(
                incorrect: "Ik heb tijd te koken",
                correct: "Ik heb tijd om te koken",
                explanation: "'Tijd hebben' uses 'om te' - you have time FOR doing something."
            ),
            CommonMistake(
                incorrect: "Het is te moeilijk te begrijpen",
                correct: "Het is te moeilijk om te begrijpen",
                explanation: "After 'te + adjective', always use 'om te': too [adjective] TO do."
            )
        ],
        tips: [
            "Learn which verbs use 'te' vs 'om te' - make lists and practice",
            "Remember: 'om te' often expresses purpose (in order to)",
            "After adjectives, usually use 'om te': moeilijk om te, belangrijk om te",
            "Practice the 'te + adjective + om te' pattern: te duur om te kopen",
            "Listen for these patterns in Dutch conversations - they're everywhere!"
        ],
        relatedRules: ["modal_verbs_b1", "word_order_complex_b1", "separable_verbs_b1"]
    )
    
    lazy var auxiliaryVerbsB1 = DutchGrammarRule(
        id: "auxiliary_verbs_b1",
        title: "Hulpwerkwoorden: 'hebben' of 'zijn' in Voltooide Tijden (B1)",
        type: .verbConjugation,
        level: .b1,
        explanation: """
        In Dutch perfect tenses (present perfect, past perfect), you must choose between "hebben" and "zijn" as auxiliary verbs. This choice depends on the type of verb and the action it describes.
        
        USE ZIJN WITH:
        1. MOVEMENT VERBS: gaan, komen, lopen, rijden, vliegen, etc.
           • "Ik ben naar huis gegaan" (I have gone home)
        
        2. CHANGE OF STATE: worden, sterven, groeien, vallen, etc.
           • "Hij is groot geworden" (He has become big)
        
        3. SPECIFIC VERBS: zijn, blijven, gebeuren, lukken, mislukken
           • "Dat is gisteren gebeurd" (That happened yesterday)
        
        USE HEBBEN WITH:
        1. MOST OTHER VERBS: werken, eten, slapen, lezen, kopen, etc.
           • "Ik heb hard gewerkt" (I have worked hard)
        
        2. TRANSITIVE VERBS (with direct object): maken, kopen, zien, horen
           • "Zij heeft een boek gekocht" (She has bought a book)
        
        3. VERBS OF THINKING/FEELING: denken, voelen, houden van, etc.
           • "Wij hebben erover gedacht" (We have thought about it)
        
        MEMORY TRICKS:
        • ZIJN = movement + change + being
        • HEBBEN = everything else (majority of verbs)
        • When in doubt, try HEBBEN first (it's more common)
        
        IMPORTANT: Some verbs can use both, depending on meaning:
        • "Ik heb gereden" (I have driven - general activity)
        • "Ik ben naar werk gereden" (I have driven to work - movement to destination)
        """,
        keyPoints: [
            "ZIJN: movement, change of state, and specific verbs (zijn, blijven, gebeuren)",
            "HEBBEN: most other verbs, transitive verbs, thinking/feeling verbs",
            "Movement TO a destination usually uses ZIJN",
            "General activities without destination usually use HEBBEN",
            "Some verbs can use both depending on context",
            "When uncertain, HEBBEN is often the safer choice"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik ben naar Amsterdam gereden.",
                english: "I have driven to Amsterdam.",
                breakdown: "Movement to destination → ZIJN + past participle",
                audioHint: "ik bɛn naːr ɑmstərdɑm ɣərɛːdə(n)"
            )
        ],
                exercises: [
            // Category 1: Movement Verbs (ZIJN)
            GrammarExercise(
                question: "Complete: 'Ik ___ gisteren naar de winkel gegaan' (I went to the store yesterday)",
                options: ["heb", "ben", "had", "was"],
                correctAnswer: 1,
                explanation: "'Gaan' (go) is a movement verb, so use ZIJN: 'Ik ben gegaan'. Movement verbs always use ZIJN.",
                hint: "Gaan is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'De trein ___ om 3 uur aangekomen' (The train arrived at 3 o'clock)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Aankomen' (arrive) is movement/arrival, so use ZIJN: 'De trein is aangekomen'.",
                hint: "Arriving is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ naar de bakker gelopen' (He walked to the bakery)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Lopen' (walk) to destination uses ZIJN: 'Hij is naar de bakker gelopen'.",
                hint: "Walking to destination - use ZIJN"
            ),
            
            // Category 2: Change of State Verbs (ZIJN)
            GrammarExercise(
                question: "Complete: 'Het kind ___ snel gegroeid' (The child grew quickly)",
                options: ["heeft", "is", "had", "was"],
                correctAnswer: 1,
                explanation: "'Groeien' (grow) shows change of state, so use ZIJN: 'Het kind is gegroeid'.",
                hint: "Growing is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ erg ziek geworden' (He became very sick)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Worden' (become) shows change of state, so use ZIJN: 'Hij is geworden'.",
                hint: "Becoming is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Mijn oma ___ vorig jaar gestorven' (My grandmother died last year)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Sterven' (die) shows change of state, so use ZIJN: 'Mijn oma is gestorven'.",
                hint: "Dying is change of state - use ZIJN"
            ),
            
            // Category 3: Specific ZIJN Verbs
            GrammarExercise(
                question: "Complete: 'Wij ___ lang in de tuin gebleven' (We stayed long in the garden)",
                options: ["hebben", "zijn", "had", "was"],
                correctAnswer: 1,
                explanation: "'Blijven' (stay) is one of the specific verbs that uses ZIJN: 'Wij zijn gebleven'.",
                hint: "Blijven is a specific ZIJN verb"
            ),
            GrammarExercise(
                question: "Complete: 'Het ongeluk ___ gisteren gebeurd' (The accident happened yesterday)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Gebeuren' (happen) is one of the specific verbs that uses ZIJN: 'Het is gebeurd'.",
                hint: "Gebeuren is a specific ZIJN verb"
            ),
            
            // Category 4: Transitive Verbs (HEBBEN)
            GrammarExercise(
                question: "Complete: 'Zij ___ een mooie jurk gekocht' (She bought a beautiful dress)",
                options: ["is", "ben", "heeft", "had"],
                correctAnswer: 2,
                explanation: "'Kopen' (buy) is a transitive verb with direct object, so use HEBBEN: 'Zij heeft gekocht'.",
                hint: "Kopen is transitive - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ een interessant boek gelezen' (I read an interesting book)",
                options: ["ben", "is", "heb", "had"],
                correctAnswer: 2,
                explanation: "'Lezen' (read) is a general activity with object, so use HEBBEN: 'Ik heb gelezen'.",
                hint: "Reading is general activity - use HEBBEN"
            ),
            
            // Category 5: General Activity Verbs (HEBBEN)
            GrammarExercise(
                question: "Complete: 'Wij ___ de hele dag gewerkt' (We worked all day)",
                options: ["zijn", "ben", "hebben", "had"],
                correctAnswer: 2,
                explanation: "'Werken' (work) is a general activity verb, so use HEBBEN: 'Wij hebben gewerkt'.",
                hint: "Working is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ de hele nacht geslapen' (I slept all night)",
                options: ["ben", "is", "heb", "had"],
                correctAnswer: 2,
                explanation: "'Slapen' (sleep) is a general activity, so use HEBBEN: 'Ik heb geslapen'.",
                hint: "Sleeping is general activity - use HEBBEN"
            ),
            
            // NEW: Translation Exercises
            GrammarExercise(
                question: "How do you say 'I have gone to Amsterdam' in Dutch?",
                options: ["Ik heb naar Amsterdam gegaan", "Ik ben naar Amsterdam gegaan", "Ik had naar Amsterdam gegaan", "Ik was naar Amsterdam gegaan"],
                correctAnswer: 1,
                explanation: "Ik ben naar Amsterdam gegaan - 'gaan' is movement, so use ZIJN",
                hint: "Remember: movement verbs use ZIJN",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'She has bought a car' in Dutch?",
                options: ["Zij is een auto gekocht", "Zij heeft een auto gekocht", "Zij had een auto gekocht", "Zij was een auto gekocht"],
                correctAnswer: 1,
                explanation: "Zij heeft een auto gekocht - 'kopen' is transitive, so use HEBBEN",
                hint: "Remember: transitive verbs use HEBBEN",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The child has grown' in Dutch?",
                options: ["Het kind heeft gegroeid", "Het kind is gegroeid", "Het kind had gegroeid", "Het kind was gegroeid"],
                correctAnswer: 1,
                explanation: "Het kind is gegroeid - 'groeien' shows change of state, so use ZIJN",
                hint: "Remember: change of state uses ZIJN",
                exerciseType: .translation
            ),
            
            // NEW: Fill-in-the-Blank Exercises
            GrammarExercise(
                question: "Complete: 'De trein ___ om 9 uur vertrokken' (The train departed at 9 o'clock)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "De trein is om 9 uur vertrokken - 'vertrekken' is movement, so use ZIJN",
                hint: "Think about what type of action this is",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ de hele dag gestudeerd' (We studied all day)",
                options: ["zijn", "ben", "hebben", "had"],
                correctAnswer: 2,
                explanation: "Wij hebben de hele dag gestudeerd - 'studeren' is general activity, so use HEBBEN",
                hint: "Think about what type of activity this is",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ erg veranderd sinds vorig jaar' (He has changed a lot since last year)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "Hij is erg veranderd sinds vorig jaar - 'veranderen' shows change of state, so use ZIJN",
                hint: "Think about what type of change this is",
                exerciseType: .fillInTheBlank
            ),
            
            // NEW: True/False Exercises
            GrammarExercise(
                question: "True or False: 'Ik heb naar huis gegaan' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Ik ben naar huis gegaan'. 'Gaan' is movement, so use ZIJN, not HEBBEN.",
                hint: "Remember the movement verb rule",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Zij is een boek gekocht' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! It should be 'Zij heeft een boek gekocht'. 'Kopen' is transitive, so use HEBBEN, not ZIJN.",
                hint: "Remember the transitive verb rule",
                exerciseType: .trueFalse
            ),
            GrammarExercise(
                question: "True or False: 'Het kind is gegroeid' is correct Dutch",
                options: ["True", "False"],
                correctAnswer: 0,
                explanation: "True! 'Groeien' shows change of state, so ZIJN is correct.",
                hint: "This follows the change of state rule",
                exerciseType: .trueFalse
            ),
            
            // NEW: Context-Based Questions
            GrammarExercise(
                question: "When talking about travel, how do you say 'I have been to Paris'?",
                options: ["Ik heb in Parijs geweest", "Ik ben in Parijs geweest", "Ik had in Parijs geweest", "Ik was in Parijs geweest"],
                correctAnswer: 1,
                explanation: "Ik ben in Parijs geweest - 'zijn' (be) is a specific ZIJN verb",
                hint: "Think about the verb 'zijn' (to be)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "When talking about work, how do you say 'I have worked hard'?",
                options: ["Ik ben hard gewerkt", "Ik heb hard gewerkt", "Ik had hard gewerkt", "Ik was hard gewerkt"],
                correctAnswer: 1,
                explanation: "Ik heb hard gewerkt - 'werken' is general activity, so use HEBBEN",
                hint: "Think about what type of activity working is",
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
        title: "Fixed Word Combinations (B1)",
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
    
    // MARK: - All Grammar Rules Array
    
    lazy var allGrammarRules: [DutchGrammarRule] = [
        // A1 Level
        presentTenseA1,
        irregularVerbsA1,
        
        // A2 Level  
        pastTenseA2,
        adjectivesA2,
        negationA2,
        possessivesA2,
        demonstrativesA2,
        dutchInformalContractionsA2,
        
        // B1 Level
        verbsWithFixedPrepositionsB1,
        infinitiveConstructionsB1,
        auxiliaryVerbsB1,
        fixedWordCombinationsB1,
        tKofschipRuleB1,
        contractionsCliticsA2,
        wordClassificationSentenceAnalysisA2
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

