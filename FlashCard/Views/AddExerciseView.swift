import SwiftUI

struct AddExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onAdd: (WordExercise) -> Void
    
    @State private var selectedType: WordExercise.ExerciseType = .fillInBlank
    @State private var prompt = ""
    @State private var options: [String] = ["", "", "", ""]
    @State private var correctAnswer = ""
    @State private var explanation = ""
    @State private var hint = ""
    @State private var selectedDifficulty: ExerciseDifficulty = .medium
    @State private var context = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.blue)
                        
                        Spacer()
                        
                        Text("Add Exercise")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Add") {
                            addExercise()
                        }
                        .foregroundColor(canAdd ? .blue : .gray)
                        .disabled(!canAdd)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                }
                .background(Color(.systemGroupedBackground))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Exercise Type
                        exerciseTypeSection
                        
                        // Basic Information
                        basicInformationSection
                        
                        // Options
                        optionsSection
                        
                        // Additional Information
                        additionalInformationSection
                    }
                    .padding()
                }
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var canAdd: Bool {
        !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count >= 2
    }
    
    // MARK: - Exercise Type Section
    
    private var exerciseTypeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercise Type")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                ForEach(WordExercise.ExerciseType.allCases, id: \.self) { type in
                    Button(action: { selectedType = type }) {
                        VStack(spacing: 8) {
                            Image(systemName: iconForExerciseType(type))
                                .font(.title2)
                                .foregroundColor(selectedType == type ? .white : .blue)
                            
                            Text(type.rawValue)
                                .font(.caption)
                                .foregroundColor(selectedType == type ? .white : .primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedType == type ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Basic Information Section
    
    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Basic Information")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Prompt
                VStack(alignment: .leading, spacing: 4) {
                    Text("Prompt")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter the question or prompt", text: $prompt, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                // Correct Answer
                VStack(alignment: .leading, spacing: 4) {
                    Text("Correct Answer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter the correct answer", text: $correctAnswer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Difficulty
                VStack(alignment: .leading, spacing: 4) {
                    Text("Difficulty")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Picker("Difficulty", selection: $selectedDifficulty) {
                        ForEach(ExerciseDifficulty.allCases, id: \.self) { difficulty in
                            HStack {
                                Circle()
                                    .fill(Color(difficulty.color))
                                    .frame(width: 8, height: 8)
                                Text(difficulty.rawValue)
                            }
                            .tag(difficulty)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Options Section
    
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Options")
                .font(.headline)
            
            VStack(spacing: 12) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    HStack {
                        TextField("Option \(index + 1)", text: $options[index])
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if options.count > 2 {
                            Button(action: { removeOption(at: index) }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                if options.count < 6 {
                    Button(action: addOption) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Option")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Additional Information Section
    
    private var additionalInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Additional Information")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Explanation
                VStack(alignment: .leading, spacing: 4) {
                    Text("Explanation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Explain why this is the correct answer", text: $explanation, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(3...6)
                }
                
                // Hint
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hint (Optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Provide a helpful hint", text: $hint)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Context
                VStack(alignment: .leading, spacing: 4) {
                    Text("Context (Optional)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Additional context for the exercise", text: $context, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func addOption() {
        if options.count < 6 {
            options.append("")
        }
    }
    
    private func removeOption(at index: Int) {
        if options.count > 2 {
            options.remove(at: index)
        }
    }
    
    private func addExercise() {
        guard canAdd else { return }
        
        // Validate that correct answer is in options
        let validOptions = options.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if !validOptions.contains(correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)) {
            errorMessage = "The correct answer must be one of the options"
            showingError = true
            return
        }
        
        let exercise = WordExercise(
            type: selectedType,
            prompt: prompt.trimmingCharacters(in: .whitespacesAndNewlines),
            options: validOptions,
            correctAnswer: correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines),
            explanation: explanation.trimmingCharacters(in: .whitespacesAndNewlines),
            hint: hint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : hint.trimmingCharacters(in: .whitespacesAndNewlines),
            difficulty: selectedDifficulty,
            context: context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : context.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        onAdd(exercise)
        dismiss()
    }
}

#Preview {
    AddExerciseView { _ in }
} 