import SwiftUI
import Charts

struct StudySessionResultsView: View {
    let session: StudySession
    let viewModel: FlashCardViewModel
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
    @State private var unlockedAchievements: [Achievement] = []
    @State private var showAchievementsModal = false
    @Environment(\.dismiss) private var dismiss
    @State private var showingAchievementModal = false
    @State private var achievementToShow: Achievement?
    @State private var hasShownLevelUp = false
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("Study Session Complete! 🎉")
                            .font(.title)
                            .bold()
                            .multilineTextAlignment(.center)
                        
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
                                    Text("Level \(userProfile.level)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("Level \(userProfile.level + 1)")
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
            
            // Achievements Modal
            if showAchievementsModal && !unlockedAchievements.isEmpty {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showAchievementsModal = false }
                VStack(spacing: 20) {
                    Text("Achievements Unlocked!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    HStack(spacing: 16) {
                        ForEach(unlockedAchievements) { achievement in
                            AchievementBadgeView(achievement: achievement)
                        }
                    }
                    Button("Close") {
                        showAchievementsModal = false
                    }
                    .padding(.top, 8)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground)))
                .shadow(radius: 20)
            }
        }
        .navigationTitle("Session Complete!")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .overlay(
            GlobalNotificationOverlay()
        )
        .onAppear {
            setupAnimations()
        }
    }
    
    private func setupAnimations() {
        // Calculate XP gained
        calculateXPGained()
        
        // Store previous values for animation
        previousLevel = userProfile.level
        previousXP = userProfile.xp
        previousProgress = userProfile.progressToNextLevel
        
        // Award XP and track achievements
        awardXPAndTrackAchievements()
        
        // Start with previous progress
        animatedProgress = previousProgress
        
        // STEP 1: Animate XP progress bar first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 1.5)) {
                self.animatedProgress = self.userProfile.progressToNextLevel
            }
            
            // STEP 2: After progress bar animation, check for level up and show notifications
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if self.userProfile.level > self.previousLevel {
                    self.showLevelUpNotification()
                }
                
                // STEP 3: Check for achievements last
                self.checkForAchievements()
            }
        }
    }
    
    private func showLevelUpNotification() {
        if !hasShownLevelUp {
            hasShownLevelUp = true
            // Show level up notification using the user profile manager
            userProfile.showingLevelUpNotification = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                userProfile.showingLevelUpNotification = false
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
    
    private func checkForAchievements() {
        // Show achievements modal if any achievements were unlocked
        if !unlockedAchievements.isEmpty {
            showAchievementsModal = true
        }
    }
    
    private func calculateXPGained() {
        // Calculate XP based on session performance
        let baseXP = 50
        let performanceBonus = session.knownCards * 5 // 5 XP per known card
        xpGained = baseXP + performanceBonus
    }
    
    private func awardXPAndTrackAchievements() {
        // Track achievements before XP is awarded
        let achievementsBefore = Set(userProfile.achievements.filter { $0.isUnlocked }.map { $0.id })
        userProfile.addXP(xpGained)
        // Track achievements after XP is awarded
        let achievementsAfter = Set(userProfile.achievements.filter { $0.isUnlocked }.map { $0.id })
        let newAchievementIDs = achievementsAfter.subtracting(achievementsBefore)
        unlockedAchievements = userProfile.achievements.filter { newAchievementIDs.contains($0.id) }
        // Don't show achievements modal here - let the main animation sequence handle it
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
                .frame(maxWidth: .infinity)
                .padding()
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
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(12)
                }
            }
        }
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