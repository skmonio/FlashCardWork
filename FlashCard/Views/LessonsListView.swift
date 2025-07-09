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
                ForEach(lessonManager.lessons) { lesson in
                    NavigationLink(destination: LessonDetailView(lesson: lesson, completedLessons: $completedLessons, viewModel: viewModel, shouldLoadSaveState: SaveStateManager.shared.hasSaveState(gameType: .lesson))) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(lesson.title)
                                        .font(.headline)
                                    Spacer()
                                    let bestScore = analyticsManager.getBestScoreForLesson(lesson.id)
                                    let hasSaveState = SaveStateManager.shared.hasSaveState(gameType: .lesson)
                                    
                                    if bestScore >= 100 {
                                        Text("Complete")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 2)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    } else if hasSaveState && bestScore == 0 {
                                        // Check if this specific lesson has a save state
                                        if let savedState = SaveStateManager.shared.loadGameState(gameType: .lesson, as: LessonGameState.self),
                                           savedState.lessonId == lesson.id {
                                            Text("In Progress")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 2)
                                                .background(Color.orange)
                                                .cornerRadius(8)
                                        }
                                    }
                                }
                                Text(lesson.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                // Progress indicator
                                let bestScore = analyticsManager.getBestScoreForLesson(lesson.id)
                                let hasSaveState = SaveStateManager.shared.hasSaveState(gameType: .lesson)
                                if bestScore > 0 {
                                    HStack {
                                        ProgressView(value: Double(bestScore) / 100.0)
                                            .progressViewStyle(LinearProgressViewStyle(tint: bestScore >= 100 ? .green : .blue))
                                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                        
                                        Text("\(bestScore)%")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(bestScore >= 100 ? .green : .blue)
                                    }
                                } else if hasSaveState {
                                    // Check if this specific lesson has a save state
                                    if let savedState = SaveStateManager.shared.loadGameState(gameType: .lesson, as: LessonGameState.self),
                                       savedState.lessonId == lesson.id {
                                        HStack {
                                            ProgressView(value: Double(savedState.currentExerciseIndex) / Double(savedState.shuffledExercises.count))
                                                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                                .scaleEffect(x: 1, y: 1.5, anchor: .center)
                                            
                                            Text("\(savedState.currentExerciseIndex)/\(savedState.shuffledExercises.count)")
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.orange)
                                        }
                                    }
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                let bestScore = analyticsManager.getBestScoreForLesson(lesson.id)
                                let hasSaveState = SaveStateManager.shared.hasSaveState(gameType: .lesson)
                                if bestScore > 0 {
                                    HStack {
                                        Image(systemName: bestScore >= 100 ? "checkmark.circle.fill" : "circle.fill")
                                            .foregroundColor(bestScore >= 100 ? .green : .blue)
                                        Text("\(bestScore)%")
                                            .font(.caption)
                                            .foregroundColor(bestScore >= 100 ? .green : .blue)
                                    }
                                } else if hasSaveState {
                                    // Check if this specific lesson has a save state
                                    if let savedState = SaveStateManager.shared.loadGameState(gameType: .lesson, as: LessonGameState.self),
                                       savedState.lessonId == lesson.id {
                                        HStack {
                                            Image(systemName: "clock.fill")
                                                .foregroundColor(.orange)
                                            Text("In Progress")
                                                .font(.caption)
                                                .foregroundColor(.orange)
                                        }
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
    @State private var selectedAnswer: String = ""
    @State private var showFeedback: Bool = false
    @State private var correctCount = 0
    @State private var userAnswers: [Int: String] = [:]
    @State private var lessonStartTime: Date?
    @State private var exerciseStartTime: Date?
    @State private var exerciseAttempts: [ExerciseAttempt] = []
    @State private var showingExitConfirmation = false
    @State private var vocabularyExpanded = false
    @State private var isInReviewMode = false
    @State private var selectedWords: [String] = []
    @State private var availableWords: [String] = []

    // New: Shuffled exercises and options
    @State private var shuffledExercises: [(exercise: Exercise, shuffledOptions: [String], correctIndex: Int)] = []
    
    // Save state properties
    private var shouldLoadSaveState: Bool = false
    
    // Computed property to check if there's significant progress to save
    private var hasSignificantProgress: Bool {
        // Don't consider review mode as significant progress that needs saving
        return started && !finished && !isInReviewMode && (currentExerciseIndex > 0 || !userAnswers.isEmpty)
    }
    
    // Computed property to get user's existing words
    private var userWords: Set<String> {
        Set(viewModel.flashCards.map { $0.word.lowercased() })
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
                title: lesson.title,
                showBackButton: true,
                showProfileIcon: false,
                onBack: { 
                    // Don't show exit confirmation if lesson is complete and we're just reviewing
                    if started && !finished && !isInReviewMode {
                        showingExitConfirmation = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if !started {
                        lessonIntroView
                    } else if finished {
                        lessonCompleteView
                    } else if reviewMode {
                        // Remove this entire section - no longer needed
                        EmptyView()
                    } else if !shuffledExercises.isEmpty {
                        lessonExerciseView
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
    
    // MARK: - Sub-Views
    
    private var lessonIntroView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(lesson.description)
            
            if !lesson.vocabulary.isEmpty {
                vocabularySection
            }
            
            Spacer()
            
            Button(action: {
                HapticManager.shared.buttonTap()
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
                print("📚 Started lesson with \(shuffledExercises.count) exercises")
                for (index, tuple) in shuffledExercises.enumerated() {
                    print("📚 Exercise \(index): \(tuple.exercise.prompt)")
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
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom)
        }
    }
    
    private var vocabularySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    vocabularyExpanded.toggle()
                }
                HapticManager.shared.buttonTap()
            }) {
                HStack {
                    Text("Vocabulary (\(lesson.vocabulary.count) words)")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: vocabularyExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(PlainButtonStyle())
            
            if vocabularyExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    // Clickable words with translations
                    WrapHStack(vocabularyItems: lesson.vocabulary, userWords: userWords, onTap: { vocabularyItem in
                        // Navigate to AddCardView with pre-filled word and translation
                        navigationCoordinator.presentSheet(.addCard(initialWord: vocabularyItem.dutchWord, initialDefinition: vocabularyItem.translation))
                    })
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
    
    private var lessonCompleteView: some View {
        VStack(spacing: 16) {
            Text("Lesson Complete!")
                .font(.title)
                .bold()
            Text("You answered \(correctCount) out of \(shuffledExercises.count) correctly.")
                .font(.headline)
            Button(action: {
                HapticManager.shared.buttonTap()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Back to Lessons")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                HapticManager.shared.buttonTap()
                // Just go back to the last question and let them navigate normally
                finished = false
                isInReviewMode = true // Set review mode flag
                currentExerciseIndex = shuffledExercises.count - 1
                selectedAnswer = userAnswers[currentExerciseIndex] ?? ""
                showFeedback = true // Show feedback immediately in review
            }) {
                Text("Review Lesson")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var lessonExerciseView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Game-style progress bar
            LessonProgressBar(completedQuestions: currentExerciseIndex + 1, total: shuffledExercises.count)
                .padding(.bottom, 8)
            
            // Exercise flow
            let tuple = shuffledExercises[currentExerciseIndex]
            let exercise = tuple.exercise
            let options = tuple.shuffledOptions
            let correctIdx = tuple.correctIndex
            
            Text(exercise.prompt)
                .font(.title2)
                .bold()
            
            if exercise.type == .sentenceBuilding {
                // Sentence Building UI
                sentenceBuildingView(exercise: exercise, options: options, correctIdx: correctIdx)
                    .id("sentence-building-\(currentExerciseIndex)") // Force view recreation when exercise changes
                    .onAppear {
                        // Initialize sentence building state if not already done
                        if availableWords.isEmpty {
                            availableWords = options.shuffled()
                            print("📚 Initialized sentence building for exercise \(currentExerciseIndex): \(exercise.prompt)")
                        }
                    }
            } else {
                // Standard multiple choice UI
                multipleChoiceView(exercise: exercise, options: options, correctIdx: correctIdx)
            }
            
            if showFeedback {
                feedbackView(exercise: exercise)
            }
            
            Spacer()
        }
        .onAppear {
            print("📚 Displaying exercise \(currentExerciseIndex): \(shuffledExercises[currentExerciseIndex].exercise.prompt)")
        }
    }
    
    private func multipleChoiceView(exercise: Exercise, options: [String], correctIdx: Int) -> some View {
        VStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                Button(action: {
                    if !showFeedback {
                        // Immediate haptic feedback for responsiveness
                        HapticManager.shared.buttonTap()
                        
                        selectedAnswer = option
                        showFeedback = true
                        userAnswers[currentExerciseIndex] = option
                        
                        // Check if answer is correct
                        if let idx = options.firstIndex(of: option), idx == correctIdx {
                            correctCount += 1
                            // Success feedback for correct answer
                            HapticManager.shared.successNotification()
                        } else {
                            // Error feedback for incorrect answer
                            HapticManager.shared.errorNotification()
                        }
                        
                        // Record exercise attempt (async to avoid blocking UI)
                        DispatchQueue.main.async {
                            recordExerciseAttempt(exercise: exercise, userAnswer: option)
                        }
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
        }
    }
    
    private func feedbackView(exercise: Exercise) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.explanation)
                .font(.body)
                .foregroundColor(.secondary)
            
            // Navigation buttons (Previous and Next/Finish)
            HStack(spacing: 12) {
                Button(action: {
                    HapticManager.shared.buttonTap()
                    if currentExerciseIndex > 0 {
                        currentExerciseIndex -= 1
                        selectedAnswer = userAnswers[currentExerciseIndex] ?? ""
                        showFeedback = userAnswers[currentExerciseIndex] != nil
                        // Restore sentence building state for previous exercise
                        restoreSentenceBuildingState()
                        print("📚 Navigated to previous exercise: \(currentExerciseIndex)")
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
                    HapticManager.shared.buttonTap()
                    if currentExerciseIndex < shuffledExercises.count - 1 {
                        currentExerciseIndex += 1
                        selectedAnswer = userAnswers[currentExerciseIndex] ?? ""
                        showFeedback = userAnswers[currentExerciseIndex] != nil
                        // Restore sentence building state for next exercise
                        restoreSentenceBuildingState()
                        print("📚 Navigated to next exercise: \(currentExerciseIndex)")
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
                }) {
                    Text(currentExerciseIndex < shuffledExercises.count - 1 ? "Next" : "Finish Lesson")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.top)
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
    
    private func resetSentenceBuildingState() {
        // Reset sentence building state when changing exercises
        selectedWords.removeAll()
        availableWords.removeAll()
        // Also reset feedback state if we're moving to a new exercise
        if !userAnswers.keys.contains(currentExerciseIndex) {
            showFeedback = false
            selectedAnswer = ""
        }
        print("📚 Reset sentence building state for exercise \(currentExerciseIndex)")
    }
    
    private func restoreSentenceBuildingState() {
        let tuple = shuffledExercises[currentExerciseIndex]
        let exercise = tuple.exercise
        let options = tuple.shuffledOptions
        
        if exercise.type == .sentenceBuilding {
            // Clear current state
            selectedWords.removeAll()
            availableWords.removeAll()
            
            if let savedAnswer = userAnswers[currentExerciseIndex] {
                // Restore the user's previous answer
                selectedWords = savedAnswer.components(separatedBy: " ")
                // Rebuild available words from what wasn't used
                availableWords = options.filter { !selectedWords.contains($0) }
                print("📚 Restored sentence building state: \(selectedWords)")
            } else {
                // Initialize for new exercise
                availableWords = options.shuffled()
                print("📚 Initialized new sentence building exercise")
            }
        }
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
                // Restore sentence building state if needed
                restoreSentenceBuildingState()
            } else {
                // Initialize sentence building state for new exercise
                restoreSentenceBuildingState()
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
    
    // MARK: - Sentence Building View
    
    @ViewBuilder
    private func sentenceBuildingView(exercise: Exercise, options: [String], correctIdx: Int) -> some View {
        VStack(spacing: 16) {
            // Built sentence display
            VStack(alignment: .leading, spacing: 8) {
                Text("Your sentence:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 4) {
                    if showFeedback {
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
                                            if !showFeedback {
                                                // Remove word from sentence
                                                let removedWord = selectedWords.remove(at: index)
                                                // No need to update availableWords, grid will update automatically
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
                    showFeedback ? 
                    (selectedAnswer == exercise.correctAnswer ? Color.green.opacity(0.15) : Color.red.opacity(0.15)) :
                    Color(.systemGray6)
                )
                .cornerRadius(12)
            }
            
            // Show correct answer if wrong
            if showFeedback && selectedAnswer != exercise.correctAnswer {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Correct answer:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(exercise.correctAnswer)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(.green)
                        .cornerRadius(12)
                }
            }
            
            // Available words (grid, stable positions)
            if !showFeedback {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available words:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                        ForEach(options.indices, id: \.self) { index in
                            let word = options[index]
                            let isSelected = selectedWords.contains(word)
                            Button(action: {
                                if !showFeedback && !isSelected {
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
                            .disabled(showFeedback || isSelected)
                        }
                    }
                }
            }
            
            // Check answer button
            if !showFeedback && selectedWords.count == options.count {
                Button(action: {
                    HapticManager.shared.buttonTap()
                    
                    let userSentence = selectedWords.joined(separator: " ")
                    selectedAnswer = userSentence
                    showFeedback = true
                    userAnswers[currentExerciseIndex] = userSentence
                    
                    // Check if answer is correct
                    if userSentence == exercise.correctAnswer {
                        correctCount += 1
                        HapticManager.shared.successNotification()
                    } else {
                        HapticManager.shared.errorNotification()
                    }
                    
                    // Record exercise attempt
                    DispatchQueue.main.async {
                        recordExerciseAttempt(exercise: exercise, userAnswer: userSentence)
                    }
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
            if !showFeedback && !selectedWords.isEmpty {
                Button(action: {
                    HapticManager.shared.buttonTap()
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
}

// Helper for wrapping vocab words
struct WrapHStack: View {
    let vocabularyItems: [VocabularyItem]
    let userWords: Set<String>
    let onTap: (VocabularyItem) -> Void
    
    @State private var showingTranslation: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(vocabularyItems, id: \.id) { item in
                if userWords.contains(item.dutchWord.lowercased()) {
                    // Already added words
                    HStack(spacing: 4) {
                        Text(item.dutchWord)
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        Text("-")
                            .foregroundColor(.secondary)
                        Text(item.translation)
                            .foregroundColor(.primary)
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                    .padding(6)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    // Words not yet added
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 4) {
                            Text(item.dutchWord)
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Image(systemName: showingTranslation.contains(item.id) ? "plus.circle.fill" : "plus.circle")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                        
                        if showingTranslation.contains(item.id) {
                            HStack(spacing: 4) {
                                Text("-")
                                    .foregroundColor(.secondary)
                                Text(item.translation)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                        }
                    }
                    .padding(6)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    .onTapGesture {
                        // Single tap: show/hide translation
                        if showingTranslation.contains(item.id) {
                            showingTranslation.remove(item.id)
                        } else {
                            showingTranslation.insert(item.id)
                        }
                        HapticManager.shared.buttonTap()
                    }
                    .onTapGesture(count: 2) {
                        // Double tap: add card
                        onTap(item)
                        HapticManager.shared.successNotification()
                        
                        // Show brief visual feedback
                        showingTranslation.insert(item.id)
                        
                        // Hide translation after a delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showingTranslation.remove(item.id)
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