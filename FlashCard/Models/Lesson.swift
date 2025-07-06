import Foundation

struct Lesson: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let vocabulary: [String] // Dutch words, linked to user's flashcards
    let exercises: [Exercise]
}

struct Exercise: Identifiable, Codable, Hashable {
    enum ExerciseType: String, Codable, Hashable {
        case fillInBlank
        case missingWord
        case matchMeaning
        case useInSentence
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
    static let chapter35: Lesson = Lesson(
        id: UUID(),
        title: "Chapter 3.5 – Dutch Vocabulary in Context",
        description: "Practice using new Dutch words in context. Learn their meanings and test your understanding with fill-in-the-blank and word selection exercises.",
        vocabulary: [
            "nauwelijks", "bereid", "ontzettend", "ziek", "het tijdstip", "de zekerheid", "waarderen", "aandoen", "aanvullen", "het alarm", "het best doen", "zich druk maken", "het komt niet uit", "logeren", "net zoals", "nogal", "een praatje maken", "trouwens"
        ],
        exercises: [
            // --- New exercise types at the top ---
            Exercise(
                type: .matchMeaning,
                prompt: "Match: ziek",
                options: ["sick", "time", "to appreciate"],
                correctAnswer: "sick",
                explanation: "'Ziek' means 'sick' in English. (Question: Match: ziek)",
                vocabularyReference: "ziek"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: het tijdstip",
                options: ["moment/time", "alarm", "to worry"],
                correctAnswer: "moment/time",
                explanation: "'Het tijdstip' means 'moment' or 'time'. (Question: Match: het tijdstip)",
                vocabularyReference: "het tijdstip"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'waarderen':",
                options: [
                    "Ik waardeer jouw hulp.",
                    "Ik waardeer naar school.",
                    "Ik waardeer een appel."
                ],
                correctAnswer: "Ik waardeer jouw hulp.",
                explanation: "'Waarderen' means 'to appreciate', so 'Ik waardeer jouw hulp.' (I appreciate your help) is correct. The other sentences are grammatically incorrect or don't make sense in Dutch. (Question: Choose the correct use of 'waarderen')",
                vocabularyReference: "waarderen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Het is ___ druk op straat vandaag!",
                options: ["ontzettend", "nauwelijks", "nogal"],
                correctAnswer: "ontzettend",
                explanation: "'Ontzettend' means 'extremely' or 'very', which fits the context of describing how busy the street is. (Question: Het is ___ druk op straat vandaag! = It is ___ busy on the street today!)",
                vocabularyReference: "ontzettend"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'logeren':",
                options: [
                    "Mijn kinderen logeren bij vrienden.",
                    "Ik logeer een boek.",
                    "Wij logeren een appel."
                ],
                correctAnswer: "Mijn kinderen logeren bij vrienden.",
                explanation: "'Logeren' means 'to stay overnight', so 'Mijn kinderen logeren bij vrienden.' (My children are staying overnight with friends) is correct. The other sentences are not correct uses of 'logeren'. (Question: Choose the correct use of 'logeren')",
                vocabularyReference: "logeren"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Kun je de deur voorzichtig ___? Het kind slaapt.",
                options: ["aandoen", "aanvullen", "waarderen"],
                correctAnswer: "aandoen",
                explanation: "'Aandoen' means 'to turn on' or 'to close gently', which fits the context of carefully handling the door. (Question: Kun je de deur voorzichtig ___? Het kind slaapt. = Can you carefully ___ the door? The child is sleeping.)",
                vocabularyReference: "aandoen"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ gezet voor morgenochtend vroeg.",
                options: ["het alarm", "de zekerheid", "het tijdstip"],
                correctAnswer: "het alarm",
                explanation: "'Het alarm' means 'the alarm', which fits the context of setting an alarm for early morning. (Question: Ik heb ___ gezet voor morgenochtend vroeg. = I have set the ___ for early tomorrow morning.)",
                vocabularyReference: "het alarm"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'het best doen':",
                options: [
                    "Ik ga mijn best doen voor het examen.",
                    "Ik ga het best doen kopen.",
                    "Het best doen is moeilijk eten."
                ],
                correctAnswer: "Ik ga mijn best doen voor het examen.",
                explanation: "'Het best doen' (or 'mijn best doen') means 'to do one's best', so 'Ik ga mijn best doen voor het examen.' (I will do my best for the exam) is correct. (Question: Choose the correct use of 'het best doen')",
                vocabularyReference: "het best doen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Maak je niet zo ___! Alles komt goed.",
                options: ["zich druk maken", "druk", "ontzettend"],
                correctAnswer: "druk",
                explanation: "'Zich druk maken' means 'to worry'. The phrase 'Maak je niet zo druk!' means 'Don't worry so much!' (Question: Maak je niet zo ___! Alles komt goed. = Don't ___ so much! Everything will be fine.)",
                vocabularyReference: "zich druk maken"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Mijn zus houdt van winkelen, ___ ik.",
                options: ["net zoals", "nauwelijks", "nogal"],
                correctAnswer: "net zoals",
                explanation: "'Net zoals' means 'just like', which fits the context of comparing similarities. (Question: Mijn zus houdt van winkelen, ___ ik. = My sister likes shopping, ___ me.)",
                vocabularyReference: "net zoals"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'nogal':",
                options: [
                    "Het is nogal koud buiten.",
                    "Ik nogal naar huis.",
                    "Wij nogal een boek."
                ],
                correctAnswer: "Het is nogal koud buiten.",
                explanation: "'Nogal' means 'quite' or 'rather', so 'Het is nogal koud buiten.' (It is quite cold outside) is correct. (Question: Choose the correct use of 'nogal')",
                vocabularyReference: "nogal"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik ga even ___ met de buren.",
                options: ["een praatje maken", "zich druk maken", "het best doen"],
                correctAnswer: "een praatje maken",
                explanation: "'Een praatje maken' means 'to have a chat', which fits the context of talking with neighbors. (Question: Ik ga even ___ met de buren. = I'm going to ___ with the neighbors.)",
                vocabularyReference: "een praatje maken"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Voor ___ neem ik altijd een paraplu mee.",
                options: ["de zekerheid", "het tijdstip", "het alarm"],
                correctAnswer: "de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure', which fits the context of taking an umbrella as a precaution. (Question: Voor ___ neem ik altijd een paraplu mee. = For ___ I always take an umbrella.)",
                vocabularyReference: "de zekerheid"
            ),
            // --- Additional exercises ---
            Exercise(
                type: .fillInBlank,
                prompt: "Tot morgen! Zullen we ___ morgen na het werk naar het sportclub gaan?",
                options: ["nauwelijks", "trouwens", "waarderen"],
                correctAnswer: "trouwens",
                explanation: "'Trouwens' means 'by the way', which fits the context of suggesting something as an afterthought. (Question: Tot morgen! Zullen we ___ morgen na het werk naar het sportclub gaan? = See you tomorrow! ___ shall we go to the sports club tomorrow after work?)",
                vocabularyReference: "trouwens"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De appels in de winkel zijn op. Kun jij ze ___?",
                options: ["aandoen", "aanvullen", "logeren"],
                correctAnswer: "aanvullen",
                explanation: "'Aanvullen' means 'to supplement' or 'to refill', which fits the context of restocking apples. (Question: De appels in de winkel zijn op. Kun jij ze ___? = The apples in the store are sold out. Can you ___ them?)",
                vocabularyReference: "aanvullen"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Mijn collega is ziek, dus ik moet zijn werk ...",
                options: ["aanvullen", "overnemen", "waarderen"],
                correctAnswer: "overnemen",
                explanation: "'Overnemen' means 'to take over', which fits the context of covering for a sick colleague. (Question: Mijn collega is ziek, dus ik moet zijn werk ... = My colleague is sick, so I have to ... his work.)",
                vocabularyReference: nil
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ een paraplu meegenomen.",
                options: ["nauwelijks", "nogal", "voor de zekerheid"],
                correctAnswer: "voor de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure', which fits the context of taking an umbrella as a precaution. (Question: Ik heb ___ een paraplu meegenomen. = I have ___ taken an umbrella.)",
                vocabularyReference: "voor de zekerheid"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: nauwelijks",
                options: ["hardly", "always", "quickly"],
                correctAnswer: "hardly",
                explanation: "'Nauwelijks' means 'hardly' or 'barely'. (Question: Match: nauwelijks)",
                vocabularyReference: "nauwelijks"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: waarderen",
                options: ["to appreciate", "to worry", "to stay overnight"],
                correctAnswer: "to appreciate",
                explanation: "'Waarderen' means 'to appreciate'. (Question: Match: waarderen)",
                vocabularyReference: "waarderen"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'bereid':",
                options: [
                    "Ik ben bereid om te helpen.",
                    "Ik ben nauwelijks thuis.",
                    "Ik maak een praatje."
                ],
                correctAnswer: "Ik ben bereid om te helpen.",
                explanation: "'Bereid' means 'willing' or 'prepared', so 'Ik ben bereid om te helpen.' (I am willing to help) is correct. (Question: Choose the correct use of 'bereid')",
                vocabularyReference: "bereid"
            ),
            // --- New additional exercises ---
            Exercise(
                type: .fillInBlank,
                prompt: "Hij is ___ thuis, hij werkt altijd.",
                options: ["nauwelijks", "nogal", "ontzettend"],
                correctAnswer: "nauwelijks",
                explanation: "'Nauwelijks' means 'hardly' or 'barely', which fits the context of someone who is rarely home due to work. (Question: Hij is ___ thuis, hij werkt altijd. = He is ___ home, he always works.)",
                vocabularyReference: "nauwelijks"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'aandoen':",
                options: [
                    "Ik doe het licht aan.",
                    "Ik doe een boek aan.",
                    "Ik doe een appel aan."
                ],
                correctAnswer: "Ik doe het licht aan.",
                explanation: "'Aandoen' means 'to turn on' or 'to put on', so 'Ik doe het licht aan.' (I turn on the light) is correct. (Question: Choose the correct use of 'aandoen')",
                vocabularyReference: "aandoen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Het weer is ___ slecht vandaag.",
                options: ["nogal", "nauwelijks", "net zoals"],
                correctAnswer: "nogal",
                explanation: "'Nogal' means 'quite' or 'rather', which fits the context of describing the weather. (Question: Het weer is ___ slecht vandaag. = The weather is ___ bad today.)",
                vocabularyReference: "nogal"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ een extra trui meegenomen.",
                options: ["voor de zekerheid", "het alarm", "het tijdstip"],
                correctAnswer: "voor de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure', which fits the context of taking extra clothing as a precaution. (Question: Ik heb ___ een extra trui meegenomen. = I have ___ taken an extra sweater.)",
                vocabularyReference: "voor de zekerheid"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'zich druk maken':",
                options: [
                    "Maak je niet druk, alles komt goed.",
                    "Ik maak druk een boek.",
                    "Wij maken druk een appel."
                ],
                correctAnswer: "Maak je niet druk, alles komt goed.",
                explanation: "'Zich druk maken' means 'to worry', so 'Maak je niet druk, alles komt goed.' (Don't worry, everything will be fine) is correct. (Question: Choose the correct use of 'zich druk maken')",
                vocabularyReference: "zich druk maken"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Mijn broer en ik houden van dezelfde muziek, ___ onze ouders.",
                options: ["net zoals", "nogal", "nauwelijks"],
                correctAnswer: "net zoals",
                explanation: "'Net zoals' means 'just like', which fits the context of comparing similarities between family members. (Question: Mijn broer en ik houden van dezelfde muziek, ___ onze ouders. = My brother and I like the same music, ___ our parents.)",
                vocabularyReference: "net zoals"
            ),
            Exercise(
                type: .matchMeaning,
                prompt: "Match: bereid",
                options: ["willing/prepared", "sick", "to appreciate"],
                correctAnswer: "willing/prepared",
                explanation: "'Bereid' means 'willing' or 'prepared'. (Question: Match: bereid)",
                vocabularyReference: "bereid"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De winkel is ___ open op zondag.",
                options: ["nauwelijks", "nogal", "ontzettend"],
                correctAnswer: "nauwelijks",
                explanation: "'Nauwelijks' means 'hardly' or 'barely', which fits the context of a store that is rarely open on Sundays. (Question: De winkel is ___ open op zondag. = The store is ___ open on Sunday.)",
                vocabularyReference: "nauwelijks"
            ),
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'aanvullen':",
                options: [
                    "Kun je de voorraad aanvullen?",
                    "Ik aanvul een boek.",
                    "Wij aanvullen een appel."
                ],
                correctAnswer: "Kun je de voorraad aanvullen?",
                explanation: "'Aanvullen' means 'to supplement' or 'to refill', so 'Kun je de voorraad aanvullen?' (Can you refill the stock?) is correct. (Question: Choose the correct use of 'aanvullen')",
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
            Lesson.chapter35
        ]
    }
    
    func lesson(withId id: UUID) -> Lesson? {
        lessons.first { $0.id == id }
    }
} 