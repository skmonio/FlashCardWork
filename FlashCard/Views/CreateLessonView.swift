import SwiftUI

struct CreateLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userLessonManager = UserLessonManager.shared
    
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var questions: [UserQuestion] = []
    
    @State private var showingSuccessAlert = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // Editing mode
    let editingLesson: UserLesson?
    let isEditing: Bool
    
    let questionTypes = [
        "Multiple Choice",
        "Fill in Blank", 
        "Missing Word",
        "Match Meaning",
        "Use in Sentence",
        "Sentence Building",
        "True/False"
    ]
    
    init(editingLesson: UserLesson? = nil) {
        self.editingLesson = editingLesson
        self.isEditing = editingLesson != nil
        
        if let lesson = editingLesson {
            _title = State(initialValue: lesson.title)
            _description = State(initialValue: lesson.description)
            _questions = State(initialValue: lesson.questions)
        } else {
            // Start with one empty question with one empty answer
            let defaultAnswers = [UserAnswer(text: "", isCorrect: true)]
            _questions = State(initialValue: [UserQuestion(questionType: "Multiple Choice", question: "", answers: defaultAnswers, hint: "")])
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                UnifiedHeader(
                    title: isEditing ? "Edit Lesson" : "Create Lesson",
                    showBackButton: true,
                    showProfileIcon: false,
                    onBack: { dismiss() },
                    trailing: {
                        AnyView(
                            Button(action: saveLesson) {
                                Text(isEditing ? "Update" : "Save")
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            .disabled(!isFormValid)
                        )
                    }
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Basic Info Section
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Lesson Information")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                // Title Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Lesson Title")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Enter lesson title", text: $title)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .autocapitalization(.words)
                                }
                                
                                // Description Field
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Short Description")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    TextField("Describe what this lesson teaches", text: $description, axis: .vertical)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .lineLimit(3, reservesSpace: true)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Questions Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Questions (\(questions.count))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: addQuestion) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Question")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            ForEach(questions.indices, id: \.self) { index in
                                questionCard(for: index)
                            }
                        }
                        
                        // Preview Section
                        if isFormValid {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Preview")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.horizontal)
                                
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(title)
                                        .font(.headline)
                                    
                                    Text(description)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    VStack(alignment: .leading, spacing: 12) {
                                        ForEach(questions.indices, id: \.self) { index in
                                            let question = questions[index]
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("Question \(index + 1):")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.secondary)
                                                
                                                Text(question.question)
                                                    .font(.body)
                                                
                                                if question.isSentenceBuilding {
                                                    // Show ordered sentence for sentence building
                                                    Text("Correct sentence: \(question.correctAnswer)")
                                                        .font(.body)
                                                        .foregroundColor(.green)
                                                    
                                                    Text("Words to arrange: \(question.answers.map { $0.text }.filter { !$0.isEmpty }.joined(separator: ", "))")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                } else {
                                                    // Show answer options for other types
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        ForEach(question.answers, id: \.id) { answer in
                                                            HStack {
                                                                Image(systemName: answer.isCorrect ? "checkmark.circle.fill" : "circle")
                                                                    .foregroundColor(answer.isCorrect ? .green : .gray)
                                                                    .font(.caption)
                                                                Text(answer.text)
                                                                    .font(.body)
                                                                    .foregroundColor(answer.isCorrect ? .green : .primary)
                                                            }
                                                        }
                                                    }
                                                }
                                                
                                                if !question.hint.isEmpty {
                                                    Text("Hint: \(question.hint)")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                                
                                                Text("Type: \(question.questionType)")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.vertical, 4)
                                            
                                            if index < questions.count - 1 {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                // Ensure editing state is properly loaded when view appears
                if let editingLesson = editingLesson, isEditing {
                    title = editingLesson.title
                    description = editingLesson.description
                    questions = editingLesson.questions
                }
            }
            .alert("Success!", isPresented: $showingSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text(isEditing ? "Your lesson has been updated successfully!" : "Your lesson has been created successfully!")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func questionCard(for index: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Question \(index + 1)")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if questions.count > 1 {
                    Button(action: {
                        removeQuestion(at: index)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(6)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Question Type Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Question Type")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Picker("Question Type", selection: Binding(
                        get: { questions[index].questionType },
                        set: { newType in
                            let oldType = questions[index].questionType
                            questions[index].questionType = newType
                            
                            // Handle conversion between sentence building and other types
                            if oldType.lowercased() != "sentence building" && newType.lowercased() == "sentence building" {
                                // Converting TO sentence building - set order indices
                                for i in 0..<questions[index].answers.count {
                                    questions[index].answers[i].orderIndex = i
                                    questions[index].answers[i].isCorrect = false // Not used for sentence building
                                }
                            } else if oldType.lowercased() == "sentence building" && newType.lowercased() != "sentence building" {
                                // Converting FROM sentence building - clear order indices and set first as correct
                                for i in 0..<questions[index].answers.count {
                                    questions[index].answers[i].orderIndex = nil
                                    questions[index].answers[i].isCorrect = (i == 0) // Make first answer correct
                                }
                            }
                        }
                    )) {
                        ForEach(questionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Question Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Question")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your question", text: Binding(
                        get: { questions[index].question },
                        set: { questions[index].question = $0 }
                    ), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3, reservesSpace: true)
                }
                
                // Answer Options Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(questions[index].isSentenceBuilding ? "Words/Phrases (in order)" : "Answer Options")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Button(action: {
                            addAnswer(to: index)
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.caption)
                                Text(questions[index].isSentenceBuilding ? "Add Word" : "Add Answer")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if questions[index].isSentenceBuilding {
                        // Sentence Building Interface
                        sentenceBuildingInterface(for: index)
                    } else {
                        // Regular Multiple Choice Interface
                        regularAnswersInterface(for: index)
                    }
                    
                    Text(questions[index].isSentenceBuilding ? 
                         "Use arrows to reorder words. The sentence will be: \(getOrderedSentence(for: index))" :
                         "Tap the circle to mark correct answers")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .italic()
                }
                
                // Hint Field (Optional)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hint (Optional)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    TextField("Enter a helpful hint", text: Binding(
                        get: { questions[index].hint },
                        set: { questions[index].hint = $0 }
                    ), axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(2, reservesSpace: true)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func sentenceBuildingInterface(for index: Int) -> some View {
        VStack(spacing: 8) {
            ForEach(questions[index].answers.indices, id: \.self) { answerIndex in
                HStack(spacing: 8) {
                    // Order number
                    Text("\(answerIndex + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    
                    // Text field for the word/phrase
                    TextField("Enter word or phrase", text: Binding(
                        get: { questions[index].answers[answerIndex].text },
                        set: { 
                            questions[index].answers[answerIndex].text = $0
                            // Update order index to match current position
                            questions[index].answers[answerIndex].orderIndex = answerIndex
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Reorder buttons
                    VStack(spacing: 2) {
                        Button(action: {
                            moveAnswerUp(questionIndex: index, answerIndex: answerIndex)
                        }) {
                            Image(systemName: "chevron.up")
                                .font(.caption2)
                                .foregroundColor(answerIndex > 0 ? .blue : .gray)
                        }
                        .disabled(answerIndex == 0)
                        
                        Button(action: {
                            moveAnswerDown(questionIndex: index, answerIndex: answerIndex)
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .foregroundColor(answerIndex < questions[index].answers.count - 1 ? .blue : .gray)
                        }
                        .disabled(answerIndex == questions[index].answers.count - 1)
                    }
                    
                    // Delete button
                    if questions[index].answers.count > 1 {
                        Button(action: {
                            removeAnswer(questionIndex: index, answerIndex: answerIndex)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(4)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
    }
    
    private func regularAnswersInterface(for index: Int) -> some View {
        VStack(spacing: 8) {
            ForEach(questions[index].answers.indices, id: \.self) { answerIndex in
                HStack(spacing: 8) {
                    Button(action: {
                        toggleCorrectAnswer(questionIndex: index, answerIndex: answerIndex)
                    }) {
                        Image(systemName: questions[index].answers[answerIndex].isCorrect ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(questions[index].answers[answerIndex].isCorrect ? .green : .gray)
                            .font(.title3)
                    }
                    
                    TextField("Enter answer option", text: Binding(
                        get: { questions[index].answers[answerIndex].text },
                        set: { questions[index].answers[answerIndex].text = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if questions[index].answers.count > 1 {
                        Button(action: {
                            removeAnswer(questionIndex: index, answerIndex: answerIndex)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(4)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
    }
    
    private func getOrderedSentence(for index: Int) -> String {
        let words = questions[index].answers.map { $0.text }.filter { !$0.isEmpty }
        return words.joined(separator: " ")
    }
    
    private var isFormValid: Bool {
        let hasBasicInfo = !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                          !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let hasValidQuestions = !questions.isEmpty && questions.allSatisfy { question in
            let hasQuestion = !question.question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            if question.isSentenceBuilding {
                // For sentence building, just need non-empty words
                let hasValidWords = !question.answers.isEmpty && 
                                  question.answers.allSatisfy { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                return hasQuestion && hasValidWords
            } else {
                // For other types, need at least one correct answer
                let hasValidAnswers = !question.answers.isEmpty && 
                                    question.answers.allSatisfy { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty } &&
                                    question.answers.contains { $0.isCorrect }
                return hasQuestion && hasValidAnswers
            }
        }
        
        return hasBasicInfo && hasValidQuestions
    }
    
    private func addQuestion() {
        let defaultAnswers = [UserAnswer(text: "", isCorrect: true)]
        questions.append(UserQuestion(questionType: "Multiple Choice", question: "", answers: defaultAnswers, hint: ""))
    }
    
    private func removeQuestion(at index: Int) {
        guard questions.count > 1 else { return } // Don't allow removing the last question
        questions.remove(at: index)
    }
    
    private func addAnswer(to questionIndex: Int) {
        if questions[questionIndex].isSentenceBuilding {
            // For sentence building, add word with next order index
            let nextOrderIndex = questions[questionIndex].answers.count
            questions[questionIndex].answers.append(UserAnswer(text: "", isCorrect: false, orderIndex: nextOrderIndex))
        } else {
            // For regular questions, add as incorrect by default
            questions[questionIndex].answers.append(UserAnswer(text: "", isCorrect: false))
        }
    }
    
    private func removeAnswer(questionIndex: Int, answerIndex: Int) {
        guard questions[questionIndex].answers.count > 1 else { return } // Keep at least one answer
        
        let wasCorrect = questions[questionIndex].answers[answerIndex].isCorrect
        questions[questionIndex].answers.remove(at: answerIndex)
        
        // For sentence building, update order indices
        if questions[questionIndex].isSentenceBuilding {
            for i in 0..<questions[questionIndex].answers.count {
                questions[questionIndex].answers[i].orderIndex = i
            }
        } else {
            // If we removed the only correct answer, make the first remaining answer correct
            if wasCorrect && !questions[questionIndex].answers.contains(where: { $0.isCorrect }) {
                if !questions[questionIndex].answers.isEmpty {
                    questions[questionIndex].answers[0].isCorrect = true
                }
            }
        }
    }
    
    private func moveAnswerUp(questionIndex: Int, answerIndex: Int) {
        guard answerIndex > 0 else { return }
        
        // Swap with previous item
        questions[questionIndex].answers.swapAt(answerIndex, answerIndex - 1)
        
        // Update order indices
        for i in 0..<questions[questionIndex].answers.count {
            questions[questionIndex].answers[i].orderIndex = i
        }
    }
    
    private func moveAnswerDown(questionIndex: Int, answerIndex: Int) {
        guard answerIndex < questions[questionIndex].answers.count - 1 else { return }
        
        // Swap with next item
        questions[questionIndex].answers.swapAt(answerIndex, answerIndex + 1)
        
        // Update order indices
        for i in 0..<questions[questionIndex].answers.count {
            questions[questionIndex].answers[i].orderIndex = i
        }
    }
    
    private func toggleCorrectAnswer(questionIndex: Int, answerIndex: Int) {
        questions[questionIndex].answers[answerIndex].isCorrect.toggle()
        
        // Ensure at least one answer is always marked as correct (for non-sentence building)
        if !questions[questionIndex].isSentenceBuilding && !questions[questionIndex].answers.contains(where: { $0.isCorrect }) {
            questions[questionIndex].answers[answerIndex].isCorrect = true
        }
    }
    
    private func saveLesson() {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields for the lesson title, description, questions, and at least one correct answer for each question"
            showingErrorAlert = true
            return
        }
        
        // Clean up the questions and answers
        let cleanedQuestions = questions.map { question in
            var cleaned = question
            cleaned.question = question.question.trimmingCharacters(in: .whitespacesAndNewlines)
            cleaned.hint = question.hint.trimmingCharacters(in: .whitespacesAndNewlines)
            cleaned.answers = question.answers.map { answer in
                var cleanedAnswer = answer
                cleanedAnswer.text = answer.text.trimmingCharacters(in: .whitespacesAndNewlines)
                return cleanedAnswer
            }.filter { !$0.text.isEmpty } // Remove empty answers
            
            if cleaned.isSentenceBuilding {
                // For sentence building, ensure order indices are properly set
                for i in 0..<cleaned.answers.count {
                    cleaned.answers[i].orderIndex = i
                    cleaned.answers[i].isCorrect = false // Not used for sentence building
                }
            } else {
                // Ensure at least one answer is marked as correct for non-sentence building
                if !cleaned.answers.contains(where: { $0.isCorrect }) && !cleaned.answers.isEmpty {
                    cleaned.answers[0].isCorrect = true
                }
                // Clear order indices for non-sentence building
                for i in 0..<cleaned.answers.count {
                    cleaned.answers[i].orderIndex = nil
                }
            }
            
            return cleaned
        }
        
        if isEditing, let existingLesson = editingLesson {
            // Update existing lesson
            var updatedLesson = existingLesson
            updatedLesson.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedLesson.description = description.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedLesson.questions = cleanedQuestions
            
            userLessonManager.updateLesson(updatedLesson)
        } else {
            // Create new lesson
            let newLesson = UserLesson(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                questions: cleanedQuestions
            )
            
            userLessonManager.addLesson(newLesson)
        }
        
        showingSuccessAlert = true
    }
}

struct CreateLessonView_Previews: PreviewProvider {
    static var previews: some View {
        CreateLessonView()
    }
} 