import SwiftUI

struct LessonsListView: View {
    @ObservedObject var lessonManager = LessonManager.shared
    @ObservedObject var analyticsManager = LessonAnalyticsManager.shared
    @ObservedObject var pathManager = LearningPathManager.shared
    @State private var completedLessons: [UUID: Int] = [:] // lessonId: bestScore
    let viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: FlashCardViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Unified Header
            UnifiedHeader(
                title: "Dutch Lessons",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // Continue Lesson Section (if there's a saved state)
                    if SaveStateManager.shared.hasSaveState(gameType: .lesson) {
                        continueLessonSection
                    }
                    
                    // Learning Path Section
                    learningPathSection
                    
                    // Regular Lessons Section
                    regularLessonsSection
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
    }
    
    private var learningPathSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Learning Path")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                if let path = pathManager.currentPath {
                    Text("\(Int(path.progressPercentage * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            NavigationLink(destination: LearningPathView(viewModel: viewModel)) {
                HStack {
                    Image(systemName: "map.fill")
                        .font(.title2)
                        .foregroundColor(.purple)
                        .frame(width: 30)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Chapter 3: Communication Mastery")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("NEW")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(4)
                        }
                        
                        Text("Master Dutch communication skills from basic to advanced levels")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        if let path = pathManager.currentPath {
                            HStack {
                                ProgressView(value: path.progressPercentage)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                    .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                
                                Text("\(path.completedLessons)/\(path.totalLessons) lessons")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.1), Color.blue.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private var regularLessonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Individual Lessons")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVStack(spacing: 12) {
                ForEach(lessonManager.lessons.filter { $0.title != "Chapter 3.5 – Dutch Vocabulary in Context" }) { lesson in
                    NavigationLink(destination: LessonDetailView(lesson: lesson, completedLessons: $completedLessons, viewModel: viewModel, shouldLoadSaveState: SaveStateManager.shared.hasSaveState(gameType: .lesson))) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(lesson.title)
                                    .font(.headline)
                                Text(lesson.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                let bestScore = analyticsManager.getBestScoreForLesson(lesson.id)
                                if bestScore > 0 {
                                    HStack {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(.green)
                                        Text("\(bestScore)%")
                                            .font(.caption)
                                            .foregroundColor(.green)
                                    }
                                }
                                let attempts = analyticsManager.getAnalyticsForLesson(lesson.id)
                                if !attempts.isEmpty {
                                    Text("\(attempts.count) attempts")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
    
    private var continueLessonSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Continue Lesson")
                .font(.title2)
                .fontWeight(.bold)
            
            if let savedState = SaveStateManager.shared.loadGameState(gameType: .lesson, as: LessonGameState.self),
               let lesson = lessonManager.lesson(withId: savedState.lessonId) {
                NavigationLink(destination: LessonDetailView(lesson: lesson, completedLessons: $completedLessons, viewModel: viewModel, shouldLoadSaveState: true)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "graduationcap.fill")
                                    .foregroundColor(.blue)
                                Text(savedState.lessonTitle)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                            }
                            
                            HStack {
                                Text("Progress: \(savedState.currentExerciseIndex + 1)/\(savedState.shuffledExercises.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text("Score: \(savedState.correctCount)/\(savedState.shuffledExercises.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.green)
                            }
                            
                            if let savedAt = SaveStateManager.shared.getSaveStateInfo(gameType: .lesson) {
                                Text("Saved \(timeAgoString(from: savedAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

struct LessonDetailView: View {
    let lesson: Lesson
    @Binding var completedLessons: [UUID: Int]
    let viewModel: FlashCardViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var navigationCoordinator: NavigationCoordinator
    @ObservedObject var analyticsManager = LessonAnalyticsManager.shared
    
    @State private var started = false
    @State private var finished = false
    @State private var reviewMode = false
    @State private var currentExerciseIndex = 0
    @State private var selectedAnswer: String?
    @State private var showFeedback = false
    @State private var correctCount = 0
    @State private var userAnswers: [Int: String] = [:]
    @State private var userWords: Set<String> = []
    @State private var lessonStartTime: Date?
    @State private var exerciseStartTime: Date?
    @State private var exerciseAttempts: [ExerciseAttempt] = []
    @State private var showingExitConfirmation = false

    // New: Shuffled exercises and options
    @State private var shuffledExercises: [(exercise: Exercise, shuffledOptions: [String], correctIndex: Int)] = []
    
    // Save state properties
    private var shouldLoadSaveState: Bool = false
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        return started && !finished && (currentExerciseIndex > 0 || !userAnswers.isEmpty)
    }

    var filteredExercises: [Exercise] {
        lesson.exercises
    }
    
    // Count of completed questions (questions that have been answered)
    var completedQuestions: Int {
        userAnswers.count
    }
    
    init(lesson: Lesson, completedLessons: Binding<[UUID: Int]>, viewModel: FlashCardViewModel, shouldLoadSaveState: Bool = false) {
        self.lesson = lesson
        self._completedLessons = completedLessons
        self.viewModel = viewModel
        self.shouldLoadSaveState = shouldLoadSaveState
    }
    
    var body: some View {
        VStack(spacing: 0) {
            UnifiedHeader(
                title: "Chapter 3.5",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { 
                    if started && !finished {
                        showingExitConfirmation = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !started {
                        // Lesson intro
                        Text(lesson.description)
                        if !lesson.vocabulary.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Vocabulary:")
                                    .font(.headline)
                                // Clickable words
                                WrapHStack(words: lesson.vocabulary, userWords: userWords, onTap: { word in
                                    // Navigate to AddCardView with pre-filled word
                                    navigationCoordinator.presentSheet(.addCard(initialWord: word))
                                })
                            }
                        }
                        Spacer()
                        Button(action: {
                            started = true
                            currentExerciseIndex = 0
                            correctCount = 0
                            finished = false
                            userAnswers = [:]
                            // Start analytics tracking
                            lessonStartTime = analyticsManager.startLessonTracking(lessonId: lesson.id, lessonTitle: lesson.title)
                            exerciseStartTime = Date()
                            exerciseAttempts = []
                            // Shuffle exercises and options
                            shuffledExercises = lesson.exercises.shuffled().map { ex in
                                let shuffled = ex.options.shuffled()
                                let correctIdx = shuffled.firstIndex(of: ex.correctAnswer) ?? 0
                                return (exercise: ex, shuffledOptions: shuffled, correctIndex: correctIdx)
                            }
                        }) {
                            Text("Start Lesson")
                                .font(.title2)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.bottom)
                    } else if finished {
                        // End screen with review option
                        VStack(spacing: 16) {
                            Text("Lesson Complete!")
                                .font(.title)
                                .bold()
                            Text("You answered \(correctCount) out of \(shuffledExercises.count) correctly.")
                                .font(.headline)
                            Button("Back to Lessons") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                            Button("Review Lesson") {
                                // Just go back to the last question and let them navigate normally
                                finished = false
                                currentExerciseIndex = shuffledExercises.count - 1
                                selectedAnswer = userAnswers[currentExerciseIndex]
                                showFeedback = true // Show feedback immediately in review
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        Spacer()
                    } else if reviewMode {
                        // Remove this entire section - no longer needed
                        EmptyView()
                    } else if !shuffledExercises.isEmpty {
                        // Game-style progress bar
                        LessonProgressBar(completedQuestions: currentExerciseIndex + 1, total: shuffledExercises.count)
                            .padding(.bottom, 8)
                        // Exercise flow
                        let tuple = shuffledExercises[currentExerciseIndex]
                        let exercise = tuple.exercise
                        let options = tuple.shuffledOptions
                        let correctIdx = tuple.correctIndex
                        VStack(alignment: .leading, spacing: 16) {
                            // Custom UI per exercise type
                                Text(exercise.prompt)
                                    .font(.title2)
                                    .bold()
                            ForEach(options, id: \.self) { option in
                                    Button(action: {
                                        if !showFeedback {
                                            selectedAnswer = option
                                            showFeedback = true
                                            userAnswers[currentExerciseIndex] = option
                                        if let idx = options.firstIndex(of: option), idx == correctIdx {
                                                correctCount += 1
                                            }
                                            // Record exercise attempt
                                            recordExerciseAttempt(exercise: exercise, userAnswer: option)
                                        }
                                    }) {
                                        HStack {
                                            Text(option)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                            Spacer()
                                            if showFeedback {
                                            if let idx = options.firstIndex(of: option), idx == correctIdx {
                                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                            } else if option == selectedAnswer && options.firstIndex(of: option) != correctIdx {
                                                    Image(systemName: "xmark.circle.fill").foregroundColor(.red)
                                                }
                                            }
                                        }
                                        .padding()
                                        .background(
                                            showFeedback ?
                                            ((options.firstIndex(of: option) == correctIdx) ? Color.green.opacity(0.15) :
                                                    (option == selectedAnswer ? Color.red.opacity(0.15) : Color(.systemGray6))) :
                                                Color(.systemGray6)
                                        )
                                        .cornerRadius(8)
                                    }
                                    .disabled(showFeedback)
                            }
                            if showFeedback {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(exercise.explanation)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    // Navigation buttons (Previous and Next/Finish)
                                    HStack(spacing: 12) {
                                        Button("Previous") {
                                            if currentExerciseIndex > 0 {
                                                currentExerciseIndex -= 1
                                                selectedAnswer = userAnswers[currentExerciseIndex]
                                                showFeedback = userAnswers[currentExerciseIndex] != nil
                                            }
                                        }
                                        .disabled(currentExerciseIndex == 0)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(currentExerciseIndex == 0 ? Color.gray.opacity(0.3) : Color.gray.opacity(0.2))
                                        .foregroundColor(currentExerciseIndex == 0 ? .gray : .blue)
                                        .cornerRadius(8)
                                        Button(currentExerciseIndex < shuffledExercises.count - 1 ? "Next" : "Finish Lesson") {
                                            if currentExerciseIndex < shuffledExercises.count - 1 {
                                                currentExerciseIndex += 1
                                                selectedAnswer = userAnswers[currentExerciseIndex]
                                                showFeedback = userAnswers[currentExerciseIndex] != nil
                                            } else {
                                                finished = true
                                                // Clear saved progress since lesson is complete
                                                clearSavedProgress()
                                                // Save progress
                                                let percent = Int((Double(correctCount) / Double(shuffledExercises.count)) * 100)
                                                let prev = completedLessons[lesson.id] ?? 0
                                                if percent > prev { completedLessons[lesson.id] = percent }
                                                // Record lesson completion analytics
                                                if let startTime = lessonStartTime {
                                                    analyticsManager.recordLessonCompletion(
                                                        lessonId: lesson.id,
                                                        lessonTitle: lesson.title,
                                                        startTime: startTime,
                                                        totalExercises: shuffledExercises.count,
                                                        correctAnswers: correctCount,
                                                        exerciseAttempts: exerciseAttempts
                                                    )
                                                }
                                            }
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.top)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .alert("Exit Lesson?", isPresented: $showingExitConfirmation) {
            Button("Save & Exit", role: .destructive) {
                saveProgressAndDismiss()
            }
            Button("Exit Without Saving") {
                clearSavedProgress()
                presentationMode.wrappedValue.dismiss()
            }
            Button("Continue Lesson", role: .cancel) { }
        } message: {
            Text(hasSignificantProgress ? 
                "Would you like to save your progress?" : 
                "Are you sure you want to exit?")
        }
        .onAppear {
            if shouldLoadSaveState {
                loadSavedProgress()
            }
        }
        .onDisappear {
            // Auto-save when view disappears
            if hasSignificantProgress && !finished {
                saveCurrentProgress()
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func recordExerciseAttempt(exercise: Exercise, userAnswer: String) {
        guard let startTime = exerciseStartTime else { return }
        let timeSpent = Date().timeIntervalSince(startTime)
        
        let attempt = ExerciseAttempt(
            exerciseId: exercise.id,
            exerciseType: exercise.type.rawValue,
            prompt: exercise.prompt,
            userAnswer: userAnswer,
            correctAnswer: exercise.correctAnswer,
            timeSpent: timeSpent,
            vocabularyWord: exercise.vocabularyReference
        )
        
        exerciseAttempts.append(attempt)
        exerciseStartTime = Date() // Reset for next exercise
    }
    
    // MARK: - Save/Restore Methods
    
    private func saveCurrentProgress() {
        guard hasSignificantProgress else { return }
        
        let savedExercises = shuffledExercises.map { tuple in
            LessonGameState.SavedExercise(
                exerciseId: tuple.exercise.id,
                prompt: tuple.exercise.prompt,
                shuffledOptions: tuple.shuffledOptions,
                correctIndex: tuple.correctIndex,
                correctAnswer: tuple.exercise.correctAnswer,
                explanation: tuple.exercise.explanation,
                vocabularyReference: tuple.exercise.vocabularyReference
            )
        }
        
        let gameState = LessonGameState(
            lessonId: lesson.id,
            lessonTitle: lesson.title,
            currentExerciseIndex: currentExerciseIndex,
            correctCount: correctCount,
            userAnswers: userAnswers,
            shuffledExercises: savedExercises,
            lessonStartTime: lessonStartTime,
            exerciseAttempts: exerciseAttempts
        )
        
        SaveStateManager.shared.saveGameState(
            gameType: .lesson,
            gameData: gameState
        )
        
        print("📚 Lesson progress saved - Index: \(currentExerciseIndex), Score: \(correctCount)/\(shuffledExercises.count)")
    }
    
    private func loadSavedProgress() {
        if let savedState = SaveStateManager.shared.loadGameState(
            gameType: .lesson,
            as: LessonGameState.self
        ) {
            // Only load if it's the same lesson
            guard savedState.lessonId == lesson.id else {
                print("📚 Saved lesson ID doesn't match current lesson, starting fresh")
                return
            }
            
            // Restore state
            started = true
            currentExerciseIndex = savedState.currentExerciseIndex
            correctCount = savedState.correctCount
            userAnswers = savedState.userAnswers
            lessonStartTime = savedState.lessonStartTime
            exerciseAttempts = savedState.exerciseAttempts
            
            // Restore shuffled exercises
            shuffledExercises = savedState.shuffledExercises.map { savedExercise in
                // Find the original exercise
                let originalExercise = lesson.exercises.first { $0.id == savedExercise.exerciseId }
                return (
                    exercise: originalExercise ?? Exercise(
                        type: .fillInBlank,
                        prompt: savedExercise.prompt,
                        options: savedExercise.shuffledOptions,
                        correctAnswer: savedExercise.correctAnswer,
                        explanation: savedExercise.explanation,
                        vocabularyReference: savedExercise.vocabularyReference
                    ),
                    shuffledOptions: savedExercise.shuffledOptions,
                    correctIndex: savedExercise.correctIndex
                )
            }
            
            // Restore current exercise state
            if let currentAnswer = userAnswers[currentExerciseIndex] {
                selectedAnswer = currentAnswer
                showFeedback = true
            }
            
            print("📚 Lesson progress loaded - Index: \(currentExerciseIndex), Score: \(correctCount)/\(shuffledExercises.count)")
            HapticManager.shared.successNotification()
        } else {
            // No saved state found, start normally
            print("📚 No saved state found, starting fresh lesson")
        }
    }
    
    private func clearSavedProgress() {
        SaveStateManager.shared.deleteSaveState(gameType: .lesson)
    }
    
    private func saveProgressAndDismiss() {
        if hasSignificantProgress && !finished {
            saveCurrentProgress()
        }
        presentationMode.wrappedValue.dismiss()
    }
}

// Helper for wrapping vocab words
struct WrapHStack: View {
    let words: [String]
    let userWords: Set<String>
    let onTap: (String) -> Void
    
    private var lines: [[String]] {
        var result: [[String]] = [[]]
        var currentLineWidth: CGFloat = 0
        let maxWidth: CGFloat = UIScreen.main.bounds.width - 60
        
        for word in words {
            let wordWidth = word.widthOfString(usingFont: .systemFont(ofSize: 16)) + 32
            if currentLineWidth + wordWidth > maxWidth {
                result.append([word])
                currentLineWidth = wordWidth
            } else {
                result[result.count - 1].append(word)
                currentLineWidth += wordWidth
            }
        }
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                HStack(spacing: 8) {
                    ForEach(line, id: \.self) { word in
                        if userWords.contains(word.lowercased()) {
                            HStack {
                                Text(word)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                            .padding(6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        } else {
                            Button(action: { onTap(word) }) {
                                HStack {
                                    Text(word)
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                                .foregroundColor(.blue)
                                .padding(6)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
}

// Helper for string width
extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
} 