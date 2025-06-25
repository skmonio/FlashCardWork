import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @StateObject private var settingsManager = SettingsManager.shared
    @Environment(\.dismiss) private var dismiss
    
    // State for data management features
    @State private var showingExportImport = false
    @State private var showingResetAlert = false
    @State private var showingCloudKitSettings = false
    
    // State for duplicate detection
    @State private var showingDuplicateAlert = false
    @State private var duplicateResults: (success: Bool, message: String) = (false, "")
    @State private var isCheckingDuplicates = false
    
    // Control whether this is shown as a sheet or inline
    var isSheet: Bool = true
    
    var body: some View {
        Group {
            if isSheet {
                NavigationView {
                    settingsContent
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
            } else {
                settingsContent
            }
        }
        .sheet(isPresented: $showingExportImport) {
            ExportImportView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingCloudKitSettings) {
            CloudKitSettingsView(viewModel: viewModel)
        }
        .alert("Reset Learning Statistics", isPresented: $showingResetAlert) {
            Button("Reset", role: .destructive) {
                viewModel.resetLearningStatistics()
                HapticManager.shared.successNotification()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will reset all learning progress and percentages for all cards. This action cannot be undone.")
        }
        .alert("Duplicate Detection", isPresented: $showingDuplicateAlert) {
            Button("OK") { }
        } message: {
            Text(duplicateResults.message)
        }
    }
    
    private var settingsContent: some View {
        List {
            // CloudKit Sync Section
            Section {
                HStack {
                    Image(systemName: "icloud.and.arrow.up")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("iCloud Sync")
                            .foregroundColor(.primary)
                        Text(viewModel.isCloudSyncEnabled ? "Enabled" : "Disabled")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $viewModel.isCloudSyncEnabled)
                        .onTapGesture(count: 10) {
                            // Developer tools - 10x tap opens CloudKit settings
                            showingCloudKitSettings = true
                        }
                }
                .contentShape(Rectangle())
                .onTapGesture(count: 10) {
                    // Developer tools - 10x tap opens CloudKit settings
                    showingCloudKitSettings = true
                }
            } header: {
                Text("Cloud Sync")
            } footer: {
                Text("Sync your flash cards across all your devices using iCloud.")
            }
            
            // Audio & Haptic Settings in one section
            Section {
                HStack {
                    Image(systemName: "speaker.wave.2")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Sound Effects")
                    
                    Spacer()
                    
                    Toggle("", isOn: $settingsManager.isSoundEnabled)
                        .onChange(of: settingsManager.isSoundEnabled) { newValue in
                            if newValue {
                                SoundManager.shared.playCorrectSound()
                            }
                            HapticManager.shared.lightImpact()
                        }
                }
                
                HStack {
                    Image(systemName: "iphone.radiowaves.left.and.right")
                        .foregroundColor(.teal)
                        .frame(width: 24)
                    
                    Text("Haptic Feedback")
                    
                    Spacer()
                    
                    Toggle("", isOn: $settingsManager.isHapticsEnabled)
                        .onChange(of: settingsManager.isHapticsEnabled) { newValue in
                            if newValue {
                                HapticManager.shared.mediumImpact()
                            }
                        }
                }
                
                HStack {
                    Image(systemName: "paintbrush")
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.3))
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
            
            // App Information & Data Management in one section
            Section {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    
                    Text("Version")
                    
                    Spacer()
                    
                    Text("1.0")
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    showingExportImport = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up.on.square")
                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0))
                            .frame(width: 24)
                        
                        Text("Export & Import")
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                }
                
                Button(action: {
                    checkAndRemoveDuplicates()
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        
                        Text("Check for Duplicates")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if isCheckingDuplicates {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(isCheckingDuplicates)
                
                Button(action: {
                    showingResetAlert = true
                }) {
                    HStack {
                        Image(systemName: "chart.bar.xaxis")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Reset Statistics")
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                }
                
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
                        
                        Spacer()
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Duplicate Detection Methods
    
    private func checkAndRemoveDuplicates() {
        isCheckingDuplicates = true
        
        Task {
            let results = await viewModel.removeDuplicates()
            
            await MainActor.run {
                isCheckingDuplicates = false
                duplicateResults = results
                showingDuplicateAlert = true
                
                if results.success {
                    HapticManager.shared.successNotification()
                    if settingsManager.isSoundEnabled {
                        SoundManager.shared.playCorrectSound()
                    }
                } else {
                    HapticManager.shared.errorNotification()
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