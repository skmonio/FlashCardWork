import AudioToolbox
import Foundation

class SoundManager {
    static let shared = SoundManager()
    
    private init() {}
    
    // MARK: - iOS System Sound IDs
    
    /// Tick sound for correct answers (green feedback)
    private let tickSoundID: SystemSoundID = 1057 // iOS tick sound
    
    /// Tock sound for incorrect answers (red feedback)  
    private let tockSoundID: SystemSoundID = 1306 // iOS tock sound
    
    // MARK: - Public Methods
    
    /// Play tick sound for correct answers
    func playCorrectSound() {
        AudioServicesPlaySystemSound(tickSoundID)
    }
    
    /// Play tock sound for incorrect answers
    func playIncorrectSound() {
        AudioServicesPlaySystemSound(tockSoundID)
    }
    
    /// Play a light system sound for button taps and interactions
    func playTapSound() {
        AudioServicesPlaySystemSound(1104) // iOS light tap sound
    }
    
    /// Play system sound for game completion/success
    func playSuccessSound() {
        AudioServicesPlaySystemSound(1025) // iOS unlock/success sound
    }
    
    /// Play system sound for warnings/errors
    func playWarningSound() {
        AudioServicesPlaySystemSound(1053) // iOS warning sound
    }
} 