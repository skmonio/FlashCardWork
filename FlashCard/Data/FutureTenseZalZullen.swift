import Foundation

// MARK: - Future Tense with Zal and Zullen Grammar Rule

extension DutchGrammarRulesDatabase {
    
    var futureTenseZalZullenA2: DutchGrammarRule {
        DutchGrammarRule(
            id: "future_tense_zal_zullen_a2",
            title: "Toekomende Tijd: Zal en Zullen (Future Tense) - A2",
            type: .tenses,
            level: .a2,
            explanation: """
            In Dutch, the future tense is formed using the auxiliary verbs 'zal' and 'zullen' combined with the infinitive of the main verb. This is similar to English 'will' and 'shall'.
            
            **Conjugation of Zullen:**
            • ik zal (I will/shall)
            • jij/je zult (you will/shall) - also: jij/je zal (informal)
            • hij/zij/het zal (he/she/it will/shall)
            • wij/we zullen (we will/shall)
            • jullie zullen (you all will/shall)
            • zij zullen (they will/shall)
            
            **Usage Patterns:**
            
            1. **Simple Future (will/shall):**
            • Ik zal morgen naar school gaan (I will go to school tomorrow)
            • Zij zullen volgende week verhuizen (They will move next week)
            
            2. **Intentions and Plans:**
            • Ik zal je helpen (I will help you)
            • We zullen het probleem oplossen (We will solve the problem)
            
            3. **Predictions:**
            • Het zal morgen regenen (It will rain tomorrow)
            • De trein zal op tijd komen (The train will arrive on time)
            
            4. **Promises and Offers:**
            • Ik zal het niet vergeten (I will not forget it)
            • Ik zal je bellen (I will call you)
            
            **Word Order:**
            • Subject + zal/zullen + infinitive + other elements
            • In questions: zal/zullen + subject + infinitive + other elements
            • With separable verbs: zal/zullen + subject + separated parts
            
            **Common Expressions:**
            • "Ik zal het proberen" (I will try)
            • "Het zal wel" (It will be fine/It's probably okay)
            • "Dat zal wel" (That's probably right)
            """,
            keyPoints: [
                "Zal = will/shall (singular: ik, hij/zij/het)",
                "Zullen = will/shall (plural: wij, jullie, zij)",
                "Jij/je can use both 'zult' (formal) and 'zal' (informal)",
                "Always use infinitive of main verb after zal/zullen",
                "Word order: Subject + zal/zullen + infinitive",
                "Used for future plans, predictions, promises",
                "Similar to English 'will' and 'shall'",
                "Common in everyday Dutch conversation"
            ],
            examples: [
                GrammarExample(
                    dutch: "Ik zal morgen naar Amsterdam gaan.",
                    english: "I will go to Amsterdam tomorrow.",
                    breakdown: "Subject (Ik) + zal + infinitive (gaan) + time + place",
                    audioHint: "ik zɑl mɔrɣə(n) naːr ɑmstərdɑm ɣaːn"
                ),
                GrammarExample(
                    dutch: "Zij zullen volgende week verhuizen.",
                    english: "They will move next week.",
                    breakdown: "Subject (Zij) + zullen + infinitive (verhuizen) + time",
                    audioHint: "zɛi zɵlə(n) vɔləɣəndə ʋeːk vərɵizə(n)"
                ),
                GrammarExample(
                    dutch: "Het zal morgen regenen.",
                    english: "It will rain tomorrow.",
                    breakdown: "Subject (Het) + zal + infinitive (regenen) + time",
                    audioHint: "hət zɑl mɔrɣə(n) reːɣənə(n)"
                ),
                GrammarExample(
                    dutch: "Wij zullen het probleem oplossen.",
                    english: "We will solve the problem.",
                    breakdown: "Subject (Wij) + zullen + object + infinitive (oplossen)",
                    audioHint: "ʋɛi zɵlə(n) hət proːbleːm ɔplɔsə(n)"
                ),
                GrammarExample(
                    dutch: "Ik zal je helpen met je huiswerk.",
                    english: "I will help you with your homework.",
                    breakdown: "Subject (Ik) + zal + object (je) + infinitive (helpen) + prepositional phrase",
                    audioHint: "ik zɑl jə hɛlpə(n) mət jə hɵisʋɛrk"
                ),
                GrammarExample(
                    dutch: "Zal ik de deur voor je openen?",
                    english: "Shall I open the door for you?",
                    breakdown: "Question: zal + subject (ik) + object + infinitive (openen)",
                    audioHint: "zɑl ik də døːr voːr jə oːpənə(n)"
                )
            ],
            exercises: [
                // Sentence Building Exercises
                GrammarExercise(
                    question: "Build the sentence: 'I will work tomorrow'",
                    options: ["Ik", "zal", "morgen", "werken"],
                    correctAnswer: 0,
                    explanation: "Ik zal morgen werken means 'I will work tomorrow'",
                    hint: "Start with 'Ik' (I)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Ik zal morgen werken"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'We will go to school'",
                    options: ["Wij", "zullen", "naar", "school", "gaan"],
                    correctAnswer: 0,
                    explanation: "Wij zullen naar school gaan means 'We will go to school'",
                    hint: "Start with 'Wij' (We)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Wij zullen naar school gaan"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'She will write a letter'",
                    options: ["Zij", "zal", "een", "brief", "schrijven"],
                    correctAnswer: 0,
                    explanation: "Zij zal een brief schrijven means 'She will write a letter'",
                    hint: "Start with 'Zij' (She)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zal een brief schrijven"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'They will arrive tomorrow'",
                    options: ["Zij", "zullen", "morgen", "aankomen"],
                    correctAnswer: 0,
                    explanation: "Zij zullen morgen aankomen means 'They will arrive tomorrow'",
                    hint: "Start with 'Zij' (They)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zullen morgen aankomen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'He will call you later'",
                    options: ["Hij", "zal", "je", "later", "bellen"],
                    correctAnswer: 0,
                    explanation: "Hij zal je later bellen means 'He will call you later'",
                    hint: "Start with 'Hij' (He)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Hij zal je later bellen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will you help me?'",
                    options: ["Zal", "je", "me", "helpen"],
                    correctAnswer: 0,
                    explanation: "Zal je me helpen? means 'Will you help me?'",
                    hint: "Questions start with 'Zal'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zal je me helpen?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'We will solve the problem'",
                    options: ["Wij", "zullen", "het", "probleem", "oplossen"],
                    correctAnswer: 0,
                    explanation: "Wij zullen het probleem oplossen means 'We will solve the problem'",
                    hint: "Start with 'Wij' (We)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Wij zullen het probleem oplossen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'It will rain tomorrow'",
                    options: ["Het", "zal", "morgen", "regenen"],
                    correctAnswer: 0,
                    explanation: "Het zal morgen regenen means 'It will rain tomorrow'",
                    hint: "Start with 'Het' (It)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Het zal morgen regenen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will they come to the party?'",
                    options: ["Zullen", "zij", "naar", "het", "feest", "komen"],
                    correctAnswer: 0,
                    explanation: "Zullen zij naar het feest komen? means 'Will they come to the party?'",
                    hint: "Questions start with 'Zullen'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zullen zij naar het feest komen?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'I will study Dutch next week'",
                    options: ["Ik", "zal", "volgende", "week", "Nederlands", "studeren"],
                    correctAnswer: 0,
                    explanation: "Ik zal volgende week Nederlands studeren means 'I will study Dutch next week'",
                    hint: "Start with 'Ik' (I)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Ik zal volgende week Nederlands studeren"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'She will buy a new car'",
                    options: ["Zij", "zal", "een", "nieuwe", "auto", "kopen"],
                    correctAnswer: 0,
                    explanation: "Zij zal een nieuwe auto kopen means 'She will buy a new car'",
                    hint: "Start with 'Zij' (She)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zal een nieuwe auto kopen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will you bring the books?'",
                    options: ["Zal", "je", "de", "boeken", "meenemen"],
                    correctAnswer: 0,
                    explanation: "Zal je de boeken meenemen? means 'Will you bring the books?'",
                    hint: "Questions start with 'Zal'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zal je de boeken meenemen?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'They will build a new house'",
                    options: ["Zij", "zullen", "een", "nieuw", "huis", "bouwen"],
                    correctAnswer: 0,
                    explanation: "Zij zullen een nieuw huis bouwen means 'They will build a new house'",
                    hint: "Start with 'Zij' (They)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zullen een nieuw huis bouwen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'He will give you the money'",
                    options: ["Hij", "zal", "je", "het", "geld", "geven"],
                    correctAnswer: 0,
                    explanation: "Hij zal je het geld geven means 'He will give you the money'",
                    hint: "Start with 'Hij' (He)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Hij zal je het geld geven"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will we see each other next week?'",
                    options: ["Zullen", "wij", "elkaar", "volgende", "week", "zien"],
                    correctAnswer: 0,
                    explanation: "Zullen wij elkaar volgende week zien? means 'Will we see each other next week?'",
                    hint: "Questions start with 'Zullen'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zullen wij elkaar volgende week zien?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'The train will arrive at 3 PM'",
                    options: ["De", "trein", "zal", "om", "3", "uur", "aankomen"],
                    correctAnswer: 0,
                    explanation: "De trein zal om 3 uur aankomen means 'The train will arrive at 3 PM'",
                    hint: "Start with 'De trein' (The train)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "De trein zal om 3 uur aankomen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'I will try to help you'",
                    options: ["Ik", "zal", "proberen", "je", "te", "helpen"],
                    correctAnswer: 0,
                    explanation: "Ik zal proberen je te helpen means 'I will try to help you'",
                    hint: "Start with 'Ik' (I)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Ik zal proberen je te helpen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will you tell me the truth?'",
                    options: ["Zal", "je", "me", "de", "waarheid", "vertellen"],
                    correctAnswer: 0,
                    explanation: "Zal je me de waarheid vertellen? means 'Will you tell me the truth?'",
                    hint: "Questions start with 'Zal'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zal je me de waarheid vertellen?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'She will make dinner for us'",
                    options: ["Zij", "zal", "voor", "ons", "eten", "maken"],
                    correctAnswer: 0,
                    explanation: "Zij zal voor ons eten maken means 'She will make dinner for us'",
                    hint: "Start with 'Zij' (She)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zal voor ons eten maken"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'They will wait for you at the station'",
                    options: ["Zij", "zullen", "op", "je", "wachten", "op", "het", "station"],
                    correctAnswer: 0,
                    explanation: "Zij zullen op je wachten op het station means 'They will wait for you at the station'",
                    hint: "Start with 'Zij' (They)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zullen op je wachten op het station"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will he remember our appointment?'",
                    options: ["Zal", "hij", "onze", "afspraak", "onthouden"],
                    correctAnswer: 0,
                    explanation: "Zal hij onze afspraak onthouden? means 'Will he remember our appointment?'",
                    hint: "Questions start with 'Zal'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zal hij onze afspraak onthouden?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'We will start the meeting at 2 PM'",
                    options: ["Wij", "zullen", "de", "vergadering", "om", "2", "uur", "beginnen"],
                    correctAnswer: 0,
                    explanation: "Wij zullen de vergadering om 2 uur beginnen means 'We will start the meeting at 2 PM'",
                    hint: "Start with 'Wij' (We)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Wij zullen de vergadering om 2 uur beginnen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'I will explain everything to you'",
                    options: ["Ik", "zal", "je", "alles", "uitleggen"],
                    correctAnswer: 0,
                    explanation: "Ik zal je alles uitleggen means 'I will explain everything to you'",
                    hint: "Start with 'Ik' (I)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Ik zal je alles uitleggen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will they understand the problem?'",
                    options: ["Zullen", "zij", "het", "probleem", "begrijpen"],
                    correctAnswer: 0,
                    explanation: "Zullen zij het probleem begrijpen? means 'Will they understand the problem?'",
                    hint: "Questions start with 'Zullen'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zullen zij het probleem begrijpen?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'The weather will be nice tomorrow'",
                    options: ["Het", "weer", "zal", "morgen", "mooi", "zijn"],
                    correctAnswer: 0,
                    explanation: "Het weer zal morgen mooi zijn means 'The weather will be nice tomorrow'",
                    hint: "Start with 'Het weer' (The weather)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Het weer zal morgen mooi zijn"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'She will become a doctor'",
                    options: ["Zij", "zal", "dokter", "worden"],
                    correctAnswer: 0,
                    explanation: "Zij zal dokter worden means 'She will become a doctor'",
                    hint: "Start with 'Zij' (She)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zal dokter worden"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will you be ready on time?'",
                    options: ["Zal", "je", "op", "tijd", "klaar", "zijn"],
                    correctAnswer: 0,
                    explanation: "Zal je op tijd klaar zijn? means 'Will you be ready on time?'",
                    hint: "Questions start with 'Zal'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zal je op tijd klaar zijn?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'They will stay here for a week'",
                    options: ["Zij", "zullen", "hier", "een", "week", "blijven"],
                    correctAnswer: 0,
                    explanation: "Zij zullen hier een week blijven means 'They will stay here for a week'",
                    hint: "Start with 'Zij' (They)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zij zullen hier een week blijven"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'I will find a solution to this problem'",
                    options: ["Ik", "zal", "een", "oplossing", "voor", "dit", "probleem", "vinden"],
                    correctAnswer: 0,
                    explanation: "Ik zal een oplossing voor dit probleem vinden means 'I will find a solution to this problem'",
                    hint: "Start with 'Ik' (I)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Ik zal een oplossing voor dit probleem vinden"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will he agree with our plan?'",
                    options: ["Zal", "hij", "akkoord", "gaan", "met", "ons", "plan"],
                    correctAnswer: 0,
                    explanation: "Zal hij akkoord gaan met ons plan? means 'Will he agree with our plan?'",
                    hint: "Questions start with 'Zal'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zal hij akkoord gaan met ons plan?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'We will need more time for this project'",
                    options: ["Wij", "zullen", "meer", "tijd", "nodig", "hebben", "voor", "dit", "project"],
                    correctAnswer: 0,
                    explanation: "Wij zullen meer tijd nodig hebben voor dit project means 'We will need more time for this project'",
                    hint: "Start with 'Wij' (We)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Wij zullen meer tijd nodig hebben voor dit project"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will she be able to come to the meeting?'",
                    options: ["Zal", "zij", "naar", "de", "vergadering", "kunnen", "komen"],
                    correctAnswer: 0,
                    explanation: "Zal zij naar de vergadering kunnen komen? means 'Will she be able to come to the meeting?'",
                    hint: "Questions start with 'Zal'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zal zij naar de vergadering kunnen komen?"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'The children will play in the garden'",
                    options: ["De", "kinderen", "zullen", "in", "de", "tuin", "spelen"],
                    correctAnswer: 0,
                    explanation: "De kinderen zullen in de tuin spelen means 'The children will play in the garden'",
                    hint: "Start with 'De kinderen' (The children)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "De kinderen zullen in de tuin spelen"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'I will think about your proposal'",
                    options: ["Ik", "zal", "over", "jouw", "voorstel", "nadenken"],
                    correctAnswer: 0,
                    explanation: "Ik zal over jouw voorstel nadenken means 'I will think about your proposal'",
                    hint: "Start with 'Ik' (I)",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Ik zal over jouw voorstel nadenken"
                ),
                GrammarExercise(
                    question: "Build the sentence: 'Will they remember to bring the documents?'",
                    options: ["Zullen", "zij", "denken", "aan", "het", "meenemen", "van", "de", "documenten"],
                    correctAnswer: 0,
                    explanation: "Zullen zij denken aan het meenemen van de documenten? means 'Will they remember to bring the documents?'",
                    hint: "Questions start with 'Zullen'",
                    exerciseType: .sentenceBuilding,
                    correctSentence: "Zullen zij denken aan het meenemen van de documenten?"
                )
            ],
            commonMistakes: [
                CommonMistake(
                    incorrect: "Ik zullen",
                    correct: "Ik zal",
                    explanation: "'Ik' uses 'zal', not 'zullen'. 'Zullen' is for plural subjects (wij, jullie, zij)"
                ),
                CommonMistake(
                    incorrect: "Wij zal",
                    correct: "Wij zullen",
                    explanation: "'Wij' uses 'zullen', not 'zal'. 'Zal' is for singular subjects (ik, hij, zij, het)"
                ),
                CommonMistake(
                    incorrect: "Ik zal ga",
                    correct: "Ik zal gaan",
                    explanation: "After 'zal', use the infinitive form of the verb (gaan), not the stem (ga)"
                ),
                CommonMistake(
                    incorrect: "Zij zullen komt",
                    correct: "Zij zullen komen",
                    explanation: "After 'zullen', use the infinitive form of the verb (komen), not the conjugated form (komt)"
                ),
                CommonMistake(
                    incorrect: "Ik ga je helpen",
                    correct: "Ik zal je helpen",
                    explanation: "For future tense with certainty, use 'zal' rather than 'gaan'. 'Gaan' suggests immediate future or intention"
                ),
                CommonMistake(
                    incorrect: "Hij wil morgen komen",
                    correct: "Hij zal morgen komen",
                    explanation: "For future tense, use 'zal' rather than 'wil'. 'Wil' means 'want', not 'will'"
                )
            ],
            tips: [
                "Learn the conjugation: ik/hij/zij/het = zal, wij/jullie/zij = zullen",
                "Always use infinitive after zal/zullen",
                "Zal/zullen is for future tense, not present tense",
                "Use zal/zullen for predictions, promises, and plans",
                "In questions, zal/zullen comes first",
                "Jij/je can use both 'zult' (formal) and 'zal' (informal)",
                "Practice with common expressions like 'Ik zal het proberen'",
                "Remember: zal/zullen + infinitive = future tense",
                "Don't confuse 'wil' (want) with 'zal' (will)",
                "Use zal/zullen for definite future plans, not just intentions"
            ],
            relatedRules: ["verb_present_a1", "verb_past_a2", "auxiliary_verbs_b1", "word_order_a1"]
        )
    }
} 