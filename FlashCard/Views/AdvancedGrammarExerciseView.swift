import SwiftUI

struct AdvancedGrammarExerciseView: View {
    let question: GrammarQuestionItem
    @State private var selectedAnswer: Int? = nil
    @State private var userInput: String = ""
    @State private var showingAnswer = false
    @State private var isCorrect: Bool? = nil
    @State private var dragOffset: CGSize = .zero
    @State private var selectedWords: [String] = []
    @State private var availableWords: [String] = []
    @State private var sentenceOrder: [Int] = []
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // Exercise Header
            exerciseHeader
            
            // Exercise Content based on type
            switch question.exerciseType {
            case "sentence_building":
                sentenceBuildingExercise
            case "fill_blank":
                fillInBlankExercise
            case "verb_conjugation":
                verbConjugationExercise
            case "multiple_choice":
                multipleChoiceExercise
            default:
                multipleChoiceExercise
            }
            
            // Action Buttons
            actionButtons
            
            Spacer()
        }
        .padding()
        .onAppear {
            setupExercise()
        }
    }
    
    // MARK: - Exercise Header
    
    private var exerciseHeader: some View {
        VStack(spacing: 8) {
            Text(question.question)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let hint = question.hint, !showingAnswer {
                Text("💡 \(hint)")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Sentence Building Exercise
    
    private var sentenceBuildingExercise: some View {
        VStack(spacing: 16) {
            // Available words area
            VStack(alignment: .leading, spacing: 8) {
                Text("Available Words:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(Array(availableWords.enumerated()), id: \.offset) { index, word in
                        if !selectedWords.contains(word) {
                            Button(action: {
                                selectWord(word)
                            }) {
                                Text(word)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            
            // Selected words area
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Sentence:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if selectedWords.isEmpty {
                    Text("Tap words to build your sentence")
                        .foregroundColor(.secondary)
                        .italic()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                        ForEach(Array(selectedWords.enumerated()), id: \.offset) { index, word in
                            Button(action: {
                                deselectWord(word)
                            }) {
                                HStack {
                                    Text(word)
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.caption)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.2))
                                .foregroundColor(.green)
                                .cornerRadius(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Fill in Blank Exercise
    
    private var fillInBlankExercise: some View {
        VStack(spacing: 16) {
            Text("Fill in the blank:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(question.question.replacingOccurrences(of: "___", with: "_____"))
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            TextField("Your answer", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
                .multilineTextAlignment(.center)
                .disabled(showingAnswer)
        }
    }
    
    // MARK: - Verb Conjugation Exercise
    
    private var verbConjugationExercise: some View {
        VStack(spacing: 16) {
            Text("Conjugate the verb:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(question.question)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            TextField("Your conjugation", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.title3)
                .multilineTextAlignment(.center)
                .disabled(showingAnswer)
        }
    }
    
    // MARK: - Multiple Choice Exercise
    
    private var multipleChoiceExercise: some View {
        VStack(spacing: 12) {
            ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
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
                .disabled(showingAnswer)
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if showingAnswer {
                // Show explanation
                VStack(spacing: 8) {
                    Text(question.explanation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    Button("Continue") {
                        // Handle continue action
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                // Check answer button
                Button("Check Answer") {
                    checkAnswer()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canCheckAnswer)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var canCheckAnswer: Bool {
        switch question.exerciseType {
        case "sentence_building":
            return !selectedWords.isEmpty
        case "fill_blank", "verb_conjugation":
            return !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case "multiple_choice":
            return selectedAnswer != nil
        default:
            return false
        }
    }
    
    private func setupExercise() {
        switch question.exerciseType {
        case "sentence_building":
            // Extract words from question (assuming format: "Build the sentence: 'word1 / word2 / word3'")
            if let range = question.question.range(of: "'") {
                let wordsString = String(question.question[range.upperBound...])
                if let endRange = wordsString.range(of: "'") {
                    let words = String(wordsString[..<endRange.lowerBound])
                    availableWords = words.components(separatedBy: " / ").shuffled()
                }
            }
        default:
            break
        }
    }
    
    private func selectWord(_ word: String) {
        selectedWords.append(word)
    }
    
    private func deselectWord(_ word: String) {
        if let index = selectedWords.firstIndex(of: word) {
            selectedWords.remove(at: index)
        }
    }
    
    private func checkAnswer() {
        let isAnswerCorrect: Bool
        
        switch question.exerciseType {
        case "sentence_building":
            let userSentence = selectedWords.joined(separator: " ")
            isAnswerCorrect = question.options[question.correctAnswer] == userSentence
            
        case "fill_blank", "verb_conjugation":
            let userAnswer = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let correctAnswer = question.options[question.correctAnswer].lowercased()
            isAnswerCorrect = userAnswer == correctAnswer
            
        case "multiple_choice":
            isAnswerCorrect = selectedAnswer == question.correctAnswer
            
        default:
            isAnswerCorrect = false
        }
        
        isCorrect = isAnswerCorrect
        showingAnswer = true
    }
}

// MARK: - Preview

struct AdvancedGrammarExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        AdvancedGrammarExerciseView(question: GrammarQuestionItem(
            id: "test",
            question: "Build the sentence: 'Ik / maken / huiswerk'",
            options: ["Ik maak huiswerk", "Ik maakt huiswerk", "Ik maken huiswerk", "Ik maakte huiswerk"],
            correctAnswer: 0,
            explanation: "Ik maak huiswerk - 'ik' form uses stem only",
            hint: "Arrange the words and conjugate 'maken' for 'ik'",
            difficulty: "medium",
            tags: ["present_tense", "sentence_building", "word_order"],
            exerciseType: "sentence_building"
        ))
    }
} 