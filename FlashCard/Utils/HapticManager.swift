import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Settings Check
    private var isHapticsEnabled: Bool {
        return SettingsManager.shared.isHapticsEnabled
    }
    
    // MARK: - Haptic Feedback Types
    
    /// Light impact for subtle feedback (card tap, button press)
    func lightImpact() {
        guard isHapticsEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    /// Medium impact for moderate feedback (card flip, selection)
    func mediumImpact() {
        guard isHapticsEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    /// Heavy impact for strong feedback (correct answer, completion)
    func heavyImpact() {
        guard isHapticsEnabled else { return }
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
    }
    
    /// Success notification (game won, test completed)
    func successNotification() {
        guard isHapticsEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
    
    /// Warning notification (wrong answer, limited attempts)
    func warningNotification() {
        guard isHapticsEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.warning)
    }
    
    /// Error notification (game over, failed action)
    func errorNotification() {
        guard isHapticsEnabled else { return }
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.error)
    }
    
    /// Selection changed (deck selection, card selection)
    func selectionChanged() {
        guard isHapticsEnabled else { return }
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
    
    /// Test game haptic-only feedback (for use with custom audio)
    func testCorrectHaptic() {
        successNotification() // Haptic only, no sound
    }
    
    func testWrongHaptic() {
        errorNotification() // Haptic only, no sound
    }
    
    func questionAdvance() {
        lightImpact()
    }
    
    /// Game interactions
    func cardMatch() {
        heavyImpact() // Memory game match
        // Use custom sound for games (not study mode)
        SoundManager.shared.playTestCorrectSound() // Custom Correct.wav for matches
    }
    
    func cardMismatch() {
        mediumImpact() // Memory game no match
        // Use custom sound for games (not study mode)
        SoundManager.shared.playTestWrongSound() // Custom Wrong.wav for mismatches
    }
    
    func gameComplete() {
        // Double success for emphasis
        successNotification()
        SoundManager.shared.playCompleteSound() // Use new Complete.wav sound for game completion
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