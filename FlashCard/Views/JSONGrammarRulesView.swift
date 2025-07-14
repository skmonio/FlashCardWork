import SwiftUI

struct JSONGrammarRulesView: View {
    @StateObject private var questionManager = GrammarQuestionManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedLevel: LanguageLevel = .a1
    @State private var selectedRule: GrammarRuleData? = nil
    @State private var showingExercises = false
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
    @State private var shuffledExercises: [GrammarExercise] = []
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
                    } else {
                        NavigationCoordinator.shared.pop()
                    }
                },
                trailing: {
                    AnyView(
                        Button(action: {
                            showingRuleSelection = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.title2)
                                .foregroundColor(.blue)
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
        .sheet(isPresented: $showingExportSheet) {
            exportSheet()
        }
        .sheet(isPresented: $showingRuleSelection) {
            ruleSelectionSheet()
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
                            startExercise()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    // MARK: - Exercise Content
    
    private var exerciseContent: some View {
        VStack(spacing: 0) {
            // Exercise Header
            HStack {
                Button("Exit") {
                    if hasSignificantProgress {
                        showingCloseConfirmation = true
                    } else {
                        showingLeaveConfirmation = true
                    }
                }
                .foregroundColor(.red)
                
                Spacer()
                
                Text("\(currentExerciseIndex + 1) / \(shuffledExercises.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Hint") {
                    // Show hint if available
                }
                .foregroundColor(.blue)
                .disabled(shuffledExercises.isEmpty || currentExerciseIndex >= shuffledExercises.count)
            }
            .padding()
            
            // Progress Bar
            ProgressView(value: Double(currentExerciseIndex), total: Double(shuffledExercises.count))
                .padding(.horizontal)
            
            // Question Content
            if !shuffledExercises.isEmpty && currentExerciseIndex < shuffledExercises.count {
                let exercise = shuffledExercises[currentExerciseIndex]
                let options = shuffledOptions.isEmpty ? exercise.options : shuffledOptions[currentExerciseIndex]
                
                VStack(spacing: 20) {
                    Text(exercise.question)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    VStack(spacing: 12) {
                        ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                            Button(action: {
                                selectedAnswer = index
                            }) {
                                HStack {
                                    Text(option)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    if selectedAnswer == index {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(selectedAnswer == index ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    
                    if showingAnswer {
                        VStack(spacing: 8) {
                            Text(exercise.explanation)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(10)
                            
                            Button("Next Question") {
                                nextQuestion()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(currentExerciseIndex >= shuffledExercises.count - 1)
                        }
                        .padding(.horizontal)
                    } else {
                        Button("Check Answer") {
                            checkAnswer()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedAnswer == nil)
                        .padding(.horizontal)
                    }
                }
            }
            
            Spacer()
        }
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
    
    private func nextQuestion() {
        if currentExerciseIndex < shuffledExercises.count - 1 {
            currentExerciseIndex += 1
            selectedAnswer = nil
            showingAnswer = false
        } else {
            // Exercise complete
            finalScore = exerciseScore
            totalQuestions = shuffledExercises.count
            showingEndScreen = true
        }
    }
    
    private func shuffleExerciseOptions(_ exercises: [GrammarExercise]) -> ([GrammarExercise], [[String]], [Int: Int]) {
        var shuffledExercises: [GrammarExercise] = []
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
} 