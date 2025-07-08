import Foundation

struct VocabularyItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let dutchWord: String
    let translation: String
    
    init(dutchWord: String, translation: String) {
        self.dutchWord = dutchWord
        self.translation = translation
    }
}

struct Lesson: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let vocabulary: [VocabularyItem] // Dutch words with translations, linked to user's flashcards
    let exercises: [Exercise]
}

struct Exercise: Identifiable, Codable, Hashable {
    enum ExerciseType: String, Codable, Hashable {
        case fillInBlank
        case missingWord
        case matchMeaning
        case useInSentence
        case sentenceBuilding
    }
    let id: UUID
    let type: ExerciseType
    let prompt: String
    let options: [String]
    let correctAnswer: String
    let explanation: String
    let vocabularyReference: String? // Link to main vocab by word
    
    init(type: ExerciseType, prompt: String, options: [String], correctAnswer: String, explanation: String, vocabularyReference: String? = nil) {
        self.id = UUID()
        self.type = type
        self.prompt = prompt
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.vocabularyReference = vocabularyReference
    }
}

extension Lesson {
    static let chapter31: Lesson = Lesson(
        id: UUID(),
        title: "Chapter 3.1 – Everyday Vocabulary",
        description: """
Practice Dutch vocabulary for everyday situations, objects, and activities. Learn words for common items, actions, and descriptive terms used in daily life.
""",
        vocabulary: [
            VocabularyItem(dutchWord: "bedrag", translation: "amount"),
            VocabularyItem(dutchWord: "bijeenkomst", translation: "meeting"),
            VocabularyItem(dutchWord: "blad", translation: "leaf"),
            VocabularyItem(dutchWord: "dak", translation: "roof"),
            VocabularyItem(dutchWord: "eigenlijk", translation: "actually"),
            VocabularyItem(dutchWord: "geschikt", translation: "suitable"),
            VocabularyItem(dutchWord: "getuige", translation: "witness"),
            VocabularyItem(dutchWord: "gezamenlijk", translation: "together"),
            VocabularyItem(dutchWord: "inbreken", translation: "commit burglary"),
            VocabularyItem(dutchWord: "kruiwagen", translation: "wheelbarrow"),
            VocabularyItem(dutchWord: "lantaarnpaal", translation: "lamppost"),
            VocabularyItem(dutchWord: "mededeling", translation: "announcement"),
            VocabularyItem(dutchWord: "meedoen", translation: "join"),
            VocabularyItem(dutchWord: "nuttig", translation: "useful"),
            VocabularyItem(dutchWord: "ongerust", translation: "worried"),
            VocabularyItem(dutchWord: "overkant", translation: "across the street"),
            VocabularyItem(dutchWord: "slachtoffer", translation: "victim"),
            VocabularyItem(dutchWord: "verslag", translation: "report"),
            VocabularyItem(dutchWord: "zijkant", translation: "side"),
            VocabularyItem(dutchWord: "zomaar", translation: "out of the blue, suddenly")
        ],
        exercises: [
            // --- Sentence Building Exercises ---
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Het", "bedrag", "is", "te", "hoog"],
                correctAnswer: "Het bedrag is te hoog",
                explanation: "'Het bedrag is te hoog' means 'The amount is too high'. 'Bedrag' means 'amount'.",
                vocabularyReference: "bedrag"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["We", "hebben", "een", "bijeenkomst", "gehouden"],
                correctAnswer: "We hebben een bijeenkomst gehouden",
                explanation: "'We hebben een bijeenkomst gehouden' means 'We held a meeting'. 'Bijeenkomst' means 'meeting'.",
                vocabularyReference: "bijeenkomst"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Het", "blad", "valt", "van", "de", "boom"],
                correctAnswer: "Het blad valt van de boom",
                explanation: "'Het blad valt van de boom' means 'The leaf falls from the tree'. 'Blad' means 'leaf'.",
                vocabularyReference: "blad"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Het", "dak", "is", "kapot"],
                correctAnswer: "Het dak is kapot",
                explanation: "'Het dak is kapot' means 'The roof is broken'. 'Dak' means 'roof'.",
                vocabularyReference: "dak"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "ben", "eigenlijk", "niet", "thuis"],
                correctAnswer: "Ik ben eigenlijk niet thuis",
                explanation: "'Ik ben eigenlijk niet thuis' means 'I am actually not home'. 'Eigenlijk' means 'actually'.",
                vocabularyReference: "eigenlijk"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Deze", "schoenen", "zijn", "geschikt", "voor", "wandelen"],
                correctAnswer: "Deze schoenen zijn geschikt voor wandelen",
                explanation: "'Deze schoenen zijn geschikt voor wandelen' means 'These shoes are suitable for walking'. 'Geschikt' means 'suitable'.",
                vocabularyReference: "geschikt"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "getuige", "zag", "alles", "gebeuren"],
                correctAnswer: "De getuige zag alles gebeuren",
                explanation: "'De getuige zag alles gebeuren' means 'The witness saw everything happen'. 'Getuige' means 'witness'.",
                vocabularyReference: "getuige"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["We", "werken", "gezamenlijk", "aan", "het", "project"],
                correctAnswer: "We werken gezamenlijk aan het project",
                explanation: "'We werken gezamenlijk aan het project' means 'We work together on the project'. 'Gezamenlijk' means 'together'.",
                vocabularyReference: "gezamenlijk"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Iemand", "probeerde", "in", "te", "breken"],
                correctAnswer: "Iemand probeerde in te breken",
                explanation: "'Iemand probeerde in te breken' means 'Someone tried to break in'. 'Inbreken' means 'to commit burglary'.",
                vocabularyReference: "inbreken"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "kruiwagen", "staat", "in", "de", "tuin"],
                correctAnswer: "De kruiwagen staat in de tuin",
                explanation: "'De kruiwagen staat in de tuin' means 'The wheelbarrow is in the garden'. 'Kruiwagen' means 'wheelbarrow'.",
                vocabularyReference: "kruiwagen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "lantaarnpaal", "geeft", "licht"],
                correctAnswer: "De lantaarnpaal geeft licht",
                explanation: "'De lantaarnpaal geeft licht' means 'The lamppost gives light'. 'Lantaarnpaal' means 'lamppost'.",
                vocabularyReference: "lantaarnpaal"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Er", "is", "een", "belangrijke", "mededeling"],
                correctAnswer: "Er is een belangrijke mededeling",
                explanation: "'Er is een belangrijke mededeling' means 'There is an important announcement'. 'Mededeling' means 'announcement'.",
                vocabularyReference: "mededeling"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Wil", "je", "meedoen", "met", "het", "spel"],
                correctAnswer: "Wil je meedoen met het spel",
                explanation: "'Wil je meedoen met het spel' means 'Do you want to join the game'. 'Meedoen' means 'to join'.",
                vocabularyReference: "meedoen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Dit", "gereedschap", "is", "heel", "nuttig"],
                correctAnswer: "Dit gereedschap is heel nuttig",
                explanation: "'Dit gereedschap is heel nuttig' means 'This tool is very useful'. 'Nuttig' means 'useful'.",
                vocabularyReference: "nuttig"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "ben", "ongerust", "om", "de", "kinderen"],
                correctAnswer: "Ik ben ongerust om de kinderen",
                explanation: "'Ik ben ongerust om de kinderen' means 'I am worried about the children'. 'Ongerust' means 'worried'.",
                vocabularyReference: "ongerust"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Hij", "woont", "aan", "de", "overkant"],
                correctAnswer: "Hij woont aan de overkant",
                explanation: "'Hij woont aan de overkant' means 'He lives across the street'. 'Overkant' means 'across the street'.",
                vocabularyReference: "overkant"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Het", "slachtoffer", "is", "naar", "het", "ziekenhuis"],
                correctAnswer: "Het slachtoffer is naar het ziekenhuis",
                explanation: "'Het slachtoffer is naar het ziekenhuis' means 'The victim went to the hospital'. 'Slachtoffer' means 'victim'.",
                vocabularyReference: "slachtoffer"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "schrijf", "een", "verslag", "over", "het", "ongeluk"],
                correctAnswer: "Ik schrijf een verslag over het ongeluk",
                explanation: "'Ik schrijf een verslag over het ongeluk' means 'I am writing a report about the accident'. 'Verslag' means 'report'.",
                vocabularyReference: "verslag"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "deur", "is", "aan", "de", "zijkant"],
                correctAnswer: "De deur is aan de zijkant",
                explanation: "'De deur is aan de zijkant' means 'The door is on the side'. 'Zijkant' means 'side'.",
                vocabularyReference: "zijkant"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Hij", "verscheen", "zomaar", "bij", "de", "deur"],
                correctAnswer: "Hij verscheen zomaar bij de deur",
                explanation: "'Hij verscheen zomaar bij de deur' means 'He appeared suddenly at the door'. 'Zomaar' means 'suddenly' or 'out of the blue'.",
                vocabularyReference: "zomaar"
            ),
            // --- Match Meaning Exercises ---
            Exercise(
                type: .matchMeaning,
                prompt: "Match: bedrag",
                options: ["amount", "meeting", "leaf"],
                correctAnswer: "amount",
                explanation: "'Bedrag' means 'amount'.",
                vocabularyReference: "bedrag"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: bijeenkomst",
                options: ["meeting", "roof", "witness"],
                correctAnswer: "meeting",
                explanation: "'Bijeenkomst' means 'meeting'.",
                vocabularyReference: "bijeenkomst"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: eigenlijk",
                options: ["actually", "suitable", "together"],
                correctAnswer: "actually",
                explanation: "'Eigenlijk' means 'actually'.",
                vocabularyReference: "eigenlijk"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: geschikt",
                options: ["suitable", "witness", "useful"],
                correctAnswer: "suitable",
                explanation: "'Geschikt' means 'suitable'.",
                vocabularyReference: "geschikt"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: nuttig",
                options: ["useful", "worried", "victim"],
                correctAnswer: "useful",
                explanation: "'Nuttig' means 'useful'.",
                vocabularyReference: "nuttig"
            ),
            // --- Fill in Blank Exercises ---
            Exercise(
                type: .fillInBlank,
                prompt: "Het ___ van de rekening is €50.",
                options: ["bedrag", "blad", "dak"],
                correctAnswer: "bedrag",
                explanation: "'Bedrag' means 'amount'. Het bedrag van de rekening is €50. (The amount of the bill is €50.)",
                vocabularyReference: "bedrag"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "We hebben een ___ gepland voor morgen.",
                options: ["bijeenkomst", "kruiwagen", "lantaarnpaal"],
                correctAnswer: "bijeenkomst",
                explanation: "'Bijeenkomst' means 'meeting'. We hebben een bijeenkomst gepland voor morgen. (We have a meeting planned for tomorrow.)",
                vocabularyReference: "bijeenkomst"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Het ___ van het huis is lek.",
                options: ["dak", "blad", "zijkant"],
                correctAnswer: "dak",
                explanation: "'Dak' means 'roof'. Het dak van het huis is lek. (The roof of the house is leaking.)",
                vocabularyReference: "dak"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik ben ___ niet zo goed in wiskunde.",
                options: ["eigenlijk", "gezamenlijk", "zomaar"],
                correctAnswer: "eigenlijk",
                explanation: "'Eigenlijk' means 'actually'. Ik ben eigenlijk niet zo goed in wiskunde. (I am actually not so good at math.)",
                vocabularyReference: "eigenlijk"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Deze schoenen zijn ___ voor hardlopen.",
                options: ["geschikt", "nuttig", "ongerust"],
                correctAnswer: "geschikt",
                explanation: "'Geschikt' means 'suitable'. Deze schoenen zijn geschikt voor hardlopen. (These shoes are suitable for running.)",
                vocabularyReference: "geschikt"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ___ zag het ongeluk gebeuren.",
                options: ["getuige", "slachtoffer", "verslag"],
                correctAnswer: "getuige",
                explanation: "'Getuige' means 'witness'. De getuige zag het ongeluk gebeuren. (The witness saw the accident happen.)",
                vocabularyReference: "getuige"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "We werken ___ aan dit project.",
                options: ["gezamenlijk", "meedoen", "zomaar"],
                correctAnswer: "gezamenlijk",
                explanation: "'Gezamenlijk' means 'together'. We werken gezamenlijk aan dit project. (We work together on this project.)",
                vocabularyReference: "gezamenlijk"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Iemand probeerde ___ in het huis.",
                options: ["in te breken", "meedoen", "ongerust"],
                correctAnswer: "in te breken",
                explanation: "'Inbreken' means 'to commit burglary'. Iemand probeerde in te breken in het huis. (Someone tried to break into the house.)",
                vocabularyReference: "inbreken"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ___ staat in de schuur.",
                options: ["kruiwagen", "lantaarnpaal", "zijkant"],
                correctAnswer: "kruiwagen",
                explanation: "'Kruiwagen' means 'wheelbarrow'. De kruiwagen staat in de schuur. (The wheelbarrow is in the shed.)",
                vocabularyReference: "kruiwagen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ___ geeft licht in de straat.",
                options: ["lantaarnpaal", "mededeling", "verslag"],
                correctAnswer: "lantaarnpaal",
                explanation: "'Lantaarnpaal' means 'lamppost'. De lantaarnpaal geeft licht in de straat. (The lamppost gives light in the street.)",
                vocabularyReference: "lantaarnpaal"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Er is een belangrijke ___ op het bord.",
                options: ["mededeling", "verslag", "bijeenkomst"],
                correctAnswer: "mededeling",
                explanation: "'Mededeling' means 'announcement'. Er is een belangrijke mededeling op het bord. (There is an important announcement on the board.)",
                vocabularyReference: "mededeling"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Wil je ___ met het spel?",
                options: ["meedoen", "gezamenlijk", "zomaar"],
                correctAnswer: "meedoen",
                explanation: "'Meedoen' means 'to join'. Wil je meedoen met het spel? (Do you want to join the game?)",
                vocabularyReference: "meedoen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Dit boek is heel ___ voor mijn studie.",
                options: ["nuttig", "geschikt", "eigenlijk"],
                correctAnswer: "nuttig",
                explanation: "'Nuttig' means 'useful'. Dit boek is heel nuttig voor mijn studie. (This book is very useful for my studies.)",
                vocabularyReference: "nuttig"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik ben ___ om mijn hond.",
                options: ["ongerust", "nuttig", "geschikt"],
                correctAnswer: "ongerust",
                explanation: "'Ongerust' means 'worried'. Ik ben ongerust om mijn hond. (I am worried about my dog.)",
                vocabularyReference: "ongerust"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Hij woont aan de ___ van de straat.",
                options: ["overkant", "zijkant", "dak"],
                correctAnswer: "overkant",
                explanation: "'Overkant' means 'across the street'. Hij woont aan de overkant van de straat. (He lives across the street.)",
                vocabularyReference: "overkant"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Het ___ van het ongeluk is in het ziekenhuis.",
                options: ["slachtoffer", "getuige", "verslag"],
                correctAnswer: "slachtoffer",
                explanation: "'Slachtoffer' means 'victim'. Het slachtoffer van het ongeluk is in het ziekenhuis. (The victim of the accident is in the hospital.)",
                vocabularyReference: "slachtoffer"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik schrijf een ___ over de vergadering.",
                options: ["verslag", "mededeling", "bijeenkomst"],
                correctAnswer: "verslag",
                explanation: "'Verslag' means 'report'. Ik schrijf een verslag over de vergadering. (I am writing a report about the meeting.)",
                vocabularyReference: "verslag"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ingang is aan de ___ van het gebouw.",
                options: ["zijkant", "overkant", "dak"],
                correctAnswer: "zijkant",
                explanation: "'Zijkant' means 'side'. De ingang is aan de zijkant van het gebouw. (The entrance is on the side of the building.)",
                vocabularyReference: "zijkant"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Hij verscheen ___ bij de deur.",
                options: ["zomaar", "eigenlijk", "gezamenlijk"],
                correctAnswer: "zomaar",
                explanation: "'Zomaar' means 'suddenly' or 'out of the blue'. Hij verscheen zomaar bij de deur. (He appeared suddenly at the door.)",
                vocabularyReference: "zomaar"
            ),
            // --- Use in Sentence Exercises ---
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'bedrag':",
                options: [
                    "Het bedrag is te hoog.",
                    "Het bedrag valt van de boom.",
                    "Het bedrag is kapot."
                ],
                correctAnswer: "Het bedrag is te hoog.",
                explanation: "'Bedrag' means 'amount'. Het bedrag is te hoog. (The amount is too high.)",
                vocabularyReference: "bedrag"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'eigenlijk':",
                options: [
                    "Ik ben eigenlijk niet thuis.",
                    "Deze schoenen zijn eigenlijk voor wandelen.",
                    "We werken eigenlijk aan het project."
                ],
                correctAnswer: "Ik ben eigenlijk niet thuis.",
                explanation: "'Eigenlijk' means 'actually'. Ik ben eigenlijk niet thuis. (I am actually not home.)",
                vocabularyReference: "eigenlijk"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'geschikt':",
                options: [
                    "Deze schoenen zijn geschikt voor wandelen.",
                    "Ik ben geschikt om de kinderen.",
                    "We werken geschikt aan het project."
                ],
                correctAnswer: "Deze schoenen zijn geschikt voor wandelen.",
                explanation: "'Geschikt' means 'suitable'. Deze schoenen zijn geschikt voor wandelen. (These shoes are suitable for walking.)",
                vocabularyReference: "geschikt"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'nuttig':",
                options: [
                    "Dit gereedschap is heel nuttig.",
                    "Ik ben nuttig om de kinderen.",
                    "We werken nuttig aan het project."
                ],
                correctAnswer: "Dit gereedschap is heel nuttig.",
                explanation: "'Nuttig' means 'useful'. Dit gereedschap is heel nuttig. (This tool is very useful.)",
                vocabularyReference: "nuttig"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'zomaar':",
                options: [
                    "Hij verscheen zomaar bij de deur.",
                    "We werken zomaar aan het project.",
                    "Deze schoenen zijn zomaar voor wandelen."
                ],
                correctAnswer: "Hij verscheen zomaar bij de deur.",
                explanation: "'Zomaar' means 'suddenly' or 'out of the blue'. Hij verscheen zomaar bij de deur. (He appeared suddenly at the door.)",
                vocabularyReference: "zomaar"
            ),
            // --- Missing Word Exercises ---
            Exercise(
                type: .missingWord,
                prompt: "Het ___ van de rekening is €50.",
                options: ["bedrag", "blad", "dak"],
                correctAnswer: "bedrag",
                explanation: "'Bedrag' means 'amount'. Het bedrag van de rekening is €50. (The amount of the bill is €50.)",
                vocabularyReference: "bedrag"
            ),
            Exercise(
                type: .missingWord,
                prompt: "We hebben een ___ gepland.",
                options: ["bijeenkomst", "kruiwagen", "lantaarnpaal"],
                correctAnswer: "bijeenkomst",
                explanation: "'Bijeenkomst' means 'meeting'. We hebben een bijeenkomst gepland. (We have a meeting planned.)",
                vocabularyReference: "bijeenkomst"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Het ___ van het huis is lek.",
                options: ["dak", "blad", "zijkant"],
                correctAnswer: "dak",
                explanation: "'Dak' means 'roof'. Het dak van het huis is lek. (The roof of the house is leaking.)",
                vocabularyReference: "dak"
            ),
            Exercise(
                type: .missingWord,
                prompt: "De ___ zag het ongeluk gebeuren.",
                options: ["getuige", "slachtoffer", "verslag"],
                correctAnswer: "getuige",
                explanation: "'Getuige' means 'witness'. De getuige zag het ongeluk gebeuren. (The witness saw the accident happen.)",
                vocabularyReference: "getuige"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Het ___ van het ongeluk is in het ziekenhuis.",
                options: ["slachtoffer", "getuige", "verslag"],
                correctAnswer: "slachtoffer",
                explanation: "'Slachtoffer' means 'victim'. Het slachtoffer van het ongeluk is in het ziekenhuis. (The victim of the accident is in the hospital.)",
                vocabularyReference: "slachtoffer"
            )
        ]
    )

    static let chapter33: Lesson = Lesson(
        id: UUID(),
        title: "Chapter 3.3 – Meeting and Maintenance Vocabulary",
        description: """
Practice Dutch vocabulary related to meetings, registration, and maintenance tasks. Learn words for chairing meetings, keeping things clean, and administrative tasks.
""",
        vocabulary: [
            VocabularyItem(dutchWord: "aanmelden", translation: "to register"),
            VocabularyItem(dutchWord: "achteraf", translation: "afterwards / later / in hindsight"),
            VocabularyItem(dutchWord: "afmelden", translation: "log out"),
            VocabularyItem(dutchWord: "bespreken", translation: "to discuss / to talk about / to review"),
            VocabularyItem(dutchWord: "dweil", translation: "mop"),
            VocabularyItem(dutchWord: "klusser", translation: "handyman"),
            VocabularyItem(dutchWord: "notulen", translation: "meeting minutes"),
            VocabularyItem(dutchWord: "rondvraag", translation: "open floor discussion"),
            VocabularyItem(dutchWord: "schoonhouden", translation: "to keep clean"),
            VocabularyItem(dutchWord: "vooraf", translation: "beforehand / in advance / ahead of time"),
            VocabularyItem(dutchWord: "voorzitten", translation: "to chair / to preside over"),
            VocabularyItem(dutchWord: "vuilniszakken", translation: "garbage bags / trash bags"),
            VocabularyItem(dutchWord: "waarschuwen", translation: "to warn")
        ],
        exercises: [
            // --- Sentence Building Exercises ---
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "moet", "me", "aanmelden", "voor", "de", "cursus"],
                correctAnswer: "Ik moet me aanmelden voor de cursus",
                explanation: "'Ik moet me aanmelden voor de cursus' means 'I have to register for the course'. 'Aanmelden' means 'to register'.",
                vocabularyReference: "aanmelden"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["We", "bespreken", "dit", "tijdens", "de", "vergadering"],
                correctAnswer: "We bespreken dit tijdens de vergadering",
                explanation: "'We bespreken dit tijdens de vergadering' means 'We will discuss this during the meeting'. 'Bespreken' means 'to discuss'.",
                vocabularyReference: "bespreken"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "klusser", "komt", "morgen", "langs"],
                correctAnswer: "De klusser komt morgen langs",
                explanation: "'De klusser komt morgen langs' means 'The handyman is coming tomorrow'. 'Klusser' means 'handyman'.",
                vocabularyReference: "klusser"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "moet", "de", "kamer", "schoonhouden"],
                correctAnswer: "Ik moet de kamer schoonhouden",
                explanation: "'Ik moet de kamer schoonhouden' means 'I have to keep the room clean'. 'Schoonhouden' means 'to keep clean'.",
                vocabularyReference: "schoonhouden"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Zij", "voorzit", "de", "vergadering"],
                correctAnswer: "Zij voorzit de vergadering",
                explanation: "'Zij voorzit de vergadering' means 'She chairs the meeting'. 'Voorzitten' means 'to chair' or 'to preside over'.",
                vocabularyReference: "voorzitten"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "waarschuw", "je", "vooraf"],
                correctAnswer: "Ik waarschuw je vooraf",
                explanation: "'Ik waarschuw je vooraf' means 'I warn you beforehand'. 'Waarschuwen' means 'to warn' and 'vooraf' means 'beforehand'.",
                vocabularyReference: "waarschuwen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "notulen", "worden", "opgeschreven"],
                correctAnswer: "De notulen worden opgeschreven",
                explanation: "'De notulen worden opgeschreven' means 'The meeting minutes are being written down'. 'Notulen' means 'meeting minutes'.",
                vocabularyReference: "notulen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["We", "hebben", "een", "rondvraag", "gehouden"],
                correctAnswer: "We hebben een rondvraag gehouden",
                explanation: "'We hebben een rondvraag gehouden' means 'We held an open floor discussion'. 'Rondvraag' means 'open floor discussion'.",
                vocabularyReference: "rondvraag"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "moet", "me", "afmelden", "van", "het", "systeem"],
                correctAnswer: "Ik moet me afmelden van het systeem",
                explanation: "'Ik moet me afmelden van het systeem' means 'I have to log out of the system'. 'Afmelden' means 'to log out'.",
                vocabularyReference: "afmelden"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "dweil", "is", "nat", "en", "vies"],
                correctAnswer: "De dweil is nat en vies",
                explanation: "'De dweil is nat en vies' means 'The mop is wet and dirty'. 'Dweil' means 'mop'.",
                vocabularyReference: "dweil"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["De", "vuilniszakken", "moeten", "buiten", "gezet", "worden"],
                correctAnswer: "De vuilniszakken moeten buiten gezet worden",
                explanation: "'De vuilniszakken moeten buiten gezet worden' means 'The garbage bags have to be put outside'. 'Vuilniszakken' means 'garbage bags'.",
                vocabularyReference: "vuilniszakken"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Achteraf", "was", "het", "een", "goede", "beslissing"],
                correctAnswer: "Achteraf was het een goede beslissing",
                explanation: "'Achteraf was het een goede beslissing' means 'Afterwards it was a good decision'. 'Achteraf' means 'afterwards' or 'in hindsight'.",
                vocabularyReference: "achteraf"
            ),
            // --- Match Meaning Exercises ---
            Exercise(
                type: .matchMeaning,
                prompt: "Match: aanmelden",
                options: ["to register", "to log out", "to discuss"],
                correctAnswer: "to register",
                explanation: "'Aanmelden' means 'to register'.",
                vocabularyReference: "aanmelden"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: bespreken",
                options: ["to discuss", "to warn", "to keep clean"],
                correctAnswer: "to discuss",
                explanation: "'Bespreken' means 'to discuss' or 'to talk about'.",
                vocabularyReference: "bespreken"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: klusser",
                options: ["handyman", "mop", "meeting minutes"],
                correctAnswer: "handyman",
                explanation: "'Klusser' means 'handyman'.",
                vocabularyReference: "klusser"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: voorzitten",
                options: ["to chair", "to warn", "to register"],
                correctAnswer: "to chair",
                explanation: "'Voorzitten' means 'to chair' or 'to preside over'.",
                vocabularyReference: "voorzitten"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: notulen",
                options: ["meeting minutes", "garbage bags", "open floor discussion"],
                correctAnswer: "meeting minutes",
                explanation: "'Notulen' means 'meeting minutes'.",
                vocabularyReference: "notulen"
            ),
            // --- Fill in Blank Exercises ---
            Exercise(
                type: .fillInBlank,
                prompt: "Je moet je ___ voor de vergadering.",
                options: ["aanmelden", "afmelden", "bespreken"],
                correctAnswer: "aanmelden",
                explanation: "'Aanmelden' means 'to register'. Je moet je aanmelden voor de vergadering. (You have to register for the meeting.)",
                vocabularyReference: "aanmelden"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "We gaan dit probleem ___ tijdens de vergadering.",
                options: ["bespreken", "waarschuwen", "voorzitten"],
                correctAnswer: "bespreken",
                explanation: "'Bespreken' means 'to discuss'. We gaan dit probleem bespreken tijdens de vergadering. (We will discuss this problem during the meeting.)",
                vocabularyReference: "bespreken"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ___ komt morgen om de lekkage te repareren.",
                options: ["klusser", "dweil", "notulen"],
                correctAnswer: "klusser",
                explanation: "'Klusser' means 'handyman'. De klusser komt morgen om de lekkage te repareren. (The handyman is coming tomorrow to fix the leak.)",
                vocabularyReference: "klusser"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik moet de keuken ___ voordat de gasten komen.",
                options: ["schoonhouden", "aanmelden", "afmelden"],
                correctAnswer: "schoonhouden",
                explanation: "'Schoonhouden' means 'to keep clean'. Ik moet de keuken schoonhouden voordat de gasten komen. (I have to keep the kitchen clean before the guests come.)",
                vocabularyReference: "schoonhouden"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Zij zal de vergadering ___.",
                options: ["voorzitten", "waarschuwen", "bespreken"],
                correctAnswer: "voorzitten",
                explanation: "'Voorzitten' means 'to chair'. Zij zal de vergadering voorzitten. (She will chair the meeting.)",
                vocabularyReference: "voorzitten"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik wil je ___ waarschuwen dat het gevaarlijk is.",
                options: ["waarschuwen", "aanmelden", "afmelden"],
                correctAnswer: "waarschuwen",
                explanation: "'Waarschuwen' means 'to warn'. Ik wil je waarschuwen dat het gevaarlijk is. (I want to warn you that it's dangerous.)",
                vocabularyReference: "waarschuwen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ___ worden opgeschreven door de secretaris.",
                options: ["notulen", "vuilniszakken", "dweil"],
                correctAnswer: "notulen",
                explanation: "'Notulen' means 'meeting minutes'. De notulen worden opgeschreven door de secretaris. (The meeting minutes are being written down by the secretary.)",
                vocabularyReference: "notulen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "We hebben een ___ gehouden aan het einde van de vergadering.",
                options: ["rondvraag", "dweil", "klusser"],
                correctAnswer: "rondvraag",
                explanation: "'Rondvraag' means 'open floor discussion'. We hebben een rondvraag gehouden aan het einde van de vergadering. (We held an open floor discussion at the end of the meeting.)",
                vocabularyReference: "rondvraag"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Vergeet niet om je ___ van het systeem.",
                options: ["afmelden", "aanmelden", "bespreken"],
                correctAnswer: "afmelden",
                explanation: "'Afmelden' means 'to log out'. Vergeet niet om je afmelden van het systeem. (Don't forget to log out of the system.)",
                vocabularyReference: "afmelden"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ___ is nat en moet drogen.",
                options: ["dweil", "notulen", "vuilniszakken"],
                correctAnswer: "dweil",
                explanation: "'Dweil' means 'mop'. De dweil is nat en moet drogen. (The mop is wet and needs to dry.)",
                vocabularyReference: "dweil"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De ___ moeten buiten gezet worden.",
                options: ["vuilniszakken", "notulen", "dweil"],
                correctAnswer: "vuilniszakken",
                explanation: "'Vuilniszakken' means 'garbage bags'. De vuilniszakken moeten buiten gezet worden. (The garbage bags have to be put outside.)",
                vocabularyReference: "vuilniszakken"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "___ was het een goede beslissing om te verhuizen.",
                options: ["achteraf", "vooraf", "rondvraag"],
                correctAnswer: "achteraf",
                explanation: "'Achteraf' means 'afterwards' or 'in hindsight'. Achteraf was het een goede beslissing om te verhuizen. (Afterwards it was a good decision to move.)",
                vocabularyReference: "achteraf"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik wil je ___ waarschuwen dat het druk wordt.",
                options: ["vooraf", "achteraf", "rondvraag"],
                correctAnswer: "vooraf",
                explanation: "'Vooraf' means 'beforehand' or 'in advance'. Ik wil je vooraf waarschuwen dat het druk wordt. (I want to warn you beforehand that it will be busy.)",
                vocabularyReference: "vooraf"
            ),
            // --- Use in Sentence Exercises ---
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'aanmelden':",
                options: [
                    "Ik moet me aanmelden voor de cursus.",
                    "Zij meldt zich af van het systeem.",
                    "Wij melden ons aan voor de vergadering."
                ],
                correctAnswer: "Ik moet me aanmelden voor de cursus.",
                explanation: "'Aanmelden' means 'to register'. Ik moet me aanmelden voor de cursus. (I have to register for the course.)",
                vocabularyReference: "aanmelden"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'bespreken':",
                options: [
                    "We bespreken het probleem morgen.",
                    "Zij bespreekt de notulen.",
                    "Wij bespreken de rondvraag."
                ],
                correctAnswer: "We bespreken het probleem morgen.",
                explanation: "'Bespreken' means 'to discuss'. We bespreken het probleem morgen. (We will discuss the problem tomorrow.)",
                vocabularyReference: "bespreken"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'voorzitten':",
                options: [
                    "Zij voorzit de vergadering.",
                    "Hij voorzit de notulen.",
                    "Wij voorzitten de rondvraag."
                ],
                correctAnswer: "Zij voorzit de vergadering.",
                explanation: "'Voorzitten' means 'to chair'. Zij voorzit de vergadering. (She chairs the meeting.)",
                vocabularyReference: "voorzitten"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'waarschuwen':",
                options: [
                    "Ik waarschuw je vooraf.",
                    "Zij waarschuwt de notulen.",
                    "Wij waarschuwen de vergadering."
                ],
                correctAnswer: "Ik waarschuw je vooraf.",
                explanation: "'Waarschuwen' means 'to warn'. Ik waarschuw je vooraf. (I warn you beforehand.)",
                vocabularyReference: "waarschuwen"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'schoonhouden':",
                options: [
                    "Ik moet de kamer schoonhouden.",
                    "Zij houdt de notulen schoon.",
                    "Wij houden de vergadering schoon."
                ],
                correctAnswer: "Ik moet de kamer schoonhouden.",
                explanation: "'Schoonhouden' means 'to keep clean'. Ik moet de kamer schoonhouden. (I have to keep the room clean.)",
                vocabularyReference: "schoonhouden"
            ),
            // --- Missing Word Exercises ---
            Exercise(
                type: .missingWord,
                prompt: "De ___ van de vergadering zijn klaar.",
                options: ["notulen", "rondvraag", "dweil"],
                correctAnswer: "notulen",
                explanation: "'Notulen' means 'meeting minutes'. De notulen van de vergadering zijn klaar. (The meeting minutes are ready.)",
                vocabularyReference: "notulen"
            ),
            Exercise(
                type: .missingWord,
                prompt: "We hebben een ___ gehouden.",
                options: ["rondvraag", "klusser", "vuilniszakken"],
                correctAnswer: "rondvraag",
                explanation: "'Rondvraag' means 'open floor discussion'. We hebben een rondvraag gehouden. (We held an open floor discussion.)",
                vocabularyReference: "rondvraag"
            ),
            Exercise(
                type: .missingWord,
                prompt: "De ___ komt om de lekkage te repareren.",
                options: ["klusser", "dweil", "notulen"],
                correctAnswer: "klusser",
                explanation: "'Klusser' means 'handyman'. De klusser komt om de lekkage te repareren. (The handyman is coming to fix the leak.)",
                vocabularyReference: "klusser"
            ),
            Exercise(
                type: .missingWord,
                prompt: "De ___ is nat en vies.",
                options: ["dweil", "notulen", "vuilniszakken"],
                correctAnswer: "dweil",
                explanation: "'Dweil' means 'mop'. De dweil is nat en vies. (The mop is wet and dirty.)",
                vocabularyReference: "dweil"
            ),
            Exercise(
                type: .missingWord,
                prompt: "De ___ moeten buiten gezet worden.",
                options: ["vuilniszakken", "notulen", "dweil"],
                correctAnswer: "vuilniszakken",
                explanation: "'Vuilniszakken' means 'garbage bags'. De vuilniszakken moeten buiten gezet worden. (The garbage bags have to be put outside.)",
                vocabularyReference: "vuilniszakken"
            )
        ]
    )

    static let chapter35: Lesson = Lesson(
        id: UUID(),
        title: "Chapter 3.5 – Dutch Vocabulary in Context",
        description: """
Practice using new Dutch words in context. Learn their meanings and test your understanding with fill-in-the-blank and word selection exercises.
""",
        vocabulary: [
            VocabularyItem(dutchWord: "herrie", translation: "noise, racket"),
            VocabularyItem(dutchWord: "veilig", translation: "safe"),
            VocabularyItem(dutchWord: "nogal", translation: "rather, quite"),
            VocabularyItem(dutchWord: "logeren", translation: "to stay overnight"),
            VocabularyItem(dutchWord: "aanvullen", translation: "to refill, to supplement"),
            VocabularyItem(dutchWord: "aandoen", translation: "to turn on (e.g., lights, devices)"),
            VocabularyItem(dutchWord: "dat komt niet uit", translation: "that doesn't work out (schedule)"),
            VocabularyItem(dutchWord: "trouwens", translation: "by the way"),
            VocabularyItem(dutchWord: "fit", translation: "fit, in shape"),
            VocabularyItem(dutchWord: "nauwelijks", translation: "hardly"),
            VocabularyItem(dutchWord: "bereid", translation: "willing/prepared"),
            VocabularyItem(dutchWord: "ontzettend", translation: "extremely"),
            VocabularyItem(dutchWord: "ziek", translation: "sick"),
            VocabularyItem(dutchWord: "het tijdstip", translation: "moment/time"),
            VocabularyItem(dutchWord: "de zekerheid", translation: "just to be sure"),
            VocabularyItem(dutchWord: "waarderen", translation: "to appreciate"),
            VocabularyItem(dutchWord: "aandoen", translation: "to turn on"),
            VocabularyItem(dutchWord: "aanvullen", translation: "to supplement"),
            VocabularyItem(dutchWord: "het alarm", translation: "the alarm"),
            VocabularyItem(dutchWord: "het best doen", translation: "to do one's best"),
            VocabularyItem(dutchWord: "zich druk maken", translation: "to worry"),
            VocabularyItem(dutchWord: "het komt niet uit", translation: "it doesn't come out"),
            VocabularyItem(dutchWord: "logeren", translation: "to stay overnight"),
            VocabularyItem(dutchWord: "net zoals", translation: "just like"),
            VocabularyItem(dutchWord: "nogal", translation: "quite"),
            VocabularyItem(dutchWord: "een praatje maken", translation: "to have a chat"),
            VocabularyItem(dutchWord: "trouwens", translation: "by the way")
        ],
        exercises: [
            // --- Sentence Building Exercise (First Question) ---
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "logeren", "bij", "vrienden", "ga", "vanavond"],
                correctAnswer: "Ik ga vanavond bij vrienden logeren",
                explanation: "'Ik ga vanavond bij vrienden logeren' means 'I am going to stay overnight with friends tonight'. In Dutch, the word order is: Subject (Ik) + Verb (ga) + Time (vanavond) + Preposition (bij) + Object (vrienden) + Infinitive verb (logeren).",
                vocabularyReference: "logeren"
            ),
            // --- Additional Sentence Building Exercises ---
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Het", "is", "nogal", "koud", "buiten"],
                correctAnswer: "Het is nogal koud buiten",
                explanation: "'Het is nogal koud buiten' means 'It is quite cold outside'. 'Nogal' means 'quite' or 'rather'.",
                vocabularyReference: "nogal"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "doe", "het", "licht", "aan"],
                correctAnswer: "Ik doe het licht aan",
                explanation: "'Ik doe het licht aan' means 'I turn on the light'. 'Aandoen' means 'to turn on'.",
                vocabularyReference: "aandoen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "ben", "bereid", "om", "te", "helpen"],
                correctAnswer: "Ik ben bereid om te helpen",
                explanation: "'Ik ben bereid om te helpen' means 'I am willing to help'. 'Bereid' means 'willing' or 'prepared'.",
                vocabularyReference: "bereid"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "waardeer", "jouw", "hulp"],
                correctAnswer: "Ik waardeer jouw hulp",
                explanation: "'Ik waardeer jouw hulp' means 'I appreciate your help'. 'Waarderen' means 'to appreciate'.",
                vocabularyReference: "waarderen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Het", "is", "ontzettend", "druk", "vandaag"],
                correctAnswer: "Het is ontzettend druk vandaag",
                explanation: "'Het is ontzettend druk vandaag' means 'It is extremely busy today'. 'Ontzettend' means 'extremely'.",
                vocabularyReference: "ontzettend"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "heb", "nauwelijks", "tijd", "gehad"],
                correctAnswer: "Ik heb nauwelijks tijd gehad",
                explanation: "'Ik heb nauwelijks tijd gehad' means 'I hardly had time'. 'Nauwelijks' means 'hardly'.",
                vocabularyReference: "nauwelijks"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "maak", "me", "niet", "druk"],
                correctAnswer: "Ik maak me niet druk",
                explanation: "'Ik maak me niet druk' means 'I don't worry'. 'Zich druk maken' means 'to worry'.",
                vocabularyReference: "zich druk maken"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "ga", "een", "praatje", "maken"],
                correctAnswer: "Ik ga een praatje maken",
                explanation: "'Ik ga een praatje maken' means 'I am going to have a chat'. 'Een praatje maken' means 'to have a chat'.",
                vocabularyReference: "een praatje maken"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "vul", "de", "voorraad", "aan"],
                correctAnswer: "Ik vul de voorraad aan",
                explanation: "'Ik vul de voorraad aan' means 'I refill the stock'. 'Aanvullen' means 'to supplement' or 'to refill'.",
                vocabularyReference: "aanvullen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "heb", "het", "alarm", "gezet"],
                correctAnswer: "Ik heb het alarm gezet",
                explanation: "'Ik heb het alarm gezet' means 'I have set the alarm'. 'Het alarm' means 'the alarm'.",
                vocabularyReference: "het alarm"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "doe", "mijn", "best", "voor", "het", "examen"],
                correctAnswer: "Ik doe mijn best voor het examen",
                explanation: "'Ik doe mijn best voor het examen' means 'I do my best for the exam'. 'Het best doen' means 'to do one's best'.",
                vocabularyReference: "het best doen"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Ik", "neem", "voor", "de", "zekerheid", "een", "paraplu"],
                correctAnswer: "Ik neem voor de zekerheid een paraplu",
                explanation: "'Ik neem voor de zekerheid een paraplu' means 'I take an umbrella just to be sure'. 'Voor de zekerheid' means 'just to be sure'.",
                vocabularyReference: "de zekerheid"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Trouwens", "ik", "ga", "morgen", "naar", "de", "sportclub"],
                correctAnswer: "Trouwens ik ga morgen naar de sportclub",
                explanation: "'Trouwens ik ga morgen naar de sportclub' means 'By the way, I am going to the sports club tomorrow'. 'Trouwens' means 'by the way'.",
                vocabularyReference: "trouwens"
            ),
            Exercise(
                type: .sentenceBuilding,
                prompt: "Arrange the words to form a correct Dutch sentence:",
                options: ["Het", "tijdstip", "is", "niet", "belangrijk"],
                correctAnswer: "Het tijdstip is niet belangrijk",
                explanation: "'Het tijdstip is niet belangrijk' means 'The time is not important'. 'Het tijdstip' means 'the moment' or 'time'.",
                vocabularyReference: "het tijdstip"
            ),
            // --- New exercise types at the top ---
            Exercise(
                type: .matchMeaning,
                prompt: "Match: ziek",
                options: ["sick", "time", "to appreciate"],
                correctAnswer: "sick",
                explanation: "'Ziek' means 'sick' in English.",
                vocabularyReference: "ziek"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: het tijdstip",
                options: ["moment/time", "alarm", "to worry"],
                correctAnswer: "moment/time",
                explanation: "'Het tijdstip' means 'moment' or 'time'.",
                vocabularyReference: "het tijdstip"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'waarderen':",
                options: [
                    "Ik waardeer jouw hulp.",
                    "Ik waardeer de mooie bloemen.",
                    "Ik waardeer de goede service."
                ],
                correctAnswer: "Ik waardeer jouw hulp.",
                explanation: "'Waarderen' means 'to appreciate'. Ik waardeer jouw hulp. (I appreciate your help)",
                vocabularyReference: "waarderen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Het is ___ druk op straat vandaag!",
                options: ["ontzettend", "nauwelijks", "nogal"],
                correctAnswer: "ontzettend",
                explanation: "'Ontzettend' means 'extremely' or 'very'. Het is ontzettend druk op straat vandaag! (It is extremely busy on the street today!)",
                vocabularyReference: "ontzettend"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'logeren':",
                options: [
                    "Mijn kinderen logeren bij vrienden.",
                    "Wij logeren in een hotel.",
                    "Zij logeren bij hun oma."
                ],
                correctAnswer: "Mijn kinderen logeren bij vrienden.",
                explanation: "'Logeren' means 'to stay overnight'. Mijn kinderen logeren bij vrienden. (My children are staying overnight with friends)",
                vocabularyReference: "logeren"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Kun je de deur voorzichtig ___? Het kind slaapt.",
                options: ["aandoen", "aanvullen", "waarderen"],
                correctAnswer: "aandoen",
                explanation: "'Aandoen' means 'to turn on' or 'to close gently'. Kun je de deur voorzichtig aandoen? Het kind slaapt. (Can you carefully close the door? The child is sleeping.)",
                vocabularyReference: "aandoen"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ gezet voor morgenochtend vroeg.",
                options: ["het alarm", "de zekerheid", "het tijdstip"],
                correctAnswer: "het alarm",
                explanation: "'Het alarm' means 'the alarm'. Ik heb het alarm gezet voor morgenochtend vroeg. (I have set the alarm for early tomorrow morning.)",
                vocabularyReference: "het alarm"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'het best doen':",
                options: [
                    "Ik ga mijn best doen voor het examen.",
                    "Zij doet haar best om te helpen.",
                    "Wij doen ons best om op tijd te komen."
                ],
                correctAnswer: "Ik ga mijn best doen voor het examen.",
                explanation: "'Het best doen' (or 'mijn best doen') means 'to do one's best'. Ik ga mijn best doen voor het examen. (I will do my best for the exam)",
                vocabularyReference: "het best doen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Maak je niet zo ___! Alles komt goed.",
                options: ["zich druk maken", "druk", "ontzettend"],
                correctAnswer: "druk",
                explanation: "'Zich druk maken' means 'to worry'. Maak je niet zo druk! Alles komt goed. (Don't worry so much! Everything will be fine.)",
                vocabularyReference: "zich druk maken"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Mijn zus houdt van winkelen, ___ ik.",
                options: ["net zoals", "nauwelijks", "nogal"],
                correctAnswer: "net zoals",
                explanation: "'Net zoals' means 'just like'. Mijn zus houdt van winkelen, net zoals ik. (My sister likes shopping, just like me.)",
                vocabularyReference: "net zoals"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'nogal':",
                options: [
                    "Het is nogal koud buiten.",
                    "Het eten is nogal lekker.",
                    "De film is nogal spannend."
                ],
                correctAnswer: "Het is nogal koud buiten.",
                explanation: "'Nogal' means 'quite' or 'rather'. Het is nogal koud buiten. (It is quite cold outside)",
                vocabularyReference: "nogal"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik ga even ___ met de buren.",
                options: ["een praatje maken", "zich druk maken", "het best doen"],
                correctAnswer: "een praatje maken",
                explanation: "'Een praatje maken' means 'to have a chat'. Ik ga even een praatje maken met de buren. (I'm going to have a chat with the neighbors.)",
                vocabularyReference: "een praatje maken"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Voor ___ neem ik altijd een paraplu mee.",
                options: ["de zekerheid", "het tijdstip", "het alarm"],
                correctAnswer: "de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure'. Voor de zekerheid neem ik altijd een paraplu mee. (Just to be sure, I always take an umbrella.)",
                vocabularyReference: "de zekerheid"
            ),
            // --- Additional exercises ---
            Exercise(
                type: .fillInBlank,
                prompt: "Tot morgen! Zullen we ___ morgen na het werk naar de sportclub gaan?",
                options: ["nauwelijks", "trouwens", "waarderen"],
                correctAnswer: "trouwens",
                explanation: "'Trouwens' means 'by the way'. Tot morgen! Zullen we trouwens morgen na het werk naar de sportclub gaan? (See you tomorrow! By the way, shall we go to the sports club tomorrow after work?)",
                vocabularyReference: "trouwens"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De appels in de winkel zijn op. Kun jij ze ___?",
                options: ["aandoen", "aanvullen", "logeren"],
                correctAnswer: "aanvullen",
                explanation: "'Aanvullen' means 'to supplement' or 'to refill'. De appels in de winkel zijn op. Kun jij ze aanvullen? (The apples in the store are sold out. Can you refill them?)",
                vocabularyReference: "aanvullen"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Mijn collega is ziek, dus ik moet zijn werk ...",
                options: ["aanvullen", "overnemen", "waarderen"],
                correctAnswer: "overnemen",
                explanation: "'Overnemen' means 'to take over'. Mijn collega is ziek, dus ik moet zijn werk overnemen. (My colleague is sick, so I have to take over his work.)",
                vocabularyReference: nil
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ een paraplu meegenomen.",
                options: ["nauwelijks", "nogal", "voor de zekerheid"],
                correctAnswer: "voor de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure'. Ik heb voor de zekerheid een paraplu meegenomen. (I have taken an umbrella just to be sure.)",
                vocabularyReference: "voor de zekerheid"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: nauwelijks",
                options: ["hardly", "always", "quickly"],
                correctAnswer: "hardly",
                explanation: "'Nauwelijks' means 'hardly' or 'barely'.",
                vocabularyReference: "nauwelijks"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: waarderen",
                options: ["to appreciate", "to worry", "to stay overnight"],
                correctAnswer: "to appreciate",
                explanation: "'Waarderen' means 'to appreciate'.",
                vocabularyReference: "waarderen"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'bereid':",
                options: [
                    "Ik ben bereid om te helpen.",
                    "Zij is bereid om te betalen.",
                    "Wij zijn bereid om te wachten."
                ],
                correctAnswer: "Ik ben bereid om te helpen.",
                explanation: "'Bereid' means 'willing' or 'prepared'. Ik ben bereid om te helpen. (I am willing to help)",
                vocabularyReference: "bereid"
            ),
            // --- New additional exercises ---
            Exercise(
                type: .fillInBlank,
                prompt: "Hij is ___ thuis, hij werkt altijd.",
                options: ["nauwelijks", "nogal", "ontzettend"],
                correctAnswer: "nauwelijks",
                explanation: "'Nauwelijks' means 'hardly' or 'barely'. Hij is nauwelijks thuis, hij werkt altijd. (He is hardly home, he always works.)",
                vocabularyReference: "nauwelijks"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'aandoen':",
                options: [
                    "Ik doe het licht aan.",
                    "Zij doet de verwarming aan.",
                    "Wij doen de radio aan."
                ],
                correctAnswer: "Ik doe het licht aan.",
                explanation: "'Aandoen' means 'to turn on' or 'to put on'. Ik doe het licht aan. (I turn on the light)",
                vocabularyReference: "aandoen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Het weer is ___ slecht vandaag.",
                options: ["nogal", "nauwelijks", "net zoals"],
                correctAnswer: "nogal",
                explanation: "'Nogal' means 'quite' or 'rather'. Het weer is nogal slecht vandaag. (The weather is quite bad today.)",
                vocabularyReference: "nogal"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ een extra trui meegenomen.",
                options: ["voor de zekerheid", "het alarm", "het tijdstip"],
                correctAnswer: "voor de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure'. Ik heb voor de zekerheid een extra trui meegenomen. (I have taken an extra sweater just to be sure.)",
                vocabularyReference: "voor de zekerheid"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'zich druk maken':",
                options: [
                    "Maak je niet druk, alles komt goed.",
                    "Zij maakt zich druk om het weer.",
                    "Wij maken ons druk om de kinderen."
                ],
                correctAnswer: "Maak je niet druk, alles komt goed.",
                explanation: "'Zich druk maken' means 'to worry'. Maak je niet druk, alles komt goed. (Don't worry, everything will be fine)",
                vocabularyReference: "zich druk maken"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Mijn broer en ik houden van dezelfde muziek, ___ onze ouders.",
                options: ["net zoals", "nogal", "nauwelijks"],
                correctAnswer: "net zoals",
                explanation: "'Net zoals' means 'just like'. Mijn broer en ik houden van dezelfde muziek, net zoals onze ouders. (My brother and I like the same music, just like our parents.)",
                vocabularyReference: "net zoals"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: bereid",
                options: ["willing/prepared", "sick", "to appreciate"],
                correctAnswer: "willing/prepared",
                explanation: "'Bereid' means 'willing' or 'prepared'.",
                vocabularyReference: "bereid"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De winkel is ___ open op zondag.",
                options: ["nauwelijks", "nogal", "ontzettend"],
                correctAnswer: "nauwelijks",
                explanation: "'Nauwelijks' means 'hardly' or 'barely'. De winkel is nauwelijks open op zondag. (The store is hardly open on Sunday.)",
                vocabularyReference: "nauwelijks"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'aanvullen':",
                options: [
                    "Kun je de voorraad aanvullen?",
                    "Zij vult de informatie aan.",
                    "Wij vullen de documenten aan."
                ],
                correctAnswer: "Kun je de voorraad aanvullen?",
                explanation: "'Aanvullen' means 'to supplement' or 'to refill'. Kun je de voorraad aanvullen? (Can you refill the stock?)",
                vocabularyReference: "aanvullen"
            )
        ]
    )
}

class LessonManager: ObservableObject {
    static let shared = LessonManager()
    
    @Published private(set) var lessons: [Lesson]
    
    private init() {
        // Add more lessons here as needed
        self.lessons = [
            Lesson.chapter31,
            Lesson.chapter33,
            Lesson.chapter35
        ]
    }
    
    func lesson(withId id: UUID) -> Lesson? {
        lessons.first { $0.id == id }
    }
} 