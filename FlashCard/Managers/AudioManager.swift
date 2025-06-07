import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    static let shared = AudioManager()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession!
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var hasPermission = false
    
    private var recordingTimer: Timer?
    
    override init() {
        super.init()
        setupRecordingSession()
    }
    
    // MARK: - Setup and Permissions
    
    private func setupRecordingSession() {
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            
            recordingSession.requestRecordPermission { [weak self] allowed in
                DispatchQueue.main.async {
                    self?.hasPermission = allowed
                }
            }
        } catch {
            print("Failed to set up recording session: \(error)")
        }
    }
    
    // MARK: - File Management
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func getAudioURL(for cardId: UUID) -> URL {
        return getDocumentsDirectory().appendingPathComponent("card_\(cardId.uuidString).m4a")
    }
    
    func audioExists(for cardId: UUID) -> Bool {
        let url = getAudioURL(for: cardId)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func deleteAudio(for cardId: UUID) {
        let url = getAudioURL(for: cardId)
        try? FileManager.default.removeItem(at: url)
    }
    
    // MARK: - Recording
    
    func startRecording(for cardId: UUID) {
        guard hasPermission else {
            print("No recording permission")
            return
        }
        
        let audioURL = getAudioURL(for: cardId)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingTime = 0
            
            // Start timer to track recording time
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder else { return }
                self.recordingTime = recorder.currentTime
            }
            
            HapticManager.shared.lightImpact()
        } catch {
            print("Could not start recording: \(error)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        HapticManager.shared.lightImpact()
    }
    
    // MARK: - Playback
    
    func playAudio(for cardId: UUID) {
        guard !isRecording else { return }
        
        let audioURL = getAudioURL(for: cardId)
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("Audio file does not exist for card: \(cardId)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
            isPlaying = true
            HapticManager.shared.lightImpact()
        } catch {
            print("Could not play audio: \(error)")
        }
    }
    
    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    // MARK: - Utility
    
    func getRecordingDuration(for cardId: UUID) -> TimeInterval? {
        let audioURL = getAudioURL(for: cardId)
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            return nil
        }
        
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            return audioPlayer.duration
        } catch {
            return nil
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - AVAudioRecorderDelegate

extension AudioManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("Recording failed")
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
    }
} 