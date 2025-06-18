import SwiftUI

struct CloudKitSettingsView: View {
    @ObservedObject var viewModel: FlashCardViewModel
    @ObservedObject var cloudKitManager = CloudKitManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // Sync Status
                    HStack {
                        Image(systemName: syncStatusIcon)
                            .foregroundColor(syncStatusColor)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud Sync")
                                .font(.headline)
                            Text(cloudKitManager.statusMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.isCloudSyncEnabled)
                            .disabled(!cloudKitManager.isAccountAvailable)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Sync Status")
                } footer: {
                    Text(footerText)
                }
                
                if cloudKitManager.isAccountAvailable {
                    Section {
                        Button(action: {
                            viewModel.manualSync()
                        }) {
                            HStack {
                                Image(systemName: "icloud.and.arrow.up")
                                Text("Sync Now")
                            }
                        }
                        .disabled(!viewModel.isCloudSyncEnabled || syncInProgress)
                        
                        // Add force sync option for troubleshooting
                        Button(action: {
                            viewModel.forceFullSync()
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text("Force Full Sync")
                            }
                        }
                        .disabled(!viewModel.isCloudSyncEnabled || syncInProgress)
                        
                        // Add test quota button for diagnostics
                        Button(action: {
                            viewModel.testCloudKitQuota()
                        }) {
                            HStack {
                                Image(systemName: "chart.bar.doc.horizontal")
                                Text("Test CloudKit Quota")
                            }
                        }
                        .disabled(!viewModel.isCloudSyncEnabled || syncInProgress)
                        
                        if let lastSync = cloudKitManager.lastSyncDate {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.secondary)
                                Text("Last synced: \(formatDate(lastSync))")
                                    .foregroundColor(.secondary)
                            }
                            .font(.caption)
                        }
                    } header: {
                        Text("Sync Controls")
                    } footer: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• **Sync Now**: Quick sync of recent changes")
                            Text("• **Force Full Sync**: Complete sync of all data (use if having sync issues)")
                            Text("• **Test CloudKit Quota**: Run diagnostics and test quota management")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Development testing section
                    Section {
                        Button(action: {
                            viewModel.createTestCards(count: 100)
                        }) {
                            HStack {
                                Image(systemName: "plus.rectangle.on.rectangle")
                                Text("Create 100 Test Cards")
                            }
                        }
                        .disabled(!viewModel.isCloudSyncEnabled || syncInProgress)
                        
                    } header: {
                        Text("Development Testing")
                    } footer: {
                        Text("⚠️ Creates test cards to simulate quota limits. Use only for testing quota management.")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                // New device setup section
                if cloudKitManager.isAccountAvailable && viewModel.isCloudSyncEnabled {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "iphone.badge.plus")
                                    .foregroundColor(.blue)
                                Text("New Device Setup")
                                    .font(.headline)
                            }
                            
                            Text("If this is a new device and you're not seeing your cards:")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top) {
                                    Text("1.")
                                        .fontWeight(.medium)
                                    Text("Make sure you're signed into the same iCloud account")
                                }
                                HStack(alignment: .top) {
                                    Text("2.")
                                        .fontWeight(.medium)
                                    Text("Check that iCloud Drive is enabled in Settings")
                                }
                                HStack(alignment: .top) {
                                    Text("3.")
                                        .fontWeight(.medium)
                                    Text("Try 'Force Full Sync' above to download all data")
                                }
                                HStack(alignment: .top) {
                                    Text("4.")
                                        .fontWeight(.medium)
                                    Text("Wait a few minutes - large collections take time to sync")
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Troubleshooting")
                    }
                }
                
                // Quota management section
                if case .error(let errorMessage) = cloudKitManager.syncStatus,
                   errorMessage.contains("quota") {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("CloudKit Quota Exceeded")
                                    .font(.headline)
                            }
                            
                            Text("You're temporarily hitting CloudKit's rate limits. This is normal for large collections or new devices.")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("What to do:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .fontWeight(.medium)
                                        Text("Wait 5-10 minutes, then try syncing again")
                                    }
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .fontWeight(.medium)
                                        Text("The app will automatically retry in the background")
                                    }
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .fontWeight(.medium)
                                        Text("Your data is safe - nothing is lost")
                                    }
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .fontWeight(.medium)
                                        Text("Large collections may take several sync attempts")
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Quota Information")
                    }
                }
                
                Section {
                    InfoRow(
                        icon: "iphone.and.ipad",
                        title: "Cross-Device Sync",
                        description: "Your cards appear on all your devices"
                    )
                    
                    InfoRow(
                        icon: "icloud",
                        title: "iCloud Backup",
                        description: "Cards are safely backed up to iCloud"
                    )
                    
                    InfoRow(
                        icon: "wifi.slash",
                        title: "Offline Support",
                        description: "Works offline, syncs when connected"
                    )
                    
                    InfoRow(
                        icon: "person.fill.shield",
                        title: "Private & Secure",
                        description: "Only you can access your cards"
                    )
                } header: {
                    Text("How iCloud Sync Works")
                }
                
                if !cloudKitManager.isAccountAvailable {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundColor(.orange)
                                Text("iCloud Account Required")
                                    .font(.headline)
                            }
                            
                            Text("To sync your flash cards across devices, you need to sign in to iCloud in your device Settings.")
                                .font(.body)
                                .foregroundColor(.secondary)
                            
                            Button("Open Settings") {
                                openSettings()
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // Simulator-specific section
                if case .simulatorMode = cloudKitManager.syncStatus {
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "desktopcomputer")
                                    .foregroundColor(.blue)
                                Text("Simulator Mode")
                                    .font(.headline)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CloudKit sync is disabled in the iOS Simulator.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                
                                Text("To test sync features:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("1.")
                                            .fontWeight(.medium)
                                        Text("Connect your iPhone or iPad")
                                    }
                                    HStack {
                                        Text("2.")
                                            .fontWeight(.medium)
                                        Text("Select your device in Xcode")
                                    }
                                    HStack {
                                        Text("3.")
                                            .fontWeight(.medium)
                                        Text("Build and run on the device")
                                    }
                                    HStack {
                                        Text("4.")
                                            .fontWeight(.medium)
                                        Text("Make sure you're signed into iCloud")
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8)
                    } header: {
                        Text("Development Info")
                    }
                }
            }
            .navigationTitle("iCloud Sync")
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
    
    private var syncStatusIcon: String {
        switch cloudKitManager.syncStatus {
        case .unknown:
            return "questionmark.circle"
        case .syncing:
            return "icloud.and.arrow.up"
        case .success:
            return "icloud.and.arrow.up.fill"
        case .error:
            return "exclamationmark.icloud"
        case .noAccount:
            return "person.crop.circle.badge.exclamationmark"
        case .offline:
            return "wifi.slash"
        case .simulatorMode:
            return "desktopcomputer"
        case .idle:
            return "clock"
        }
    }
    
    private var syncStatusColor: Color {
        switch cloudKitManager.syncStatus {
        case .unknown:
            return .secondary
        case .syncing:
            return .blue
        case .success:
            return .green
        case .error:
            return .red
        case .noAccount:
            return .orange
        case .offline:
            return .orange
        case .simulatorMode:
            return .blue
        case .idle:
            return .orange
        }
    }
    
    private var syncInProgress: Bool {
        switch cloudKitManager.syncStatus {
        case .syncing:
            return true
        default:
            return false
        }
    }
    
    private var footerText: String {
        switch cloudKitManager.syncStatus {
        case .simulatorMode:
            return "CloudKit sync is only available on physical devices. Use Xcode to run on a real iPhone or iPad to test sync features."
        default:
            if !cloudKitManager.isAccountAvailable {
                return "Sign in to iCloud in Settings to enable sync across your devices."
            } else if viewModel.isCloudSyncEnabled {
                return "Your flash cards are automatically synced across all your devices signed in to the same iCloud account."
            } else {
                return "Enable sync to access your cards on all your devices and back them up to iCloud."
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.title3)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 2)
    }
}

struct CloudKitSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        CloudKitSettingsView(viewModel: FlashCardViewModel())
    }
} 