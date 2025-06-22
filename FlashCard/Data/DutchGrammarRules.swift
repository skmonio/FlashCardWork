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
    
    // MARK: - Additional A1 Level Rules
    
    lazy var dutchArticlesA1 = DutchGrammarRule(
        id: "articles_a1",
        title: "Dutch Articles: De and Het (A1)",
        type: .adjectives,
        level: .a1,
        explanation: """
        Dutch has two definite articles: "de" and "het" (both meaning "the" in English). Unlike English, you must memorize which article goes with each noun, as there are no reliable rules.
        
        • DE is used with about 2/3 of Dutch nouns
        • HET is used with about 1/3 of Dutch nouns
        • ALL plural nouns use DE
        
        The indefinite article is "een" (meaning "a" or "an") and is used with both de-words and het-words in singular form.
        
        Tips for learning:
        - Always learn nouns with their articles
        - Most nouns ending in -e use DE
        - Most diminutives (ending in -je) use HET
        """,
        keyPoints: [
            "DE and HET both mean 'the' in English",
            "About 2/3 of nouns use DE, 1/3 use HET",
            "ALL plural nouns use DE",
            "EEN means 'a/an' for both types",
            "Always memorize nouns with their articles",
            "No reliable rules - must be memorized"
        ],
        examples: [
            GrammarExample(
                dutch: "de man → de mannen",
                english: "the man → the men",
                breakdown: "DE-word becomes DE in plural",
                audioHint: "də mɑn → də mɑnə(n)"
            ),
            GrammarExample(
                dutch: "het huis → de huizen",
                english: "the house → the houses",
                breakdown: "HET-word becomes DE in plural",
                audioHint: "ət hœys → də hœyzə(n)"
            ),
            GrammarExample(
                dutch: "de vrouw, een vrouw",
                english: "the woman, a woman",
                breakdown: "DE-word with indefinite article EEN",
                audioHint: "də vrɑu, ən vrɑu"
            ),
            GrammarExample(
                dutch: "het kind, een kind",
                english: "the child, a child",
                breakdown: "HET-word with indefinite article EEN",
                audioHint: "ət kɪnt, ən kɪnt"
            ),
            GrammarExample(
                dutch: "de tafel, de stoelen",
                english: "the table, the chairs",
                breakdown: "Both plural forms use DE",
                audioHint: "də taːfəl, də stulə(n)"
            ),
            GrammarExample(
                dutch: "het meisje (diminutive)",
                english: "the girl (little girl)",
                breakdown: "Diminutives ending in -je use HET",
                audioHint: "ət mɛiʃə"
            )
        ],
        exercises: [
            GrammarExercise(
                question: "Which article goes with 'auto' (car)?",
                options: ["de auto", "het auto", "een auto", "Both de and een are correct"],
                correctAnswer: 3,
                explanation: "Auto uses DE (de auto), and EEN for indefinite (een auto). Both 'de auto' and 'een auto' are correct depending on context.",
                hint: "Remember: EEN works with both DE and HET words"
            ),
            GrammarExercise(
                question: "What happens to HET-words in plural?",
                options: ["They keep HET", "They change to DE", "They use EEN", "They have no article"],
                correctAnswer: 1,
                explanation: "ALL plural nouns use DE, regardless of whether they were originally DE or HET words.",
                hint: "All plurals use the same article"
            ),
            GrammarExercise(
                question: "Choose the correct form: 'I see ___ houses'",
                options: ["Ik zie het huizen", "Ik zie de huizen", "Ik zie een huizen", "Ik zie huizen"],
                correctAnswer: 1,
                explanation: "'Huizen' is plural, so it must use DE. 'Ik zie de huizen' means 'I see the houses'.",
                hint: "Plural nouns always use DE"
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "het huizen (plural)",
                correct: "de huizen",
                explanation: "All plural nouns use DE, even if the singular used HET"
            ),
            CommonMistake(
                incorrect: "Learning nouns without articles",
                correct: "Always learn: de man, het huis, de vrouw",
                explanation: "Always memorize nouns together with their articles from the beginning"
            ),
            CommonMistake(
                incorrect: "een de man",
                correct: "een man OR de man",
                explanation: "Don't combine EEN with DE/HET - use either the definite or indefinite article"
            )
        ],
        tips: [
            "Make flashcards with the article: 'de hond' not just 'hond'",
            "Most words ending in -e are DE words (de tafel, de kamer)",
            "Most diminutives ending in -je/-tje are HET words (het meisje, het huisje)",
            "When in doubt, guess DE - it's more common (about 2/3 of nouns)",
            "Practice with 'This is...' sentences: 'Dit is de/het...'"
        ],
        relatedRules: ["pluralization_a2", "adjectives_a2", "demonstratives_a2"]
    )
    
    lazy var pluralizationA2 = DutchGrammarRule(
        id: "pluralization_a2",
        title: "Making Plurals in Dutch (A2)",
        type: .pluralization,
        level: .a2,
        explanation: """
        Dutch has several ways to make nouns plural, but there are patterns you can learn. The most common endings are -en and -s.
        
        Main patterns:
        1. Add -EN (most common): hond → honden (dogs)
        2. Add -S: auto → auto's (cars)
        3. Change vowel + add -EN: stad → steden (cities)
        4. Irregular forms: kind → kinderen (children)
        
        When to use -S:
        • Words ending in unstressed -el, -en, -er
        • Words ending in -a, -i, -o, -u, -y
        • Foreign words
        
        When to use -EN:
        • Most other Dutch words
        • Often with vowel changes in the stem
        """,
        keyPoints: [
            "Two main plural endings: -EN and -S",
            "-EN is more common for native Dutch words",
            "-S is used for foreign words and specific endings",
            "Vowels often change when adding -EN",
            "ALL plurals use DE as the article",
            "Some irregular plurals must be memorized"
        ],
        examples: [
            GrammarExample(
                dutch: "de hond → de honden",
                english: "the dog → the dogs",
                breakdown: "Regular -EN plural, no vowel change",
                audioHint: "də hɔnt → də hɔndə(n)"
            ),
            GrammarExample(
                dutch: "de auto → de auto's",
                english: "the car → the cars",
                breakdown: "Foreign word ending in -o gets -S",
                audioHint: "də ɔto → də ɔtos"
            ),
            GrammarExample(
                dutch: "de stad → de steden",
                english: "the city → the cities",
                breakdown: "Vowel change: a → e when adding -EN",
                audioHint: "də stɑt → də steːdə(n)"
            ),
            GrammarExample(
                dutch: "het kind → de kinderen",
                english: "the child → the children",
                breakdown: "Irregular plural form (like English child/children)",
                audioHint: "ət kɪnt → də kɪndərə(n)"
            ),
            GrammarExample(
                dutch: "de tafel → de tafels",
                english: "the table → the tables",
                breakdown: "Words ending in -el add -S",
                audioHint: "də taːfəl → də taːfəls"
            ),
            GrammarExample(
                dutch: "het meisje → de meisjes",
                english: "the girl → the girls",
                breakdown: "Diminutives ending in -je add -S",
                audioHint: "ət mɛiʃə → də mɛiʃəs"
            ),
            GrammarExample(
                dutch: "de fiets → de fietsen",
                english: "the bicycle → the bicycles",
                breakdown: "Regular -EN plural",
                audioHint: "də fits → də fitsə(n)"
            ),
            GrammarExample(
                dutch: "het boek → de boeken",
                english: "the book → the books",
                breakdown: "Vowel change: oe → oe (no change here) + -EN",
                audioHint: "ət buk → də bukə(n)"
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
            )
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
            "Learn common irregular plurals: kind→kinderen, ei→eieren",
            "Foreign words usually add -S: foto→foto's, taxi→taxi's",
            "Words ending in -f often change to -v: brief→brieven",
            "Practice saying plurals out loud to remember vowel changes",
            "When in doubt with Dutch words, try -EN first"
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
            GrammarExercise(
                question: "Complete: 'Ik denk ___ mijn vakantie' (I think about my vacation)",
                options: ["over", "aan", "van", "voor"],
                correctAnswer: 1,
                explanation: "Dutch uses 'denken AAN' (think of/about). Unlike English 'think about', Dutch connects thoughts with 'aan'.",
                hint: "This verb uses a different preposition than English"
            ),
            GrammarExercise(
                question: "Complete: 'Hij is bang ___ honden' (He is afraid of dogs)",
                options: ["van", "voor", "aan", "over"],
                correctAnswer: 1,
                explanation: "'Bang VOOR' means afraid OF something. 'Voor' shows what threatens you or causes fear.",
                hint: "Think about what you use for danger or threat"
            ),
            GrammarExercise(
                question: "Complete: 'Zij luistert graag ___ muziek' (She likes to listen to music)",
                options: ["aan", "naar", "voor", "bij"],
                correctAnswer: 1,
                explanation: "'Luisteren NAAR' means listen TO. 'Naar' shows direction - your attention goes toward the sound.",
                hint: "This preposition shows direction"
            ),
            GrammarExercise(
                question: "Complete: 'Ik wacht ___ je' (I wait for you)",
                options: ["voor", "op", "aan", "naar"],
                correctAnswer: 1,
                explanation: "'Wachten OP' means wait FOR. 'Op' shows expectation - you're waiting ON something to happen.",
                hint: "Think about expecting something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij houdt ___ voetbal' (He loves football)",
                options: ["aan", "van", "voor", "met"],
                correctAnswer: 1,
                explanation: "'Houden VAN' means love/like. 'Van' shows the source of your feelings - you get pleasure FROM it.",
                hint: "This preposition shows affection"
            ),
            GrammarExercise(
                question: "Complete: 'Zij is geïnteresseerd ___ fotografie' (She is interested in photography)",
                options: ["voor", "in", "aan", "van"],
                correctAnswer: 1,
                explanation: "'Geïnteresseerd IN' means interested IN. Same as English - your interest goes INTO the subject.",
                hint: "Same preposition as in English"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ben gek ___ haar' (I'm crazy about her)",
                options: ["van", "op", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Gek OP' means crazy ABOUT. 'Op' shows intense focus - your feelings are focused ON that person.",
                hint: "Think about being enthusiastic"
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
                options: ["aan", "met", "van", "op"],
                correctAnswer: 1,
                explanation: "'Beginnen MET' means start WITH. 'Met' shows accompaniment - you start together WITH something.",
                hint: "Think about starting together with something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij stopt ___ roken' (He stops smoking)",
                options: ["van", "met", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Stoppen MET' means stop doing something. 'Met' shows separation - you break the connection WITH the activity.",
                hint: "Think about ending an activity"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ben trots ___ mijn zoon' (I'm proud of my son)",
                options: ["van", "op", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Trots OP' means proud OF. 'Op' shows the target of your pride - your feelings rest ON that person.",
                hint: "Think about feeling proud"
            ),
            GrammarExercise(
                question: "Complete: 'Zij praat ___ politiek' (She talks about politics)",
                options: ["aan", "over", "van", "met"],
                correctAnswer: 1,
                explanation: "'Praten OVER' means talk ABOUT a topic. 'Over' shows the subject spans OVER your conversation.",
                hint: "Think about discussing a subject"
            ),
            GrammarExercise(
                question: "Complete: 'Hij kijkt ___ televisie' (He watches television)",
                options: ["aan", "naar", "op", "voor"],
                correctAnswer: 1,
                explanation: "'Kijken NAAR' means look/watch AT. 'Naar' shows direction - your eyes go TOWARD what you're watching.",
                hint: "Think about directing your eyes"
            ),
            GrammarExercise(
                question: "Complete: 'Ik lach ___ de grapjes' (I laugh at the jokes)",
                options: ["van", "om", "aan", "over"],
                correctAnswer: 1,
                explanation: "'Lachen OM' means laugh AT/ABOUT. 'Om' shows what surrounds your laughter - you laugh AROUND the funny thing.",
                hint: "Think about finding something funny"
            ),
            GrammarExercise(
                question: "Complete: 'Hij lijkt ___ zijn vader' (He looks like his father)",
                options: ["aan", "op", "naar", "van"],
                correctAnswer: 1,
                explanation: "'Lijken OP' means resemble/look like. 'Op' shows similarity - his appearance rests ON his father's features.",
                hint: "Think about similarity"
            ),
            GrammarExercise(
                question: "Complete: 'Zij droomt ___ een grote reis' (She dreams of a big trip)",
                options: ["aan", "van", "over", "naar"],
                correctAnswer: 1,
                explanation: "'Dromen VAN' means dream OF/ABOUT. 'Van' shows the source - the dream comes FROM that desire.",
                hint: "Think about having dreams"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ben bezorgd ___ het weer' (I'm worried about the weather)",
                options: ["van", "over", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Bezorgd OVER' means worried ABOUT. 'Over' shows the topic spans OVER your thoughts with concern.",
                hint: "Think about being concerned"
            ),
            GrammarExercise(
                question: "Complete: 'Hij is boos ___ zijn vrienden' (He's angry at his friends)",
                options: ["van", "op", "aan", "met"],
                correctAnswer: 1,
                explanation: "'Boos OP' means angry AT/WITH. 'Op' shows the target - your anger is directed ON those people.",
                hint: "Think about being angry at someone"
            ),
            GrammarExercise(
                question: "Complete: 'Ik concentreer me ___ mijn werk' (I concentrate on my work)",
                options: ["aan", "op", "van", "met"],
                correctAnswer: 1,
                explanation: "'Concentreren OP' means concentrate ON. 'Op' shows focus - your attention rests ON that one thing.",
                hint: "Think about focusing attention"
            ),
            GrammarExercise(
                question: "Complete: 'Hij neemt deel ___ de wedstrijd' (He participates in the competition)",
                options: ["van", "aan", "op", "met"],
                correctAnswer: 1,
                explanation: "'Deelnemen AAN' means participate IN. 'Aan' shows connection - you attach yourself TO the activity.",
                hint: "Think about participating"
            ),
            GrammarExercise(
                question: "Complete: 'Zij discussiëert ___ haar collega's' (She discusses with her colleagues)",
                options: ["aan", "met", "van", "over"],
                correctAnswer: 1,
                explanation: "'Discussiëren MET' means discuss WITH people. 'Met' shows companionship - you discuss together WITH others.",
                hint: "Think about having a discussion with someone"
            ),
            GrammarExercise(
                question: "Complete: 'Ik heb ervaring ___ computers' (I have experience with computers)",
                options: ["van", "met", "in", "aan"],
                correctAnswer: 1,
                explanation: "'Ervaring MET' means experience WITH. 'Met' shows tool/method - you gained experience by working WITH them.",
                hint: "Think about having experience with something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij feliciteert haar ___ haar verjaardag' (He congratulates her on her birthday)",
                options: ["voor", "met", "aan", "van"],
                correctAnswer: 1,
                explanation: "'Feliciteren MET' means congratulate ON. 'Met' shows the occasion - you celebrate together WITH that event.",
                hint: "Think about congratulating someone"
            ),
            GrammarExercise(
                question: "Complete: 'Ik maak gebruik ___ de toilet' (I use the toilet)",
                options: ["aan", "van", "met", "voor"],
                correctAnswer: 1,
                explanation: "'Gebruik maken VAN' means make use OF. 'Van' shows source - you take advantage FROM that resource.",
                hint: "Think about utilizing something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij is goed ___ wiskunde' (He is good at mathematics)",
                options: ["met", "in", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Goed IN' means good AT a subject. 'In' shows the domain - your skill exists WITHIN that field.",
                hint: "Think about being skilled in something"
            ),
            GrammarExercise(
                question: "Complete: 'Zij heeft een hekel ___ spinnen' (She hates spiders)",
                options: ["van", "aan", "voor", "op"],
                correctAnswer: 1,
                explanation: "'Hekel hebben AAN' means hate/dislike. 'Aan' shows attachment - the dislike sticks TO that thing.",
                hint: "Think about disliking something"
            ),
            GrammarExercise(
                question: "Complete: 'Ik informeer ___ de openingstijden' (I inquire about opening hours)",
                options: ["over", "naar", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Informeren NAAR' means inquire ABOUT/ask for. 'Naar' shows direction - you reach TOWARD information.",
                hint: "Think about asking for information"
            ),
            GrammarExercise(
                question: "Complete: 'Hij schrijft zich in ___ een cursus' (He enrolls in a course)",
                options: ["aan", "voor", "in", "op"],
                correctAnswer: 1,
                explanation: "'Inschrijven VOOR' means enroll FOR/sign up for. 'Voor' shows purpose - you register FOR that specific thing.",
                hint: "Think about signing up for something"
            ),
            GrammarExercise(
                question: "Complete: 'Zij heeft invloed ___ zijn beslissing' (She has influence on his decision)",
                options: ["van", "op", "aan", "over"],
                correctAnswer: 1,
                explanation: "'Invloed OP' means influence ON. 'Op' shows impact - your influence presses ON that person/decision.",
                hint: "Think about affecting something"
            ),
            GrammarExercise(
                question: "Complete: 'Ik maak kennis ___ de buren' (I get acquainted with the neighbors)",
                options: ["aan", "met", "van", "voor"],
                correctAnswer: 1,
                explanation: "'Kennismaken MET' means get acquainted WITH. 'Met' shows companionship - you meet together WITH them.",
                hint: "Think about meeting someone new"
            ),
            GrammarExercise(
                question: "Complete: 'Hij heeft kritiek ___ het plan' (He has criticism of the plan)",
                options: ["aan", "op", "van", "over"],
                correctAnswer: 1,
                explanation: "'Kritiek OP' means criticism OF/ON. 'Op' shows target - your criticism focuses ON that specific thing.",
                hint: "Think about criticizing something"
            ),
            GrammarExercise(
                question: "Complete: 'Ik doe mee ___ het spel' (I participate in the game)",
                options: ["aan", "met", "in", "bij"],
                correctAnswer: 1,
                explanation: "'Meedoen MET' means participate WITH/join in. 'Met' shows companionship - you play together WITH others.",
                hint: "Think about joining an activity"
            ),
            GrammarExercise(
                question: "Complete: 'Hij denkt na ___ het probleem' (He thinks about the problem)",
                options: ["aan", "over", "van", "met"],
                correctAnswer: 1,
                explanation: "'Nadenken OVER' means think ABOUT/ponder. 'Over' shows the topic spans OVER your thoughts deeply.",
                hint: "Think about pondering something"
            ),
            GrammarExercise(
                question: "Complete: 'Zij reageert ___ de e-mail' (She responds to the email)",
                options: ["aan", "op", "van", "met"],
                correctAnswer: 1,
                explanation: "'Reageren OP' means respond TO/react to. 'Op' shows trigger - your response builds ON that stimulus.",
                hint: "Think about responding to something"
            ),
            GrammarExercise(
                question: "Complete: 'Ik maak reclame ___ mijn bedrijf' (I advertise for my company)",
                options: ["aan", "voor", "van", "met"],
                correctAnswer: 1,
                explanation: "'Reclame maken VOOR' means advertise FOR. 'Voor' shows benefit - you promote FOR your company's advantage.",
                hint: "Think about promoting something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij houdt rekening ___ het weer' (He takes the weather into account)",
                options: ["van", "met", "aan", "voor"],
                correctAnswer: 1,
                explanation: "'Rekening houden MET' means consider/account for. 'Met' shows inclusion - you calculate together WITH that factor.",
                hint: "Think about considering something"
            ),
            GrammarExercise(
                question: "Complete: 'Zij heeft respect ___ haar leraar' (She has respect for her teacher)",
                options: ["aan", "voor", "van", "met"],
                correctAnswer: 1,
                explanation: "'Respect VOOR' means respect FOR. 'Voor' shows direction - your respect is directed FOR that person.",
                hint: "Think about showing respect"
            ),
            GrammarExercise(
                question: "Complete: 'Ik werk samen ___ internationale bedrijven' (I work together with international companies)",
                options: ["aan", "met", "van", "voor"],
                correctAnswer: 1,
                explanation: "'Samenwerken MET' means collaborate WITH. 'Met' shows partnership - you work together WITH others.",
                hint: "Think about collaborating"
            ),
            GrammarExercise(
                question: "Complete: 'Hij schaamt zich ___ zijn gedrag' (He is ashamed of his behavior)",
                options: ["van", "voor", "aan", "over"],
                correctAnswer: 1,
                explanation: "'Schamen VOOR' means be ashamed OF. 'Voor' shows cause - you feel shame FOR what you did.",
                hint: "Think about feeling ashamed"
            ),
            GrammarExercise(
                question: "Complete: 'Wij schrikken ___ het nieuws' (We are shocked by the news)",
                options: ["aan", "van", "voor", "over"],
                correctAnswer: 1,
                explanation: "'Schrikken VAN' means be shocked BY. 'Van' shows source - the shock comes FROM that surprising thing.",
                hint: "Think about being startled"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ben geslaagd ___ mijn examen' (I passed my exam)",
                options: ["aan", "voor", "in", "met"],
                correctAnswer: 1,
                explanation: "'Slagen VOOR' means pass/succeed in an exam. 'Voor' shows the challenge - you succeeded FOR that test.",
                hint: "Think about succeeding in an exam"
            ),
            GrammarExercise(
                question: "Complete: 'Hij slaapt slecht ___ het lawaai' (He sleeps badly because of the noise)",
                options: ["aan", "van", "door", "met"],
                correctAnswer: 1,
                explanation: "'Slecht slapen VAN' means sleep badly because OF. 'Van' shows source - the problem comes FROM that cause.",
                hint: "Think about what disturbs sleep"
            ),
            GrammarExercise(
                question: "Complete: 'Zij is verliefd ___ haar buurman' (She is in love with her neighbor)",
                options: ["aan", "op", "van", "met"],
                correctAnswer: 1,
                explanation: "'Verliefd OP' means in love WITH. 'Op' shows focus - your romantic feelings are focused ON that person.",
                hint: "Think about romantic feelings"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ben tevreden ___ mijn salaris' (I am satisfied with my salary)",
                options: ["van", "met", "over", "aan"],
                correctAnswer: 1,
                explanation: "'Tevreden MET' means satisfied WITH. 'Met' shows accompaniment - your satisfaction goes together WITH that thing.",
                hint: "Think about being content with something"
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
            GrammarExercise(
                question: "Complete: 'Ik ga naar de winkel ___ boodschappen ___ doen' (I go to the store to do shopping)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Om...te' expresses purpose - you go to the store IN ORDER TO do shopping. This shows the goal of your action.",
                hint: "This expresses purpose - why you're going"
            ),
            GrammarExercise(
                question: "Complete: 'Het is moeilijk ___ Nederlands ___ spreken' (It's difficult to speak Dutch)",
                options: ["om, te", "te, te", "om, om", "te, om"],
                correctAnswer: 0,
                explanation: "After adjectives expressing difficulty, use 'om...te': 'moeilijk om te'. This pattern shows something is hard TO DO.",
                hint: "After adjectives like 'moeilijk', use om...te"
            ),
            GrammarExercise(
                question: "Complete: 'Ik vergeet altijd mijn sleutels ___ meenemen' (I always forget to take my keys)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Vergeten' uses 'te' directly: 'vergeten te doen'. This is a direct connection between the verbs.",
                hint: "Vergeten connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Hij stopt met roken ___ gezonder ___ worden' (He stops smoking to become healthier)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Om...te' expresses the purpose or goal - he stops smoking IN ORDER TO become healthier.",
                hint: "This shows the purpose or goal of stopping"
            ),
            GrammarExercise(
                question: "Complete: 'Zij belooft ___ komen' (She promises to come)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Beloven' (promise) uses 'te' directly: 'beloven te komen'. This is a direct connection.",
                hint: "Beloven connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Het boek is te duur ___ kopen' (The book is too expensive to buy)",
                options: ["te", "om te", "om", "voor te"],
                correctAnswer: 1,
                explanation: "After 'te + adjective', use 'om te': 'te duur om te kopen'. This shows something is TOO [adjective] TO do.",
                hint: "After 'te + adjective', use om te"
            ),
            GrammarExercise(
                question: "Complete: 'Ik heb geen tijd ___ koken' (I don't have time to cook)",
                options: ["om te", "te", "voor te", "aan te"],
                correctAnswer: 0,
                explanation: "'Tijd hebben om te' - having time FOR doing something. 'Om te' shows the purpose of the time.",
                hint: "Think about having time FOR doing something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij leert ___ fietsen' (He learns to cycle)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Leren' (learn) uses 'te' directly: 'leren te fietsen'. This is a direct skill connection.",
                hint: "Leren connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Wij gaan vroeg naar bed ___ uitgerust ___ zijn' (We go to bed early to be rested)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Om...te' expresses purpose - you go to bed early IN ORDER TO be rested tomorrow.",
                hint: "This shows the purpose of going to bed early"
            ),
            GrammarExercise(
                question: "Complete: 'Het is belangrijk ___ sporten' (It's important to exercise)",
                options: ["om te", "te", "om", "voor te"],
                correctAnswer: 0,
                explanation: "After 'belangrijk' (important), use 'om te': 'belangrijk om te sporten'. This shows importance OF doing something.",
                hint: "After adjectives expressing importance, use om te"
            ),
            GrammarExercise(
                question: "Complete: 'Zij besluit ___ stoppen met werken' (She decides to stop working)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 0,
                explanation: "'Besluiten' (decide) uses 'om te': 'besluiten om te stoppen'. This shows a decision TO do something.",
                hint: "Besluiten uses om te for decisions"
            ),
            GrammarExercise(
                question: "Complete: 'Ik probeer ___ vroeg ___ zijn' (I try to be early)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Proberen' can use both, but 'om te' is more common: 'proberen om te zijn'. This shows effort TOWARD a goal.",
                hint: "Proberen often uses om te for efforts toward goals"
            ),
            GrammarExercise(
                question: "Complete: 'Het huis is te klein ___ wonen' (The house is too small to live in)",
                options: ["te", "om te", "om", "voor te"],
                correctAnswer: 1,
                explanation: "After 'te + adjective', use 'om te': 'te klein om te wonen'. Pattern: too [adjective] TO do something.",
                hint: "Te + adjective + om te pattern"
            ),
            GrammarExercise(
                question: "Complete: 'Hij heeft zin ___ uitgaan' (He feels like going out)",
                options: ["om te", "te", "in", "aan te"],
                correctAnswer: 0,
                explanation: "'Zin hebben om te' - feeling like doing something. 'Om te' shows what you feel like doing.",
                hint: "Zin hebben uses om te"
            ),
            GrammarExercise(
                question: "Complete: 'Wij hopen ___ slagen' (We hope to succeed)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Hopen' (hope) uses 'te' directly: 'hopen te slagen'. This is a direct emotional connection.",
                hint: "Hopen connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Zij weigert ___ helpen' (She refuses to help)",
                options: ["om te", "te", "om", "voor te"],
                correctAnswer: 1,
                explanation: "'Weigeren' (refuse) uses 'te' directly: 'weigeren te helpen'. This shows direct refusal.",
                hint: "Weigeren connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Het is onmogelijk ___ alles ___ onthouden' (It's impossible to remember everything)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "After adjectives like 'onmogelijk', use 'om...te': 'onmogelijk om te onthouden'.",
                hint: "After adjectives expressing possibility, use om...te"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ben van plan ___ verhuizen' (I plan to move)",
                options: ["om te", "te", "om", "naar te"],
                correctAnswer: 0,
                explanation: "'Van plan zijn om te' - planning TO do something. This expression always uses 'om te'.",
                hint: "Van plan zijn uses om te"
            ),
            GrammarExercise(
                question: "Complete: 'Hij durft niet ___ springen' (He doesn't dare to jump)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Durven' (dare) uses 'te' directly: 'durven te springen'. This is direct courage/fear.",
                hint: "Durven connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Wij komen hier ___ studeren' (We come here to study)",
                options: ["te", "om te", "om", "voor te"],
                correctAnswer: 1,
                explanation: "'Om te' expresses purpose - you come here IN ORDER TO study. This shows why you come.",
                hint: "This expresses the purpose of coming"
            ),
            GrammarExercise(
                question: "Complete: 'Het is makkelijk ___ fouten ___ maken' (It's easy to make mistakes)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "After 'makkelijk' (easy), use 'om...te': 'makkelijk om fouten te maken'.",
                hint: "After adjectives expressing ease, use om...te"
            ),
            GrammarExercise(
                question: "Complete: 'Zij schijnt ___ ziek zijn' (She seems to be sick)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Schijnen' (seem) uses 'te' directly: 'schijnen te zijn'. This is direct appearance.",
                hint: "Schijnen connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ga naar de bibliotheek ___ boeken ___ lenen' (I go to the library to borrow books)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Om...te' expresses purpose - you go to the library IN ORDER TO borrow books.",
                hint: "This shows the purpose of going to the library"
            ),
            GrammarExercise(
                question: "Complete: 'Het weer is te slecht ___ buiten ___ spelen' (The weather is too bad to play outside)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "After 'te + adjective', use 'om...te': 'te slecht om buiten te spelen'.",
                hint: "Te + adjective + om te pattern"
            ),
            GrammarExercise(
                question: "Complete: 'Zij doet haar best ___ slagen' (She does her best to succeed)",
                options: ["om te", "te", "om", "voor te"],
                correctAnswer: 0,
                explanation: "'Haar best doen om te' - doing your best TO achieve something. This shows effort toward a goal.",
                hint: "Doing your best FOR achieving something"
            ),
            GrammarExercise(
                question: "Complete: 'Hij blijkt ___ gelijk hebben' (He turns out to be right)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Blijken' (turn out) uses 'te' directly: 'blijken te hebben'. This shows direct revelation.",
                hint: "Blijken connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Ik heb geen geld ___ een auto ___ kopen' (I don't have money to buy a car)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Om...te' expresses purpose - you need money IN ORDER TO buy a car.",
                hint: "This shows what the money is for"
            ),
            GrammarExercise(
                question: "Complete: 'Zij lijkt ___ moe zijn' (She seems to be tired)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Lijken' (seem) uses 'te' directly: 'lijken te zijn'. This is direct appearance.",
                hint: "Lijken connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Het is nuttig ___ veel ___ lezen' (It's useful to read a lot)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "After 'nuttig' (useful), use 'om...te': 'nuttig om veel te lezen'.",
                hint: "After adjectives expressing usefulness, use om...te"
            ),
            GrammarExercise(
                question: "Complete: 'Wij gaan naar Amsterdam ___ het Rijksmuseum ___ bezoeken' (We go to Amsterdam to visit the Rijksmuseum)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "'Om...te' expresses purpose - you go to Amsterdam IN ORDER TO visit the museum.",
                hint: "This shows the purpose of the trip"
            ),
            GrammarExercise(
                question: "Complete: 'Hij dreigt ___ vertrekken' (He threatens to leave)",
                options: ["om te", "te", "om", "mee te"],
                correctAnswer: 1,
                explanation: "'Dreigen' (threaten) uses 'te' directly: 'dreigen te vertrekken'. This is direct threat.",
                hint: "Dreigen connects directly with te"
            ),
            GrammarExercise(
                question: "Complete: 'Het is slim ___ geld ___ sparen' (It's smart to save money)",
                options: ["te, te", "om, te", "om, om", "te, om"],
                correctAnswer: 1,
                explanation: "After 'slim' (smart), use 'om...te': 'slim om geld te sparen'.",
                hint: "After adjectives expressing wisdom, use om...te"
            ),
            GrammarExercise(
                question: "Complete: 'Ik sta op het punt ___ vertrekken' (I'm about to leave)",
                options: ["om te", "te", "om", "van te"],
                correctAnswer: 0,
                explanation: "'Op het punt staan om te' - being about TO do something. This expression uses 'om te'.",
                hint: "Op het punt staan uses om te"
            ),
            GrammarExercise(
                question: "Complete: 'Zij weet niet hoe ___ koken' (She doesn't know how to cook)",
                options: ["om te", "te", "om", "aan te"],
                correctAnswer: 1,
                explanation: "'Weten hoe te' - knowing how TO do something. This uses 'te' directly.",
                hint: "Weten hoe uses te directly"
            ),
            GrammarExercise(
                question: "Past tense of 'kussen': Zij ___ haar kind (She kissed her child)",
                options: ["kusde", "kuste", "kusede", "kusete"],
                correctAnswer: 1,
                explanation: "kussen → kus. S is in 't kofschip, so use -TE: kuste",
                hint: "Is S in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'fietsen': Ik ___ naar school (I cycled to school)",
                options: ["fietste", "fietsde", "fietsete", "fietsede"],
                correctAnswer: 0,
                explanation: "fietsen → fiets. S is in 't kofschip, so use -TE: fietste",
                hint: "Is S in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'tekenen': Hij ___ een prachtig plaatje (He drew a beautiful picture)",
                options: ["tekende", "tekente", "tekenede", "tekenete"],
                correctAnswer: 0,
                explanation: "tekenen → teken. N is NOT in 't kofschip, so use -DE: tekende",
                hint: "Is N in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'hopen': Wij ___ op goed weer (We hoped for good weather)",
                options: ["hoopde", "hoopte", "hopede", "hopete"],
                correctAnswer: 1,
                explanation: "hopen → hoop. P is in 't kofschip, so use -TE: hoopte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'bellen': Zij ___ haar moeder (She called her mother)",
                options: ["belde", "beltte", "belede", "belette"],
                correctAnswer: 0,
                explanation: "bellen → bel. L is NOT in 't kofschip, so use -DE: belde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'pakken': Ik ___ mijn tas (I grabbed my bag)",
                options: ["pakde", "pakte", "pakede", "pakete"],
                correctAnswer: 1,
                explanation: "pakken → pak. K is in 't kofschip, so use -TE: pakte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'voelen': Hij ___ zich ziek (He felt sick)",
                options: ["voelde", "voelte", "voelede", "voelette"],
                correctAnswer: 0,
                explanation: "voelen → voel. L is NOT in 't kofschip, so use -DE: voelde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'ruiken': Het ___ lekker (It smelled good)",
                options: ["ruikte", "ruikde", "ruikete", "ruikede"],
                correctAnswer: 0,
                explanation: "ruiken → ruik. K is in 't kofschip, so use -TE: ruikte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'dansen': Wij ___ de hele avond (We danced all evening)",
                options: ["danste", "dansde", "dansete", "dansede"],
                correctAnswer: 0,
                explanation: "dansen → dans. S is in 't kofschip, so use -TE: danste",
                hint: "Is S in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'wachten': Jullie ___ op de bus (You waited for the bus)",
                options: ["wachtte", "wachtde", "wachtete", "wachtede"],
                correctAnswer: 0,
                explanation: "wachten → wacht. T is in 't kofschip, so use -TE: wachtte",
                hint: "Is T in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'leven': Zij ___ in Frankrijk (She lived in France)",
                options: ["levde", "lefte", "leefde", "leeftte"],
                correctAnswer: 2,
                explanation: "leven → leef (F becomes V!). F is in 't kofschip, but stem ends in F, so use -DE: leefde",
                hint: "Watch out: F becomes V in the stem!"
            ),
            GrammarExercise(
                question: "Past tense of 'reizen': Ik ___ door Europa (I traveled through Europe)",
                options: ["reiste", "reisde", "reizede", "reizete"],
                correctAnswer: 1,
                explanation: "reizen → reis (Z becomes S!). S is in 't kofschip, but stem ends in S from Z, so use -DE: reisde",
                hint: "Watch out: Z becomes S in the stem!"
            ),
            GrammarExercise(
                question: "Past tense of 'zoeken': Hij ___ zijn sleutels (He looked for his keys)",
                options: ["zoedte", "zoekte", "zoekede", "zoekete"],
                correctAnswer: 1,
                explanation: "zoeken → zoek. K is in 't kofschip, so use -TE: zoekte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'horen': Wij ___ muziek (We heard music)",
                options: ["hoorde", "hoortte", "hoorerde", "hoorette"],
                correctAnswer: 0,
                explanation: "horen → hoor. R is NOT in 't kofschip, so use -DE: hoorde",
                hint: "Is R in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'koken': Zij ___ een heerlijke maaltijd (She cooked a delicious meal)",
                options: ["kookde", "kookte", "kookede", "kookete"],
                correctAnswer: 1,
                explanation: "koken → kook. K is in 't kofschip, so use -TE: kookte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'werken': Ik ___ hard gisteren (I worked hard yesterday)",
                options: ["werkde", "werkte", "werkede", "werkete"],
                correctAnswer: 1,
                explanation: "werken → werk. K is in 't kofschip, so use -TE: werkte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'vragen': Hij ___ om hulp (He asked for help)",
                options: ["vraagde", "vraagtte", "vroeg", "vragte"],
                correctAnswer: 2,
                explanation: "vragen is irregular: vroeg. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'openen': Wij ___ de deur (We opened the door)",
                options: ["opente", "opende", "openede", "openette"],
                correctAnswer: 1,
                explanation: "openen → open. N is NOT in 't kofschip, so use -DE: opende",
                hint: "Is N in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'kloppen': Het ___ niet (It didn't add up)",
                options: ["klopde", "klopte", "klopede", "klopete"],
                correctAnswer: 1,
                explanation: "kloppen → klop. P is in 't kofschip, so use -TE: klopte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'dromen': Ik ___ van vakantie (I dreamed of vacation)",
                options: ["droomde", "droomtte", "dromede", "dromette"],
                correctAnswer: 0,
                explanation: "dromen → droom. M is NOT in 't kofschip, so use -DE: droomde",
                hint: "Is M in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'lachen': Zij ___ om mijn grap (She laughed at my joke)",
                options: ["lachde", "lachte", "lachede", "lachete"],
                correctAnswer: 1,
                explanation: "lachen → lach. CH is in 't kofschip, so use -TE: lachte",
                hint: "Is CH in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'sparen': Hij ___ geld voor een auto (He saved money for a car)",
                options: ["spaarde", "spaarte", "sparede", "sparette"],
                correctAnswer: 0,
                explanation: "sparen → spaar. R is NOT in 't kofschip, so use -DE: spaarde",
                hint: "Is R in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'wassen': Ik ___ mijn handen (I washed my hands)",
                options: ["waste", "wasde", "wasse", "waschte"],
                correctAnswer: 1,
                explanation: "wassen → was. S is in 't kofschip, but this is irregular: waste (not waschte)",
                hint: "This verb has an irregular past tense!"
            ),
            GrammarExercise(
                question: "Past tense of 'typen': Wij ___ een brief (We typed a letter)",
                options: ["typede", "typte", "typeede", "typette"],
                correctAnswer: 1,
                explanation: "typen → typ. P is in 't kofschip, so use -TE: typte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'redden': Hij ___ de kat (He saved the cat)",
                options: ["redde", "redtte", "redede", "redette"],
                correctAnswer: 0,
                explanation: "redden → red. D is NOT in 't kofschip, so use -DE: redde",
                hint: "Is D in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'tellen': Zij ___ tot tien (She counted to ten)",
                options: ["telde", "teltte", "telede", "telette"],
                correctAnswer: 0,
                explanation: "tellen → tel. L is NOT in 't kofschip, so use -DE: telde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'happen': De hond ___ naar het eten (The dog snapped at the food)",
                options: ["hapde", "hapte", "hapede", "hapete"],
                correctAnswer: 1,
                explanation: "happen → hap. P is in 't kofschip, so use -TE: hapte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'missen': Ik ___ de trein (I missed the train)",
                options: ["miste", "misde", "misete", "misede"],
                correctAnswer: 0,
                explanation: "missen → mis. S is in 't kofschip, so use -TE: miste",
                hint: "Is S in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'vullen': Hij ___ het glas (He filled the glass)",
                options: ["vulde", "vultte", "vulede", "vulette"],
                correctAnswer: 0,
                explanation: "vullen → vul. L is NOT in 't kofschip, so use -DE: vulde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'roken': Zij ___ een sigaret (She smoked a cigarette)",
                options: ["rookde", "rookte", "rokede", "rokette"],
                correctAnswer: 1,
                explanation: "roken → rook. K is in 't kofschip, so use -TE: rookte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'vallen': Ik ___ van mijn fiets (I fell off my bike)",
                options: ["valde", "valtte", "viel", "valle"],
                correctAnswer: 2,
                explanation: "vallen is irregular: viel. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'raden': Hij ___ het antwoord (He guessed the answer)",
                options: ["raadde", "raadtte", "ried", "radte"],
                correctAnswer: 2,
                explanation: "raden is irregular: ried. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'knippen': Ik ___ mijn haar (I cut my hair)",
                options: ["knipde", "knipte", "knipede", "knipete"],
                correctAnswer: 1,
                explanation: "knippen → knip. P is in 't kofschip, so use -TE: knipte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'groeien': De boom ___ snel (The tree grew fast)",
                options: ["groeide", "groeitte", "groeiede", "groeiette"],
                correctAnswer: 0,
                explanation: "groeien → groei. I is NOT in 't kofschip, so use -DE: groeide",
                hint: "Is I in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'bouwen': Wij ___ een huis (We built a house)",
                options: ["bouwde", "bouwtte", "bouwede", "bouwette"],
                correctAnswer: 0,
                explanation: "bouwen → bouw. W is NOT in 't kofschip, so use -DE: bouwde",
                hint: "Is W in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'vechten': Hij ___ voor zijn rechten (He fought for his rights)",
                options: ["vechtde", "vochte", "vecht", "vechtte"],
                correctAnswer: 1,
                explanation: "vechten is irregular: vocht. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'fluiten': Zij ___ een liedje (She whistled a song)",
                options: ["floot", "fluitde", "fluittte", "fluitede"],
                correctAnswer: 0,
                explanation: "fluiten is irregular: floot. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'wensen': Ik ___ je geluk (I wished you luck)",
                options: ["wenste", "wensde", "wensete", "wensede"],
                correctAnswer: 0,
                explanation: "wensen → wens. S is in 't kofschip, so use -TE: wenste",
                hint: "Is S in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'delen': Hij ___ zijn lunch (He shared his lunch)",
                options: ["deelde", "deltte", "delede", "delette"],
                correctAnswer: 0,
                explanation: "delen → deel. L is NOT in 't kofschip, so use -DE: deelde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'tikken': Wij ___ op de deur (We knocked on the door)",
                options: ["tikde", "tikte", "tikede", "tikete"],
                correctAnswer: 1,
                explanation: "tikken → tik. K is in 't kofschip, so use -TE: tikte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'hangen': Het schilderij ___ aan de muur (The painting hung on the wall)",
                options: ["hangde", "hing", "hangtte", "hangede"],
                correctAnswer: 1,
                explanation: "hangen is irregular: hing. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'schudden': Hij ___ zijn hoofd (He shook his head)",
                options: ["schudde", "schudtte", "schudede", "schudette"],
                correctAnswer: 0,
                explanation: "schudden → schud. D is NOT in 't kofschip, so use -DE: schudde",
                hint: "Is D in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'happen': De vis ___ naar het aas (The fish bit at the bait)",
                options: ["hapde", "hapte", "hapede", "hapete"],
                correctAnswer: 1,
                explanation: "happen → hap. P is in 't kofschip, so use -TE: hapte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'rennen': Ik ___ naar huis (I ran home)",
                options: ["rende", "rentte", "renede", "renette"],
                correctAnswer: 0,
                explanation: "rennen → ren. N is NOT in 't kofschip, so use -DE: rende",
                hint: "Is N in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'vissen': Hij ___ in de rivier (He fished in the river)",
                options: ["viste", "visde", "visete", "visede"],
                correctAnswer: 0,
                explanation: "vissen → vis. S is in 't kofschip, so use -TE: viste",
                hint: "Is S in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'blazen': De wind ___ hard (The wind blew hard)",
                options: ["blies", "blazde", "blaztte", "blazede"],
                correctAnswer: 0,
                explanation: "blazen is irregular: blies. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'plakken': Zij ___ de foto in het album (She stuck the photo in the album)",
                options: ["plakde", "plakte", "plakede", "plakete"],
                correctAnswer: 1,
                explanation: "plakken → plak. K is in 't kofschip, so use -TE: plakte",
                hint: "Is K in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'gillen': Het kind ___ van schrik (The child screamed in fright)",
                options: ["gilde", "giltte", "gilede", "gilette"],
                correctAnswer: 0,
                explanation: "gillen → gil. L is NOT in 't kofschip, so use -DE: gilde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'trekken': Wij ___ aan het touw (We pulled the rope)",
                options: ["trok", "trekde", "trektte", "trekede"],
                correctAnswer: 0,
                explanation: "trekken is irregular: trok. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'stampen': Hij ___ op de grond (He stamped on the ground)",
                options: ["stampde", "stampte", "stampede", "stampete"],
                correctAnswer: 1,
                explanation: "stampen → stamp. P is in 't kofschip, so use -TE: stampte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'zwemmen': Ik ___ in het zwembad (I swam in the pool)",
                options: ["zwom", "zwemde", "zwemtte", "zwemede"],
                correctAnswer: 0,
                explanation: "zwemmen is irregular: zwom. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'ademen': Zij ___ diep in (She breathed deeply)",
                options: ["ademde", "ademtte", "ademede", "ademette"],
                correctAnswer: 0,
                explanation: "ademen → adem. M is NOT in 't kofschip, so use -DE: ademde",
                hint: "Is M in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'schaatsen': Wij ___ op het ijs (We skated on the ice)",
                options: ["schaatste", "schaatsde", "schaatsete", "schaatsede"],
                correctAnswer: 0,
                explanation: "schaatsen → schaats. S is in 't kofschip, so use -TE: schaatste",
                hint: "Is S in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'branden': Het huis ___ af (The house burned down)",
                options: ["brandde", "brandtte", "brandede", "brandette"],
                correctAnswer: 0,
                explanation: "branden → brand. D is NOT in 't kofschip, so use -DE: brandde",
                hint: "Is D in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'klappen': Het publiek ___ hard (The audience clapped loudly)",
                options: ["klapde", "klapte", "klapede", "klapete"],
                correctAnswer: 1,
                explanation: "klappen → klap. P is in 't kofschip, so use -TE: klapte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'gooien': Hij ___ de bal (He threw the ball)",
                options: ["gooide", "gooitte", "gooidede", "gooiette"],
                correctAnswer: 0,
                explanation: "gooien → gooi. I is NOT in 't kofschip, so use -DE: gooide",
                hint: "Is I in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'schoppen': Zij ___ de bal weg (She kicked the ball away)",
                options: ["schopde", "schopte", "schopede", "schopete"],
                correctAnswer: 1,
                explanation: "schoppen → schop. P is in 't kofschip, so use -TE: schopte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'snijden': Ik ___ het brood (I cut the bread)",
                options: ["sneed", "snijdde", "snijdtte", "snijdede"],
                correctAnswer: 0,
                explanation: "snijden is irregular: sneed. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'wippen': Het kind ___ op de schommel (The child bounced on the swing)",
                options: ["wipde", "wipte", "wipede", "wipete"],
                correctAnswer: 1,
                explanation: "wippen → wip. P is in 't kofschip, so use -TE: wipte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'rollen': De bal ___ over de grond (The ball rolled over the ground)",
                options: ["rolde", "roltte", "rolede", "rolette"],
                correctAnswer: 0,
                explanation: "rollen → rol. L is NOT in 't kofschip, so use -DE: rolde",
                hint: "Is L in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'duiken': Hij ___ in het water (He dove into the water)",
                options: ["dook", "duikde", "duiktte", "duikede"],
                correctAnswer: 0,
                explanation: "duiken is irregular: dook. Not all verbs follow 't kofschip rule!",
                hint: "This is an irregular verb!"
            ),
            GrammarExercise(
                question: "Past tense of 'kloppen': Mijn hart ___ snel (My heart beat fast)",
                options: ["klopde", "klopte", "klopede", "klopete"],
                correctAnswer: 1,
                explanation: "kloppen → klop. P is in 't kofschip, so use -TE: klopte",
                hint: "Is P in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'vegen': Zij ___ de vloer (She swept the floor)",
                options: ["veegde", "veegtte", "vegede", "vegette"],
                correctAnswer: 0,
                explanation: "vegen → veeg. G is NOT in 't kofschip, so use -DE: veegde",
                hint: "Is G in 't kofschip?"
            ),
            GrammarExercise(
                question: "Past tense of 'stappen': Wij ___ uit de auto (We stepped out of the car)",
                options: ["stapde", "stapte", "stapede", "stapete"],
                correctAnswer: 1,
                explanation: "stappen → stap. P is in 't kofschip, so use -TE: stapte",
                hint: "Is P in 't kofschip?"
            )
            // ... existing code ...
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
            GrammarExercise(
                question: "Complete: 'Ik ___ gisteren naar de winkel gegaan' (I went to the store yesterday)",
                options: ["heb", "ben", "had", "was"],
                correctAnswer: 1,
                explanation: "'Gaan' (go) is a movement verb, so use ZIJN: 'Ik ben gegaan'. Movement verbs always use ZIJN.",
                hint: "Gaan is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een mooie jurk gekocht' (She bought a beautiful dress)",
                options: ["is", "ben", "heeft", "had"],
                correctAnswer: 2,
                explanation: "'Kopen' (buy) is a transitive verb with direct object, so use HEBBEN: 'Zij heeft gekocht'.",
                hint: "Kopen is transitive - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Het kind ___ snel gegroeid' (The child grew quickly)",
                options: ["heeft", "is", "had", "was"],
                correctAnswer: 1,
                explanation: "'Groeien' (grow) shows change of state, so use ZIJN: 'Het kind is gegroeid'.",
                hint: "Growing is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ de hele dag gewerkt' (We worked all day)",
                options: ["zijn", "ben", "hebben", "had"],
                correctAnswer: 2,
                explanation: "'Werken' (work) is a general activity verb, so use HEBBEN: 'Wij hebben gewerkt'.",
                hint: "Working is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De trein ___ om 3 uur aangekomen' (The train arrived at 3 o'clock)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Aankomen' (arrive) is movement/arrival, so use ZIJN: 'De trein is aangekomen'.",
                hint: "Arriving is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ een interessant boek gelezen' (I read an interesting book)",
                options: ["ben", "is", "heb", "had"],
                correctAnswer: 2,
                explanation: "'Lezen' (read) is a general activity with object, so use HEBBEN: 'Ik heb gelezen'.",
                hint: "Reading is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ erg ziek geworden' (He became very sick)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Worden' (become) shows change of state, so use ZIJN: 'Hij is geworden'.",
                hint: "Becoming is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ lang in de tuin gebleven' (We stayed long in the garden)",
                options: ["hebben", "zijn", "had", "was"],
                correctAnswer: 1,
                explanation: "'Blijven' (stay) is one of the specific verbs that uses ZIJN: 'Wij zijn gebleven'.",
                hint: "Blijven is a specific ZIJN verb"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ prachtig gezongen' (She sang beautifully)",
                options: ["is", "ben", "heeft", "had"],
                correctAnswer: 2,
                explanation: "'Zingen' (sing) is a general activity, so use HEBBEN: 'Zij heeft gezongen'.",
                hint: "Singing is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Het ongeluk ___ gisteren gebeurd' (The accident happened yesterday)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Gebeuren' (happen) is one of the specific verbs that uses ZIJN: 'Het is gebeurd'.",
                hint: "Gebeuren is a specific ZIJN verb"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ de hele nacht geslapen' (I slept all night)",
                options: ["ben", "is", "heb", "had"],
                correctAnswer: 2,
                explanation: "'Slapen' (sleep) is a general activity, so use HEBBEN: 'Ik heb geslapen'.",
                hint: "Sleeping is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De vogel ___ weggevlogen' (The bird flew away)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Vliegen' (fly) with direction/movement uses ZIJN: 'De vogel is weggevlogen'.",
                hint: "Flying away is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Jullie ___ een leuke film gezien' (You saw a nice movie)",
                options: ["zijn", "ben", "hebben", "had"],
                correctAnswer: 2,
                explanation: "'Zien' (see) with direct object uses HEBBEN: 'Jullie hebben gezien'.",
                hint: "Seeing with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Mijn oma ___ vorig jaar gestorven' (My grandmother died last year)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Sterven' (die) shows change of state, so use ZIJN: 'Mijn oma is gestorven'.",
                hint: "Dying is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ over het probleem gedacht' (We thought about the problem)",
                options: ["zijn", "ben", "hebben", "had"],
                correctAnswer: 2,
                explanation: "'Denken' (think) is a mental activity, so use HEBBEN: 'Wij hebben gedacht'.",
                hint: "Thinking is mental activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De kinderen ___ in het park gespeeld' (The children played in the park)",
                options: ["zijn", "ben", "hebben", "had"],
                correctAnswer: 2,
                explanation: "'Spelen' (play) is a general activity, so use HEBBEN: 'De kinderen hebben gespeeld'.",
                hint: "Playing is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ naar de bakker gelopen' (He walked to the bakery)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Lopen' (walk) to destination uses ZIJN: 'Hij is naar de bakker gelopen'.",
                hint: "Walking to destination - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ mijn vrienden geholpen' (I helped my friends)",
                options: ["ben", "is", "heb", "had"],
                correctAnswer: 2,
                explanation: "'Helpen' (help) with direct object uses HEBBEN: 'Ik heb geholpen'.",
                hint: "Helping with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Het experiment ___ mislukt' (The experiment failed)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Mislukken' (fail) is one of the specific verbs that uses ZIJN: 'Het is mislukt'.",
                hint: "Mislukken is a specific ZIJN verb"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een brief geschreven' (She wrote a letter)",
                options: ["is", "ben", "heeft", "had"],
                correctAnswer: 2,
                explanation: "'Schrijven' (write) with direct object uses HEBBEN: 'Zij heeft geschreven'.",
                hint: "Writing with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ met de auto gereden' (We drove by car)",
                options: ["zijn", "ben", "hebben", "had"],
                correctAnswer: 2,
                explanation: "'Rijden' without destination (general activity) uses HEBBEN: 'Wij hebben gereden'.",
                hint: "Driving as general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De bloemen ___ mooi gegroeid' (The flowers grew beautifully)",
                options: ["hebben", "zijn", "had", "was"],
                correctAnswer: 1,
                explanation: "'Groeien' (grow) shows change of state, so use ZIJN: 'De bloemen zijn gegroeid'.",
                hint: "Growing is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ de hele dag thuis gebleven' (I stayed home all day)",
                options: ["heb", "ben", "had", "was"],
                correctAnswer: 1,
                explanation: "'Blijven' (stay) is a specific verb that uses ZIJN: 'Ik ben gebleven'.",
                hint: "Blijven is a specific ZIJN verb"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een nieuwe baan gevonden' (He found a new job)",
                options: ["is", "ben", "heeft", "had"],
                correctAnswer: 2,
                explanation: "'Vinden' (find) with direct object uses HEBBEN: 'Hij heeft gevonden'.",
                hint: "Finding with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De kat ___ van de tafel gevallen' (The cat fell from the table)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Vallen' (fall) shows change of position/state, so use ZIJN: 'De kat is gevallen'.",
                hint: "Falling is change of position - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ samen naar de bioscoop gegaan' (We went to the cinema together)",
                options: ["hebben", "zijn", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Gaan' (go) is movement, so always use ZIJN: 'Wij zijn gegaan'.",
                hint: "Going is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een interessant boek gelezen' (He read an interesting book)",
                options: ["is", "ben", "heeft", "waren"],
                correctAnswer: 2,
                explanation: "'Lezen' (read) with direct object uses HEBBEN: 'Hij heeft gelezen'.",
                hint: "Reading with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De plant ___ snel gegroeid' (The plant grew quickly)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Groeien' (grow) shows change of state, so use ZIJN: 'De plant is gegroeid'.",
                hint: "Growing is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ de hele ochtend gestudeerd' (I studied all morning)",
                options: ["ben", "is", "heb", "waren"],
                correctAnswer: 2,
                explanation: "'Studeren' (study) is a general activity, so use HEBBEN: 'Ik heb gestudeerd'.",
                hint: "Studying is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ vroeg naar bed gegaan' (She went to bed early)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Gaan' (go) is movement, so always use ZIJN: 'Zij is gegaan'.",
                hint: "Going is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Het ___ eindelijk gelukt!' (It finally succeeded!)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Lukken' (succeed) is one of the specific verbs that uses ZIJN: 'Het is gelukt'.",
                hint: "Lukken is a specific ZIJN verb"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ lekker gegeten' (We ate well)",
                options: ["zijn", "ben", "hebben", "waren"],
                correctAnswer: 2,
                explanation: "'Eten' (eat) is a general activity, so use HEBBEN: 'Wij hebben gegeten'.",
                hint: "Eating is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De kinderen ___ naar school gelopen' (The children walked to school)",
                options: ["hebben", "zijn", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Lopen' (walk) to destination uses ZIJN: 'De kinderen zijn gelopen'.",
                hint: "Walking to destination - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ zijn moeder gebeld' (He called his mother)",
                options: ["is", "ben", "heeft", "waren"],
                correctAnswer: 2,
                explanation: "'Bellen' (call) with direct object uses HEBBEN: 'Hij heeft gebeld'.",
                hint: "Calling with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De bloem ___ mooi gebloeied' (The flower bloomed beautifully)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Bloeien' (bloom) shows change of state, so use ZIJN: 'De bloem is gebloeied'.",
                hint: "Blooming is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ de hele dag gewerkt' (I worked all day)",
                options: ["ben", "is", "heb", "waren"],
                correctAnswer: 2,
                explanation: "'Werken' (work) is a general activity, so use HEBBEN: 'Ik heb gewerkt'.",
                hint: "Working is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ naar Frankrijk verhuisd' (She moved to France)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Verhuizen' (move house) is movement/change, so use ZIJN: 'Zij is verhuisd'.",
                hint: "Moving house is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ een cadeau gekocht' (We bought a gift)",
                options: ["zijn", "ben", "hebben", "waren"],
                correctAnswer: 2,
                explanation: "'Kopen' (buy) with direct object uses HEBBEN: 'Wij hebben gekocht'.",
                hint: "Buying with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De hond ___ weggerend' (The dog ran away)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Rennen' (run) with direction uses ZIJN: 'De hond is weggerend'.",
                hint: "Running away is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ lang geslapen' (He slept for a long time)",
                options: ["is", "ben", "heeft", "waren"],
                correctAnswer: 2,
                explanation: "'Slapen' (sleep) is a general activity, so use HEBBEN: 'Hij heeft geslapen'.",
                hint: "Sleeping is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Het meisje ___ groot geworden' (The girl became big)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Worden' (become) shows change of state, so use ZIJN: 'Het meisje is geworden'.",
                hint: "Becoming is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ een e-mail verstuurd' (I sent an email)",
                options: ["ben", "is", "heb", "waren"],
                correctAnswer: 2,
                explanation: "'Versturen' (send) with direct object uses HEBBEN: 'Ik heb verstuurd'.",
                hint: "Sending with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ naar Amsterdam gekomen' (She came to Amsterdam)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Komen' (come) is movement, so use ZIJN: 'Zij is gekomen'.",
                hint: "Coming is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ de film gezien' (We saw the movie)",
                options: ["zijn", "ben", "hebben", "waren"],
                correctAnswer: 2,
                explanation: "'Zien' (see) with direct object uses HEBBEN: 'Wij hebben gezien'.",
                hint: "Seeing with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De vogel ___ uit het nest gevallen' (The bird fell out of the nest)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Vallen' (fall) shows change of position, so use ZIJN: 'De vogel is gevallen'.",
                hint: "Falling is change of position - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ hard gelopen' (He ran hard)",
                options: ["is", "ben", "heeft", "waren"],
                correctAnswer: 2,
                explanation: "'Lopen' (run) without destination (general activity) uses HEBBEN: 'Hij heeft gelopen'.",
                hint: "Running as general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ mijn sleutels verloren' (I lost my keys)",
                options: ["ben", "is", "heb", "waren"],
                correctAnswer: 2,
                explanation: "'Verliezen' (lose) with direct object uses HEBBEN: 'Ik heb verloren'.",
                hint: "Losing with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De zon ___ ondergegaan' (The sun set)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Ondergaan' (set/go down) is movement, so use ZIJN: 'De zon is ondergegaan'.",
                hint: "Setting/going down is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ muziek geluisterd' (We listened to music)",
                options: ["zijn", "ben", "hebben", "waren"],
                correctAnswer: 2,
                explanation: "'Luisteren' (listen) is a general activity, so use HEBBEN: 'Wij hebben geluisterd'.",
                hint: "Listening is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Het kind ___ in slaap gevallen' (The child fell asleep)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'In slaap vallen' (fall asleep) shows change of state, so use ZIJN: 'Het kind is gevallen'.",
                hint: "Falling asleep is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een verhaal verteld' (He told a story)",
                options: ["is", "ben", "heeft", "waren"],
                correctAnswer: 2,
                explanation: "'Vertellen' (tell) with direct object uses HEBBEN: 'Hij heeft verteld'.",
                hint: "Telling with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ naar de winkel gefietst' (She cycled to the store)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Fietsen' (cycle) to destination uses ZIJN: 'Zij is gefietst'.",
                hint: "Cycling to destination - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ een boek geschreven' (I wrote a book)",
                options: ["ben", "is", "heb", "waren"],
                correctAnswer: 2,
                explanation: "'Schrijven' (write) with direct object uses HEBBEN: 'Ik heb geschreven'.",
                hint: "Writing with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De baby ___ geboren' (The baby was born)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Geboren worden' (be born) shows change of state, so use ZIJN: 'De baby is geboren'.",
                hint: "Being born is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ de hele middag gepraat' (We talked all afternoon)",
                options: ["zijn", "ben", "hebben", "waren"],
                correctAnswer: 2,
                explanation: "'Praten' (talk) is a general activity, so use HEBBEN: 'Wij hebben gepraat'.",
                hint: "Talking is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ uit het raam gesprongen' (He jumped out of the window)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Springen' (jump) with movement uses ZIJN: 'Hij is gesprongen'.",
                hint: "Jumping with movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ een foto gemaakt' (I took a photo)",
                options: ["ben", "is", "heb", "waren"],
                correctAnswer: 2,
                explanation: "'Maken' (make) with direct object uses HEBBEN: 'Ik heb gemaakt'.",
                hint: "Making with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De trein ___ vertrokken' (The train departed)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Vertrekken' (depart) is movement, so use ZIJN: 'De trein is vertrokken'.",
                hint: "Departing is movement - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ Nederlands geleerd' (She learned Dutch)",
                options: ["is", "ben", "heeft", "waren"],
                correctAnswer: 2,
                explanation: "'Leren' (learn) with direct object uses HEBBEN: 'Zij heeft geleerd'.",
                hint: "Learning with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Het water ___ bevroren' (The water froze)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Bevriezen' (freeze) shows change of state, so use ZIJN: 'Het water is bevroren'.",
                hint: "Freezing is change of state - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ samen gedanst' (We danced together)",
                options: ["zijn", "ben", "hebben", "waren"],
                correctAnswer: 2,
                explanation: "'Dansen' (dance) is a general activity, so use HEBBEN: 'Wij hebben gedanst'.",
                hint: "Dancing is general activity - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ naar huis gerend' (He ran home)",
                options: ["heeft", "is", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Rennen' (run) to destination uses ZIJN: 'Hij is gerend'.",
                hint: "Running to destination - use ZIJN"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ een brief ontvangen' (I received a letter)",
                options: ["ben", "is", "heb", "waren"],
                correctAnswer: 2,
                explanation: "'Ontvangen' (receive) with direct object uses HEBBEN: 'Ik heb ontvangen'.",
                hint: "Receiving with object - use HEBBEN"
            ),
            GrammarExercise(
                question: "Complete: 'De bloemen ___ verwelkt' (The flowers wilted)",
                options: ["hebben", "zijn", "had", "waren"],
                correctAnswer: 1,
                explanation: "'Verwelken' (wilt) shows change of state, so use ZIJN: 'De bloemen zijn verwelkt'.",
                hint: "Wilting is change of state - use ZIJN"
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
            GrammarExercise(
                question: "Complete: 'Ik ___ haast, ik moet naar werk' (I'm in a hurry)",
                options: ["ben", "heb", "krijg", "maak"],
                correctAnswer: 1,
                explanation: "'Haast hebben' = be in a hurry. In Dutch you HAVE hurry, not ARE hurry.",
                hint: "In Dutch you HAVE hurry"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een belangrijke beslissing' (She makes an important decision)",
                options: ["maakt", "neemt", "heeft", "krijgt"],
                correctAnswer: 1,
                explanation: "'Een beslissing nemen' = make a decision. Use 'nemen' (take), not 'maken' (make).",
                hint: "In Dutch you TAKE a decision"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ honger na het sporten' (He gets hungry after sports)",
                options: ["heeft", "krijgt", "wordt", "maakt"],
                correctAnswer: 1,
                explanation: "'Honger krijgen' = get hungry. 'Honger hebben' = be hungry. Here he GETS hungry.",
                hint: "He becomes hungry - think about change"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ een afspraak met de dokter' (We make an appointment with the doctor)",
                options: ["nemen", "maken", "hebben", "krijgen"],
                correctAnswer: 1,
                explanation: "'Een afspraak maken' = make an appointment. Use 'maken', not 'nemen'.",
                hint: "You CREATE an appointment"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ pijn in mijn rug' (I have pain in my back)",
                options: ["ben", "heb", "krijg", "word"],
                correctAnswer: 1,
                explanation: "'Pijn hebben' = have pain/be in pain. In Dutch you HAVE pain.",
                hint: "In Dutch you HAVE pain"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ ziek en kan niet komen' (She is sick and can't come)",
                options: ["heeft", "krijgt", "is", "wordt"],
                correctAnswer: 2,
                explanation: "'Ziek zijn' = be sick. This is a state, so use 'zijn'.",
                hint: "This describes her current state"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ zijn rijbewijs vorige maand' (He got his driver's license last month)",
                options: ["kreeg", "haalde", "nam", "maakte"],
                correctAnswer: 1,
                explanation: "'Je rijbewijs halen' = get your driver's license. Use 'halen' (fetch/get).",
                hint: "You fetch/obtain your license"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ problemen met de computer' (We're having problems with the computer)",
                options: ["maken", "hebben", "krijgen", "zijn"],
                correctAnswer: 1,
                explanation: "'Problemen hebben' = have problems. You HAVE problems, not make them (unless you cause them).",
                hint: "You experience problems"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ geluk met het weer' (I'm lucky with the weather)",
                options: ["ben", "heb", "krijg", "maak"],
                correctAnswer: 1,
                explanation: "'Geluk hebben' = be lucky. In Dutch you HAVE luck.",
                hint: "In Dutch you HAVE luck"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ in dienst bij een groot bedrijf' (He starts working at a big company)",
                options: ["gaat", "komt", "wordt", "is"],
                correctAnswer: 1,
                explanation: "'In dienst komen' = start working/join a company. Use 'komen' (come).",
                hint: "You come into service"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een baan als lerares' (She got a job as a teacher)",
                options: ["heeft", "kreeg", "nam", "maakte"],
                correctAnswer: 1,
                explanation: "'Een baan krijgen' = get a job. Past tense: 'kreeg'.",
                hint: "You receive a job"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ lid van de sportclub' (We are members of the sports club)",
                options: ["hebben", "zijn", "worden", "krijgen"],
                correctAnswer: 1,
                explanation: "'Lid zijn van' = be a member of. Use 'zijn' for membership status.",
                hint: "This describes membership status"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ het koud buiten' (I'm getting cold outside)",
                options: ["heb", "krijg", "ben", "word"],
                correctAnswer: 1,
                explanation: "'Het koud krijgen' = get cold. You GET cold (change of state).",
                hint: "You become cold - think about change"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ antwoord op zijn vraag' (He gives an answer to his question)",
                options: ["geeft", "heeft", "maakt", "neemt"],
                correctAnswer: 0,
                explanation: "'Antwoord geven' = give an answer. Use 'geven' (give).",
                hint: "You provide an answer"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ stage bij een ziekenhuis' (She does an internship at a hospital)",
                options: ["doet", "loopt", "heeft", "gaat"],
                correctAnswer: 1,
                explanation: "'Stage lopen' = do an internship. Use 'lopen' (walk/run), not 'doen'.",
                hint: "In Dutch you 'walk' an internship"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ een opleiding tot verpleegkundige' (I'm doing training to become a nurse)",
                options: ["doe", "volg", "heb", "krijg"],
                correctAnswer: 1,
                explanation: "'Een opleiding volgen' = follow/do training. Use 'volgen' (follow).",
                hint: "You follow a course of training"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ een fout in zijn huiswerk' (He made a mistake in his homework)",
                options: ["maakte", "nam", "had", "kreeg"],
                correctAnswer: 0,
                explanation: "'Een fout maken' = make a mistake. Past tense: 'maakte'.",
                hint: "You create a mistake"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ een idee voor het feest' (We have an idea for the party)",
                options: ["zijn", "hebben", "krijgen", "maken"],
                correctAnswer: 1,
                explanation: "'Een idee hebben' = have an idea. Use 'hebben' (have).",
                hint: "You possess an idea"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ een kind vorig jaar' (She had a baby last year)",
                options: ["had", "kreeg", "nam", "maakte"],
                correctAnswer: 1,
                explanation: "'Een kind krijgen' = have a baby. Past tense: 'kreeg'.",
                hint: "You receive a baby"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ naar huis na het werk' (I go home after work)",
                options: ["kom", "ga", "ben", "loop"],
                correctAnswer: 1,
                explanation: "'Naar huis gaan' = go home. Use 'gaan' (go) with direction.",
                hint: "You move toward home"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ het warm in de zon' (He's getting warm in the sun)",
                options: ["heeft", "krijgt", "is", "wordt"],
                correctAnswer: 1,
                explanation: "'Het warm krijgen' = get warm. You GET warm (change of state).",
                hint: "You become warm - think about change"
            ),
            GrammarExercise(
                question: "Complete: 'Wij ___ dorst van het rennen' (We get thirsty from running)",
                options: ["hebben", "krijgen", "zijn", "worden"],
                correctAnswer: 1,
                explanation: "'Dorst krijgen' = get thirsty. You GET thirsty (change of state).",
                hint: "You become thirsty - think about change"
            ),
            GrammarExercise(
                question: "Complete: 'Zij ___ gelijk met haar mening' (She is right with her opinion)",
                options: ["heeft", "is", "krijgt", "maakt"],
                correctAnswer: 0,
                explanation: "'Gelijk hebben' = be right. In Dutch you HAVE right, not ARE right.",
                hint: "In Dutch you HAVE right"
            ),
            GrammarExercise(
                question: "Complete: 'Ik ___ ongelijk over die kwestie' (I was wrong about that issue)",
                options: ["had", "was", "kreeg", "maakte"],
                correctAnswer: 0,
                explanation: "'Ongelijk hebben' = be wrong. In Dutch you HAVE wrong, not ARE wrong.",
                hint: "In Dutch you HAVE wrong"
            ),
            GrammarExercise(
                question: "Complete: 'Hij ___ zin in een ijsje' (He feels like having ice cream)",
                options: ["heeft", "is", "krijgt", "maakt"],
                correctAnswer: 0,
                explanation: "'Zin hebben in' = feel like having. In Dutch you HAVE desire for something.",
                hint: "In Dutch you HAVE desire"
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
    
    // MARK: - All Grammar Rules Array
    
    lazy var allGrammarRules: [DutchGrammarRule] = [
        // A1 Level
        presentTenseA1,
        irregularVerbsA1,
        basicWordOrderA1,
        dutchArticlesA1,
        
        // A2 Level  
        pastTenseA2,
        questionWordOrderA2,
        pluralizationA2,
        adjectivesA2,
        negationA2,
        possessivesA2,
        demonstrativesA2,
        
        // B1 Level
        verbsWithFixedPrepositionsB1,
        infinitiveConstructionsB1,
        auxiliaryVerbsB1,
        fixedWordCombinationsB1,
        tKofschipRuleB1
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