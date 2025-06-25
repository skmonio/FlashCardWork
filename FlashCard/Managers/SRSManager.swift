import Foundation

/// Manages the Spaced Repetition System (SRS) algorithm
/// Based on the SuperMemo 2 algorithm with some modifications
class SRSManager: ObservableObject {
    static let shared = SRSManager()
    
    private init() {}
    
    // MARK: - SRS Configuration
    
    /// Minimum ease factor (prevents cards from becoming too difficult)
    private let minEaseFactor: Double = 1.3
    
    /// Maximum ease factor (prevents cards from becoming too easy)
    private let maxEaseFactor: Double = 5.0
    
    /// Ease factor bonus for correct answers
    private let easeFactorBonus: Double = 0.1
    
    /// Ease factor penalty for incorrect answers
    private let easeFactorPenalty: Double = 0.15
    
    /// Learning intervals in minutes for new cards
    private let learningIntervals: [Int] = [1, 10, 60, 1440] // 1min, 10min, 1hr, 1day
    
    // MARK: - Review Quality Enum
    
    enum ReviewQuality: Int, CaseIterable {
        case again = 1      // Complete blackout
        case hard = 2       // Incorrect response
        case good = 3       // Correct response with effort
        case easy = 4       // Correct response with ease
        case perfect = 5    // Perfect response
        
        var description: String {
            switch self {
            case .again: return "Again"
            case .hard: return "Hard"
            case .good: return "Good"
            case .easy: return "Easy"
            case .perfect: return "Perfect"
            }
        }
        
        var color: String {
            switch self {
            case .again: return "red"
            case .hard: return "orange"
            case .good: return "blue"
            case .easy: return "green"
            case .perfect: return "purple"
            }
        }
    }
    
    // MARK: - Simple Review Quality Enum (for Know/Don't Know interface)
    
    enum SimpleReviewQuality: Int, CaseIterable {
        case dontKnow = 0   // I don't know it
        case know = 1       // I know it
        
        var description: String {
            switch self {
            case .dontKnow: return "I Don't Know"
            case .know: return "I Know It"
            }
        }
        
        var color: String {
            switch self {
            case .dontKnow: return "red"
            case .know: return "green"
            }
        }
        
        var icon: String {
            switch self {
            case .dontKnow: return "xmark.circle.fill"
            case .know: return "checkmark.circle.fill"
            }
        }
    }
    
    // MARK: - SRS Algorithm
    
    /// Process a card review and update its SRS state
    /// - Parameters:
    ///   - card: The card being reviewed
    ///   - quality: How well the user knew the card
    /// - Returns: Updated card with new SRS state
    func processReview(for card: FlashCard, quality: ReviewQuality) -> FlashCard {
        var updatedCard = card
        let now = Date()
        
        // Update review statistics
        updatedCard.totalReviews += 1
        updatedCard.lastReviewDate = now
        updatedCard.markAsModified()
        
        // Update consecutive counters
        switch quality {
        case .again, .hard:
            updatedCard.consecutiveIncorrect += 1
            updatedCard.consecutiveCorrect = 0
        case .good, .easy, .perfect:
            updatedCard.consecutiveCorrect += 1
            updatedCard.consecutiveIncorrect = 0
        }
        
        // Calculate new SRS level and interval
        let (newLevel, newInterval) = calculateNewLevelAndInterval(
            currentLevel: card.srsLevel,
            quality: quality,
            easeFactor: card.easeFactor
        )
        
        updatedCard.srsLevel = newLevel
        
        // Update ease factor
        updatedCard.easeFactor = calculateNewEaseFactor(
            currentEaseFactor: card.easeFactor,
            quality: quality
        )
        
        // Calculate next review date
        updatedCard.nextReviewDate = calculateNextReviewDate(
            from: now,
            interval: newInterval
        )
        
        return updatedCard
    }
    
    /// Process a simple card review (Know/Don't Know) with intelligent quality assessment
    /// - Parameters:
    ///   - card: The card being reviewed
    ///   - simpleQuality: Whether the user knows it or not
    /// - Returns: Updated card with new SRS state
    func processSimpleReview(for card: FlashCard, simpleQuality: SimpleReviewQuality) -> FlashCard {
        // Convert simple quality to detailed quality based on learning history
        let detailedQuality = determineDetailedQuality(for: card, simpleQuality: simpleQuality)
        
        // Process with the detailed quality
        return processReview(for: card, quality: detailedQuality)
    }
    
    /// Determine detailed quality based on simple input and learning history
    private func determineDetailedQuality(for card: FlashCard, simpleQuality: SimpleReviewQuality) -> ReviewQuality {
        switch simpleQuality {
        case .dontKnow:
            // Always treat as "again" for don't know
            return .again
            
        case .know:
            // Analyze learning history to determine quality level
            let learningScore = calculateLearningScore(for: card)
            
            if card.srsLevel == 0 {
                // First time reviewing - treat as "good"
                return .good
            } else if card.consecutiveCorrect >= 3 {
                // User has been consistently correct - treat as "easy"
                return .easy
            } else if learningScore > 0.7 {
                // High learning score - treat as "good"
                return .good
            } else if card.consecutiveCorrect > 0 {
                // Some correct answers - treat as "good"
                return .good
            } else {
                // First correct answer after mistakes - treat as "hard"
                return .hard
            }
        }
    }
    
    /// Calculate a learning score based on card history (0.0 to 1.0)
    private func calculateLearningScore(for card: FlashCard) -> Double {
        guard card.totalReviews > 0 else { return 0.0 }
        
        let correctRatio = Double(card.consecutiveCorrect) / Double(max(1, card.totalReviews))
        let recentPerformance = card.consecutiveCorrect > 0 ? 1.0 : 0.0
        
        // Weight recent performance more heavily
        return (correctRatio * 0.3) + (recentPerformance * 0.7)
    }
    
    /// Calculate new SRS level and interval based on review quality
    private func calculateNewLevelAndInterval(currentLevel: Int, quality: ReviewQuality, easeFactor: Double) -> (level: Int, interval: Int) {
        switch quality {
        case .again:
            // Reset to learning phase
            return (1, learningIntervals[0])
            
        case .hard:
            if currentLevel <= 3 {
                // Still in learning phase, move to next interval
                let nextIntervalIndex = min(currentLevel, learningIntervals.count - 1)
                return (currentLevel + 1, learningIntervals[nextIntervalIndex])
            } else {
                // In review phase, reduce interval
                let reducedInterval = max(1, Int(Double(currentInterval(for: currentLevel)) * 0.8))
                return (currentLevel, reducedInterval)
            }
            
        case .good:
            if currentLevel <= 3 {
                // Move to next learning interval
                let nextIntervalIndex = min(currentLevel, learningIntervals.count - 1)
                return (currentLevel + 1, learningIntervals[nextIntervalIndex])
            } else {
                // Move to next review interval
                let newInterval = Int(Double(currentInterval(for: currentLevel)) * easeFactor)
                return (currentLevel + 1, newInterval)
            }
            
        case .easy:
            if currentLevel <= 3 {
                // Skip learning phase, go to review
                let reviewInterval = Int(pow(easeFactor, 1.0).rounded())
                return (4, reviewInterval)
            } else {
                // Increase interval more than usual
                let newInterval = Int(Double(currentInterval(for: currentLevel)) * easeFactor * 1.3)
                return (currentLevel + 1, newInterval)
            }
            
        case .perfect:
            if currentLevel <= 3 {
                // Skip learning phase, go to review with bonus
                let reviewInterval = Int(pow(easeFactor, 1.5).rounded())
                return (4, reviewInterval)
            } else {
                // Significant interval increase
                let newInterval = Int(Double(currentInterval(for: currentLevel)) * easeFactor * 1.5)
                return (currentLevel + 1, newInterval)
            }
        }
    }
    
    /// Calculate the current interval for a given SRS level
    private func currentInterval(for level: Int) -> Int {
        switch level {
        case 0: return 0
        case 1: return 1
        case 2: return 6
        case 3: return 15
        default: return Int(pow(2.5, Double(level - 3)).rounded())
        }
    }
    
    /// Calculate new ease factor based on review quality
    private func calculateNewEaseFactor(currentEaseFactor: Double, quality: ReviewQuality) -> Double {
        var newEaseFactor = currentEaseFactor
        
        switch quality {
        case .again:
            newEaseFactor -= easeFactorPenalty * 2
        case .hard:
            newEaseFactor -= easeFactorPenalty
        case .good:
            // No change for good
            break
        case .easy:
            newEaseFactor += easeFactorBonus
        case .perfect:
            newEaseFactor += easeFactorBonus * 2
        }
        
        // Clamp to valid range
        return max(minEaseFactor, min(maxEaseFactor, newEaseFactor))
    }
    
    /// Calculate next review date based on interval
    private func calculateNextReviewDate(from date: Date, interval: Int) -> Date {
        return date.addingTimeInterval(TimeInterval(interval * 60)) // Convert minutes to seconds
    }
    
    // MARK: - Smart Study Mode Integration
    
    /// Adjust SRS interval based on study mode
    func adjustIntervalForStudyMode(_ interval: Int, mode: StudyMode) -> Int {
        let multiplier = SmartStudyManager.shared.getSRSMultiplier(for: mode)
        return Int(Double(interval) * multiplier)
    }
    
    /// Process a card review with study mode consideration
    func processReviewWithStudyMode(for card: FlashCard, quality: ReviewQuality, mode: StudyMode) -> FlashCard {
        var updatedCard = processReview(for: card, quality: quality)
        
        // Adjust the next review date based on study mode
        if let nextReviewDate = updatedCard.nextReviewDate {
            let adjustedInterval = adjustIntervalForStudyMode(
                Int(nextReviewDate.timeIntervalSince(Date()) / 60),
                mode: mode
            )
            updatedCard.nextReviewDate = Date().addingTimeInterval(TimeInterval(adjustedInterval * 60))
        }
        
        return updatedCard
    }
    
    /// Process a simple review with study mode consideration
    func processSimpleReviewWithStudyMode(for card: FlashCard, simpleQuality: SimpleReviewQuality, mode: StudyMode) -> FlashCard {
        var updatedCard = processSimpleReview(for: card, simpleQuality: simpleQuality)
        
        // Adjust the next review date based on study mode
        if let nextReviewDate = updatedCard.nextReviewDate {
            let adjustedInterval = adjustIntervalForStudyMode(
                Int(nextReviewDate.timeIntervalSince(Date()) / 60),
                mode: mode
            )
            updatedCard.nextReviewDate = Date().addingTimeInterval(TimeInterval(adjustedInterval * 60))
        }
        
        return updatedCard
    }
    
    // MARK: - Card Filtering
    
    /// Get cards that are due for review
    func getDueCards(from cards: [FlashCard]) -> [FlashCard] {
        return cards.filter { $0.isDueForReview }
    }
    
    /// Get new cards (never reviewed)
    func getNewCards(from cards: [FlashCard], limit: Int = 20) -> [FlashCard] {
        return cards.filter { $0.isNew }.prefix(limit).map { $0 }
    }
    
    /// Get learning cards (in learning phase)
    func getLearningCards(from cards: [FlashCard]) -> [FlashCard] {
        return cards.filter { $0.isLearning && $0.isDueForReview }
    }
    
    /// Get review cards (in review phase)
    func getReviewCards(from cards: [FlashCard]) -> [FlashCard] {
        return cards.filter { $0.isReviewing && $0.isDueForReview }
    }
    
    // MARK: - Statistics
    
    /// Get SRS statistics for a collection of cards
    func getSRSStatistics(for cards: [FlashCard]) -> SRSStatistics {
        let newCards = cards.filter { $0.isNew }.count
        let learningCards = cards.filter { $0.isLearning }.count
        let reviewCards = cards.filter { $0.isReviewing }.count
        let dueCards = cards.filter { $0.isDueForReview }.count
        
        let averageEaseFactor = cards.isEmpty ? 0 : cards.map { $0.easeFactor }.reduce(0, +) / Double(cards.count)
        
        return SRSStatistics(
            totalCards: cards.count,
            newCards: newCards,
            learningCards: learningCards,
            reviewCards: reviewCards,
            dueCards: dueCards,
            averageEaseFactor: averageEaseFactor
        )
    }
}

// MARK: - SRS Statistics

struct SRSStatistics {
    let totalCards: Int
    let newCards: Int
    let learningCards: Int
    let reviewCards: Int
    let dueCards: Int
    let averageEaseFactor: Double
    
    var learningProgress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(learningCards + reviewCards) / Double(totalCards)
    }
    
    var reviewProgress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(reviewCards) / Double(totalCards)
    }
} 