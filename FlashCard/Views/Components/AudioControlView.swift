import SwiftUI

struct AudioControlView: View {
    let cardId: UUID
    let mode: AudioMode
    @State private var audioManager: AudioManager?
    @State private var showingPermissionAlert = false
    @State private var showingSimulatorInfo = false
    @State private var showingDeleteConfirmation = false
    
    // Local state for immediate UI updates
    @State private var localIsRecording = false
    @State private var localRecordingTime: TimeInterval = 0
    @State private var recordingTimer: Timer?
    
    enum AudioMode {
        case record       // Show record/stop buttons
        case playOnly     // Show play button only
        case full         // Show both record and play
        case studyMode    // Simple audio icon for studying
        case recordOnly   // Show only recording controls, no playback
    }
    
    // Simulator detection
    private var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Study mode - simple audio icon
            if mode == .studyMode {
                studyModeControls
            } else {
                // Recording controls
                if mode == .record || mode == .full || mode == .recordOnly {
                    recordingControls
                }
                
                // Playback controls
                if mode == .playOnly || mode == .full {
                    playbackControls
                }
                
                // Simulator info button
                if isSimulator && (mode == .record || mode == .full || mode == .recordOnly) {
                    Button(action: {
                        showingSimulatorInfo = true
                    }) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
            }
        }
        .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
            Button("OK") { }
        } message: {
            Text("Please enable microphone access in Settings to record audio for your flashcards.")
        }
        .alert("Simulator Mode", isPresented: $showingSimulatorInfo) {
            Button("OK") { }
        } message: {
            Text("Audio recording is simulated in the iOS Simulator. For real audio recording, test on a physical device.")
        }
        .alert("Delete Audio", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                audioManager?.deleteAudio(for: cardId)
                audioManager?.stopPlayback()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this audio recording?")
        }
        .onAppear {
            // Safely initialize AudioManager
            DispatchQueue.main.async {
                do {
                    audioManager = AudioManager.shared
                } catch {
                    print("AudioControlView: Failed to initialize AudioManager: \(error)")
                    audioManager = nil
                }
            }
        }
        .onDisappear {
            // Clean up recording timer
            recordingTimer?.invalidate()
            recordingTimer = nil
            localIsRecording = false
        }
    }
    
    @ViewBuilder
    private var studyModeControls: some View {
        if audioManager?.audioExists(for: cardId) ?? false {
            Button(action: {
                if audioManager?.isPlaying ?? false {
                    audioManager?.stopPlayback()
                } else {
                    audioManager?.playAudio(for: cardId)
                }
            }) {
                Image(systemName: audioManager?.isPlaying ?? false ? "speaker.wave.2.fill" : "speaker.wave.2")
                    .foregroundColor(.blue)
                    .font(.title2)
                    .scaleEffect(audioManager?.isPlaying ?? false ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: audioManager?.isPlaying ?? false)
            }
            .buttonStyle(.plain)
        }
    }
    
    @ViewBuilder
    private var recordingControls: some View {
        if localIsRecording {
            // Recording in progress - prominent red button
            Button(action: {
                stopRecording()
            }) {
                HStack(spacing: 8) {
                    // Pulsing red circle
                    Circle()
                        .fill(Color.red)
                        .frame(width: 12, height: 12)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: localIsRecording)
                    
                    Text("Recording - Tap to Stop")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                    
                    Text(formatTime(localRecordingTime))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .monospacedDigit()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                )
            }
            .buttonStyle(.plain)
        } else {
            // Record/Re-record button
            Button(action: {
                startRecording()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: audioManager?.audioExists(for: cardId) ?? false ? "mic.fill" : "mic")
                        .foregroundColor(.blue)
                        .font(.system(size: 16))
                    
                    Text(audioManager?.audioExists(for: cardId) ?? false ? "Re-record" : (isSimulator ? "Record (Simulator)" : "Record"))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue.opacity(0.05)))
                )
            }
            .buttonStyle(.plain)
            .disabled(!(audioManager?.hasPermission ?? false))
        }
    }
    
    // MARK: - Recording Management
    
    private func startRecording() {
        guard let audioManager = audioManager else { return }
        
        if audioManager.hasPermission {
            // Update UI immediately
            localIsRecording = true
            localRecordingTime = 0
            
            // Start the recording timer
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                localRecordingTime += 0.1
            }
            
            // Start actual recording
            audioManager.startRecording(for: cardId)
        } else {
            showingPermissionAlert = true
        }
    }
    
    private func stopRecording() {
        // Update UI immediately
        localIsRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        // Stop actual recording
        audioManager?.stopRecording()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    @ViewBuilder
    private var playbackControls: some View {
        if audioManager?.audioExists(for: cardId) ?? false {
            HStack(spacing: 12) {
                // Play/Stop button
                Button(action: {
                    if audioManager?.isPlaying ?? false {
                        audioManager?.stopPlayback()
                    } else {
                        audioManager?.playAudio(for: cardId)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: audioManager?.isPlaying ?? false ? "stop.circle.fill" : "play.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        // Only show duration in full mode (not playOnly)
                        if mode == .full {
                            if let duration = audioManager?.getRecordingDuration(for: cardId) {
                                Text(audioManager?.formatTime(duration) ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .monospacedDigit()
                            }
                            
                            if isSimulator && (audioManager?.isPlaying ?? false) {
                                Text("(sim)")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Delete audio button (only in full mode)
                if mode == .full {
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }
        } else if mode == .playOnly {
            // Don't show anything in playOnly mode if no audio exists
            EmptyView()
        }
    }
}

struct AudioControlView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AudioControlView(cardId: UUID(), mode: .record)
            AudioControlView(cardId: UUID(), mode: .recordOnly)
            AudioControlView(cardId: UUID(), mode: .playOnly)
            AudioControlView(cardId: UUID(), mode: .full)
            AudioControlView(cardId: UUID(), mode: .studyMode)
        }
        .padding()
    }
} 