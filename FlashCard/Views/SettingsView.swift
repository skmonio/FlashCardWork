import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @StateObject private var settingsManager = SettingsManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
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
    
    // Add state for WelcomeView popup
    @State private var showingWelcome = false
    
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
                VStack(spacing: 0) {
                    UnifiedHeader(
                        title: "Settings",
                        showBackButton: false,
                        onProfile: { NavigationCoordinator.shared.presentSheet(.userProfile) }
                    )
                    settingsContent
                }
                .navigationBarHidden(true)
                .background(Color(.systemBackground))
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
            }
            
            // Notification Settings Section
            Section {
                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    
                    Text("Study Reminders")
                    
                    Spacer()
                    
                    Toggle("", isOn: $settingsManager.isNotificationsEnabled)
                        .onChange(of: settingsManager.isNotificationsEnabled) { newValue in
                            if newValue {
                                // Request permission first, then schedule if granted
                                notificationManager.requestNotificationPermission { granted in
                                    if granted {
                                        notificationManager.scheduleNotifications()
                                    } else {
                                        // If permission denied, turn off the toggle
                                        DispatchQueue.main.async {
                                            settingsManager.isNotificationsEnabled = false
                                        }
                                    }
                                }
                            } else {
                                notificationManager.cancelAllNotifications()
                            }
                            HapticManager.shared.lightImpact()
                        }
                }
                
                if settingsManager.isNotificationsEnabled {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Reminder Time")
                            
                            Spacer()
                            
                            DatePicker("", selection: $settingsManager.notificationTime, displayedComponents: .hourAndMinute)
                                .onChange(of: settingsManager.notificationTime) { _ in
                                    notificationManager.scheduleNotifications()
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.purple)
                                    .frame(width: 24)
                                
                                Text("Frequency")
                                
                                Spacer()
                            }
                            
                            // Frequency selection with buttons
                            VStack(spacing: 8) {
                                ForEach(SettingsManager.NotificationFrequency.allCases, id: \.self) { frequency in
                                    Button(action: {
                                        settingsManager.notificationFrequency = frequency
                                        notificationManager.scheduleNotifications()
                                        HapticManager.shared.lightImpact()
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(frequency.displayName)
                                                    .font(.body)
                                                    .fontWeight(.medium)
                                                Text(frequency.description)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            if settingsManager.notificationFrequency == frequency {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.title3)
                                            } else {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                                    .font(.title3)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(settingsManager.notificationFrequency == frequency ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
            }
            
            // Theme Settings Section
            Section {
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
                    removeDuplicateCards()
                }) {
                    HStack {
                        Image(systemName: "trash.circle")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Remove Duplicate Cards")
                            .foregroundColor(.red)
                        
                        Spacer()
                    }
                }
                
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
            
            // Add About/Help section at the bottom
            Section {
                Button(action: {
                    showingWelcome = true
                }) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("What is Taal Trek?")
                            .foregroundColor(.primary)
                        Spacer()
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
        .listRowBackground(Color(.systemBackground))
        .sheet(isPresented: $showingWelcome) {
            WelcomeView(isPresented: $showingWelcome)
        }
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
    
    private func removeDuplicateCards() {
        let result = viewModel.removeDuplicateCards()
        
        // Show alert with results
        duplicateResults = (true, result.message)
        showingDuplicateAlert = true
        
        if result.removedCount > 0 {
            HapticManager.shared.successNotification()
            if settingsManager.isSoundEnabled {
                SoundManager.shared.playCorrectSound()
            }
        } else {
            HapticManager.shared.lightImpact()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: FlashCardViewModel())
    }
} 