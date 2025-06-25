import Foundation
import SwiftUI

class SmartStudyManager: ObservableObject {
    static let shared = SmartStudyManager()
    
    @Published var currentStudyMode: StudyMode = .adaptive
    @Published var currentRound: Int = 1
    @Published var totalRounds: Int = 1
    
    private init() {}
    
    // MARK: - Study Mode Management
    
    func getSettings(for mode: StudyMode) -> StudyModeSettings {
        return StudyModeSettings.defaultSettings(for: mode)
    }
    
    func startStudySession(mode: StudyMode) {
        currentStudyMode = mode
        let settings = getSettings(for: mode)
        currentRound = 1
        totalRounds = settings.rounds
    }
    
    func nextRound() -> Bool {
        if currentRound < totalRounds {
            currentRound += 1
            return true
        }
        return false
    }
    
    func resetSession() {
        currentRound = 1
    }
    
    // MARK: - Card Sorting and Filtering
    
    func sortCardsForStudyMode(_ cards: [FlashCard], mode: StudyMode) -> [FlashCard] {
        switch mode {
        case .adaptive:
            return sortCardsForAdaptiveMode(cards)
        case .cram:
            return sortCardsForCramMode(cards)
        case .maintenance:
            return sortCardsForMaintenanceMode(cards)
        }
    }
    
    func filterCardsForStudyMode(_ cards: [FlashCard], mode: StudyMode) -> [FlashCard] {
        switch mode {
        case .adaptive:
            // Include all cards, but prioritize struggling ones
            return cards
        case .cram:
            // Include all cards for intensive review
            return cards
        case .maintenance:
            // Only include cards that are learned but need maintenance (70-90% learning percentage)
            return cards.filter { card in
                let percentage = card.learningPercentage ?? 0
                return percentage >= 70 && percentage <= 90
            }
        }
    }
    
    // MARK: - Mode-Specific Sorting
    
    /// Adaptive Mode: Focus on cards you struggle with
    private func sortCardsForAdaptiveMode(_ cards: [FlashCard]) -> [FlashCard] {
        return cards.sorted { card1, card2 in
            let score1 = calculateAdaptiveScore(for: card1)
            let score2 = calculateAdaptiveScore(for: card2)
            
            if score1 == score2 {
                return Bool.random()
            }
            
            return score1 < score2
        }
    }
    
    /// Cram Mode: Intensive review - show all cards, prioritize by difficulty
    private func sortCardsForCramMode(_ cards: [FlashCard]) -> [FlashCard] {
        return cards.sorted { card1, card2 in
            let score1 = calculateCramScore(for: card1)
            let score2 = calculateCramScore(for: card2)
            
            if score1 == score2 {
                return Bool.random()
            }
            
            return score1 < score2
        }
    }
    
    /// Maintenance Mode: Keep learned cards fresh
    private func sortCardsForMaintenanceMode(_ cards: [FlashCard]) -> [FlashCard] {
        return cards.sorted { card1, card2 in
            let score1 = calculateMaintenanceScore(for: card1)
            let score2 = calculateMaintenanceScore(for: card2)
            
            if score1 == score2 {
                return Bool.random()
            }
            
            return score1 < score2
        }
    }
    
    // MARK: - Score Calculations
    
    /// Calculate adaptive mode score (focus on struggling cards)
    private func calculateAdaptiveScore(for card: FlashCard) -> Int {
        let percentage = card.learningPercentage ?? 0
        let timesShown = card.timesShown
        let consecutiveIncorrect = card.consecutiveIncorrect
        
        // Base score: lower percentage = higher priority
        var score = 100 - percentage
        
        // Heavy penalty for consecutive incorrect answers
        score += consecutiveIncorrect * 50
        
        // Bonus for cards that haven't been shown much (they might be forgotten)
        if timesShown == 0 {
            score += 200 // Highest priority for unseen cards
        } else if timesShown < 3 {
            score += 100 // High priority for rarely seen cards
        }
        
        // Penalty for cards that are doing well
        if percentage > 80 {
            score -= 50
        }
        
        return score
    }
    
    /// Calculate cram mode score (intensive review)
    private func calculateCramScore(for card: FlashCard) -> Int {
        let percentage = card.learningPercentage ?? 0
        let lastReviewDate = card.lastReviewDate ?? Date.distantPast
        let daysSinceReview = Calendar.current.dateComponents([.day], from: lastReviewDate, to: Date()).day ?? 0
        
        // Base score: prioritize cards that need review
        var score = 100 - percentage
        
        // Bonus for cards that haven't been reviewed recently
        score += daysSinceReview * 10
        
        // Ensure all cards get some priority, but struggling ones get more
        if percentage < 50 {
            score += 100
        } else if percentage < 70 {
            score += 50
        }
        
        return score
    }
    
    /// Calculate maintenance mode score (keep learned cards fresh)
    private func calculateMaintenanceScore(for card: FlashCard) -> Int {
        let percentage = card.learningPercentage ?? 0
        let lastReviewDate = card.lastReviewDate ?? Date.distantPast
        let daysSinceReview = Calendar.current.dateComponents([.day], from: lastReviewDate, to: Date()).day ?? 0
        
        // Only consider cards in the maintenance range (70-90%)
        guard percentage >= 70 && percentage <= 90 else {
            return 1000 // Low priority for cards outside maintenance range
        }
        
        // Base score: prioritize cards that haven't been reviewed recently
        var score = daysSinceReview * 20
        
        // Slight penalty for very well-known cards
        if percentage > 85 {
            score -= 20
        }
        
        return score
    }
    
    // MARK: - SRS Integration
    
    func getSRSMultiplier(for mode: StudyMode) -> Double {
        switch mode {
        case .adaptive:
            return 1.0 // Normal spacing
        case .cram:
            return 0.5 // Shorter spacing for intensive review
        case .maintenance:
            return 1.5 // Longer spacing for maintenance
        }
    }
    
    func adjustSRSInterval(_ interval: TimeInterval, for mode: StudyMode) -> TimeInterval {
        return interval * getSRSMultiplier(for: mode)
    }
} 