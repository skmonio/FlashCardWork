import SwiftUI
import Charts

struct StudySessionResultsView: View {
    let session: StudySession
    let viewModel: FlashCardViewModel
    let sessionXP: Int // Add sessionXP parameter
    let onStudyAgain: () -> Void
    let onReviewUnknown: () -> Void
    let onDone: () -> Void
    
    @StateObject private var statsManager = StatisticsManager.shared
    @StateObject private var userProfile = UserProfileManager.shared
    @State private var xpGained: Int = 0
    @State private var showingXPAnimation = false
    @State private var animatedProgress: Double = 0
    @State private var showingFloatingXP = false
    @State private var floatingXPPosition = CGPoint(x: 200, y: 100)
    @State private var previousXP: Int = 0
    @State private var previousLevel: Int = 1
    @State private var previousProgress: Double = 0
    @Environment(\.dismiss) private var dismiss
    @State private var showingAchievementModal = false
    @State private var achievementToShow: Achievement?
    @State private var displayedLevel: Int = 1
    @State private var isLevelUpEffect: Bool = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("Great job! You've made progress on your learning journey.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // XP Gain Section
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            // Centered XP Earned
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title2)
                                    Text("\(xpGained) XP")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            // XP Progress Bar (animated from previous to new progress)
                            VStack(spacing: 8) {
                                HStack {
                                    Text("Level \(displayedLevel)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .scaleEffect(isLevelUpEffect ? 1.3 : 1.0)
                                        .animation(.easeInOut(duration: 0.3), value: isLevelUpEffect)
                                    Spacer()
                                    Text("Level \(displayedLevel + 1)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        // Background
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 12)
                                        
                                        // Progress bar
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(LinearGradient(
                                                gradient: Gradient(colors: [.blue, .purple]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                            .frame(width: geometry.size.width * animatedProgress, height: 12)
                                    }
                                }
                                .frame(height: 12)
                                .animation(.easeInOut(duration: 1.5), value: animatedProgress)
                                
                                HStack {
                                    Text("\(userProfile.xp) XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(userProfile.xpForLevel(userProfile.level + 1)) XP")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.secondarySystemGroupedBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Session Summary Card
                    SessionSummaryCard(session: session)
                        .padding(.top, 8)
                    
                    // Action Buttons
                    ActionButtonsView(
                        session: session,
                        onStudyAgain: onStudyAgain,
                        onReviewUnknown: onReviewUnknown,
                        onDone: onDone
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            
            // Floating XP Animation - REMOVED to fix yellow button issue
            // if showingFloatingXP {
            //     FloatingXPNotificationView(
            //         amount: xpGained,
            //         position: floatingXPPosition,
            //         isShowing: $showingFloatingXP
            //     )
            // }
        }
        .navigationTitle("Session Complete")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay(
            GlobalNotificationOverlay()
        )
        .onAppear {
            setupAnimations()
        }
    }
    
    private func setupAnimations() {
        xpGained = sessionXP // Use sessionXP directly
        previousLevel = userProfile.level
        previousXP = userProfile.xp
        let oldXP = previousXP
        let newXP = previousXP + xpGained
        let oldLevel = userProfile.calculateLevel(forXP: oldXP)
        let newLevel = userProfile.calculateLevel(forXP: newXP)
        let levelsGained = newLevel - oldLevel
        let oldLevelXP = userProfile.xpForLevel(oldLevel)
        let newLevelXP = userProfile.xpForLevel(newLevel)
        let finalProgress = Double(newXP - newLevelXP) / Double(userProfile.xpForLevel(newLevel + 1) - newLevelXP)

        displayedLevel = oldLevel
        animatedProgress = Double(oldXP - oldLevelXP) / Double(userProfile.xpForLevel(oldLevel + 1) - oldLevelXP)

        awardXPAndTrackAchievements()

        func animateLevel(level: Int, remaining: Int) {
            withAnimation(.easeInOut(duration: 1.0)) {
                animatedProgress = 1.0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // Level up effect
                isLevelUpEffect = true
                withAnimation(.easeInOut(duration: 0.3)) {
                    // Quick scale or color flash
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    isLevelUpEffect = false
                    displayedLevel += 1
                    
                    // Instant reset without backward animation
                    animatedProgress = 0.0
                    
                    // Continue with next level or final progress
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if remaining > 1 {
                            animateLevel(level: level + 1, remaining: remaining - 1)
                        } else {
                            // Final fill to correct progress
                            withAnimation(.easeInOut(duration: 1.0)) {
                                animatedProgress = finalProgress
                            }
                        }
                    }
                }
            }
        }

        // Start animation after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if levelsGained > 0 {
                animateLevel(level: oldLevel, remaining: levelsGained)
            } else {
                withAnimation(.easeInOut(duration: 1.0)) {
                    animatedProgress = finalProgress
                }
            }
        }
    }
    
    private func showFloatingXPGain() {
        // Remove floating XP notification to avoid yellow button issue
        // showingFloatingXP = true
        // DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        //     showingFloatingXP = false
        // }
    }
    
    private func calculateXPGained() {
        // Use sessionXP that was tracked during the game session
        xpGained = sessionXP
    }
    
    private func awardXPAndTrackAchievements() {
        // Award XP - achievements are automatically checked and notifications shown by UserProfileManager.addXP()
        userProfile.addXP(xpGained)
        
        // No need to track achievements here since UserProfileManager handles all achievement notifications
        // This prevents double notifications
    }
}

struct SessionSummaryCard: View {
    let session: StudySession
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Session Summary")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "checkmark.circle.fill",
                    color: .green,
                    title: "Known",
                    value: "\(session.knownCards)",
                    subtitle: "\(session.accuracyPercentage)%"
                )
                
                StatItem(
                    icon: "xmark.circle.fill",
                    color: .red,
                    title: "Need Review",
                    value: "\(session.unknownCards)",
                    subtitle: "Practice more"
                )
                
                StatItem(
                    icon: "minus.circle.fill",
                    color: .blue,
                    title: "Skipped",
                    value: "\(session.skippedCards)",
                    subtitle: "For later"
                )
            }
            
            if session.duration > 0 {
                HStack {
                    Image(systemName: "clock.fill")
                        .foregroundColor(.orange)
                    Text("Session Duration: \(formatDuration(session.duration))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

struct StatItem: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct QuickStatsGrid: View {
    let session: StudySession
    let statsManager: StatisticsManager
    
    var body: some View {
        let weeklyStats = statsManager.getSessionStatistics(for: 7)
        
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            QuickStatCard(
                icon: "target",
                title: "Accuracy",
                value: "\(weeklyStats.accuracyPercentage)%",
                subtitle: "this week",
                color: .green
            )
            
            QuickStatCard(
                icon: "speedometer",
                title: "Avg Time/Card",
                value: weeklyStats.formattedAverageTimePerCard,
                subtitle: "this week",
                color: .purple
            )
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .bold()
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct StreakCard: View {
    let statsManager: StatisticsManager
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "flame.fill")
                .font(.title)
                .foregroundColor(.orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Current Streak")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("\(statsManager.currentStreak) days")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.orange)
                
                if statsManager.longestStreak > statsManager.currentStreak {
                    Text("Longest: \(statsManager.longestStreak) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Streak visualization
            HStack(spacing: 4) {
                ForEach(0..<min(statsManager.currentStreak, 7), id: \.self) { index in
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 8, height: 8)
                }
                
                if statsManager.currentStreak > 7 {
                    Text("+\(statsManager.currentStreak - 7)")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ActionButtonsView: View {
    let session: StudySession
    let onStudyAgain: () -> Void
    let onReviewUnknown: () -> Void
    let onDone: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onStudyAgain) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Study All Cards Again")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(12)
            }
            
            if session.unknownCards > 0 {
                Button(action: onReviewUnknown) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Review Unknown Cards (\(session.unknownCards))")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal, 40)
    }
}

struct DetailedAnalyticsView: View {
    let viewModel: FlashCardViewModel
    @StateObject private var statsManager = StatisticsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Learning Curve Chart
                    LearningCurveChart(statsManager: statsManager)
                    
                    // Weakest Areas
                    WeakestAreasSection(viewModel: viewModel, statsManager: statsManager)
                    
                    // Deck Performance
                    DeckPerformanceSection(viewModel: viewModel, statsManager: statsManager)
                    
                    // Study Time Breakdown
                    StudyTimeBreakdownSection(statsManager: statsManager)
                }
                .padding()
            }
            .navigationTitle("Detailed Analytics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct LearningCurveChart: View {
    let statsManager: StatisticsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Progress (30 Days)")
                .font(.headline)
                .foregroundColor(.primary)
            
            let learningCurve = statsManager.getLearningCurve(for: 30)
            
            if learningCurve.isEmpty {
                Text("No data available yet. Complete more study sessions to see your learning curve!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
            } else {
                Chart(learningCurve) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(.blue)
                    .interpolationMethod(.catmullRom)
                    
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Accuracy", point.accuracy)
                    )
                    .foregroundStyle(.blue.opacity(0.1))
                }
                .frame(height: 200)
                .chartYScale(domain: 0...1)
                .chartYAxis {
                    AxisMarks(values: [0, 0.25, 0.5, 0.75, 1.0]) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let doubleValue = value.as(Double.self) {
                                Text("\(Int(doubleValue * 100))%")
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month().day())
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct WeakestAreasSection: View {
    let viewModel: FlashCardViewModel
    let statsManager: StatisticsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weakest Areas")
                .font(.headline)
                .foregroundColor(.primary)
            
            let weakestAreas = statsManager.getWeakestAreas(viewModel: viewModel, limit: 5)
            
            if weakestAreas.isEmpty {
                Text("No weak areas identified yet. Keep studying to see your weakest cards!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(weakestAreas) { area in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(area.card.word)
                                .font(.subheadline)
                                .bold()
                            
                            Text(area.card.definition)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(area.weaknessPercentage)%")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.red)
                            
                            Text("weak")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct DeckPerformanceSection: View {
    let viewModel: FlashCardViewModel
    let statsManager: StatisticsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deck Performance")
                .font(.headline)
                .foregroundColor(.primary)
            
            let deckPerformance = statsManager.getDeckPerformance(viewModel: viewModel)
            
            if deckPerformance.isEmpty {
                Text("No deck performance data available.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ForEach(deckPerformance.prefix(5)) { deck in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(deck.deckName)
                                .font(.subheadline)
                                .bold()
                            
                            Text("\(deck.knownCards)/\(deck.totalCards) cards")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(deck.accuracyPercentage)%")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(deck.accuracy >= 0.8 ? .green : deck.accuracy >= 0.6 ? .orange : .red)
                            
                            Text("accuracy")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct StudyTimeBreakdownSection: View {
    let statsManager: StatisticsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study Time Breakdown")
                .font(.headline)
                .foregroundColor(.primary)
            
            let breakdown = statsManager.getStudyTimeBreakdown()
            
            VStack(spacing: 8) {
                TimeBreakdownRow(title: "Today", time: breakdown.formattedToday, color: .blue)
                TimeBreakdownRow(title: "This Week", time: breakdown.formattedThisWeek, color: .green)
                TimeBreakdownRow(title: "This Month", time: breakdown.formattedThisMonth, color: .orange)
                TimeBreakdownRow(title: "Total", time: breakdown.formattedTotal, color: .purple)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

struct TimeBreakdownRow: View {
    let title: String
    let time: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(time)
                .font(.subheadline)
                .bold()
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
} 