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
                // Fill-in-the-blank (conjugation)
                GrammarExercise(
                    question: "Complete: 'Ik ___ morgen naar school gaan' (I will go to school tomorrow)",
                    options: ["zal", "zullen", "zult"],
                    correctAnswer: 0,
                    explanation: "Ik zal morgen naar school gaan - 'ik' uses 'zal'",
                    hint: "Remember: ik = zal",
                    exerciseType: .fillInTheBlank
                ),
                GrammarExercise(
                    question: "Complete: 'Wij ___ volgende week verhuizen' (We will move next week)",
                    options: ["zal", "zullen", "zult"],
                    correctAnswer: 1,
                    explanation: "Wij zullen volgende week verhuizen - 'wij' uses 'zullen'",
                    hint: "Remember: wij = zullen",
                    exerciseType: .fillInTheBlank
                ),
                GrammarExercise(
                    question: "Complete: 'Hij ___ je bellen' (He will call you)",
                    options: ["zal", "zullen", "zult"],
                    correctAnswer: 0,
                    explanation: "Hij zal je bellen - 'hij' uses 'zal'",
                    hint: "Remember: hij = zal",
                    exerciseType: .fillInTheBlank
                ),
                // Word order multiple choice
                GrammarExercise(
                    question: "Choose the correct word order: 'I will go to school tomorrow' (Ik / zal / morgen / naar school / gaan)",
                    options: [
                        "Ik zal morgen naar school gaan",
                        "Zal ik morgen naar school gaan",
                        "Morgen zal ik naar school gaan"
                    ],
                    correctAnswer: 0,
                    explanation: "Ik zal morgen naar school gaan is the correct word order for a statement.",
                    hint: "Subject + zal + time + place + infinitive",
                    exerciseType: .multipleChoice
                ),
                GrammarExercise(
                    question: "Choose the correct word order: 'We will solve the problem' (Wij / zullen / het probleem / oplossen)",
                    options: [
                        "Wij zullen het probleem oplossen",
                        "Zullen wij het probleem oplossen",
                        "Het probleem zullen wij oplossen"
                    ],
                    correctAnswer: 0,
                    explanation: "Wij zullen het probleem oplossen is the correct word order for a statement.",
                    hint: "Subject + zullen + object + infinitive",
                    exerciseType: .multipleChoice
                ),
                GrammarExercise(
                    question: "Choose the correct word order: 'Will you help me?' (Zal / je / me / helpen)",
                    options: [
                        "Zal je me helpen?",
                        "Je zal me helpen?",
                        "Me zal je helpen?"
                    ],
                    correctAnswer: 0,
                    explanation: "Zal je me helpen? is the correct word order for a yes/no question.",
                    hint: "Zal/zullen + subject + object + infinitive",
                    exerciseType: .multipleChoice
                ),
                GrammarExercise(
                    question: "Choose the correct word order: 'They will arrive tomorrow' (Zij / zullen / morgen / aankomen)",
                    options: [
                        "Zij zullen morgen aankomen",
                        "Zullen zij morgen aankomen",
                        "Morgen zullen zij aankomen"
                    ],
                    correctAnswer: 0,
                    explanation: "Zij zullen morgen aankomen is the correct word order for a statement.",
                    hint: "Subject + zullen + time + infinitive",
                    exerciseType: .multipleChoice
                ),
                GrammarExercise(
                    question: "Choose the correct word order: 'Shall I open the window?' (Zal / ik / het raam / openen)",
                    options: [
                        "Zal ik het raam openen?",
                        "Ik zal het raam openen?",
                        "Het raam zal ik openen?"
                    ],
                    correctAnswer: 0,
                    explanation: "Zal ik het raam openen? is the correct word order for a yes/no question.",
                    hint: "Zal/zullen + subject + object + infinitive",
                    exerciseType: .multipleChoice
                ),
                
                // SENTENCE ORDERING EXERCISES - More challenging
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'I will study Dutch tomorrow'",
                    options: ["Ik zal morgen Nederlands studeren", "Morgen zal ik Nederlands studeren", "Ik zal Nederlands morgen studeren", "Nederlands zal ik morgen studeren"],
                    correctAnswer: 0,
                    explanation: "Ik zal morgen Nederlands studeren - Subject + zal + time + object + infinitive",
                    hint: "Remember: Subject + zal + time + object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'We will visit our grandparents next week'",
                    options: ["Wij zullen volgende week onze grootouders bezoeken", "Volgende week zullen wij onze grootouders bezoeken", "Wij zullen onze grootouders volgende week bezoeken", "Onze grootouders zullen wij volgende week bezoeken"],
                    correctAnswer: 0,
                    explanation: "Wij zullen volgende week onze grootouders bezoeken - Subject + zullen + time + object + infinitive",
                    hint: "Remember: Subject + zullen + time + object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will you come to the party?'",
                    options: ["Zal je naar het feest komen?", "Je zal naar het feest komen?", "Naar het feest zal je komen?", "Komen zal je naar het feest?"],
                    correctAnswer: 0,
                    explanation: "Zal je naar het feest komen? - Question: zal + subject + prepositional phrase + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'She will buy a new car next month'",
                    options: ["Zij zal volgende maand een nieuwe auto kopen", "Volgende maand zal zij een nieuwe auto kopen", "Zij zal een nieuwe auto volgende maand kopen", "Een nieuwe auto zal zij volgende maand kopen"],
                    correctAnswer: 0,
                    explanation: "Zij zal volgende maand een nieuwe auto kopen - Subject + zal + time + object + infinitive",
                    hint: "Remember: Subject + zal + time + object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'They will finish the project on time'",
                    options: ["Zij zullen het project op tijd afmaken", "Het project zullen zij op tijd afmaken", "Zij zullen op tijd het project afmaken", "Op tijd zullen zij het project afmaken"],
                    correctAnswer: 0,
                    explanation: "Zij zullen het project op tijd afmaken - Subject + zullen + object + time + infinitive",
                    hint: "Remember: Subject + zullen + object + time + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Shall I help you with your homework?'",
                    options: ["Zal ik je helpen met je huiswerk?", "Ik zal je helpen met je huiswerk?", "Je zal ik helpen met je huiswerk?", "Helpen zal ik je met je huiswerk?"],
                    correctAnswer: 0,
                    explanation: "Zal ik je helpen met je huiswerk? - Question: zal + subject + object + infinitive + prepositional phrase",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'It will rain tomorrow afternoon'",
                    options: ["Het zal morgenmiddag regenen", "Morgenmiddag zal het regenen", "Het zal regenen morgenmiddag", "Regenen zal het morgenmiddag"],
                    correctAnswer: 0,
                    explanation: "Het zal morgenmiddag regenen - Subject + zal + time + infinitive",
                    hint: "Remember: Subject + zal + time + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'We will have dinner at eight o'clock'",
                    options: ["Wij zullen om acht uur eten", "Om acht uur zullen wij eten", "Wij zullen eten om acht uur", "Eten zullen wij om acht uur"],
                    correctAnswer: 0,
                    explanation: "Wij zullen om acht uur eten - Subject + zullen + time + infinitive",
                    hint: "Remember: Subject + zullen + time + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will they arrive at the station?'",
                    options: ["Zullen zij op het station aankomen?", "Zij zullen op het station aankomen?", "Op het station zullen zij aankomen?", "Aankomen zullen zij op het station?"],
                    correctAnswer: 0,
                    explanation: "Zullen zij op het station aankomen? - Question: zullen + subject + prepositional phrase + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'I will call you later'",
                    options: ["Ik zal je later bellen", "Later zal ik je bellen", "Ik zal bellen je later", "Bellen zal ik je later"],
                    correctAnswer: 0,
                    explanation: "Ik zal je later bellen - Subject + zal + object + time + infinitive",
                    hint: "Remember: Subject + zal + object + time + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'She will send you an email'",
                    options: ["Zij zal je een email sturen", "Je zal zij een email sturen", "Een email zal zij je sturen", "Sturen zal zij je een email"],
                    correctAnswer: 0,
                    explanation: "Zij zal je een email sturen - Subject + zal + indirect object + direct object + infinitive",
                    hint: "Remember: Subject + zal + indirect object + direct object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will you bring the books to school?'",
                    options: ["Zal je de boeken naar school meenemen?", "Je zal de boeken naar school meenemen?", "De boeken zal je naar school meenemen?", "Meenemen zal je de boeken naar school?"],
                    correctAnswer: 0,
                    explanation: "Zal je de boeken naar school meenemen? - Question: zal + subject + object + prepositional phrase + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'They will build a new house'",
                    options: ["Zij zullen een nieuw huis bouwen", "Een nieuw huis zullen zij bouwen", "Zij zullen bouwen een nieuw huis", "Bouwen zullen zij een nieuw huis"],
                    correctAnswer: 0,
                    explanation: "Zij zullen een nieuw huis bouwen - Subject + zullen + object + infinitive",
                    hint: "Remember: Subject + zullen + object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'He will give you the money tomorrow'",
                    options: ["Hij zal je morgen het geld geven", "Morgen zal hij je het geld geven", "Hij zal het geld je morgen geven", "Geven zal hij je morgen het geld"],
                    correctAnswer: 0,
                    explanation: "Hij zal je morgen het geld geven - Subject + zal + indirect object + time + direct object + infinitive",
                    hint: "Remember: Subject + zal + indirect object + time + direct object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will we see each other next week?'",
                    options: ["Zullen wij elkaar volgende week zien?", "Wij zullen elkaar volgende week zien?", "Elkaar zullen wij volgende week zien?", "Zien zullen wij elkaar volgende week?"],
                    correctAnswer: 0,
                    explanation: "Zullen wij elkaar volgende week zien? - Question: zullen + subject + object + time + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'The train will arrive at 3 PM'",
                    options: ["De trein zal om 3 uur aankomen", "Om 3 uur zal de trein aankomen", "De trein zal aankomen om 3 uur", "Aankomen zal de trein om 3 uur"],
                    correctAnswer: 0,
                    explanation: "De trein zal om 3 uur aankomen - Subject + zal + time + infinitive",
                    hint: "Remember: Subject + zal + time + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'I will try to help you'",
                    options: ["Ik zal proberen je te helpen", "Proberen zal ik je te helpen", "Ik zal je proberen te helpen", "Je zal ik proberen te helpen"],
                    correctAnswer: 0,
                    explanation: "Ik zal proberen je te helpen - Subject + zal + infinitive + object + te + infinitive",
                    hint: "Remember: Subject + zal + infinitive + object + te + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will you tell me the truth?'",
                    options: ["Zal je me de waarheid vertellen?", "Je zal me de waarheid vertellen?", "De waarheid zal je me vertellen?", "Vertellen zal je me de waarheid?"],
                    correctAnswer: 0,
                    explanation: "Zal je me de waarheid vertellen? - Question: zal + subject + indirect object + direct object + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'She will make dinner for us'",
                    options: ["Zij zal voor ons eten maken", "Voor ons zal zij eten maken", "Zij zal eten voor ons maken", "Maken zal zij voor ons eten"],
                    correctAnswer: 0,
                    explanation: "Zij zal voor ons eten maken - Subject + zal + prepositional phrase + object + infinitive",
                    hint: "Remember: Subject + zal + prepositional phrase + object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'They will wait for you at the station'",
                    options: ["Zij zullen op je wachten op het station", "Op het station zullen zij op je wachten", "Zij zullen op het station op je wachten", "Wachten zullen zij op je op het station"],
                    correctAnswer: 0,
                    explanation: "Zij zullen op je wachten op het station - Subject + zullen + prepositional phrase + infinitive + location",
                    hint: "Remember: Subject + zullen + prepositional phrase + infinitive + location",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will he remember our appointment?'",
                    options: ["Zal hij onze afspraak onthouden?", "Hij zal onze afspraak onthouden?", "Onze afspraak zal hij onthouden?", "Onthouden zal hij onze afspraak?"],
                    correctAnswer: 0,
                    explanation: "Zal hij onze afspraak onthouden? - Question: zal + subject + object + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'We will start the meeting at 2 PM'",
                    options: ["Wij zullen de vergadering om 2 uur beginnen", "Om 2 uur zullen wij de vergadering beginnen", "De vergadering zullen wij om 2 uur beginnen", "Beginnen zullen wij de vergadering om 2 uur"],
                    correctAnswer: 0,
                    explanation: "Wij zullen de vergadering om 2 uur beginnen - Subject + zullen + object + time + infinitive",
                    hint: "Remember: Subject + zullen + object + time + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'I will explain everything to you'",
                    options: ["Ik zal je alles uitleggen", "Je zal ik alles uitleggen", "Alles zal ik je uitleggen", "Uitleggen zal ik je alles"],
                    correctAnswer: 0,
                    explanation: "Ik zal je alles uitleggen - Subject + zal + indirect object + direct object + infinitive",
                    hint: "Remember: Subject + zal + indirect object + direct object + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will they understand the problem?'",
                    options: ["Zullen zij het probleem begrijpen?", "Zij zullen het probleem begrijpen?", "Het probleem zullen zij begrijpen?", "Begrijpen zullen zij het probleem?"],
                    correctAnswer: 0,
                    explanation: "Zullen zij het probleem begrijpen? - Question: zullen + subject + object + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'The weather will be nice tomorrow'",
                    options: ["Het weer zal morgen mooi zijn", "Morgen zal het weer mooi zijn", "Het weer zal mooi morgen zijn", "Zijn zal het weer morgen mooi"],
                    correctAnswer: 0,
                    explanation: "Het weer zal morgen mooi zijn - Subject + zal + time + adjective + zijn",
                    hint: "Remember: Subject + zal + time + adjective + zijn",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'She will become a doctor'",
                    options: ["Zij zal dokter worden", "Dokter zal zij worden", "Zij zal worden dokter", "Worden zal zij dokter"],
                    correctAnswer: 0,
                    explanation: "Zij zal dokter worden - Subject + zal + profession + worden",
                    hint: "Remember: Subject + zal + profession + worden",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will you be ready on time?'",
                    options: ["Zal je op tijd klaar zijn?", "Je zal op tijd klaar zijn?", "Op tijd zal je klaar zijn?", "Zijn zal je op tijd klaar?"],
                    correctAnswer: 0,
                    explanation: "Zal je op tijd klaar zijn? - Question: zal + subject + time + adjective + zijn",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'They will stay here for a week'",
                    options: ["Zij zullen hier een week blijven", "Hier zullen zij een week blijven", "Een week zullen zij hier blijven", "Blijven zullen zij hier een week"],
                    correctAnswer: 0,
                    explanation: "Zij zullen hier een week blijven - Subject + zullen + location + time + infinitive",
                    hint: "Remember: Subject + zullen + location + time + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'I will find a solution to this problem'",
                    options: ["Ik zal een oplossing voor dit probleem vinden", "Een oplossing zal ik voor dit probleem vinden", "Voor dit probleem zal ik een oplossing vinden", "Vinden zal ik een oplossing voor dit probleem"],
                    correctAnswer: 0,
                    explanation: "Ik zal een oplossing voor dit probleem vinden - Subject + zal + object + prepositional phrase + infinitive",
                    hint: "Remember: Subject + zal + object + prepositional phrase + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will he agree with our plan?'",
                    options: ["Zal hij akkoord gaan met ons plan?", "Hij zal akkoord gaan met ons plan?", "Met ons plan zal hij akkoord gaan?", "Gaan zal hij akkoord met ons plan?"],
                    correctAnswer: 0,
                    explanation: "Zal hij akkoord gaan met ons plan? - Question: zal + subject + akkoord + gaan + prepositional phrase",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'We will need more time for this project'",
                    options: ["Wij zullen meer tijd nodig hebben voor dit project", "Meer tijd zullen wij nodig hebben voor dit project", "Voor dit project zullen wij meer tijd nodig hebben", "Hebben zullen wij meer tijd nodig voor dit project"],
                    correctAnswer: 0,
                    explanation: "Wij zullen meer tijd nodig hebben voor dit project - Subject + zullen + object + nodig + hebben + prepositional phrase",
                    hint: "Remember: Subject + zullen + object + nodig + hebben + prepositional phrase",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will she be able to come to the meeting?'",
                    options: ["Zal zij naar de vergadering kunnen komen?", "Zij zal naar de vergadering kunnen komen?", "Naar de vergadering zal zij kunnen komen?", "Komen zal zij naar de vergadering kunnen?"],
                    correctAnswer: 0,
                    explanation: "Zal zij naar de vergadering kunnen komen? - Question: zal + subject + prepositional phrase + kunnen + infinitive",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'The children will play in the garden'",
                    options: ["De kinderen zullen in de tuin spelen", "In de tuin zullen de kinderen spelen", "De kinderen zullen spelen in de tuin", "Spelen zullen de kinderen in de tuin"],
                    correctAnswer: 0,
                    explanation: "De kinderen zullen in de tuin spelen - Subject + zullen + location + infinitive",
                    hint: "Remember: Subject + zullen + location + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'I will think about your proposal'",
                    options: ["Ik zal over jouw voorstel nadenken", "Over jouw voorstel zal ik nadenken", "Jouw voorstel zal ik over nadenken", "Nadenken zal ik over jouw voorstel"],
                    correctAnswer: 0,
                    explanation: "Ik zal over jouw voorstel nadenken - Subject + zal + prepositional phrase + infinitive",
                    hint: "Remember: Subject + zal + prepositional phrase + infinitive",
                    exerciseType: .sentenceOrder
                ),
                GrammarExercise(
                    question: "Arrange the words in correct Dutch word order: 'Will they remember to bring the documents?'",
                    options: ["Zullen zij denken aan het meenemen van de documenten?", "Zij zullen denken aan het meenemen van de documenten?", "Aan het meenemen zullen zij denken van de documenten?", "Denken zullen zij aan het meenemen van de documenten?"],
                    correctAnswer: 0,
                    explanation: "Zullen zij denken aan het meenemen van de documenten? - Question: zullen + subject + infinitive + prepositional phrase",
                    hint: "Questions start with zal/zullen + subject",
                    exerciseType: .sentenceOrder
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