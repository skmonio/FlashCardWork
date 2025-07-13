import Foundation

// MARK: - Updated A1 Zelfstandig Grammar Rule (Plural Focus Only)

struct UpdatedDutchGrammarRule {
    static let dutchNounsAndArticlesA1 = DutchGrammarRule(
        id: "dutch_articles_a1",
        title: "Zelfstandige Naamwoorden - Meervoud en Enkelvoud (Nouns - Plural and Singular) - A1",
        type: .pluralization,
        level: .a1,
        explanation: """
        In het Nederlands vormen we het meervoud van zelfstandige naamwoorden (nouns) door uitgangen toe te voegen aan het enkelvoud.
        
        Belangrijke regels voor meervoud vorming:
        • Meestal: enkelvoud + -en (de man → de mannen)
        • Soms: enkelvoud + -s (de auto → de auto's)
        • Speciale gevallen: kind → kinderen, stad → steden
        • Woorden die eindigen op -a, -o, -u, -i krijgen meestal -'s
        • Woorden die eindigen op -e, -el, -er, -en krijgen meestal -en
        
        Onthoud: alle meervouden krijgen 'de' als lidwoord.
        """,
        keyPoints: [
            "Meervoud meestal: + -en",
            "Soms: + -s (vooral bij woorden op -a, -o, -u, -i)",
            "Speciale gevallen moet je leren",
            "Alle meervouden krijgen 'de'",
            "Oefen met veel voorbeelden"
        ],
        examples: [
            GrammarExample(
                dutch: "de man",
                english: "the man",
                breakdown: "enkelvoud",
                audioHint: "də mɑn"
            ),
            GrammarExample(
                dutch: "de mannen",
                english: "the men",
                breakdown: "meervoud: man + en",
                audioHint: "də mɑnə(n)"
            ),
            GrammarExample(
                dutch: "het huis",
                english: "the house",
                breakdown: "enkelvoud",
                audioHint: "hət hɵis"
            ),
            GrammarExample(
                dutch: "de huizen",
                english: "the houses",
                breakdown: "meervoud: huis + en",
                audioHint: "də hɵizə(n)"
            ),
            GrammarExample(
                dutch: "de hond",
                english: "the dog",
                breakdown: "enkelvoud",
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
                breakdown: "enkelvoud",
                audioHint: "də ɑuto"
            ),
            GrammarExample(
                dutch: "de auto's",
                english: "the cars",
                breakdown: "meervoud: auto + 's",
                audioHint: "də ɑutos"
            ),
            GrammarExample(
                dutch: "het boek",
                english: "the book",
                breakdown: "enkelvoud",
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
                breakdown: "enkelvoud",
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
                breakdown: "enkelvoud",
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
                breakdown: "enkelvoud",
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
                breakdown: "enkelvoud",
                audioHint: "hət ideː"
            ),
            GrammarExample(
                dutch: "de ideeën",
                english: "the ideas",
                breakdown: "meervoud: idee + ën",
                audioHint: "də ideːə(n)"
            ),
            GrammarExample(
                dutch: "de stad",
                english: "the city",
                breakdown: "enkelvoud",
                audioHint: "də stɑt"
            ),
            GrammarExample(
                dutch: "de steden",
                english: "the cities",
                breakdown: "onregelmatig meervoud",
                audioHint: "də steːdə(n)"
            ),
            GrammarExample(
                dutch: "de foto",
                english: "the photo",
                breakdown: "enkelvoud",
                audioHint: "də foto"
            ),
            GrammarExample(
                dutch: "de foto's",
                english: "the photos",
                breakdown: "meervoud: foto + 's",
                audioHint: "də fotos"
            ),
            GrammarExample(
                dutch: "de radio",
                english: "the radio",
                breakdown: "enkelvoud",
                audioHint: "də radio"
            ),
            GrammarExample(
                dutch: "de radio's",
                english: "the radios",
                breakdown: "meervoud: radio + 's",
                audioHint: "də radios"
            ),
            GrammarExample(
                dutch: "de tafel",
                english: "the table",
                breakdown: "enkelvoud",
                audioHint: "də taːfəl"
            ),
            GrammarExample(
                dutch: "de tafels",
                english: "the tables",
                breakdown: "meervoud: tafel + s",
                audioHint: "də taːfəls"
            )
        ],
        exercises: [
            // Basic plural exercises
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
                question: "Wat is het meervoud van 'hond'?",
                options: ["honden", "honds", "hondes", "hondjes"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'hond' is 'honden' (hond + en)",
                hint: "Meestal voeg je -en toe"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'boek'?",
                options: ["boeken", "boeks", "boekes", "boekjes"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'boek' is 'boeken' (boek + en)",
                hint: "Meestal voeg je -en toe"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'school'?",
                options: ["scholen", "schools", "schooles", "schooljes"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'school' is 'scholen' (school + en)",
                hint: "Meestal voeg je -en toe"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'vriend'?",
                options: ["vrienden", "vriends", "vriendes", "vriendjes"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'vriend' is 'vrienden' (vriend + en)",
                hint: "Meestal voeg je -en toe"
            ),
            
            // -s plural exercises
            GrammarExercise(
                question: "Wat is het meervoud van 'auto'?",
                options: ["auto's", "autos", "auten", "autoën"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'auto' is 'auto's' (auto + 's)",
                hint: "Sommige woorden krijgen -'s"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'foto'?",
                options: ["foto's", "fotos", "foten", "fotoën"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'foto' is 'foto's' (foto + 's)",
                hint: "Woorden op -o krijgen meestal -'s"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'radio'?",
                options: ["radio's", "radios", "radien", "radioën"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'radio' is 'radio's' (radio + 's)",
                hint: "Woorden op -o krijgen meestal -'s"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'tafel'?",
                options: ["tafels", "tafelen", "tafeljes", "tafels"],
                correctAnswer: 0,
                explanation: "Het meervoud van 'tafel' is 'tafels' (tafel + s)",
                hint: "Sommige woorden op -el krijgen -s"
            ),
            
            // Irregular plural exercises
            GrammarExercise(
                question: "Wat is het meervoud van 'kind'?",
                options: ["kinds", "kindes", "kinderen", "kindjes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'kind' is 'kinderen' (onregelmatig)",
                hint: "Dit is een onregelmatig meervoud"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'stad'?",
                options: ["stads", "stades", "steden", "stadjes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'stad' is 'steden' (onregelmatig)",
                hint: "Dit is een onregelmatig meervoud"
            ),
            GrammarExercise(
                question: "Wat is het meervoud van 'idee'?",
                options: ["idees", "ideeën", "ideen", "ideejes"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'idee' is 'ideeën' (idee + ën)",
                hint: "Dit is een onregelmatig meervoud"
            ),
            
            // Fill in the blank exercises
            GrammarExercise(
                question: "Complete: 'De ___ blaffen' (The dogs bark)",
                options: ["hond", "honden", "honds", "hondes"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'hond' is 'honden' (hond + en)",
                hint: "Meestal voeg je -en toe",
                exerciseType: .fillInTheBlank
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
                question: "Complete: 'De ___ spelen buiten' (The children play outside)",
                options: ["kind", "kinds", "kinderen", "kindjes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'kind' is 'kinderen'",
                hint: "Dit is een onregelmatig meervoud",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn groot' (The houses are big)",
                options: ["huis", "huizen", "huises", "huisjes"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'huis' is 'huizen' (huis + en)",
                hint: "Meestal voeg je -en toe",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn interessant' (The books are interesting)",
                options: ["boek", "boeken", "boeks", "boekjes"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'boek' is 'boeken' (boek + en)",
                hint: "Meestal voeg je -en toe",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn mooi' (The photos are beautiful)",
                options: ["foto", "foto's", "fotos", "foten"],
                correctAnswer: 1,
                explanation: "Het meervoud van 'foto' is 'foto's'",
                hint: "Foto's krijgen -'s in meervoud",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn oud' (The cities are old)",
                options: ["stad", "stads", "steden", "stadjes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'stad' is 'steden'",
                hint: "Dit is een onregelmatig meervoud",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn vriendelijk' (The friends are friendly)",
                options: ["vriend", "vriends", "vrienden", "vriendjes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'vriend' is 'vrienden' (vriend + en)",
                hint: "Meestal voeg je -en toe",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn nieuw' (The tables are new)",
                options: ["tafel", "tafelen", "tafels", "tafeljes"],
                correctAnswer: 2,
                explanation: "Het meervoud van 'tafel' is 'tafels' (tafel + s)",
                hint: "Sommige woorden op -el krijgen -s",
                exerciseType: .fillInTheBlank
            ),
            
            // Translation exercises
            GrammarExercise(
                question: "How do you say 'The men work' in Dutch?",
                options: ["De man werken", "De mannen werken", "De mans werken", "De manen werken"],
                correctAnswer: 1,
                explanation: "De mannen werken - 'mannen' is het meervoud van 'man'",
                hint: "Mannen = men (plural of man)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The houses are big' in Dutch?",
                options: ["De huis zijn groot", "De huizen zijn groot", "De huises zijn groot", "De huisjes zijn groot"],
                correctAnswer: 1,
                explanation: "De huizen zijn groot - 'huizen' is het meervoud van 'huis'",
                hint: "Huizen = houses (plural of house)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The dogs bark' in Dutch?",
                options: ["De hond blaffen", "De honden blaffen", "De honds blaffen", "De hondes blaffen"],
                correctAnswer: 1,
                explanation: "De honden blaffen - 'honden' is het meervoud van 'hond'",
                hint: "Honden = dogs (plural of dog)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The cars are expensive' in Dutch?",
                options: ["De auto zijn duur", "De auto's zijn duur", "De autos zijn duur", "De auten zijn duur"],
                correctAnswer: 1,
                explanation: "De auto's zijn duur - 'auto's' is het meervoud van 'auto'",
                hint: "Auto's = cars (plural of car)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The children play' in Dutch?",
                options: ["De kind spelen", "De kinds spelen", "De kinderen spelen", "De kindjes spelen"],
                correctAnswer: 2,
                explanation: "De kinderen spelen - 'kinderen' is het meervoud van 'kind'",
                hint: "Kinderen = children (plural of child)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The books are interesting' in Dutch?",
                options: ["De boek zijn interessant", "De boeken zijn interessant", "De boeks zijn interessant", "De boekjes zijn interessant"],
                correctAnswer: 1,
                explanation: "De boeken zijn interessant - 'boeken' is het meervoud van 'boek'",
                hint: "Boeken = books (plural of book)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The schools are good' in Dutch?",
                options: ["De school zijn goed", "De scholen zijn goed", "De schools zijn goed", "De schooljes zijn goed"],
                correctAnswer: 1,
                explanation: "De scholen zijn goed - 'scholen' is het meervoud van 'school'",
                hint: "Scholen = schools (plural of school)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The friends are nice' in Dutch?",
                options: ["De vriend zijn aardig", "De vriends zijn aardig", "De vrienden zijn aardig", "De vriendjes zijn aardig"],
                correctAnswer: 2,
                explanation: "De vrienden zijn aardig - 'vrienden' is het meervoud van 'vriend'",
                hint: "Vrienden = friends (plural of friend)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The photos are beautiful' in Dutch?",
                options: ["De foto zijn mooi", "De foto's zijn mooi", "De fotos zijn mooi", "De foten zijn mooi"],
                correctAnswer: 1,
                explanation: "De foto's zijn mooi - 'foto's' is het meervoud van 'foto'",
                hint: "Foto's = photos (plural of photo)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The cities are old' in Dutch?",
                options: ["De stad zijn oud", "De stads zijn oud", "De steden zijn oud", "De stadjes zijn oud"],
                correctAnswer: 2,
                explanation: "De steden zijn oud - 'steden' is het meervoud van 'stad'",
                hint: "Steden = cities (plural of city)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The tables are new' in Dutch?",
                options: ["De tafel zijn nieuw", "De tafelen zijn nieuw", "De tafels zijn nieuw", "De tafeljes zijn nieuw"],
                correctAnswer: 2,
                explanation: "De tafels zijn nieuw - 'tafels' is het meervoud van 'tafel'",
                hint: "Tafels = tables (plural of table)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The radios work' in Dutch?",
                options: ["De radio werken", "De radio's werken", "De radios werken", "De radien werken"],
                correctAnswer: 1,
                explanation: "De radio's werken - 'radio's' is het meervoud van 'radio'",
                hint: "Radio's = radios (plural of radio)",
                exerciseType: .translation
            ),
            GrammarExercise(
                question: "How do you say 'The ideas are good' in Dutch?",
                options: ["De idee zijn goed", "De idees zijn goed", "De ideeën zijn goed", "De ideen zijn goed"],
                correctAnswer: 2,
                explanation: "De ideeën zijn goed - 'ideeën' is het meervoud van 'idee'",
                hint: "Ideeën = ideas (plural of idea)",
                exerciseType: .translation
            )
        ],
        commonMistakes: [
            CommonMistake(
                incorrect: "mans",
                correct: "mannen",
                explanation: "Het meervoud van 'man' is 'mannen' (man + en), niet 'mans'"
            ),
            CommonMistake(
                incorrect: "autos",
                correct: "auto's",
                explanation: "Het meervoud van 'auto' is 'auto's' (met apostrof), niet 'autos'"
            ),
            CommonMistake(
                incorrect: "kinds",
                correct: "kinderen",
                explanation: "Het meervoud van 'kind' is 'kinderen' (onregelmatig), niet 'kinds'"
            ),
            CommonMistake(
                incorrect: "stads",
                correct: "steden",
                explanation: "Het meervoud van 'stad' is 'steden' (onregelmatig), niet 'stads'"
            ),
            CommonMistake(
                incorrect: "fotos",
                correct: "foto's",
                explanation: "Het meervoud van 'foto' is 'foto's' (met apostrof), niet 'fotos'"
            ),
            CommonMistake(
                incorrect: "idees",
                correct: "ideeën",
                explanation: "Het meervoud van 'idee' is 'ideeën' (met trema), niet 'idees'"
            ),
            CommonMistake(
                incorrect: "tafelen",
                correct: "tafels",
                explanation: "Het meervoud van 'tafel' is 'tafels' (tafel + s), niet 'tafelen'"
            )
        ],
        tips: [
            "Meestal voeg je -en toe voor meervoud",
            "Woorden op -a, -o, -u, -i krijgen meestal -'s",
            "Sommige woorden op -el krijgen -s",
            "Onregelmatige meervouden moet je leren",
            "Oefen met veel voorbeelden",
            "Let op de spelling (apostrof bij -'s)",
            "Gebruik een woordenboek om te controleren"
        ],
        relatedRules: ["verb_present_a1", "adjectives_a2", "possessives_a2", "demonstratives_a2"]
    )
} 