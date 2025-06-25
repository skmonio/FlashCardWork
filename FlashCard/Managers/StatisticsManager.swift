import Foundation
import SwiftUI

class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    
    @Published var studySessions: [StudySession] = []
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var totalStudyTime: TimeInterval = 0
    
    private let userDefaultsKey = "StudySessions"
    private let streakKey = "CurrentStreak"
    private let longestStreakKey = "LongestStreak"
    private let totalStudyTimeKey = "TotalStudyTime"
    
    init() {
        loadData()
    }
    
    // MARK: - Study Session Management
    
    func startSession(deckIds: [UUID], cardCount: Int) -> StudySession {
        let session = StudySession(
            id: UUID(),
            startTime: Date(),
            deckIds: deckIds,
            totalCards: cardCount,
            knownCards: 0,
            unknownCards: 0,
            skippedCards: 0,
            duration: 0
        )
        return session
    }
    
    func endSession(_ session: StudySession, knownCards: Int, unknownCards: Int, skippedCards: Int) {
        var updatedSession = session
        updatedSession.endTime = Date()
        updatedSession.duration = updatedSession.endTime!.timeIntervalSince(session.startTime)
        updatedSession.knownCards = knownCards
        updatedSession.unknownCards = unknownCards
        updatedSession.skippedCards = skippedCards
        
        studySessions.append(updatedSession)
        updateStreak()
        totalStudyTime += updatedSession.duration
        saveData()
    }
    
    // MARK: - Analytics Methods
    
    func getSessionStatistics(for days: Int = 7) -> SessionStatistics {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recentSessions = studySessions.filter { $0.endTime ?? Date() >= cutoffDate }
        
        let totalSessions = recentSessions.count
        let totalCards = recentSessions.reduce(0) { $0 + $1.totalCards }
        let totalKnown = recentSessions.reduce(0) { $0 + $1.knownCards }
        let totalUnknown = recentSessions.reduce(0) { $0 + $1.unknownCards }
        let totalSkipped = recentSessions.reduce(0) { $0 + $1.skippedCards }
        let totalTime = recentSessions.reduce(0) { $0 + $1.duration }
        
        let accuracy = totalCards > 0 ? Double(totalKnown) / Double(totalCards) : 0
        let averageTimePerCard = totalCards > 0 ? totalTime / Double(totalCards) : 0
        
        return SessionStatistics(
            totalSessions: totalSessions,
            totalCards: totalCards,
            totalKnown: totalKnown,
            totalUnknown: totalUnknown,
            totalSkipped: totalSkipped,
            totalTime: totalTime,
            accuracy: accuracy,
            averageTimePerCard: averageTimePerCard,
            averageSessionLength: totalSessions > 0 ? totalTime / Double(totalSessions) : 0
        )
    }
    
    func getLearningCurve(for days: Int = 30) -> [LearningCurvePoint] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recentSessions = studySessions.filter { $0.endTime ?? Date() >= cutoffDate }
        
        // Group sessions by day
        let calendar = Calendar.current
        var dailyStats: [Date: (known: Int, total: Int)] = [:]
        
        for session in recentSessions {
            let day = calendar.startOfDay(for: session.endTime ?? session.startTime)
            let current = dailyStats[day] ?? (known: 0, total: 0)
            dailyStats[day] = (
                known: current.known + session.knownCards,
                total: current.total + session.totalCards
            )
        }
        
        // Convert to sorted array
        return dailyStats.sorted { $0.key < $1.key }.map { date, stats in
            LearningCurvePoint(
                date: date,
                accuracy: stats.total > 0 ? Double(stats.known) / Double(stats.total) : 0,
                cardsStudied: stats.total
            )
        }
    }
    
    func getWeakestAreas(viewModel: FlashCardViewModel, limit: Int = 10) -> [WeakestArea] {
        let cards = viewModel.flashCards
        
        // Calculate weakness score for each card
        let cardWeaknesses = cards.map { card in
            let weaknessScore = calculateWeaknessScore(for: card)
            return (card: card, score: weaknessScore)
        }
        
        // Sort by weakness score (highest first) and take top cards
        let weakestCards = cardWeaknesses
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { WeakestArea(card: $0.card, weaknessScore: $0.score) }
        
        return Array(weakestCards)
    }
    
    func getDeckPerformance(viewModel: FlashCardViewModel) -> [DeckPerformance] {
        var deckStats: [UUID: (name: String, totalCards: Int, knownCards: Int, unknownCards: Int)] = [:]
        
        for deck in viewModel.decks {
            let cards = deck.cards
            let totalCards = cards.count
            let knownCards = cards.filter { $0.learningPercentage ?? 0 >= 80 }.count
            let unknownCards = cards.filter { $0.learningPercentage ?? 0 < 50 }.count
            
            deckStats[deck.id] = (
                name: deck.name,
                totalCards: totalCards,
                knownCards: knownCards,
                unknownCards: unknownCards
            )
        }
        
        return deckStats.map { deckId, stats in
            DeckPerformance(
                deckId: deckId,
                deckName: stats.name,
                totalCards: stats.totalCards,
                knownCards: stats.knownCards,
                unknownCards: stats.unknownCards,
                accuracy: stats.totalCards > 0 ? Double(stats.knownCards) / Double(stats.totalCards) : 0
            )
        }.sorted { $0.accuracy > $1.accuracy }
    }
    
    func getStudyTimeBreakdown() -> StudyTimeBreakdown {
        let calendar = Calendar.current
        let now = Date()
        
        // Get sessions for different time periods
        let today = calendar.startOfDay(for: now)
        let thisWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let thisMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
        
        let todaySessions = studySessions.filter { $0.endTime ?? Date() >= today }
        let weekSessions = studySessions.filter { $0.endTime ?? Date() >= thisWeek }
        let monthSessions = studySessions.filter { $0.endTime ?? Date() >= thisMonth }
        
        return StudyTimeBreakdown(
            today: todaySessions.reduce(0) { $0 + $1.duration },
            thisWeek: weekSessions.reduce(0) { $0 + $1.duration },
            thisMonth: monthSessions.reduce(0) { $0 + $1.duration },
            total: totalStudyTime
        )
    }
    
    // MARK: - Helper Methods
    
    private func calculateWeaknessScore(for card: FlashCard) -> Double {
        let percentage = card.learningPercentage ?? 0
        let timesShown = card.timesShown
        let consecutiveIncorrect = card.consecutiveIncorrect
        
        // Base score from learning percentage (inverted - lower percentage = higher weakness)
        let percentageScore = (100.0 - Double(percentage)) / 100.0
        
        // Penalty for high consecutive incorrect
        let consecutivePenalty = min(Double(consecutiveIncorrect) * 0.2, 1.0)
        
        // Bonus for cards that haven't been shown much (they might be forgotten)
        let exposureBonus = timesShown == 0 ? 0.5 : max(0, (10.0 - Double(timesShown)) / 10.0)
        
        return percentageScore + consecutivePenalty + exposureBonus
    }
    
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        
        // Check if there was a session today
        let hasSessionToday = studySessions.contains { session in
            guard let endTime = session.endTime else { return false }
            return calendar.isDate(endTime, inSameDayAs: today)
        }
        
        // Check if there was a session yesterday
        let hasSessionYesterday = studySessions.contains { session in
            guard let endTime = session.endTime else { return false }
            return calendar.isDate(endTime, inSameDayAs: yesterday)
        }
        
        if hasSessionToday {
            if hasSessionYesterday {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
        }
        
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    // MARK: - Data Persistence
    
    private func saveData() {
        if let encoded = try? JSONEncoder().encode(studySessions) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
        UserDefaults.standard.set(currentStreak, forKey: streakKey)
        UserDefaults.standard.set(longestStreak, forKey: longestStreakKey)
        UserDefaults.standard.set(totalStudyTime, forKey: totalStudyTimeKey)
    }
    
    private func loadData() {
        if let savedSessions = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedSessions = try? JSONDecoder().decode([StudySession].self, from: savedSessions) {
            studySessions = decodedSessions
        }
        
        currentStreak = UserDefaults.standard.integer(forKey: streakKey)
        longestStreak = UserDefaults.standard.integer(forKey: longestStreakKey)
        totalStudyTime = UserDefaults.standard.double(forKey: totalStudyTimeKey)
    }
}

// MARK: - Data Models

struct StudySession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    var endTime: Date?
    let deckIds: [UUID]
    let totalCards: Int
    var knownCards: Int
    var unknownCards: Int
    var skippedCards: Int
    var duration: TimeInterval
    
    var accuracy: Double {
        let totalAnswered = knownCards + unknownCards
        return totalAnswered > 0 ? Double(knownCards) / Double(totalAnswered) : 0
    }
    
    var accuracyPercentage: Int {
        Int(accuracy * 100)
    }
}

struct SessionStatistics {
    let totalSessions: Int
    let totalCards: Int
    let totalKnown: Int
    let totalUnknown: Int
    let totalSkipped: Int
    let totalTime: TimeInterval
    let accuracy: Double
    let averageTimePerCard: TimeInterval
    let averageSessionLength: TimeInterval
    
    var accuracyPercentage: Int {
        return Int(accuracy * 100)
    }
    
    var formattedTotalTime: String {
        let hours = Int(totalTime) / 3600
        let minutes = Int(totalTime) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var formattedAverageTimePerCard: String {
        let seconds = Int(averageTimePerCard)
        if seconds < 60 {
            return "\(seconds)s"
        } else {
            let minutes = seconds / 60
            let remainingSeconds = seconds % 60
            return "\(minutes)m \(remainingSeconds)s"
        }
    }
}

struct LearningCurvePoint: Identifiable {
    let id = UUID()
    let date: Date
    let accuracy: Double
    let cardsStudied: Int
    
    var accuracyPercentage: Int {
        return Int(accuracy * 100)
    }
}

struct WeakestArea: Identifiable {
    let id = UUID()
    let card: FlashCard
    let weaknessScore: Double
    
    var weaknessPercentage: Int {
        return Int(weaknessScore * 100)
    }
}

struct DeckPerformance: Identifiable {
    let id = UUID()
    let deckId: UUID
    let deckName: String
    let totalCards: Int
    let knownCards: Int
    let unknownCards: Int
    let accuracy: Double
    
    var accuracyPercentage: Int {
        return Int(accuracy * 100)
    }
}

struct StudyTimeBreakdown {
    let today: TimeInterval
    let thisWeek: TimeInterval
    let thisMonth: TimeInterval
    let total: TimeInterval
    
    var formattedToday: String {
        let minutes = Int(today) / 60
        return "\(minutes)m"
    }
    
    var formattedThisWeek: String {
        let hours = Int(thisWeek) / 3600
        let minutes = Int(thisWeek) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var formattedThisMonth: String {
        let hours = Int(thisMonth) / 3600
        let minutes = Int(thisMonth) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var formattedTotal: String {
        let hours = Int(total) / 3600
        let minutes = Int(total) % 3600 / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - Smart Study Modes

enum StudyMode: String, CaseIterable, Codable {
    case adaptive = "adaptive"
    case cram = "cram"
    case maintenance = "maintenance"
    
    var displayName: String {
        switch self {
        case .adaptive: return "Adaptive"
        case .cram: return "Cram"
        case .maintenance: return "Maintenance"
        }
    }
    
    var description: String {
        switch self {
        case .adaptive: return "Focus on cards you struggle with"
        case .cram: return "Intensive review before tests"
        case .maintenance: return "Keep learned cards fresh"
        }
    }
    
    var icon: String {
        switch self {
        case .adaptive: return "brain.head.profile"
        case .cram: return "bolt.fill"
        case .maintenance: return "leaf.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .adaptive: return .blue
        case .cram: return .orange
        case .maintenance: return .green
        }
    }
}

struct StudyModeSettings {
    let mode: StudyMode
    let rounds: Int
    let focusPercentage: Double
    
    static func defaultSettings(for mode: StudyMode) -> StudyModeSettings {
        switch mode {
        case .adaptive:
            return StudyModeSettings(mode: mode, rounds: 1, focusPercentage: 0.3)
        case .cram:
            return StudyModeSettings(mode: mode, rounds: 3, focusPercentage: 1.0)
        case .maintenance:
            return StudyModeSettings(mode: mode, rounds: 1, focusPercentage: 0.7)
        }
    }
} 