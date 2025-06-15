import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @StateObject private var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                // Audio Settings Section
                Section(header: Text("Audio")) {
                    HStack {
                        Image(systemName: "speaker.wave.2")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Sound Effects")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settingsManager.isSoundEnabled)
                            .onChange(of: settingsManager.isSoundEnabled) { newValue in
                                if newValue {
                                    // Play a test sound when enabling
                                    SoundManager.shared.playCorrectSound()
                                }
                                HapticManager.shared.lightImpact()
                            }
                    }
                }
                
                // Haptic Settings Section
                Section(header: Text("Haptics")) {
                    HStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Haptic Feedback")
                        
                        Spacer()
                        
                        Toggle("", isOn: $settingsManager.isHapticsEnabled)
                            .onChange(of: settingsManager.isHapticsEnabled) { newValue in
                                if newValue {
                                    // Provide test haptic when enabling
                                    HapticManager.shared.mediumImpact()
                                } else {
                                    // No haptic when disabling (since it's being disabled)
                                }
                            }
                    }
                }
                
                // Theme Settings Section
                Section(header: Text("Appearance")) {
                    HStack {
                        Image(systemName: "paintbrush")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Theme")
                        
                        Spacer()
                        
                        Picker("Theme", selection: $settingsManager.selectedTheme) {
                            ForEach(SettingsManager.AppTheme.allCases, id: \.self) { theme in
                                Text(theme.displayName).tag(theme)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 180)
                        .onChange(of: settingsManager.selectedTheme) { _ in
                            HapticManager.shared.lightImpact()
                        }
                    }
                }
                
                // App Information Section
                Section(header: Text("About")) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text("1.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "rectangle.stack")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Total Cards")
                        
                        Spacer()
                        
                        Text("\(viewModel.flashCards.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "folder")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Total Decks")
                        
                        Spacer()
                        
                        Text("\(viewModel.decks.count)")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Reset Section
                Section(header: Text("Reset")) {
                    Button(action: {
                        settingsManager.resetToDefaults()
                        HapticManager.shared.successNotification()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("Reset Settings to Default")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: FlashCardViewModel())
    }
} 