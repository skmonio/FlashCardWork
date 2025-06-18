import AudioToolbox
import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var correctAudioPlayer: AVAudioPlayer?
    private var wrongAudioPlayer: AVAudioPlayer?
    private var gameAudioPlayer: AVAudioPlayer?
    private var completeAudioPlayer: AVAudioPlayer?
    
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
    
    /// Play begin.wav for splash screen transition
    func playBeginSound() {
        guard isSoundEnabled else { return }
        
        // Look for Begin.wav in the root of the bundle (since it was moved there)
        guard let url = Bundle.main.url(forResource: "Begin", withExtension: "wav") else {
            print("❌ Could not find Begin.wav in bundle")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("🔊 Playing Begin.wav")
        } catch {
            print("❌ Error playing Begin.wav: \(error)")
        }
    }
    
    /// Play Game.wav when user starts a game
    func playGameStartSound() {
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: "Game", withExtension: "wav") else {
            print("❌ Could not find Game.wav in bundle, falling back to tap sound")
            playTapSound() // Fallback to system sound
            return
        }
        
        do {
            gameAudioPlayer = try AVAudioPlayer(contentsOf: url)
            gameAudioPlayer?.play()
            print("🔊 Playing Game.wav")
        } catch {
            print("❌ Error playing Game.wav: \(error), falling back to tap sound")
            playTapSound() // Fallback to system sound
        }
    }
    
    /// Play Complete.wav for game completion (replaces old success sound)
    func playCompleteSound() {
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: "Complete", withExtension: "wav") else {
            print("❌ Could not find Complete.wav in bundle, falling back to system success sound")
            playSuccessSound() // Fallback to system sound
            return
        }
        
        do {
            completeAudioPlayer = try AVAudioPlayer(contentsOf: url)
            completeAudioPlayer?.play()
            print("🔊 Playing Complete.wav")
        } catch {
            print("❌ Error playing Complete.wav: \(error), falling back to system success sound")
            playSuccessSound() // Fallback to system sound
        }
    }
    
    /// Play custom Correct.wav for test game correct answers
    func playTestCorrectSound() {
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: "Correct", withExtension: "wav") else {
            print("❌ Could not find Correct.wav in bundle, falling back to system sound")
            playCorrectSound() // Fallback to system sound
            return
        }
        
        do {
            correctAudioPlayer = try AVAudioPlayer(contentsOf: url)
            correctAudioPlayer?.play()
            print("🔊 Playing Correct.wav")
        } catch {
            print("❌ Error playing Correct.wav: \(error), falling back to system sound")
            playCorrectSound() // Fallback to system sound
        }
    }
    
    /// Play custom Wrong.wav for test game incorrect answers
    func playTestWrongSound() {
        guard isSoundEnabled else { return }
        
        guard let url = Bundle.main.url(forResource: "Wrong", withExtension: "wav") else {
            print("❌ Could not find Wrong.wav in bundle, falling back to system sound")
            playIncorrectSound() // Fallback to system sound
            return
        }
        
        do {
            wrongAudioPlayer = try AVAudioPlayer(contentsOf: url)
            wrongAudioPlayer?.play()
            print("🔊 Playing Wrong.wav")
        } catch {
            print("❌ Error playing Wrong.wav: \(error), falling back to system sound")
            playIncorrectSound() // Fallback to system sound
        }
    }
    
    /// Play tick sound for correct answers (system sound - fallback)
    func playCorrectSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(tickSoundID)
    }
    
    /// Play tock sound for incorrect answers (system sound - fallback)
    func playIncorrectSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(tockSoundID)
    }
    
    /// Play a light system sound for button taps and interactions
    func playTapSound() {
        guard isSoundEnabled else { return }
        AudioServicesPlaySystemSound(1104) // iOS light tap sound
    }
    
    /// Play system sound for game completion/success (fallback - use playCompleteSound() instead)
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