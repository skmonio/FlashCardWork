import Foundation

// MARK: - Dutch Vocabulary Expansion Packs
// This file contains additional comprehensive vocabulary packs to expand the Dutch learning system

extension DutchVocabularyDatabase {
    
    // MARK: - Advanced Business & Professional Vocabulary
    
    static var advancedBusinessB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Zakelijk Gevorderd (B1)",
            level: .b1,
            category: .business,
            words: [
                DutchWord(word: "onderneming", article: "de", definition: "enterprise", example: "Onze onderneming groeit snel.", plural: "ondernemingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "ondernemer", article: "de", definition: "entrepreneur", example: "Een succesvolle ondernemer neemt risico's.", plural: "ondernemers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "startup", article: "de", definition: "startup", example: "Deze startup heeft veel potentieel.", plural: "startups", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "investering", article: "de", definition: "investment", example: "Deze investering is risicovol.", plural: "investeringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "aandeelhouder", article: "de", definition: "shareholder", example: "Aandeelhouders hebben stemrecht.", plural: "aandeelhouders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "winst", article: "de", definition: "profit", example: "Het bedrijf maakte veel winst.", plural: "winsten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "verlies", article: "het", definition: "loss", example: "Het verlies was hoger dan verwacht.", plural: "verliezen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "omzet", article: "de", definition: "turnover", example: "De omzet steeg met 20%.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "markt", article: "de", definition: "market", example: "De markt voor elektrische auto's groeit.", plural: "markten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "concurrentie", article: "de", definition: "competition", example: "De concurrentie is fel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "concurrent", article: "de", definition: "competitor", example: "Onze concurrent lanceert een nieuw product.", plural: "concurrenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "klant", article: "de", definition: "customer", example: "Tevreden klanten zijn belangrijk.", plural: "klanten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "leverancier", article: "de", definition: "supplier", example: "We hebben een nieuwe leverancier.", plural: "leveranciers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "distributeur", article: "de", definition: "distributor", example: "De distributeur verkoopt onze producten.", plural: "distributeurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "marketing", article: "de", definition: "marketing", example: "Marketing is cruciaal voor succes.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "reclame", article: "de", definition: "advertising", example: "Reclame op tv is duur.", plural: "reclames", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "campagne", article: "de", definition: "campaign", example: "De reclamecampagne was succesvol.", plural: "campagnes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "merk", article: "het", definition: "brand", example: "Dit merk is wereldberoemd.", plural: "merken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "strategie", article: "de", definition: "strategy", example: "We hebben een nieuwe strategie.", plural: "strategieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "doelstelling", article: "de", definition: "objective", example: "Onze doelstelling is haalbaar.", plural: "doelstellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "budget", article: "het", definition: "budget", example: "Het budget is beperkt dit jaar.", plural: "budgetten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "subsidie", article: "de", definition: "subsidy", example: "We ontvingen een subsidie van de regering.", plural: "subsidies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "fusie", article: "de", definition: "merger", example: "De fusie werd aangekondigd.", plural: "fusies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "overname", article: "de", definition: "acquisition", example: "De overname kost veel geld.", plural: "overnames", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "faillissement", article: "het", definition: "bankruptcy", example: "Het bedrijf ging failliet.", plural: "faillissementen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "productiviteit", article: "de", definition: "productivity", example: "De productiviteit stijgt.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "efficiency", article: "de", definition: "efficiency", example: "Efficiency is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "kwaliteitscontrole", article: "de", definition: "quality control", example: "Kwaliteitscontrole voorkomt fouten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "innovatie", article: "de", definition: "innovation", example: "Innovatie drijft groei aan.", plural: "innovaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "samenwerking", article: "de", definition: "collaboration", example: "Samenwerking is cruciaal.", plural: "samenwerkingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "teamwork", article: "het", definition: "teamwork", example: "Goed teamwork leidt tot succes.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "leiderschap", article: "het", definition: "leadership", example: "Leiderschap is een vaardigheid.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "motivatie", article: "de", definition: "motivation", example: "Motivatie is belangrijk voor succes.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "prestatie", article: "de", definition: "performance", example: "Zijn prestatie was uitstekend.", plural: "prestaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "resultaat", article: "het", definition: "result", example: "Het resultaat overtrof verwachtingen.", plural: "resultaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "doeltreffend", article: "", definition: "effective", example: "Deze methode is doeltreffend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .business),
                DutchWord(word: "verantwoordelijkheid", article: "de", definition: "responsibility", example: "Verantwoordelijkheid is belangrijk.", plural: "verantwoordelijkheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "betrouwbaarheid", article: "de", definition: "reliability", example: "Betrouwbaarheid bouwt vertrouwen op.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "flexibiliteit", article: "de", definition: "flexibility", example: "Flexibiliteit is een voordeel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "aanpassingsvermogen", article: "het", definition: "adaptability", example: "Aanpassingsvermogen is essentieel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "creativiteit", article: "de", definition: "creativity", example: "Creativiteit lost problemen op.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "originaliteit", article: "de", definition: "originality", example: "Originaliteit onderscheidt ons.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "professionaliteit", article: "de", definition: "professionalism", example: "Professionaliteit is vereist.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "competitie", article: "de", definition: "competition", example: "Competitie stimuleert groei.", plural: "competities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "marktaandeel", article: "het", definition: "market share", example: "Ons marktaandeel groeit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "klantenservice", article: "de", definition: "customer service", example: "Goede klantenservice is cruciaal.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "klanttevredenheid", article: "de", definition: "customer satisfaction", example: "Klanttevredenheid is ons doel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "klantenbinding", article: "de", definition: "customer loyalty", example: "Klantenbinding verhoogt winst.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "verkoopcijfers", article: "de", definition: "sales figures", example: "De verkoopcijfers zijn goed.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "winstmarge", article: "de", definition: "profit margin", example: "De winstmarge is gezond.", plural: "winstmarges", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "kostenbeheersing", article: "de", definition: "cost control", example: "Kostenbeheersing is noodzakelijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "budgettering", article: "de", definition: "budgeting", example: "Budgettering helpt bij planning.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business),
                DutchWord(word: "financiering", article: "de", definition: "financing", example: "Financiering is beschikbaar.", plural: "financieringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .business)
            ],
            description: "Advanced business vocabulary for professional discussions"
        )
    }
    
    // MARK: - Advanced Technology & Digital Vocabulary
    
    static var advancedTechnologyB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Technologie Gevorderd (B1)",
            level: .b1,
            category: .technology,
            words: [
                DutchWord(word: "digitalisering", article: "de", definition: "digitalization", example: "Digitalisering verandert alles.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "automatisering", article: "de", definition: "automation", example: "Automatisering verhoogt efficiency.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "robotisering", article: "de", definition: "robotization", example: "Robotisering neemt toe.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "kunstmatige intelligentie", article: "de", definition: "artificial intelligence", example: "AI revolutioneert industrie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "machine learning", article: "het", definition: "machine learning", example: "Machine learning verbetert systemen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "big data", article: "de", definition: "big data", example: "Big data geeft inzichten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "dataanalyse", article: "de", definition: "data analysis", example: "Dataanalyse onthult patronen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "cloudcomputing", article: "het", definition: "cloud computing", example: "Cloudcomputing is flexibel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "cybersecurity", article: "de", definition: "cybersecurity", example: "Cybersecurity is cruciaal.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "databeveiliging", article: "de", definition: "data security", example: "Databeveiliging voorkomt lekken.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "privacy", article: "de", definition: "privacy", example: "Privacy is een recht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "gegevensbescherming", article: "de", definition: "data protection", example: "Gegevensbescherming is wettelijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "internetverbinding", article: "de", definition: "internet connection", example: "Snelle internetverbinding is nodig.", plural: "internetverbindingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "bandbreedte", article: "de", definition: "bandwidth", example: "Meer bandbreedte betekent sneller.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "downloadsnelheid", article: "de", definition: "download speed", example: "Downloadsnelheid is belangrijk.", plural: "downloadsnelheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "uploadsnelheid", article: "de", definition: "upload speed", example: "Uploadsnelheid bepaalt prestatie.", plural: "uploadsnelheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "gebruikersinterface", article: "de", definition: "user interface", example: "Eenvoudige interface is beter.", plural: "gebruikersinterfaces", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "gebruikerservaring", article: "de", definition: "user experience", example: "Goede gebruikerservaring is essentieel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "gebruiksvriendelijkheid", article: "de", definition: "user-friendliness", example: "Gebruiksvriendelijkheid verhoogt adoptie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "compatibiliteit", article: "de", definition: "compatibility", example: "Compatibiliteit voorkomt problemen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "interoperabiliteit", article: "de", definition: "interoperability", example: "Interoperabiliteit verbindt systemen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "schaalbaarheid", article: "de", definition: "scalability", example: "Schaalbaarheid is belangrijk voor groei.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "betrouwbaarheid", article: "de", definition: "reliability", example: "Systeembetrouwbaarheid is cruciaal.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "beschikbaarheid", article: "de", definition: "availability", example: "24/7 beschikbaarheid is vereist.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "prestatie", article: "de", definition: "performance", example: "Systeemprestatie moet geoptimaliseerd.", plural: "prestaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "optimalisatie", article: "de", definition: "optimization", example: "Optimalisatie verbetert snelheid.", plural: "optimalisaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "configuratie", article: "de", definition: "configuration", example: "Juiste configuratie is belangrijk.", plural: "configuraties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "installatie", article: "de", definition: "installation", example: "Installatie is eenvoudig.", plural: "installaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "implementatie", article: "de", definition: "implementation", example: "Implementatie duurt drie maanden.", plural: "implementaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "integratie", article: "de", definition: "integration", example: "Systeemintegratie is complex.", plural: "integraties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "migratie", article: "de", definition: "migration", example: "Datamigratie vergt voorbereiding.", plural: "migraties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "synchronisatie", article: "de", definition: "synchronization", example: "Synchronisatie houdt data consistent.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "archivering", article: "de", definition: "archiving", example: "Archivering bewaart oude data.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "versioning", article: "de", definition: "versioning", example: "Versioning houdt wijzigingen bij.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "debuggen", article: "", definition: "to debug", example: "Debuggen lost problemen op.", plural: "", pastTense: "debugde", futureTense: "zal debuggen", pastParticiple: "gedebugd", wordType: .verb, level: .b1, category: .technology),
                DutchWord(word: "testen", article: "", definition: "to test", example: "Testen voorkomt fouten.", plural: "", pastTense: "testte", futureTense: "zal testen", pastParticiple: "getest", wordType: .verb, level: .b1, category: .technology),
                DutchWord(word: "valideren", article: "", definition: "to validate", example: "Valideren controleert juistheid.", plural: "", pastTense: "valideerde", futureTense: "zal valideren", pastParticiple: "gevalideerd", wordType: .verb, level: .b1, category: .technology),
                DutchWord(word: "verificatie", article: "de", definition: "verification", example: "Verificatie bevestigt identiteit.", plural: "verificaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "authenticatie", article: "de", definition: "authentication", example: "Authenticatie beveiligt toegang.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "autorisatie", article: "de", definition: "authorization", example: "Autorisatie geeft toegangsrechten.", plural: "autorisaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "toegangscontrole", article: "de", definition: "access control", example: "Toegangscontrole beschermt systemen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "tweefactorauthenticatie", article: "de", definition: "two-factor authentication", example: "Tweefactorauthenticatie is veiliger.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "biometrisch", article: "", definition: "biometric", example: "Biometrische scanners zijn nauwkeurig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .technology),
                DutchWord(word: "vingerafdruk", article: "de", definition: "fingerprint", example: "Vingerafdruk ontgrendelt telefoon.", plural: "vingerafdrukken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "gezichtsherkenning", article: "de", definition: "facial recognition", example: "Gezichtsherkenning is controversieel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "spraakherkenning", article: "de", definition: "speech recognition", example: "Spraakherkenning wordt beter.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "natuurlijke taal", article: "de", definition: "natural language", example: "Natuurlijke taalverwerking is complex.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "chatbot", article: "de", definition: "chatbot", example: "Chatbots helpen klanten.", plural: "chatbots", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "virtuele assistent", article: "de", definition: "virtual assistant", example: "Virtuele assistenten zijn handig.", plural: "virtuele assistenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "augmented reality", article: "de", definition: "augmented reality", example: "AR verrijkt de werkelijkheid.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology),
                DutchWord(word: "virtual reality", article: "de", definition: "virtual reality", example: "VR creëert nieuwe werelden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .technology)
            ],
            description: "Advanced technology vocabulary for digital discussions"
        )
    }
    
    // MARK: - Society & Social Issues Vocabulary
    
    static var societyB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Maatschappij (B1)",
            level: .b1,
            category: .politics,
            words: [
                DutchWord(word: "maatschappij", article: "de", definition: "society", example: "Onze maatschappij verandert snel.", plural: "maatschappijen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "gemeenschap", article: "de", definition: "community", example: "De gemeenschap werkt samen.", plural: "gemeenschappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "burgerschap", article: "het", definition: "citizenship", example: "Burgerschap brengt rechten en plichten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "burger", article: "de", definition: "citizen", example: "Elke burger heeft stemrecht.", plural: "burgers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "democratie", article: "de", definition: "democracy", example: "Democratie vereist participatie.", plural: "democratieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vrijheid", article: "de", definition: "freedom", example: "Vrijheid is een fundamenteel recht.", plural: "vrijheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "gelijkheid", article: "de", definition: "equality", example: "Gelijkheid voor de wet is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "rechtvaardigheid", article: "de", definition: "justice", example: "Rechtvaardigheid moet zegevieren.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "solidariteit", article: "de", definition: "solidarity", example: "Solidariteit verbindt mensen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "tolerantie", article: "de", definition: "tolerance", example: "Tolerantie is een Nederlandse waarde.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "diversiteit", article: "de", definition: "diversity", example: "Diversiteit verrijkt de samenleving.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "inclusie", article: "de", definition: "inclusion", example: "Inclusie is belangrijk voor iedereen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "discriminatie", article: "de", definition: "discrimination", example: "Discriminatie is verboden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vooroordeel", article: "het", definition: "prejudice", example: "Vooroordelen zijn schadelijk.", plural: "vooroordelen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "stereotype", article: "het", definition: "stereotype", example: "Stereotypes zijn vaak onjuist.", plural: "stereotypes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "integratie", article: "de", definition: "integration", example: "Integratie is een tweezijdig proces.", plural: "integraties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "assimilatie", article: "de", definition: "assimilation", example: "Assimilatie betekent aanpassing.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "multiculturalisme", article: "het", definition: "multiculturalism", example: "Multiculturalisme kenmerkt Nederland.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "globalisering", article: "de", definition: "globalization", example: "Globalisering verbindt de wereld.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "urbanisatie", article: "de", definition: "urbanization", example: "Urbanisatie concentreert bevolking.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vergrijzing", article: "de", definition: "aging population", example: "Vergrijzing is een uitdaging.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "jeugdwerkloosheid", article: "de", definition: "youth unemployment", example: "Jeugdwerkloosheid is een probleem.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "sociale zekerheid", article: "de", definition: "social security", example: "Sociale zekerheid beschermt burgers.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "welvaartsstaat", article: "de", definition: "welfare state", example: "De welvaartsstaat zorgt voor iedereen.", plural: "welvaartsstaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "inkomensongelijkheid", article: "de", definition: "income inequality", example: "Inkomensongelijkheid groeit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics)
            ],
            description: "Society and social issues vocabulary for civic discussions"
        )
    }
    
    // MARK: - PACK 4: ADVANCED TRANSPORTATION & LOGISTICS (B1)
    
    static var advancedTransportationB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Geavanceerd Vervoer en Logistiek (B1)",
            level: .b1,
            category: .logistics,
            words: [
                // Public Transportation & Infrastructure
                DutchWord(word: "openbaar vervoer", article: "het", definition: "public transportation", example: "Openbaar vervoer is milieuvriendelijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "dienstregeling", article: "de", definition: "timetable/schedule", example: "De dienstregeling is veranderd.", plural: "dienstregelingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "vertraging", article: "de", definition: "delay", example: "De trein heeft een vertraging van 10 minuten.", plural: "vertragingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "aansluiting", article: "de", definition: "connection (transport)", example: "Ik mis mijn aansluiting in Utrecht.", plural: "aansluitingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "perron", article: "het", definition: "platform", example: "De trein vertrekt van perron 3.", plural: "perrons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "spoor", article: "het", definition: "track/railway", example: "Het spoor is geblokkeerd.", plural: "sporen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "conducteur", article: "de", definition: "conductor", example: "De conducteur controleert de kaartjes.", plural: "conducteurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "machinist", article: "de", definition: "train driver", example: "De machinist stuurt de trein.", plural: "machinisten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "halte", article: "de", definition: "stop/station", example: "De bus stopt bij elke halte.", plural: "haltes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "eindstation", article: "het", definition: "terminus", example: "Dit is het eindstation van lijn 12.", plural: "eindstations", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                
                // Automotive & Traffic
                DutchWord(word: "verkeerslicht", article: "het", definition: "traffic light", example: "Stop voor het rode verkeerslicht.", plural: "verkeerslichten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "rotonde", article: "de", definition: "roundabout", example: "Neem de tweede afslag bij de rotonde.", plural: "rotondes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "kruising", article: "de", definition: "intersection", example: "Let op bij de kruising.", plural: "kruisingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "snelweg", article: "de", definition: "highway", example: "De snelweg is druk vandaag.", plural: "snelwegen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "provinciale weg", article: "de", definition: "provincial road", example: "De provinciale weg is smaller.", plural: "provinciale wegen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "parkeerplaats", article: "de", definition: "parking space", example: "Er is geen parkeerplaats vrij.", plural: "parkeerplaatsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "parkeergarage", article: "de", definition: "parking garage", example: "De parkeergarage is vol.", plural: "parkeergarages", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "tolweg", article: "de", definition: "toll road", example: "In Frankrijk zijn er veel tolwegen.", plural: "tolwegen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "tankstation", article: "het", definition: "gas station", example: "We moeten tanken bij het tankstation.", plural: "tankstations", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "benzine", article: "de", definition: "gasoline", example: "Benzine wordt steeds duurder.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "diesel", article: "de", definition: "diesel", example: "Dieselauto's zijn zuiniger.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "elektrisch", article: "", definition: "electric", example: "Elektrische auto's zijn populair.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .logistics),
                
                // Aviation
                DutchWord(word: "luchthaven", article: "de", definition: "airport", example: "Schiphol is de grootste luchthaven.", plural: "luchthavens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "terminal", article: "de", definition: "terminal", example: "Mijn vlucht vertrekt van terminal 2.", plural: "terminals", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "gate", article: "de", definition: "gate", example: "Ga naar gate B7 voor instappen.", plural: "gates", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "instappen", article: "", definition: "to board", example: "We kunnen nu instappen.", plural: "", pastTense: "stapte in", futureTense: "zal instappen", pastParticiple: "ingestapt", wordType: .verb, level: .b1, category: .logistics),
                DutchWord(word: "uitstappen", article: "", definition: "to disembark", example: "Alle passagiers moeten uitstappen.", plural: "", pastTense: "stapte uit", futureTense: "zal uitstappen", pastParticiple: "uitgestapt", wordType: .verb, level: .b1, category: .logistics),
                DutchWord(word: "piloot", article: "de", definition: "pilot", example: "De piloot maakt een veilige landing.", plural: "piloten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "steward", article: "de", definition: "flight attendant (male)", example: "De steward serveert drankjes.", plural: "stewards", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "stewardess", article: "de", definition: "flight attendant (female)", example: "De stewardess legt de veiligheid uit.", plural: "stewardessen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "turbulentie", article: "de", definition: "turbulence", example: "Er is lichte turbulentie verwacht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "landing", article: "de", definition: "landing", example: "De landing was zeer soepel.", plural: "landingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "opstijgen", article: "", definition: "to take off", example: "Het vliegtuig stijgt om 15:30 op.", plural: "", pastTense: "steeg op", futureTense: "zal opstijgen", pastParticiple: "opgestegen", wordType: .verb, level: .b1, category: .logistics),
                
                // Maritime & Shipping
                DutchWord(word: "haven", article: "de", definition: "harbor/port", example: "Rotterdam heeft de grootste haven.", plural: "havens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "containerschip", article: "het", definition: "container ship", example: "Het containerschip is enorm.", plural: "containerschepen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "veerboot", article: "de", definition: "ferry", example: "De veerboot vaart naar Engeland.", plural: "veerboten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "kapitein", article: "de", definition: "captain", example: "De kapitein stuurt het schip.", plural: "kapiteins", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "bemanning", article: "de", definition: "crew", example: "De bemanning werkt hard.", plural: "bemanningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "lading", article: "de", definition: "cargo", example: "De lading wordt gelost.", plural: "ladingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "container", article: "de", definition: "container", example: "De container is 40 voet lang.", plural: "containers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                
                // Logistics & Transport Management
                DutchWord(word: "logistiek", article: "de", definition: "logistics", example: "Logistiek is cruciaal voor handel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "distributie", article: "de", definition: "distribution", example: "Distributie moet efficiënt zijn.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "magazijn", article: "het", definition: "warehouse", example: "Het magazijn is vol voorraad.", plural: "magazijnen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "voorraad", article: "de", definition: "inventory/stock", example: "De voorraad is bijna op.", plural: "voorraden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "levering", article: "de", definition: "delivery", example: "De levering komt morgen aan.", plural: "leveringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "bezorgen", article: "", definition: "to deliver", example: "Wij bezorgen binnen 24 uur.", plural: "", pastTense: "bezorgde", futureTense: "zal bezorgen", pastParticiple: "bezorgd", wordType: .verb, level: .b1, category: .logistics),
                DutchWord(word: "transport", article: "het", definition: "transport", example: "Transport over water is goedkoop.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "vervoerder", article: "de", definition: "carrier/transporter", example: "De vervoerder is betrouwbaar.", plural: "vervoerders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "expeditie", article: "de", definition: "shipping/forwarding", example: "Het expeditiebedrijf regelt alles.", plural: "expedities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics),
                DutchWord(word: "vrachtbrief", article: "de", definition: "bill of lading", example: "De vrachtbrief is het bewijs.", plural: "vrachtbrieven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .logistics)
            ],
            description: "Advanced transportation and logistics vocabulary for professional and travel contexts"
        )
    }
    
    // MARK: - PACK 5: ARTS & CULTURE (B1)
    
    static var artsCultureB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Kunst en Cultuur (B1)",
            level: .b1,
            category: .culture,
            words: [
                // Museums & Exhibitions
                DutchWord(word: "museum", article: "het", definition: "museum", example: "Het Rijksmuseum is wereldberoemd.", plural: "musea", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "tentoonstelling", article: "de", definition: "exhibition", example: "De tentoonstelling loopt tot december.", plural: "tentoonstellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "expositie", article: "de", definition: "exposition", example: "De expositie toont moderne kunst.", plural: "exposities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "kunstwerk", article: "het", definition: "artwork", example: "Dit kunstwerk is zeer waardevol.", plural: "kunstwerken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "schilderij", article: "het", definition: "painting", example: "Van Gogh's schilderijen zijn beroemd.", plural: "schilderijen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "beeldhouwwerk", article: "het", definition: "sculpture", example: "Het beeldhouwwerk staat in het park.", plural: "beeldhouwwerken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "kunstenaar", article: "de", definition: "artist", example: "De kunstenaar exposeert zijn werk.", plural: "kunstenaars", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "schilder", article: "de", definition: "painter", example: "Rembrandt was een grote schilder.", plural: "schilders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "beeldhouwer", article: "de", definition: "sculptor", example: "De beeldhouwer werkt met marmer.", plural: "beeldhouwers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "galerij", article: "de", definition: "gallery", example: "De galerij toont hedendaagse kunst.", plural: "galerijen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                
                // Theater & Performing Arts
                DutchWord(word: "theater", article: "het", definition: "theater", example: "We gaan vanavond naar het theater.", plural: "theaters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "toneelstuk", article: "het", definition: "play", example: "Het toneelstuk was indrukwekkend.", plural: "toneelstukken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "voorstelling", article: "de", definition: "performance", example: "De voorstelling begint om acht uur.", plural: "voorstellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "acteur", article: "de", definition: "actor", example: "De acteur speelt zijn rol perfect.", plural: "acteurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "actrice", article: "de", definition: "actress", example: "De actrice won een prijs.", plural: "actrices", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "regisseur", article: "de", definition: "director", example: "De regisseur geeft aanwijzingen.", plural: "regisseurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "script", article: "het", definition: "script", example: "Het script is nog niet af.", plural: "scripts", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "podium", article: "het", definition: "stage", example: "De acteurs staan op het podium.", plural: "podiums", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "publiek", article: "het", definition: "audience", example: "Het publiek applaudisseerde luid.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "applaus", article: "het", definition: "applause", example: "Er klonk spontaan applaus.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                
                // Music
                DutchWord(word: "muziek", article: "de", definition: "music", example: "Muziek verbindt mensen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "concert", article: "het", definition: "concert", example: "Het concert was uitverkocht.", plural: "concerten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "orkest", article: "het", definition: "orchestra", example: "Het orkest speelt Beethoven.", plural: "orkesten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "dirigent", article: "de", definition: "conductor", example: "De dirigent leidt het orkest.", plural: "dirigenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "musicus", article: "de", definition: "musician", example: "De musicus speelt viool.", plural: "musici", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "componist", article: "de", definition: "composer", example: "Mozart was een beroemde componist.", plural: "componisten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "compositie", article: "de", definition: "composition", example: "Deze compositie is complex.", plural: "composities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "instrument", article: "het", definition: "instrument", example: "Welk instrument bespeel je?", plural: "instrumenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "melodie", article: "de", definition: "melody", example: "De melodie is heel mooi.", plural: "melodieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "ritme", article: "het", definition: "rhythm", example: "Het ritme is heel catchy.", plural: "ritmes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                
                // Literature
                DutchWord(word: "literatuur", article: "de", definition: "literature", example: "Nederlandse literatuur is rijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "schrijver", article: "de", definition: "writer", example: "De schrijver publiceert een nieuw boek.", plural: "schrijvers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "auteur", article: "de", definition: "author", example: "De auteur signeert boeken.", plural: "auteurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "dichter", article: "de", definition: "poet", example: "De dichter leest zijn gedichten voor.", plural: "dichters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "gedicht", article: "het", definition: "poem", example: "Dit gedicht is ontroerend.", plural: "gedichten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "roman", article: "de", definition: "novel", example: "Deze roman is een bestseller.", plural: "romans", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "verhaal", article: "het", definition: "story", example: "Het verhaal heeft een verrassend einde.", plural: "verhalen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "hoofdstuk", article: "het", definition: "chapter", example: "Ik lees het laatste hoofdstuk.", plural: "hoofdstukken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "bibliotheek", article: "de", definition: "library", example: "De bibliotheek heeft veel boeken.", plural: "bibliotheken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "uitgeverij", article: "de", definition: "publisher", example: "De uitgeverij publiceert het boek.", plural: "uitgeverijen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                
                // Film & Media
                DutchWord(word: "film", article: "de", definition: "film/movie", example: "De film won een Oscar.", plural: "films", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "bioscoop", article: "de", definition: "cinema", example: "We gaan naar de bioscoop.", plural: "bioscopen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "documentaire", article: "de", definition: "documentary", example: "De documentaire is leerzaam.", plural: "documentaires", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "animatie", article: "de", definition: "animation", example: "Animatie is populair bij kinderen.", plural: "animaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "scenario", article: "het", definition: "screenplay", example: "Het scenario is goed geschreven.", plural: "scenario's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                
                // Cultural Events & Festivals
                DutchWord(word: "festival", article: "het", definition: "festival", example: "Het muziekfestival duurt drie dagen.", plural: "festivals", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "evenement", article: "het", definition: "event", example: "Het evenement was een groot succes.", plural: "evenementen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "cultureel", article: "", definition: "cultural", example: "Amsterdam heeft een rijk cultureel leven.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .culture),
                DutchWord(word: "traditie", article: "de", definition: "tradition", example: "Deze traditie is eeuwenoud.", plural: "tradities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "erfgoed", article: "het", definition: "heritage", example: "Het erfgoed moet beschermd worden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "monument", article: "het", definition: "monument", example: "Het monument herdenkt de oorlog.", plural: "monumenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "architectuur", article: "de", definition: "architecture", example: "Amsterdamse architectuur is uniek.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture),
                DutchWord(word: "architect", article: "de", definition: "architect", example: "De architect ontwierp het gebouw.", plural: "architecten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .culture)
            ],
            description: "Arts and culture vocabulary for discussing museums, theater, music, literature, and cultural experiences"
        )
    }
    
    // MARK: - PACK 6: ADVANCED HOME & LIVING (B1)
    
    static var advancedHomeLivingB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Geavanceerd Wonen en Leven (B1)",
            level: .b1,
            category: .home,
            words: [
                // Interior Design & Furniture
                DutchWord(word: "inrichting", article: "de", definition: "interior design/furnishing", example: "De inrichting van het huis is modern.", plural: "inrichtingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "interieur", article: "het", definition: "interior", example: "Het interieur is smaakvol ingericht.", plural: "interieurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "meubilair", article: "het", definition: "furniture", example: "Het meubilair is van goede kwaliteit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "decoratie", article: "de", definition: "decoration", example: "De decoratie geeft sfeer aan de kamer.", plural: "decoraties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "behang", article: "het", definition: "wallpaper", example: "Het behang heeft een mooi patroon.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "vloerbedekking", article: "de", definition: "flooring/carpet", example: "De vloerbedekking is comfortabel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "parket", article: "het", definition: "parquet/hardwood floor", example: "Het parket glans mooi.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "tegels", article: "de", definition: "tiles", example: "De tegels in de badkamer zijn nieuw.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "gordijnen", article: "de", definition: "curtains", example: "De gordijnen houden het licht tegen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "jaloezie", article: "de", definition: "blinds", example: "De jaloezie regelt het licht.", plural: "jaloezieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                
                // Household Appliances
                DutchWord(word: "huishoudapparaat", article: "het", definition: "household appliance", example: "Dit huishoudapparaat is energiezuinig.", plural: "huishoudapparaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "wasmachine", article: "de", definition: "washing machine", example: "De wasmachine is kapot.", plural: "wasmachines", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "droger", article: "de", definition: "dryer", example: "De droger staat naast de wasmachine.", plural: "drogers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "vaatwasser", article: "de", definition: "dishwasher", example: "De vaatwasser bespaart tijd.", plural: "vaatwassers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "stofzuiger", article: "de", definition: "vacuum cleaner", example: "De stofzuiger zuigt goed.", plural: "stofzuigers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "airconditioning", article: "de", definition: "air conditioning", example: "De airconditioning koelt het huis.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "ventilator", article: "de", definition: "fan", example: "De ventilator zorgt voor verkoeling.", plural: "ventilatoren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "verwarming", article: "de", definition: "heating", example: "De verwarming werkt goed.", plural: "verwarmingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "radiator", article: "de", definition: "radiator", example: "De radiator wordt warm.", plural: "radiatoren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "thermostaat", article: "de", definition: "thermostat", example: "De thermostaat regelt de temperatuur.", plural: "thermostaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                
                // Kitchen Equipment
                DutchWord(word: "keukenapparatuur", article: "de", definition: "kitchen equipment", example: "Moderne keukenapparatuur is handig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "magnetron", article: "de", definition: "microwave", example: "De magnetron warmt eten snel op.", plural: "magnetrons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "blender", article: "de", definition: "blender", example: "De blender maakt smoothies.", plural: "blenders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "mixer", article: "de", definition: "mixer", example: "De mixer klopt het deeg.", plural: "mixers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "broodrooster", article: "de", definition: "toaster", example: "De broodrooster maakt toast.", plural: "broodroosters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "koffiezetapparaat", article: "het", definition: "coffee maker", example: "Het koffiezetapparaat zet sterke koffie.", plural: "koffiezetapparaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "waterkoker", article: "de", definition: "kettle", example: "De waterkoker kookt snel.", plural: "waterkokers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "afzuigkap", article: "de", definition: "range hood", example: "De afzuigkap zuigt rook weg.", plural: "afzuigkappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                
                // Utilities & Infrastructure
                DutchWord(word: "nutsvoorzieningen", article: "de", definition: "utilities", example: "Alle nutsvoorzieningen zijn aangesloten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "elektriciteit", article: "de", definition: "electricity", example: "Elektriciteit is duur geworden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "waterleiding", article: "de", definition: "water supply/plumbing", example: "De waterleiding moet gerepareerd.", plural: "waterleidingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "gasleiding", article: "de", definition: "gas line", example: "De gasleiding is veilig geïnstalleerd.", plural: "gasleidingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "riolering", article: "de", definition: "sewerage", example: "De riolering is verstopt.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "internetaansluiting", article: "de", definition: "internet connection", example: "De internetaansluiting is snel.", plural: "internetaansluitingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "wifi", article: "de", definition: "wifi", example: "De wifi werkt goed.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                
                // Home Maintenance & Security
                DutchWord(word: "onderhoud", article: "het", definition: "maintenance", example: "Regelmatig onderhoud is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "reparatie", article: "de", definition: "repair", example: "De reparatie kost veel geld.", plural: "reparaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "renovatie", article: "de", definition: "renovation", example: "De renovatie duurt drie maanden.", plural: "renovaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "verbouwing", article: "de", definition: "remodeling", example: "De verbouwing is bijna klaar.", plural: "verbouwingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "isolatie", article: "de", definition: "insulation", example: "Goede isolatie bespaart energie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "beveiliging", article: "de", definition: "security", example: "De beveiliging van het huis is goed.", plural: "beveiligingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "alarm", article: "het", definition: "alarm", example: "Het alarm gaat af bij inbraak.", plural: "alarmen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "rookmelder", article: "de", definition: "smoke detector", example: "De rookmelder piept als de batterij leeg is.", plural: "rookmelders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                
                // Modern Living & Smart Home
                DutchWord(word: "slimme woning", article: "de", definition: "smart home", example: "Een slimme woning bespaart energie.", plural: "slimme woningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "domotica", article: "de", definition: "home automation", example: "Domotica maakt het leven gemakkelijker.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "energiezuinig", article: "", definition: "energy-efficient", example: "Energiezuinige apparaten zijn duurder.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .home),
                DutchWord(word: "duurzaamheid", article: "de", definition: "sustainability", example: "Duurzaamheid is steeds belangrijker.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "zonnepanelen", article: "de", definition: "solar panels", example: "Zonnepanelen wekken stroom op.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "warmtepomp", article: "de", definition: "heat pump", example: "Een warmtepomp is milieuvriendelijk.", plural: "warmtepompen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "ventilatie", article: "de", definition: "ventilation", example: "Goede ventilatie voorkomt schimmel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home),
                DutchWord(word: "luchtkwaliteit", article: "de", definition: "air quality", example: "De luchtkwaliteit binnenshuis is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .home)
            ],
            description: "Advanced home and living vocabulary for discussing interior design, appliances, utilities, and modern housing"
        )
    }
    
    // MARK: - PACK 7: COMPLETE WEATHER & CLIMATE (B1)
    
    static var weatherClimateB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Weer en Klimaat Compleet (B1)",
            level: .b1,
            category: .nature,
            words: [
                // Weather Conditions & Phenomena
                DutchWord(word: "weersomstandigheden", article: "de", definition: "weather conditions", example: "De weersomstandigheden zijn slecht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "weersverwachting", article: "de", definition: "weather forecast", example: "De weersverwachting voorspelt regen.", plural: "weersverwachtingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "meteorologie", article: "de", definition: "meteorology", example: "Meteorologie is de studie van het weer.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "weerman", article: "de", definition: "weatherman", example: "De weerman voorspelt storm.", plural: "weermannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "neerslag", article: "de", definition: "precipitation", example: "Er wordt veel neerslag verwacht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "regenbui", article: "de", definition: "rain shower", example: "Een korte regenbui koelt af.", plural: "regenbuien", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "hoosbui", article: "de", definition: "downpour", example: "De hoosbui overviel ons.", plural: "hoosbuien", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "motregen", article: "de", definition: "drizzle", example: "Motregen maakt alles nat.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "hagel", article: "de", definition: "hail", example: "Hagel beschadigde de auto's.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "ijzel", article: "de", definition: "freezing rain", example: "IJzel maakt de wegen glad.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                
                // Temperature & Atmospheric Conditions
                DutchWord(word: "temperatuur", article: "de", definition: "temperature", example: "De temperatuur stijgt snel.", plural: "temperaturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "hittegolf", article: "de", definition: "heat wave", example: "De hittegolf duurt al een week.", plural: "hittegolven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "vorst", article: "de", definition: "frost", example: "Vorst beschadigde de planten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "rijp", article: "de", definition: "hoarfrost", example: "Rijp bedekt het gras.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "luchtvochtigheid", article: "de", definition: "humidity", example: "De luchtvochtigheid is hoog.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "luchtdruk", article: "de", definition: "air pressure", example: "Lage luchtdruk brengt regen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "barometer", article: "de", definition: "barometer", example: "De barometer daalt snel.", plural: "barometers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "thermometer", article: "de", definition: "thermometer", example: "De thermometer toont 25 graden.", plural: "thermometers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                
                // Wind & Air Movement
                DutchWord(word: "windkracht", article: "de", definition: "wind force", example: "De windkracht neemt toe.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "windrichting", article: "de", definition: "wind direction", example: "De windrichting is noordwest.", plural: "windrichtingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "windstil", article: "", definition: "windless/calm", example: "Het is vandaag windstil.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .nature),
                DutchWord(word: "bries", article: "de", definition: "breeze", example: "Een zachte bries koelt af.", plural: "briezen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "storm", article: "de", definition: "storm", example: "De storm richt veel schade aan.", plural: "stormen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "orkaan", article: "de", definition: "hurricane", example: "De orkaan nadert de kust.", plural: "orkanen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "tornado", article: "de", definition: "tornado", example: "Een tornado verwoestte het dorp.", plural: "tornado's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                
                // Clouds & Visibility
                DutchWord(word: "bewolking", article: "de", definition: "cloud cover", example: "De bewolking neemt toe.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "wolkenformatie", article: "de", definition: "cloud formation", example: "Interessante wolkenformaties aan de hemel.", plural: "wolkenformaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "onweerswolk", article: "de", definition: "thundercloud", example: "Donkere onweerswolken pakken samen.", plural: "onweerswolken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "mist", article: "de", definition: "fog", example: "Dichte mist beperkt het zicht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "nevel", article: "de", definition: "mist/haze", example: "Lichte nevel hangt over het water.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "zicht", article: "het", definition: "visibility", example: "Het zicht is minder dan 100 meter.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                
                // Seasons & Climate Patterns
                DutchWord(word: "seizoen", article: "het", definition: "season", example: "Elk seizoen heeft zijn charme.", plural: "seizoenen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "klimaat", article: "het", definition: "climate", example: "Het klimaat verandert wereldwijd.", plural: "klimaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "klimaatverandering", article: "de", definition: "climate change", example: "Klimaatverandering is een urgent probleem.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "opwarming", article: "de", definition: "warming", example: "De aarde opwarming gaat door.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "broeikaseffect", article: "het", definition: "greenhouse effect", example: "Het broeikaseffect versterkt zich.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "droogte", article: "de", definition: "drought", example: "De droogte duurt al maanden.", plural: "droogtes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "overstroming", article: "de", definition: "flood", example: "De overstroming veroorzaakte schade.", plural: "overstromingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                
                // Lightning & Thunder
                DutchWord(word: "onweer", article: "het", definition: "thunderstorm", example: "Het onweer komt dichterbij.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "bliksem", article: "de", definition: "lightning", example: "Bliksem verlicht de hemel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "donder", article: "de", definition: "thunder", example: "De donder rolt over het land.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "blikseminslag", article: "de", definition: "lightning strike", example: "Een blikseminslag trof de boom.", plural: "blikseminslagen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                
                // Natural Phenomena
                DutchWord(word: "regenboog", article: "de", definition: "rainbow", example: "Een prachtige regenboog verschijnt.", plural: "regenbogen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "zonsopkomst", article: "de", definition: "sunrise", example: "De zonsopkomst is om 7 uur.", plural: "zonsopkomsten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "zonsondergang", article: "de", definition: "sunset", example: "De zonsondergang kleurt de hemel rood.", plural: "zonsondergangen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "schemering", article: "de", definition: "twilight", example: "In de schemering wordt het donker.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "dauw", article: "de", definition: "dew", example: "Dauw bedekt het gras 's ochtends.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                
                // Weather Measurement & Prediction
                DutchWord(word: "weerstation", article: "het", definition: "weather station", example: "Het weerstation meet de temperatuur.", plural: "weerstations", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "satellietbeeld", article: "het", definition: "satellite image", example: "Het satellietbeeld toont wolken.", plural: "satellietbeelden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "weerkaart", article: "de", definition: "weather map", example: "De weerkaart voorspelt regen.", plural: "weerkaarten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "weermodel", article: "het", definition: "weather model", example: "Het weermodel berekent voorspellingen.", plural: "weermodellen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature),
                DutchWord(word: "weerwaarschuwing", article: "de", definition: "weather warning", example: "Er is een weerwaarschuwing afgegeven.", plural: "weerwaarschuwingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .nature)
            ],
            description: "Complete weather and climate vocabulary for discussing meteorology, natural phenomena, and climate change"
        )
    }
    
    // MARK: - PACK 8: ADVANCED COOKING & CUISINE (B1)
    
    static var advancedCookingCuisineB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Geavanceerd Koken en Keuken (B1)",
            level: .b1,
            category: .food,
            words: [
                // Cooking Techniques & Methods
                DutchWord(word: "kooktechniek", article: "de", definition: "cooking technique", example: "Deze kooktechniek vereist precisie.", plural: "kooktechnieken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "bereidingswijze", article: "de", definition: "preparation method", example: "De bereidingswijze staat in het recept.", plural: "bereidingswijzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "marineren", article: "", definition: "to marinate", example: "Marineer het vlees twee uur.", plural: "", pastTense: "marineerde", futureTense: "zal marineren", pastParticiple: "gemarineerd", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "braden", article: "", definition: "to roast", example: "Braad de kip in de oven.", plural: "", pastTense: "braadde", futureTense: "zal braden", pastParticiple: "gebraden", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "sudderen", article: "", definition: "to simmer", example: "Laat de soep zachtjes sudderen.", plural: "", pastTense: "sudderde", futureTense: "zal sudderen", pastParticiple: "gesudderd", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "stomen", article: "", definition: "to steam", example: "Stoom de groenten licht.", plural: "", pastTense: "stoomde", futureTense: "zal stomen", pastParticiple: "gestoomd", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "pocheren", article: "", definition: "to poach", example: "Pocheer het ei in water.", plural: "", pastTense: "pocheerde", futureTense: "zal pocheren", pastParticiple: "gepocheerd", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "flamberen", article: "", definition: "to flambé", example: "Flambeer het dessert met cognac.", plural: "", pastTense: "flambeerde", futureTense: "zal flamberen", pastParticiple: "geflambeerd", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "karameliseren", article: "", definition: "to caramelize", example: "Karameliseer de uien langzaam.", plural: "", pastTense: "karameliseerde", futureTense: "zal karameliseren", pastParticiple: "gekarameliseerd", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "gratineren", article: "", definition: "to gratinate", example: "Gratineer de lasagne in de oven.", plural: "", pastTense: "gratineerde", futureTense: "zal gratineren", pastParticiple: "gegratineerd", wordType: .verb, level: .b1, category: .food),
                
                // Professional Kitchen Equipment
                DutchWord(word: "professionele keuken", article: "de", definition: "professional kitchen", example: "De professionele keuken is goed uitgerust.", plural: "professionele keukens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "keukenmachine", article: "de", definition: "food processor", example: "De keukenmachine hakt alles fijn.", plural: "keukenmachines", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "staafmixer", article: "de", definition: "hand blender", example: "Gebruik de staafmixer voor de soep.", plural: "staafmixers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "mandoline", article: "de", definition: "mandoline slicer", example: "De mandoline snijdt perfecte plakjes.", plural: "mandolines", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "sous-vide", article: "de", definition: "sous-vide cooking", example: "Sous-vide geeft perfecte resultaten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "pastamaker", article: "de", definition: "pasta machine", example: "De pastamaker maakt verse pasta.", plural: "pastamakers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "wok", article: "de", definition: "wok", example: "Roerbak snel in de hete wok.", plural: "woks", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "grillpan", article: "de", definition: "grill pan", example: "De grillpan geeft mooie strepen.", plural: "grillpannen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                
                // Ingredients & Seasonings
                DutchWord(word: "ingrediënt", article: "het", definition: "ingredient", example: "Alle ingrediënten zijn vers.", plural: "ingrediënten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "kruiden", article: "de", definition: "herbs", example: "Verse kruiden geven meer smaak.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "specerijen", article: "de", definition: "spices", example: "Exotische specerijen maken het bijzonder.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "marinade", article: "de", definition: "marinade", example: "De marinade trekt in het vlees.", plural: "marinades", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "bouillon", article: "de", definition: "broth/stock", example: "Zelfgemaakte bouillon smaakt beter.", plural: "bouillons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "fond", article: "de", definition: "cooking base/stock", example: "Een goede fond is de basis.", plural: "fonds", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "roux", article: "de", definition: "roux (flour-butter mixture)", example: "Maak een roux voor de saus.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "emulsie", article: "de", definition: "emulsion", example: "Mayonaise is een emulsie.", plural: "emulsies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                
                // Recipe & Measurement Terms
                DutchWord(word: "recept", article: "het", definition: "recipe", example: "Dit recept komt uit Frankrijk.", plural: "recepten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "portie", article: "de", definition: "portion/serving", example: "Een portie is 200 gram.", plural: "porties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "hoeveelheid", article: "de", definition: "quantity/amount", example: "De juiste hoeveelheid is belangrijk.", plural: "hoeveelheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "afwegen", article: "", definition: "to weigh", example: "Weeg de ingrediënten nauwkeurig af.", plural: "", pastTense: "woog af", futureTense: "zal afwegen", pastParticiple: "afgewogen", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "afmeten", article: "", definition: "to measure", example: "Meet de vloeistof precies af.", plural: "", pastTense: "mat af", futureTense: "zal afmeten", pastParticiple: "afgemeten", wordType: .verb, level: .b1, category: .food),
                DutchWord(word: "keukenweegschaal", article: "de", definition: "kitchen scale", example: "Een keukenweegschaal is handig.", plural: "keukenweegschalen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                
                // Food Preparation & Presentation
                DutchWord(word: "voorbereiding", article: "de", definition: "preparation", example: "Goede voorbereiding is essentieel.", plural: "voorbereidingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "presentatie", article: "de", definition: "presentation", example: "De presentatie van het bord is mooi.", plural: "presentaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "garnering", article: "de", definition: "garnish", example: "Een eenvoudige garnering volstaat.", plural: "garneringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "decoratie", article: "de", definition: "decoration", example: "De decoratie maakt het feestelijk.", plural: "decoraties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "opscheppen", article: "", definition: "to serve/dish up", example: "Schep het eten mooi op.", plural: "", pastTense: "schepte op", futureTense: "zal opscheppen", pastParticiple: "opgeschept", wordType: .verb, level: .b1, category: .food),
                
                // Culinary Terms & Concepts
                DutchWord(word: "gastronomie", article: "de", definition: "gastronomy", example: "Nederlandse gastronomie evolueert.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "culinair", article: "", definition: "culinary", example: "Een culinaire ervaring.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .food),
                DutchWord(word: "smaakprofiel", article: "het", definition: "flavor profile", example: "Het smaakprofiel is complex.", plural: "smaakprofielen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "textuur", article: "de", definition: "texture", example: "De textuur is perfect.", plural: "texturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "mondgevoel", article: "het", definition: "mouthfeel", example: "Het mondgevoel is romig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "umami", article: "de", definition: "umami (5th taste)", example: "Umami geeft diepte aan de smaak.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                
                // Restaurant & Professional Terms
                DutchWord(word: "chef-kok", article: "de", definition: "head chef", example: "De chef-kok leidt de keuken.", plural: "chef-koks", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "sous-chef", article: "de", definition: "sous chef", example: "De sous-chef assisteert de chef.", plural: "sous-chefs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "keukenbrigade", article: "de", definition: "kitchen brigade", example: "De keukenbrigade werkt als team.", plural: "keukenbrigades", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "mise en place", article: "de", definition: "mise en place (prep work)", example: "Mise en place is cruciaal.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "à la carte", article: "", definition: "à la carte", example: "Het à la carte menu is uitgebreid.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .food),
                DutchWord(word: "degustatiemenu", article: "het", definition: "tasting menu", example: "Het degustatiemenu heeft zeven gangen.", plural: "degustatiemenu's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "amuse-bouche", article: "de", definition: "amuse-bouche", example: "De amuse-bouche opent de maaltijd.", plural: "amuse-bouches", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "hoofdgerecht", article: "het", definition: "main course", example: "Het hoofdgerecht is vis.", plural: "hoofdgerechten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food),
                DutchWord(word: "bijgerecht", article: "het", definition: "side dish", example: "Het bijgerecht past er goed bij.", plural: "bijgerechten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .food)
            ],
            description: "Advanced cooking and cuisine vocabulary for professional kitchen techniques, ingredients, and culinary culture"
        )
    }
    
    // MARK: - PACK 9: POLITICS & SOCIETY (B1)
    
    static var politicsSocietyB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Politiek en Maatschappij (B1)",
            level: .b1,
            category: .politics,
            words: [
                DutchWord(word: "politiek", article: "het", definition: "political", example: "Politiek is een belangrijk aspect.", plural: "politieke", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .politics),
                DutchWord(word: "maatschappij", article: "de", definition: "society", example: "Onze maatschappij verandert snel.", plural: "maatschappijen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "gemeenschap", article: "de", definition: "community", example: "De gemeenschap werkt samen.", plural: "gemeenschappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "burgerschap", article: "het", definition: "citizenship", example: "Burgerschap brengt rechten en plichten.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "burger", article: "de", definition: "citizen", example: "Elke burger heeft stemrecht.", plural: "burgers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "democratie", article: "de", definition: "democracy", example: "Democratie vereist participatie.", plural: "democratieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vrijheid", article: "de", definition: "freedom", example: "Vrijheid is een fundamenteel recht.", plural: "vrijheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "gelijkheid", article: "de", definition: "equality", example: "Gelijkheid voor de wet is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "rechtvaardigheid", article: "de", definition: "justice", example: "Rechtvaardigheid moet zegevieren.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "solidariteit", article: "de", definition: "solidarity", example: "Solidariteit verbindt mensen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "tolerantie", article: "de", definition: "tolerance", example: "Tolerantie is een Nederlandse waarde.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "diversiteit", article: "de", definition: "diversity", example: "Diversiteit verrijkt de samenleving.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "inclusie", article: "de", definition: "inclusion", example: "Inclusie is belangrijk voor iedereen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "discriminatie", article: "de", definition: "discrimination", example: "Discriminatie is verboden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vooroordeel", article: "het", definition: "prejudice", example: "Vooroordelen zijn schadelijk.", plural: "vooroordelen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "stereotype", article: "het", definition: "stereotype", example: "Stereotypes zijn vaak onjuist.", plural: "stereotypes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "integratie", article: "de", definition: "integration", example: "Integratie is een tweezijdig proces.", plural: "integraties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "assimilatie", article: "de", definition: "assimilation", example: "Assimilatie betekent aanpassing.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "multiculturalisme", article: "het", definition: "multiculturalism", example: "Multiculturalisme kenmerkt Nederland.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "globalisering", article: "de", definition: "globalization", example: "Globalisering verbindt de wereld.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "urbanisatie", article: "de", definition: "urbanization", example: "Urbanisatie concentreert bevolking.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vergrijzing", article: "de", definition: "aging population", example: "Vergrijzing is een uitdaging.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "jeugdwerkloosheid", article: "de", definition: "youth unemployment", example: "Jeugdwerkloosheid is een probleem.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "sociale zekerheid", article: "de", definition: "social security", example: "Sociale zekerheid beschermt burgers.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "welvaartsstaat", article: "de", definition: "welfare state", example: "De welvaartsstaat zorgt voor iedereen.", plural: "welvaartsstaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "inkomensongelijkheid", article: "de", definition: "income inequality", example: "Inkomensongelijkheid groeit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics)
            ],
            description: "Society and social issues vocabulary for civic discussions"
        )
    }
    
    // MARK: - PACK 10: CRIME & SAFETY (B1)
    
    static var crimeSafetyB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Misdaad en Veiligheid (B1)",
            level: .b1,
            category: .crime,
            words: [
                DutchWord(word: "misdaad", article: "de", definition: "crime", example: "Misdaad moet bestreden worden.", plural: "misdaden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "veiligheid", article: "de", definition: "safety", example: "Veiligheid is belangrijk voor iedereen.", plural: "veiligheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "politie", article: "de", definition: "police", example: "De politie onderzoekt de zaak.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "agent", article: "de", definition: "police officer", example: "De agent schrijft een boete uit.", plural: "agenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "dief", article: "de", definition: "thief", example: "De dief werd gepakt.", plural: "dieven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "diefstal", article: "de", definition: "theft", example: "Er was een diefstal in de winkel.", plural: "diefstallen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "inbraak", article: "de", definition: "burglary", example: "Er was een inbraak bij de buren.", plural: "inbraken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "inbreker", article: "de", definition: "burglar", example: "De inbreker kwam via het raam.", plural: "inbrekers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "overval", article: "de", definition: "robbery", example: "Er was een overval op de bank.", plural: "overvallen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "geweld", article: "het", definition: "violence", example: "Geweld is nooit de oplossing.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "aanvallen", article: "", definition: "to attack", example: "Hij werd aangevallen op straat.", plural: "", pastTense: "viel aan", futureTense: "zal aanvallen", pastParticiple: "aangevallen", wordType: .verb, level: .b1, category: .crime),
                DutchWord(word: "bedreigen", article: "", definition: "to threaten", example: "Hij bedreigde zijn buurman.", plural: "", pastTense: "bedreigde", futureTense: "zal bedreigen", pastParticiple: "bedreigd", wordType: .verb, level: .b1, category: .crime),
                DutchWord(word: "moord", article: "de", definition: "murder", example: "Moord is het zwaarste misdrijf.", plural: "moorden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "verdachte", article: "de", definition: "suspect", example: "De verdachte werd gearresteerd.", plural: "verdachten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "arresteren", article: "", definition: "to arrest", example: "De politie arresteerde de dader.", plural: "", pastTense: "arresteerde", futureTense: "zal arresteren", pastParticiple: "gearresteerd", wordType: .verb, level: .b1, category: .crime),
                DutchWord(word: "onderzoek", article: "het", definition: "investigation", example: "Het onderzoek duurt nog voort.", plural: "onderzoeken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "slachtoffer", article: "het", definition: "victim", example: "Het slachtoffer deed aangifte.", plural: "slachtoffers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "aangifte", article: "de", definition: "report (to police)", example: "Zij deed aangifte van diefstal.", plural: "aangiftes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "gevangenis", article: "de", definition: "prison", example: "Hij zit in de gevangenis.", plural: "gevangenissen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "cel", article: "de", definition: "cell", example: "De gevangene zit in zijn cel.", plural: "cellen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "boete", article: "de", definition: "fine", example: "Hij kreeg een boete voor snelheidsovertredingen.", plural: "boetes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "straf", article: "de", definition: "punishment", example: "De straf was te licht.", plural: "straffen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "rechtbank", article: "de", definition: "court", example: "De zaak komt voor de rechtbank.", plural: "rechtbanken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "advocaat", article: "de", definition: "lawyer", example: "De advocaat verdedigt zijn cliënt.", plural: "advocaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "rechter", article: "de", definition: "judge", example: "De rechter spreekt het vonnis uit.", plural: "rechters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "vonnis", article: "het", definition: "verdict", example: "Het vonnis wordt morgen uitgesproken.", plural: "vonnissen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "schuldig", article: "", definition: "guilty", example: "Hij is schuldig aan de misdaad.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .crime),
                DutchWord(word: "onschuldig", article: "", definition: "innocent", example: "Zij werd onschuldig bevonden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .crime),
                DutchWord(word: "bewijs", article: "het", definition: "evidence", example: "Er is geen bewijs tegen hem.", plural: "bewijzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "getuige", article: "de", definition: "witness", example: "De getuige zag alles gebeuren.", plural: "getuigen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "alarm", article: "het", definition: "alarm", example: "Het alarm ging af.", plural: "alarmen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "beveiliging", article: "de", definition: "security", example: "De beveiliging is verscherpt.", plural: "beveiligingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "camera", article: "de", definition: "camera", example: "De beveiligingscamera filmde alles.", plural: "camera's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "slot", article: "het", definition: "lock", example: "Het slot van de deur is kapot.", plural: "sloten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "sleutel", article: "de", definition: "key", example: "Ik ben mijn sleutel kwijt.", plural: "sleutels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "brandweer", article: "de", definition: "fire department", example: "De brandweer kwam snel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "ambulance", article: "de", definition: "ambulance", example: "Er kwam een ambulance.", plural: "ambulances", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "noodgeval", article: "het", definition: "emergency", example: "In geval van nood bel 112.", plural: "noodgevallen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "hulp", article: "de", definition: "help", example: "Hij riep om hulp.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "redden", article: "", definition: "to save/rescue", example: "De brandweer redde de kat.", plural: "", pastTense: "redde", futureTense: "zal redden", pastParticiple: "gered", wordType: .verb, level: .b1, category: .crime),
                DutchWord(word: "gevaarlijk", article: "", definition: "dangerous", example: "Deze buurt is gevaarlijk 's nachts.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .crime),
                DutchWord(word: "voorzichtig", article: "", definition: "careful", example: "Wees voorzichtig op straat.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .crime),
                DutchWord(word: "beschermen", article: "", definition: "to protect", example: "De politie beschermt de burgers.", plural: "", pastTense: "beschermde", futureTense: "zal beschermen", pastParticiple: "beschermd", wordType: .verb, level: .b1, category: .crime),
                DutchWord(word: "preventie", article: "de", definition: "prevention", example: "Preventie is beter dan genezen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "wet", article: "de", definition: "law", example: "De wet moet gerespecteerd worden.", plural: "wetten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "regel", article: "de", definition: "rule", example: "Er zijn regels die gevolgd moeten worden.", plural: "regels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "overtreding", article: "de", definition: "violation", example: "Hij beging een verkeersovertreding.", plural: "overtredingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "controle", article: "de", definition: "control/check", example: "Er was een politiecontrole.", plural: "controles", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "identificatie", article: "de", definition: "identification", example: "Toon uw identificatie.", plural: "identificaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "legitimatie", article: "de", definition: "ID document", example: "Heeft u een legitimatie bij u?", plural: "legitimaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "fraude", article: "de", definition: "fraud", example: "Creditcardfraude komt veel voor.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime),
                DutchWord(word: "oplichting", article: "de", definition: "scam", example: "Hij werd slachtoffer van oplichting.", plural: "oplichtingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .crime)
            ],
            description: "Crime and safety vocabulary for security discussions"
        )
    }
    
    // MARK: - PACK 11: GEOGRAPHY & COUNTRIES (B1)
    
    static var geographyCountriesB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Geografie en Landen (B1)",
            level: .b1,
            category: .geography,
            words: [
                DutchWord(word: "geografie", article: "de", definition: "geography", example: "Geografie is een interessant vak.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "continent", article: "het", definition: "continent", example: "Europa is een continent.", plural: "continenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "land", article: "het", definition: "country", example: "Nederland is een klein land.", plural: "landen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "hoofdstad", article: "de", definition: "capital", example: "Amsterdam is de hoofdstad.", plural: "hoofdsteden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "stad", article: "de", definition: "city", example: "Rotterdam is een grote stad.", plural: "steden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "dorp", article: "het", definition: "village", example: "Hij woont in een klein dorp.", plural: "dorpen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "provincie", article: "de", definition: "province", example: "Noord-Holland is een provincie.", plural: "provincies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "grens", article: "de", definition: "border", example: "De grens met Duitsland is dichtbij.", plural: "grenzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "rivier", article: "de", definition: "river", example: "De Rijn is een grote rivier.", plural: "rivieren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "meer", article: "het", definition: "lake", example: "Het IJsselmeer is een groot meer.", plural: "meren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "zee", article: "de", definition: "sea", example: "De Noordzee grenst aan Nederland.", plural: "zeeën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "oceaan", article: "de", definition: "ocean", example: "De Atlantische Oceaan is groot.", plural: "oceanen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "berg", article: "de", definition: "mountain", example: "De Alpen zijn hoge bergen.", plural: "bergen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "heuvel", article: "de", definition: "hill", example: "Limburg heeft veel heuvels.", plural: "heuvels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "vlakte", article: "de", definition: "plain", example: "Nederland is grotendeels vlak.", plural: "vlaktes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "kust", article: "de", definition: "coast", example: "De Nederlandse kust is lang.", plural: "kusten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "strand", article: "het", definition: "beach", example: "Het strand van Scheveningen is populair.", plural: "stranden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "eiland", article: "het", definition: "island", example: "Texel is een Waddeneiland.", plural: "eilanden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "kaart", article: "de", definition: "map", example: "Ik kijk op de kaart.", plural: "kaarten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "kompas", article: "het", definition: "compass", example: "Een kompas wijst naar het noorden.", plural: "kompassen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "noord", article: "het", definition: "north", example: "Het noorden van Nederland is Friesland.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "zuid", article: "het", definition: "south", example: "Limburg ligt in het zuiden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "oost", article: "het", definition: "east", example: "Duitsland ligt ten oosten van Nederland.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "west", article: "het", definition: "west", example: "De zee ligt in het westen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "bevolking", article: "de", definition: "population", example: "Nederland heeft 17 miljoen inwoners.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "inwoner", article: "de", definition: "inhabitant", example: "Amsterdam heeft veel inwoners.", plural: "inwoners", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "cultuur", article: "de", definition: "culture", example: "Nederlandse cultuur is divers.", plural: "culturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "taal", article: "de", definition: "language", example: "Nederlands is de officiële taal.", plural: "talen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "klimaat", article: "het", definition: "climate", example: "Nederland heeft een gematigd klimaat.", plural: "klimaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography),
                DutchWord(word: "landschap", article: "het", definition: "landscape", example: "Het Nederlandse landschap is vlak.", plural: "landschappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .geography)
            ],
            description: "Geography and countries vocabulary for regional discussions"
        )
    }
    
    // MARK: - PACK 12: HISTORY (B1)
    
    static var historyB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Geschiedenis (B1)",
            level: .b1,
            category: .history,
            words: [
                DutchWord(word: "geschiedenis", article: "de", definition: "history", example: "Geschiedenis is belangrijk om te leren.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "verleden", article: "het", definition: "past", example: "Het verleden leert ons veel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "eeuw", article: "de", definition: "century", example: "De 20e eeuw was turbulent.", plural: "eeuwen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "periode", article: "de", definition: "period", example: "De Gouden Eeuw was een rijke periode.", plural: "periodes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "oorlog", article: "de", definition: "war", example: "De Tweede Wereldoorlog duurde zes jaar.", plural: "oorlogen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "vrede", article: "de", definition: "peace", example: "Na de oorlog kwam er vrede.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "koning", article: "de", definition: "king", example: "Willem-Alexander is de koning.", plural: "koningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "koningin", article: "de", definition: "queen", example: "Koningin Máxima komt uit Argentinië.", plural: "koninginnen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "rijk", article: "het", definition: "empire", example: "Het Romeinse Rijk was machtig.", plural: "rijken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "revolutie", article: "de", definition: "revolution", example: "De Franse Revolutie veranderde alles.", plural: "revoluties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "ontdekking", article: "de", definition: "discovery", example: "De ontdekking van Amerika was belangrijk.", plural: "ontdekkingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "uitvinding", article: "de", definition: "invention", example: "De uitvinding van de computer was revolutionair.", plural: "uitvindingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "monument", article: "het", definition: "monument", example: "Het Nationaal Monument staat op de Dam.", plural: "monumenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "museum", article: "het", definition: "museum", example: "Het Rijksmuseum is beroemd.", plural: "musea", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "archeologie", article: "de", definition: "archaeology", example: "Archeologie bestudeert het verleden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "cultuur", article: "de", definition: "culture", example: "Elke cultuur heeft zijn eigen geschiedenis.", plural: "culturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "traditie", article: "de", definition: "tradition", example: "Sinterklaas is een Nederlandse traditie.", plural: "tradities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "erfgoed", article: "het", definition: "heritage", example: "Cultureel erfgoed moet beschermd worden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "datum", article: "de", definition: "date", example: "Welke datum is belangrijk in de geschiedenis?", plural: "data", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "jaartal", article: "het", definition: "year", example: "1945 is een belangrijk jaartal.", plural: "jaartallen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "document", article: "het", definition: "document", example: "Historische documenten zijn waardevol.", plural: "documenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "bron", article: "de", definition: "source", example: "Primaire bronnen zijn belangrijk voor historici.", plural: "bronnen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "onderzoek", article: "het", definition: "research", example: "Historisch onderzoek vereist geduld.", plural: "onderzoeken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "historicus", article: "de", definition: "historian", example: "De historicus schreef een boek.", plural: "historici", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history),
                DutchWord(word: "chronologie", article: "de", definition: "chronology", example: "De chronologie van gebeurtenissen is belangrijk.", plural: "chronologieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .history)
            ],
            description: "History vocabulary for historical discussions"
        )
    }
    
    // MARK: - PACK 13: AGRICULTURE (B1)
    
    static var agricultureB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Landbouw en Voedselproductie (B1)",
            level: .b1,
            category: .agriculture,
            words: [
                DutchWord(word: "landbouw", article: "de", definition: "agriculture", example: "Landbouw is belangrijk voor voedsel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "boer", article: "de", definition: "farmer", example: "De boer werkt op het land.", plural: "boeren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "boerderij", article: "de", definition: "farm", example: "De boerderij heeft veel dieren.", plural: "boerderijen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "akker", article: "de", definition: "field", example: "De akker is klaar voor de oogst.", plural: "akkers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "gewas", article: "het", definition: "crop", example: "Tarwe is een belangrijk gewas.", plural: "gewassen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "oogst", article: "de", definition: "harvest", example: "De oogst was dit jaar goed.", plural: "oogsten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "zaaien", article: "", definition: "to sow", example: "In het voorjaar zaaien we de zaden.", plural: "", pastTense: "zaaide", futureTense: "zal zaaien", pastParticiple: "gezaaid", wordType: .verb, level: .b1, category: .agriculture),
                DutchWord(word: "planten", article: "", definition: "to plant", example: "We planten aardappelen in april.", plural: "", pastTense: "plantte", futureTense: "zal planten", pastParticiple: "geplant", wordType: .verb, level: .b1, category: .agriculture),
                DutchWord(word: "groeien", article: "", definition: "to grow", example: "De planten groeien snel.", plural: "", pastTense: "groeide", futureTense: "zal groeien", pastParticiple: "gegroeid", wordType: .verb, level: .b1, category: .agriculture),
                DutchWord(word: "water geven", article: "", definition: "to water", example: "Elke dag water geven aan de planten.", plural: "", pastTense: "gaf water", futureTense: "zal water geven", pastParticiple: "water gegeven", wordType: .verb, level: .b1, category: .agriculture),
                DutchWord(word: "mest", article: "de", definition: "fertilizer", example: "Mest helpt planten groeien.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "tractor", article: "de", definition: "tractor", example: "De boer rijdt op zijn tractor.", plural: "tractors", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "vee", article: "het", definition: "livestock", example: "Het vee staat in de wei.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "koe", article: "de", definition: "cow", example: "Koeien geven melk.", plural: "koeien", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "varken", article: "het", definition: "pig", example: "Varkens worden gehouden voor vlees.", plural: "varkens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "kip", article: "de", definition: "chicken", example: "Kippen leggen eieren.", plural: "kippen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "schaap", article: "het", definition: "sheep", example: "Schapen geven wol.", plural: "schapen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "melk", article: "de", definition: "milk", example: "Verse melk is gezond.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "ei", article: "het", definition: "egg", example: "Eieren zijn eiwitrijk.", plural: "eieren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "vlees", article: "het", definition: "meat", example: "Vlees is een bron van eiwit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "grond", article: "de", definition: "soil", example: "Vruchtbare grond is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "irrigatie", article: "de", definition: "irrigation", example: "Irrigatie helpt bij droogte.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "biologisch", article: "", definition: "organic", example: "Biologische landbouw is duurzaam.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .agriculture),
                DutchWord(word: "pesticiden", article: "de", definition: "pesticides", example: "Pesticiden bestrijden ongedierte.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .agriculture),
                DutchWord(word: "duurzaam", article: "", definition: "sustainable", example: "Duurzame landbouw beschermt het milieu.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .agriculture)
            ],
            description: "Agriculture and food production vocabulary"
        )
    }
    
    // MARK: - PACK 14: CONSTRUCTION & ARCHITECTURE (B1)
    
    static var constructionArchitectureB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Bouw en Architectuur (B1)",
            level: .b1,
            category: .construction,
            words: [
                DutchWord(word: "bouw", article: "de", definition: "construction", example: "De bouw van het huis duurt lang.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "architectuur", article: "de", definition: "architecture", example: "Nederlandse architectuur is uniek.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "architect", article: "de", definition: "architect", example: "De architect ontwierp het gebouw.", plural: "architecten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "gebouw", article: "het", definition: "building", example: "Het gebouw is erg hoog.", plural: "gebouwen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "bouwen", article: "", definition: "to build", example: "Ze bouwen een nieuw huis.", plural: "", pastTense: "bouwde", futureTense: "zal bouwen", pastParticiple: "gebouwd", wordType: .verb, level: .b1, category: .construction),
                DutchWord(word: "ontwerp", article: "het", definition: "design", example: "Het ontwerp is modern.", plural: "ontwerpen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "fundament", article: "het", definition: "foundation", example: "Het fundament moet sterk zijn.", plural: "fundamenten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "muur", article: "de", definition: "wall", example: "De muur is twee meter hoog.", plural: "muren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "dak", article: "het", definition: "roof", example: "Het dak moet gerepareerd worden.", plural: "daken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "vloer", article: "de", definition: "floor", example: "De vloer is van hout gemaakt.", plural: "vloeren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "raam", article: "het", definition: "window", example: "Het raam geeft veel licht.", plural: "ramen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "deur", article: "de", definition: "door", example: "De deur is open.", plural: "deuren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "trap", article: "de", definition: "stairs", example: "De trap naar boven is steil.", plural: "trappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "lift", article: "de", definition: "elevator", example: "De lift is defect.", plural: "liften", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "beton", article: "het", definition: "concrete", example: "Beton is een sterk materiaal.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "steen", article: "de", definition: "stone/brick", example: "Het huis is van steen gebouwd.", plural: "stenen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "hout", article: "het", definition: "wood", example: "Hout is een natuurlijk materiaal.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "staal", article: "het", definition: "steel", example: "Staal wordt gebruikt voor de constructie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "glas", article: "het", definition: "glass", example: "Moderne gebouwen gebruiken veel glas.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "verf", article: "de", definition: "paint", example: "De muren hebben nieuwe verf nodig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "gereedschap", article: "het", definition: "tools", example: "Gereedschap is nodig voor de klus.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "hamer", article: "de", definition: "hammer", example: "Hij slaat met de hamer op de spijker.", plural: "hamers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "zaag", article: "de", definition: "saw", example: "Met de zaag snijdt hij het hout.", plural: "zagen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "schroef", article: "de", definition: "screw", example: "De schroef houdt de plank vast.", plural: "schroeven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction),
                DutchWord(word: "renovatie", article: "de", definition: "renovation", example: "De renovatie van het huis is klaar.", plural: "renovaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .construction)
            ],
            description: "Construction and architecture vocabulary"
        )
    }
    
    // MARK: - PACK 15: AUTOMOTIVE & VEHICLES (B1)
    
    static var automotiveB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Auto's en Voertuigen (B1)",
            level: .b1,
            category: .automotive,
            words: [
                DutchWord(word: "voertuig", article: "het", definition: "vehicle", example: "Elk voertuig moet verzekerd zijn.", plural: "voertuigen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "motor", article: "de", definition: "engine/motorcycle", example: "De motor van de auto is kapot.", plural: "motoren", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "transmissie", article: "de", definition: "transmission", example: "De transmissie schakelt automatisch.", plural: "transmissies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "versnelling", article: "de", definition: "gear", example: "Schakel naar een hogere versnelling.", plural: "versnellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "rem", article: "de", definition: "brake", example: "De remmen werken goed.", plural: "remmen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "stuur", article: "het", definition: "steering wheel", example: "Het stuur is zwaar.", plural: "sturen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "band", article: "de", definition: "tire", example: "De band is lek.", plural: "banden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "velg", article: "de", definition: "rim", example: "De velgen zijn van aluminium.", plural: "velgen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "accu", article: "de", definition: "battery", example: "De accu is leeg.", plural: "accu's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "koplamp", article: "de", definition: "headlight", example: "De koplamp is defect.", plural: "koplampen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "richtingaanwijzer", article: "de", definition: "turn signal", example: "Gebruik de richtingaanwijzer.", plural: "richtingaanwijzers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "dashboard", article: "het", definition: "dashboard", example: "Het dashboard toont de snelheid.", plural: "dashboards", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "kilometerstand", article: "de", definition: "mileage", example: "De kilometerstand is hoog.", plural: "kilometerstanden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "brandstof", article: "de", definition: "fuel", example: "Brandstof is duur geworden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "tanken", article: "", definition: "to refuel", example: "We moeten tanken voordat we vertrekken.", plural: "", pastTense: "tankte", futureTense: "zal tanken", pastParticiple: "getankt", wordType: .verb, level: .b1, category: .automotive),
                DutchWord(word: "garage", article: "de", definition: "garage", example: "De auto staat in de garage.", plural: "garages", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "monteur", article: "de", definition: "mechanic", example: "De monteur repareert de auto.", plural: "monteurs", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "onderhoud", article: "het", definition: "maintenance", example: "Regelmatig onderhoud is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "reparatie", article: "de", definition: "repair", example: "De reparatie kost veel geld.", plural: "reparaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "verzekering", article: "de", definition: "insurance", example: "Autoverzekering is verplicht.", plural: "verzekeringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "rijbewijs", article: "het", definition: "driver's license", example: "Je hebt een rijbewijs nodig.", plural: "rijbewijzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "kenteken", article: "het", definition: "license plate", example: "Het kenteken is geel.", plural: "kentekens", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "verkeer", article: "het", definition: "traffic", example: "Het verkeer is druk vandaag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "file", article: "de", definition: "traffic jam", example: "We staan in de file.", plural: "files", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive),
                DutchWord(word: "navigatie", article: "de", definition: "navigation", example: "De navigatie toont de route.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .automotive)
            ],
            description: "Automotive and vehicle vocabulary for transportation discussions"
        )
    }
    
    // MARK: - PACK 16: TELECOMMUNICATIONS (B1)
    
    static var telecommunicationsB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Telecommunicatie (B1)",
            level: .b1,
            category: .telecommunications,
            words: [
                DutchWord(word: "telecommunicatie", article: "de", definition: "telecommunications", example: "Telecommunicatie verbindt de wereld.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "mobiele telefoon", article: "de", definition: "mobile phone", example: "Mijn mobiele telefoon is nieuw.", plural: "mobiele telefoons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "smartphone", article: "de", definition: "smartphone", example: "Een smartphone heeft veel functies.", plural: "smartphones", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "netwerk", article: "het", definition: "network", example: "Het netwerk is overbelast.", plural: "netwerken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "signaal", article: "het", definition: "signal", example: "Het signaal is zwak hier.", plural: "signalen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "bereik", article: "het", definition: "coverage/range", example: "Het bereik is goed in de stad.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "provider", article: "de", definition: "provider", example: "Welke provider gebruik je?", plural: "providers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "abonnement", article: "het", definition: "subscription", example: "Mijn abonnement is duur.", plural: "abonnementen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "prepaid", article: "", definition: "prepaid", example: "Ik heb een prepaid telefoon.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .telecommunications),
                DutchWord(word: "beltegoed", article: "het", definition: "calling credit", example: "Mijn beltegoed is op.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "dataverbruik", article: "het", definition: "data usage", example: "Mijn dataverbruik is hoog.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "roaming", article: "het", definition: "roaming", example: "Roaming in het buitenland kost extra.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "sms", article: "de", definition: "text message", example: "Stuur me een sms.", plural: "sms'jes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "voicemail", article: "de", definition: "voicemail", example: "Je hebt een voicemail ontvangen.", plural: "voicemails", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "videobellen", article: "", definition: "to video call", example: "We kunnen videobellen via internet.", plural: "", pastTense: "videobelde", futureTense: "zal videobellen", pastParticiple: "gebeld", wordType: .verb, level: .b1, category: .telecommunications),
                DutchWord(word: "internetverbinding", article: "de", definition: "internet connection", example: "De internetverbinding is snel.", plural: "internetverbindingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "wifi", article: "de", definition: "wifi", example: "De wifi werkt niet.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "hotspot", article: "de", definition: "hotspot", example: "Er is een wifi hotspot in het café.", plural: "hotspots", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "glasvezel", article: "de", definition: "fiber optic", example: "Glasvezel geeft snelle internet.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "modem", article: "de", definition: "modem", example: "De modem staat in de meterkast.", plural: "modems", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "router", article: "de", definition: "router", example: "De router verspreidt het wifi signaal.", plural: "routers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "app", article: "de", definition: "app", example: "Download de app op je telefoon.", plural: "apps", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "update", article: "de", definition: "update", example: "Er is een nieuwe update beschikbaar.", plural: "updates", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications),
                DutchWord(word: "installeren", article: "", definition: "to install", example: "Installeer de nieuwe software.", plural: "", pastTense: "installeerde", futureTense: "zal installeren", pastParticiple: "geïnstalleerd", wordType: .verb, level: .b1, category: .telecommunications),
                DutchWord(word: "verbinding", article: "de", definition: "connection", example: "De verbinding is verbroken.", plural: "verbindingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .telecommunications)
            ],
            description: "Telecommunications vocabulary for modern communication"
        )
    }
    
    // MARK: - PACK 17: HOSPITALITY & TOURISM (B1)
    
    static var hospitalityB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Horeca en Toerisme (B1)",
            level: .b1,
            category: .hospitality,
            words: [
                DutchWord(word: "horeca", article: "de", definition: "hospitality industry", example: "Horeca is een belangrijke sector.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "gastvrijheid", article: "de", definition: "hospitality", example: "Nederlandse gastvrijheid is bekend.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "hotel", article: "het", definition: "hotel", example: "We verblijven in een luxe hotel.", plural: "hotels", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "receptie", article: "de", definition: "reception", example: "Meld je aan bij de receptie.", plural: "recepties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "reservering", article: "de", definition: "reservation", example: "Ik heb een reservering gemaakt.", plural: "reserveringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "inchecken", article: "", definition: "to check in", example: "We kunnen om 15:00 inchecken.", plural: "", pastTense: "checkte in", futureTense: "zal inchecken", pastParticiple: "ingecheckt", wordType: .verb, level: .b1, category: .hospitality),
                DutchWord(word: "uitchecken", article: "", definition: "to check out", example: "Uitchecken is voor 11:00.", plural: "", pastTense: "checkte uit", futureTense: "zal uitchecken", pastParticiple: "uitgecheckt", wordType: .verb, level: .b1, category: .hospitality),
                DutchWord(word: "kamer", article: "de", definition: "room", example: "De kamer heeft een mooi uitzicht.", plural: "kamers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "suite", article: "de", definition: "suite", example: "De suite is erg ruim.", plural: "suites", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "ontbijt", article: "het", definition: "breakfast", example: "Het ontbijt is inbegrepen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "roomservice", article: "de", definition: "room service", example: "Roomservice is 24 uur beschikbaar.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "conciërge", article: "de", definition: "concierge", example: "De conciërge helpt met reserveringen.", plural: "conciërges", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "portier", article: "de", definition: "doorman", example: "De portier opent de deur.", plural: "portiers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "kamermeisje", article: "het", definition: "housekeeper", example: "Het kamermeisje maakt de kamer schoon.", plural: "kamermeisjes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "restaurant", article: "het", definition: "restaurant", example: "Het restaurant serveert lokale gerechten.", plural: "restaurants", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "ober", article: "de", definition: "waiter", example: "De ober neemt de bestelling op.", plural: "obers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "serveerster", article: "de", definition: "waitress", example: "De serveerster is erg vriendelijk.", plural: "serveersters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "menukaart", article: "de", definition: "menu", example: "Mag ik de menukaart zien?", plural: "menukaarten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "bestelling", article: "de", definition: "order", example: "Wat is uw bestelling?", plural: "bestellingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "rekening", article: "de", definition: "bill", example: "Mag ik de rekening?", plural: "rekeningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "fooi", article: "de", definition: "tip", example: "Een fooi is niet verplicht.", plural: "fooien", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "toerist", article: "de", definition: "tourist", example: "Amsterdam trekt veel toeristen.", plural: "toeristen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "toerisme", article: "het", definition: "tourism", example: "Toerisme is belangrijk voor de economie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "gids", article: "de", definition: "guide", example: "De gids vertelt over de geschiedenis.", plural: "gidsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality),
                DutchWord(word: "excursie", article: "de", definition: "excursion", example: "We maken een excursie naar Volendam.", plural: "excursies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .hospitality)
            ],
            description: "Hospitality and tourism vocabulary for service industry discussions"
        )
    }
    
    // MARK: - PACK 18: BANKING & FINANCE (B1)
    
    static var bankingFinanceB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Bankwezen en Financiën (B1)",
            level: .b1,
            category: .finance,
            words: [
                DutchWord(word: "bank", article: "de", definition: "bank", example: "Ik ga naar de bank.", plural: "banken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "rekening", article: "de", definition: "account", example: "Mijn bankrekening is leeg.", plural: "rekeningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "spaarrekening", article: "de", definition: "savings account", example: "Ik heb geld op mijn spaarrekening.", plural: "spaarrekeningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "betaalrekening", article: "de", definition: "checking account", example: "De betaalrekening is voor dagelijks gebruik.", plural: "betaalrekeningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "pinpas", article: "de", definition: "debit card", example: "Ik betaal met mijn pinpas.", plural: "pinpassen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "creditcard", article: "de", definition: "credit card", example: "Accepteert u creditcards?", plural: "creditcards", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "pincode", article: "de", definition: "PIN code", example: "Voer uw pincode in.", plural: "pincodes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "geldautomaat", article: "de", definition: "ATM", example: "Er is een geldautomaat bij de bank.", plural: "geldautomaten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "opnemen", article: "", definition: "to withdraw", example: "Ik neem geld op.", plural: "", pastTense: "nam op", futureTense: "zal opnemen", pastParticiple: "opgenomen", wordType: .verb, level: .b1, category: .finance),
                DutchWord(word: "storten", article: "", definition: "to deposit", example: "Ik stort geld op mijn rekening.", plural: "", pastTense: "stortte", futureTense: "zal storten", pastParticiple: "gestort", wordType: .verb, level: .b1, category: .finance),
                DutchWord(word: "overboeken", article: "", definition: "to transfer", example: "Ik boek geld over naar mijn spaarrekening.", plural: "", pastTense: "boekte over", futureTense: "zal overboeken", pastParticiple: "overboekt", wordType: .verb, level: .b1, category: .finance),
                DutchWord(word: "saldo", article: "het", definition: "balance", example: "Mijn saldo is laag.", plural: "saldo's", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "rente", article: "de", definition: "interest", example: "De rente op sparen is laag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "lening", article: "de", definition: "loan", example: "Ik heb een lening afgesloten.", plural: "leningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "hypotheek", article: "de", definition: "mortgage", example: "We hebben een hypotheek voor ons huis.", plural: "hypotheken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "verzekering", article: "de", definition: "insurance", example: "Zorgverzekering is verplicht.", plural: "verzekeringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "premie", article: "de", definition: "premium", example: "De premie is dit jaar gestegen.", plural: "premies", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "investeren", article: "", definition: "to invest", example: "Hij investeert in aandelen.", plural: "", pastTense: "investeerde", futureTense: "zal investeren", pastParticiple: "geïnvesteerd", wordType: .verb, level: .b1, category: .finance),
                DutchWord(word: "aandeel", article: "het", definition: "share/stock", example: "Aandelen kunnen in waarde stijgen.", plural: "aandelen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "obligatie", article: "de", definition: "bond", example: "Obligaties zijn veiliger dan aandelen.", plural: "obligaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "beurs", article: "de", definition: "stock exchange", example: "De beurs gaat vandaag omhoog.", plural: "beurzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "budget", article: "het", definition: "budget", example: "We moeten ons budget bijhouden.", plural: "budgetten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "uitgaven", article: "de", definition: "expenses", example: "Mijn uitgaven zijn te hoog.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "inkomsten", article: "de", definition: "income", example: "Mijn inkomsten zijn stabiel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance),
                DutchWord(word: "belasting", article: "de", definition: "tax", example: "Belasting betalen is verplicht.", plural: "belastingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .finance)
            ],
            description: "Banking and finance vocabulary for financial discussions"
        )
    }
    
    // MARK: - PACK 19: REAL ESTATE (B1)
    
    static var realEstateB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Vastgoed (B1)",
            level: .b1,
            category: .realEstate,
            words: [
                DutchWord(word: "vastgoed", article: "het", definition: "real estate", example: "Vastgoed is een goede investering.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "makelaar", article: "de", definition: "real estate agent", example: "De makelaar toont het huis.", plural: "makelaars", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "woning", article: "de", definition: "dwelling", example: "Deze woning is te koop.", plural: "woningen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "eigendom", article: "het", definition: "property", example: "Dit is privé-eigendom.", plural: "eigendommen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "kopen", article: "", definition: "to buy", example: "We willen een huis kopen.", plural: "", pastTense: "kocht", futureTense: "zal kopen", pastParticiple: "gekocht", wordType: .verb, level: .b1, category: .realEstate),
                DutchWord(word: "verkopen", article: "", definition: "to sell", example: "Ze verkopen hun huis.", plural: "", pastTense: "verkocht", futureTense: "zal verkopen", pastParticiple: "verkocht", wordType: .verb, level: .b1, category: .realEstate),
                DutchWord(word: "huren", article: "", definition: "to rent", example: "We huren een appartement.", plural: "", pastTense: "huurde", futureTense: "zal huren", pastParticiple: "gehuurd", wordType: .verb, level: .b1, category: .realEstate),
                DutchWord(word: "verhuren", article: "", definition: "to rent out", example: "Hij verhuurt zijn huis.", plural: "", pastTense: "verhuurde", futureTense: "zal verhuren", pastParticiple: "verhuurd", wordType: .verb, level: .b1, category: .realEstate),
                DutchWord(word: "huur", article: "de", definition: "rent", example: "De huur is duur in Amsterdam.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "huurder", article: "de", definition: "tenant", example: "De huurder betaalt elke maand.", plural: "huurders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "verhuurder", article: "de", definition: "landlord", example: "De verhuurder repareert de verwarmung.", plural: "verhuurders", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "huurcontract", article: "het", definition: "lease agreement", example: "Het huurcontract is voor een jaar.", plural: "huurcontracten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "borg", article: "de", definition: "deposit", example: "Je moet een borg betalen.", plural: "borgen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "hypotheek", article: "de", definition: "mortgage", example: "We hebben een hypotheek nodig.", plural: "hypotheken", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "koopprijs", article: "de", definition: "purchase price", example: "De koopprijs is onderhandelbaar.", plural: "koopprijzen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "waarde", article: "de", definition: "value", example: "De waarde van het huis is gestegen.", plural: "waarden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "taxatie", article: "de", definition: "appraisal", example: "Een taxatie is nodig voor de hypotheek.", plural: "taxaties", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "bezichtiging", article: "de", definition: "viewing", example: "De bezichtiging is morgen om 14:00.", plural: "bezichtigingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "oppervlakte", article: "de", definition: "surface area", example: "De oppervlakte is 100 vierkante meter.", plural: "oppervlaktes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "vierkante meter", article: "de", definition: "square meter", example: "Het huis is 120 vierkante meter.", plural: "vierkante meters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "tuin", article: "de", definition: "garden", example: "Het huis heeft een grote tuin.", plural: "tuinen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "balkon", article: "het", definition: "balcony", example: "Het balkon kijkt uit op het park.", plural: "balkons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "garage", article: "de", definition: "garage", example: "Er is een garage bij het huis.", plural: "garages", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "parkeerplaats", article: "de", definition: "parking space", example: "Elke woning heeft een parkeerplaats.", plural: "parkeerplaatsen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate),
                DutchWord(word: "buurt", article: "de", definition: "neighborhood", example: "Het is een rustige buurt.", plural: "buurten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .realEstate)
            ],
            description: "Real estate vocabulary for property discussions"
        )
    }
    
    // MARK: - PACK 20: SPORTS & RECREATION (B1)
    
    static var sportsRecreationB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Sport en Recreatie (B1)",
            level: .b1,
            category: .sports,
            words: [
                DutchWord(word: "recreatie", article: "de", definition: "recreation", example: "Recreatie is belangrijk voor de gezondheid.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "vrije tijd", article: "de", definition: "free time", example: "In mijn vrije tijd sport ik graag.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "sportschool", article: "de", definition: "gym", example: "Ik ga drie keer per week naar de sportschool.", plural: "sportscholen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "fitness", article: "de", definition: "fitness", example: "Fitness is goed voor je conditie.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "trainen", article: "", definition: "to train", example: "Ik train elke dag een uur.", plural: "", pastTense: "trainde", futureTense: "zal trainen", pastParticiple: "getraind", wordType: .verb, level: .b1, category: .sports),
                DutchWord(word: "training", article: "de", definition: "training", example: "De training begint om 19:00.", plural: "trainingen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "coach", article: "de", definition: "coach", example: "De coach geeft goede adviezen.", plural: "coaches", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "team", article: "het", definition: "team", example: "Ons team speelt goed samen.", plural: "teams", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "wedstrijd", article: "de", definition: "match/competition", example: "De wedstrijd is spannend.", plural: "wedstrijden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "competitie", article: "de", definition: "league", example: "We spelen in de hoogste competitie.", plural: "competities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "kampioenschap", article: "het", definition: "championship", example: "Het kampioenschap is volgende maand.", plural: "kampioenschappen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "kampioen", article: "de", definition: "champion", example: "Hij is de nieuwe kampioen.", plural: "kampioenen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "winnen", article: "", definition: "to win", example: "We gaan de wedstrijd winnen.", plural: "", pastTense: "won", futureTense: "zal winnen", pastParticiple: "gewonnen", wordType: .verb, level: .b1, category: .sports),
                DutchWord(word: "verliezen", article: "", definition: "to lose", example: "We mogen niet verliezen.", plural: "", pastTense: "verloor", futureTense: "zal verliezen", pastParticiple: "verloren", wordType: .verb, level: .b1, category: .sports),
                DutchWord(word: "gelijkspel", article: "het", definition: "draw/tie", example: "De wedstrijd eindigde in een gelijkspel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "scheidsrechter", article: "de", definition: "referee", example: "De scheidsrechter fluit voor een overtreding.", plural: "scheidsrechters", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "toeschouwer", article: "de", definition: "spectator", example: "Er waren veel toeschouwers.", plural: "toeschouwers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "stadion", article: "het", definition: "stadium", example: "Het stadion zit vol.", plural: "stadions", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "zwembad", article: "het", definition: "swimming pool", example: "Het zwembad is open van 6 tot 22 uur.", plural: "zwembaden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "zwemmen", article: "", definition: "to swim", example: "Ik zwem graag in de zomer.", plural: "", pastTense: "zwom", futureTense: "zal zwemmen", pastParticiple: "gezwommen", wordType: .verb, level: .b1, category: .sports),
                DutchWord(word: "hardlopen", article: "", definition: "to run", example: "Hardlopen is goed voor je hart.", plural: "", pastTense: "liep hard", futureTense: "zal hardlopen", pastParticiple: "hardgelopen", wordType: .verb, level: .b1, category: .sports),
                DutchWord(word: "marathon", article: "de", definition: "marathon", example: "De marathon van Amsterdam is beroemd.", plural: "marathons", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "wielrennen", article: "", definition: "cycling", example: "Wielrennen is populair in Nederland.", plural: "", pastTense: "reed", futureTense: "zal wielrennen", pastParticiple: "gewielrend", wordType: .verb, level: .b1, category: .sports),
                DutchWord(word: "yoga", article: "de", definition: "yoga", example: "Yoga helpt bij ontspanning.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports),
                DutchWord(word: "ontspanning", article: "de", definition: "relaxation", example: "Ontspanning is belangrijk na het werk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .sports)
            ],
            description: "Sports and recreation vocabulary for leisure activities"
        )
    }
    
    // MARK: - PACK 21: DAILY LIFE & MODERN SOCIETY (B1) - THE 1000+ WORD MILESTONE PACK!
    
    static var dailyLifeModernSocietyB1: DutchVocabularyPack {
        return DutchVocabularyPack(
            name: "Dagelijks Leven en Moderne Samenleving (B1)",
            level: .b1,
            category: .politics,
            words: [
                DutchWord(word: "digitalisering", article: "de", definition: "digitalization", example: "Digitalisering verandert de samenleving.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "artificiële intelligentie", article: "de", definition: "artificial intelligence", example: "Artificiële intelligentie wordt steeds belangrijker.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "algoritme", article: "het", definition: "algorithm", example: "Het algoritme bepaalt wat je ziet.", plural: "algoritmes", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "cybersecurity", article: "de", definition: "cybersecurity", example: "Cybersecurity is cruciaal voor bedrijven.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "privacy", article: "de", definition: "privacy", example: "Privacy online is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "gegevens", article: "de", definition: "data", example: "Bedrijven verzamelen veel gegevens.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "cloudcomputing", article: "het", definition: "cloud computing", example: "Cloudcomputing maakt opslag eenvoudig.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "streaming", article: "het", definition: "streaming", example: "Streaming van films is populair.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "podcast", article: "de", definition: "podcast", example: "Ik luister graag naar podcasts.", plural: "podcasts", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "influencer", article: "de", definition: "influencer", example: "Influencers hebben veel volgers.", plural: "influencers", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "diversiteit", article: "de", definition: "diversity", example: "Diversiteit verrijkt de samenleving.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "inclusie", article: "de", definition: "inclusion", example: "Inclusie is belangrijk op de werkvloer.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "discriminatie", article: "de", definition: "discrimination", example: "Discriminatie is bij wet verboden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "gelijkheid", article: "de", definition: "equality", example: "Gelijkheid voor iedereen is een recht.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "mensenrechten", article: "de", definition: "human rights", example: "Mensenrechten zijn universeel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vluchtelingen", article: "de", definition: "refugees", example: "Nederland helpt vluchtelingen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "integratie", article: "de", definition: "integration", example: "Integratie is een wederzijds proces.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "multicultureel", article: "", definition: "multicultural", example: "Nederland is een multiculturele samenleving.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .adjective, level: .b1, category: .politics),
                DutchWord(word: "generatiekloof", article: "de", definition: "generation gap", example: "De generatiekloof wordt groter.", plural: "generatiekloven", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "vergrijzing", article: "de", definition: "aging population", example: "Vergrijzing is een uitdaging.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "work-life balance", article: "de", definition: "work-life balance", example: "Een goede work-life balance is essentieel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "thuiswerken", article: "", definition: "working from home", example: "Thuiswerken is nu normaal.", plural: "", pastTense: "werkte thuis", futureTense: "zal thuiswerken", pastParticiple: "thuisgewerkt", wordType: .verb, level: .b1, category: .politics),
                DutchWord(word: "flexwerken", article: "", definition: "flexible working", example: "Flexwerken geeft meer vrijheid.", plural: "", pastTense: "werkte flex", futureTense: "zal flexwerken", pastParticiple: "geflexwerkt", wordType: .verb, level: .b1, category: .politics),
                DutchWord(word: "burnout", article: "de", definition: "burnout", example: "Burnout komt steeds vaker voor.", plural: "burnouts", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "stress", article: "de", definition: "stress", example: "Te veel stress is ongezond.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "mindfulness", article: "de", definition: "mindfulness", example: "Mindfulness helpt tegen stress.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "welzijn", article: "het", definition: "wellbeing", example: "Het welzijn van werknemers is belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "zelfzorg", article: "de", definition: "self-care", example: "Zelfzorg is geen luxe maar noodzaak.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "levenskwaliteit", article: "de", definition: "quality of life", example: "Nederland heeft een hoge levenskwaliteit.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "levensstijl", article: "de", definition: "lifestyle", example: "Een gezonde levensstijl is belangrijk.", plural: "levensstijlen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "consumentisme", article: "het", definition: "consumerism", example: "Consumentisme heeft gevolgen voor het milieu.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "koopkracht", article: "de", definition: "purchasing power", example: "De koopkracht is afgenomen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "inflatie", article: "de", definition: "inflation", example: "Inflatie maakt alles duurder.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "economische crisis", article: "de", definition: "economic crisis", example: "De economische crisis raakt iedereen.", plural: "economische crises", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "werkloosheid", article: "de", definition: "unemployment", example: "Werkloosheid is een groot probleem.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "armoede", article: "de", definition: "poverty", example: "Armoede bestaat ook in rijke landen.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "ongelijkheid", article: "de", definition: "inequality", example: "Ongelijkheid neemt toe.", plural: "ongelijkheden", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "welvaart", article: "de", definition: "prosperity", example: "Welvaart moet eerlijk verdeeld worden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "sociaal vangnet", article: "het", definition: "social safety net", example: "Het sociaal vangnet helpt mensen in nood.", plural: "sociale vangnetten", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "uitkering", article: "de", definition: "benefit/allowance", example: "Hij krijgt een uitkering van de gemeente.", plural: "uitkeringen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "gezondheidsapp", article: "de", definition: "health app", example: "Gezondheidsapps helpen bij fitness.", plural: "gezondheidsapps", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "wearable", article: "de", definition: "wearable device", example: "Wearables meten je hartslag.", plural: "wearables", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "telemedicine", article: "de", definition: "telemedicine", example: "Telemedicine maakt zorg toegankelijker.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "preventieve zorg", article: "de", definition: "preventive care", example: "Preventieve zorg voorkomt ziekte.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "mentale gezondheid", article: "de", definition: "mental health", example: "Mentale gezondheid is net zo belangrijk.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "therapie", article: "de", definition: "therapy", example: "Therapie kan helpen bij problemen.", plural: "therapieën", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "meditatie", article: "de", definition: "meditation", example: "Meditatie kalmeert de geest.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "voedingssupplement", article: "het", definition: "dietary supplement", example: "Voedingssupplementen zijn populair.", plural: "voedingssupplementen", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "superfoods", article: "de", definition: "superfoods", example: "Superfoods zijn erg gezond.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "detox", article: "de", definition: "detox", example: "Een detox reinigt je lichaam.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "urbanisatie", article: "de", definition: "urbanization", example: "Urbanisatie zorgt voor drukke steden.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "smart city", article: "de", definition: "smart city", example: "Amsterdam wordt een smart city.", plural: "smart cities", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics),
                DutchWord(word: "infrastructuur", article: "de", definition: "infrastructure", example: "Goede infrastructuur is essentieel.", plural: "", pastTense: "", futureTense: "", pastParticiple: "", wordType: .noun, level: .b1, category: .politics)
            ],
            description: "Comprehensive daily life and modern society vocabulary covering technology, social issues, work-life balance, economy, health trends, and urban living - the ultimate B1 vocabulary collection that pushes us over 1000 words!"
        )
    }
    
    // MARK: - Expanded All Packs Array
    static var expandedPacks: [DutchVocabularyPack] {
        return [
            advancedBusinessB1,
            advancedTechnologyB1,
            societyB1,
            advancedTransportationB1,
            artsCultureB1,
            advancedHomeLivingB1,
            weatherClimateB1,
            advancedCookingCuisineB1,
            politicsSocietyB1,
            crimeSafetyB1,
            geographyCountriesB1,
            historyB1,
            agricultureB1,
            constructionArchitectureB1,
            automotiveB1,
            telecommunicationsB1,
            hospitalityB1,
            bankingFinanceB1,
            realEstateB1,
            sportsRecreationB1,
            dailyLifeModernSocietyB1
        ]
    }
} 