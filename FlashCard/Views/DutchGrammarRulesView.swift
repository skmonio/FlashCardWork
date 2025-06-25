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
    @State private var exerciseScores: [String: Int] = [:] // Store scores for each rule
    @State private var shuffledExercises: [GrammarExercise] = []
    @State private var searchText = ""
    @State private var showingEndScreen = false
    @State private var finalScore = 0
    @State private var totalQuestions = 0
    @State private var questionAnswers: [Int: Int] = [:] // Track answers for each question index
    @State private var questionScores: [Int: Bool] = [:] // Track if each question was answered correctly
    @State private var showingLeaveConfirmation = false
    
    private let grammarDB = DutchGrammarRulesDatabase.shared
    
    // UserDefaults keys
    private let completedExercisesKey = "completedDutchGrammarExercises"
    private let exerciseScoresKey = "dutchGrammarExerciseScores"
    
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
            // Top bar without X button
            HStack {
                Text("📚 Dutch Grammar Rules")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
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
                        ForEach(filteredRules) { rule in
                            Button(action: {
                                selectedRule = rule
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(rule.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(rule.type.rawValue)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        // Completion and score indicators
                                        VStack(alignment: .trailing, spacing: 4) {
                                            if completedExercises.contains(rule.id) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                    Text("Completed")
                                                        .font(.caption)
                                                        .foregroundColor(.green)
                                                }
                                            }
                                            
                                            if let score = exerciseScores[rule.id] {
                                                HStack(spacing: 4) {
                                                    Text("\(score)%")
                                                        .font(.caption)
                                                        .fontWeight(.semibold)
                                                        .foregroundColor(scoreColor(for: score))
                                                    Image(systemName: scoreIcon(for: score))
                                                        .foregroundColor(scoreColor(for: score))
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Short description
                                    Text(shortDescription(for: rule))
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                    
                                    HStack {
                                        Text("\(rule.exercises.count) exercises")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 0.1), value: true)
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
        .navigationDestination(isPresented: $showingExercises) {
            exerciseSheet
        }
        .navigationDestination(isPresented: $showingEndScreen) {
            endScreenView
        }
        .onAppear {
            loadCompletedExercises()
            loadExerciseScores()
        }
        .alert("Leave Exercise?", isPresented: $showingLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                showingExercises = false
                selectedRule = nil
            }
            Button("Continue Exercise", role: .cancel) { }
        } message: {
            Text("Are you sure you want to leave? Your progress will be lost.")
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
                        questionAnswers.removeAll()
                        questionScores.removeAll()
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
                                
                                // Store the answer for this question
                                questionAnswers[currentExerciseIndex] = index
                                
                                // Check if this answer is correct
                                let isCorrect = index == exercise.correctAnswer
                                questionScores[currentExerciseIndex] = isCorrect
                                
                                // Recalculate total score based on all answered questions
                                exerciseScore = questionScores.values.filter { $0 }.count
                                
                                // If this is the last question, automatically complete after a delay
                                if currentExerciseIndex == totalCount - 1 {
                                    let finalScore = (exerciseScore * 100) / totalCount
                                    completedExercises.insert(rule.id)
                                    exerciseScores[rule.id] = finalScore
                                    saveCompletedExercises()
                                    saveExerciseScores()
                                    showingExercises = false
                                    showingEndScreen = true
                                    self.finalScore = finalScore
                                    self.totalQuestions = totalCount
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
                            // Restore the previous answer and score state for this question
                            selectedAnswer = questionAnswers[currentExerciseIndex]
                            showingAnswer = selectedAnswer != nil
                        }
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    if showingAnswer && currentExerciseIndex < totalCount - 1 {
                        Button("Next") {
                            currentExerciseIndex += 1
                            // Restore the answer and score state for the next question
                            selectedAnswer = questionAnswers[currentExerciseIndex]
                            showingAnswer = selectedAnswer != nil
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Exercises")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    showingLeaveConfirmation = true
                }
            }
        }
    }
    
    // MARK: - End Screen View
    
    private var endScreenView: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: finalScore >= 80 ? "star.circle.fill" : finalScore >= 60 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(finalScore >= 80 ? .yellow : finalScore >= 60 ? .green : .orange)
                
                Text("Exercise Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("You completed \(selectedRule?.title ?? "the exercise")")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Score Display
            VStack(spacing: 20) {
                Text("Your Score")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                HStack(spacing: 20) {
                    VStack {
                        Text("\(finalScore)%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(scoreColor)
                        Text("Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack {
                        Text("\(exerciseScore)/\(totalQuestions)")
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("Correct")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
            }
            
            // Performance Message
            VStack(spacing: 12) {
                Text(performanceMessage)
                    .font(.headline)
                    .foregroundColor(scoreColor)
                    .multilineTextAlignment(.center)
                
                Text(performanceDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 16) {
                Button("Continue Learning") {
                    showingEndScreen = false
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
                
                Button("Review Rules") {
                    showingEndScreen = false
                    showingExercises = false
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    showingEndScreen = false
                }
            }
        }
    }
    
    // MARK: - Helper Computed Properties
    
    private var scoreColor: Color {
        if finalScore >= 80 {
            return .green
        } else if finalScore >= 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var performanceMessage: String {
        if finalScore >= 90 {
            return "Excellent! 🎉"
        } else if finalScore >= 80 {
            return "Great Job! 👍"
        } else if finalScore >= 60 {
            return "Good Effort! 💪"
        } else {
            return "Keep Practicing! 📚"
        }
    }
    
    private var performanceDescription: String {
        if finalScore >= 90 {
            return "You've mastered this grammar rule! Consider moving on to more advanced topics."
        } else if finalScore >= 80 {
            return "You have a solid understanding of this rule. A little more practice will make it perfect!"
        } else if finalScore >= 60 {
            return "You're on the right track! Review the explanations and try again to improve your score."
        } else {
            return "Don't worry! Grammar takes time to learn. Review the rule explanations and practice more."
        }
    }
    
    // MARK: - Helper Functions
    
    private func shortDescription(for rule: DutchGrammarRule) -> String {
        switch rule.type {
        case .verbConjugation:
            return "Master Dutch verb forms and conjugations."
        case .sentenceStructure:
            return "Learn Dutch sentence patterns and word order."
        case .pluralization:
            return "Rules for making Dutch nouns plural."
        case .pronunciation:
            return "Key Dutch pronunciation patterns and sounds."
        case .spelling:
            return "Dutch spelling rules and patterns."
        case .tenses:
            return "Using different verb tenses in Dutch."
        case .wordOrder:
            return "Complex word order rules in Dutch."
        case .adjectives:
            return "How Dutch adjectives change with nouns."
        case .prepositions:
            return "Dutch prepositions and verb combinations."
        case .negation:
            return "Making sentences negative with 'niet' and 'geen'."
        }
    }
    
    private func iconFor(ruleType: GrammarRuleType) -> String {
        switch ruleType {
        case .verbConjugation: return "textformat.abc"
        case .sentenceStructure: return "text.alignleft"
        case .pluralization: return "textformat.123"
        case .pronunciation: return "speaker.wave.2"
        case .spelling: return "pencil"
        case .tenses: return "clock"
        case .wordOrder: return "arrow.left.and.right"
        case .adjectives: return "textformat.size"
        case .prepositions: return "arrow.up.forward"
        case .negation: return "minus.circle"
        }
    }
    
    private func scoreColor(for score: Int) -> Color {
        if score >= 80 {
            return .green
        } else if score >= 60 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func scoreIcon(for score: Int) -> String {
        if score >= 80 {
            return "star.fill"
        } else if score >= 60 {
            return "checkmark.circle.fill"
        } else {
            return "exclamationmark.circle.fill"
        }
    }
    
    // MARK: - Persistence Methods
    
    private func saveCompletedExercises() {
        UserDefaults.standard.set(Array(completedExercises), forKey: completedExercisesKey)
    }
    
    private func saveExerciseScores() {
        UserDefaults.standard.set(exerciseScores, forKey: exerciseScoresKey)
    }
    
    private func loadCompletedExercises() {
        if let savedCompletedExercises = UserDefaults.standard.array(forKey: completedExercisesKey) as? [String] {
            completedExercises = Set(savedCompletedExercises)
        }
    }
    
    private func loadExerciseScores() {
        if let savedExerciseScores = UserDefaults.standard.object(forKey: exerciseScoresKey) as? [String: Int] {
            exerciseScores = savedExerciseScores
        }
    }
}

#Preview {
    DutchGrammarRulesView()
} 