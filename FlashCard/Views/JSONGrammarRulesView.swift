import SwiftUI

struct JSONGrammarRulesView: View {
    @StateObject private var questionManager = GrammarQuestionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLevel: LanguageLevel = .a1
    @State private var selectedRule: GrammarRuleData? = nil
    @State private var showingExercises = false
    @State private var showingRuleDetail = false
    @State private var currentExerciseIndex = 0
    @State private var selectedAnswer: Int? = nil
    @State private var showingAnswer = false
    @State private var exerciseScore = 0
    @State private var searchText = ""
    @State private var showingEndScreen = false
    @State private var finalScore = 0
    @State private var totalQuestions = 0
    @State private var questionAnswers: [Int: Int] = [:]
    @State private var questionScores: [Int: Bool] = [:]
    @State private var showingLeaveConfirmation = false
    @State private var shuffledExercises: [GrammarQuestionItem] = []
    @State private var shuffledOptions: [[String]] = []
    @State private var correctAnswerMapping: [Int: Int] = [:]
    @State private var allQuestionsAnswered = false
    @State private var exerciseStartTime: Date? = nil
    @State private var showingCloseConfirmation = false
    
    // Export functionality
    @State private var showingExportSheet = false
    @State private var showingRuleSelection = false
    @State private var exportData: Data? = nil
    @State private var exportFileName: String = ""
    @State private var exportMimeType: String = "text/csv"
    @State private var exportRuleSelection: GrammarRuleData? = nil
    @State private var exportAllRules = false
    // Import functionality
    @State private var showingImportPicker = false
    @State private var importResultMessage: String? = nil
    @State private var showingImportAlert = false
    
    var filteredRules: [GrammarRuleData] {
        let levelRules = questionManager.getRulesByLevel(selectedLevel)
        if searchText.isEmpty {
            return levelRules
        } else {
            return levelRules.filter { rule in
                rule.title.localizedCaseInsensitiveContains(searchText) ||
                rule.explanation.localizedCaseInsensitiveContains(searchText) ||
                rule.type.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            UnifiedHeader(
                title: "Dutch Grammar (JSON)",
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
                    } else if showingRuleDetail {
                        showingRuleDetail = false
                        selectedRule = nil
                    } else {
                        NavigationCoordinator.shared.pop()
                    }
                },
                trailing: {
                    AnyView(
                        HStack(spacing: 16) {
                            Button(action: {
                                showingRuleSelection = true
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Button(action: {
                                showingImportPicker = true
                            }) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.title2)
                                    .foregroundColor(.green)
                            }
                        }
                    )
                }
            )
            
            if questionManager.isLoading {
                loadingView
            } else if questionManager.errorMessage != nil {
                errorView
            } else if showingEndScreen {
                endScreenContent
            } else if showingRuleDetail {
                ruleDetailView
            } else if showingExercises {
                exerciseContent
            } else {
                mainContent
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert("Leave Exercise?", isPresented: $showingLeaveConfirmation) {
            Button("Leave", role: .destructive) {
                showingExercises = false
                showingRuleDetail = false
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
                showingRuleDetail = false
                selectedRule = nil
            }
            Button("Exit without saving", role: .destructive) {
                clearSavedProgress()
                showingExercises = false
                showingRuleDetail = false
                selectedRule = nil
            }
            Button("Continue Exercise", role: .cancel) { }
        } message: {
            Text(hasSignificantProgress ? 
                "Would you like to save your progress and continue later, or exit without saving?" : 
                "Are you sure you want to exit?")
        }
        .sheet(isPresented: $showingExportSheet) {
            exportSheet()
        }
        .sheet(isPresented: $showingRuleSelection) {
            ruleSelectionSheet()
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json, .commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleGrammarImport(result: result)
        }
        .alert("Import Result", isPresented: $showingImportAlert) {
            Button("OK") {}
        } message: {
            Text(importResultMessage ?? "Unknown result")
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack {
            ProgressView("Loading grammar questions...")
                .padding()
        }
    }
    
    // MARK: - Error View
    
    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Error Loading Questions")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(questionManager.errorMessage ?? "Unknown error")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Retry") {
                questionManager.loadQuestions()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LanguageLevel.allCases, id: \.self) { level in
                        Button(action: {
                            selectedLevel = level
                        }) {
                            Text(level.rawValue.uppercased())
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedLevel == level ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedLevel == level ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Rules List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredRules, id: \.id) { rule in
                        GrammarRuleCard(rule: rule) {
                            selectedRule = rule
                            showingRuleDetail = true
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Rule Detail View
    
    private var ruleDetailView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let rule = selectedRule {
                    // Rule Title and Level
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(rule.title)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(rule.level.uppercased())
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(levelColor(rule.level).opacity(0.2))
                                .foregroundColor(levelColor(rule.level))
                                .cornerRadius(12)
                        }
                        
                        Text(rule.type.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Rule Explanation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Explanation")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(rule.explanation)
                            .font(.body)
                            .lineSpacing(2)
                    }
                    
                    // Key Points
                    if !rule.keyPoints.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Key Points")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(rule.keyPoints.enumerated()), id: \.offset) { index, point in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("•")
                                            .foregroundColor(.blue)
                                            .fontWeight(.medium)
                                        Text(point)
                                            .font(.body)
                                            .lineSpacing(2)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // Examples
                    if !rule.examples.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Examples")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(rule.examples.enumerated()), id: \.offset) { index, example in
                                    VStack(spacing: 0) {
                                        // Dutch sentence (top section)
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Image(systemName: "quote.bubble.fill")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                    Text("Dutch")
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.blue)
                                                }
                                                
                                                Text(example.dutch)
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.primary)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.08))
                                        
                                        // English translation (bottom section)
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                HStack {
                                                    Image(systemName: "globe")
                                                        .font(.caption)
                                                        .foregroundColor(.green)
                                                    Text("English")
                                                        .font(.caption)
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.green)
                                                }
                                                
                                                Text(example.english)
                                                    .font(.body)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.green.opacity(0.08))
                                        
                                        // Breakdown (if available)
                                        if !example.breakdown.isEmpty {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    HStack {
                                                        Image(systemName: "lightbulb.fill")
                                                            .font(.caption)
                                                            .foregroundColor(.orange)
                                                        Text("Breakdown")
                                                            .font(.caption)
                                                            .fontWeight(.medium)
                                                            .foregroundColor(.orange)
                                                    }
                                                    
                                                    Text(example.breakdown)
                                                        .font(.caption)
                                                        .foregroundColor(.orange)
                                                        .italic()
                                                }
                                                Spacer()
                                            }
                                            .padding()
                                            .background(Color.orange.opacity(0.08))
                                        }
                                    }
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Start Exercise Button
                    Button(action: {
                        startExercise()
                    }) {
                        HStack {
                            Text("Start Exercise")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(rule.questions.count) questions")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 8)
                }
            }
            .padding()
        }
    }
    
    private func levelColor(_ level: String) -> Color {
        switch level.uppercased() {
        case "A1": return .green
        case "A2": return .blue
        case "B1": return .orange
        case "B2": return .red
        default: return .gray
        }
    }
    
    // MARK: - Exercise Content
    
    private var exerciseContent: some View {
        VStack(spacing: 0) {
            // Lesson-style progress bar
            LessonProgressBar(completedQuestions: currentExerciseIndex + 1, total: shuffledExercises.count)
                .padding(.horizontal)
                .padding(.bottom, 16)
            
            // Question Content
            if !shuffledExercises.isEmpty && currentExerciseIndex < shuffledExercises.count {
                let exercise = shuffledExercises[currentExerciseIndex]
                let options = shuffledOptions.isEmpty ? exercise.options : shuffledOptions[currentExerciseIndex]
                
                VStack(spacing: 20) {
                    // Question prompt
                    Text(exercise.question)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Hint if available and not showing answer
                    if let hint = exercise.hint, !showingAnswer {
                        Text("💡 \(hint)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.horizontal)
                    }
                    
                    // Answer options
                    VStack(spacing: 12) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                if !showingAnswer {
                                    selectedAnswer = index
                                    checkAnswer()
                                }
                            }) {
                                HStack {
                                    Text(option)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    
                                    if showingAnswer {
                                        let correctAnswer = correctAnswerMapping[currentExerciseIndex] ?? shuffledExercises[currentExerciseIndex].correctAnswer
                                        
                                        if index == correctAnswer {
                                            // Correct answer - show green checkmark
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.white)
                                        } else if selectedAnswer == index {
                                            // Selected wrong answer - show red X
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                        }
                                    } else if selectedAnswer == index {
                                        // Selected but not yet checked
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    showingAnswer ? 
                                        answerButtonColor(index: index, correctAnswer: correctAnswerMapping[currentExerciseIndex] ?? shuffledExercises[currentExerciseIndex].correctAnswer) :
                                        (selectedAnswer == index ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                )
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(showingAnswer)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Feedback section (lesson-style) - shown immediately after selection
                    if showingAnswer {
                        feedbackView(exercise: exercise)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    // MARK: - Feedback View (Lesson-style)
    
    private func feedbackView(exercise: GrammarQuestionItem) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Explanation
            Text(exercise.explanation)
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            
            // Navigation buttons (Previous and Next/Finish) - Lesson style
            HStack(spacing: 12) {
                Button(action: {
                    if currentExerciseIndex > 0 {
                        currentExerciseIndex -= 1
                        selectedAnswer = questionAnswers[currentExerciseIndex]
                        showingAnswer = questionAnswers[currentExerciseIndex] != nil
                    }
                }) {
                    Text("Previous")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(currentExerciseIndex == 0 ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                        .foregroundColor(currentExerciseIndex == 0 ? .gray : .blue)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(currentExerciseIndex == 0)
                
                Button(action: {
                    if currentExerciseIndex < shuffledExercises.count - 1 {
                        currentExerciseIndex += 1
                        selectedAnswer = questionAnswers[currentExerciseIndex]
                        showingAnswer = questionAnswers[currentExerciseIndex] != nil
                    } else {
                        // Exercise complete
                        finalScore = exerciseScore
                        totalQuestions = shuffledExercises.count
                        showingExercises = false
                        showingEndScreen = true
                    }
                }) {
                    Text(currentExerciseIndex < shuffledExercises.count - 1 ? "Next" : "Finish")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    // MARK: - End Screen Content
    
    private var endScreenContent: some View {
        VStack(spacing: 20) {
            Text("Exercise Complete!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Your Score: \(finalScore) / \(totalQuestions)")
                .font(.title2)
            
            Text("Percentage: \(Int((Double(finalScore) / Double(totalQuestions)) * 100))%")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Button("Back to Rules") {
                showingEndScreen = false
                selectedRule = nil
            }
            .buttonStyle(.borderedProminent)
            
            Button("Try Again") {
                showingEndScreen = false
                startExercise()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func startExercise() {
        guard let rule = selectedRule else { return }
        
        let questions = questionManager.getQuestions(for: rule.id)
        guard !questions.isEmpty else { return }
        
        // Shuffle exercises and options
        let (shuffledEx, shuffledOpts, answerMapping) = shuffleExerciseOptions(questions.shuffled())
        shuffledExercises = shuffledEx
        shuffledOptions = shuffledOpts
        correctAnswerMapping = answerMapping
        
        showingRuleDetail = false
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
    
    private func checkAnswer() {
        guard let selectedAnswer = selectedAnswer,
              currentExerciseIndex < shuffledExercises.count else { return }
        
        let exercise = shuffledExercises[currentExerciseIndex]
        let correctAnswer = correctAnswerMapping[currentExerciseIndex] ?? exercise.correctAnswer
        let isCorrect = selectedAnswer == correctAnswer
        
        questionAnswers[currentExerciseIndex] = selectedAnswer
        questionScores[currentExerciseIndex] = isCorrect
        
        if isCorrect {
            exerciseScore += 1
        }
        
        showingAnswer = true
    }
    
    private func shuffleExerciseOptions(_ exercises: [GrammarQuestionItem]) -> ([GrammarQuestionItem], [[String]], [Int: Int]) {
        var shuffledExercises: [GrammarQuestionItem] = []
        var shuffledOptions: [[String]] = []
        var answerMapping: [Int: Int] = [:]
        
        for (index, exercise) in exercises.enumerated() {
            let shuffled = exercise.options.shuffled()
            let correctAnswer = exercise.correctAnswer
            let newCorrectAnswer = shuffled.firstIndex(of: exercise.options[correctAnswer]) ?? 0
            
            shuffledExercises.append(exercise)
            shuffledOptions.append(shuffled)
            answerMapping[index] = newCorrectAnswer
        }
        
        return (shuffledExercises, shuffledOptions, answerMapping)
    }
    
    private var hasSignificantProgress: Bool {
        return currentExerciseIndex > 0 || exerciseScore > 0
    }
    
    private func saveCurrentProgress() {
        // Implementation for saving progress
    }
    
    private func clearSavedProgress() {
        // Implementation for clearing saved progress
    }
    
    private func answerButtonColor(index: Int, correctAnswer: Int) -> Color {
        if index == correctAnswer {
            // Correct answer - green
            return Color.green.opacity(0.8)
        } else if selectedAnswer == index {
            // Selected wrong answer - red
            return Color.red.opacity(0.8)
        } else {
            // Unselected options - gray
            return Color.gray.opacity(0.1)
        }
    }
}

// MARK: - Grammar Rule Card

struct GrammarRuleCard: View {
    let rule: GrammarRuleData
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(rule.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(rule.level.uppercased())
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(levelColor.opacity(0.2))
                        .foregroundColor(levelColor)
                        .cornerRadius(8)
                }
                
                Text(rule.explanation)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                
                HStack {
                    Text("\(rule.questions.count) questions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var levelColor: Color {
        switch rule.level.uppercased() {
        case "A1": return .green
        case "A2": return .blue
        case "B1": return .orange
        case "B2": return .red
        default: return .gray
        }
    }
}

// MARK: - Export Functionality

extension JSONGrammarRulesView {
    private func exportSheet() -> some View {
        if let data = exportData {
            AnyView(ShareSheet(activityItems: [ExportFileWrapper(data: data, fileName: exportFileName, mimeType: exportMimeType)]))
        } else {
            AnyView(Text("No data to export"))
        }
    }
    
    private func ruleSelectionSheet() -> some View {
        NavigationView {
            VStack(spacing: 0) {
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
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        Button(action: {
                            exportAllRules = true
                            exportRuleSelection = nil
                            showingRuleSelection = false
                            showExportPicker()
                        }) {
                            HStack {
                                Text("All Rules")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(questionManager.getAllRules().count) rules")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        ForEach(questionManager.getAllRules(), id: \.id) { rule in
                            Button(action: {
                                exportAllRules = false
                                exportRuleSelection = rule
                                showingRuleSelection = false
                                showExportPicker()
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(rule.title)
                                        .fontWeight(.medium)
                                    Text("\(rule.questions.count) questions")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private func showExportPicker() {
        let alert = UIAlertController(title: "Export Format", message: "Choose export format", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "CSV", style: .default, handler: { _ in
            exportGrammarQuestions(as: .csv)
        }))
        alert.addAction(UIAlertAction(title: "JSON", style: .default, handler: { _ in
            exportGrammarQuestions(as: .json)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(alert, animated: true)
        }
    }
    
    private enum ExportFormat { case csv, json }
    
    private func exportGrammarQuestions(as format: ExportFormat) {
        switch format {
        case .csv:
            let csv = questionManager.exportToCSV()
            exportData = csv.data(using: .utf8)
            exportFileName = exportAllRules ? "DutchGrammar_AllRules.csv" : "DutchGrammar_\(exportRuleSelection?.title.replacingOccurrences(of: " ", with: "_") ?? "Rule").csv"
            exportMimeType = "text/csv"
        case .json:
            let json = questionManager.exportToJSON()
            exportData = json.data(using: .utf8)
            exportFileName = exportAllRules ? "DutchGrammar_AllRules.json" : "DutchGrammar_\(exportRuleSelection?.title.replacingOccurrences(of: " ", with: "_") ?? "Rule").json"
            exportMimeType = "application/json"
        }
        
        showingExportSheet = true
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
    
    // MARK: - Import Logic
    private func handleGrammarImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                importResultMessage = "No file selected."
                showingImportAlert = true
                return
            }
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                var importedRules: [GrammarRuleData] = []
                var importType: String = ""
                // Try JSON import
                if url.pathExtension.lowercased() == "json" {
                    if let imported = try? decoder.decode(GrammarQuestionData.self, from: data) {
                        importedRules = imported.grammar_rules
                        importType = "JSON (GrammarQuestionData)"
                    } else {
                        throw NSError(domain: "Import", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure for grammar rules."])
                    }
                } else {
                    // Try CSV import (only basic support)
                    if let csvString = String(data: data, encoding: .utf8) {
                        let rows = csvString.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty }
                        guard let header = rows.first else { throw NSError(domain: "Import", code: 2, userInfo: [NSLocalizedDescriptionKey: "CSV missing header row"]) }
                        let columns = header.components(separatedBy: ",")
                        let idIdx = columns.firstIndex(of: "Rule ID")
                        let titleIdx = columns.firstIndex(of: "Rule Title")
                        let typeIdx = columns.firstIndex(of: "Type")
                        let levelIdx = columns.firstIndex(of: "Level")
                        let explanationIdx = columns.firstIndex(of: "Explanation")
                        // Only basic fields for CSV import
                        for row in rows.dropFirst() {
                            let fields = row.components(separatedBy: ",")
                            func val(_ idx: Int?) -> String { idx != nil && idx! < fields.count ? fields[idx!].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : "" }
                            let rule = GrammarRuleData(
                                id: val(idIdx),
                                title: val(titleIdx),
                                type: val(typeIdx),
                                level: val(levelIdx),
                                explanation: val(explanationIdx),
                                keyPoints: [],
                                examples: [],
                                questions: []
                            )
                            importedRules.append(rule)
                        }
                        importType = "CSV"
                    } else {
                        throw NSError(domain: "Import", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not decode file as UTF-8 text."])
                    }
                }
                if importedRules.isEmpty {
                    importResultMessage = "No grammar rules found in import file."
                } else {
                    // Merge/replace logic
                    var updated = 0, added = 0
                    var currentRules = questionManager.questionData?.grammar_rules ?? []
                    for rule in importedRules {
                        if let idx = currentRules.firstIndex(where: { $0.id == rule.id }) {
                            currentRules[idx] = rule; updated += 1
                        } else {
                            currentRules.append(rule); added += 1
                        }
                    }
                    let newMetadata = questionManager.questionData?.metadata ?? GrammarMetadata(version: "imported", lastUpdated: "now", description: "Imported")
                    questionManager.questionData = GrammarQuestionData(
                        metadata: newMetadata,
                        grammar_rules: currentRules
                    )
                    importResultMessage = "Imported/updated \(importedRules.count) rules (\(importType)). Updated: \(updated), Added: \(added)."
                }
                showingImportAlert = true
            } catch {
                importResultMessage = "Failed to import: \(error.localizedDescription)"
                showingImportAlert = true
            }
        case .failure(let error):
            importResultMessage = "Import failed: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
} 