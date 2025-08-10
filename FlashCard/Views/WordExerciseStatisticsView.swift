import SwiftUI
import Charts

struct WordExerciseStatisticsView: View {
    @ObservedObject var wordExerciseManager = DutchWordExerciseManager.shared
    @Environment(\.dismiss) private var dismiss
    
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
                        
                        Text("Statistics")
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    
                    Divider()
                }
                .background(Color(.systemGroupedBackground))
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Overview Stats
                        overviewStatsSection
                        
                        // Category Breakdown
                        categoryBreakdownSection
                        
                        // Difficulty Breakdown
                        difficultyBreakdownSection
                        
                        // Recent Activity
                        recentActivitySection
                        
                        // Export Stats
                        exportStatsSection
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Overview Stats Section
    
    private var overviewStatsSection: some View {
        let stats = wordExerciseManager.getStatistics()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                WordStatCard(
                    title: "Total Words",
                    value: "\(stats.totalWordExercises)",
                    icon: "textformat",
                    color: .blue
                )
                
                WordStatCard(
                    title: "Total Questions",
                    value: "\(stats.totalQuestions)",
                    icon: "questionmark.circle",
                    color: .green
                )
                
                WordStatCard(
                    title: "User Created",
                    value: "\(stats.userCreated)",
                    icon: "plus.circle",
                    color: .orange
                )
                
                WordStatCard(
                    title: "Imported",
                    value: "\(stats.imported)",
                    icon: "square.and.arrow.down",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Category Breakdown Section
    
    private var categoryBreakdownSection: some View {
        let stats = wordExerciseManager.getStatistics()
        let categoryData = stats.categoryBreakdown.sorted { $0.value > $1.value }
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Categories")
                .font(.headline)
            
            if categoryData.isEmpty {
                emptyStateView("No categories yet")
            } else {
                VStack(spacing: 12) {
                    ForEach(categoryData.prefix(5), id: \.key) { category, count in
                        CategoryRow(
                            category: category,
                            count: count,
                            total: stats.totalWordExercises
                        )
                    }
                    
                    if categoryData.count > 5 {
                        Button("View All Categories") {
                            // Could navigate to detailed category view
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Difficulty Breakdown Section
    
    private var difficultyBreakdownSection: some View {
        let stats = wordExerciseManager.getStatistics()
        let difficultyData = stats.difficultyBreakdown.sorted { $0.value > $1.value }
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Difficulty Levels")
                .font(.headline)
            
            if difficultyData.isEmpty {
                emptyStateView("No difficulty data")
            } else {
                VStack(spacing: 12) {
                    ForEach(difficultyData, id: \.key) { difficulty, count in
                        DifficultyRow(
                            difficulty: difficulty,
                            count: count,
                            total: stats.totalWordExercises
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        let recentExercises = wordExerciseManager.wordExercises
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(5)
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
            
            if recentExercises.isEmpty {
                emptyStateView("No recent activity")
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(recentExercises), id: \.id) { exercise in
                        RecentActivityRow(exercise: exercise)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Export Stats Section
    
    private var exportStatsSection: some View {
        let stats = wordExerciseManager.getStatistics()
        
        return VStack(alignment: .leading, spacing: 16) {
            Text("Data Summary")
                .font(.headline)
            
            VStack(spacing: 12) {
                SummaryRow(
                    title: "Average Questions per Word",
                    value: stats.totalWordExercises > 0 ? String(format: "%.1f", Double(stats.totalQuestions) / Double(stats.totalWordExercises)) : "0"
                )
                
                SummaryRow(
                    title: "Most Popular Category",
                    value: stats.categoryBreakdown.max(by: { $0.value < $1.value })?.key.rawValue ?? "None"
                )
                
                SummaryRow(
                    title: "Most Common Difficulty",
                    value: stats.difficultyBreakdown.max(by: { $0.value < $1.value })?.key.rawValue ?? "None"
                )
                
                SummaryRow(
                    title: "Creation Rate",
                    value: "\(stats.userCreated) user-created vs \(stats.imported) imported"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Views
    
    private func emptyStateView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.bar")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Supporting Views

struct WordStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct CategoryRow: View {
    let category: WordCategory
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? (Double(count) / Double(total)) * 100 : 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(count) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(percentage))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                ProgressView(value: percentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(width: 60)
            }
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct DifficultyRow: View {
    let difficulty: ExerciseDifficulty
    let count: Int
    let total: Int
    
    private var percentage: Double {
        total > 0 ? (Double(count) / Double(total)) * 100 : 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(difficulty.color))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(difficulty.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(count) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(percentage))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(Color(difficulty.color))
                
                ProgressView(value: percentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(difficulty.color)))
                    .frame(width: 60)
            }
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct RecentActivityRow: View {
    let exercise: DutchWordExercise
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: exercise.createdAt, relativeTo: Date())
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.targetWord)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(exercise.wordTranslation)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: exercise.isUserCreated ? "plus.circle" : "square.and.arrow.down")
                        .font(.caption)
                        .foregroundColor(exercise.isUserCreated ? .orange : .purple)
                    
                    Text(exercise.isUserCreated ? "Created" : "Imported")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(8)
    }
}

struct SummaryRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WordExerciseStatisticsView()
} 