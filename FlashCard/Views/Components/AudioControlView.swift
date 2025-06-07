import SwiftUI

struct AudioControlView: View {
    let cardId: UUID
    let mode: AudioMode
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingPermissionAlert = false
    
    enum AudioMode {
        case record       // Show record/stop buttons
        case playOnly     // Show play button only
        case full         // Show both record and play
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Recording controls
            if mode == .record || mode == .full {
                recordingControls
            }
            
            // Playback controls
            if mode == .playOnly || mode == .full {
                playbackControls
            }
        }
        .alert("Microphone Permission Required", isPresented: $showingPermissionAlert) {
            Button("OK") { }
        } message: {
            Text("Please enable microphone access in Settings to record audio for your flashcards.")
        }
    }
    
    @ViewBuilder
    private var recordingControls: some View {
        if audioManager.isRecording {
            // Recording in progress
            HStack(spacing: 12) {
                Button(action: {
                    audioManager.stopRecording()
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Recording...")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text(audioManager.formatTime(audioManager.recordingTime))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Recording indicator
                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .opacity(0.8)
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: audioManager.isRecording)
            }
        } else {
            // Record button
            Button(action: {
                if audioManager.hasPermission {
                    audioManager.startRecording(for: cardId)
                } else {
                    showingPermissionAlert = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: audioManager.audioExists(for: cardId) ? "mic.fill" : "mic")
                        .foregroundColor(audioManager.audioExists(for: cardId) ? .blue : .gray)
                    
                    Text(audioManager.audioExists(for: cardId) ? "Re-record" : "Record")
                        .font(.caption)
                        .foregroundColor(audioManager.audioExists(for: cardId) ? .blue : .gray)
                }
            }
            .buttonStyle(.bordered)
            .disabled(!audioManager.hasPermission)
        }
    }
    
    @ViewBuilder
    private var playbackControls: some View {
        if audioManager.audioExists(for: cardId) {
            HStack(spacing: 12) {
                // Play/Stop button
                Button(action: {
                    if audioManager.isPlaying {
                        audioManager.stopPlayback()
                    } else {
                        audioManager.playAudio(for: cardId)
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: audioManager.isPlaying ? "stop.circle.fill" : "play.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title2)
                        
                        if let duration = audioManager.getRecordingDuration(for: cardId) {
                            Text(audioManager.formatTime(duration))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Delete audio button (only in full mode)
                if mode == .full {
                    Button(action: {
                        audioManager.deleteAudio(for: cardId)
                        audioManager.stopPlayback()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                }
            }
        } else if mode == .playOnly {
            HStack(spacing: 6) {
                Image(systemName: "speaker.slash")
                    .foregroundColor(.gray)
                Text("No audio")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct AudioControlView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AudioControlView(cardId: UUID(), mode: .record)
            AudioControlView(cardId: UUID(), mode: .playOnly)
            AudioControlView(cardId: UUID(), mode: .full)
        }
        .padding()
    }
} 