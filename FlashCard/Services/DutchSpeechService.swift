#if !LITE_VERSION
import Foundation
import AVFoundation

@MainActor
class DutchSpeechService: NSObject, ObservableObject {
    static let shared = DutchSpeechService()
    
    private let synthesizer = AVSpeechSynthesizer()
    @Published var isSpeaking = false
    @Published var currentlySpeaking: String = ""
    
    // Speech settings optimized for language learning
    @Published var speechRate: Float = 0.4        // Slower for learning
    @Published var pitchMultiplier: Float = 1.0   // Normal pitch
    @Published var volume: Float = 1.0            // Full volume
    
    // Available Dutch voices
    @Published var availableDutchVoices: [AVSpeechSynthesisVoice] = []
    @Published var selectedVoice: AVSpeechSynthesisVoice?
    
    override init() {
        super.init()
        synthesizer.delegate = self
        loadDutchVoices()
    }
    
    /// Load available Dutch voices on the device
    private func loadDutchVoices() {
        availableDutchVoices = AVSpeechSynthesisVoice.speechVoices().filter { voice in
            voice.language.hasPrefix("nl") // Dutch language codes (nl-NL, nl-BE)
        }
        
        // Set default voice (prefer nl-NL if available)
        selectedVoice = availableDutchVoices.first { $0.language == "nl-NL" } 
                       ?? availableDutchVoices.first
                       ?? AVSpeechSynthesisVoice(language: "nl-NL")
        
        print("🔊 Found \(availableDutchVoices.count) Dutch voices")
        availableDutchVoices.forEach { voice in
            print("   - \(voice.name) (\(voice.language))")
        }
    }
    
    /// Speak Dutch text with current settings
    func speakDutch(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Stop any current speech
        stopSpeaking()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = selectedVoice
        utterance.rate = speechRate
        utterance.pitchMultiplier = pitchMultiplier
        utterance.volume = volume
        
        currentlySpeaking = text
        isSpeaking = true
        
        synthesizer.speak(utterance)
        
        print("🔊 Speaking Dutch: \"\(text)\"")
    }
    
    /// Speak with custom rate (useful for different learning modes)
    func speakDutch(_ text: String, rate: Float) {
        let originalRate = speechRate
        speechRate = rate
        speakDutch(text)
        speechRate = originalRate
    }
    
    /// Stop current speech
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    /// Pause current speech
    func pauseSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    /// Continue paused speech
    func continueSpeaking() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
        }
    }
    
    /// Check if Dutch TTS is available
    func isDutchTTSAvailable() -> Bool {
        return !availableDutchVoices.isEmpty
    }
    
    /// Get voice information for UI display
    func getVoiceDisplayName(for voice: AVSpeechSynthesisVoice) -> String {
        let countryFlag = voice.language == "nl-NL" ? "🇳🇱" : "🇧🇪"
        return "\(countryFlag) \(voice.name)"
    }
}

// MARK: - AVSpeechSynthesizerDelegate
extension DutchSpeechService: AVSpeechSynthesizerDelegate {
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentlySpeaking = ""
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.currentlySpeaking = ""
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        // Could add paused state if needed
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        // Could add continued state if needed
    }
}

#else
import Foundation
import SwiftUI

// MARK: - Stubbed Dutch Speech Service for Lite Version
@MainActor
class DutchSpeechService: NSObject, ObservableObject {
    static let shared = DutchSpeechService()
    
    @Published var isSpeaking = false
    @Published var currentlySpeaking: String = ""
    @Published var speechRate: Float = 0.4
    @Published var pitchMultiplier: Float = 1.0
    @Published var volume: Float = 1.0
    @Published var availableDutchVoices: [Any] = []
    @Published var selectedVoice: Any?
    
    override init() {
        super.init()
    }
    
    func speakDutch(_ text: String) {
        // No-op in lite version
    }
    
    func speakDutch(_ text: String, rate: Float) {
        // No-op in lite version
    }
    
    func stopSpeaking() {
        // No-op in lite version
    }
    
    func pauseSpeaking() {
        // No-op in lite version
    }
    
    func continueSpeaking() {
        // No-op in lite version
    }
    
    func isDutchTTSAvailable() -> Bool {
        return false
    }
    
    func getVoiceDisplayName(for voice: Any) -> String {
        return ""
    }
}
#endif 