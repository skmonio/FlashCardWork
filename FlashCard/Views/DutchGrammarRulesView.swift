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
    @State private var shuffledOptions: [[String]] = [] // Store shuffled options for each exercise
    @State private var correctAnswerMapping: [Int: Int] = [:] // Map original correct answer to shuffled position
    @State private var allQuestionsAnswered = false // Track if all questions have been answered
    
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
            // Custom Header
            UnifiedHeader(
                title: "Dutch Grammar",
                onBack: {
                    if showingEndScreen {
                        showingEndScreen = false
                    } else if showingExercises {
                        showingLeaveConfirmation = true
                    } else {
                        // Use the navigation coordinator to go back
                        NavigationCoordinator.shared.pop()
                    }
                },
                onProfile: {
                    // Present user profile sheet
                    NavigationCoordinator.shared.presentSheet(.userProfile)
                }
            )
            
            if showingEndScreen {
                // End Screen Content
                endScreenContent
            } else if showingExercises {
                // Exercise Content
                exerciseContent
            } else {
                // Main Content
                mainContent
            }
        }
        .onAppear {
            loadCompletedExercises()
            loadExerciseScores()
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
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
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        VStack(spacing: 0) {
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
            .padding(.top, 8)
            
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
                            RuleCard(
                                rule: rule,
                                completedExercises: completedExercises,
                                exerciseScores: exerciseScores,
                                onTap: {
                                selectedRule = rule
                                }
                            )
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
    }
    
    // MARK: - Exercise Content
    
    private var exerciseContent: some View {
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
                                
                                // Check if this is the last question and all questions are now answered
                                if currentExerciseIndex == totalCount - 1 {
                                    allQuestionsAnswered = true
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
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Spacer()
                    
                    if showingAnswer {
                        if currentExerciseIndex < totalCount - 1 {
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
                        .buttonStyle(PlainButtonStyle())
                        } else if allQuestionsAnswered {
                            // Show Finish button when all questions are answered and we're on the last question
                            Button("Finish") {
                                let totalCount = shuffledExercises.isEmpty ? rule.exercises.count : shuffledExercises.count
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
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.green)
                            .cornerRadius(8)
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - End Screen Content
    
    private var endScreenContent: some View {
        ScrollView {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: finalScore >= 80 ? "star.circle.fill" : finalScore >= 60 ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(finalScore >= 80 ? .yellow : finalScore >= 60 ? .green : .orange)
                
                Text("Exercise Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                
                Text("You completed \(selectedRule?.title ?? "the exercise")")
                    .font(.headline)
                    .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
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
                        .lineLimit(nil)
                
                Text(performanceDescription)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                        .lineLimit(nil)
                    .padding(.horizontal)
            }
            
                Spacer(minLength: 20)
            
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
                .buttonStyle(PlainButtonStyle())
                
                Button("Review Rules") {
                    showingEndScreen = false
                    showingExercises = false
                }
                .foregroundColor(.blue)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        }
    }
    
    // MARK: - Rule Detail View
    
    private var ruleDetailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                    
                    // Exercises Button - now positioned under the title
                    Button("Exercises") {
                        // Shuffle both the exercises and their options
                        let (shuffledEx, shuffledOpts, answerMapping) = shuffleExerciseOptions(rule.exercises.shuffled())
                        shuffledExercises = shuffledEx
                        shuffledOptions = shuffledOpts
                        correctAnswerMapping = answerMapping
                        showingExercises = true
                        currentExerciseIndex = 0
                        selectedAnswer = nil
                        showingAnswer = false
                        exerciseScore = 0
                        questionAnswers.removeAll()
                        questionScores.removeAll()
                        allQuestionsAnswered = false
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .buttonStyle(PlainButtonStyle())
                    
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
    
    private func shuffleExerciseOptions(_ exercises: [GrammarExercise]) -> ([GrammarExercise], [[String]], [Int: Int]) {
        var shuffledExercises: [GrammarExercise] = []
        var shuffledOptionsArray: [[String]] = []
        var correctAnswerMapping: [Int: Int] = [:]
        
        for (exerciseIndex, exercise) in exercises.enumerated() {
            // Create pairs of (option, originalIndex) for shuffling
            let optionPairs = exercise.options.enumerated().map { ($0.element, $0.offset) }
            let shuffledPairs = optionPairs.shuffled()
            
            // Extract shuffled options
            let shuffledOptions = shuffledPairs.map { $0.0 }
            shuffledOptionsArray.append(shuffledOptions)
            
            // Find the new position of the correct answer
            let correctAnswerText = exercise.options[exercise.correctAnswer]
            let newCorrectAnswerIndex = shuffledOptions.firstIndex(of: correctAnswerText) ?? 0
            correctAnswerMapping[exerciseIndex] = newCorrectAnswerIndex
            
            // Create new exercise with shuffled options
            let shuffledExercise = GrammarExercise(
                question: exercise.question,
                options: shuffledOptions,
                correctAnswer: newCorrectAnswerIndex,
                explanation: exercise.explanation,
                hint: exercise.hint,
                exerciseType: exercise.exerciseType
            )
            shuffledExercises.append(shuffledExercise)
        }
        
        return (shuffledExercises, shuffledOptionsArray, correctAnswerMapping)
    }
    
    private func loadCompletedExercises() {
        if let data = UserDefaults.standard.data(forKey: completedExercisesKey),
           let completed = try? JSONDecoder().decode(Set<String>.self, from: data) {
            completedExercises = completed
        }
    }
    
    private func saveCompletedExercises() {
        if let data = try? JSONEncoder().encode(completedExercises) {
            UserDefaults.standard.set(data, forKey: completedExercisesKey)
        }
    }
    
    private func loadExerciseScores() {
        if let data = UserDefaults.standard.data(forKey: exerciseScoresKey),
           let scores = try? JSONDecoder().decode([String: Int].self, from: data) {
            exerciseScores = scores
        }
    }
    
    private func saveExerciseScores() {
        if let data = try? JSONEncoder().encode(exerciseScores) {
            UserDefaults.standard.set(data, forKey: exerciseScoresKey)
        }
    }
}

// MARK: - Rule Card Component
struct RuleCard: View {
    let rule: DutchGrammarRule
    let completedExercises: Set<String>
    let exerciseScores: [String: Int]
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
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
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .shadow(color: cardOutlineColor.opacity(0.2), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(.easeInOut(duration: 0.1), value: true)
    }
    
    private var cardOutlineColor: Color {
        if completedExercises.contains(rule.id) {
            if let score = exerciseScores[rule.id] {
                if score >= 80 {
                    return .green
                } else if score >= 60 {
                    return .orange
                } else {
                    return .red
                }
            }
            return .green // Completed but no score
        } else {
            return .blue // Not completed
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
}

#Preview {
    DutchGrammarRulesView()
} 