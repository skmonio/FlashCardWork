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

enum LanguageLevel: String, CaseIterable {
    case a1 = "A1"
    case a2 = "A2"
    case b1 = "B1"
}

// MARK: - Grammar Rule Structure

struct DutchGrammarRule {
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
        In het Nederlands vervoeging je werkwoorden door uitgangen toe te voegen aan de stam van het werkwoord. De stam krijg je door -en van de infinitief (hele werkwoord) af te halen.
        
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
                question: "Perfectum van 'maken': Ik ... een fout ...",
                options: ["heb/gemaakt", "ben/gemaakt", "heb/gemaakd", "ben/gemaakd"],
                correctAnswer: 0,
                explanation: "Maken gebruikt 'hebben' + gemaakt (k is hard → -t)",
                hint: "Maken is geen beweging, dus gebruik 'hebben'"
            ),
            GrammarExercise(
                question: "Perfectum van 'komen': Hij ... te laat ...",
                options: ["heeft/gekomen", "is/gekomen", "heeft/gekomt", "is/gekomt"],
                correctAnswer: 1,
                explanation: "Komen is beweging (zijn) + gekomen (onregelmatig)",
                hint: "Komen is beweging en onregelmatig"
            ),
            GrammarExercise(
                question: "Perfectum van 'spelen': Wij ... voetbal ...",
                options: ["hebben/gespeelt", "zijn/gespeelt", "hebben/gespeeld", "zijn/gespeeld"],
                correctAnswer: 2,
                explanation: "Spelen gebruikt 'hebben' + gespeeld (l is zacht → -d)",
                hint: "Is spelen beweging? Is l hard of zacht?"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik ben gewerkt",
                correct: "Ik heb gewerkt",
                explanation: "Werken is geen beweging of verandering, dus gebruik 'hebben'"
            ),
            CommonMistake(
                incorrect: "Hij heeft gegaan",
                correct: "Hij is gegaan",
                explanation: "Gaan is beweging, dus gebruik 'zijn'"
            ),
            CommonMistake(
                incorrect: "Zij heeft gemaakd",
                correct: "Zij heeft gemaakt",
                explanation: "K is hard ('t kofschip) dus -t, niet -d"
            )
        ],
        tips: [
            "Leer welke werkwoorden 'zijn' gebruiken: beweging en verandering",
            "Ezelsbruggetje: 'zijn' voor 'zijn, blijven, worden' en beweging",
            "Oefen onregelmatige voltooid deelwoorden apart",
            "Let op woordvolgorde: hulpwerkwoord + ... + voltooid deelwoord",
            "In bijzinnen komt het voltooid deelwoord voor het hulpwerkwoord"
        ],
        relatedRules: ["verb_past_a2", "verb_irregular_perfect_b1", "word_order_b1"]
    )
    
    // MARK: - Word Order Rules
    
    lazy var basicWordOrderA1 = DutchGrammarRule(
        id: "word_order_basic_a1",
        title: "Basis Woordvolgorde - Hoofdzinnen (A1)",
        type: .wordOrder,
        level: .a1,
        explanation: """
        Nederlandse hoofdzinnen (gewone zinnen) hebben een vaste woordvolgorde. De belangrijkste regel is dat het werkwoord altijd op de tweede plaats staat, niet op de eerste.
        
        Basis patroon: ONDERWERP + WERKWOORD + REST
        
        Voorbeelden:
        • Ik werk in Amsterdam.
        • Hij speelt voetbal.
        • Wij leren Nederlands.
        
        Als je met iets anders begint dan het onderwerp, komt het werkwoord nog steeds op plaats 2, en het onderwerp schuift naar plaats 3.
        """,
        keyPoints: [
            "Werkwoord staat altijd op plaats 2 in hoofdzinnen",
            "Onderwerp + werkwoord + rest van de zin",
            "Als je niet met onderwerp begint, schuift alles op",
            "Werkwoord blijft op plaats 2, onderwerp gaat naar plaats 3"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik woon in Utrecht.",
                english: "I live in Utrecht.",
                breakdown: "1: Ik (onderwerp) + 2: woon (werkwoord) + 3: in Utrecht",
                audioHint: "ik voːn ɪn ytrɛxt"
            ),
            GrammarExample(
                dutch: "Morgen ga ik naar school.",
                english: "Tomorrow I go to school.",
                breakdown: "1: Morgen + 2: ga (werkwoord) + 3: ik (onderwerp) + 4: naar school",
                audioHint: "mɔrɣə(n) ɣaː ik naːr sxoːl"
            ),
            GrammarExample(
                dutch: "Vandaag werkt hij thuis.",
                english: "Today he works at home.",
                breakdown: "1: Vandaag + 2: werkt (werkwoord) + 3: hij (onderwerp) + 4: thuis",
                audioHint: "vɑndaːx vɛrkt hɛi tœys"
            ),
            GrammarExample(
                dutch: "In de zomer zwemmen wij veel.",
                english: "In summer we swim a lot.",
                breakdown: "1: In de zomer + 2: zwemmen (werkwoord) + 3: wij (onderwerp) + 4: veel",
                audioHint: "ɪn də zoːmər zvɛmə(n) vɛi veːl"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Juiste woordvolgorde: 'school / naar / ik / ga'",
                options: ["School ga ik naar", "Ik ga naar school", "Ga ik naar school", "Naar school ga ik"],
                correctAnswer: 1,
                explanation: "Normale woordvolgorde: onderwerp (ik) + werkwoord (ga) + rest (naar school)",
                hint: "Begin met het onderwerp 'ik'"
            ),
            GrammarExercise(
                question: "Juiste woordvolgorde: 'morgen / zij / werkt'",
                options: ["Morgen zij werkt", "Zij morgen werkt", "Morgen werkt zij", "Werkt zij morgen"],
                correctAnswer: 2,
                explanation: "Als je met 'morgen' begint: morgen (1) + werkt (2) + zij (3)",
                hint: "Werkwoord moet op plaats 2, dus na 'morgen'"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Morgen ik ga naar school",
                correct: "Morgen ga ik naar school",
                explanation: "Werkwoord moet op plaats 2, dus 'ga' komt na 'morgen'"
            ),
            CommonMistake(
                incorrect: "Thuis hij werkt",
                correct: "Thuis werkt hij",
                explanation: "Als je met 'thuis' begint, komt werkwoord op plaats 2"
            )
        ],
        tips: [
            "Tel altijd: plaats 1, plaats 2 (werkwoord), plaats 3...",
            "Oefen met verschillende beginwoorden (vandaag, morgen, hier, etc.)",
            "Werkwoord op plaats 2 is de belangrijkste regel",
            "Luister naar Nederlandse zinnen en tel de posities mee"
        ],
        relatedRules: ["word_order_questions_a1", "word_order_time_a2", "word_order_complex_b1"]
    )
    
    lazy var questionWordOrderA2 = DutchGrammarRule(
        id: "word_order_questions_a2",
        title: "Woordvolgorde in Vragen (A2)",
        type: .wordOrder,
        level: .a2,
        explanation: """
        Er zijn twee soorten vragen in het Nederlands:
        
        1. JA/NEE vragen: Werkwoord op plaats 1
           • Ga jij naar school? (Ja/Nee)
           • Werk je morgen? (Ja/Nee)
        
        2. VRAAGWOORD vragen: Vraagwoord op plaats 1, werkwoord op plaats 2
           • Waar woon jij?
           • Wanneer ga je naar huis?
           • Wat doe je vandaag?
        
        In beide gevallen komt het onderwerp na het werkwoord.
        """,
        keyPoints: [
            "Ja/nee vragen: werkwoord eerst, dan onderwerp",
            "Vraagwoord vragen: vraagwoord + werkwoord + onderwerp",
            "Onderwerp komt altijd na het werkwoord in vragen",
            "Belangrijkste vraagwoorden: wat, waar, wanneer, wie, waarom, hoe"
        ],
        examples: [
            GrammarExample(
                dutch: "Spreek jij Nederlands?",
                english: "Do you speak Dutch?",
                breakdown: "Ja/nee vraag: spreek (werkwoord) + jij (onderwerp)",
                audioHint: "spreːk jɛi neːdərlɑnts"
            ),
            GrammarExample(
                dutch: "Waar woon je?",
                english: "Where do you live?",
                breakdown: "Vraagwoord vraag: waar + woon (werkwoord) + je (onderwerp)",
                audioHint: "vaːr voːn jə"
            ),
            GrammarExample(
                dutch: "Wat eet jij graag?",
                english: "What do you like to eat?",
                breakdown: "wat + eet (werkwoord) + jij (onderwerp) + graag",
                audioHint: "vɑt eːt jɛi ɣraːx"
            ),
            GrammarExample(
                dutch: "Wanneer kom je thuis?",
                english: "When do you come home?",
                breakdown: "wanneer + kom (werkwoord) + je (onderwerp) + thuis",
                audioHint: "vɑneːr kɔm jə tœys"
            ),
            GrammarExample(
                dutch: "Hoe gaat het met je?",
                english: "How are you doing?",
                breakdown: "hoe + gaat (werkwoord) + het (onderwerp) + met je",
                audioHint: "hu ɣaːt ət mɛt jə"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Maak een ja/nee vraag: 'jij / spreekt / Engels'",
                options: ["Jij spreekt Engels?", "Spreekt jij Engels?", "Engels spreekt jij?", "Spreek jij Engels?"],
                correctAnswer: 1,
                explanation: "Ja/nee vraag: werkwoord eerst, dan onderwerp. 'Spreekt' (niet 'spreek') omdat 'jij' in vragen formeel is",
                hint: "Begin met het werkwoord voor ja/nee vragen"
            ),
            GrammarExercise(
                question: "Maak een vraagwoord vraag: 'waar / jij / woont'",
                options: ["Waar jij woont?", "Woont waar jij?", "Waar woont jij?", "Jij woont waar?"],
                correctAnswer: 2,
                explanation: "Vraagwoord + werkwoord + onderwerp: waar + woont + jij",
                hint: "Vraagwoord eerst, dan werkwoord, dan onderwerp"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Waar jij woont?",
                correct: "Waar woon je?",
                explanation: "Na vraagwoord komt werkwoord, dan onderwerp"
            ),
            CommonMistake(
                incorrect: "Jij spreekt Nederlands?",
                correct: "Spreek jij Nederlands?",
                explanation: "Voor ja/nee vragen begin je met het werkwoord"
            ),
            CommonMistake(
                incorrect: "Wat jij doet?",
                correct: "Wat doe je?",
                explanation: "Na vraagwoord: werkwoord + onderwerp (doe + je)"
            )
        ],
        tips: [
            "Ja/nee vragen: draai werkwoord en onderwerp om",
            "Vraagwoord vragen: vraagwoord + werkwoord + onderwerp",
            "In informele vragen gebruik je vaak 'je' in plaats van 'jij'",
            "Oefen met alle vraagwoorden: wat, waar, wanneer, wie, waarom, hoe"
        ],
        relatedRules: ["word_order_basic_a1", "word_order_complex_b1", "verb_conjugation_questions_a2"]
    )
    
    lazy var complexWordOrderB1 = DutchGrammarRule(
        id: "word_order_complex_b1",
        title: "Complexe Woordvolgorde - Bijzinnen en Samengestelde Tijden (B1)",
        type: .wordOrder,
        level: .b1,
        explanation: """
        Op B1 niveau leer je complexere woordvolgorde regels:
        
        1. BIJZINNEN: Werkwoord komt op het einde
           • Ik denk dat hij morgen komt.
           • Zij zegt dat ze Nederlands leert.
        
        2. SAMENGESTELDE TIJDEN: Hulpwerkwoord op plaats 2, hoofdwerkwoord op het einde
           • Ik heb gisteren gewerkt.
           • Wij zijn naar Amsterdam gegaan.
        
        3. MODALE WERKWOORDEN: Modaal werkwoord op plaats 2, infinitief op het einde
           • Ik kan goed zwemmen.
           • Hij wil morgen komen.
        """,
        keyPoints: [
            "Bijzinnen: werkwoord komt helemaal achteraan",
            "Samengestelde tijden: hulpwerkwoord + ... + hoofdwerkwoord",
            "Modale werkwoorden: modaal werkwoord + ... + infinitief",
            "Voegwoorden die bijzinnen maken: dat, omdat, als, toen, etc.",
            "In bijzinnen geen inversie (werkwoord blijft achteraan)"
        ],
        examples: [
            GrammarExample(
                dutch: "Ik denk dat hij ziek is.",
                english: "I think that he is sick.",
                breakdown: "Hoofdzin: Ik denk + Bijzin: dat hij ziek is (werkwoord achteraan)",
                audioHint: "ik dɛŋk dɑt hɛi ziːk ɪs"
            ),
            GrammarExample(
                dutch: "Hij zegt dat hij morgen komt.",
                english: "He says that he comes tomorrow.",
                breakdown: "dat hij morgen komt (werkwoord 'komt' achteraan in bijzin)",
                audioHint: "hɛi zɛxt dɑt hɛi mɔrɣə(n) kɔmt"
            ),
            GrammarExample(
                dutch: "Ik heb gisteren hard gewerkt.",
                english: "I worked hard yesterday.",
                breakdown: "heb (hulpwerkwoord plaats 2) + gewerkt (hoofdwerkwoord achteraan)",
                audioHint: "ik hɛp ɣɪstərə(n) hɑrt ɣəvɛrkt"
            ),
            GrammarExample(
                dutch: "Zij kan goed Nederlands spreken.",
                english: "She can speak Dutch well.",
                breakdown: "kan (modaal plaats 2) + spreken (infinitief achteraan)",
                audioHint: "zɛi kɑn ɣut neːdərlɑnts spreːkə(n)"
            ),
            GrammarExample(
                dutch: "Omdat het regent, blijf ik thuis.",
                english: "Because it's raining, I stay home.",
                breakdown: "Bijzin eerst: omdat het regent (werkwoord achteraan) + hoofdzin",
                audioHint: "ɔmdɑt ət reːɣənt blɛif ik tœys"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Bijzin met 'dat': 'Ik weet ... hij morgen ... (komen)'",
                options: ["dat hij morgen komt", "dat komt hij morgen", "dat hij komt morgen", "hij dat morgen komt"],
                correctAnswer: 0,
                explanation: "In bijzinnen komt het werkwoord achteraan: dat hij morgen komt",
                hint: "Bijzinnen: werkwoord komt helemaal achteraan"
            ),
            GrammarExercise(
                question: "Perfectum woordvolgorde: 'Ik ... gisteren ... (hebben/werken)'",
                options: ["heb gisteren gewerkt", "heb gewerkt gisteren", "gewerkt heb gisteren", "gisteren heb gewerkt"],
                correctAnswer: 0,
                explanation: "Hulpwerkwoord op plaats 2, tijd in het midden, hoofdwerkwoord achteraan",
                hint: "Hulpwerkwoord + tijd + hoofdwerkwoord"
            ),
            GrammarExercise(
                question: "Modaal werkwoord: 'Hij ... morgen niet ... (kunnen/komen)'",
                options: ["kan morgen niet komen", "kan komen morgen niet", "morgen kan niet komen", "niet kan morgen komen"],
                correctAnswer: 0,
                explanation: "Modaal werkwoord + tijd + negatie + infinitief",
                hint: "Modaal werkwoord op plaats 2, infinitief achteraan"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "Ik denk dat komt hij morgen",
                correct: "Ik denk dat hij morgen komt",
                explanation: "In bijzinnen komt werkwoord achteraan, geen inversie"
            ),
            CommonMistake(
                incorrect: "Ik heb gewerkt gisteren",
                correct: "Ik heb gisteren gewerkt",
                explanation: "Tijd komt tussen hulpwerkwoord en hoofdwerkwoord"
            ),
            CommonMistake(
                incorrect: "Hij kan komen niet",
                correct: "Hij kan niet komen",
                explanation: "'Niet' komt voor de infinitief"
            )
        ],
        tips: [
            "Bijzinnen: onthoud 'werkwoord achteraan'",
            "Samengestelde tijden: hulpwerkwoord + midden + hoofdwerkwoord",
            "Modale werkwoorden: modaal + midden + infinitief",
            "Oefen met voegwoorden: dat, omdat, als, toen, terwijl",
            "Let op: geen inversie in bijzinnen!"
        ],
        relatedRules: ["word_order_basic_a1", "verb_perfect_b1", "modal_verbs_b1"]
    )
    
    // MARK: - All Grammar Rules Array
    
    lazy var allGrammarRules: [DutchGrammarRule] = [
        // A1 Level
        presentTenseA1,
        irregularVerbsA1,
        basicWordOrderA1,
        
        // A2 Level  
        pastTenseA2,
        questionWordOrderA2,
        
        // B1 Level
        perfectTenseB1,
        complexWordOrderB1
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