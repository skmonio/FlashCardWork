import SwiftUI

struct WordExerciseDetailView: View {
    let wordExercise: DutchWordExercise
    @ObservedObject var wordExerciseManager = DutchWordExerciseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentExerciseIndex = 0
    @State private var selectedAnswer: String?
    @State private var showingAnswer = false
    @State private var score = 0
    @State private var completedExercises: Set<UUID> = []
    @State private var showingResults = false
    @State private var exerciseResults: [UUID: Bool] = [:]
    @State private var shuffledExercises: [WordExercise] = []
    @State private var shuffledOptions: [[String]] = []
    @State private var correctAnswerMapping: [Int: String] = [:]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text(wordExercise.targetWord)
                                .font(.headline)
                            
                            Text(wordExercise.wordTranslation)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button("Results") {
                            showingResults = true
                        }
                        .foregroundColor(.blue)
                        .disabled(completedExercises.isEmpty)
                    }
                    .padding(.horizontal)
                    
                    // Progress Bar
                    ProgressView(value: Double(completedExercises.count), total: Double(shuffledExercises.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                        .padding(.horizontal)
                    
                    Divider()
                }
                .background(Color(.systemGroupedBackground))
                
                if shuffledExercises.isEmpty {
                    loadingView
                } else if currentExerciseIndex >= shuffledExercises.count {
                    completionView
                } else {
                    exerciseView
                }
            }
        }
        .onAppear {
            setupExercises()
        }
        .sheet(isPresented: $showingResults) {
            ExerciseResultsView(
                wordExercise: wordExercise,
                results: exerciseResults,
                score: score,
                totalQuestions: shuffledExercises.count
            )
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Preparing exercises...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Exercise View
    
    private var exerciseView: some View {
        let currentExercise = shuffledExercises[currentExerciseIndex]
        let currentOptions = shuffledOptions[currentExerciseIndex]
        
        return ScrollView {
            VStack(spacing: 24) {
                // Exercise Header
                exerciseHeader(currentExercise)
                
                // Question
                questionSection(currentExercise)
                
                // Options
                optionsSection(currentExercise, options: currentOptions)
                
                // Answer Section
                if showingAnswer {
                    answerSection(currentExercise)
                }
                
                // Navigation Buttons
                navigationButtons
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Exercise Header
    
    private func exerciseHeader(_ exercise: WordExercise) -> some View {
        VStack(spacing: 12) {
            HStack {
                Label(exercise.type.rawValue, systemImage: iconForExerciseType(exercise.type))
                    .font(.subheadline)
                    .foregroundColor(.blue)
                
                Spacer()
                
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(exercise.difficulty.color))
                        .frame(width: 8, height: 8)
                    
                    Text(exercise.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text("Question \(currentExerciseIndex + 1) of \(shuffledExercises.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Question Section
    
    private func questionSection(_ exercise: WordExercise) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(exercise.prompt)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.leading)
            
            if let context = exercise.context {
                Text(context)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Options Section
    
    private func optionsSection(_ exercise: WordExercise, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select your answer:")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button(action: {
                        if !showingAnswer {
                            selectedAnswer = option
                        }
                    }) {
                        HStack {
                            Text(option)
                                .font(.body)
                                .foregroundColor(optionColor(option, exercise: exercise))
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            if showingAnswer {
                                Image(systemName: optionIcon(option, exercise: exercise))
                                    .foregroundColor(optionColor(option, exercise: exercise))
                            }
                        }
                        .padding()
                        .background(optionBackground(option, exercise: exercise))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(optionBorder(option, exercise: exercise), lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(showingAnswer)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Answer Section
    
    private func answerSection(_ exercise: WordExercise) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(isCorrect ? .green : .red)
                    .font(.title2)
                
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Explanation:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(exercise.explanation)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            if let hint = exercise.hint {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hint:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    Text(hint)
                        .font(.body)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if showingAnswer {
                Button("Next Question") {
                    nextQuestion()
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
            } else {
                Button("Check Answer") {
                    checkAnswer()
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(selectedAnswer != nil ? Color.blue : Color.gray)
                .cornerRadius(8)
                .disabled(selectedAnswer == nil)
            }
        }
    }
    
    // MARK: - Completion View
    
    private var completionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("Exercise Complete!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                Text("Score: \(score)/\(shuffledExercises.count)")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Accuracy: \(Int((Double(score) / Double(shuffledExercises.count)) * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                Button("View Results") {
                    showingResults = true
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
                
                Button("Close") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Computed Properties
    
    private var isCorrect: Bool {
        guard let selectedAnswer = selectedAnswer else { return false }
        return selectedAnswer == shuffledExercises[currentExerciseIndex].correctAnswer
    }
    
    // MARK: - Helper Methods
    
    private func setupExercises() {
        shuffledExercises = wordExercise.exercises.shuffled()
        shuffledOptions = shuffledExercises.map { exercise in
            exercise.options.shuffled()
        }
        correctAnswerMapping = Dictionary(uniqueKeysWithValues: shuffledExercises.enumerated().map { index, exercise in
            (index, exercise.correctAnswer)
        })
    }
    
    private func iconForExerciseType(_ type: WordExercise.ExerciseType) -> String {
        switch type {
        case .fillInBlank: return "textformat.abc"
        case .sentenceBuilding: return "textformat.abc.dottedunderline"
        case .multipleChoice: return "list.bullet"
        case .translation: return "arrow.left.arrow.right"
        case .wordOrder: return "arrow.up.arrow.down"
        case .contextClue: return "lightbulb"
        case .pronunciation: return "speaker.wave.2"
        case .conjugation: return "textformat.abc"
        case .articlePractice: return "textformat.abc"
        case .synonymAntonym: return "arrow.left.arrow.right"
        }
    }
    
    private func optionColor(_ option: String, exercise: WordExercise) -> Color {
        guard showingAnswer else { return .primary }
        
        if option == exercise.correctAnswer {
            return .green
        } else if option == selectedAnswer && option != exercise.correctAnswer {
            return .red
        } else {
            return .secondary
        }
    }
    
    private func optionBackground(_ option: String, exercise: WordExercise) -> Color {
        guard showingAnswer else {
            return selectedAnswer == option ? Color.blue.opacity(0.1) : Color(.tertiarySystemGroupedBackground)
        }
        
        if option == exercise.correctAnswer {
            return Color.green.opacity(0.1)
        } else if option == selectedAnswer && option != exercise.correctAnswer {
            return Color.red.opacity(0.1)
        } else {
            return Color(.tertiarySystemGroupedBackground)
        }
    }
    
    private func optionBorder(_ option: String, exercise: WordExercise) -> Color {
        guard showingAnswer else {
            return selectedAnswer == option ? .blue : .clear
        }
        
        if option == exercise.correctAnswer {
            return .green
        } else if option == selectedAnswer && option != exercise.correctAnswer {
            return .red
        } else {
            return .clear
        }
    }
    
    private func optionIcon(_ option: String, exercise: WordExercise) -> String {
        if option == exercise.correctAnswer {
            return "checkmark.circle.fill"
        } else if option == selectedAnswer && option != exercise.correctAnswer {
            return "xmark.circle.fill"
        } else {
            return ""
        }
    }
    
    private func checkAnswer() {
        showingAnswer = true
        
        let currentExercise = shuffledExercises[currentExerciseIndex]
        let correct = isCorrect
        
        if correct {
            score += 1
        }
        
        completedExercises.insert(currentExercise.id)
        exerciseResults[currentExercise.id] = correct
    }
    
    private func nextQuestion() {
        showingAnswer = false
        selectedAnswer = nil
        currentExerciseIndex += 1
    }
}

// MARK: - Results View

struct ExerciseResultsView: View {
    let wordExercise: DutchWordExercise
    let results: [UUID: Bool]
    let score: Int
    let totalQuestions: Int
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Results")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("\(wordExercise.targetWord) - \(wordExercise.wordTranslation)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Score Card
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        ScoreItem(
                            title: "Score",
                            value: "\(score)/\(totalQuestions)",
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        ScoreItem(
                            title: "Accuracy",
                            value: "\(Int((Double(score) / Double(totalQuestions)) * 100))%",
                            icon: "percent",
                            color: .blue
                        )
                    }
                    
                    ProgressView(value: Double(score), total: Double(totalQuestions))
                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                
                // Results List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(results.keys), id: \.self) { exerciseId in
                            if let exercise = wordExercise.exercises.first(where: { $0.id == exerciseId }) {
                                ResultRow(
                                    exercise: exercise,
                                    isCorrect: results[exerciseId] ?? false
                                )
                            }
                        }
                    }
                }
                
                Button("Close") {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

struct ScoreItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResultRow: View {
    let exercise: WordExercise
    let isCorrect: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isCorrect ? .green : .red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(exercise.prompt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Text(isCorrect ? "Correct" : "Incorrect")
                .font(.caption)
                .foregroundColor(isCorrect ? .green : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background((isCorrect ? Color.green : Color.red).opacity(0.1))
                .cornerRadius(4)
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

#Preview {
    WordExerciseDetailView(wordExercise: DutchWordExercise.exampleForWord("terecht", translation: "justified"))
} 