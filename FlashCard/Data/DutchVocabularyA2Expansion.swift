import Foundation

// MARK: - A2 Level Vocabulary Expansion
// Adding comprehensive A2 packs to reach nearly 1000 words total

extension DutchVocabularyDatabase {
    
    // MARK: - A2 Expansion Packs
    
    static var dailyActivitiesA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Dagelijkse Activiteiten (A2)",
            level: .a2,
            category: .daily,
            words: [
                DutchWord(word: "activiteit", article: "de", definition: "activity", example: "Sport is een gezonde activiteit.", plural: "activiteiten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .daily),
                DutchWord(word: "routine", article: "de", definition: "routine", example: "Mijn dagelijkse routine is vast.", plural: "routines", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .daily),
                DutchWord(word: "opstaan", article: "", definition: "to get up", example: "Ik sta vroeg op.", plural: "", pastTense: "stond op", futureTense: "zal opstaan", pastParticiple: "opgestaan", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "douchen", article: "", definition: "to shower", example: "Ik douche elke ochtend.", plural: "", pastTense: "douchte", futureTense: "zal douchen", pastParticiple: "gedoucht", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "aankleden", article: "", definition: "to get dressed", example: "Ik kleed me snel aan.", plural: "", pastTense: "kleedde aan", futureTense: "zal aankleden", pastParticiple: "aangekleed", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "ontbijten", article: "", definition: "to have breakfast", example: "Wij ontbijten samen.", plural: "", pastTense: "ontbeet", futureTense: "zal ontbijten", pastParticiple: "ontbeten", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "lunchen", article: "", definition: "to have lunch", example: "Ik lunch om twaalf uur.", plural: "", pastTense: "lunchte", futureTense: "zal lunchen", pastParticiple: "geluncht", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "dineren", article: "", definition: "to have dinner", example: "Wij dineren om zes uur.", plural: "", pastTense: "dineerde", futureTense: "zal dineren", pastParticiple: "gedineerd", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "koken", article: "", definition: "to cook", example: "Ik kook graag.", plural: "", pastTense: "kookte", futureTense: "zal koken", pastParticiple: "gekookt", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "schoonmaken", article: "", definition: "to clean", example: "Ik maak het huis schoon.", plural: "", pastTense: "maakte schoon", futureTense: "zal schoonmaken", pastParticiple: "schoongemaakt", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "wassen", article: "", definition: "to wash", example: "Ik was de kleren.", plural: "", pastTense: "waste", futureTense: "zal wassen", pastParticiple: "gewassen", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "strijken", article: "", definition: "to iron", example: "Ik strijk mijn overhemd.", plural: "", pastTense: "streek", futureTense: "zal strijken", pastParticiple: "gestreken", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "boodschappen", article: "de", definition: "groceries", example: "Ik doe boodschappen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .daily),
                DutchWord(word: "afwassen", article: "", definition: "to do dishes", example: "Na het eten was ik af.", plural: "", pastTense: "waste af", futureTense: "zal afwassen", pastParticiple: "afgewassen", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "opruimen", article: "", definition: "to tidy up", example: "Ik ruim mijn kamer op.", plural: "", pastTense: "ruimde op", futureTense: "zal opruimen", pastParticiple: "opgeruimd", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "slapen", article: "", definition: "to sleep", example: "Ik slaap acht uur.", plural: "", pastTense: "sliep", futureTense: "zal slapen", pastParticiple: "geslapen", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "rusten", article: "", definition: "to rest", example: "Ik rust na het werk.", plural: "", pastTense: "rustte", futureTense: "zal rusten", pastParticiple: "gerust", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "plannen", article: "", definition: "to plan", example: "Ik plan mijn dag.", plural: "", pastTense: "plande", futureTense: "zal plannen", pastParticiple: "gepland", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "voorbereiden", article: "", definition: "to prepare", example: "Ik bereid het eten voor.", plural: "", pastTense: "bereidde voor", futureTense: "zal voorbereiden", pastParticiple: "voorbereid", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "organiseren", article: "", definition: "to organize", example: "Ik organiseer mijn spullen.", plural: "", pastTense: "organiseerde", futureTense: "zal organiseren", pastParticiple: "georganiseerd", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "herinneren", article: "", definition: "to remember", example: "Ik herinner me alles.", plural: "", pastTense: "herinnerde", futureTense: "zal herinneren", pastParticiple: "herinnerd", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "vergeten", article: "", definition: "to forget", example: "Ik vergeet vaak dingen.", plural: "", pastTense: "vergat", futureTense: "zal vergeten", pastParticiple: "vergeten", wordType: .verb, level: .a2, category: .daily),
                DutchWord(word: "druk", article: "", definition: "busy", example: "Ik heb een drukke dag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .daily),
                DutchWord(word: "vrij", article: "", definition: "free", example: "Ik ben vrij dit weekend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .daily),
                DutchWord(word: "gewoontes", article: "de", definition: "habits", example: "Goede gewoontes zijn belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .daily)
            ],
            description: "Essential vocabulary for describing daily routines and activities"
        )
    }
    
    static var shoppingA2Extended: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Uitgebreid Winkelen (A2)",
            level: .a2,
            category: .shopping,
            words: [
                DutchWord(word: "winkelcentrum", article: "het", definition: "shopping center", example: "Het winkelcentrum is groot.", plural: "winkelcentra", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "verkoper", article: "de", definition: "salesperson", example: "De verkoper helpt me.", plural: "verkopers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "korting", article: "de", definition: "discount", example: "Er is korting op kleding.", plural: "kortingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "aanbieding", article: "de", definition: "offer/sale", example: "Er is een goede aanbieding.", plural: "aanbiedingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "contant", article: "", definition: "cash", example: "Ik betaal contant.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .shopping),
                DutchWord(word: "pinpas", article: "de", definition: "debit card", example: "Ik betaal met mijn pinpas.", plural: "pinpassen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "creditcard", article: "de", definition: "credit card", example: "Mijn creditcard is verlopen.", plural: "creditcards", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "bon", article: "de", definition: "receipt", example: "Kan ik de bon krijgen?", plural: "bonnen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "kassa", article: "de", definition: "checkout", example: "Ik sta in de rij bij de kassa.", plural: "kassa's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "ruilen", article: "", definition: "to exchange", example: "Kan ik dit ruilen?", plural: "", pastTense: "ruilde", futureTense: "zal ruilen", pastParticiple: "geruild", wordType: .verb, level: .a2, category: .shopping),
                DutchWord(word: "terugbrengen", article: "", definition: "to return", example: "Ik breng het artikel terug.", plural: "", pastTense: "bracht terug", futureTense: "zal terugbrengen", pastParticiple: "teruggebracht", wordType: .verb, level: .a2, category: .shopping),
                DutchWord(word: "passen", article: "", definition: "to try on", example: "Mag ik dit passen?", plural: "", pastTense: "paste", futureTense: "zal passen", pastParticiple: "gepast", wordType: .verb, level: .a2, category: .shopping),
                DutchWord(word: "zoeken", article: "", definition: "to look for", example: "Ik zoek een cadeau.", plural: "", pastTense: "zocht", futureTense: "zal zoeken", pastParticiple: "gezocht", wordType: .verb, level: .a2, category: .shopping),
                DutchWord(word: "goedkoop", article: "", definition: "cheap", example: "Deze kleren zijn goedkoop.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .shopping),
                DutchWord(word: "duur", article: "", definition: "expensive", example: "Dit restaurant is duur.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .shopping),
                DutchWord(word: "gratis", article: "", definition: "free", example: "De koffie is gratis.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .shopping),
                DutchWord(word: "kwaliteit", article: "de", definition: "quality", example: "De kwaliteit is uitstekend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "merk", article: "het", definition: "brand", example: "Dit merk is populair.", plural: "merken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "maat", article: "de", definition: "size", example: "Welke maat heeft u?", plural: "maten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "kleur", article: "de", definition: "color", example: "Deze kleur staat je goed.", plural: "kleuren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "model", article: "het", definition: "model/style", example: "Dit model is nieuw.", plural: "modellen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "collectie", article: "de", definition: "collection", example: "De nieuwe collectie is uit.", plural: "collecties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "uitverkoop", article: "de", definition: "sale", example: "Er is uitverkoop in de winkel.", plural: "uitverkopen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "cadeaubon", article: "de", definition: "gift voucher", example: "Ik kreeg een cadeaubon.", plural: "cadeaubonnen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping),
                DutchWord(word: "garantie", article: "de", definition: "warranty", example: "Er is twee jaar garantie.", plural: "garanties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .shopping)
            ],
            description: "Extended shopping vocabulary for detailed commercial interactions"
        )
    }
    
    static var emotionsA2Extended: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Uitgebreide Emoties (A2)",
            level: .a2,
            category: .emotions,
            words: [
                DutchWord(word: "emotie", article: "de", definition: "emotion", example: "Hij toont veel emotie.", plural: "emoties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .emotions),
                DutchWord(word: "gevoel", article: "het", definition: "feeling", example: "Ik heb een goed gevoel.", plural: "gevoelens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .emotions),
                DutchWord(word: "stemming", article: "de", definition: "mood", example: "Ik ben in een goede stemming.", plural: "stemmingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .emotions),
                DutchWord(word: "opgewonden", article: "", definition: "excited", example: "Ik ben opgewonden over de reis.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "nerveus", article: "", definition: "nervous", example: "Ik ben nerveus voor het examen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "ontspannen", article: "", definition: "relaxed", example: "Ik voel me ontspannen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "gestrest", article: "", definition: "stressed", example: "Ik ben gestrest door het werk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "teleurgesteld", article: "", definition: "disappointed", example: "Ik ben teleurgesteld in het resultaat.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "trots", article: "", definition: "proud", example: "Ik ben trots op mijn kinderen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "jaloers", article: "", definition: "jealous", example: "Zij is jaloers op haar zus.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "nieuwsgierig", article: "", definition: "curious", example: "Kinderen zijn nieuwsgierig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "verdrietig", article: "", definition: "sad", example: "Zij is verdrietig om het nieuws.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "eenzaam", article: "", definition: "lonely", example: "Hij voelt zich eenzaam.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "gelukkig", article: "", definition: "happy", example: "Ik ben gelukkig met mijn leven.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "tevreden", article: "", definition: "satisfied", example: "Ik ben tevreden met het resultaat.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "ontevreden", article: "", definition: "dissatisfied", example: "Hij is ontevreden over de service.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "verrast", article: "", definition: "surprised", example: "Ik ben verrast door het cadeau.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "geschokt", article: "", definition: "shocked", example: "Zij was geschokt door het nieuws.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "dankbaar", article: "", definition: "grateful", example: "Ik ben dankbaar voor je hulp.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "boos", article: "", definition: "angry", example: "Hij is boos op zijn collega.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "gefrustreerd", article: "", definition: "frustrated", example: "Ik ben gefrustreerd door de vertraging.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "hoopvol", article: "", definition: "hopeful", example: "Ik ben hoopvol over de toekomst.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "pessimistisch", article: "", definition: "pessimistic", example: "Hij is pessimistisch over de economie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "optimistisch", article: "", definition: "optimistic", example: "Zij is optimistisch over haar carrière.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions),
                DutchWord(word: "moe", article: "", definition: "tired", example: "Ik ben moe na het werk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .emotions)
            ],
            description: "Comprehensive emotional vocabulary for detailed expression of feelings"
        )
    }
    
    static var weatherA2Extended: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Uitgebreid Weer (A2)",
            level: .a2,
            category: .weather,
            words: [
                DutchWord(word: "weersvoorspelling", article: "de", definition: "weather forecast", example: "De weersvoorspelling is goed.", plural: "weersvoorspellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "temperatuur", article: "de", definition: "temperature", example: "De temperatuur is 20 graden.", plural: "temperaturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "luchtvochtigheid", article: "de", definition: "humidity", example: "De luchtvochtigheid is hoog.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "luchtdruk", article: "de", definition: "air pressure", example: "De luchtdruk daalt.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "bewolking", article: "de", definition: "cloudiness", example: "Er is veel bewolking vandaag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "neerslag", article: "de", definition: "precipitation", example: "Er wordt neerslag verwacht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "droogte", article: "de", definition: "drought", example: "Er is droogte in het zuiden.", plural: "droogtes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "overstroming", article: "de", definition: "flood", example: "Door de regen is er overstroming.", plural: "overstromingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "donder", article: "de", definition: "thunder", example: "Ik hoor donder in de verte.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "bliksem", article: "de", definition: "lightning", example: "Bliksem verlicht de hemel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "onweer", article: "het", definition: "thunderstorm", example: "Er komt onweer aan.", plural: "onweders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "hagel", article: "de", definition: "hail", example: "Hagel beschadigt auto's.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "vorst", article: "de", definition: "frost", example: "Er is vorst vannacht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "ijzel", article: "de", definition: "freezing rain", example: "IJzel maakt de wegen glad.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "regenboog", article: "de", definition: "rainbow", example: "Na de regen zie je een regenboog.", plural: "regenbogen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "zonsopgang", article: "de", definition: "sunrise", example: "De zonsopgang is mooi.", plural: "zonsopgangen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "zonsondergang", article: "de", definition: "sunset", example: "We kijken naar de zonsondergang.", plural: "zonsondergangen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "seizoen", article: "het", definition: "season", example: "Welk seizoen vind je het leukst?", plural: "seizoenen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "klimaat", article: "het", definition: "climate", example: "Nederland heeft een gematigd klimaat.", plural: "klimaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "tropisch", article: "", definition: "tropical", example: "Een tropisch klimaat is warm.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .weather),
                DutchWord(word: "gematigd", article: "", definition: "temperate", example: "Een gematigd klimaat is aangenaam.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .weather),
                DutchWord(word: "vochtig", article: "", definition: "humid", example: "Het is vochtig vandaag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .weather),
                DutchWord(word: "droog", article: "", definition: "dry", example: "Het weer is droog deze week.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .weather),
                DutchWord(word: "helder", article: "", definition: "clear", example: "De lucht is helder blauw.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .weather),
                DutchWord(word: "bewolkt", article: "", definition: "cloudy", example: "Het is bewolkt vandaag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .weather)
            ],
            description: "Advanced weather and climate vocabulary for detailed weather discussions"
        )
    }
    
    static var educationA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Onderwijs en School (A2)",
            level: .a2,
            category: .education,
            words: [
                DutchWord(word: "onderwijs", article: "het", definition: "education", example: "Goed onderwijs is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "school", article: "de", definition: "school", example: "Mijn kinderen gaan naar school.", plural: "scholen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "klas", article: "de", definition: "class", example: "Onze klas heeft 25 leerlingen.", plural: "klassen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "leerling", article: "de", definition: "student", example: "De leerling doet zijn huiswerk.", plural: "leerlingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "student", article: "de", definition: "student", example: "Zij is student aan de universiteit.", plural: "studenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "leraar", article: "de", definition: "teacher", example: "De leraar legt de les uit.", plural: "leraren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "les", article: "de", definition: "lesson", example: "De les begint om negen uur.", plural: "lessen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "huiswerk", article: "het", definition: "homework", example: "Ik maak mijn huiswerk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "boek", article: "het", definition: "book", example: "Dit boek is interessant.", plural: "boeken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "schrift", article: "het", definition: "notebook", example: "Ik schrijf in mijn schrift.", plural: "schriften", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "pen", article: "de", definition: "pen", example: "Mijn pen schrijft goed.", plural: "pennen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "potlood", article: "het", definition: "pencil", example: "Ik teken met een potlood.", plural: "potloden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "toets", article: "de", definition: "test", example: "De toets was moeilijk.", plural: "toetsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "examen", article: "het", definition: "exam", example: "Het examen is volgende week.", plural: "examens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "cijfer", article: "het", definition: "grade", example: "Ik kreeg een goed cijfer.", plural: "cijfers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "vakantie", article: "de", definition: "holiday", example: "Schoolvakantie is leuk.", plural: "vakanties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "pauze", article: "de", definition: "break", example: "We hebben pauze om tien uur.", plural: "pauzes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .education),
                DutchWord(word: "leren", article: "", definition: "to learn", example: "Ik leer Nederlands.", plural: "", pastTense: "leerde", futureTense: "zal leren", pastParticiple: "geleerd", wordType: .verb, level: .a2, category: .education),
                DutchWord(word: "studeren", article: "", definition: "to study", example: "Ik studeer voor het examen.", plural: "", pastTense: "studeerde", futureTense: "zal studeren", pastParticiple: "gestudeerd", wordType: .verb, level: .a2, category: .education),
                DutchWord(word: "onderwijzen", article: "", definition: "to teach", example: "Hij onderwijst wiskunde.", plural: "", pastTense: "onderwees", futureTense: "zal onderwijzen", pastParticiple: "onderwezen", wordType: .verb, level: .a2, category: .education),
                DutchWord(word: "uitleggen", article: "", definition: "to explain", example: "De leraar legt het uit.", plural: "", pastTense: "legde uit", futureTense: "zal uitleggen", pastParticiple: "uitgelegd", wordType: .verb, level: .a2, category: .education),
                DutchWord(word: "begrijpen", article: "", definition: "to understand", example: "Ik begrijp de les.", plural: "", pastTense: "begreep", futureTense: "zal begrijpen", pastParticiple: "begrepen", wordType: .verb, level: .a2, category: .education),
                DutchWord(word: "vragen", article: "", definition: "to ask", example: "Mag ik iets vragen?", plural: "", pastTense: "vroeg", futureTense: "zal vragen", pastParticiple: "gevraagd", wordType: .verb, level: .a2, category: .education),
                DutchWord(word: "antwoorden", article: "", definition: "to answer", example: "Ik antwoord op de vraag.", plural: "", pastTense: "antwoordde", futureTense: "zal antwoorden", pastParticiple: "geantwoord", wordType: .verb, level: .a2, category: .education),
                DutchWord(word: "moeilijk", article: "", definition: "difficult", example: "Deze les is moeilijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .education)
            ],
            description: "Educational vocabulary for school and academic discussions"
        )
    }
    
    static var technologyA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Technologie en Internet (A2)",
            level: .a2,
            category: .technology,
            words: [
                DutchWord(word: "technologie", article: "de", definition: "technology", example: "Technologie verandert snel.", plural: "technologieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "computer", article: "de", definition: "computer", example: "Mijn computer is nieuw.", plural: "computers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "laptop", article: "de", definition: "laptop", example: "Ik werk op mijn laptop.", plural: "laptops", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "telefoon", article: "de", definition: "phone", example: "Mijn telefoon gaat over.", plural: "telefoons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "smartphone", article: "de", definition: "smartphone", example: "Iedereen heeft een smartphone.", plural: "smartphones", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "internet", article: "het", definition: "internet", example: "Internet is overal beschikbaar.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "website", article: "de", definition: "website", example: "Deze website is informatief.", plural: "websites", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "e-mail", article: "de", definition: "email", example: "Ik stuur een e-mail.", plural: "e-mails", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "bericht", article: "het", definition: "message", example: "Ik krijg een bericht.", plural: "berichten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "app", article: "de", definition: "app", example: "Deze app is handig.", plural: "apps", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "sociale media", article: "de", definition: "social media", example: "Sociale media is populair.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "video", article: "de", definition: "video", example: "Ik kijk een video.", plural: "video's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "foto", article: "de", definition: "photo", example: "Ik maak een foto.", plural: "foto's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "camera", article: "de", definition: "camera", example: "Mijn camera maakt mooie foto's.", plural: "camera's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "wachtwoord", article: "het", definition: "password", example: "Mijn wachtwoord is veilig.", plural: "wachtwoorden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "account", article: "het", definition: "account", example: "Ik maak een nieuw account.", plural: "accounts", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .technology),
                DutchWord(word: "inloggen", article: "", definition: "to log in", example: "Ik log in op mijn account.", plural: "", pastTense: "logde in", futureTense: "zal inloggen", pastParticiple: "ingelogd", wordType: .verb, level: .a2, category: .technology),
                DutchWord(word: "uitloggen", article: "", definition: "to log out", example: "Vergeet niet uit te loggen.", plural: "", pastTense: "logde uit", futureTense: "zal uitloggen", pastParticiple: "uitgelogd", wordType: .verb, level: .a2, category: .technology),
                DutchWord(word: "downloaden", article: "", definition: "to download", example: "Ik download de app.", plural: "", pastTense: "downloadde", futureTense: "zal downloaden", pastParticiple: "gedownload", wordType: .verb, level: .a2, category: .technology),
                DutchWord(word: "uploaden", article: "", definition: "to upload", example: "Ik upload de foto.", plural: "", pastTense: "uploadde", futureTense: "zal uploaden", pastParticiple: "geuploaded", wordType: .verb, level: .a2, category: .technology),
                DutchWord(word: "delen", article: "", definition: "to share", example: "Ik deel de video online.", plural: "", pastTense: "deelde", futureTense: "zal delen", pastParticiple: "gedeeld", wordType: .verb, level: .a2, category: .technology),
                DutchWord(word: "zoeken", article: "", definition: "to search", example: "Ik zoek informatie online.", plural: "", pastTense: "zocht", futureTense: "zal zoeken", pastParticiple: "gezocht", wordType: .verb, level: .a2, category: .technology),
                DutchWord(word: "verbinden", article: "", definition: "to connect", example: "Ik verbind met het wifi.", plural: "", pastTense: "verbond", futureTense: "zal verbinden", pastParticiple: "verbonden", wordType: .verb, level: .a2, category: .technology),
                DutchWord(word: "digitaal", article: "", definition: "digital", example: "We leven in een digitale wereld.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .technology),
                DutchWord(word: "online", article: "", definition: "online", example: "Ik werk online.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .technology)
            ],
            description: "Technology and internet vocabulary for digital communication"
        )
    }
    
    static var transportationTravelA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Vervoer en Reizen (A2)",
            level: .a2,
            category: .transportation,
            words: [
                DutchWord(word: "vervoer", article: "het", definition: "transportation", example: "Openbaar vervoer is handig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "reis", article: "de", definition: "trip", example: "Mijn reis naar Italië was geweldig.", plural: "reizen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "vakantie", article: "de", definition: "vacation", example: "We gaan op vakantie.", plural: "vakanties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "ticket", article: "het", definition: "ticket", example: "Ik koop een treinticket.", plural: "tickets", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "kaartje", article: "het", definition: "ticket", example: "Het kaartje kost vijf euro.", plural: "kaartjes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "station", article: "het", definition: "station", example: "Het station is druk.", plural: "stations", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "halte", article: "de", definition: "stop", example: "De bushalte is hier.", plural: "haltes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "luchthaven", article: "de", definition: "airport", example: "De luchthaven is groot.", plural: "luchthavens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "haven", article: "de", definition: "harbor", example: "Schepen liggen in de haven.", plural: "havens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "parkeerplaats", article: "de", definition: "parking space", example: "Ik zoek een parkeerplaats.", plural: "parkeerplaatsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "garage", article: "de", definition: "garage", example: "Mijn auto staat in de garage.", plural: "garages", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "benzine", article: "de", definition: "gasoline", example: "Ik tank benzine.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "tankstation", article: "het", definition: "gas station", example: "Het tankstation is open.", plural: "tankstations", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "kaart", article: "de", definition: "map", example: "Ik kijk op de kaart.", plural: "kaarten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "route", article: "de", definition: "route", example: "Deze route is sneller.", plural: "routes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "bestemming", article: "de", definition: "destination", example: "Mijn bestemming is Amsterdam.", plural: "bestemmingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .transportation),
                DutchWord(word: "reizen", article: "", definition: "to travel", example: "Ik reis graag.", plural: "", pastTense: "reisde", futureTense: "zal reizen", pastParticiple: "gereisd", wordType: .verb, level: .a2, category: .transportation),
                DutchWord(word: "vertrekken", article: "", definition: "to depart", example: "De trein vertrekt om acht uur.", plural: "", pastTense: "vertrok", futureTense: "zal vertrekken", pastParticiple: "vertrokken", wordType: .verb, level: .a2, category: .transportation),
                DutchWord(word: "aankomen", article: "", definition: "to arrive", example: "We komen om tien uur aan.", plural: "", pastTense: "kwam aan", futureTense: "zal aankomen", pastParticiple: "aangekomen", wordType: .verb, level: .a2, category: .transportation),
                DutchWord(word: "instappen", article: "", definition: "to get on", example: "Ik stap in de trein.", plural: "", pastTense: "stapte in", futureTense: "zal instappen", pastParticiple: "ingestapt", wordType: .verb, level: .a2, category: .transportation),
                DutchWord(word: "uitstappen", article: "", definition: "to get off", example: "Ik stap uit bij het station.", plural: "", pastTense: "stapte uit", futureTense: "zal uitstappen", pastParticiple: "uitgestapt", wordType: .verb, level: .a2, category: .transportation),
                DutchWord(word: "overstappen", article: "", definition: "to transfer", example: "Ik moet overstappen in Utrecht.", plural: "", pastTense: "stapte over", futureTense: "zal overstappen", pastParticiple: "overgestapt", wordType: .verb, level: .a2, category: .transportation),
                DutchWord(word: "reserveren", article: "", definition: "to reserve", example: "Ik reserveer een plaats.", plural: "", pastTense: "reserveerde", futureTense: "zal reserveren", pastParticiple: "gereserveerd", wordType: .verb, level: .a2, category: .transportation),
                DutchWord(word: "comfortabel", article: "", definition: "comfortable", example: "De trein is comfortabel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .transportation),
                DutchWord(word: "punctueel", article: "", definition: "punctual", example: "Nederlandse treinen zijn punctueel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .transportation)
            ],
            description: "Transportation and travel vocabulary for mobility and journey discussions"
        )
    }
    
    static var entertainmentLeisureA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Entertainment en Vrije Tijd (A2)",
            level: .a2,
            category: .entertainment,
            words: [
                DutchWord(word: "entertainment", article: "het", definition: "entertainment", example: "Dit programma biedt goed entertainment.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "vrije tijd", article: "de", definition: "free time", example: "Ik heb veel vrije tijd.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "hobby", article: "de", definition: "hobby", example: "Lezen is mijn hobby.", plural: "hobby's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "interesse", article: "de", definition: "interest", example: "Ik heb interesse in kunst.", plural: "interesses", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "bioscoop", article: "de", definition: "cinema", example: "We gaan naar de bioscoop.", plural: "bioscopen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "theater", article: "het", definition: "theater", example: "Het theater speelt een mooie voorstelling.", plural: "theaters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "concert", article: "het", definition: "concert", example: "Het concert was fantastisch.", plural: "concerten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "festival", article: "het", definition: "festival", example: "Het muziekfestival duurt drie dagen.", plural: "festivals", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "voorstelling", article: "de", definition: "performance", example: "De voorstelling begint om acht uur.", plural: "voorstellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "museum", article: "het", definition: "museum", example: "Het museum heeft interessante exposities.", plural: "musea", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "tentoonstelling", article: "de", definition: "exhibition", example: "De tentoonstelling is indrukwekkend.", plural: "tentoonstellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "park", article: "het", definition: "park", example: "We wandelen in het park.", plural: "parken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "café", article: "het", definition: "café", example: "We drinken koffie in het café.", plural: "cafés", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "restaurant", article: "het", definition: "restaurant", example: "Dit restaurant heeft lekker eten.", plural: "restaurants", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "feest", article: "het", definition: "party", example: "We geven een feest.", plural: "feesten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "verjaardag", article: "de", definition: "birthday", example: "Vandaag is mijn verjaardag.", plural: "verjaardagen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "cadeau", article: "het", definition: "gift", example: "Ik geef een mooi cadeau.", plural: "cadeaus", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "spel", article: "het", definition: "game", example: "We spelen een leuk spel.", plural: "spellen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "sport", article: "de", definition: "sport", example: "Sport is gezond.", plural: "sporten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "genieten", article: "", definition: "to enjoy", example: "Ik geniet van de muziek.", plural: "", pastTense: "genoot", futureTense: "zal genieten", pastParticiple: "genoten", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "ontspannen", article: "", definition: "to relax", example: "Ik ontspan na het werk.", plural: "", pastTense: "ontspande", futureTense: "zal ontspannen", pastParticiple: "ontspannen", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "vieren", article: "", definition: "to celebrate", example: "We vieren zijn verjaardag.", plural: "", pastTense: "vierde", futureTense: "zal vieren", pastParticiple: "gevierd", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "uitnodigen", article: "", definition: "to invite", example: "Ik nodig je uit voor het feest.", plural: "", pastTense: "nodigde uit", futureTense: "zal uitnodigen", pastParticiple: "uitgenodigd", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "leuk", article: "", definition: "fun", example: "Het feest was erg leuk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .entertainment),
                DutchWord(word: "interessant", article: "", definition: "interesting", example: "De tentoonstelling is interessant.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .entertainment)
            ],
            description: "Vocabulary for entertainment, leisure activities, and free time enjoyment"
        )
    }
    
    static var healthWellnessA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Gezondheid en Welzijn (A2)",
            level: .a2,
            category: .medical,
            words: [
                DutchWord(word: "gezondheid", article: "de", definition: "health", example: "Gezondheid is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "ziek", article: "", definition: "sick", example: "Ik ben ziek vandaag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "dokter", article: "de", definition: "doctor", example: "De dokter helpt patiënten.", plural: "dokters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "medicijn", article: "het", definition: "medicine", example: "Dit medicijn helpt tegen hoofdpijn.", plural: "medicijnen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "pijn", article: "de", definition: "pain", example: "Ik heb pijn in mijn rug.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "hoofdpijn", article: "de", definition: "headache", example: "Ik heb last van hoofdpijn.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "koorts", article: "de", definition: "fever", example: "Hij heeft koorts.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "verkouden", article: "", definition: "having a cold", example: "Ik ben verkouden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "griep", article: "de", definition: "flu", example: "De griep gaat rond.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "hoesten", article: "", definition: "to cough", example: "Ik moet steeds hoesten.", plural: "", pastTense: "hoestte", futureTense: "zal hoesten", pastParticiple: "gehoest", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "niezen", article: "", definition: "to sneeze", example: "Hij moet niezen.", plural: "", pastTense: "niesde", futureTense: "zal niezen", pastParticiple: "geniest", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "tandarts", article: "de", definition: "dentist", example: "Ik ga naar de tandarts.", plural: "tandartsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "tand", article: "de", definition: "tooth", example: "Mijn tand doet pijn.", plural: "tanden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "apotheek", article: "de", definition: "pharmacy", example: "Ik haal medicijnen bij de apotheek.", plural: "apotheken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "ziekenhuis", article: "het", definition: "hospital", example: "Hij ligt in het ziekenhuis.", plural: "ziekenhuizen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "verpleegster", article: "de", definition: "nurse (female)", example: "De verpleegster zorgt voor patiënten.", plural: "verpleegsters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "verpleger", article: "de", definition: "nurse (male)", example: "De verpleger is vriendelijk.", plural: "verplegers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "beter", article: "", definition: "better", example: "Ik voel me beter.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "gezond", article: "", definition: "healthy", example: "Groenten zijn gezond.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "voeding", article: "de", definition: "nutrition", example: "Goede voeding is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "vitamine", article: "de", definition: "vitamin", example: "Fruit bevat vitamines.", plural: "vitamines", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "dieet", article: "het", definition: "diet", example: "Hij volgt een dieet.", plural: "diëten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "bewegen", article: "", definition: "to exercise", example: "Bewegen is goed voor je gezondheid.", plural: "", pastTense: "bewoog", futureTense: "zal bewegen", pastParticiple: "bewogen", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "stress", article: "de", definition: "stress", example: "Werk kan stress veroorzaken.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "ontspannen", article: "", definition: "to relax", example: "Ik wil ontspannen.", plural: "", pastTense: "ontspande", futureTense: "zal ontspannen", pastParticiple: "ontspannen", wordType: .verb, level: .a2, category: .medical)
            ],
            description: "Health and wellness vocabulary for medical discussions and daily health topics"
        )
    }
    
    static var extendedFamilyA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Uitgebreide Familie en Relaties (A2)",
            level: .a2,
            category: .family,
            words: [
                DutchWord(word: "familielid", article: "het", definition: "family member", example: "Elk familielid is welkom.", plural: "familieleden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "neef", article: "de", definition: "cousin (male)/nephew", example: "Mijn neef woont in Amsterdam.", plural: "neven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "nicht", article: "de", definition: "cousin (female)/niece", example: "Mijn nicht studeert geneeskunde.", plural: "nichten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "zwager", article: "de", definition: "brother-in-law", example: "Mijn zwager is aardig.", plural: "zwagers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "schoonzus", article: "de", definition: "sister-in-law", example: "Mijn schoonzus kookt goed.", plural: "schoonzussen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "schoonouders", article: "de", definition: "parents-in-law", example: "De schoonouders komen op bezoek.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "schoondochter", article: "de", definition: "daughter-in-law", example: "Hun schoondochter is lief.", plural: "schoondochters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "schoonzoon", article: "de", definition: "son-in-law", example: "De schoonzoon helpt vaak.", plural: "schoonzonen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "stiefvader", article: "de", definition: "stepfather", example: "Mijn stiefvader is aardig.", plural: "stiefvaders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "stiefmoeder", article: "de", definition: "stepmother", example: "Zijn stiefmoeder kookt lekker.", plural: "stiefmoeders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "halfbroer", article: "de", definition: "half-brother", example: "Mijn halfbroer woont ver weg.", plural: "halfbroers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "halfzus", article: "de", definition: "half-sister", example: "Zijn halfzus is jonger.", plural: "halfzussen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "adopteren", article: "", definition: "to adopt", example: "Ze willen een kind adopteren.", plural: "", pastTense: "adopteerde", futureTense: "zal adopteren", pastParticiple: "geadopteerd", wordType: .verb, level: .a2, category: .family),
                DutchWord(word: "verwant", article: "", definition: "related", example: "We zijn niet verwant.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .family),
                DutchWord(word: "verwantschap", article: "de", definition: "relationship/kinship", example: "Er is een verre verwantschap.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "generatie", article: "de", definition: "generation", example: "Elke generatie is anders.", plural: "generaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "voorouder", article: "de", definition: "ancestor", example: "Onze voorouders kwamen uit Duitsland.", plural: "voorouders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "afstammen", article: "", definition: "to descend from", example: "Hij stamt af van boeren.", plural: "", pastTense: "stamde af", futureTense: "zal afstammen", pastParticiple: "afgestammen", wordType: .verb, level: .a2, category: .family),
                DutchWord(word: "erfenis", article: "de", definition: "inheritance", example: "Hij kreeg een erfenis.", plural: "erfenissen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "erven", article: "", definition: "to inherit", example: "Zij erfde het huis.", plural: "", pastTense: "erfde", futureTense: "zal erven", pastParticiple: "geërfd", wordType: .verb, level: .a2, category: .family),
                DutchWord(word: "familiefeest", article: "het", definition: "family celebration", example: "We hebben een familiefeest.", plural: "familiefeesten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "reünie", article: "de", definition: "reunion", example: "De familiereünie is leuk.", plural: "reünies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "stamboom", article: "de", definition: "family tree", example: "We maken een stamboom.", plural: "stambomen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "opvoeding", article: "de", definition: "upbringing", example: "Hij had een goede opvoeding.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .family),
                DutchWord(word: "opvoeden", article: "", definition: "to raise/bring up", example: "Ouders voeden kinderen op.", plural: "", pastTense: "voedde op", futureTense: "zal opvoeden", pastParticiple: "opgevoed", wordType: .verb, level: .a2, category: .family)
            ],
            description: "Extended family relationships and family dynamics vocabulary"
        )
    }
    
    static var cityLifeA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Stadsleven en Voorzieningen (A2)",
            level: .a2,
            category: .home,
            words: [
                DutchWord(word: "stadsleven", article: "het", definition: "city life", example: "Het stadsleven is druk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "voorziening", article: "de", definition: "facility/amenity", example: "De wijk heeft goede voorzieningen.", plural: "voorzieningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "buurt", article: "de", definition: "neighborhood", example: "Ik woon in een leuke buurt.", plural: "buurten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "buurman", article: "de", definition: "neighbor (male)", example: "De buurman is vriendelijk.", plural: "buurmannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "buurvrouw", article: "de", definition: "neighbor (female)", example: "De buurvrouw helpt vaak.", plural: "buurvrouwen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "gemeente", article: "de", definition: "municipality", example: "De gemeente zorgt voor wegen.", plural: "gemeenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "gemeentehuis", article: "het", definition: "city hall", example: "We gaan naar het gemeentehuis.", plural: "gemeentehuizen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "burgermeester", article: "de", definition: "mayor", example: "De burgermeester opent het festival.", plural: "burgemeesters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "verkeer", article: "het", definition: "traffic", example: "Het verkeer is druk vandaag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "verkeersregel", article: "de", definition: "traffic rule", example: "Verkeersregels zijn belangrijk.", plural: "verkeersregels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "zebrapad", article: "het", definition: "crosswalk", example: "Steek over bij het zebrapad.", plural: "zebrapaden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "stoep", article: "de", definition: "sidewalk", example: "Loop op de stoep.", plural: "stoepen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "straat", article: "de", definition: "street", example: "Onze straat is rustig.", plural: "straten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "plein", article: "het", definition: "square", example: "Het plein is vol mensen.", plural: "pleinen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "park", article: "het", definition: "park", example: "We wandelen in het park.", plural: "parken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "speeltuin", article: "de", definition: "playground", example: "Kinderen spelen in de speeltuin.", plural: "speeltuinen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "fontein", article: "de", definition: "fountain", example: "Er staat een mooie fontein.", plural: "fonteinen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "standbeeld", article: "het", definition: "statue", example: "Het standbeeld is beroemd.", plural: "standbeelden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "brug", article: "de", definition: "bridge", example: "We steken de brug over.", plural: "bruggen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "kanaal", article: "het", definition: "canal", example: "Amsterdam heeft mooie kanalen.", plural: "kanalen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "gracht", article: "de", definition: "canal (in city)", example: "De grachten zijn wereldberoemd.", plural: "grachten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "rondvaart", article: "de", definition: "boat tour", example: "We maken een rondvaart.", plural: "rondvaarten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "toerisme", article: "het", definition: "tourism", example: "Toerisme is belangrijk voor de stad.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "toerist", article: "de", definition: "tourist", example: "Veel toeristen bezoeken de stad.", plural: "toeristen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home),
                DutchWord(word: "gids", article: "de", definition: "guide", example: "De gids vertelt over de geschiedenis.", plural: "gidsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .home)
            ],
            description: "City life, urban facilities, and local community vocabulary"
        )
    }
    
    static var hobbyActivitiesA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Hobby's en Vrije Tijd (A2)",
            level: .a2,
            category: .sports,
            words: [
                DutchWord(word: "hobby", article: "de", definition: "hobby", example: "Lezen is mijn hobby.", plural: "hobby's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "verzamelen", article: "", definition: "to collect", example: "Ik verzamel postzegels.", plural: "", pastTense: "verzamelde", futureTense: "zal verzamelen", pastParticiple: "verzameld", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "verzameling", article: "de", definition: "collection", example: "Zijn verzameling is groot.", plural: "verzamelingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "tekenen", article: "", definition: "to draw", example: "Zij kan goed tekenen.", plural: "", pastTense: "tekende", futureTense: "zal tekenen", pastParticiple: "getekend", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "schilderen", article: "", definition: "to paint", example: "Hij schildert landschappen.", plural: "", pastTense: "schilderde", futureTense: "zal schilderen", pastParticiple: "geschilderd", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "fotografie", article: "de", definition: "photography", example: "Fotografie is zijn passie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "fotograferen", article: "", definition: "to photograph", example: "Ik fotografeer graag natuur.", plural: "", pastTense: "fotografeerde", futureTense: "zal fotograferen", pastParticiple: "gefotografeerd", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "camera", article: "de", definition: "camera", example: "Mijn camera maakt mooie foto's.", plural: "camera's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "breien", article: "", definition: "to knit", example: "Oma breit een trui.", plural: "", pastTense: "breide", futureTense: "zal breien", pastParticiple: "gebreid", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "naaien", article: "", definition: "to sew", example: "Zij naait haar eigen kleren.", plural: "", pastTense: "naaide", futureTense: "zal naaien", pastParticiple: "genaaid", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "handwerk", article: "het", definition: "handicraft", example: "Handwerk is ontspannend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "puzzel", article: "de", definition: "puzzle", example: "Deze puzzel heeft 1000 stukjes.", plural: "puzzels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "bordspel", article: "het", definition: "board game", example: "We spelen een bordspel.", plural: "bordspellen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "kaartspel", article: "het", definition: "card game", example: "Poker is een kaartspel.", plural: "kaartspellen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "schaken", article: "", definition: "to play chess", example: "Hij schaakte tegen de computer.", plural: "", pastTense: "schaakte", futureTense: "zal schaken", pastParticiple: "geschaakt", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "dammen", article: "", definition: "to play checkers", example: "We dammen elke zondag.", plural: "", pastTense: "damde", futureTense: "zal dammen", pastParticiple: "gedamd", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "tuinieren", article: "", definition: "to garden", example: "Zij tuiniert graag.", plural: "", pastTense: "tuinierde", futureTense: "zal tuinieren", pastParticiple: "getuinierd", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "tuinbouw", article: "de", definition: "gardening", example: "Tuinbouw is zijn hobby.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "bloem", article: "de", definition: "flower", example: "Deze bloem ruikt lekker.", plural: "bloemen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "plant", article: "de", definition: "plant", example: "Deze plant groeit snel.", plural: "planten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "zaaien", article: "", definition: "to sow", example: "We zaaien zaden in de lente.", plural: "", pastTense: "zaaide", futureTense: "zal zaaien", pastParticiple: "gezaaid", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "oogsten", article: "", definition: "to harvest", example: "We oogsten de tomaten.", plural: "", pastTense: "oogstte", futureTense: "zal oogsten", pastParticiple: "geoogst", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "wandelen", article: "", definition: "to walk/hike", example: "We wandelen in het bos.", plural: "", pastTense: "wandelde", futureTense: "zal wandelen", pastParticiple: "gewandeld", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "wandeling", article: "de", definition: "walk", example: "De wandeling was ontspannend.", plural: "wandelingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "fietsen", article: "", definition: "to cycle", example: "Ik fiets naar het werk.", plural: "", pastTense: "fietste", futureTense: "zal fietsen", pastParticiple: "gefietst", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "fietstocht", article: "de", definition: "bike trip", example: "We maken een lange fietstocht.", plural: "fietstochten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "instrument", article: "het", definition: "musical instrument", example: "Welk instrument bespeel je?", plural: "instrumenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .sports),
                DutchWord(word: "bespelen", article: "", definition: "to play (instrument)", example: "Hij bespeelt de piano.", plural: "", pastTense: "bespeelde", futureTense: "zal bespelen", pastParticiple: "bespeeld", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "zingen", article: "", definition: "to sing", example: "Zij zingt prachtig.", plural: "", pastTense: "zong", futureTense: "zal zingen", pastParticiple: "gezongen", wordType: .verb, level: .a2, category: .sports),
                DutchWord(word: "dansen", article: "", definition: "to dance", example: "We dansen op de muziek.", plural: "", pastTense: "danste", futureTense: "zal dansen", pastParticiple: "gedanst", wordType: .verb, level: .a2, category: .sports)
            ],
            description: "Hobbies and leisure activities vocabulary for personal interests"
        )
    }
    
    static var workLifeA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Werkleven en Carrière (A2)",
            level: .a2,
            category: .work,
            words: [
                DutchWord(word: "carrière", article: "de", definition: "career", example: "Hij heeft een succesvolle carrière.", plural: "carrières", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "solliciteren", article: "", definition: "to apply for a job", example: "Ik solliciteer naar een nieuwe baan.", plural: "", pastTense: "solliciteerde", futureTense: "zal solliciteren", pastParticiple: "gesolliciteerd", wordType: .verb, level: .a2, category: .work),
                DutchWord(word: "sollicitatie", article: "de", definition: "job application", example: "Mijn sollicitatie was succesvol.", plural: "sollicitaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "gesprek", article: "het", definition: "interview", example: "Het sollicitatiegesprek ging goed.", plural: "gesprekken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "cv", article: "het", definition: "resume/CV", example: "Mijn cv is up-to-date.", plural: "cv's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "werkgever", article: "de", definition: "employer", example: "Mijn werkgever is vriendelijk.", plural: "werkgevers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "werknemer", article: "de", definition: "employee", example: "Elke werknemer krijgt een bonus.", plural: "werknemers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "collega", article: "de", definition: "colleague", example: "Mijn collega's zijn aardig.", plural: "collega's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "baas", article: "de", definition: "boss", example: "De baas is tevreden.", plural: "bazen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "manager", article: "de", definition: "manager", example: "De manager leidt het team.", plural: "managers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "leidinggevende", article: "de", definition: "supervisor", example: "Mijn leidinggevende helpt me.", plural: "leidinggevenden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "team", article: "het", definition: "team", example: "Ons team werkt goed samen.", plural: "teams", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "samenwerken", article: "", definition: "to collaborate", example: "We werken samen aan het project.", plural: "", pastTense: "werkte samen", futureTense: "zal samenwerken", pastParticiple: "samengewerkt", wordType: .verb, level: .a2, category: .work),
                DutchWord(word: "project", article: "het", definition: "project", example: "Het project is bijna af.", plural: "projecten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "deadline", article: "de", definition: "deadline", example: "De deadline is morgen.", plural: "deadlines", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "vergadering", article: "de", definition: "meeting", example: "We hebben een vergadering om 10 uur.", plural: "vergaderingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "presentatie", article: "de", definition: "presentation", example: "Zijn presentatie was interessant.", plural: "presentaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "presenteren", article: "", definition: "to present", example: "Ik presenteer de resultaten.", plural: "", pastTense: "presenteerde", futureTense: "zal presenteren", pastParticiple: "gepresenteerd", wordType: .verb, level: .a2, category: .work),
                DutchWord(word: "salaris", article: "het", definition: "salary", example: "Mijn salaris is goed.", plural: "salarissen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "loon", article: "het", definition: "wage", example: "Het loon wordt wekelijks betaald.", plural: "lonen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "verhoging", article: "de", definition: "raise", example: "Ik kreeg een salarisverhoging.", plural: "verhogingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "bonus", article: "de", definition: "bonus", example: "Alle werknemers krijgen een bonus.", plural: "bonussen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "vakantie", article: "de", definition: "vacation", example: "Ik neem vakantie in juli.", plural: "vakanties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "verlof", article: "het", definition: "leave", example: "Hij heeft verlof genomen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "ziekteverlof", article: "het", definition: "sick leave", example: "Zij is op ziekteverlof.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "overwerk", article: "het", definition: "overtime", example: "Ik moet overwerk maken.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "parttime", article: "", definition: "part-time", example: "Zij werkt parttime.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .work),
                DutchWord(word: "fulltime", article: "", definition: "full-time", example: "Hij heeft een fulltime baan.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .work),
                DutchWord(word: "werkloosheid", article: "de", definition: "unemployment", example: "Werkloosheid is een probleem.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .work),
                DutchWord(word: "werkloos", article: "", definition: "unemployed", example: "Hij is al maanden werkloos.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .work)
            ],
            description: "Work life and career development vocabulary"
        )
    }
    
    static var communicationA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Communicatie en Taal (A2)",
            level: .a2,
            category: .media,
            words: [
                DutchWord(word: "communicatie", article: "de", definition: "communication", example: "Goede communicatie is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "communiceren", article: "", definition: "to communicate", example: "We communiceren via email.", plural: "", pastTense: "communiceerde", futureTense: "zal communiceren", pastParticiple: "gecommuniceerd", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "gesprek", article: "het", definition: "conversation", example: "We hadden een leuk gesprek.", plural: "gesprekken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "discussie", article: "de", definition: "discussion", example: "De discussie was interessant.", plural: "discussies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "discussiëren", article: "", definition: "to discuss", example: "We discussiëren over politiek.", plural: "", pastTense: "discussieerde", futureTense: "zal discussiëren", pastParticiple: "gediscussieerd", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "uitleggen", article: "", definition: "to explain", example: "Kun je dat uitleggen?", plural: "", pastTense: "legde uit", futureTense: "zal uitleggen", pastParticiple: "uitgelegd", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "uitleg", article: "de", definition: "explanation", example: "Zijn uitleg was duidelijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "beschrijven", article: "", definition: "to describe", example: "Beschrijf je vakantie.", plural: "", pastTense: "beschreef", futureTense: "zal beschrijven", pastParticiple: "beschreven", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "beschrijving", article: "de", definition: "description", example: "De beschrijving klopt.", plural: "beschrijvingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "vertellen", article: "", definition: "to tell", example: "Vertel me over je dag.", plural: "", pastTense: "vertelde", futureTense: "zal vertellen", pastParticiple: "verteld", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "verhaal", article: "het", definition: "story", example: "Dat is een mooi verhaal.", plural: "verhalen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "mening", article: "de", definition: "opinion", example: "Wat is jouw mening?", plural: "meningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "eens", article: "", definition: "agree", example: "Ik ben het eens.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .media),
                DutchWord(word: "oneens", article: "", definition: "disagree", example: "We zijn het oneens.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .media),
                DutchWord(word: "akkoord", article: "", definition: "agreed", example: "Akkoord, we doen het zo.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .media),
                DutchWord(word: "taal", article: "de", definition: "language", example: "Nederlands is een mooie taal.", plural: "talen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "moedertaal", article: "de", definition: "mother tongue", example: "Nederlands is mijn moedertaal.", plural: "moedertalen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "vreemde taal", article: "de", definition: "foreign language", example: "Engels is een vreemde taal voor mij.", plural: "vreemde talen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "vertalen", article: "", definition: "to translate", example: "Kun je dit vertalen?", plural: "", pastTense: "vertaalde", futureTense: "zal vertalen", pastParticiple: "vertaald", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "vertaling", article: "de", definition: "translation", example: "De vertaling is correct.", plural: "vertalingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "accent", article: "het", definition: "accent", example: "Hij heeft een Amerikaans accent.", plural: "accenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "uitspraak", article: "de", definition: "pronunciation", example: "De uitspraak is moeilijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "uitspreken", article: "", definition: "to pronounce", example: "Hoe spreek je dit uit?", plural: "", pastTense: "sprak uit", futureTense: "zal uitspreken", pastParticiple: "uitgesproken", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "woordenschat", article: "de", definition: "vocabulary", example: "Mijn woordenschat groeit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "grammatica", article: "de", definition: "grammar", example: "Nederlandse grammatica is complex.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "spelling", article: "de", definition: "spelling", example: "Let op je spelling.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "spellen", article: "", definition: "to spell", example: "Kun je je naam spellen?", plural: "", pastTense: "spelde", futureTense: "zal spellen", pastParticiple: "gespeld", wordType: .verb, level: .a2, category: .media),
                DutchWord(word: "lettergreep", article: "de", definition: "syllable", example: "Dit woord heeft drie lettergrepen.", plural: "lettergrepen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "betekenis", article: "de", definition: "meaning", example: "Wat is de betekenis van dit woord?", plural: "betekenissen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .media),
                DutchWord(word: "betekenen", article: "", definition: "to mean", example: "Wat betekent dit woord?", plural: "", pastTense: "betekende", futureTense: "zal betekenen", pastParticiple: "betekend", wordType: .verb, level: .a2, category: .media)
            ],
            description: "Communication and language learning vocabulary"
        )
    }
    
    static var personalCareA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Persoonlijke Verzorging (A2)",
            level: .a2,
            category: .body,
            words: [
                DutchWord(word: "verzorging", article: "de", definition: "care", example: "Persoonlijke verzorging is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "hygiene", article: "de", definition: "hygiene", example: "Goede hygiene voorkomt ziekte.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "douchen", article: "", definition: "to shower", example: "Ik douche elke ochtend.", plural: "", pastTense: "douchte", futureTense: "zal douchen", pastParticiple: "gedoucht", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "douche", article: "de", definition: "shower", example: "De douche is warm.", plural: "douches", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "baden", article: "", definition: "to bathe", example: "Ik baad graag in bad.", plural: "", pastTense: "baadde", futureTense: "zal baden", pastParticiple: "gebaad", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "bad", article: "het", definition: "bath", example: "Een warm bad is ontspannend.", plural: "baden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "shampoo", article: "de", definition: "shampoo", example: "Deze shampoo ruikt lekker.", plural: "shampoos", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "zeep", article: "de", definition: "soap", example: "Was je handen met zeep.", plural: "zepen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "tandenborstel", article: "de", definition: "toothbrush", example: "Mijn tandenborstel is nieuw.", plural: "tandenborstels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "tandpasta", article: "de", definition: "toothpaste", example: "Deze tandpasta smaakt naar mint.", plural: "tandpasta's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "poetsen", article: "", definition: "to brush", example: "Ik poets mijn tanden.", plural: "", pastTense: "poetste", futureTense: "zal poetsen", pastParticiple: "gepoetst", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "kam", article: "de", definition: "comb", example: "Waar is mijn kam?", plural: "kammen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "kammen", article: "", definition: "to comb", example: "Ik kam mijn haar.", plural: "", pastTense: "kamde", futureTense: "zal kammen", pastParticiple: "gekamd", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "borstel", article: "de", definition: "brush", example: "Deze borstel is zacht.", plural: "borstels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "borstelen", article: "", definition: "to brush", example: "Ik borstel mijn haar.", plural: "", pastTense: "borstelde", futureTense: "zal borstelen", pastParticiple: "geborsteld", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "föhn", article: "de", definition: "hair dryer", example: "De föhn is kapot.", plural: "föhns", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "föhnen", article: "", definition: "to blow-dry", example: "Ik föhn mijn haar droog.", plural: "", pastTense: "föhnde", futureTense: "zal föhnen", pastParticiple: "geföhnd", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "spiegel", article: "de", definition: "mirror", example: "Ik kijk in de spiegel.", plural: "spiegels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "handdoek", article: "de", definition: "towel", example: "De handdoek is droog.", plural: "handdoeken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "afdrogen", article: "", definition: "to dry off", example: "Ik droog me af met een handdoek.", plural: "", pastTense: "droogde af", futureTense: "zal afdrogen", pastParticiple: "afgedroogd", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "deodorant", article: "de", definition: "deodorant", example: "Ik gebruik deodorant.", plural: "deodorants", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "parfum", article: "het", definition: "perfume", example: "Haar parfum ruikt lekker.", plural: "parfums", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "crème", article: "de", definition: "cream", example: "Deze crème is goed voor je huid.", plural: "crèmes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "lotion", article: "de", definition: "lotion", example: "Bodylotion houdt je huid zacht.", plural: "lotions", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "scheren", article: "", definition: "to shave", example: "Hij scheert zich elke dag.", plural: "", pastTense: "schoor", futureTense: "zal scheren", pastParticiple: "geschoren", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "scheermesje", article: "het", definition: "razor", example: "Dit scheermesje is scherp.", plural: "scheermesjes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "scheercrème", article: "de", definition: "shaving cream", example: "Scheercrème voorkomt irritatie.", plural: "scheercrèmes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "nagel", article: "de", definition: "nail", example: "Mijn nagels zijn lang.", plural: "nagels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body),
                DutchWord(word: "knippen", article: "", definition: "to cut", example: "Ik knip mijn nagels.", plural: "", pastTense: "knipte", futureTense: "zal knippen", pastParticiple: "geknipt", wordType: .verb, level: .a2, category: .body),
                DutchWord(word: "nagelknipper", article: "de", definition: "nail clipper", example: "Waar is de nagelknipper?", plural: "nagelknippers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .body)
            ],
            description: "Personal care and hygiene vocabulary for daily routines"
        )
    }
    
    static var societyLifeA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Maatschappij en Samenleving (A2)",
            level: .a2,
            category: .culture,
            words: [
                DutchWord(word: "maatschappij", article: "de", definition: "society", example: "We leven in een moderne maatschappij.", plural: "maatschappijen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "samenleving", article: "de", definition: "society/community", example: "De samenleving verandert snel.", plural: "samenlevingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "gemeenschap", article: "de", definition: "community", example: "Onze gemeenschap helpt elkaar.", plural: "gemeenschappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "burger", article: "de", definition: "citizen", example: "Elke burger heeft rechten.", plural: "burgers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "burgerschap", article: "het", definition: "citizenship", example: "Hij kreeg het Nederlandse burgerschap.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "recht", article: "het", definition: "right", example: "Iedereen heeft recht op onderwijs.", plural: "rechten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "plicht", article: "de", definition: "duty", example: "Het is onze plicht te helpen.", plural: "plichten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "verantwoordelijkheid", article: "de", definition: "responsibility", example: "Dat is jouw verantwoordelijkheid.", plural: "verantwoordelijkheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "verantwoordelijk", article: "", definition: "responsible", example: "Hij is verantwoordelijk voor het project.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "vrijheid", article: "de", definition: "freedom", example: "Vrijheid is een belangrijk recht.", plural: "vrijheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "vrij", article: "", definition: "free", example: "We zijn vrij om te kiezen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "gelijkheid", article: "de", definition: "equality", example: "Gelijkheid is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "gelijk", article: "", definition: "equal", example: "Alle mensen zijn gelijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "veiligheid", article: "de", definition: "safety", example: "Veiligheid op straat is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "veilig", article: "", definition: "safe", example: "Deze buurt is veilig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "gevaar", article: "het", definition: "danger", example: "Er is geen gevaar.", plural: "gevaren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "gevaarlijk", article: "", definition: "dangerous", example: "Dat is gevaarlijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "hulp", article: "de", definition: "help", example: "Dank je voor je hulp.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "helpen", article: "", definition: "to help", example: "Ik help je graag.", plural: "", pastTense: "hielp", futureTense: "zal helpen", pastParticiple: "geholpen", wordType: .verb, level: .a2, category: .culture),
                DutchWord(word: "steun", article: "de", definition: "support", example: "Hij heeft onze steun.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "steunen", article: "", definition: "to support", example: "We steunen dit plan.", plural: "", pastTense: "steunde", futureTense: "zal steunen", pastParticiple: "gesteund", wordType: .verb, level: .a2, category: .culture),
                DutchWord(word: "solidariteit", article: "de", definition: "solidarity", example: "Solidariteit is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "tolerantie", article: "de", definition: "tolerance", example: "Nederland staat bekend om tolerantie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "tolerant", article: "", definition: "tolerant", example: "Hij is zeer tolerant.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "respect", article: "het", definition: "respect", example: "Respect voor elkaar is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "respecteren", article: "", definition: "to respect", example: "We respecteren elkaars mening.", plural: "", pastTense: "respecteerde", futureTense: "zal respecteren", pastParticiple: "gerespecteerd", wordType: .verb, level: .a2, category: .culture),
                DutchWord(word: "diversiteit", article: "de", definition: "diversity", example: "Diversiteit verrijkt de samenleving.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "divers", article: "", definition: "diverse", example: "We hebben een diverse groep.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "integratie", article: "de", definition: "integration", example: "Integratie is een proces.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "integreren", article: "", definition: "to integrate", example: "Nieuwkomers moeten integreren.", plural: "", pastTense: "integreerde", futureTense: "zal integreren", pastParticiple: "geïntegreerd", wordType: .verb, level: .a2, category: .culture),
                DutchWord(word: "cultuur", article: "de", definition: "culture", example: "Nederlandse cultuur is interessant.", plural: "culturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "cultureel", article: "", definition: "cultural", example: "Het is een cultureel evenement.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "traditie", article: "de", definition: "tradition", example: "Het is een oude traditie.", plural: "tradities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .culture),
                DutchWord(word: "traditioneel", article: "", definition: "traditional", example: "We eten traditioneel voedsel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture),
                DutchWord(word: "modern", article: "", definition: "modern", example: "Dit is een modern gebouw.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .culture)
            ],
            description: "Society and community vocabulary for social discussions"
        )
    }
    
    static var businessBasicsA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Zakelijke Basis (A2)",
            level: .a2,
            category: .business,
            words: [
                DutchWord(word: "bedrijf", article: "het", definition: "company", example: "Hij werkt bij een groot bedrijf.", plural: "bedrijven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "kantoor", article: "het", definition: "office", example: "Ons kantoor is in het centrum.", plural: "kantoren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "winkel", article: "de", definition: "shop", example: "De winkel is open tot 18:00.", plural: "winkels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "klant", article: "de", definition: "customer", example: "De klant is tevreden.", plural: "klanten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "verkopen", article: "", definition: "to sell", example: "Wij verkopen kwaliteitsproducten.", plural: "", pastTense: "verkocht", futureTense: "zal verkopen", pastParticiple: "verkocht", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "verkoop", article: "de", definition: "sale", example: "De verkoop gaat goed.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "kopen", article: "", definition: "to buy", example: "Ik koop dit product.", plural: "", pastTense: "kocht", futureTense: "zal kopen", pastParticiple: "gekocht", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "aankoop", article: "de", definition: "purchase", example: "Dit is een goede aankoop.", plural: "aankopen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "product", article: "het", definition: "product", example: "Dit product is populair.", plural: "producten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "dienst", article: "de", definition: "service", example: "We bieden goede diensten.", plural: "diensten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "kwaliteit", article: "de", definition: "quality", example: "De kwaliteit is uitstekend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "prijs", article: "de", definition: "price", example: "De prijs is redelijk.", plural: "prijzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "korting", article: "de", definition: "discount", example: "Er is 20% korting.", plural: "kortingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "aanbieding", article: "de", definition: "offer/deal", example: "Dit is een speciale aanbieding.", plural: "aanbiedingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "bestellen", article: "", definition: "to order", example: "Ik bestel online.", plural: "", pastTense: "bestelde", futureTense: "zal bestellen", pastParticiple: "besteld", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "bestelling", article: "de", definition: "order", example: "Mijn bestelling is aangekomen.", plural: "bestellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "leveren", article: "", definition: "to deliver", example: "We leveren binnen 24 uur.", plural: "", pastTense: "leverde", futureTense: "zal leveren", pastParticiple: "geleverd", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "levering", article: "de", definition: "delivery", example: "De levering is gratis.", plural: "leveringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "betalen", article: "", definition: "to pay", example: "Hoe wilt u betalen?", plural: "", pastTense: "betaalde", futureTense: "zal betalen", pastParticiple: "betaald", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "betaling", article: "de", definition: "payment", example: "De betaling is verwerkt.", plural: "betalingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "rekening", article: "de", definition: "bill", example: "Mag ik de rekening?", plural: "rekeningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "factuur", article: "de", definition: "invoice", example: "De factuur is verzonden.", plural: "facturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "contract", article: "het", definition: "contract", example: "We tekenen het contract.", plural: "contracten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "afspraak", article: "de", definition: "appointment", example: "Ik heb een afspraak om 14:00.", plural: "afspraken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "agenda", article: "de", definition: "agenda", example: "Staat het in je agenda?", plural: "agenda's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "planning", article: "de", definition: "planning", example: "De planning is vol.", plural: "planningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "plannen", article: "", definition: "to plan", example: "We plannen een vergadering.", plural: "", pastTense: "plande", futureTense: "zal plannen", pastParticiple: "gepland", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "organiseren", article: "", definition: "to organize", example: "Zij organiseert het evenement.", plural: "", pastTense: "organiseerde", futureTense: "zal organiseren", pastParticiple: "georganiseerd", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "organisatie", article: "de", definition: "organization", example: "Onze organisatie groeit.", plural: "organisaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "leiding", article: "de", definition: "management", example: "De leiding neemt beslissingen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "leiden", article: "", definition: "to lead", example: "Hij leidt het team.", plural: "", pastTense: "leidde", futureTense: "zal leiden", pastParticiple: "geleid", wordType: .verb, level: .a2, category: .business),
                DutchWord(word: "beslissing", article: "de", definition: "decision", example: "Het is een moeilijke beslissing.", plural: "beslissingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .business),
                DutchWord(word: "beslissen", article: "", definition: "to decide", example: "We moeten snel beslissen.", plural: "", pastTense: "besliste", futureTense: "zal beslissen", pastParticiple: "beslist", wordType: .verb, level: .a2, category: .business)
            ],
            description: "Basic business and commercial vocabulary for workplace situations"
        )
    }
    
    static var leisureExtendedA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Uitgebreide Vrije Tijd (A2)",
            level: .a2,
            category: .entertainment,
            words: [
                DutchWord(word: "ontspanning", article: "de", definition: "relaxation", example: "Ik zoek ontspanning na het werk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "ontspannen", article: "", definition: "to relax", example: "Ik ontspan graag thuis.", plural: "", pastTense: "ontspande", futureTense: "zal ontspannen", pastParticiple: "ontspannen", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "vermaak", article: "het", definition: "entertainment", example: "Het park biedt veel vermaak.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "vermaken", article: "", definition: "to entertain", example: "Hij vermaakt de kinderen.", plural: "", pastTense: "vermaakte", futureTense: "zal vermaken", pastParticiple: "vermaakt", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "activiteit", article: "de", definition: "activity", example: "Welke activiteit doe je graag?", plural: "activiteiten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "evenement", article: "het", definition: "event", example: "Het evenement was succesvol.", plural: "evenementen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "festival", article: "het", definition: "festival", example: "We gaan naar een muziekfestival.", plural: "festivals", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "concert", article: "het", definition: "concert", example: "Het concert was fantastisch.", plural: "concerten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "optreden", article: "het", definition: "performance", example: "Hun optreden was geweldig.", plural: "optredens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "optreden", article: "", definition: "to perform", example: "De band treedt op vanavond.", plural: "", pastTense: "trad op", futureTense: "zal optreden", pastParticiple: "opgetreden", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "theater", article: "het", definition: "theater", example: "We gaan naar het theater.", plural: "theaters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "toneelstuk", article: "het", definition: "play", example: "Het toneelstuk was indrukwekkend.", plural: "toneelstukken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "acteur", article: "de", definition: "actor", example: "Hij is een bekende acteur.", plural: "acteurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "actrice", article: "de", definition: "actress", example: "Zij is een getalenteerde actrice.", plural: "actrices", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "acteren", article: "", definition: "to act", example: "Hij kan goed acteren.", plural: "", pastTense: "acteerde", futureTense: "zal acteren", pastParticiple: "geacteerd", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "museum", article: "het", definition: "museum", example: "Het museum heeft mooie kunst.", plural: "musea", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "kunst", article: "de", definition: "art", example: "Moderne kunst is interessant.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "kunstenaar", article: "de", definition: "artist", example: "De kunstenaar is creatief.", plural: "kunstenaars", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "tentoonstelling", article: "de", definition: "exhibition", example: "De tentoonstelling is populair.", plural: "tentoonstellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "galerie", article: "de", definition: "gallery", example: "We bezoeken een kunstgalerie.", plural: "galerieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "bibliotheek", article: "de", definition: "library", example: "Ik leen boeken in de bibliotheek.", plural: "bibliotheken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "lenen", article: "", definition: "to borrow", example: "Ik leen dit boek.", plural: "", pastTense: "leende", futureTense: "zal lenen", pastParticiple: "geleend", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "terugbrengen", article: "", definition: "to return", example: "Ik breng het boek terug.", plural: "", pastTense: "bracht terug", futureTense: "zal terugbrengen", pastParticiple: "teruggebracht", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "lidmaatschap", article: "het", definition: "membership", example: "Ik heb een lidmaatschap van de sportschool.", plural: "lidmaatschappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "lid", article: "het", definition: "member", example: "Hij is lid van de club.", plural: "leden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "club", article: "de", definition: "club", example: "Onze club organiseert activiteiten.", plural: "clubs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "vereniging", article: "de", definition: "association", example: "De vereniging heeft veel leden.", plural: "verenigingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "deelnemen", article: "", definition: "to participate", example: "Ik neem deel aan de wedstrijd.", plural: "", pastTense: "nam deel", futureTense: "zal deelnemen", pastParticiple: "deelgenomen", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "deelname", article: "de", definition: "participation", example: "Deelname is gratis.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "wedstrijd", article: "de", definition: "competition", example: "De wedstrijd was spannend.", plural: "wedstrijden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment),
                DutchWord(word: "winnen", article: "", definition: "to win", example: "Ons team gaat winnen.", plural: "", pastTense: "won", futureTense: "zal winnen", pastParticiple: "gewonnen", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "verliezen", article: "", definition: "to lose", example: "We mogen niet verliezen.", plural: "", pastTense: "verloor", futureTense: "zal verliezen", pastParticiple: "verloren", wordType: .verb, level: .a2, category: .entertainment),
                DutchWord(word: "prijs", article: "de", definition: "prize", example: "Hij won de eerste prijs.", plural: "prijzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .entertainment)
            ],
            description: "Extended leisure and entertainment vocabulary for cultural activities"
        )
    }
    
    static var emergencyServicesA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Nooddiensten en Veiligheid (A2)",
            level: .a2,
            category: .crime,
            words: [
                DutchWord(word: "nooddienst", article: "de", definition: "emergency service", example: "Bel de nooddienst bij gevaar.", plural: "nooddiensten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "noodgeval", article: "het", definition: "emergency", example: "Dit is een noodgeval.", plural: "noodgevallen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "hulp", article: "de", definition: "help", example: "Ik heb hulp nodig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "politie", article: "de", definition: "police", example: "De politie komt eraan.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "agent", article: "de", definition: "police officer", example: "De agent schrijft een bekeuring.", plural: "agenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "brandweer", article: "de", definition: "fire department", example: "De brandweer blust het vuur.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "brandweerman", article: "de", definition: "firefighter", example: "De brandweerman is moedig.", plural: "brandweermannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "ambulance", article: "de", definition: "ambulance", example: "De ambulance rijdt snel.", plural: "ambulances", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "ziekenwagen", article: "de", definition: "ambulance", example: "De ziekenwagen brengt patiënten.", plural: "ziekenwagens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "arts", article: "de", definition: "doctor", example: "De arts onderzoekt de patiënt.", plural: "artsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "bellen", article: "", definition: "to call", example: "Bel 112 voor noodhulp.", plural: "", pastTense: "belde", futureTense: "zal bellen", pastParticiple: "gebeld", wordType: .verb, level: .a2, category: .crime),
                DutchWord(word: "alarmnummer", article: "het", definition: "emergency number", example: "112 is het alarmnummer.", plural: "alarmnummers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "brand", article: "de", definition: "fire", example: "Er is brand in het gebouw.", plural: "branden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "branden", article: "", definition: "to burn", example: "Het huis brandt.", plural: "", pastTense: "brandde", futureTense: "zal branden", pastParticiple: "gebrand", wordType: .verb, level: .a2, category: .crime),
                DutchWord(word: "blussen", article: "", definition: "to extinguish", example: "De brandweer blust het vuur.", plural: "", pastTense: "bluste", futureTense: "zal blussen", pastParticiple: "geblust", wordType: .verb, level: .a2, category: .crime),
                DutchWord(word: "ongeval", article: "het", definition: "accident", example: "Er is een ongeval gebeurd.", plural: "ongevallen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "gewond", article: "", definition: "injured", example: "Hij is gewond geraakt.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .crime),
                DutchWord(word: "verwonding", article: "de", definition: "injury", example: "De verwonding is niet ernstig.", plural: "verwondingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "eerste hulp", article: "de", definition: "first aid", example: "Hij geeft eerste hulp.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "verbandtrommel", article: "de", definition: "first aid kit", example: "Waar is de verbandtrommel?", plural: "verbandtrommels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "verband", article: "het", definition: "bandage", example: "Doe een verband om de wond.", plural: "verbanden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "pleister", article: "de", definition: "band-aid", example: "Ik heb een pleister nodig.", plural: "pleisters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "redden", article: "", definition: "to rescue", example: "De brandweer redt de kat.", plural: "", pastTense: "redde", futureTense: "zal redden", pastParticiple: "gered", wordType: .verb, level: .a2, category: .crime),
                DutchWord(word: "redding", article: "de", definition: "rescue", example: "De redding was succesvol.", plural: "reddingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "evacueren", article: "", definition: "to evacuate", example: "We moeten het gebouw evacueren.", plural: "", pastTense: "evacueerde", futureTense: "zal evacueren", pastParticiple: "geëvacueerd", wordType: .verb, level: .a2, category: .crime),
                DutchWord(word: "evacuatie", article: "de", definition: "evacuation", example: "De evacuatie verliep goed.", plural: "evacuaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "uitgang", article: "de", definition: "exit", example: "Waar is de nooduitgang?", plural: "uitgangen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "nooduitgang", article: "de", definition: "emergency exit", example: "Gebruik de nooduitgang.", plural: "nooduitgangen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "alarm", article: "het", definition: "alarm", example: "Het alarm gaat af.", plural: "alarmen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "sirene", article: "de", definition: "siren", example: "De sirene van de ambulance.", plural: "sirenes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "waarschuwen", article: "", definition: "to warn", example: "Waarschuw de anderen.", plural: "", pastTense: "waarschuwde", futureTense: "zal waarschuwen", pastParticiple: "gewaarschuwd", wordType: .verb, level: .a2, category: .crime),
                DutchWord(word: "waarschuwing", article: "de", definition: "warning", example: "Dit is een waarschuwing.", plural: "waarschuwingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "veiligheid", article: "de", definition: "safety", example: "Veiligheid is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .crime),
                DutchWord(word: "veilig", article: "", definition: "safe", example: "Ben je veilig?", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .crime),
                DutchWord(word: "beschermen", article: "", definition: "to protect", example: "We beschermen de kinderen.", plural: "", pastTense: "beschermde", futureTense: "zal beschermen", pastParticiple: "beschermd", wordType: .verb, level: .a2, category: .crime)
            ],
            description: "Emergency services and safety vocabulary for urgent situations"
        )
    }
    
    static var naturalEnvironmentA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Natuur en Milieu (A2)",
            level: .a2,
            category: .nature,
            words: [
                DutchWord(word: "natuur", article: "de", definition: "nature", example: "De natuur is mooi.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "natuurlijk", article: "", definition: "natural", example: "Dit is een natuurlijk product.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .nature),
                DutchWord(word: "milieu", article: "het", definition: "environment", example: "We moeten het milieu beschermen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "milieuverontreiniging", article: "de", definition: "pollution", example: "Milieuverontreiniging is een probleem.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "vervuiling", article: "de", definition: "pollution", example: "Luchtvervuiling is schadelijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "vervuilen", article: "", definition: "to pollute", example: "Fabrieken vervuilen de lucht.", plural: "", pastTense: "vervuilde", futureTense: "zal vervuilen", pastParticiple: "vervuild", wordType: .verb, level: .a2, category: .nature),
                DutchWord(word: "schoon", article: "", definition: "clean", example: "De lucht is schoon.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .nature),
                DutchWord(word: "schoonmaken", article: "", definition: "to clean", example: "We maken het park schoon.", plural: "", pastTense: "maakte schoon", futureTense: "zal schoonmaken", pastParticiple: "schoongemaakt", wordType: .verb, level: .a2, category: .nature),
                DutchWord(word: "recyclen", article: "", definition: "to recycle", example: "Ik recycle plastic flessen.", plural: "", pastTense: "recyclede", futureTense: "zal recyclen", pastParticiple: "gerecycled", wordType: .verb, level: .a2, category: .nature),
                DutchWord(word: "recycling", article: "de", definition: "recycling", example: "Recycling is goed voor het milieu.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "afval", article: "het", definition: "waste", example: "Gooi afval in de prullenbak.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "afvalcontainer", article: "de", definition: "waste container", example: "De afvalcontainer is vol.", plural: "afvalcontainers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "prullenbak", article: "de", definition: "trash can", example: "Gebruik de prullenbak.", plural: "prullenbakken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "plastic", article: "het", definition: "plastic", example: "Plastic is slecht voor de natuur.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "glas", article: "het", definition: "glass", example: "Glas kan gerecycled worden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "papier", article: "het", definition: "paper", example: "Oud papier wordt gerecycled.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "karton", article: "het", definition: "cardboard", example: "Karton gaat bij het oud papier.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "energie", article: "de", definition: "energy", example: "We gebruiken te veel energie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "besparen", article: "", definition: "to save", example: "We besparen energie.", plural: "", pastTense: "bespaarde", futureTense: "zal besparen", pastParticiple: "bespaard", wordType: .verb, level: .a2, category: .nature),
                DutchWord(word: "duurzaam", article: "", definition: "sustainable", example: "We kiezen voor duurzame producten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .nature),
                DutchWord(word: "duurzaamheid", article: "de", definition: "sustainability", example: "Duurzaamheid is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "klimaat", article: "het", definition: "climate", example: "Het klimaat verandert.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "klimaatverandering", article: "de", definition: "climate change", example: "Klimaatverandering is een probleem.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "opwarming", article: "de", definition: "warming", example: "De aarde warmt op.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "opwarmen", article: "", definition: "to warm up", example: "De aarde warmt op.", plural: "", pastTense: "warmde op", futureTense: "zal opwarmen", pastParticiple: "opgewarmd", wordType: .verb, level: .a2, category: .nature),
                DutchWord(word: "bos", article: "het", definition: "forest", example: "We wandelen in het bos.", plural: "bossen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "boom", article: "de", definition: "tree", example: "Deze boom is oud.", plural: "bomen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "planten", article: "", definition: "to plant", example: "We planten nieuwe bomen.", plural: "", pastTense: "plantte", futureTense: "zal planten", pastParticiple: "geplant", wordType: .verb, level: .a2, category: .nature),
                DutchWord(word: "groeien", article: "", definition: "to grow", example: "Planten groeien in de lente.", plural: "", pastTense: "groeide", futureTense: "zal groeien", pastParticiple: "gegroeid", wordType: .verb, level: .a2, category: .nature),
                DutchWord(word: "groei", article: "de", definition: "growth", example: "De groei van planten is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "water", article: "het", definition: "water", example: "Schoon water is essentieel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "lucht", article: "de", definition: "air", example: "De lucht is fris.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "aarde", article: "de", definition: "earth", example: "We moeten de aarde beschermen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "planeet", article: "de", definition: "planet", example: "De aarde is onze planeet.", plural: "planeten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .nature),
                DutchWord(word: "beschermen", article: "", definition: "to protect", example: "We beschermen de natuur.", plural: "", pastTense: "beschermde", futureTense: "zal beschermen", pastParticiple: "beschermd", wordType: .verb, level: .a2, category: .nature)
            ],
            description: "Nature and environment vocabulary for ecological discussions"
        )
    }
    
    static var seasonalActivitiesA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Seizoenen en Activiteiten (A2)",
            level: .a2,
            category: .weather,
            words: [
                DutchWord(word: "seizoen", article: "het", definition: "season", example: "Welk seizoen vind je het leukst?", plural: "seizoenen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "lente", article: "de", definition: "spring", example: "In de lente bloeien de bloemen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "zomer", article: "de", definition: "summer", example: "De zomer is warm.", plural: "zomers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "herfst", article: "de", definition: "autumn", example: "In de herfst vallen de bladeren.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "winter", article: "de", definition: "winter", example: "De winter is koud.", plural: "winters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "blad", article: "het", definition: "leaf", example: "Het blad is groen.", plural: "bladeren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "vallen", article: "", definition: "to fall", example: "De bladeren vallen.", plural: "", pastTense: "viel", futureTense: "zal vallen", pastParticiple: "gevallen", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "bloeien", article: "", definition: "to bloom", example: "De tulpen bloeien in april.", plural: "", pastTense: "bloeide", futureTense: "zal bloeien", pastParticiple: "gebloeid", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "bloesem", article: "de", definition: "blossom", example: "De kersenbloesem is prachtig.", plural: "bloesems", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "tuin", article: "de", definition: "garden", example: "Onze tuin is groot.", plural: "tuinen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "tuinieren", article: "", definition: "to garden", example: "Ik tuinier graag.", plural: "", pastTense: "tuinierde", futureTense: "zal tuinieren", pastParticiple: "getuinierd", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "maaien", article: "", definition: "to mow", example: "Hij maait het gras.", plural: "", pastTense: "maaide", futureTense: "zal maaien", pastParticiple: "gemaaid", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "gras", article: "het", definition: "grass", example: "Het gras is groen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "sneeuw", article: "de", definition: "snow", example: "Er ligt sneeuw.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "sneeuwen", article: "", definition: "to snow", example: "Het sneeuwt vandaag.", plural: "", pastTense: "sneeuwde", futureTense: "zal sneeuwen", pastParticiple: "gesneeuwd", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "sneeuwpop", article: "de", definition: "snowman", example: "We maken een sneeuwpop.", plural: "sneeuwpoppen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "schaatsen", article: "", definition: "to ice skate", example: "We schaatsen op het ijs.", plural: "", pastTense: "schaatste", futureTense: "zal schaatsen", pastParticiple: "geschaatst", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "schaats", article: "de", definition: "ice skate", example: "Mijn schaatsen zijn nieuw.", plural: "schaatsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "ijs", article: "het", definition: "ice", example: "Het ijs is dik.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "bevriezen", article: "", definition: "to freeze", example: "Het water bevriest.", plural: "", pastTense: "bevroor", futureTense: "zal bevriezen", pastParticiple: "bevroren", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "smelten", article: "", definition: "to melt", example: "De sneeuw smelt.", plural: "", pastTense: "smolt", futureTense: "zal smelten", pastParticiple: "gesmolten", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "zwemmen", article: "", definition: "to swim", example: "We zwemmen in de zomer.", plural: "", pastTense: "zwom", futureTense: "zal zwemmen", pastParticiple: "gezwommen", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "zwembad", article: "het", definition: "swimming pool", example: "Het zwembad is open.", plural: "zwembaden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "strand", article: "het", definition: "beach", example: "We gaan naar het strand.", plural: "stranden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "zee", article: "de", definition: "sea", example: "De zee is blauw.", plural: "zeeën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "golf", article: "de", definition: "wave", example: "De golven zijn hoog.", plural: "golven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "zand", article: "het", definition: "sand", example: "Het zand is warm.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "zandkasteel", article: "het", definition: "sandcastle", example: "We bouwen een zandkasteel.", plural: "zandkastelen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather),
                DutchWord(word: "zonnen", article: "", definition: "to sunbathe", example: "Zij zont op het strand.", plural: "", pastTense: "zonde", futureTense: "zal zonnen", pastParticiple: "gezond", wordType: .verb, level: .a2, category: .weather),
                DutchWord(word: "zonnebrand", article: "de", definition: "sunburn", example: "Ik heb zonnebrand.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .weather)
            ],
            description: "Seasonal activities and weather-related vocabulary"
        )
    }
    
    static var foodPreparationA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Koken en Eten Bereiden (A2)",
            level: .a2,
            category: .cooking,
            words: [
                DutchWord(word: "koken", article: "", definition: "to cook", example: "Ik kook elke dag.", plural: "", pastTense: "kookte", futureTense: "zal koken", pastParticiple: "gekookt", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "kok", article: "de", definition: "cook/chef", example: "De kok maakt lekker eten.", plural: "koks", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "bereiden", article: "", definition: "to prepare", example: "Ik bereid het eten voor.", plural: "", pastTense: "bereidde", futureTense: "zal bereiden", pastParticiple: "bereid", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "bereiding", article: "de", definition: "preparation", example: "De bereiding duurt een uur.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "recept", article: "het", definition: "recipe", example: "Dit recept is makkelijk.", plural: "recepten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "ingrediënt", article: "het", definition: "ingredient", example: "Welke ingrediënten heb je nodig?", plural: "ingrediënten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "snijden", article: "", definition: "to cut", example: "Snijd de uien klein.", plural: "", pastTense: "sneed", futureTense: "zal snijden", pastParticiple: "gesneden", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "mes", article: "het", definition: "knife", example: "Dit mes is scherp.", plural: "messen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "snijplank", article: "de", definition: "cutting board", example: "Gebruik een snijplank.", plural: "snijplanken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "hakken", article: "", definition: "to chop", example: "Hak de groenten fijn.", plural: "", pastTense: "hakte", futureTense: "zal hakken", pastParticiple: "gehakt", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "schillen", article: "", definition: "to peel", example: "Schil de aardappels.", plural: "", pastTense: "schilde", futureTense: "zal schillen", pastParticiple: "geschild", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "dunschiller", article: "de", definition: "peeler", example: "Waar is de dunschiller?", plural: "dunschillers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "roeren", article: "", definition: "to stir", example: "Roer de soep om.", plural: "", pastTense: "roerde", futureTense: "zal roeren", pastParticiple: "geroerd", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "lepel", article: "de", definition: "spoon", example: "Roer met een lepel.", plural: "lepels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "pollepel", article: "de", definition: "ladle", example: "Gebruik de pollepel voor soep.", plural: "pollepels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "bakken", article: "", definition: "to fry/bake", example: "Bak de eieren in de pan.", plural: "", pastTense: "bakte", futureTense: "zal bakken", pastParticiple: "gebakken", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "pan", article: "de", definition: "pan", example: "De pan is heet.", plural: "pannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "koekenpan", article: "de", definition: "frying pan", example: "Bak pannenkoeken in de koekenpan.", plural: "koekenpannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "braadpan", article: "de", definition: "roasting pan", example: "Gebruik de braadpan voor vlees.", plural: "braadpannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "steelpan", article: "de", definition: "saucepan", example: "Kook water in de steelpan.", plural: "steelpannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "oven", article: "de", definition: "oven", example: "Zet de taart in de oven.", plural: "ovens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "magnetron", article: "de", definition: "microwave", example: "Warm het eten op in de magnetron.", plural: "magnetrons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "opwarmen", article: "", definition: "to heat up", example: "Warm de soep op.", plural: "", pastTense: "warmde op", futureTense: "zal opwarmen", pastParticiple: "opgewarmd", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "kookplaat", article: "de", definition: "stove/cooktop", example: "De kookplaat is aan.", plural: "kookplaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "fornuis", article: "het", definition: "stove", example: "Het fornuis heeft vier pitten.", plural: "fornuizen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "pit", article: "de", definition: "burner", example: "Zet de pan op de pit.", plural: "pitten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "kookwekker", article: "de", definition: "cooking timer", example: "Zet de kookwekker op 10 minuten.", plural: "kookwekkers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "proeven", article: "", definition: "to taste", example: "Proef of het zout genoeg is.", plural: "", pastTense: "proefde", futureTense: "zal proeven", pastParticiple: "geproefd", wordType: .verb, level: .a2, category: .cooking),
                DutchWord(word: "smaak", article: "de", definition: "taste", example: "De smaak is perfect.", plural: "smaken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .cooking),
                DutchWord(word: "kruiden", article: "", definition: "to season", example: "Kruid het vlees goed.", plural: "", pastTense: "kruidde", futureTense: "zal kruiden", pastParticiple: "gekruid", wordType: .verb, level: .a2, category: .cooking)
            ],
            description: "Cooking and food preparation vocabulary for kitchen activities"
        )
    }
    
    static var socialLifeA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Sociaal Leven en Vriendschap (A2)",
            level: .a2,
            category: .relationships,
            words: [
                DutchWord(word: "vriend", article: "de", definition: "friend (male)", example: "Hij is mijn beste vriend.", plural: "vrienden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "vriendin", article: "de", definition: "friend (female)", example: "Zij is mijn goede vriendin.", plural: "vriendinnen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "vriendschap", article: "de", definition: "friendship", example: "Onze vriendschap is belangrijk.", plural: "vriendschappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "bevriend", article: "", definition: "befriended", example: "We zijn bevriend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .relationships),
                DutchWord(word: "kennismaken", article: "", definition: "to get acquainted", example: "Leuk om kennis te maken.", plural: "", pastTense: "maakte kennis", futureTense: "zal kennismaken", pastParticiple: "kennisgemaakt", wordType: .verb, level: .a2, category: .relationships),
                DutchWord(word: "kennis", article: "de", definition: "acquaintance", example: "Hij is een kennis van mij.", plural: "kennissen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "ontmoeten", article: "", definition: "to meet", example: "We ontmoeten elkaar morgen.", plural: "", pastTense: "ontmoette", futureTense: "zal ontmoeten", pastParticiple: "ontmoet", wordType: .verb, level: .a2, category: .relationships),
                DutchWord(word: "ontmoeting", article: "de", definition: "meeting", example: "De ontmoeting was leuk.", plural: "ontmoetingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "afspreken", article: "", definition: "to make an appointment", example: "Zullen we afspreken?", plural: "", pastTense: "sprak af", futureTense: "zal afspreken", pastParticiple: "afgesproken", wordType: .verb, level: .a2, category: .relationships),
                DutchWord(word: "afspraak", article: "de", definition: "date/appointment", example: "We hebben een afspraak.", plural: "afspraken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "uitnodigen", article: "", definition: "to invite", example: "Ik nodig je uit voor mijn feest.", plural: "", pastTense: "nodigde uit", futureTense: "zal uitnodigen", pastParticiple: "uitgenodigd", wordType: .verb, level: .a2, category: .relationships),
                DutchWord(word: "uitnodiging", article: "de", definition: "invitation", example: "Dank je voor de uitnodiging.", plural: "uitnodigingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "bezoeken", article: "", definition: "to visit", example: "Ik bezoek mijn oma.", plural: "", pastTense: "bezocht", futureTense: "zal bezoeken", pastParticiple: "bezocht", wordType: .verb, level: .a2, category: .relationships),
                DutchWord(word: "bezoek", article: "het", definition: "visit", example: "We krijgen bezoek.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "gast", article: "de", definition: "guest", example: "Onze gasten zijn welkom.", plural: "gasten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "gastheer", article: "de", definition: "host", example: "Hij is een goede gastheer.", plural: "gastheren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "gastvrouw", article: "de", definition: "hostess", example: "Zij is een vriendelijke gastvrouw.", plural: "gastvrouwen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "feest", article: "het", definition: "party", example: "Het feest was geweldig.", plural: "feesten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "feesten", article: "", definition: "to party", example: "We feesten tot laat.", plural: "", pastTense: "feestte", futureTense: "zal feesten", pastParticiple: "gefeest", wordType: .verb, level: .a2, category: .relationships),
                DutchWord(word: "verjaardag", article: "de", definition: "birthday", example: "Vandaag is mijn verjaardag.", plural: "verjaardagen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "jarig", article: "", definition: "having a birthday", example: "Ik ben vandaag jarig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .relationships),
                DutchWord(word: "cadeau", article: "het", definition: "gift", example: "Dit cadeau is voor jou.", plural: "cadeaus", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "cadeautje", article: "het", definition: "small gift", example: "Een leuk cadeautje.", plural: "cadeautjes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "feliciteren", article: "", definition: "to congratulate", example: "Ik feliciteer je met je verjaardag.", plural: "", pastTense: "feliciteerde", futureTense: "zal feliciteren", pastParticiple: "gefeliciteerd", wordType: .verb, level: .a2, category: .relationships),
                DutchWord(word: "felicitatie", article: "de", definition: "congratulation", example: "Gefeliciteerd!", plural: "felicitaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "gezellig", article: "", definition: "cozy/fun", example: "Het was een gezellige avond.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .relationships),
                DutchWord(word: "gezelligheid", article: "de", definition: "coziness", example: "Gezelligheid is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "samen", article: "", definition: "together", example: "We doen het samen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adverb, level: .a2, category: .relationships),
                DutchWord(word: "samenzijn", article: "het", definition: "being together", example: "Het samenzijn was leuk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships),
                DutchWord(word: "groep", article: "de", definition: "group", example: "Onze groep is hecht.", plural: "groepen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .relationships)
            ],
            description: "Social life and friendship vocabulary for personal relationships"
        )
    }
    
    static var lifestyleHealthA2: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Levensstijl en Welzijn (A2)",
            level: .a2,
            category: .medical,
            words: [
                DutchWord(word: "levensstijl", article: "de", definition: "lifestyle", example: "Een gezonde levensstijl is belangrijk.", plural: "levensstijlen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "welzijn", article: "het", definition: "well-being", example: "Welzijn is essentieel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "leven", article: "", definition: "to live", example: "Ik leef gezond.", plural: "", pastTense: "leefde", futureTense: "zal leven", pastParticiple: "geleefd", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "leven", article: "het", definition: "life", example: "Het leven is mooi.", plural: "levens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "levend", article: "", definition: "alive", example: "Hij is nog levend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "levendig", article: "", definition: "lively", example: "Zij is een levendig persoon.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "fit", article: "", definition: "fit", example: "Ik voel me fit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "fitness", article: "de", definition: "fitness", example: "Fitness is goed voor je.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "sporten", article: "", definition: "to do sports", example: "Ik sport drie keer per week.", plural: "", pastTense: "sportte", futureTense: "zal sporten", pastParticiple: "gesport", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "sportief", article: "", definition: "sporty", example: "Hij is heel sportief.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "sportschool", article: "de", definition: "gym", example: "Ik ga naar de sportschool.", plural: "sportscholen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "trainen", article: "", definition: "to train", example: "Ik train hard.", plural: "", pastTense: "trainde", futureTense: "zal trainen", pastParticiple: "getraind", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "training", article: "de", definition: "training", example: "De training was zwaar.", plural: "trainingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "oefenen", article: "", definition: "to exercise", example: "Ik oefen elke dag.", plural: "", pastTense: "oefende", futureTense: "zal oefenen", pastParticiple: "geoefend", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "oefening", article: "de", definition: "exercise", example: "Deze oefening is moeilijk.", plural: "oefeningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "hardlopen", article: "", definition: "to run", example: "Ik ga hardlopen in het park.", plural: "", pastTense: "liep hard", futureTense: "zal hardlopen", pastParticiple: "hardgelopen", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "joggen", article: "", definition: "to jog", example: "Zij jogt elke ochtend.", plural: "", pastTense: "jogde", futureTense: "zal joggen", pastParticiple: "gejogd", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "yoga", article: "de", definition: "yoga", example: "Yoga is ontspannend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "meditatie", article: "de", definition: "meditation", example: "Meditatie helpt tegen stress.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "mediteren", article: "", definition: "to meditate", example: "Ik mediteer 's ochtends.", plural: "", pastTense: "mediteerde", futureTense: "zal mediteren", pastParticiple: "gemediteerd", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "rust", article: "de", definition: "rest", example: "Ik heb rust nodig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "rusten", article: "", definition: "to rest", example: "Ik rust uit na het werk.", plural: "", pastTense: "rustte", futureTense: "zal rusten", pastParticiple: "gerust", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "rustig", article: "", definition: "calm", example: "Blijf rustig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "slapen", article: "", definition: "to sleep", example: "Ik slaap acht uur per nacht.", plural: "", pastTense: "sliep", futureTense: "zal slapen", pastParticiple: "geslapen", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "slaap", article: "de", definition: "sleep", example: "Goede slaap is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "slaperig", article: "", definition: "sleepy", example: "Ik ben slaperig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "wakker", article: "", definition: "awake", example: "Ben je wakker?", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "wekker", article: "de", definition: "alarm clock", example: "De wekker gaat om 7 uur.", plural: "wekkers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "opstaan", article: "", definition: "to get up", example: "Ik sta vroeg op.", plural: "", pastTense: "stond op", futureTense: "zal opstaan", pastParticiple: "opgestaan", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "vroeg", article: "", definition: "early", example: "Ik sta vroeg op.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adverb, level: .a2, category: .medical),
                DutchWord(word: "laat", article: "", definition: "late", example: "Ik ga laat naar bed.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adverb, level: .a2, category: .medical),
                DutchWord(word: "moe", article: "", definition: "tired", example: "Ik ben moe.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "moeheid", article: "de", definition: "tiredness", example: "Moeheid is normaal.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "energie", article: "de", definition: "energy", example: "Ik heb veel energie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "energiek", article: "", definition: "energetic", example: "Zij is heel energiek.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .a2, category: .medical),
                DutchWord(word: "balans", article: "de", definition: "balance", example: "Work-life balans is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "evenwicht", article: "het", definition: "balance", example: "Zoek het juiste evenwicht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "gewicht", article: "het", definition: "weight", example: "Mijn gewicht is stabiel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical),
                DutchWord(word: "wegen", article: "", definition: "to weigh", example: "Ik weeg 70 kilo.", plural: "", pastTense: "woog", futureTense: "zal wegen", pastParticiple: "gewogen", wordType: .verb, level: .a2, category: .medical),
                DutchWord(word: "weegschaal", article: "de", definition: "scale", example: "De weegschaal staat in de badkamer.", plural: "weegschalen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .a2, category: .medical)
            ],
            description: "Lifestyle and wellness vocabulary for healthy living discussions"
        )
    }
    
    // MARK: - A2 Expanded Packs Array
    static var a2ExpansionPacks: [DutchVocabularyPack] {
        return [
            dailyActivitiesA2,
            shoppingA2Extended,
            emotionsA2Extended,
            weatherA2Extended,
            educationA2,
            technologyA2,
            transportationTravelA2,
            entertainmentLeisureA2,
            healthWellnessA2,
            extendedFamilyA2,
            cityLifeA2,
            hobbyActivitiesA2,
            workLifeA2,
            communicationA2,
            personalCareA2,
            societyLifeA2,
            businessBasicsA2,
            leisureExtendedA2,
            emergencyServicesA2,
            naturalEnvironmentA2,
            seasonalActivitiesA2,
            foodPreparationA2,
            socialLifeA2,
            lifestyleHealthA2
        ]
    }
} 