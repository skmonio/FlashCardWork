import AudioToolbox
import Foundation

class SoundManager {
    static let shared = SoundManager()
    
    private init() {}
    
    // MARK: - Settings Check
    private var isSoundEnabled: Bool {
        return SettingsManager.shared.isSoundEnabled
    }
    
    // MARK: - iOS System Sound IDs
    
    /// Tick sound for correct answers (green feedback)
    private let tickSoundID: SystemSoundID = 1057 // iOS tick sound
    
    /// Tock sound for incorrect answers (red feedback)  
    private let tockSoundID: SystemSoundID = 1306 // iOS tock sound
    
    // MARK: - Public Methods
    
    /// Play tick sound for correct answers
    func playCorrectSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(tickSoundID)
    }
    
    /// Play tock sound for incorrect answers
    func playIncorrectSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(tockSoundID)
    }
    
    /// Play a light system sound for button taps and interactions
    func playTapSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // iOS light tap sound
    }
    
    /// Play system sound for game completion/success
    func playSuccessSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1025) // iOS unlock/success sound
    }
    
    /// Play system sound for warnings/errors
    func playWarningSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1053) // iOS warning sound
    }
} 