import Foundation

// MARK: - JSON Grammar Question Models

struct GrammarQuestionData: Codable {
    let metadata: GrammarMetadata
    let rules: [String: GrammarRuleData]
}

struct GrammarMetadata: Codable {
    let version: String
    let lastUpdated: String
    let description: String
}

struct GrammarRuleData: Codable {
    let id: String
    let title: String
    let type: String
    let level: String
    let explanation: String
    let keyPoints: [String]
    let questions: [GrammarQuestionItem]
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
    
    // Convert to existing GrammarExercise format
    func toGrammarExercise() -> GrammarExercise {
        return GrammarExercise(
            question: question,
            options: options,
            correctAnswer: correctAnswer,
            explanation: explanation,
            hint: hint,
            exerciseType: ExerciseType(rawValue: exerciseType) ?? .multipleChoice
        )
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
            print("✅ Loaded \(questionData?.rules.count ?? 0) grammar rules with questions")
        } catch {
            errorMessage = "Failed to load questions: \(error.localizedDescription)"
            print("❌ Error loading grammar questions: \(error)")
        }
        
        isLoading = false
    }
    
    func getRule(by id: String) -> GrammarRuleData? {
        return questionData?.rules[id]
    }
    
    func getRulesByLevel(_ level: LanguageLevel) -> [GrammarRuleData] {
        guard let data = questionData else { return [] }
        
        return data.rules.values.filter { rule in
            rule.level.uppercased() == level.rawValue.uppercased()
        }
    }
    
    func getAllRules() -> [GrammarRuleData] {
        return questionData?.rules.values.map { $0 } ?? []
    }
    
    func getQuestions(for ruleId: String) -> [GrammarExercise] {
        guard let rule = getRule(by: ruleId) else { return [] }
        return rule.questions.map { $0.toGrammarExercise() }
    }
    
    func addQuestion(to ruleId: String, _ question: GrammarQuestionItem) {
        // This would be implemented for editing functionality
        // For now, we're read-only from JSON
    }
    
    func exportToCSV() -> String {
        var csv = "Rule ID,Rule Title,Question ID,Question,Options,Correct Answer,Explanation,Hint,Difficulty,Tags,Exercise Type\n"
        
        guard let data = questionData else { return csv }
        
        for (ruleId, rule) in data.rules {
            for question in rule.questions {
                let options = question.options.joined(separator: "; ")
                let tags = question.tags.joined(separator: "; ")
                let correctAnswerText = question.options.indices.contains(question.correctAnswer) ? question.options[question.correctAnswer] : ""
                
                let line = "\"\(ruleId)\",\"\(rule.title)\",\"\(question.id)\",\"\(question.question)\",\"\(options)\",\"\(correctAnswerText)\",\"\(question.explanation)\",\"\(question.hint ?? "")\",\"\(question.difficulty)\",\"\(tags)\",\"\(question.exerciseType)\"\n"
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

// MARK: - Extensions for Compatibility

extension GrammarRuleData {
    func toDutchGrammarRule() -> DutchGrammarRule {
        return DutchGrammarRule(
            id: id,
            title: title,
            type: GrammarRuleType(rawValue: type) ?? .verbConjugation,
            level: LanguageLevel(rawValue: level) ?? .a1,
            explanation: explanation,
            keyPoints: keyPoints,
            examples: [], // We'll add examples later if needed
            exercises: questions.map { $0.toGrammarExercise() },
            commonMistakes: [],
            tips: [],
            relatedRules: []
        )
    }
} 