import SwiftUI

struct DutchGrammarRulesView: View {
    @State private var selectedLevel: LanguageLevel = .a1
    @State private var selectedRuleType: GrammarRuleType? = nil
    @State private var selectedRule: DutchGrammarRule? = nil
    @State private var showingExercises = false
    @State private var currentExerciseIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingAnswer = false
    @State private var exerciseScore = 0
    @State private var completedExercises: Set<String> = []
    
    private let grammarDB = DutchGrammarRulesDatabase.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Level Selection Header
                levelSelectionHeader
                
                if selectedRule == nil {
                    // Rules Overview
                    rulesOverviewView
                } else {
                    // Detailed Rule View
                    ruleDetailView
                }
            }
            .navigationTitle("Nederlandse Grammatica")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingExercises) {
            exerciseSheet
        }
    }
    
    // MARK: - Level Selection Header
    
    private var levelSelectionHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Kies je niveau:")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            HStack(spacing: 12) {
                ForEach(LanguageLevel.allCases, id: \.self) { level in
                    Button(action: {
                        selectedLevel = level
                        selectedRule = nil
                        selectedRuleType = nil
                    }) {
                        VStack(spacing: 4) {
                            Text(level.rawValue)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(levelDescription(for: level))
                                .font(.caption)
                                .multilineTextAlignment(.center)
                        }
                        .foregroundColor(selectedLevel == level ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedLevel == level ? Color.blue : Color.gray.opacity(0.1))
                        )
                    }
                }
            }
            
            // Rule count for selected level
            Text("\(grammarDB.getRulesByLevel(selectedLevel).count) regels beschikbaar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - Rules Overview
    
    private var rulesOverviewView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Rule Types for Selected Level
                let availableTypes = Set(grammarDB.getRulesByLevel(selectedLevel).map { $0.type })
                
                ForEach(Array(availableTypes), id: \.self) { ruleType in
                    ruleTypeSection(for: ruleType)
                }
            }
            .padding()
        }
    }
    
    private func ruleTypeSection(for ruleType: GrammarRuleType) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: iconFor(ruleType: ruleType))
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text(ruleType.rawValue)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                let rulesCount = grammarDB.getRulesByType(ruleType).filter { $0.level == selectedLevel }.count
                Text("\(rulesCount)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            
            let rules = grammarDB.getRulesByType(ruleType).filter { $0.level == selectedLevel }
            
            ForEach(rules, id: \.id) { rule in
                Button(action: {
                    selectedRule = rule
                }) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(rule.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            if completedExercises.contains(rule.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(String(rule.explanation.prefix(100)) + "...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Rule Detail View
    
    private var ruleDetailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Back Button and Title
                HStack {
                    Button("← Terug") {
                        selectedRule = nil
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Oefeningen") {
                        showingExercises = true
                        currentExerciseIndex = 0
                        selectedAnswer = nil
                        showingAnswer = false
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(8)
                }
                
                if let rule = selectedRule {
                    // Rule Title and Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text(rule.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Text(rule.level.rawValue)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .cornerRadius(4)
                            
                            Text(rule.type.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Uitleg")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(rule.explanation)
                            .font(.body)
                            .lineSpacing(4)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Key Points
                    if !rule.keyPoints.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Belangrijke Punten")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ForEach(Array(rule.keyPoints.enumerated()), id: \.offset) { index, point in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .foregroundColor(.blue)
                                        .fontWeight(.bold)
                                    Text(point)
                                        .font(.body)
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Examples
                    if !rule.examples.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Voorbeelden")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ForEach(Array(rule.examples.enumerated()), id: \.offset) { index, example in
                                exampleCard(example: example)
                            }
                        }
                    }
                    
                    // Common Mistakes
                    if !rule.commonMistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Veelgemaakte Fouten")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ForEach(Array(rule.commonMistakes.enumerated()), id: \.offset) { index, mistake in
                                mistakeCard(mistake: mistake)
                            }
                        }
                    }
                    
                    // Tips
                    if !rule.tips.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tips")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ForEach(Array(rule.tips.enumerated()), id: \.offset) { index, tip in
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(.yellow)
                                    Text(tip)
                                        .font(.body)
                                }
                            }
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Related Rules
                    if !rule.relatedRules.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Gerelateerde Regels")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            let relatedRules = grammarDB.getRelatedRules(for: rule.id)
                            ForEach(relatedRules, id: \.id) { relatedRule in
                                Button(action: {
                                    selectedRule = relatedRule
                                }) {
                                    HStack {
                                        Text(relatedRule.title)
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Example Card
    
    private func exampleCard(example: GrammarExample) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(example.dutch)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(example.english)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
            
            if let breakdown = example.breakdown {
                Text(breakdown)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
            }
            
            if let audioHint = example.audioHint {
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.orange)
                    Text("[\(audioHint)]")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .fontFamily(.monospaced)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(8)
    }
    
    // MARK: - Mistake Card
    
    private func mistakeCard(mistake: CommonMistake) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text(mistake.incorrect)
                    .font(.body)
                    .strikethrough()
                    .foregroundColor(.red)
            }
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(mistake.correct)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            
            Text(mistake.explanation)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.red.opacity(0.05))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Exercise Sheet
    
    private var exerciseSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let rule = selectedRule, !rule.exercises.isEmpty {
                    let exercise = rule.exercises[currentExerciseIndex]
                    
                    // Progress
                    HStack {
                        Text("Vraag \(currentExerciseIndex + 1) van \(rule.exercises.count)")
                            .font(.headline)
                        Spacer()
                        Text("Score: \(exerciseScore)/\(currentExerciseIndex + (showingAnswer ? 1 : 0))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Question
                    VStack(alignment: .leading, spacing: 16) {
                        Text(exercise.question)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        
                        // Options
                        ForEach(Array(exercise.options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                if !showingAnswer {
                                    selectedAnswer = index
                                    showingAnswer = true
                                    if index == exercise.correctAnswer {
                                        exerciseScore += 1
                                    }
                                }
                            }) {
                                HStack {
                                    Text(option)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    
                                    if showingAnswer {
                                        if index == exercise.correctAnswer {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else if index == selectedAnswer && index != exercise.correctAnswer {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    showingAnswer ?
                                    (index == exercise.correctAnswer ? Color.green.opacity(0.2) :
                                     (index == selectedAnswer ? Color.red.opacity(0.2) : Color(.systemGray6))) :
                                    Color(.systemGray6)
                                )
                                .cornerRadius(8)
                            }
                            .disabled(showingAnswer)
                        }
                        
                        // Explanation and Hint
                        if showingAnswer {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Uitleg:")
                                    .font(.headline)
                                Text(exercise.explanation)
                                    .font(.body)
                                
                                if let hint = exercise.hint {
                                    Text("Tip: \(hint)")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    // Navigation Buttons
                    HStack(spacing: 20) {
                        if currentExerciseIndex > 0 {
                            Button("Vorige") {
                                currentExerciseIndex -= 1
                                selectedAnswer = nil
                                showingAnswer = false
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        if showingAnswer {
                            if currentExerciseIndex < rule.exercises.count - 1 {
                                Button("Volgende") {
                                    currentExerciseIndex += 1
                                    selectedAnswer = nil
                                    showingAnswer = false
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(8)
                            } else {
                                Button("Voltooien") {
                                    completedExercises.insert(rule.id)
                                    showingExercises = false
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.green)
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
            .padding()
            .navigationTitle("Oefeningen")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Sluiten") {
                showingExercises = false
            })
        }
    }
    
    // MARK: - Helper Functions
    
    private func levelDescription(for level: LanguageLevel) -> String {
        switch level {
        case .a1:
            return "Beginner\nBasis regels"
        case .a2:
            return "Elementair\nUitgebreide regels"
        case .b1:
            return "Intermediate\nComplexe regels"
        }
    }
    
    private func iconFor(ruleType: GrammarRuleType) -> String {
        switch ruleType {
        case .verbConjugation:
            return "arrow.triangle.2.circlepath"
        case .wordOrder:
            return "arrow.left.arrow.right"
        case .sentenceStructure:
            return "text.alignleft"
        case .pluralization:
            return "plus.circle"
        case .pronunciation:
            return "speaker.wave.3"
        case .spelling:
            return "textformat.abc"
        case .tenses:
            return "clock"
        case .adjectives:
            return "star.circle"
        case .prepositions:
            return "arrow.up.and.down.and.arrow.left.and.right"
        case .negation:
            return "minus.circle"
        }
    }
}

#Preview {
    DutchGrammarRulesView()
} 