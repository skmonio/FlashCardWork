import SwiftUI

struct LessonsListView: View {
    @ObservedObject var lessonManager = LessonManager.shared
    @ObservedObject var analyticsManager = LessonAnalyticsManager.shared
    @ObservedObject var userLessonManager = UserLessonManager.shared
    @State private var completedLessons: [UUID: Int] = [:] // lessonId: bestScore
    let viewModel: FlashCardViewModel
    @Environment(\.dismiss) private var dismiss
    
    // Export state
    @State private var showingExportSheet = false
    @State private var showingLessonSelection = false
    @State private var selectedLessonIds: Set<UUID> = []
    @State private var exportData: Data? = nil
    @State private var exportFileName: String = ""
    @State private var exportMimeType: String = "application/json"
    // Import state
    @State private var showingImportPicker = false
    @State private var importResultMessage: String? = nil
    @State private var showingImportAlert = false
    
    // User lesson state
    @State private var showingCreateLesson = false
    @State private var editingUserLesson: UserLesson? = nil
    @State private var showingDeleteAlert = false
    @State private var lessonToDelete: UserLesson? = nil
    
    // Export/Import type selection
    @State private var showingExportTypeSelection = false
    @State private var showingImportTypeSelection = false
    @State private var selectedUserLessonIds: Set<UUID> = []
    @State private var exportingUserLessons = false
    @State private var showingNoLessonsAlert = false
    @State private var showingExportFormatSheet = false
    
    enum ExportFormat: Identifiable {
        case csv, json
        var id: String {
            switch self {
            case .csv: return "csv"
            case .json: return "json"
            }
        }
    }
    
    enum ExportType: CaseIterable, Identifiable {
        case builtInLessons, userLessons, both
        
        var id: String {
            switch self {
            case .builtInLessons: return "builtin"
            case .userLessons: return "user"
            case .both: return "both"
            }
        }
        
        var displayName: String {
            switch self {
            case .builtInLessons: return "Built-in Lessons"
            case .userLessons: return "My Lessons"
            case .both: return "All Lessons"
            }
        }
        
        var description: String {
            switch self {
            case .builtInLessons: return "Export the app's built-in Dutch lessons"
            case .userLessons: return "Export your custom created lessons"
            case .both: return "Export both built-in and custom lessons"
            }
        }
    }
    
    // Combined export structure
    struct CombinedLessonsExport: Codable {
        let builtInLessons: [Lesson]
        let userLessons: [UserLesson]
        let exportDate: Date
        let version: String
        
        init(builtInLessons: [Lesson], userLessons: [UserLesson]) {
            self.builtInLessons = builtInLessons
            self.userLessons = userLessons
            self.exportDate = Date()
            self.version = "1.0"
        }
    }
    
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
                onBack: { dismiss() },
                trailing: {
                    AnyView(
                        HStack(spacing: 16) {
                            Button(action: {
                                showingExportTypeSelection = true
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
            
            ScrollView {
                VStack(spacing: 24) {
                    // Make a Lesson Button
                    VStack(spacing: 16) {
                        Button(action: {
                            showingCreateLesson = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("Make a Lesson")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // User Created Lessons Section
                    if !userLessonManager.userLessons.isEmpty {
                        userLessonsSection
                    }
                    
                    // Regular Lessons Section
                    regularLessonsSection
                }
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
        .onAppear {
            // Force refresh of user lessons when view appears
            print("📱 LessonsListView appeared - User lessons count: \(userLessonManager.userLessons.count)")
            // Force reload from storage
            userLessonManager.loadUserLessons()
            DispatchQueue.main.async {
                userLessonManager.objectWillChange.send()
                print("📱 Forced UI refresh for user lessons - Count now: \(userLessonManager.userLessons.count)")
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let data = exportData, !exportFileName.isEmpty {
                ShareSheet(activityItems: [createTemporaryFile(data: data, fileName: exportFileName)])
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text("Export Error")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("No data to export or filename is missing.")
                        .foregroundColor(.secondary)
                    Button("Close") {
                        showingExportSheet = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingLessonSelection) {
            lessonSelectionSheet()
        }
        .sheet(isPresented: $showingCreateLesson) {
            CreateLessonView(editingLesson: editingUserLesson)
                .onDisappear {
                    editingUserLesson = nil
                }
        }
        .sheet(isPresented: $showingExportTypeSelection) {
            exportTypeSelectionSheet()
        }
        .actionSheet(isPresented: $showingExportFormatSheet) {
            ActionSheet(title: Text("Export Format"), message: Text("Choose export format"), buttons: [
                .default(Text("CSV")) { 
                    print("📤 CSV format selected")
                    exportLessons(as: .csv) 
                },
                .default(Text("JSON")) { 
                    print("📤 JSON format selected")
                    exportLessons(as: .json) 
                },
                .cancel {
                    print("📤 Export cancelled")
                }
            ])
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json, .commaSeparatedText, .plainText, .data, .item],
            allowsMultipleSelection: false
        ) { result in
            handleLessonImport(result: result)
        }
        .alert("Import Result", isPresented: $showingImportAlert) {
            Button("OK") {}
        } message: {
            if let message = importResultMessage, message.contains("permission") || message.contains("readable") {
                Text("\(message)\n\nTip: Try saving the file to the Files app first, then import from there.")
            } else {
                Text(importResultMessage ?? "Unknown result")
            }
        }
        .alert("Delete Lesson", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let lesson = lessonToDelete {
                    userLessonManager.deleteLesson(id: lesson.id)
                }
                lessonToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                lessonToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this lesson? This action cannot be undone.")
        }
        .alert("No Lessons to Export", isPresented: $showingNoLessonsAlert) {
            Button("OK") {}
        } message: {
            Text("You don't have any custom lessons to export yet. Create some lessons first using the 'Make a Lesson' button.")
        }
    }
    
    private var userLessonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Lessons")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(userLessonManager.userLessons) { userLesson in
                    let lesson = userLesson.toLesson()
                    
                    NavigationLink(destination: LessonDetailView(lesson: lesson, completedLessons: $completedLessons, viewModel: viewModel, shouldLoadSaveState: false)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(userLesson.title)
                                        .font(.headline)
                                    Spacer()
                                    
                                    // User created badge
                                    Text("My Lesson")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.purple)
                                        .cornerRadius(8)
                                }
                                
                                Text(userLesson.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                Text("\(userLesson.questions.count) question\(userLesson.questions.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                
                                Text("Created: \(userLesson.createdDate.formatted(date: .abbreviated, time: .omitted))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Action buttons
                            HStack(spacing: 8) {
                                Button(action: {
                                    editingUserLesson = userLesson
                                    // Force UI refresh to ensure the lesson data is current
                                    userLessonManager.objectWillChange.send()
                                    // Small delay to ensure state is properly set
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showingCreateLesson = true
                                    }
                                }) {
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(6)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(6)
                                }
                                
                                Button(action: {
                                    lessonToDelete = userLesson
                                    showingDeleteAlert = true
                                }) {
                                    Image(systemName: "trash")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                        .padding(6)
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(6)
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
            .padding(.horizontal)
        }
    }

    private var regularLessonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Individual Lessons")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
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
            .padding(.horizontal)
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
                                                _ = selectedWords.remove(at: index)
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

// MARK: - Export UI

extension LessonsListView {
    private func exportTypeSelectionSheet() -> some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("What would you like to export?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                ForEach(ExportType.allCases) { exportType in
                    Button(action: {
                        handleExportTypeSelection(exportType)
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(exportType.displayName)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(exportType.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Lessons")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Cancel") {
                    showingExportTypeSelection = false
                }
            )
        }
    }

    private func lessonSelectionSheet() -> some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Text("Select Lessons to Export")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                    Button("Cancel") {
                        showingLessonSelection = false
                    }
                    .foregroundColor(.blue)
                }
                .padding()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        if exportingUserLessons {
                            // User lessons selection
                            Button(action: {
                                selectedUserLessonIds = Set(userLessonManager.userLessons.map { $0.id })
                                showingLessonSelection = false
                                showingExportFormatSheet = true
                            }) {
                                HStack {
                                    Text("All My Lessons")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(userLessonManager.userLessons.count) lessons")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.purple.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            ForEach(userLessonManager.userLessons) { userLesson in
                                Button(action: {
                                    if selectedUserLessonIds.contains(userLesson.id) {
                                        selectedUserLessonIds.remove(userLesson.id)
                                    } else {
                                        selectedUserLessonIds.insert(userLesson.id)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: selectedUserLessonIds.contains(userLesson.id) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(.purple)
                                        VStack(alignment: .leading) {
                                            Text(userLesson.title)
                                                .fontWeight(.medium)
                                            Text("\(userLesson.questions.count) questions")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        } else {
                            // Built-in lessons selection
                            Button(action: {
                                selectedLessonIds = Set(lessonManager.lessons.map { $0.id })
                                showingLessonSelection = false
                                showingExportFormatSheet = true
                            }) {
                                HStack {
                                    Text("All Lessons")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("\(lessonManager.lessons.count) lessons")
                                        .foregroundColor(.secondary)
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            ForEach(lessonManager.lessons, id: \.id) { lesson in
                                Button(action: {
                                    if selectedLessonIds.contains(lesson.id) {
                                        selectedLessonIds.remove(lesson.id)
                                    } else {
                                        selectedLessonIds.insert(lesson.id)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: selectedLessonIds.contains(lesson.id) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(.blue)
                                        VStack(alignment: .leading) {
                                            Text(lesson.title)
                                                .fontWeight(.medium)
                                            Text(lesson.level)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Button("Export Selected") {
                    print("📤 Export Selected clicked - User lessons: \(selectedUserLessonIds.count), Built-in: \(selectedLessonIds.count)")
                    showingLessonSelection = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        print("📤 Showing format selection sheet")
                        showingExportFormatSheet = true
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    (exportingUserLessons ? selectedUserLessonIds.isEmpty : selectedLessonIds.isEmpty) ? 
                    Color.gray.opacity(0.3) : Color.blue
                )
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding()
                .disabled(exportingUserLessons ? selectedUserLessonIds.isEmpty : selectedLessonIds.isEmpty)
            }
        }
    }
    
    private func handleExportTypeSelection(_ type: ExportType) {
        switch type {
        case .builtInLessons:
            selectedLessonIds = Set(lessonManager.lessons.map { $0.id })
            selectedUserLessonIds = []
            exportingUserLessons = false
        case .userLessons:
            selectedLessonIds = []
            selectedUserLessonIds = Set(userLessonManager.userLessons.map { $0.id })
            exportingUserLessons = true
        case .both:
            selectedLessonIds = Set(lessonManager.lessons.map { $0.id })
            selectedUserLessonIds = Set(userLessonManager.userLessons.map { $0.id })
            exportingUserLessons = false // Will handle both
        }
        showingExportTypeSelection = false
        
        // Check if there are any lessons to export
        if type == .userLessons && userLessonManager.userLessons.isEmpty {
            showingNoLessonsAlert = true
            print("📤 No user lessons to export, showing alert")
        } else {
            // Always show lesson selection to allow users to choose
            showingLessonSelection = true
            print("📤 Showing lesson selection for \(type.displayName)")
        }
    }
    
    private func exportLessons(as format: ExportFormat) {
        print("📤 Starting export process - Format: \(format)")
        print("📤 Export state - exportingUserLessons: \(exportingUserLessons)")
        print("📤 Selected user lessons: \(selectedUserLessonIds.count)")
        print("📤 Selected built-in lessons: \(selectedLessonIds.count)")
        print("📤 Total user lessons available: \(userLessonManager.userLessons.count)")
        
        switch format {
        case .csv:
            if exportingUserLessons {
                // Export selected user lessons as CSV
                let selectedLessons = userLessonManager.userLessons.filter { selectedUserLessonIds.contains($0.id) }
                let csv = generateUserLessonsCSV(selectedLessons)
                exportData = csv.data(using: .utf8)
                exportFileName = selectedUserLessonIds.count == userLessonManager.userLessons.count ? 
                    "MyLessons_All.csv" : "MyLessons_Selected.csv"
            } else if !selectedUserLessonIds.isEmpty && !selectedLessonIds.isEmpty {
                // Export both types - create combined CSV
                let builtInLessons = lessonManager.lessons.filter { selectedLessonIds.contains($0.id) }
                let userLessons = userLessonManager.userLessons.filter { selectedUserLessonIds.contains($0.id) }
                let builtInCSV = lessonManager.exportLessonsToCSV(builtInLessons)
                let userCSV = generateUserLessonsCSV(userLessons)
                let combinedCSV = builtInCSV + "\n" + userCSV.components(separatedBy: "\n").dropFirst().joined(separator: "\n")
                exportData = combinedCSV.data(using: .utf8)
                exportFileName = "AllLessons.csv"
            } else {
                // Export only built-in lessons
                let lessonsToExport = lessonManager.lessons.filter { selectedLessonIds.contains($0.id) }
                let csv = lessonManager.exportLessonsToCSV(lessonsToExport)
                exportData = csv.data(using: .utf8)
                exportFileName = selectedLessonIds.count == lessonManager.lessons.count ? "DutchLessons_All.csv" : "DutchLessons_Selected.csv"
            }
            exportMimeType = "text/csv"
            
        case .json:
            if exportingUserLessons {
                // Export selected user lessons as JSON
                let selectedLessons = userLessonManager.userLessons.filter { selectedUserLessonIds.contains($0.id) }
                let json = generateUserLessonsJSON(selectedLessons)
                exportData = json.data(using: .utf8)
                exportFileName = selectedUserLessonIds.count == userLessonManager.userLessons.count ? 
                    "MyLessons_All.json" : "MyLessons_Selected.json"
            } else if !selectedUserLessonIds.isEmpty && !selectedLessonIds.isEmpty {
                // Export both types - create combined JSON
                let builtInLessons = lessonManager.lessons.filter { selectedLessonIds.contains($0.id) }
                let userLessons = userLessonManager.userLessons.filter { selectedUserLessonIds.contains($0.id) }
                
                // Create a combined export structure
                let combinedData = CombinedLessonsExport(builtInLessons: builtInLessons, userLessons: userLessons)
                
                do {
                    let encoder = JSONEncoder()
                    encoder.outputFormatting = .prettyPrinted
                    encoder.dateEncodingStrategy = .iso8601
                    let data = try encoder.encode(combinedData)
                    exportData = data
                } catch {
                    print("❌ Error encoding combined lessons: \(error)")
                    exportData = "{}".data(using: .utf8)
                }
                exportFileName = "AllLessons.json"
            } else {
                // Export only built-in lessons
                let lessonsToExport = lessonManager.lessons.filter { selectedLessonIds.contains($0.id) }
                let json = lessonManager.exportLessonsToJSON(lessonsToExport)
                exportData = json.data(using: .utf8)
                exportFileName = selectedLessonIds.count == lessonManager.lessons.count ? "DutchLessons_All.json" : "DutchLessons_Selected.json"
            }
            exportMimeType = "application/json"
        }
        
        print("📤 Exporting file: \(exportFileName) (\(exportData?.count ?? 0) bytes)")
        
        // Validate export data before showing sheet
        guard let data = exportData, !data.isEmpty, !exportFileName.isEmpty else {
            print("❌ Export validation failed - Data: \(exportData?.count ?? 0) bytes, Filename: '\(exportFileName)'")
            // Reset export state and show error
            exportData = nil
            exportFileName = ""
            return
        }
        
        showingExportSheet = true
    }
    
    // Helper function to generate CSV for selected user lessons
    private func generateUserLessonsCSV(_ lessons: [UserLesson]) -> String {
        var csv = "Title,Description,Question Type,Question,All Answers,Hint,Created Date,Last Modified\n"
        
        for lesson in lessons {
            for question in lesson.questions {
                let allAnswers: String
                if question.questionType.lowercased() == "sentence building" {
                    // For sentence building, show word order
                    allAnswers = question.answers.map { answer in
                        if let orderIndex = answer.orderIndex {
                            return "\(answer.text) (\(orderIndex + 1))"
                        } else {
                            return answer.text
                        }
                    }.joined(separator: "; ")
                } else {
                    // For other question types, show correct/wrong markers
                    allAnswers = question.answers.map { answer in
                        let marker = answer.isCorrect ? "[CORRECT]" : "[WRONG]"
                        return "\(answer.text) \(marker)"
                    }.joined(separator: "; ")
                }
                
                let row = [
                    escapeCSVField(lesson.title),
                    escapeCSVField(lesson.description),
                    escapeCSVField(question.questionType),
                    escapeCSVField(question.question),
                    escapeCSVField(allAnswers),
                    escapeCSVField(question.hint),
                    formatDate(lesson.createdDate),
                    formatDate(lesson.lastModified)
                ].joined(separator: ",")
                csv += row + "\n"
            }
        }
        
        return csv
    }
    
    // Helper function to generate JSON for selected user lessons
    private func generateUserLessonsJSON(_ lessons: [UserLesson]) -> String {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(lessons)
            return String(data: data, encoding: .utf8) ?? "[]"
        } catch {
            print("❌ Error exporting selected user lessons to JSON: \(error)")
            return "[]"
        }
    }
    
    // Helper functions for CSV formatting
    private func escapeCSVField(_ field: String) -> String {
        let trimmed = field.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.contains(",") || trimmed.contains("\"") || trimmed.contains("\n") {
            return "\"" + trimmed.replacingOccurrences(of: "\"", with: "\"\"") + "\""
        }
        return trimmed
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Temporary File Creation
    private func createTemporaryFile(data: Data, fileName: String) -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let tempFileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: tempFileURL)
            print("📤 Created temporary file: \(tempFileURL.lastPathComponent)")
            return tempFileURL
        } catch {
            print("❌ Error creating temporary file: \(error)")
            // Return a fallback URL with the data embedded
            return tempDir.appendingPathComponent("export_error.txt")
        }
    }
    
    // MARK: - Export File Wrapper (Legacy - keeping for reference)
    class ExportFileWrapper: NSObject, UIActivityItemSource {
        let data: Data
        let fileName: String
        let mimeType: String
        
        init(data: Data, fileName: String, mimeType: String) {
            self.data = data
            self.fileName = fileName
            self.mimeType = mimeType
            print("📤 ExportFileWrapper created: \(fileName) (\(data.count) bytes) - MIME: \(mimeType)")
        }
        
        func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any { 
            print("📤 Placeholder item requested")
            return data 
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? { 
            print("📤 Item requested for activity type: \(activityType?.rawValue ?? "nil")")
            return data 
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String { 
            print("📤 Subject requested: \(fileName)")
            return fileName 
        }
        
        func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String { 
            print("📤 Data type identifier requested: \(mimeType)")
            return mimeType 
        }
        
        // This is the missing method that provides the filename!
        func activityViewController(_ activityViewController: UIActivityViewController, filenameForActivityType activityType: UIActivity.ActivityType?) -> String? {
            print("📤 Filename requested: \(fileName)")
            return fileName
        }
    }
    
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            return controller
        }
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }
    
    // MARK: - Import Logic
    private func handleLessonImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                importResultMessage = "No file selected."
                showingImportAlert = true
                return
            }
            
            print("📥 Attempting to import file: \(url.lastPathComponent)")
            print("📥 File URL: \(url)")
            
            // Start accessing security-scoped resource (needed for AirDropped files)
            let didStartAccessing = url.startAccessingSecurityScopedResource()
            print("📥 Security scoped access: \(didStartAccessing)")
            
            defer {
                if didStartAccessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            do {
                // Check if file exists and is readable
                guard FileManager.default.fileExists(atPath: url.path) else {
                    throw NSError(domain: "Import", code: 404, userInfo: [NSLocalizedDescriptionKey: "File not found at path: \(url.path)"])
                }
                
                // Check if file is readable
                guard FileManager.default.isReadableFile(atPath: url.path) else {
                    throw NSError(domain: "Import", code: 403, userInfo: [NSLocalizedDescriptionKey: "File is not readable. Try copying it to Files app first."])
                }
                
                let data = try Data(contentsOf: url)
                print("📥 Successfully read \(data.count) bytes from file")
                
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                var importedLessons: [Lesson] = []
                var importedUserLessons: [UserLesson] = []
                var importType: String = ""
                
                // Try JSON import
                if url.pathExtension.lowercased() == "json" {
                    // First try to import as user lessons
                    if let userLessons = try? decoder.decode([UserLesson].self, from: data) {
                        let addedCount = try userLessonManager.importUserLessonsFromJSON(String(data: data, encoding: .utf8) ?? "[]")
                        importResultMessage = "Imported \(addedCount) user lessons."
                        importType = "User Lessons (JSON)"
                    }
                    // Try combined format (both built-in and user lessons)
                    else if let combined = try? decoder.decode(CombinedLessonsExport.self, from: data) {
                        // Handle combined import
                        var addedBuiltIn = 0
                        var addedUser = 0
                        
                        // Import built-in lessons directly
                        LessonManager.shared.replaceLessons(with: combined.builtInLessons)
                        addedBuiltIn = combined.builtInLessons.count
                        
                        // Import user lessons directly
                        do {
                            let encoder = JSONEncoder()
                            encoder.dateEncodingStrategy = .iso8601
                            let userLessonsData = try encoder.encode(combined.userLessons)
                            let userLessonsJSON = String(data: userLessonsData, encoding: .utf8) ?? "[]"
                            addedUser = try userLessonManager.importUserLessonsFromJSON(userLessonsJSON)
                        } catch {
                            print("❌ Error importing user lessons from combined format: \(error)")
                        }
                        
                        importResultMessage = "Imported \(addedBuiltIn) built-in lessons and \(addedUser) user lessons."
                        importType = "Combined (JSON)"
                    }
                    // Try standard built-in lesson formats
                    else if let root = try? decoder.decode(LessonRootJSON.self, from: data) {
                        importedLessons = root.lessons.map { $0.toLesson() }
                        importType = "Built-in Lessons (LessonRootJSON)"
                    } else if let arr = try? decoder.decode([LessonJSON].self, from: data) {
                        importedLessons = arr.map { $0.toLesson() }
                        importType = "Built-in Lessons ([LessonJSON])"
                    } else {
                        throw NSError(domain: "Import", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure for lessons."])
                    }
                } else {
                    // Try CSV import (for built-in lessons only - user lessons have different CSV structure)
                    if let csvString = String(data: data, encoding: .utf8) {
                        let rows = csvString.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty }
                        guard let header = rows.first else { throw NSError(domain: "Import", code: 2, userInfo: [NSLocalizedDescriptionKey: "CSV missing header row"]) }
                        
                        // Check if this is a user lesson CSV by looking for user lesson specific columns
                        if header.contains("Question Type") && header.contains("Created Date") {
                            // Handle user lesson CSV import
                            print("📥 Detected user lesson CSV format")
                            try importUserLessonCSV(csvString: csvString, rows: rows)
                            importType = "User Lessons (CSV)"
                        } else {
                            // Handle built-in lesson CSV import
                            let columns = header.components(separatedBy: ",")
                            let titleIdx = columns.firstIndex(of: "Title")
                            let descIdx = columns.firstIndex(of: "Description")
                            let levelIdx = columns.firstIndex(of: "Level")
                            let catIdx = columns.firstIndex(of: "Category")
                            let timeIdx = columns.firstIndex(of: "EstimatedTime")
                            let diffIdx = columns.firstIndex(of: "Difficulty")
                            
                            for row in rows.dropFirst() {
                                let fields = row.components(separatedBy: ",")
                                func val(_ idx: Int?) -> String { idx != nil && idx! < fields.count ? fields[idx!].trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) : "" }
                                let lesson = Lesson(
                                    title: val(titleIdx),
                                    description: val(descIdx),
                                    vocabulary: [],
                                    exercises: []
                                )
                                var l = lesson
                                l.level = val(levelIdx)
                                l.category = val(catIdx)
                                l.estimatedTime = Int(val(timeIdx)) ?? 0
                                l.difficulty = val(diffIdx)
                                importedLessons.append(l)
                            }
                            importType = "Built-in Lessons (CSV)"
                        }
                    } else {
                        throw NSError(domain: "Import", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not decode file as UTF-8 text."])
                    }
                }
                
                // Handle built-in lesson import
                if !importedLessons.isEmpty {
                    LessonManager.shared.replaceLessons(with: importedLessons)
                    importResultMessage = "Imported \(importedLessons.count) lessons (\(importType))."
                }
                
                if importResultMessage == nil {
                    importResultMessage = "No lessons found in import file."
                }
                
                showingImportAlert = true
            } catch {
                print("❌ Import error: \(error)")
                importResultMessage = "Failed to import: \(error.localizedDescription)"
                showingImportAlert = true
            }
        case .failure(let error):
            print("❌ File picker error: \(error)")
            importResultMessage = "Import failed: \(error.localizedDescription)"
            showingImportAlert = true
        }
    }
    
    private func importUserLessonCSV(csvString: String, rows: [String]) throws {
        guard let header = rows.first else {
            throw NSError(domain: "Import", code: 5, userInfo: [NSLocalizedDescriptionKey: "CSV file is empty"])
        }
        
        let columns = header.components(separatedBy: ",")
        let titleIdx = columns.firstIndex(of: "Title")
        let descriptionIdx = columns.firstIndex(of: "Description") 
        let questionTypeIdx = columns.firstIndex(of: "Question Type")
        let questionIdx = columns.firstIndex(of: "Question")
        let allAnswersIdx = columns.firstIndex(of: "All Answers")
        let hintIdx = columns.firstIndex(of: "Hint")
        let createdDateIdx = columns.firstIndex(of: "Created Date")
        let lastModifiedIdx = columns.firstIndex(of: "Last Modified")
        
        // Group rows by lesson title
        var lessonGroups: [String: (description: String, questions: [UserQuestion], createdDate: Date, lastModified: Date)] = [:]
        
        for row in rows.dropFirst() {
            let fields = parseCSVRow(row)
            func val(_ idx: Int?) -> String { 
                guard let idx = idx, idx < fields.count else { return "" }
                return unescapeCSVField(fields[idx])
            }
            
            let title = val(titleIdx)
            let description = val(descriptionIdx)
            let questionType = val(questionTypeIdx)
            let question = val(questionIdx)
            let allAnswers = val(allAnswersIdx)
            let hint = val(hintIdx)
            let createdDateString = val(createdDateIdx)
            let lastModifiedString = val(lastModifiedIdx)
            
            // Parse dates
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            let createdDate = dateFormatter.date(from: createdDateString) ?? Date()
            let lastModified = dateFormatter.date(from: lastModifiedString) ?? Date()
            
            // Parse answers from the "All Answers" field
            let answers = parseAnswersFromCSV(allAnswers, questionType: questionType)
            
            let userQuestion = UserQuestion(
                questionType: questionType,
                question: question,
                answers: answers,
                hint: hint
            )
            
            // Group by lesson title
            if lessonGroups[title] == nil {
                lessonGroups[title] = (description: description, questions: [], createdDate: createdDate, lastModified: lastModified)
            }
            lessonGroups[title]?.questions.append(userQuestion)
        }
        
        // Create UserLesson objects and import them
        var addedCount = 0
        for (title, lessonData) in lessonGroups {
            let userLesson = UserLesson(
                title: title,
                description: lessonData.description,
                questions: lessonData.questions
            )
            
            // Check for duplicates and add if not exists
            if !userLessonManager.userLessons.contains(where: { $0.title.lowercased() == title.lowercased() }) {
                userLessonManager.addLesson(userLesson)
                addedCount += 1
            }
        }
        
        importResultMessage = "Imported \(addedCount) user lessons from CSV."
    }
    
    private func parseAnswersFromCSV(_ allAnswersString: String, questionType: String) -> [UserAnswer] {
        let answerStrings = allAnswersString.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        var answers: [UserAnswer] = []
        
        if questionType.lowercased() == "sentence building" {
            // Parse sentence building format: "Ik (1); eet (2); kaas (3)"
            for answerText in answerStrings {
                if let match = answerText.range(of: #"\((\d+)\)$"#, options: .regularExpression) {
                    let orderString = String(answerText[match]).replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "")
                    let orderIndex = (Int(orderString) ?? 1) - 1 // Convert to 0-based
                    let text = String(answerText[..<match.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    answers.append(UserAnswer(text: text, isCorrect: false, orderIndex: orderIndex))
                } else {
                    answers.append(UserAnswer(text: answerText, isCorrect: false, orderIndex: nil))
                }
            }
        } else {
            // Parse multiple choice format: "Answer1 [CORRECT]; Answer2 [WRONG]"
            for answerText in answerStrings {
                let isCorrect = answerText.contains("[CORRECT]")
                let text = answerText
                    .replacingOccurrences(of: "[CORRECT]", with: "")
                    .replacingOccurrences(of: "[WRONG]", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                answers.append(UserAnswer(text: text, isCorrect: isCorrect, orderIndex: nil))
            }
        }
        
        // Ensure at least one correct answer for non-sentence-building questions
        if questionType.lowercased() != "sentence building" && !answers.contains(where: { $0.isCorrect }) {
            if let firstAnswer = answers.first {
                answers[0] = UserAnswer(text: firstAnswer.text, isCorrect: true, orderIndex: firstAnswer.orderIndex)
            }
        }
        
        return answers
    }
    
    private func parseCSVRow(_ row: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = row.startIndex
        
        while i < row.endIndex {
            let char = row[i]
            
            if char == "\"" {
                if insideQuotes && i < row.index(before: row.endIndex) && row[row.index(after: i)] == "\"" {
                    // Escaped quote
                    currentField += "\""
                    i = row.index(after: i)
                } else {
                    insideQuotes.toggle()
                }
            } else if char == "," && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField += String(char)
            }
            
            i = row.index(after: i)
        }
        
        fields.append(currentField)
        return fields
    }
    
    private func unescapeCSVField(_ field: String) -> String {
        var result = field.trimmingCharacters(in: .whitespacesAndNewlines)
        if result.hasPrefix("\"") && result.hasSuffix("\"") {
            result = String(result.dropFirst().dropLast())
            result = result.replacingOccurrences(of: "\"\"", with: "\"")
        }
        return result
    }
} 