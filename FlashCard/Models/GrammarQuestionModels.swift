import Foundation

// MARK: - JSON Grammar Question Models

struct GrammarQuestionData: Codable {
    let metadata: GrammarMetadata
    let grammar_rules: [GrammarRuleData]
}

struct GrammarMetadata: Codable {
    let version: String
    let lastUpdated: String
    let description: String
}

struct ExampleItem: Codable {
    let dutch: String
    let english: String
    let breakdown: String
}

struct GrammarRuleData: Codable {
    let id: String
    let title: String
    let type: String
    let level: String
    let explanation: String
    let keyPoints: [String]
    let examples: [ExampleItem]
    let questions: [GrammarQuestionItem]

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case type
        case level
        case explanation
        case keyPoints = "key_points"
        case examples
        case questions
    }
}

struct GrammarQuestionItem: Codable, Identifiable {
    let id: String
    let question: String
    let options: [String]
    let correctAnswer: Int
    let explanation: String
    let hint: String?
    let difficulty: String
    let tags: [String]
    let exerciseType: String

    // Regular initializer for direct creation
    init(id: String, question: String, options: [String], correctAnswer: Int, explanation: String, hint: String? = nil, difficulty: String, tags: [String], exerciseType: String) {
        self.id = id
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.hint = hint
        self.difficulty = difficulty
        self.tags = tags
        self.exerciseType = exerciseType
    }

    enum CodingKeys: String, CodingKey {
        case id
        case question
        case options
        case correctAnswer = "correctAnswer"
        case correctAnswerSnake = "correct_answer"
        case explanation
        case hint
        case difficulty
        case tags
        case exerciseType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle missing id by generating one
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        
        question = try container.decode(String.self, forKey: .question)
        options = try container.decode([String].self, forKey: .options)
        
        // Handle both correctAnswer formats
        if let camelCase = try container.decodeIfPresent(Int.self, forKey: .correctAnswer) {
            correctAnswer = camelCase
        } else {
            correctAnswer = try container.decode(Int.self, forKey: .correctAnswerSnake)
        }
        
        explanation = try container.decode(String.self, forKey: .explanation)
        hint = try container.decodeIfPresent(String.self, forKey: .hint)
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty) ?? "medium"
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        exerciseType = try container.decodeIfPresent(String.self, forKey: .exerciseType) ?? "multiple_choice"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(question, forKey: .question)
        try container.encode(options, forKey: .options)
        try container.encode(correctAnswer, forKey: .correctAnswer)
        try container.encode(explanation, forKey: .explanation)
        try container.encodeIfPresent(hint, forKey: .hint)
        try container.encode(difficulty, forKey: .difficulty)
        try container.encode(tags, forKey: .tags)
        try container.encode(exerciseType, forKey: .exerciseType)
    }
}

// MARK: - Question Manager

class GrammarQuestionManager: ObservableObject {
    static let shared = GrammarQuestionManager()
    
    @Published var questionData: GrammarQuestionData?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private init() {
        loadQuestions()
    }
    
    func loadQuestions() {
        isLoading = true
        errorMessage = nil
        
        guard let url = Bundle.main.url(forResource: "DutchGrammarQuestions", withExtension: "json") else {
            errorMessage = "Could not find DutchGrammarQuestions.json"
            isLoading = false
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            questionData = try decoder.decode(GrammarQuestionData.self, from: data)
            print("✅ Loaded \(questionData?.grammar_rules.count ?? 0) grammar rules with questions")
        } catch {
            errorMessage = "Failed to load questions: \(error.localizedDescription)"
            print("❌ Error loading grammar questions: \(error)")
        }
        
        isLoading = false
    }
    
    func getRule(by id: String) -> GrammarRuleData? {
        return questionData?.grammar_rules.first(where: { $0.id == id })
    }
    
    func getRulesByLevel(_ level: LanguageLevel) -> [GrammarRuleData] {
        guard let data = questionData else { return [] }
        
        return data.grammar_rules.filter { rule in
            rule.level.uppercased() == level.rawValue.uppercased()
        }
    }
    
    func getAllRules() -> [GrammarRuleData] {
        return questionData?.grammar_rules ?? []
    }
    
    func getQuestions(for ruleId: String) -> [GrammarQuestionItem] {
        guard let rule = getRule(by: ruleId) else { return [] }
        return rule.questions
    }
    
    func addQuestion(to ruleId: String, _ question: GrammarQuestionItem) {
        // This would be implemented for editing functionality
        // For now, we're read-only from JSON
    }
    
    func exportToCSV() -> String {
        var csv = "Rule ID,Rule Title,Question ID,Question,Options,Correct Answer,Explanation,Hint,Difficulty,Tags,Exercise Type\n"
        
        guard let data = questionData else { return csv }
        
        for rule in data.grammar_rules {
            for question in rule.questions {
                let options = question.options.joined(separator: "; ")
                let tags = question.tags.joined(separator: "; ")
                let correctAnswerText = question.options.indices.contains(question.correctAnswer) ? question.options[question.correctAnswer] : ""
                
                let line = "\"\(rule.id)\",\"\(rule.title)\",\"\(question.id)\",\"\(question.question)\",\"\(options)\",\"\(correctAnswerText)\",\"\(question.explanation)\",\"\(question.hint ?? "")\",\"\(question.difficulty)\",\"\(tags)\",\"\(question.exerciseType)\"\n"
                csv += line
            }
        }
        
        return csv
    }
    
    func exportToJSON() -> String {
        guard let data = questionData else { return "{}" }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("❌ Error exporting to JSON: \(error)")
            return "{}"
        }
    }
    
    func exportToCSV(rules: [GrammarRuleData]) -> String {
        var csv = "Rule ID,Rule Title,Rule Type,Rule Level,Rule Explanation,Rule Key Points,Rule Examples,Question ID,Question,Options,Correct Answer,Explanation,Hint,Difficulty,Tags,Exercise Type\n"
        for rule in rules {
            let keyPoints = rule.keyPoints.joined(separator: "; ")
            let examples = rule.examples.map { "Dutch: \($0.dutch) | English: \($0.english) | Breakdown: \($0.breakdown)" }.joined(separator: " || ")
            for question in rule.questions {
                let options = question.options.joined(separator: "; ")
                let tags = question.tags.joined(separator: "; ")
                let correctAnswerText = question.options.indices.contains(question.correctAnswer) ? question.options[question.correctAnswer] : ""
                let line = "\"\(rule.id)\",\"\(rule.title)\",\"\(rule.type)\",\"\(rule.level)\",\"\(rule.explanation)\",\"\(keyPoints)\",\"\(examples)\",\"\(question.id)\",\"\(question.question)\",\"\(options)\",\"\(correctAnswerText)\",\"\(question.explanation)\",\"\(question.hint ?? "")\",\"\(question.difficulty)\",\"\(tags)\",\"\(question.exerciseType)\"\n"
                csv += line
            }
        }
        return csv
    }

    func exportToJSON(rules: [GrammarRuleData]) -> String {
        let data = GrammarQuestionData(metadata: questionData?.metadata ?? GrammarMetadata(version: "export", lastUpdated: "now", description: "Exported"), grammar_rules: rules)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData = try encoder.encode(data)
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        } catch {
            print("❌ Error exporting to JSON: \(error)")
            return "{}"
        }
    }
    
    func importFromJSON(_ jsonString: String) {
        do {
            let data = jsonString.data(using: .utf8) ?? Data()
            let decoder = JSONDecoder()
            questionData = try decoder.decode(GrammarQuestionData.self, from: data)
            print("✅ Imported grammar questions successfully")
        } catch {
            errorMessage = "Failed to import questions: \(error.localizedDescription)"
            print("❌ Error importing grammar questions: \(error)")
        }
    }
} 