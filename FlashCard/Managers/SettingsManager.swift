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
    
    // MARK: - Initialization
    private init() {
        // Load saved preferences or use defaults
        self.isSoundEnabled = UserDefaults.standard.object(forKey: "SoundEnabled") as? Bool ?? true
        self.isHapticsEnabled = UserDefaults.standard.object(forKey: "HapticsEnabled") as? Bool ?? true
        
        let themeRawValue = UserDefaults.standard.string(forKey: "SelectedTheme") ?? AppTheme.system.rawValue
        self.selectedTheme = AppTheme(rawValue: themeRawValue) ?? .system
        
        print("🔧 SettingsManager initialized - Sound: \(isSoundEnabled), Haptics: \(isHapticsEnabled), Theme: \(selectedTheme.displayName)")
    }
    
    // MARK: - Public Methods
    
    /// Reset all settings to defaults
    func resetToDefaults() {
        isSoundEnabled = true
        isHapticsEnabled = true
        selectedTheme = .system
        print("🔧 Settings reset to defaults")
    }
    
    /// Get current theme for UI application
    func getCurrentColorScheme() -> ColorScheme? {
        return selectedTheme.colorScheme
    }
} 