import SwiftUI
import UniformTypeIdentifiers

struct DutchWordsView: View {
    @ObservedObject var wordExerciseManager = DutchWordExerciseManager.shared
    @State private var searchText = ""
    @State private var selectedCategory: WordCategory?
    @State private var selectedDifficulty: ExerciseDifficulty?
    @State private var showingCreateExercise = false
    @State private var showingImportSheet = false
    @State private var showingExportSheet = false
    @State private var showingStatistics = false
    @State private var selectedExercise: DutchWordExercise?
    @State private var showingExerciseDetail = false
    @State private var showingError = false
    @Environment(\.dismiss) private var dismiss
    
    var filteredExercises: [DutchWordExercise] {
        var exercises = wordExerciseManager.wordExercises
        
        // Apply search filter
        if !searchText.isEmpty {
            exercises = wordExerciseManager.searchWordExercises(query: searchText)
        }
        
        // Apply category filter
        if let category = selectedCategory {
            exercises = wordExerciseManager.filterWordExercises(by: category)
        }
        
        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            exercises = wordExerciseManager.filterWordExercises(by: difficulty)
        }
        
        return exercises
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Unified Header
            UnifiedHeader(
                title: "Dutch Words",
                showBackButton: true,
                showProfileIcon: false,
                onBack: { dismiss() }
            )
            
            ScrollView {
                VStack(spacing: 20) {
                    // Statistics Card
                    statisticsCard
                    
                    // Search and Filters
                    searchAndFiltersSection
                    
                    // Action Buttons
                    actionButtonsSection
                    
                    // Word Exercises List
                    wordExercisesList
                }
                .padding(.horizontal)
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
        .sheet(isPresented: $showingCreateExercise) {
            CreateWordExerciseView()
        }
        .sheet(isPresented: $showingImportSheet) {
            ImportWordExercisesView()
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportWordExercisesView()
        }
        .sheet(isPresented: $showingStatistics) {
            WordExerciseStatisticsView()
        }
        .sheet(isPresented: $showingExerciseDetail) {
            if let exercise = selectedExercise {
                WordExerciseDetailView(wordExercise: exercise)
            }
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(wordExerciseManager.errorMessage ?? "An unknown error occurred")
        }
        .onReceive(wordExerciseManager.$errorMessage) { errorMessage in
            showingError = errorMessage != nil
        }
    }
    
    // MARK: - Statistics Card
    
    private var statisticsCard: some View {
        let stats = wordExerciseManager.getStatistics()
        
        return VStack(spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("Statistics")
                    .font(.headline)
                Spacer()
                Button("View Details") {
                    showingStatistics = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            HStack(spacing: 20) {
                StatisticItem(
                    title: "Words",
                    value: "\(stats.totalWordExercises)",
                    icon: "textformat"
                )
                
                StatisticItem(
                    title: "Questions",
                    value: "\(stats.totalQuestions)",
                    icon: "questionmark.circle"
                )
                
                StatisticItem(
                    title: "Created",
                    value: "\(stats.userCreated)",
                    icon: "plus.circle"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Search and Filters
    
    private var searchAndFiltersSection: some View {
        VStack(spacing: 12) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search words...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(10)
            
            // Filters
            HStack(spacing: 12) {
                // Category Filter
                Menu {
                    Button("All Categories") {
                        selectedCategory = nil
                    }
                    ForEach(WordCategory.allCases, id: \.self) { category in
                        Button(category.rawValue) {
                            selectedCategory = category
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: selectedCategory?.icon ?? "folder")
                        Text(selectedCategory?.rawValue ?? "All Categories")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                
                // Difficulty Filter
                Menu {
                    Button("All Difficulties") {
                        selectedDifficulty = nil
                    }
                    ForEach(ExerciseDifficulty.allCases, id: \.self) { difficulty in
                        Button(difficulty.rawValue) {
                            selectedDifficulty = difficulty
                        }
                    }
                } label: {
                    HStack {
                        Circle()
                            .fill(Color(difficultyColor(selectedDifficulty)))
                            .frame(width: 8, height: 8)
                        Text(selectedDifficulty?.rawValue ?? "All Difficulties")
                        Image(systemName: "chevron.down")
                    }
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsSection: some View {
        HStack(spacing: 12) {
            Button(action: { showingCreateExercise = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue)
                .cornerRadius(8)
            }
            
            Button(action: { showingImportSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Import")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button(action: { showingExportSheet = true }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Word Exercises List
    
    private var wordExercisesList: some View {
        LazyVStack(spacing: 12) {
            if filteredExercises.isEmpty {
                emptyStateView
            } else {
                ForEach(filteredExercises) { exercise in
                    WordExerciseCard(wordExercise: exercise) {
                        selectedExercise = exercise
                        showingExerciseDetail = true
                    }
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "textformat")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No word exercises found")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Create your first word exercise or import existing ones to get started.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Create Exercise") {
                showingCreateExercise = true
            }
            .font(.subheadline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.blue)
            .cornerRadius(8)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Helper Methods
    
    private func difficultyColor(_ difficulty: ExerciseDifficulty?) -> String {
        guard let difficulty = difficulty else { return "gray" }
        return difficulty.color
    }
}

// MARK: - Supporting Views

struct StatisticItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
            
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

struct WordExerciseCard: View {
    let wordExercise: DutchWordExercise
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Word Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(wordExercise.targetWord)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(wordExercise.wordTranslation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Label(wordExercise.category.rawValue, systemImage: wordExercise.category.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Circle()
                            .fill(Color(wordExercise.difficulty.color))
                            .frame(width: 8, height: 8)
                        
                        Text(wordExercise.difficulty.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Exercise Count
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(wordExercise.exercises.count)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    DutchWordsView()
} 