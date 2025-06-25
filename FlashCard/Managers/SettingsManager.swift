import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    // MARK: - Published Properties
    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: "SoundEnabled")
        }
    }
    
    @Published var isHapticsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isHapticsEnabled, forKey: "HapticsEnabled")
        }
    }
    
    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "SelectedTheme")
        }
    }
    
    @Published var isNotificationsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isNotificationsEnabled, forKey: "NotificationsEnabled")
        }
    }
    
    @Published var notificationTime: Date {
        didSet {
            UserDefaults.standard.set(notificationTime, forKey: "NotificationTime")
        }
    }
    
    @Published var notificationFrequency: NotificationFrequency {
        didSet {
            UserDefaults.standard.set(notificationFrequency.rawValue, forKey: "NotificationFrequency")
        }
    }
    
    // MARK: - Theme Options
    enum AppTheme: String, CaseIterable {
        case system = "system"
        case light = "light"
        case dark = "dark"
        
        var displayName: String {
            switch self {
            case .system: return "System"
            case .light: return "Light"
            case .dark: return "Dark"
            }
        }
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
    }
    
    // MARK: - Notification Frequency Options
    enum NotificationFrequency: String, CaseIterable {
        case daily = "daily"
        case everyOtherDay = "everyOtherDay"
        case weekly = "weekly"
        
        var displayName: String {
            switch self {
            case .daily: return "Daily"
            case .everyOtherDay: return "Every Other Day"
            case .weekly: return "Weekly"
            }
        }
        
        var description: String {
            switch self {
            case .daily: return "Get reminded every day"
            case .everyOtherDay: return "Get reminded every other day"
            case .weekly: return "Get reminded once a week"
            }
        }
    }
    
    // MARK: - Initialization
    private init() {
        // Load saved preferences or use defaults
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "SoundEnabled") as? Bool ?? true
        self.isHapticsEnabled = UserDefaults.standard.object(forKey: "HapticsEnabled") as? Bool ?? true
        
        let themeRawValue = UserDefaults.standard.string(forKey: "SelectedTheme") ?? AppTheme.system.rawValue
        self.selectedTheme = AppTheme(rawValue: themeRawValue) ?? .system
        
        // Load notification settings
        self.isNotificationsEnabled = UserDefaults.standard.object(forKey: "NotificationsEnabled") as? Bool ?? false
        self.notificationTime = UserDefaults.standard.object(forKey: "NotificationTime") as? Date ?? Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        
        let frequencyRawValue = UserDefaults.standard.string(forKey: "NotificationFrequency") ?? NotificationFrequency.daily.rawValue
        self.notificationFrequency = NotificationFrequency(rawValue: frequencyRawValue) ?? .daily
        
        print("🔧 SettingsManager initialized - Sound: \(isSoundEnabled), Haptics: \(isHapticsEnabled), Theme: \(selectedTheme.displayName), Notifications: \(isNotificationsEnabled)")
    }
    
    // MARK: - Public Methods
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        isSoundEnabled = true
        isHapticsEnabled = true
        selectedTheme = .system
        isNotificationsEnabled = false
        notificationTime = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date()
        notificationFrequency = .daily
        
        print("🔧 Settings reset to defaults")
    }
    
    /// Get current theme for UI application
    func getCurrentColorScheme() -> ColorScheme? {
        return selectedTheme.colorScheme
    }
} 