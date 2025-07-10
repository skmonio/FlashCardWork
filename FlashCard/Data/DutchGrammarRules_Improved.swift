import Foundation

// MARK: - Improved Dutch Nouns and Articles Grammar Rule
// This is an improved version with English explanations and many more examples

struct ImprovedDutchNounsGrammarRule {
    static let dutchNounsAndArticlesA1 = DutchGrammarRule(
        id: "dutch_articles_a1_improved",
        title: "Dutch Nouns and Articles - Understanding Zelfstandige Naamwoorden (A1)",
        type: .pluralization,
        level: .a1,
        explanation: """
        In Dutch, all nouns (zelfstandige naamwoorden) have a gender: masculine, feminine, or neuter. This determines which article you use: 'de' or 'het'.
        
        There are two types of articles:
        • DE-words: masculine and feminine words (de man, de vrouw, de auto)
        • HET-words: neuter words (het huis, het boek, het kind)
        
        Important rules:
        • All plurals use 'de' (de mannen, de huizen)
        • Diminutives always use 'het' (het mannetje, het huisje)
        • Words ending in -heid, -nis, -ing, -st are usually DE-words
        • Words ending in -je, -tje are always HET-words
        • Many words you just have to learn (no clear rule)
        
        Plural formation:
        • Usually: singular + -en (de man → de mannen)
        • Sometimes: singular + -s (de auto → de auto's)
        • Special cases: kind → kinderen, stad → steden
        
        Understanding independent forms:
        • The independent form is the basic noun without any article
        • It's used in dictionaries and when learning vocabulary
        • Example: "huis" (house) is the independent form, "het huis" is with article
        """,
        keyPoints: [
            "All nouns have a gender (masculine, feminine, or neuter)",
            "DE for masculine/feminine words",
            "HET for neuter words",
            "All plurals use DE",
            "Diminutives always use HET",
            "Plural usually: + -en, sometimes + -s",
            "Many words you just have to learn",
            "Independent form = basic noun without article"
        ],
        examples: [
            // Basic examples with articles
            GrammarExample(
                dutch: "de man",
                english: "the man",
                breakdown: "masculine → de",
                audioHint: "də mɑn"
            ),
            GrammarExample(
                dutch: "de mannen",
                english: "the men",
                breakdown: "plural → always de",
                audioHint: "də mɑnə(n)"
            ),
            GrammarExample(
                dutch: "het huis",
                english: "the house",
                breakdown: "neuter → het",
                audioHint: "hət hɵis"
            ),
            GrammarExample(
                dutch: "de huizen",
                english: "the houses",
                breakdown: "plural → always de",
                audioHint: "də hɵizə(n)"
            ),
            
            // More examples with independent forms
            GrammarExample(
                dutch: "hond (de hond)",
                english: "dog (the dog)",
                breakdown: "independent form → with article",
                audioHint: "hɔnt (də hɔnt)"
            ),
            GrammarExample(
                dutch: "honden (de honden)",
                english: "dogs (the dogs)",
                breakdown: "plural: hond + en",
                audioHint: "hɔndə(n) (də hɔndə(n))"
            ),
            GrammarExample(
                dutch: "auto (de auto)",
                english: "car (the car)",
                breakdown: "independent form → with article",
                audioHint: "ɑuto (də ɑuto)"
            ),
            GrammarExample(
                dutch: "auto's (de auto's)",
                english: "cars (the cars)",
                breakdown: "plural: auto + 's",
                audioHint: "ɑutos (də ɑutos)"
            ),
            GrammarExample(
                dutch: "boek (het boek)",
                english: "book (the book)",
                breakdown: "independent form → with article",
                audioHint: "buk (hət buk)"
            ),
            GrammarExample(
                dutch: "boeken (de boeken)",
                english: "books (the books)",
                breakdown: "plural: boek + en",
                audioHint: "bukə(n) (də bukə(n))"
            ),
            GrammarExample(
                dutch: "kind (het kind)",
                english: "child (the child)",
                breakdown: "independent form → with article",
                audioHint: "kɪnt (hət kɪnt)"
            ),
            GrammarExample(
                dutch: "kinderen (de kinderen)",
                english: "children (the children)",
                breakdown: "irregular plural",
                audioHint: "kɪndərə(n) (də kɪndərə(n))"
            ),
            
            // More vocabulary examples
            GrammarExample(
                dutch: "vriend (de vriend)",
                english: "friend (the friend)",
                breakdown: "independent form → with article",
                audioHint: "vrint (də vrint)"
            ),
            GrammarExample(
                dutch: "vrienden (de vrienden)",
                english: "friends (the friends)",
                breakdown: "plural: vriend + en",
                audioHint: "vrində(n) (də vrində(n))"
            ),
            GrammarExample(
                dutch: "idee (het idee)",
                english: "idea (the idea)",
                breakdown: "independent form → with article",
                audioHint: "ideː (hət ideː)"
            ),
            GrammarExample(
                dutch: "ideeën (de ideeën)",
                english: "ideas (the ideas)",
                breakdown: "plural: idee + ën",
                audioHint: "ideːə(n) (də ideːə(n))"
            ),
            GrammarExample(
                dutch: "stad (de stad)",
                english: "city (the city)",
                breakdown: "independent form → with article",
                audioHint: "stɑt (də stɑt)"
            ),
            GrammarExample(
                dutch: "steden (de steden)",
                english: "cities (the cities)",
                breakdown: "irregular plural",
                audioHint: "steːdə(n) (də steːdə(n))"
            ),
            GrammarExample(
                dutch: "land (het land)",
                english: "country (the country)",
                breakdown: "independent form → with article",
                audioHint: "lɑnt (hət lɑnt)"
            ),
            GrammarExample(
                dutch: "landen (de landen)",
                english: "countries (the countries)",
                breakdown: "plural: land + en",
                audioHint: "lɑndə(n) (də lɑndə(n))"
            ),
            
            // Diminutives
            GrammarExample(
                dutch: "mannetje (het mannetje)",
                english: "little man (the little man)",
                breakdown: "diminutive → always het",
                audioHint: "mɑnətjə (hət mɑnətjə)"
            ),
            GrammarExample(
                dutch: "huisje (het huisje)",
                english: "little house (the little house)",
                breakdown: "diminutive → always het",
                audioHint: "hɵisjə (hət hɵisjə)"
            ),
            GrammarExample(
                dutch: "hondje (het hondje)",
                english: "little dog (the little dog)",
                breakdown: "diminutive → always het",
                audioHint: "hɔntjə (hət hɔntjə)"
            ),
            
            // Pattern words
            GrammarExample(
                dutch: "vrijheid (de vrijheid)",
                english: "freedom (the freedom)",
                breakdown: "ends in -heid → de",
                audioHint: "vrɛihɛit (də vrɛihɛit)"
            ),
            GrammarExample(
                dutch: "kennis (de kennis)",
                english: "knowledge (the knowledge)",
                breakdown: "ends in -nis → de",
                audioHint: "kɛnis (də kɛnis)"
            ),
            GrammarExample(
                dutch: "vergadering (de vergadering)",
                english: "meeting (the meeting)",
                breakdown: "ends in -ing → de",
                audioHint: "vərɣaːdərɪŋ (də vərɣaːdərɪŋ)"
            ),
            GrammarExample(
                dutch: "kunst (de kunst)",
                english: "art (the art)",
                breakdown: "ends in -st → de",
                audioHint: "kɵnst (də kɵnst)"
            ),
            
            // More common words
            GrammarExample(
                dutch: "school (de school)",
                english: "school (the school)",
                breakdown: "feminine → de",
                audioHint: "sxoːl (də sxoːl)"
            ),
            GrammarExample(
                dutch: "scholen (de scholen)",
                english: "schools (the schools)",
                breakdown: "plural: school + en",
                audioHint: "sxoːlə(n) (də sxoːlə(n))"
            ),
            GrammarExample(
                dutch: "tafel (de tafel)",
                english: "table (the table)",
                breakdown: "feminine → de",
                audioHint: "taːfəl (də taːfəl)"
            ),
            GrammarExample(
                dutch: "tafels (de tafels)",
                english: "tables (the tables)",
                breakdown: "plural: tafel + s",
                audioHint: "taːfəls (də taːfəls)"
            ),
            GrammarExample(
                dutch: "water (het water)",
                english: "water (the water)",
                breakdown: "neuter → het",
                audioHint: "vaːtər (hət vaːtər)"
            ),
            GrammarExample(
                dutch: "winkels (de winkels)",
                english: "shops (the shops)",
                breakdown: "plural: winkel + s",
                audioHint: "vɪŋkəls (də vɪŋkəls)"
            )
        ],
        exercises: [
            // Article exercises
            GrammarExercise(
                question: "Which article do you use for 'man'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "'Man' is a masculine word, so use 'de'",
                hint: "Masculine words get 'de'"
            ),
            GrammarExercise(
                question: "Which article do you use for 'huis'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 1,
                explanation: "'Huis' is a neuter word, so use 'het'",
                hint: "Neuter words get 'het'"
            ),
            GrammarExercise(
                question: "Complete: '___ hond blaft' (The dog barks)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 0,
                explanation: "'Hond' is a masculine word, so 'De hond blaft'",
                hint: "Dogs are masculine",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "Complete: '___ boek is interessant' (The book is interesting)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 1,
                explanation: "'Boek' is a neuter word, so 'Het boek is interessant'",
                hint: "Books are neuter",
                exerciseType: .fillInTheBlank
            ),
            
            // Plural exercises with independent forms
            GrammarExercise(
                question: "What is the plural of 'man' (independent form)?",
                options: ["mans", "mannen", "manen", "mannes"],
                correctAnswer: 1,
                explanation: "The plural of 'man' is 'mannen' (man + en)",
                hint: "Usually add -en"
            ),
            GrammarExercise(
                question: "What is the plural of 'huis' (independent form)?",
                options: ["huizen", "huises", "huisjes", "huizen"],
                correctAnswer: 0,
                explanation: "The plural of 'huis' is 'huizen' (huis + en)",
                hint: "Usually add -en"
            ),
            GrammarExercise(
                question: "Complete: 'De ___ blaffen' (The dogs bark)",
                options: ["hond", "honden", "honds", "hondes"],
                correctAnswer: 1,
                explanation: "The plural of 'hond' is 'honden' (hond + en)",
                hint: "Usually add -en",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "What is the plural of 'auto' (independent form)?",
                options: ["auto's", "autos", "auten", "autoën"],
                correctAnswer: 0,
                explanation: "The plural of 'auto' is 'auto's' (auto + 's)",
                hint: "Some words get -s"
            ),
            GrammarExercise(
                question: "Complete: 'De ___ zijn duur' (The cars are expensive)",
                options: ["auto", "auto's", "autos", "auten"],
                correctAnswer: 1,
                explanation: "The plural of 'auto' is 'auto's'",
                hint: "Auto's get -'s in plural",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "What is the plural of 'kind' (independent form)?",
                options: ["kinds", "kindes", "kinderen", "kindjes"],
                correctAnswer: 2,
                explanation: "The plural of 'kind' is 'kinderen' (irregular)",
                hint: "This is an irregular plural"
            ),
            GrammarExercise(
                question: "Complete: 'De ___ spelen buiten' (The children play outside)",
                options: ["kind", "kinds", "kinderen", "kindjes"],
                correctAnswer: 2,
                explanation: "The plural of 'kind' is 'kinderen'",
                hint: "This is an irregular plural",
                exerciseType: .fillInTheBlank
            ),
            
            // More plural exercises
            GrammarExercise(
                question: "What is the plural of 'vriend' (independent form)?",
                options: ["vriends", "vrienden", "vriendes", "vriendjes"],
                correctAnswer: 1,
                explanation: "The plural of 'vriend' is 'vrienden' (vriend + en)",
                hint: "Usually add -en"
            ),
            GrammarExercise(
                question: "What is the plural of 'stad' (independent form)?",
                options: ["stads", "steden", "stadden", "stades"],
                correctAnswer: 1,
                explanation: "The plural of 'stad' is 'steden' (irregular)",
                hint: "This is an irregular plural"
            ),
            GrammarExercise(
                question: "What is the plural of 'land' (independent form)?",
                options: ["lands", "landen", "landes", "landjes"],
                correctAnswer: 1,
                explanation: "The plural of 'land' is 'landen' (land + en)",
                hint: "Usually add -en"
            ),
            GrammarExercise(
                question: "What is the plural of 'tafel' (independent form)?",
                options: ["tafels", "tafelen", "tafelden", "tafels"],
                correctAnswer: 0,
                explanation: "The plural of 'tafel' is 'tafels' (tafel + s)",
                hint: "Some words get -s"
            ),
            
            // Independent form exercises
            GrammarExercise(
                question: "What is the independent form of 'de hond'?",
                options: ["hond", "honden", "hondje", "honds"],
                correctAnswer: 0,
                explanation: "The independent form is 'hond' (without article)",
                hint: "Remove the article to get the independent form"
            ),
            GrammarExercise(
                question: "What is the independent form of 'het boek'?",
                options: ["boek", "boeken", "boekje", "boeks"],
                correctAnswer: 0,
                explanation: "The independent form is 'boek' (without article)",
                hint: "Remove the article to get the independent form"
            ),
            GrammarExercise(
                question: "What is the independent form of 'de auto'?",
                options: ["auto", "auto's", "autootje", "autos"],
                correctAnswer: 0,
                explanation: "The independent form is 'auto' (without article)",
                hint: "Remove the article to get the independent form"
            ),
            
            // Diminutive exercises
            GrammarExercise(
                question: "Which article do you use for 'mannetje'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 1,
                explanation: "Diminutives always use 'het'",
                hint: "Diminutives are always neuter"
            ),
            GrammarExercise(
                question: "Complete: '___ huisje is klein' (The little house is small)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 1,
                explanation: "Diminutives always use 'het'",
                hint: "Huisje is a diminutive",
                exerciseType: .fillInTheBlank
            ),
            GrammarExercise(
                question: "What is the diminutive of 'hond'?",
                options: ["hondje", "hondetje", "hondje", "hondje"],
                correctAnswer: 0,
                explanation: "The diminutive of 'hond' is 'hondje'",
                hint: "Add -je to make a diminutive"
            ),
            
            // Pattern exercises
            GrammarExercise(
                question: "Which article do you use for 'vrijheid'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "Words ending in -heid use 'de'",
                hint: "Look at the ending of the word"
            ),
            GrammarExercise(
                question: "Which article do you use for 'vergadering'?",
                options: ["de", "het", "een", "geen"],
                correctAnswer: 0,
                explanation: "Words ending in -ing use 'de'",
                hint: "Look at the ending of the word"
            ),
            GrammarExercise(
                question: "Complete: '___ kennis is macht' (Knowledge is power)",
                options: ["De", "Het", "Een", "Geen"],
                correctAnswer: 0,
                explanation: "Words ending in -nis use 'de'",
                hint: "Kennis ends in -nis",
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
                question: "How do you say 'The dogs are friendly' in Dutch?",
                options: ["De honden zijn vriendelijk", "Het honden zijn vriendelijk", "De hond zijn vriendelijk", "Het hond zijn vriendelijk"],
                correctAnswer: 0,
                explanation: "De honden zijn vriendelijk - plural nouns always use 'de'",
                hint: "All plurals use 'de'",
                exerciseType: .translation
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
            GrammarExercise(
                question: "True or False: The independent form of a noun includes the article",
                options: ["True", "False"],
                correctAnswer: 1,
                explanation: "False! The independent form is the basic noun without any article (e.g., 'huis' not 'het huis').",
                hint: "Think about what 'independent' means",
                exerciseType: .trueFalse
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
                explanation: "All plurals use 'de', not 'het'"
            ),
            CommonMistake(
                incorrect: "de huisje",
                correct: "het huisje",
                explanation: "Diminutives always use 'het', not 'de'"
            ),
            CommonMistake(
                incorrect: "het vrijheid",
                correct: "de vrijheid",
                explanation: "Words ending in -heid use 'de', not 'het'"
            ),
            CommonMistake(
                incorrect: "het vergadering",
                correct: "de vergadering",
                explanation: "Words ending in -ing use 'de', not 'het'"
            ),
            CommonMistake(
                incorrect: "mans",
                correct: "mannen",
                explanation: "The plural of 'man' is 'mannen', not 'mans'"
            ),
            CommonMistake(
                incorrect: "kinds",
                correct: "kinderen",
                explanation: "The plural of 'kind' is 'kinderen', not 'kinds'"
            ),
            CommonMistake(
                incorrect: "stads",
                correct: "steden",
                explanation: "The plural of 'stad' is 'steden', not 'stads'"
            )
        ],
        tips: [
            "Learn nouns with their articles from the beginning",
            "Pay attention to word endings that indicate gender",
            "Practice with both singular and plural forms",
            "Remember that all plurals use 'de'",
            "Use the independent form when learning vocabulary",
            "Focus on understanding them when listening to Dutch"
        ],
        relatedRules: ["basic_word_order_a1", "dutch_articles_a1", "pronouns_a1", "informal_speech_a2"]
    )
} 