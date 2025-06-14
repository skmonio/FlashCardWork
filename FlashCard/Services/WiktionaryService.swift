import Foundation

// MARK: - Data Models
struct WiktionaryWordInfo {
    let word: String
    let translation: String
    let article: String?
    let plural: String?
    let pastTense: String?
    let futureTense: String?
    let pastParticiple: String?
    let examples: [String]
    let wordType: WordType
    let pronunciation: String?
}

enum WordType: String, CaseIterable {
    case noun = "noun"
    case verb = "verb"
    case adjective = "adjective"
    case adverb = "adverb"
    case other = "other"
}

// MARK: - Data Models (More lenient)
struct WiktionaryAPIResponse: Codable {
    let batchcomplete: Bool?  // This field was missing!
    let query: QueryResult?
    
    // Allow for unexpected additional fields
    private enum CodingKeys: String, CodingKey {
        case batchcomplete, query
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        batchcomplete = try container.decodeIfPresent(Bool.self, forKey: .batchcomplete)
        query = try container.decodeIfPresent(QueryResult.self, forKey: .query)
    }
}

struct QueryResult: Codable {
    let pages: [PageInfo]?
    
    private enum CodingKeys: String, CodingKey {
        case pages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pages = try container.decodeIfPresent([PageInfo].self, forKey: .pages)
    }
}

struct PageInfo: Codable {
    let pageid: Int?
    let ns: Int?      // Namespace - this was missing!
    let title: String?
    let extract: String?
    let revisions: [RevisionInfo]?
    let missing: Bool?  // Handle missing pages
    
    private enum CodingKeys: String, CodingKey {
        case pageid, ns, title, extract, revisions, missing
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pageid = try container.decodeIfPresent(Int.self, forKey: .pageid)
        ns = try container.decodeIfPresent(Int.self, forKey: .ns)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        extract = try container.decodeIfPresent(String.self, forKey: .extract)
        revisions = try container.decodeIfPresent([RevisionInfo].self, forKey: .revisions)
        missing = try container.decodeIfPresent(Bool.self, forKey: .missing)
    }
}

struct RevisionInfo: Codable {
    let slots: SlotInfo?
    
    private enum CodingKeys: String, CodingKey {
        case slots
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slots = try container.decodeIfPresent(SlotInfo.self, forKey: .slots)
    }
}

struct SlotInfo: Codable {
    let main: MainContent?
    
    private enum CodingKeys: String, CodingKey {
        case main
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        main = try container.decodeIfPresent(MainContent.self, forKey: .main)
    }
}

struct MainContent: Codable {
    let contentmodel: String?
    let contentformat: String?
    let content: String? // This contains the wikitext
    
    private enum CodingKeys: String, CodingKey {
        case contentmodel, contentformat, content
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        contentmodel = try container.decodeIfPresent(String.self, forKey: .contentmodel)
        contentformat = try container.decodeIfPresent(String.self, forKey: .contentformat)
        content = try container.decodeIfPresent(String.self, forKey: .content)
    }
}

// MARK: - Wiktionary Service
class WiktionaryService: ObservableObject {
    static let shared = WiktionaryService()
    
    private let session = URLSession.shared
    private let baseURL = "https://en.wiktionary.org/w/api.php"
    
    private init() {}
    
    /// Fetch word information from Wiktionary
    func fetchWordInfo(for word: String) async throws -> WiktionaryWordInfo? {
        let cleanWord = word.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !cleanWord.isEmpty else { return nil }
        
        print("🔍 Fetching Wiktionary info for: \(cleanWord)")
        
        // Build URL for Wiktionary API
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "titles", value: cleanWord),
            URLQueryItem(name: "prop", value: "revisions"),
            URLQueryItem(name: "rvprop", value: "content"),
            URLQueryItem(name: "rvslots", value: "main"),
            URLQueryItem(name: "formatversion", value: "2")
        ]
        
        guard let url = components.url else {
            print("❌ Failed to create URL for word: \(cleanWord)")
            throw WiktionaryError.invalidURL
        }
        
        print("📡 Making request to: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            print("📡 Response received, status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ HTTP Error: Status \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                throw WiktionaryError.networkError
            }
            
            print("📄 Response data size: \(data.count) bytes")
            
            // Debug: Print raw response to see what we're getting
            if let rawString = String(data: data, encoding: .utf8) {
                print("📄 Raw API response (first 500 chars): \(String(rawString.prefix(500)))")
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(WiktionaryAPIResponse.self, from: data)
                print("✅ JSON decoded successfully")
                
                guard let pages = apiResponse.query?.pages else {
                    print("❌ No pages in API response")
                    return nil
                }
                
                print("📄 Pages found: \(pages.count)")
                
                for page in pages {
                    print("📄 Page ID: \(page.pageid ?? -1), Title: \(page.title ?? "nil"), Missing: \(page.missing ?? false)")
                    
                    // Skip missing pages
                    if page.missing == true {
                        print("📄 Page marked as missing, skipping...")
                        continue
                    }
                    
                    guard let revisions = page.revisions, !revisions.isEmpty else {
                        print("📄 No revisions found for page")
                        continue
                    }
                    
                    print("📄 Found \(revisions.count) revisions")
                    
                    guard let firstRevision = revisions.first else {
                        print("📄 No first revision")
                        continue
                    }
                    
                    print("📄 First revision exists")
                    
                    guard let slots = firstRevision.slots else {
                        print("📄 No slots in revision")
                        continue
                    }
                    
                    print("📄 Slots exist")
                    
                    guard let main = slots.main else {
                        print("📄 No main slot")
                        continue
                    }
                    
                    print("📄 Main slot exists")
                    
                    guard let content = main.content else {
                        print("📄 No content in main slot")
                        continue
                    }
                    
                    print("📄 Content exists, length: \(content.count)")
                    
                    if content.isEmpty {
                        print("📄 Content is empty")
                        continue
                    }
                    
                    print("✅ Retrieved wikitext for: \(cleanWord) (length: \(content.count) chars)")
                    return parseWikitext(content, for: cleanWord)
                }
                
                print("❌ No usable content found in any page")
                return nil
                
            } catch let jsonError {
                print("❌ JSON parsing error: \(jsonError)")
                
                // Fallback: Try to parse as generic JSON to see structure
                do {
                    let genericJson = try JSONSerialization.jsonObject(with: data, options: [])
                    print("📄 Generic JSON structure: \(genericJson)")
                    
                    if let dict = genericJson as? [String: Any] {
                        print("📄 Top-level keys: \(dict.keys)")
                        
                        if let query = dict["query"] as? [String: Any] {
                            print("📄 Query keys: \(query.keys)")
                            
                            if let pages = query["pages"] as? [Any] {
                                print("📄 Pages count: \(pages.count)")
                                for (index, pageData) in pages.enumerated() {
                                    print("📄 Page \(index): \(pageData)")
                                }
                            }
                        }
                    }
                } catch {
                    print("❌ Even generic JSON parsing failed: \(error)")
                }
                
                if let decodingError = jsonError as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("❌ Missing key: \(key), context: \(context)")
                    case .typeMismatch(let type, let context):
                        print("❌ Type mismatch: expected \(type), context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("❌ Value not found: \(type), context: \(context)")
                    case .dataCorrupted(let context):
                        print("❌ Data corrupted: \(context)")
                    @unknown default:
                        print("❌ Unknown decoding error")
                    }
                }
                throw WiktionaryError.parsingError
            }
            
        } catch {
            print("❌ Network error: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Fetch word information with completion handler (for SwiftUI compatibility)
    func fetchWordInfo(for word: String, completion: @escaping (Result<WiktionaryWordInfo?, Error>) -> Void) {
        Task {
            do {
                let result = try await fetchWordInfo(for: word)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Parse wikitext content to extract grammatical information
    private func parseWikitext(_ wikitext: String, for word: String) -> WiktionaryWordInfo? {
        print("🔍 Starting to parse wikitext for: \(word)")
        let lines = wikitext.components(separatedBy: .newlines)
        print("📄 Total lines to parse: \(lines.count)")
        
        var translation: String?
        var article: String?
        var plural: String?
        var pastTense: String?
        var futureTense: String?
        var pastParticiple: String?
        var examples: [String] = []
        var wordType = WordType.other
        var pronunciation: String?
        
        var isDutchSection = false
        var currentWordType: WordType?
        var dutchSectionFound = false
        
        for (lineNumber, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Check for Dutch section
            if trimmedLine.contains("==Dutch==") {
                isDutchSection = true
                dutchSectionFound = true
                print("📄 Found Dutch section at line \(lineNumber): \(trimmedLine)")
                continue
            } else if trimmedLine.hasPrefix("==") && !trimmedLine.hasPrefix("===") && !trimmedLine.contains("Dutch") {
                // Only exit on level 2 headings (==Something==), not level 3+ (===Something===)
                if isDutchSection {
                    print("📄 Exiting Dutch section at line \(lineNumber): \(trimmedLine)")
                }
                isDutchSection = false
                continue
            }
            
            guard isDutchSection else { continue }
            
            print("📄 Processing Dutch line \(lineNumber): \(trimmedLine)")
            
            // Extract word type
            if trimmedLine.hasPrefix("===Noun===") {
                currentWordType = .noun
                wordType = .noun
                print("📄 Found noun section")
            } else if trimmedLine.hasPrefix("===Verb===") {
                currentWordType = .verb
                wordType = .verb
                print("📄 Found verb section")
            } else if trimmedLine.hasPrefix("===Adjective===") {
                currentWordType = .adjective
                wordType = .adjective
                print("📄 Found adjective section")
            }
            
            // Extract pronunciation
            if trimmedLine.contains("{{IPA") {
                pronunciation = extractIPA(from: trimmedLine)
                print("📄 Found pronunciation: \(pronunciation ?? "nil")")
            }
            
            // Extract translations (definitions)
            if trimmedLine.hasPrefix("#") && !trimmedLine.hasPrefix("##") {
                if let extracted = extractTranslation(from: trimmedLine) {
                    translation = extracted
                    print("📄 Found translation: \(extracted)")
                }
            }
            
            // Extract grammatical information based on word type
            if let currentType = currentWordType {
                switch currentType {
                case .noun:
                    if trimmedLine.contains("{{nl-noun") {
                        let grammarInfo = extractNounInfo(from: trimmedLine)
                        article = grammarInfo.article
                        plural = grammarInfo.plural
                        print("📄 Found noun info - article: \(article ?? "nil"), plural: \(plural ?? "nil")")
                    }
                case .verb:
                    if trimmedLine.contains("{{nl-verb") {
                        let verbInfo = extractVerbInfo(from: trimmedLine)
                        pastTense = verbInfo.pastTense
                        pastParticiple = verbInfo.pastParticiple
                        print("📄 Found verb info - past: \(pastTense ?? "nil"), participle: \(pastParticiple ?? "nil")")
                    }
                default:
                    break
                }
            }
            
            // Extract examples
            if trimmedLine.hasPrefix("#:") {
                if let example = extractExample(from: trimmedLine) {
                    examples.append(example)
                    print("📄 Found example: \(example)")
                }
            }
        }
        
        print("📄 Parsing complete for '\(word)':")
        print("   - Dutch section found: \(dutchSectionFound)")
        print("   - Translation: \(translation ?? "nil")")
        print("   - Word type: \(wordType.rawValue)")
        print("   - Examples: \(examples.count)")
        
        // If no translation found, return nil
        guard let finalTranslation = translation else {
            print("❌ No translation found for: \(word)")
            return nil
        }
        
        // Generate future tense for verbs (simple rule-based)
        if wordType == .verb {
            futureTense = "zal \(word)"
        }
        
        print("✅ Parsed info for '\(word)': \(finalTranslation) (\(wordType.rawValue))")
        
        return WiktionaryWordInfo(
            word: word,
            translation: finalTranslation,
            article: article,
            plural: plural,
            pastTense: pastTense,
            futureTense: futureTense,
            pastParticiple: pastParticiple,
            examples: examples,
            wordType: wordType,
            pronunciation: pronunciation
        )
    }
    
    // MARK: - Parsing Helpers
    
    private func extractTranslation(from line: String) -> String? {
        // Remove wiki markup and extract basic translation
        var cleaned = line.replacingOccurrences(of: "#", with: "")
        cleaned = cleaned.replacingOccurrences(of: "[[", with: "")
        cleaned = cleaned.replacingOccurrences(of: "]]", with: "")
        
        // Remove templates like {{l|en|...}}
        let templatePattern = "\\{\\{[^}]+\\}\\}"
        cleaned = cleaned.replacingOccurrences(of: templatePattern, with: "", options: .regularExpression)
        
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned.isEmpty ? nil : cleaned
    }
    
    private func extractNounInfo(from line: String) -> (article: String?, plural: String?) {
        var article: String?
        var plural: String?
        
        // Extract from {{nl-noun|m|woorden}} or {{nl-noun|het|woorden}}
        if let match = line.range(of: "\\{\\{nl-noun\\|([^|]+)\\|([^}]+)\\}\\}", options: .regularExpression) {
            let content = String(line[match])
            let parts = content.components(separatedBy: "|")
            if parts.count >= 3 {
                let articlePart = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                if articlePart == "m" || articlePart == "f" || articlePart == "c" {
                    article = "de"
                } else if articlePart == "n" || articlePart.contains("het") {
                    article = "het"
                } else if articlePart == "de" || articlePart == "het" {
                    article = articlePart
                }
                
                if parts.count >= 3 {
                    plural = parts[2].replacingOccurrences(of: "}}", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return (article: article, plural: plural)
    }
    
    private func extractVerbInfo(from line: String) -> (pastTense: String?, pastParticiple: String?) {
        var pastTense: String?
        var pastParticiple: String?
        
        // Extract from {{nl-verb|werkte|gewerkt}} patterns
        if let match = line.range(of: "\\{\\{nl-verb\\|([^|]+)\\|([^}]+)\\}\\}", options: .regularExpression) {
            let content = String(line[match])
            let parts = content.components(separatedBy: "|")
            if parts.count >= 3 {
                pastTense = parts[1].trimmingCharacters(in: .whitespacesAndNewlines)
                pastParticiple = parts[2].replacingOccurrences(of: "}}", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return (pastTense: pastTense, pastParticiple: pastParticiple)
    }
    
    private func extractExample(from line: String) -> String? {
        var cleaned = line.replacingOccurrences(of: "#:", with: "")
        cleaned = cleaned.replacingOccurrences(of: "[[", with: "")
        cleaned = cleaned.replacingOccurrences(of: "]]", with: "")
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned.isEmpty ? nil : cleaned
    }
    
    private func extractIPA(from line: String) -> String? {
        // Extract IPA from {{IPA|nl|/pronunciation/}}
        if let match = line.range(of: "/[^/]+/", options: .regularExpression) {
            return String(line[match])
        }
        return nil
    }
}

// MARK: - Error Types
enum WiktionaryError: Error, LocalizedError {
    case invalidURL
    case networkError
    case parsingError
    case noDataFound
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Wiktionary URL"
        case .networkError:
            return "Network error while fetching from Wiktionary"
        case .parsingError:
            return "Error parsing Wiktionary response"
        case .noDataFound:
            return "No data found for this word"
        }
    }
} 