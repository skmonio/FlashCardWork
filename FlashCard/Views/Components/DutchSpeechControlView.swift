import SwiftUI
import AVFoundation

struct DutchSpeechControlView: View {
    let text: String
    let mode: SpeechControlMode
    
    @StateObject private var speechService = DutchSpeechService.shared
    @State private var showingVoiceSelector = false
    
    enum SpeechControlMode {
        case compact    // Just a play button
        case full      // Play button + controls
        case minimal   // Tiny button for inline use
    }
    
    var body: some View {
        Group {
            switch mode {
            case .minimal:
                minimalView
            case .compact:
                compactView
            case .full:
                fullView
            }
        }
        .sheet(isPresented: $showingVoiceSelector) {
            voiceSelectorSheet
        }
    }
    
    // MARK: - Minimal View (for inline use)
    private var minimalView: some View {
        Button(action: {
            speechService.speakDutch(text)
            HapticManager.shared.lightImpact()
        }) {
            Image(systemName: speechService.isSpeaking && speechService.currentlySpeaking == text ? "speaker.wave.2.fill" : "speaker.wave.2")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    // MARK: - Compact View
    private var compactView: some View {
        HStack(spacing: 12) {
            // Main play/stop button
            Button(action: {
                if speechService.isSpeaking && speechService.currentlySpeaking == text {
                    speechService.stopSpeaking()
                } else {
                    speechService.speakDutch(text)
                }
                HapticManager.shared.lightImpact()
            }) {
                Image(systemName: speechService.isSpeaking && speechService.currentlySpeaking == text ? "stop.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            // Voice info
            if let voice = speechService.selectedVoice {
                Text(speechService.getVoiceDisplayName(for: voice))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Settings button
            Button(action: {
                showingVoiceSelector = true
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Full View
    private var fullView: some View {
        VStack(spacing: 16) {
            // Current status
            if speechService.isSpeaking {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.blue)
                    Text("Speaking: \"\(speechService.currentlySpeaking)\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            // Main controls
            HStack(spacing: 20) {
                // Play/Stop button
                Button(action: {
                    if speechService.isSpeaking && speechService.currentlySpeaking == text {
                        speechService.stopSpeaking()
                    } else {
                        speechService.speakDutch(text)
                    }
                    HapticManager.shared.mediumImpact()
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: speechService.isSpeaking && speechService.currentlySpeaking == text ? "stop.circle.fill" : "play.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.blue)
                        Text(speechService.isSpeaking && speechService.currentlySpeaking == text ? "Stop" : "Speak")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                // Speed controls
                VStack(spacing: 8) {
                    Text("Speed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        Button("0.5x") {
                            speechService.speakDutch(text, rate: 0.3)
                            HapticManager.shared.lightImpact()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("1x") {
                            speechService.speakDutch(text, rate: 0.5)
                            HapticManager.shared.lightImpact()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("1.5x") {
                            speechService.speakDutch(text, rate: 0.7)
                            HapticManager.shared.lightImpact()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            // Voice selection
            Button(action: {
                showingVoiceSelector = true
            }) {
                HStack {
                    Image(systemName: "person.wave.2.fill")
                    if let voice = speechService.selectedVoice {
                        Text("Voice: \(speechService.getVoiceDisplayName(for: voice))")
                    } else {
                        Text("Select Voice")
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    // MARK: - Voice Selector Sheet
    private var voiceSelectorSheet: some View {
        NavigationView {
            Form {
                Section(header: Text("Dutch Voices")) {
                    ForEach(speechService.availableDutchVoices, id: \.identifier) { voice in
                        Button(action: {
                            speechService.selectedVoice = voice
                            showingVoiceSelector = false
                            HapticManager.shared.lightImpact()
                        }) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(speechService.getVoiceDisplayName(for: voice))
                                        .foregroundColor(.primary)
                                    Text(voice.language)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if speechService.selectedVoice?.identifier == voice.identifier {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    if speechService.availableDutchVoices.isEmpty {
                        Text("No Dutch voices available")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Section(header: Text("Speech Settings")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Speed: \(speechService.speechRate, specifier: "%.1f")x")
                            .font(.subheadline)
                        Slider(value: $speechService.speechRate, in: 0.1...1.0, step: 0.1)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pitch: \(speechService.pitchMultiplier, specifier: "%.1f")")
                            .font(.subheadline)
                        Slider(value: $speechService.pitchMultiplier, in: 0.5...2.0, step: 0.1)
                    }
                }
                
                Section {
                    Button("Test Current Settings") {
                        speechService.speakDutch("Hallo, dit is een test van de Nederlandse uitspraak.")
                        HapticManager.shared.lightImpact()
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Speech Settings")
            .navigationBarItems(trailing: Button("Done") {
                showingVoiceSelector = false
            })
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Preview
struct DutchSpeechControlView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            DutchSpeechControlView(text: "Hallo wereld", mode: .minimal)
            DutchSpeechControlView(text: "Hoe gaat het met je?", mode: .compact)
            DutchSpeechControlView(text: "Dit is een test van de Nederlandse uitspraak", mode: .full)
        }
        .padding()
    }
} 