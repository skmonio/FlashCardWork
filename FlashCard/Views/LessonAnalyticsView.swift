import SwiftUI

struct LessonAnalyticsView: View {
    @ObservedObject var analyticsManager = LessonAnalyticsManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Overview Stats
                    overviewSection
                    
                    // Difficult Vocabulary
                    difficultVocabularySection
                    
                    // Exercise Type Performance
                    exercisePerformanceSection
                    
                    // Recent Attempts
                    recentAttemptsSection
                }
                .padding()
            }
            .navigationTitle("Lesson Analytics")
        }
    }
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    icon: "checkmark.circle.fill",
                    title: "Lessons Completed",
                    subtitle: "\(analyticsManager.getTotalLessonsCompleted())",
                    color: .green
                )
                
                StatCard(
                    icon: "clock.fill",
                    title: "Total Time",
                    subtitle: formatTime(analyticsManager.getTotalTimeSpentOnLessons()),
                    color: .blue
                )
                
                StatCard(
                    icon: "repeat.circle.fill",
                    title: "Total Attempts",
                    subtitle: "\(analyticsManager.lessonAttempts.count)",
                    color: .orange
                )
                
                StatCard(
                    icon: "target",
                    title: "Avg. Accuracy",
                    subtitle: "\(Int(getOverallAccuracy() * 100))%",
                    color: .purple
                )
            }
        }
    }
    
    private var difficultVocabularySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Difficult Vocabulary")
                .font(.title2)
                .fontWeight(.bold)
            
            let difficultWords = analyticsManager.getDifficultVocabulary()
            
            if difficultWords.isEmpty {
                Text("Complete some lessons to see your difficult vocabulary!")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(difficultWords.prefix(5).enumerated()), id: \.offset) { index, wordData in
                    HStack {
                        Text("\(index + 1).")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        
                        Text(wordData.word)
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(wordData.errorRate * 100))% error")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var exercisePerformanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Exercise Type Performance")
                .font(.title2)
                .fontWeight(.bold)
            
            let performance = analyticsManager.getExerciseTypePerformance()
            
            if performance.isEmpty {
                Text("Complete some lessons to see performance by exercise type!")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(performance, id: \.type) { typeData in
                    HStack {
                        Text(formatExerciseType(typeData.type))
                            .font(.headline)
                        
                        Spacer()
                        
                        ProgressView(value: typeData.accuracy)
                            .frame(width: 100)
                        
                        Text("\(Int(typeData.accuracy * 100))%")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(typeData.accuracy > 0.7 ? .green : typeData.accuracy > 0.5 ? .orange : .red)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private var recentAttemptsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Attempts")
                .font(.title2)
                .fontWeight(.bold)
            
            let recentAttempts = analyticsManager.lessonAttempts.suffix(5).reversed()
            
            if recentAttempts.isEmpty {
                Text("Start learning to see your progress!")
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(Array(recentAttempts), id: \.id) { attempt in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(attempt.lessonTitle)
                                .font(.headline)
                            Spacer()
                            Text("\(attempt.scorePercentage)%")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(attempt.scorePercentage >= 80 ? .green : attempt.scorePercentage >= 60 ? .orange : .red)
                        }
                        
                        HStack {
                            Text(formatDate(attempt.endTime))
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("Duration: \(formatTime(attempt.duration))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func getOverallAccuracy() -> Double {
        let attempts = analyticsManager.lessonAttempts
        guard !attempts.isEmpty else { return 0 }
        return attempts.map { $0.accuracy }.reduce(0, +) / Double(attempts.count)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        } else {
            return "\(remainingMinutes)m"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatExerciseType(_ type: String) -> String {
        switch type {
        case "fillInBlank": return "Fill in the Blank"
        case "missingWord": return "Missing Word"
        case "useInSentence": return "Use in Sentence"
        case "dragAndDrop": return "Drag & Drop"
        default: return type.capitalized
        }
    }
} 