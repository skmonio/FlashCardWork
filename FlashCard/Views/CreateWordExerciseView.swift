import SwiftUI

struct CreateWordExerciseView: View {
    @ObservedObject var wordExerciseManager = DutchWordExerciseManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var targetWord = ""
    @State private var wordTranslation = ""
    @State private var selectedCategory: WordCategory = .general
    @State private var selectedDifficulty: ExerciseDifficulty = .medium
    @State private var exercises: [WordExercise] = []
    @State private var showingAddExercise = false
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
                        
                        Text("Create Word Exercise")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Save") {
                            saveWordExercise()
                        }
                        .foregroundColor(canSave ? .blue : .gray)
                        .disabled(!canSave)
                    }
                    .padding(.horizontal)
                    
                    Divider()
                }
                .background(Color(.systemGroupedBackground))
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Basic Information
                        basicInformationSection
                        
                        // Exercises List
                        exercisesSection
                        
                        // Add Exercise Button
                        addExerciseButton
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseView { exercise in
                exercises.append(exercise)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var canSave: Bool {
        !targetWord.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !wordTranslation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !exercises.isEmpty
    }
    
    // MARK: - Basic Information Section
    
    private var basicInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Word Information")
                .font(.headline)
            
            VStack(spacing: 12) {
                // Target Word
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dutch Word")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter Dutch word", text: $targetWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Translation
                VStack(alignment: .leading, spacing: 4) {
                    Text("English Translation")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("Enter English translation", text: $wordTranslation)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                // Category and Difficulty
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Category")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(WordCategory.allCases, id: \.self) { category in
                                Label(category.rawValue, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                    }
                    
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
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Exercises Section
    
    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Exercises (\(exercises.count))")
                    .font(.headline)
                
                Spacer()
                
                if !exercises.isEmpty {
                    Button("Clear All") {
                        exercises.removeAll()
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
            
            if exercises.isEmpty {
                emptyExercisesView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(exercises.enumerated()), id: \.element.id) { index, exercise in
                        ExerciseCard(
                            exercise: exercise,
                            onDelete: {
                                exercises.remove(at: index)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var emptyExercisesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No exercises yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Add exercises to help learn this word")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 20)
    }
    
    // MARK: - Add Exercise Button
    
    private var addExerciseButton: some View {
        Button(action: { showingAddExercise = true }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Add Exercise")
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.blue)
            .cornerRadius(8)
        }
    }
    
    // MARK: - Save Function
    
    private func saveWordExercise() {
        guard canSave else { return }
        
        let trimmedWord = targetWord.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTranslation = wordTranslation.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if word already exists
        if wordExerciseManager.getWordExercise(for: trimmedWord) != nil {
            errorMessage = "A word exercise for '\(trimmedWord)' already exists"
            showingError = true
            return
        }
        
        let wordExercise = DutchWordExercise(
            targetWord: trimmedWord,
            wordTranslation: trimmedTranslation,
            exercises: exercises,
            difficulty: selectedDifficulty,
            category: selectedCategory
        )
        
        wordExerciseManager.addWordExercise(wordExercise)
        dismiss()
    }
}

// MARK: - Supporting Views

struct ExerciseCard: View {
    let exercise: WordExercise
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
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
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(exercise.difficulty.color))
                    .frame(width: 8, height: 8)
                
                Text(exercise.difficulty.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(exercise.options.count) options")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

#Preview {
    CreateWordExerciseView()
} 