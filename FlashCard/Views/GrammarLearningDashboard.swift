import SwiftUI

struct GrammarLearningDashboard: View {
    @StateObject private var questionManager = GrammarQuestionManager.shared
    @StateObject private var userProfileManager = UserProfileManager.shared
    @StateObject private var statsManager = StatisticsManager.shared
    
    @State private var selectedLevel: LanguageLevel = .a1
    @State private var showingGrammarRules = false
    @State private var showingVocabularyIntegration = false
    @State private var showingProgressAnalytics = false
    @State private var showingPracticeSession = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    dashboardHeader
                    
                    // Progress Overview
                    progressOverview
                    
                    // Quick Actions
                    quickActions
                    
                    // Level Progress
                    levelProgressSection
                    
                    // Vocabulary Integration
                    vocabularyIntegrationSection
                    
                    // Recent Activity
                    recentActivitySection
                    
                    // Learning Recommendations
                    learningRecommendationsSection
                }
                .padding()
            }
            .navigationTitle("Grammar Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingGrammarRules) {
                JSONGrammarRulesView()
            }
            .sheet(isPresented: $showingVocabularyIntegration) {
                VocabularyGrammarIntegrationView()
            }
            .sheet(isPresented: $showingProgressAnalytics) {
                GrammarProgressAnalyticsView()
            }
            .sheet(isPresented: $showingPracticeSession) {
                GrammarPracticeSessionView()
            }
        }
    }
    
    // MARK: - Dashboard Header
    
    private var dashboardHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dutch Grammar")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Master Dutch grammar systematically")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showingProgressAnalytics = true
                }) {
                    Image(systemName: "chart.bar.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            // Overall progress bar
            ProgressView(value: overallProgress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text("Overall Progress: \(Int(overallProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(completedRules) / \(totalRules) rules")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    // MARK: - Progress Overview
    
    private var progressOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress Overview")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ProgressCard(
                    title: "A1 Level",
                    progress: a1Progress,
                    color: .green,
                    icon: "1.circle.fill"
                )
                
                ProgressCard(
                    title: "A2 Level",
                    progress: a2Progress,
                    color: .blue,
                    icon: "2.circle.fill"
                )
                
                ProgressCard(
                    title: "B1 Level",
                    progress: b1Progress,
                    color: .orange,
                    icon: "3.circle.fill"
                )
            }
        }
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                QuickActionCard(
                    title: "Practice Grammar",
                    subtitle: "Start a practice session",
                    icon: "pencil.circle.fill",
                    color: .blue
                ) {
                    showingPracticeSession = true
                }
                
                QuickActionCard(
                    title: "Review Rules",
                    subtitle: "Browse grammar rules",
                    icon: "book.circle.fill",
                    color: .green
                ) {
                    showingGrammarRules = true
                }
                
                QuickActionCard(
                    title: "Vocabulary",
                    subtitle: "Grammar + Vocabulary",
                    icon: "textformat.abc.circle.fill",
                    color: .orange
                ) {
                    showingVocabularyIntegration = true
                }
                
                QuickActionCard(
                    title: "Analytics",
                    subtitle: "View detailed progress",
                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                    color: .purple
                ) {
                    showingProgressAnalytics = true
                }
            }
        }
    }
    
    // MARK: - Level Progress Section
    
    private var levelProgressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Level Progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(LanguageLevel.allCases, id: \.self) { level in
                        LevelProgressCard(
                            level: level,
                            progress: progressForLevel(level),
                            completedRules: completedRulesForLevel(level),
                            totalRules: totalRulesForLevel(level)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Vocabulary Integration Section
    
    private var vocabularyIntegrationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Vocabulary Integration")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    showingVocabularyIntegration = true
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                IntegrationCard(
                    title: "Grammar in Context",
                    subtitle: "Practice grammar with vocabulary you know",
                    progress: vocabularyGrammarProgress,
                    color: .green
                )
                
                IntegrationCard(
                    title: "Word Types",
                    subtitle: "Learn grammar through word categories",
                    progress: wordTypesProgress,
                    color: .blue
                )
            }
        }
    }
    
    // MARK: - Recent Activity Section
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 8) {
                ForEach(recentActivities, id: \.id) { activity in
                    ActivityRow(activity: activity)
                }
            }
        }
    }
    
    // MARK: - Learning Recommendations Section
    
    private var learningRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommended Next Steps")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(learningRecommendations, id: \.id) { recommendation in
                    RecommendationCard(recommendation: recommendation)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var overallProgress: Double {
        guard totalRules > 0 else { return 0.0 }
        return Double(completedRules) / Double(totalRules)
    }
    
    private var completedRules: Int {
        // This would be calculated from user progress data
        return 3 // Placeholder
    }
    
    private var totalRules: Int {
        return questionManager.getAllRules().count
    }
    
    private var a1Progress: Double {
        return progressForLevel(.a1)
    }
    
    private var a2Progress: Double {
        return progressForLevel(.a2)
    }
    
    private var b1Progress: Double {
        return progressForLevel(.b1)
    }
    
    private var vocabularyGrammarProgress: Double {
        // Calculate based on vocabulary-grammar integration usage
        return 0.6
    }
    
    private var wordTypesProgress: Double {
        // Calculate based on word type learning progress
        return 0.4
    }
    
    private var recentActivities: [GrammarActivity] {
        return [
            GrammarActivity(id: "1", type: .practice, title: "Present Tense Practice", timestamp: Date().addingTimeInterval(-3600), score: 85),
            GrammarActivity(id: "2", type: .rule, title: "Learned Future Tense", timestamp: Date().addingTimeInterval(-7200), score: nil),
            GrammarActivity(id: "3", type: .quiz, title: "Articles Quiz", timestamp: Date().addingTimeInterval(-10800), score: 92)
        ]
    }
    
    private var learningRecommendations: [GrammarRecommendation] {
        return [
            GrammarRecommendation(id: "1", title: "Practice Irregular Verbs", description: "Focus on common irregular verbs like 'zijn' and 'hebben'", priority: .high),
            GrammarRecommendation(id: "2", title: "Review Word Order", description: "Master Dutch sentence structure", priority: .medium),
            GrammarRecommendation(id: "3", title: "Learn Past Tense", description: "Move to A2 level with past tense conjugation", priority: .low)
        ]
    }
    
    // MARK: - Helper Methods
    
    private func progressForLevel(_ level: LanguageLevel) -> Double {
        let levelRules = questionManager.getRulesByLevel(level)
        // This would calculate actual user progress for the level
        return Double.random(in: 0.0...1.0) // Placeholder
    }
    
    private func completedRulesForLevel(_ level: LanguageLevel) -> Int {
        let levelRules = questionManager.getRulesByLevel(level)
        // This would return actual completed rules count
        return Int.random(in: 0...levelRules.count) // Placeholder
    }
    
    private func totalRulesForLevel(_ level: LanguageLevel) -> Int {
        return questionManager.getRulesByLevel(level).count
    }
}

// MARK: - Supporting Views

struct ProgressCard: View {
    let title: String
    let progress: Double
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct QuickActionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LevelProgressCard: View {
    let level: LanguageLevel
    let progress: Double
    let completedRules: Int
    let totalRules: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(level.rawValue.uppercased())
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(levelColor)
            
            ProgressView(value: progress, total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: levelColor))
            
            Text("\(completedRules)/\(totalRules) rules")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 120)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var levelColor: Color {
        switch level {
        case .a1: return .green
        case .a2: return .blue
        case .b1: return .orange
        }
    }
}

struct IntegrationCard: View {
    let title: String
    let subtitle: String
    let progress: Double
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(color)
                
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .frame(width: 60)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ActivityRow: View {
    let activity: GrammarActivity
    
    var body: some View {
        HStack {
            Image(systemName: activity.type.icon)
                .foregroundColor(activity.type.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let score = activity.score {
                Text("\(score)%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(scoreColor(score))
            }
        }
        .padding(.vertical, 4)
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return .green }
        if score >= 70 { return .orange }
        return .red
    }
}

struct RecommendationCard: View {
    let recommendation: GrammarRecommendation
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recommendation.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(recommendation.priority.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(recommendation.priority.color.opacity(0.2))
                        .foregroundColor(recommendation.priority.color)
                        .cornerRadius(4)
                }
                
                Text(recommendation.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Supporting Models

struct GrammarActivity: Identifiable {
    let id: String
    let type: ActivityType
    let title: String
    let timestamp: Date
    let score: Int?
    
    enum ActivityType {
        case practice, rule, quiz
        
        var icon: String {
            switch self {
            case .practice: return "pencil.circle.fill"
            case .rule: return "book.circle.fill"
            case .quiz: return "questionmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .practice: return .blue
            case .rule: return .green
            case .quiz: return .orange
            }
        }
    }
}

struct GrammarRecommendation: Identifiable {
    let id: String
    let title: String
    let description: String
    let priority: Priority
    
    enum Priority: String, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            }
        }
    }
}

// MARK: - Placeholder Views

struct VocabularyGrammarIntegrationView: View {
    var body: some View {
        Text("Vocabulary Grammar Integration")
            .navigationTitle("Vocabulary Integration")
    }
}

struct GrammarProgressAnalyticsView: View {
    var body: some View {
        Text("Grammar Progress Analytics")
            .navigationTitle("Progress Analytics")
    }
}

struct GrammarPracticeSessionView: View {
    var body: some View {
        Text("Grammar Practice Session")
            .navigationTitle("Practice Session")
    }
}

// MARK: - Preview

struct GrammarLearningDashboard_Previews: PreviewProvider {
    static var previews: some View {
        GrammarLearningDashboard()
    }
} 