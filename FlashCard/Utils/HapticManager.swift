import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Haptic Feedback Types
    
    /// Light impact for subtle feedback (card tap, button press)
    func lightImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    /// Medium impact for moderate feedback (card flip, selection)
    func mediumImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Heavy impact for strong feedback (correct answer, completion)
    func heavyImpact() {
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    /// Success notification (game won, test completed)
    func successNotification() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Warning notification (wrong answer, limited attempts)
    func warningNotification() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Error notification (game over, failed action)
    func errorNotification() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    /// Selection changed (deck selection, card selection)
    func selectionChanged() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.selectionChanged()
    }
    
    // MARK: - Context-Specific Feedback
    
    /// Card study interactions
    func cardSwipeLeft() {
        warningNotification() // Don't know this card
    }
    
    func cardSwipeRight() {
        successNotification() // Know this card
    }
    
    func cardFlip() {
        mediumImpact() // Card revealed
    }
    
    /// Test/Quiz interactions
    func correctAnswer() {
        successNotification()
        SoundManager.shared.playCorrectSound() // Add tick sound for correct answers
    }
    
    func wrongAnswer() {
        errorNotification()
        SoundManager.shared.playIncorrectSound() // Add tock sound for incorrect answers
    }
    
    func questionAdvance() {
        lightImpact()
    }
    
    /// Game interactions
    func cardMatch() {
        heavyImpact() // Memory game match
    }
    
    func cardMismatch() {
        mediumImpact() // Memory game no match
    }
    
    func gameComplete() {
        // Double success for emphasis
        successNotification()
        SoundManager.shared.playSuccessSound() // Add success sound for game completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.heavyImpact()
        }
    }
    
    /// Navigation interactions
    func buttonTap() {
        lightImpact()
    }
    
    func multiSelectToggle() {
        selectionChanged()
    }
    
    func bulkActionComplete() {
        mediumImpact()
    }
} 