import SwiftUI

struct DutchGrammarRulesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: LanguageLevel = .a1
    @State private var selectedRuleType: GrammarRuleType? = nil
    @State private var selectedRule: DutchGrammarRule? = nil
    @State private var showingExercises = false
    @State private var currentExerciseIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingAnswer = false
    @State private var exerciseScore = 0
    @State private var completedExercises: Set<String> = []
    @State private var shuffledExercises: [GrammarExercise] = []
    @State private var searchText = ""
    
    private let grammarDB = DutchGrammarRulesDatabase.shared
    
    var filteredRules: [DutchGrammarRule] {
        let levelRules = grammarDB.getRulesByLevel(selectedLevel)
        if searchText.isEmpty {
            return levelRules
        } else {
            return levelRules.filter { rule in
                rule.title.localizedCaseInsensitiveContains(searchText) ||
                rule.explanation.localizedCaseInsensitiveContains(searchText) ||
                rule.type.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar with X button
            HStack {
                Text("📚 Dutch Grammar Rules")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search grammar rules...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            // Level Selection Tabs
            HStack(spacing: 0) {
                ForEach(LanguageLevel.allCases, id: \.self) { level in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedLevel = level
                            selectedRule = nil
                            selectedRuleType = nil
                        }
                    }) {
                        VStack(spacing: 4) {
                            Text(level.rawValue)
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Text("\(grammarDB.getRulesByLevel(level).count) rules")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedLevel == level ? Color.blue : Color.clear)
                        .foregroundColor(selectedLevel == level ? .white : .primary)
                    }
                }
            }
            .background(Color(.systemGray6))
            .padding(.top, 8)
            
            if selectedRule == nil {
                // Rules List
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(filteredRules, id: \.id) { rule in
                            Button(action: {
                                selectedRule = rule
                            }) {
                                HStack(spacing: 12) {
                                    // Icon
                                    Image(systemName: iconFor(ruleType: rule.type))
                                        .font(.system(size: 18))
                                        .foregroundColor(.blue)
                                        .frame(width: 24, height: 24)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(rule.title)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text(rule.type.rawValue)
                                            .font(.system(size: 14))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(spacing: 4) {
                                        if completedExercises.contains(rule.id) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.system(size: 16))
                                        }
                                        
                                        Text("\(rule.exercises.count)")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.white)
                                            .frame(width: 20, height: 20)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            } else {
                // Detailed Rule View
                ruleDetailView
            }
        }
        .sheet(isPresented: $showingExercises) {
            exerciseSheet
        }
    }
    
    // MARK: - Rule Detail View
    
    private var ruleDetailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Back Button and Title
                HStack {
                    Button("← Back") {
                        selectedRule = nil
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Button("Exercises") {
                        if let rule = selectedRule {
                            shuffledExercises = rule.exercises.shuffled()
                        }
                        showingExercises = true
                        currentExerciseIndex = 0
                        selectedAnswer = nil
                        showingAnswer = false
                        exerciseScore = 0
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
                        Text("Explanation")
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
                            Text("Key Points")
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
                    
                    // Common Mistakes
                    if !rule.commonMistakes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Common Mistakes")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            ForEach(Array(rule.commonMistakes.enumerated()), id: \.offset) { index, mistake in
                                mistakeCard(mistake: mistake)
                            }
                        }
                    }
                    
                    // Related Rules
                    if !rule.relatedRules.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Related Rules")
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
                    let exercise = shuffledExercises.isEmpty ? rule.exercises[currentExerciseIndex] : shuffledExercises[currentExerciseIndex]
                    let totalCount = shuffledExercises.isEmpty ? rule.exercises.count : shuffledExercises.count
                    
                    // Progress
                    HStack {
                        Text("Question \(currentExerciseIndex + 1) of \(totalCount)")
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
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Explanation:")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                ScrollView {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(exercise.explanation)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(nil)
                                        
                                        if let hint = exercise.hint {
                                            Divider()
                                                .padding(.vertical, 4)
                                            
                                            Text("Tip: \(hint)")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .lineLimit(nil)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                }
                                .frame(minHeight: 80, maxHeight: 180)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Navigation Buttons
                    HStack(spacing: 20) {
                        if currentExerciseIndex > 0 {
                            Button("Previous") {
                                currentExerciseIndex -= 1
                                selectedAnswer = nil
                                showingAnswer = false
                            }
                            .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        if showingAnswer {
                            if currentExerciseIndex < totalCount - 1 {
                                Button("Next") {
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
                                Button("Complete") {
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
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        showingExercises = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
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