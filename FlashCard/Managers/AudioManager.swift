import Foundation
import AVFoundation

class AudioManager: NSObject, ObservableObject {
    private static var _shared: AudioManager?
    private static let initLock = NSLock()
    
    static var shared: AudioManager {
        initLock.lock()
        defer { initLock.unlock() }
        
        if let instance = _shared {
            return instance
        }
        
        do {
            let instance = AudioManager()
            _shared = instance
            return instance
        } catch {
            print("AudioManager: Failed to initialize - creating disabled instance")
            let disabledInstance = AudioManager()
            disabledInstance.isDisabled = true
            _shared = disabledInstance
            return disabledInstance
        }
    }
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingSession: AVAudioSession!
    
    @Published var isRecording = false
    @Published var isPlaying = false
    @Published var recordingTime: TimeInterval = 0
    @Published var hasPermission = false
    
    private var recordingTimer: Timer?
    private var isDisabled = false // Re-enabled now that permissions are properly configured
    
    // Simulator detection
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    override init() {
        super.init()
        do {
            try setupAudioManager()
        } catch {
            print("AudioManager: Failed to setup - disabling functionality")
            isDisabled = true
        }
    }
    
    private func setupAudioManager() throws {
        if !isSimulator {
            // Ensure setup happens on main thread
            DispatchQueue.main.async { [weak self] in
                do {
                    if let strongSelf = self {
                        try strongSelf.setupRecordingSession()
                    }
                } catch {
                    print("AudioManager: Failed to setup recording session - disabling")
                    self?.isDisabled = true
                }
            }
        } else {
            // In simulator, assume permission is granted but recording won't work
            hasPermission = true
            print("AudioManager: Running in simulator - audio recording disabled")
        }
    }
    
    // MARK: - Setup and Permissions
    
    /// Request microphone permission - only called when user actually tries to record
    func requestMicrophonePermission(completion: @escaping (Bool) -> Void = { _ in }) {
        guard !isSimulator else {
            // In simulator, assume permission is granted
            hasPermission = true
            completion(true)
            return
        }
        
        recordingSession.requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                self?.hasPermission = allowed
                if allowed {
                    print("AudioManager: Recording permission granted")
                } else {
                    print("AudioManager: Recording permission denied")
                }
                completion(allowed)
            }
        }
    }
    
    private func setupRecordingSession() throws {
        do {
            recordingSession = AVAudioSession.sharedInstance()
            
            // Use a more conservative category setup
            try recordingSession.setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth, .defaultToSpeaker])
            
            // Don't activate the session immediately - wait until we need to record
            print("AudioManager: Audio session category configured")
            
            // Don't request permission here - wait until user actually tries to record
            // This prevents the permission popup from appearing when just viewing cards
            
        } catch let error as NSError {
            print("AudioManager: Failed to set up recording session: \(error)")
            print("AudioManager: Error domain: \(error.domain), code: \(error.code)")
            
            // Handle specific AVAudioSession errors
            switch error.code {
            case AVAudioSession.ErrorCode.insufficientPriority.rawValue:
                print("AudioManager: Insufficient priority to interrupt other audio")
            case AVAudioSession.ErrorCode.resourceNotAvailable.rawValue:
                print("AudioManager: Audio resource not available")
            case AVAudioSession.ErrorCode.sessionNotActive.rawValue:
                print("AudioManager: Audio session not active")
            default:
                print("AudioManager: Audio session error - \(error.localizedDescription)")
            }
            
            hasPermission = false
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
        guard !isDisabled else {
            print("AudioManager: Disabled - returning false for audio exists")
            return false
        }
        
        let url = getAudioURL(for: cardId)
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    func deleteAudio(for cardId: UUID) {
        guard !isDisabled else {
            print("AudioManager: Disabled - cannot delete audio")
            return
        }
        
        let url = getAudioURL(for: cardId)
        try? FileManager.default.removeItem(at: url)
    }
    
    // MARK: - Recording Availability
    
    func canRecord() -> Bool {
        guard !isDisabled else {
            print("AudioManager: Disabled - cannot record")
            return false
        }
        
        guard !isRecording else {
            print("AudioManager: Already recording")
            return false
        }
        
        // Check if microphone is available
        guard AVAudioSession.sharedInstance().isInputAvailable else {
            print("AudioManager: No audio input available")
            return false
        }
        
        return true
    }
    
    // MARK: - Recording
    
    func startRecording(for cardId: UUID, completion: @escaping (Bool) -> Void = { _ in }) {
        guard !isDisabled else {
            print("AudioManager: Disabled - cannot start recording")
            completion(false)
            return
        }
        
        // Check if recording is possible
        guard canRecord() else {
            // If we don't have permission, request it first
            if !hasPermission {
                requestMicrophonePermission { [weak self] granted in
                    if granted {
                        // Permission granted, try recording again
                        self?.startRecording(for: cardId, completion: completion)
                    } else {
                        print("AudioManager: Permission denied - cannot record")
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
            return
        }
        
        // Simulator fallback - create a dummy file
        if isSimulator {
            print("AudioManager: Cannot record in simulator - creating dummy audio file")
            createDummyAudioFile(for: cardId)
            completion(true)
            return
        }
        
        // Ensure we're on main thread for audio session operations
        DispatchQueue.main.async { [weak self] in
            self?.performRecording(for: cardId, completion: completion)
        }
    }
    
    private func performRecording(for cardId: UUID, completion: @escaping (Bool) -> Void = { _ in }) {
        do {
            // Ensure audio session is properly configured
            let session = AVAudioSession.sharedInstance()
            
            // Try to activate the session first
            try session.setActive(true, options: [])
            
            let audioURL = getAudioURL(for: cardId)
            
            // Create directory if it doesn't exist
            let directory = audioURL.deletingLastPathComponent()
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            
            // Clean up any existing file
            if FileManager.default.fileExists(atPath: audioURL.path) {
                try FileManager.default.removeItem(at: audioURL)
            }
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
                AVEncoderBitRateKey: 64000
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.isMeteringEnabled = false
            
            guard let recorder = audioRecorder else {
                print("AudioManager: Failed to create audio recorder")
                completion(false)
                return
            }
            
            // Prepare the recorder
            guard recorder.prepareToRecord() else {
                print("AudioManager: Failed to prepare recorder")
                audioRecorder = nil
                completion(false)
                return
            }
            
            // Start recording
            guard recorder.record() else {
                print("AudioManager: Failed to start recording")
                audioRecorder = nil
                completion(false)
                return
            }
            
            isRecording = true
            recordingTime = 0
            
            // Start timer to track recording time
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let recorder = self.audioRecorder, recorder.isRecording else {
                    self?.stopRecording()
                    return
                }
                self.recordingTime = recorder.currentTime
            }
            
            HapticManager.shared.lightImpact()
            print("AudioManager: Recording started successfully")
            completion(true)
            
        } catch {
            print("AudioManager: Could not start recording: \(error)")
            print("AudioManager: Error details: \(error.localizedDescription)")
            audioRecorder = nil
            isRecording = false
            
            // Show user-friendly error handling
            DispatchQueue.main.async {
                // You could show an alert here if needed
                print("AudioManager: Recording failed - please try again")
                completion(false)
            }
        }
    }
    
    func stopRecording() {
        guard !isDisabled else {
            print("AudioManager: Disabled - cannot stop recording")
            return
        }
        
        if isSimulator {
            // Stop the simulated recording
            isRecording = false
            recordingTimer?.invalidate()
            recordingTimer = nil
            HapticManager.shared.lightImpact()
            return
        }
        
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            self?.performStopRecording()
        }
    }
    
    private func performStopRecording() {
        guard isRecording else {
            print("AudioManager: Not currently recording")
            return
        }
        
        // Stop and clean up the recorder
        if let recorder = audioRecorder {
            if recorder.isRecording {
                recorder.stop()
                print("AudioManager: Recording stopped successfully")
            }
        }
        
        audioRecorder = nil
        isRecording = false
        
        // Clean up timer
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Try to deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            print("AudioManager: Could not deactivate audio session: \(error)")
        }
        
        HapticManager.shared.lightImpact()
    }
    
    // MARK: - Playback
    
    func playAudio(for cardId: UUID) {
        guard !isDisabled else {
            print("AudioManager: Disabled - cannot play audio")
            return
        }
        
        guard !isRecording else { return }
        
        let audioURL = getAudioURL(for: cardId)
        
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            print("Audio file does not exist for card: \(cardId)")
            return
        }
        
        // Simulator fallback - just simulate playback
        if isSimulator {
            print("AudioManager: Simulating audio playback in simulator")
            simulatePlayback()
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
        guard !isDisabled else {
            print("AudioManager: Disabled - cannot stop playback")
            return
        }
        
        if isSimulator {
            isPlaying = false
            return
        }
        
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
    }
    
    // MARK: - Utility
    
    func getRecordingDuration(for cardId: UUID) -> TimeInterval? {
        if isSimulator {
            // Return a dummy duration for simulator
            return audioExists(for: cardId) ? 3.0 : nil
        }
        
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
    
    // MARK: - Simulator Helpers
    
    private func createDummyAudioFile(for cardId: UUID) {
        let audioURL = getAudioURL(for: cardId)
        
        // Create a small dummy file to simulate recorded audio
        let dummyData = Data("dummy audio".utf8)
        try? dummyData.write(to: audioURL)
        
        // Simulate recording process
        isRecording = true
        recordingTime = 0
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingTime += 0.1
            
            // Auto-stop after 3 seconds in simulator
            if self.recordingTime >= 3.0 {
                self.stopRecording()
            }
        }
    }
    
    private func simulatePlayback() {
        isPlaying = true
        HapticManager.shared.lightImpact()
        
        // Simulate 3 seconds of playback
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.isPlaying = false
        }
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