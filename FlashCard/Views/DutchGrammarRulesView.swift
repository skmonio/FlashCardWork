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
    @State private var isReviewMode = false
    
    // Sentence building state (for sentence building exercises)
    @State private var selectedWords: [String] = []
    @State private var availableWords: [String] = []
    @State private var sentenceBuildingAnswers: [Int: [String]] = [:]
    @State private var isSentenceCorrect: Bool? = nil
    
    // Save state functionality
    @State private var exerciseStartTime: Date? = nil
    @State private var showingCloseConfirmation = false
    
    // Export functionality
    @State private var showingExportSheet = false
    @State private var showingRuleSelection = false
    @State private var exportData: Data? = nil
    @State private var exportFileName: String = ""
    @State private var exportMimeType: String = "text/csv"
    @State private var exportRuleSelection: DutchGrammarRule? = nil
    @State private var exportAllRules = false
    
    // Add a new state property:
    @State private var showingRestartConfirmation = false
    
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
                showProfileIcon: false,
                onBack: {
                    if showingEndScreen {
                        showingEndScreen = false
                    } else if showingExercises {
                        if hasSignificantProgress {
                            showingCloseConfirmation = true
                        } else {
                            showingLeaveConfirmation = true
                        }
                    } else {
                        // Use the navigation coordinator to go back
                        NavigationCoordinator.shared.pop()
                    }
                },
                trailing: {
                    AnyView(
                        Button(action: {
                            // Show rule selection for export
                            showingRuleSelection = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                    )
                }
            )
            
            if showingEndScreen {
                // End Screen Content
                endScreenContent
            } else if isReviewMode {
                // Review Mode Content
                reviewContent
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
        .alert("Save Progress?", isPresented: $showingCloseConfirmation) {
            Button("Save & Exit", role: .destructive) {
                saveCurrentProgress()
                showingExercises = false
                selectedRule = nil
            }
            Button("Exit without saving", role: .destructive) {
                clearSavedProgress()
                showingExercises = false
                selectedRule = nil
            }
            Button("Continue Exercise", role: .cancel) { }
        } message: {
            Text("Do you want to save your progress and continue later, or exit without saving?")
        }
        .alert("Start New Exercise?", isPresented: $showingRestartConfirmation) {
            Button("Start New", role: .destructive) {
                clearSavedProgress()
                // Shuffle both the exercises and their options
                let (shuffledEx, shuffledOpts, answerMapping) = shuffleExerciseOptions(selectedRule?.exercises.shuffled() ?? [])
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
                exerciseStartTime = Date()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Starting a new exercise will clear your current progress. Are you sure you want to start over?")
        }
        .sheet(isPresented: $showingExportSheet) {
            exportSheet()
        }
        .sheet(isPresented: $showingRuleSelection) {
            ruleSelectionSheet()
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
                                inProgressRules: getInProgressRules(),
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
                
                // Game-style progress bar (same as Dutch lessons)
                LessonProgressBar(completedQuestions: currentExerciseIndex + 1, total: totalCount)
                    .padding(.bottom, 8)
                
                // Question
                VStack(alignment: .leading, spacing: 16) {
                    Text(exercise.question)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Handle different exercise types
                    if exercise.exerciseType == .sentenceBuilding {
                        // Sentence Building UI
                        sentenceBuildingView(exercise: exercise, options: availableWords, correctIdx: exercise.correctAnswer)
                            .id("sentence-building-\(currentExerciseIndex)") // Force view recreation when exercise changes
                            .onAppear {
                                // Initialize sentence building state if not already done
                                if availableWords.isEmpty {
                                    // For sentence building, use the original options in correct order (don't shuffle)
                                    availableWords = exercise.options
                                    print("📚 Initialized sentence building for exercise \(currentExerciseIndex): \(exercise.question)")
                                }
                            }
                    } else {
                        // Standard multiple choice UI
                        multipleChoiceView(exercise: exercise, options: exercise.options, correctIdx: exercise.correctAnswer)
                    }
                    
                    // Explanation and Hint
                    if showingAnswer {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.explanation)
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            if let hint = exercise.hint {
                                Text("Tip: \(hint)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.top)
                    }
                }
                
                Spacer()
                
                // Navigation Buttons (same style as Dutch lessons)
                if showingAnswer {
                    HStack(spacing: 12) {
                        Button(action: {
                            if currentExerciseIndex > 0 {
                                currentExerciseIndex -= 1
                                // Restore the previous answer and score state for this question
                                selectedAnswer = questionAnswers[currentExerciseIndex]
                                showingAnswer = selectedAnswer != nil
                                // Restore sentence building state for previous exercise
                                restoreSentenceBuildingState()
                                
                                // Auto-save progress
                                saveCurrentProgress()
                            }
                        }) {
                            Text("Previous")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(currentExerciseIndex == 0 ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                                .foregroundColor(currentExerciseIndex == 0 ? .gray : .blue)
                                .cornerRadius(8)
                        }
                        .disabled(currentExerciseIndex == 0)
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            if currentExerciseIndex < totalCount - 1 {
                                currentExerciseIndex += 1
                                // Restore the answer and score state for the next question
                                selectedAnswer = questionAnswers[currentExerciseIndex]
                                showingAnswer = selectedAnswer != nil
                                // Restore sentence building state for next exercise
                                restoreSentenceBuildingState()
                                
                                // Auto-save progress
                                saveCurrentProgress()
                            } else if allQuestionsAnswered {
                                // Show Finish button when all questions are answered and we're on the last question
                                let totalCount = shuffledExercises.isEmpty ? rule.exercises.count : shuffledExercises.count
                                let finalScore = (exerciseScore * 100) / totalCount
                                completedExercises.insert(rule.id)
                                exerciseScores[rule.id] = finalScore
                                saveCompletedExercises()
                                saveExerciseScores()
                                
                                // Clear saved progress since exercise is complete
                                clearSavedProgress()
                                
                                showingExercises = false
                                showingEndScreen = true
                                self.finalScore = finalScore
                                self.totalQuestions = totalCount
                            }
                        }) {
                            Text(currentExerciseIndex < totalCount - 1 ? "Next" : "Finish Exercise")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding()
    }
    
    // MARK: - Multiple Choice View
    
    private func multipleChoiceView(exercise: GrammarExercise, options: [String], correctIdx: Int) -> some View {
        VStack(spacing: 8) {
            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
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
                        let totalCount = shuffledExercises.isEmpty ? selectedRule?.exercises.count ?? 0 : shuffledExercises.count
                        if currentExerciseIndex == totalCount - 1 {
                            allQuestionsAnswered = true
                        }
                        
                        // Auto-save progress after answering
                        saveCurrentProgress()
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
                        (index == exercise.correctAnswer ? Color.green.opacity(0.15) :
                         (index == selectedAnswer ? Color.red.opacity(0.15) : Color(.systemGray6))) :
                        Color(.systemGray6)
                    )
                    .cornerRadius(8)
                }
                .disabled(showingAnswer)
            }
        }
    }
    
    // MARK: - Sentence Building View
    
    @ViewBuilder
    private func sentenceBuildingView(exercise: GrammarExercise, options: [String], correctIdx: Int) -> some View {
        VStack(spacing: 16) {
            // Built sentence display
            VStack(alignment: .leading, spacing: 8) {
                Text("Your sentence:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    if showingAnswer {
                        // Show the completed sentence as plain text
                        Text(selectedWords.joined(separator: " "))
                            .font(.body)
                            .foregroundColor(.primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                    } else {
                        LazyVStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 2) {
                                ForEach(selectedWords.indices, id: \.self) { index in
                                    let word = selectedWords[index]
                                    Text(word)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(3)
                                        .onTapGesture {
                                            if !showingAnswer {
                                                // Remove word from sentence
                                                selectedWords.remove(at: index)
                                            }
                                        }
                                }
                                Spacer(minLength: 0)
                            }
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .frame(minHeight: 50)
                .padding()
                .background(
                    showingAnswer ? 
                    (isSentenceCorrect == true ? Color.green.opacity(0.15) : isSentenceCorrect == false ? Color.red.opacity(0.15) : Color(.systemGray6)) :
                    Color(.systemGray6)
                )
                .cornerRadius(12)
            }
            
            // Show correct answer if wrong
            if showingAnswer && isSentenceCorrect == false {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Correct answer:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(exercise.correctSentence ?? exercise.options.joined(separator: " "))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                }
            }
            
            // Available words (grid, stable positions)
            if !showingAnswer {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available words:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(options.indices, id: \.self) { index in
                            let word = options[index]
                            let isSelected = selectedWords.contains(word)
                            Button(action: {
                                if !showingAnswer && !isSelected {
                                    selectedWords.append(word)
                                }
                            }) {
                                if isSelected {
                                    // Show empty/transparent cell for selected word
                                    Color.clear
                                        .frame(height: 32)
                                } else {
                                    Text(word)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .disabled(showingAnswer || isSelected)
                        }
                    }
                }
            }
            
            // Check answer button
            if !showingAnswer && selectedWords.count == options.count {
                Button(action: {
                    let userSentence = selectedWords.joined(separator: " ")
                    let correctSentence = exercise.correctSentence ?? exercise.options.joined(separator: " ")
                    showingAnswer = true
                    isSentenceCorrect = userSentence == correctSentence
                    
                    // Store the answer for this question
                    sentenceBuildingAnswers[currentExerciseIndex] = selectedWords
                    
                    // Update question scores
                    questionScores[currentExerciseIndex] = isSentenceCorrect
                    
                    // Recalculate total score based on all answered questions
                    exerciseScore = questionScores.values.filter { $0 }.count
                    
                    // Check if this is the last question and all questions are now answered
                    let totalCount = shuffledExercises.isEmpty ? selectedRule?.exercises.count ?? 0 : shuffledExercises.count
                    if currentExerciseIndex == totalCount - 1 {
                        allQuestionsAnswered = true
                    }
                    
                    // Auto-save progress after answering
                    saveCurrentProgress()
                }) {
                    Text("Check Answer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            // Reset button
            if !showingAnswer && !selectedWords.isEmpty {
                Button(action: {
                    selectedWords.removeAll()
                }) {
                    Text("Reset")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
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
                
                Button("Review Questions") {
                    showingExercises = true
                    showingEndScreen = false
                    // Restore the last question state for review
                    currentExerciseIndex = totalQuestions - 1
                    selectedAnswer = questionAnswers[currentExerciseIndex]
                    showingAnswer = true
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
    
    // MARK: - Review Content
    
    private var reviewContent: some View {
        EmptyView()
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
                        if hasInProgressExercise(for: rule.id) {
                            showingRestartConfirmation = true
                        } else {
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
                            exerciseStartTime = Date()
                            // Try to load saved progress
                            loadSavedProgress()
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.green)
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .buttonStyle(PlainButtonStyle())
                    
                    // Continue button if there's saved progress
                    if hasInProgressExercise(for: rule.id) {
                        Button("Continue Exercise") {
                            // Load saved progress and start exercises
                            showingExercises = true
                            loadSavedProgress()
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.orange)
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .buttonStyle(PlainButtonStyle())
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
            if exercise.exerciseType == .sentenceBuilding {
                // For sentence building exercises, keep options in original order (don't shuffle)
                shuffledOptionsArray.append(exercise.options)
                correctAnswerMapping[exerciseIndex] = exercise.correctAnswer
                
                // Create exercise with original options
                let sentenceBuildingExercise = GrammarExercise(
                    question: exercise.question,
                    options: exercise.options,
                    correctAnswer: exercise.correctAnswer,
                    explanation: exercise.explanation,
                    hint: exercise.hint,
                    exerciseType: exercise.exerciseType,
                    correctSentence: exercise.correctSentence
                )
                shuffledExercises.append(sentenceBuildingExercise)
            } else {
                // For other exercise types, shuffle as before
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
    
    // MARK: - Helper Functions
    
    private func resetSentenceBuildingState() {
        // Reset sentence building state when changing exercises
        selectedWords.removeAll()
        isSentenceCorrect = nil // Reset correctness state
        
        // Initialize available words for sentence building exercises
        if let rule = selectedRule {
            let exercise = shuffledExercises.isEmpty ? rule.exercises[currentExerciseIndex] : shuffledExercises[currentExerciseIndex]
            if exercise.exerciseType == .sentenceBuilding {
                availableWords = exercise.options
            } else {
                availableWords.removeAll()
            }
        }
        
        // Also reset feedback state if we're moving to a new exercise
        if !questionAnswers.keys.contains(currentExerciseIndex) {
            showingAnswer = false
            selectedAnswer = nil
        }
        print("📚 Reset sentence building state for exercise \(currentExerciseIndex)")
    }
    
    private func restoreSentenceBuildingState() {
        // Restore sentence building state when navigating back to a previous exercise
        if let rule = selectedRule {
            let exercise = shuffledExercises.isEmpty ? rule.exercises[currentExerciseIndex] : shuffledExercises[currentExerciseIndex]
            if exercise.exerciseType == .sentenceBuilding {
                // For sentence building, we need to restore the selected words
                if let savedWords = sentenceBuildingAnswers[currentExerciseIndex] {
                    selectedWords = savedWords
                    // Rebuild available words from what wasn't used
                    availableWords = exercise.options.filter { !selectedWords.contains($0) }
                    // If we have a saved answer, show the feedback
                    if !savedWords.isEmpty {
                        showingAnswer = true
                        let userSentence = savedWords.joined(separator: " ")
                        let correctSentence = exercise.correctSentence ?? exercise.options.joined(separator: " ")
                        isSentenceCorrect = userSentence == correctSentence
                    }
                } else {
                    selectedWords.removeAll()
                    // For sentence building, use the original options in correct order (don't shuffle)
                    availableWords = exercise.options
                    showingAnswer = false
                    isSentenceCorrect = nil
                }
            }
        }
        print("📚 Restored sentence building state for exercise \(currentExerciseIndex)")
    }
    
    // MARK: - Save State Functions
    
    private var hasSignificantProgress: Bool {
        return currentExerciseIndex > 0 || exerciseScore > 0
    }
    
    private func saveCurrentProgress() {
        guard hasSignificantProgress, let rule = selectedRule else { return }
        
        let savedExercises = shuffledExercises.map { exercise in
            DutchGrammarGameState.SavedGrammarExercise(
                question: exercise.question,
                options: exercise.options,
                correctAnswer: exercise.correctAnswer,
                explanation: exercise.explanation,
                hint: exercise.hint,
                exerciseType: exercise.exerciseType.rawValue
            )
        }
        
        let gameState = DutchGrammarGameState(
            ruleId: rule.id,
            ruleTitle: rule.title,
            currentExerciseIndex: currentExerciseIndex,
            exerciseScore: exerciseScore,
            questionAnswers: questionAnswers,
            questionScores: questionScores,
            shuffledExercises: savedExercises,
            exerciseStartTime: exerciseStartTime
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .dutchGrammar,
            gameData: gameState
        )
        
        print("📚 Dutch Grammar progress saved - Index: \(currentExerciseIndex), Score: \(exerciseScore)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .dutchGrammar,
            as: DutchGrammarGameState.self
        ) {
            // Only load if it's the same rule
            guard savedState.ruleId == selectedRule?.id else {
                print("📚 Saved rule ID doesn't match current rule, starting fresh")
                return
            }
            
            // Restore state
            currentExerciseIndex = savedState.currentExerciseIndex
            exerciseScore = savedState.exerciseScore
            questionAnswers = savedState.questionAnswers
            questionScores = savedState.questionScores
            exerciseStartTime = savedState.exerciseStartTime
            
            // Restore shuffled exercises
            shuffledExercises = savedState.shuffledExercises.map { savedExercise in
                GrammarExercise(
                    question: savedExercise.question,
                    options: savedExercise.options,
                    correctAnswer: savedExercise.correctAnswer,
                    explanation: savedExercise.explanation,
                    hint: savedExercise.hint,
                    exerciseType: ExerciseType(rawValue: savedExercise.exerciseType) ?? .multipleChoice
                )
            }
            
            // Restore current exercise state
            if let currentAnswer = questionAnswers[currentExerciseIndex] {
                selectedAnswer = currentAnswer
                showingAnswer = true
                // Restore sentence building state if needed
                restoreSentenceBuildingState()
            } else {
                // Initialize sentence building state for new exercise
                restoreSentenceBuildingState()
            }
            
            // Check if all questions are answered
            allQuestionsAnswered = questionAnswers.count == shuffledExercises.count
            
            print("📚 Dutch Grammar progress loaded - Index: \(currentExerciseIndex), Score: \(exerciseScore)")
        } else {
            // No saved state found, start normally
            print("📚 No saved state found, starting fresh Dutch Grammar exercise")
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .dutchGrammar)
    }
    
    private func hasInProgressExercise(for ruleId: String) -> Bool {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .dutchGrammar,
            as: DutchGrammarGameState.self
        ) {
            return savedState.ruleId == ruleId && savedState.hasSignificantProgress
        }
        return false
    }
    
    private func getInProgressRules() -> Set<String> {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .dutchGrammar,
            as: DutchGrammarGameState.self
        ) {
            if savedState.hasSignificantProgress {
                return [savedState.ruleId]
            }
        }
        return []
    }
}

// MARK: - Rule Card Component
struct RuleCard: View {
    let rule: DutchGrammarRule
    let completedExercises: Set<String>
    let exerciseScores: [String: Int]
    let inProgressRules: Set<String>
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
                        } else if inProgressRules.contains(rule.id) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.orange)
                                Text("In Progress")
                                    .font(.caption)
                                    .foregroundColor(.orange)
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

// MARK: - Export Picker and Share Sheet
extension DutchGrammarRulesView {
    // Export Picker and Share Sheet
    @ViewBuilder
    private func exportSheet() -> some View {
        if let data = exportData {
            ShareSheet(activityItems: [ExportFileWrapper(data: data, fileName: exportFileName, mimeType: exportMimeType)])
        } else {
            EmptyView()
        }
    }
    
    private func showExportPicker() {
        // Show format picker (CSV/JSON)
        let alert = UIAlertController(title: "Export Format", message: "Choose export format", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "CSV", style: .default, handler: { _ in
            print("📤 Exporting as CSV...")
            exportGrammarQuestions(as: .csv)
        }))
        alert.addAction(UIAlertAction(title: "JSON", style: .default, handler: { _ in
            print("📤 Exporting as JSON...")
            exportGrammarQuestions(as: .json)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        // For simulator testing, show a simple alert instead of share sheet
        #if targetEnvironment(simulator)
        alert.addAction(UIAlertAction(title: "Preview Export (Simulator)", style: .default, handler: { _ in
            print("📤 Previewing export data...")
            previewExportData()
        }))
        #endif
        
        // Use a more reliable method to present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        } else {
            print("❌ Could not present export picker alert")
        }
    }
    
    private enum ExportFormat { case csv, json }
    
    private func exportGrammarQuestions(as format: ExportFormat) {
        print("📤 Starting export process...")
        var rulesToExport: [DutchGrammarRule] = []
        if exportAllRules {
            rulesToExport = grammarDB.allGrammarRules
            print("📤 Exporting all rules: \(rulesToExport.count) rules")
        } else if let rule = exportRuleSelection {
            rulesToExport = [rule]
            print("📤 Exporting single rule: \(rule.title)")
        }
        
        guard !rulesToExport.isEmpty else {
            print("❌ No rules to export!")
            return
        }
        
        switch format {
        case .csv:
            let csv = grammarRulesToCSV(rulesToExport)
            exportData = csv.data(using: .utf8)
            exportFileName = exportAllRules ? "DutchGrammar_AllRules.csv" : "DutchGrammar_\(rulesToExport.first?.title.replacingOccurrences(of: " ", with: "_") ?? "Rule").csv"
            exportMimeType = "text/csv"
            print("📤 Generated CSV data: \(csv.count) characters")
        case .json:
            let json = grammarRulesToJSON(rulesToExport)
            exportData = json.data(using: .utf8)
            exportFileName = exportAllRules ? "DutchGrammar_AllRules.json" : "DutchGrammar_\(rulesToExport.first?.title.replacingOccurrences(of: " ", with: "_") ?? "Rule").json"
            exportMimeType = "application/json"
            print("📤 Generated JSON data: \(json.count) characters")
        }
        
        // Show share sheet on device, preview on simulator
        #if targetEnvironment(simulator)
        print("📤 Running in simulator, showing preview...")
        previewExportData()
        #else
        print("📤 Running on device, showing share sheet...")
        showingExportSheet = true
        #endif
    }
    
    private func grammarRulesToCSV(_ rules: [DutchGrammarRule]) -> String {
        var csv = "Rule,Question,Options,CorrectAnswer,Explanation,Hint,Type\n"
        for rule in rules {
            for ex in rule.exercises {
                let options = ex.options.joined(separator: "; ")
                let type = String(describing: ex.exerciseType)
                let line = "\"\(rule.title)\",\"\(ex.question)\",\"\(options)\",\"\(ex.options.indices.contains(ex.correctAnswer) ? ex.options[ex.correctAnswer] : "")\",\"\(ex.explanation)\",\"\(ex.hint ?? "")\",\"\(type)\"\n"
                csv += line
            }
        }
        return csv
    }
    
    private func grammarRulesToJSON(_ rules: [DutchGrammarRule]) -> String {
        let dicts = rules.map { rule in
            [
                "rule": rule.title,
                "exercises": rule.exercises.map { ex in
                    [
                        "question": ex.question,
                        "options": ex.options,
                        "correctAnswer": ex.options.indices.contains(ex.correctAnswer) ? ex.options[ex.correctAnswer] : "",
                        "explanation": ex.explanation,
                        "hint": ex.hint ?? "",
                        "type": String(describing: ex.exerciseType)
                    ]
                }
            ]
        }
        if let data = try? JSONSerialization.data(withJSONObject: dicts, options: .prettyPrinted), let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "[]"
    }
    
    private func previewExportData() {
        print("📤 Previewing export data...")
        if let data = exportData, let str = String(data: data, encoding: .utf8) {
            print("📤 Export data available: \(str.count) characters")
            let alert = UIAlertController(title: "Export Preview", message: str, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Use the same reliable method to present the alert
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            } else {
                print("❌ Could not present preview alert")
            }
        } else {
            print("❌ No export data available to preview")
            let alert = UIAlertController(title: "No Export Data", message: "No export data available to preview.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            // Use the same reliable method to present the alert
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alert, animated: true)
            } else {
                print("❌ Could not present error alert")
            }
        }
    }
    
    class ExportFileWrapper: NSObject, UIActivityItemSource {
        let data: Data
        let fileName: String
        let mimeType: String
        init(data: Data, fileName: String, mimeType: String) {
            self.data = data
            self.fileName = fileName
            self.mimeType = mimeType
        }
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any { data }
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? { data }
        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String { fileName }
        func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String { mimeType }
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
            UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
}

// MARK: - Rule Selection Sheet
extension DutchGrammarRulesView {
    // MARK: - Rule Selection Sheet
    
    @ViewBuilder
    private func ruleSelectionSheet() -> some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Select Rules to Export")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Cancel") {
                        showingRuleSelection = false
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                // Rule List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // "All Rules" option
                        Button(action: {
                            exportAllRules = true
                            exportRuleSelection = nil
                            showingRuleSelection = false
                            showExportPicker()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Export All Rules")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text("\(grammarDB.allGrammarRules.count) rules total")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Individual rules
                        ForEach(grammarDB.allGrammarRules) { rule in
                            Button(action: {
                                exportAllRules = false
                                exportRuleSelection = rule
                                showingRuleSelection = false
                                showExportPicker()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(rule.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text("\(rule.exercises.count) exercises")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    DutchGrammarRulesView()
} 