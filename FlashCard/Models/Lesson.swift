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
                    "Ik waardeer naar school.",
                    "Ik waardeer een appel."
                ],
                correctAnswer: "Ik waardeer jouw hulp.",
                explanation: "'Waarderen' means 'to appreciate', so 'Ik waardeer jouw hulp.' is correct. The other sentences are grammatically incorrect or don't make sense in Dutch.",
                vocabularyReference: "waarderen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Het is ___ druk op straat vandaag!",
                options: ["ontzettend", "nauwelijks", "nogal"],
                correctAnswer: "ontzettend",
                explanation: "'Ontzettend' means 'extremely' or 'very', which fits the context of describing how busy the street is.",
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
                explanation: "'Logeren' means 'to stay overnight', so 'Mijn kinderen logeren bij vrienden.' is correct. The other sentences are not correct uses of 'logeren'.",
                vocabularyReference: "logeren"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Kun je de deur voorzichtig ___? Het kind slaapt.",
                options: ["aandoen", "aanvullen", "waarderen"],
                correctAnswer: "aandoen",
                explanation: "'Aandoen' means 'to turn on' or 'to close gently', which fits the context of carefully handling the door.",
                vocabularyReference: "aandoen"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ gezet voor morgenochtend vroeg.",
                options: ["het alarm", "de zekerheid", "het tijdstip"],
                correctAnswer: "het alarm",
                explanation: "'Het alarm' means 'the alarm', which fits the context of setting an alarm for early morning.",
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
                explanation: "'Het best doen' (or 'mijn best doen') means 'to do one's best', so 'Ik ga mijn best doen voor het examen.' is correct.",
                vocabularyReference: "het best doen"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Maak je niet zo ___! Alles komt goed.",
                options: ["zich druk maken", "druk", "ontzettend"],
                correctAnswer: "druk",
                explanation: "'Zich druk maken' means 'to worry'. The phrase 'Maak je niet zo druk!' means 'Don't worry so much!'",
                vocabularyReference: "zich druk maken"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Sorry, maar morgen ___ niet ___. Ik heb al een afspraak.",
                options: ["komt niet uit", "komt uit", "komt binnen"],
                correctAnswer: "komt niet uit",
                explanation: "'Het komt niet uit' means 'it doesn't work out' or 'it's not convenient', which fits the context of having a conflict.",
                vocabularyReference: "het komt niet uit"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Mijn zus houdt van winkelen, ___ ik.",
                options: ["net zoals", "nauwelijks", "nogal"],
                correctAnswer: "net zoals",
                explanation: "'Net zoals' means 'just like', which fits the context of comparing similarities.",
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
                explanation: "'Nogal' means 'quite' or 'rather', so 'Het is nogal koud buiten.' is correct.",
                vocabularyReference: "nogal"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "Ik ga even ___ met de buren.",
                options: ["een praatje maken", "zich druk maken", "het best doen"],
                correctAnswer: "een praatje maken",
                explanation: "'Een praatje maken' means 'to have a chat', which fits the context of talking with neighbors.",
                vocabularyReference: "een praatje maken"
            ),
            Exercise(
                type: .missingWord,
                prompt: "Voor ___ neem ik altijd een paraplu mee.",
                options: ["de zekerheid", "het tijdstip", "het alarm"],
                correctAnswer: "de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure', which fits the context of taking an umbrella as a precaution.",
                vocabularyReference: "de zekerheid"
            ),
            // --- Existing exercises below ---
            // Fill-in-the-blank (choose the correct word)
            Exercise(
                type: .fillInBlank,
                prompt: "Tot morgen! Zullen we ___ morgen na het werk naar het sportclub gaan?",
                options: ["nauwelijks", "trouwens", "waarderen"],
                correctAnswer: "trouwens",
                explanation: "'Trouwens' means 'by the way', which fits the context of suggesting something as an afterthought.",
                vocabularyReference: "trouwens"
            ),
            Exercise(
                type: .fillInBlank,
                prompt: "De appels in de winkel zijn op. Kun jij ze ___?",
                options: ["aandoen", "aanvullen", "logeren"],
                correctAnswer: "aanvullen",
                explanation: "'Aanvullen' means 'to supplement' or 'to refill', which fits the context of restocking apples.",
                vocabularyReference: "aanvullen"
            ),
            // Which word is missing?
            Exercise(
                type: .missingWord,
                prompt: "Mijn collega is ziek, dus ik moet zijn werk ...",
                options: ["aanvullen", "overnemen", "waarderen"],
                correctAnswer: "overnemen",
                explanation: "'Overnemen' means 'to take over', which fits the context of covering for a sick colleague.",
                vocabularyReference: nil
            ),
            Exercise(
                type: .missingWord,
                prompt: "Ik heb ___ een paraplu meegenomen.",
                options: ["nauwelijks", "nogal", "voor de zekerheid"],
                correctAnswer: "voor de zekerheid",
                explanation: "'Voor de zekerheid' means 'just to be sure', which fits the context of taking an umbrella as a precaution.",
                vocabularyReference: "voor de zekerheid"
            ),
            // Match the word to the meaning
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
            // Use the word in a sentence
            Exercise(
                type: .useInSentence,
                prompt: "Choose the correct use of 'bereid':",
                options: [
                    "Ik ben bereid om te helpen.",
                    "Ik ben nauwelijks thuis.",
                    "Ik maak een praatje."
                ],
                correctAnswer: "Ik ben bereid om te helpen.",
                explanation: "'Bereid' means 'willing' or 'prepared', so 'Ik ben bereid om te helpen.' is correct.",
                vocabularyReference: "bereid"
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