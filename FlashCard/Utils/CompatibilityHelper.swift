import SwiftUI
import Foundation

/// Helper class to handle iOS version compatibility and feature availability
struct CompatibilityHelper {
    
    // MARK: - iOS Version Checks
    
    /// Check if Translation framework is available (iOS 17.4+)
    static var isTranslationFrameworkAvailable: Bool {
        if #available(iOS 17.4, *) {
            return true
        } else {
            return false
        }
    }
    
    /// Check if modern toolbar API is available (iOS 14+)
    static var isModernToolbarAvailable: Bool {
        if #available(iOS 14.0, *) {
            return true
        } else {
            return false
        }
    }
    
    /// Check if Live Text scanning is available (iOS 16+)
    static var isLiveTextAvailable: Bool {
        if #available(iOS 16.0, *) {
            return true
        } else {
            return false
        }
    }
    
    /// Check if advanced Vision features are available (iOS 17+)
    static var isAdvancedVisionAvailable: Bool {
        if #available(iOS 17.0, *) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Feature Availability Messages
    
    /// Get user-friendly message for unavailable features
    static func getUnavailableFeatureMessage(for feature: UnavailableFeature) -> String {
        switch feature {
        case .translation:
            return "Translation suggestions require iOS 17.4 or later. You can still add translations manually."
        case .liveText:
            return "Live text scanning requires iOS 16 or later. You can still import images and extract text manually."
        case .advancedOCR:
            return "Advanced text recognition requires iOS 17 or later. Basic text extraction is still available."
        }
    }
    
    /// Show compatibility alert for unavailable features
    static func showCompatibilityAlert(for feature: UnavailableFeature) -> Alert {
        Alert(
            title: Text("Feature Not Available"),
            message: Text(getUnavailableFeatureMessage(for: feature)),
            dismissButton: .default(Text("OK"))
        )
    }
}

// MARK: - Feature Enumeration

enum UnavailableFeature {
    case translation
    case liveText
    case advancedOCR
}

// MARK: - Compatibility View Modifiers

extension View {
    /// Apply toolbar with compatibility for older iOS versions
    @ViewBuilder
    func compatibleToolbar<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if CompatibilityHelper.isModernToolbarAvailable {
            self.toolbar {
                content()
            }
        } else {
            // Fallback for iOS 13 and earlier
            self.navigationBarItems(trailing: content())
        }
    }
    
    /// Show feature unavailable alert
    func featureUnavailableAlert(
        isPresented: Binding<Bool>,
        feature: UnavailableFeature
    ) -> some View {
        self.alert(isPresented: isPresented) {
            CompatibilityHelper.showCompatibilityAlert(for: feature)
        }
    }
}

// MARK: - Compatibility Wrappers

/// Wrapper for Translation framework functionality
struct TranslationCompatibility {
    
    /// Check if a word can be translated using Apple's framework
    static func canTranslate() -> Bool {
        return CompatibilityHelper.isTranslationFrameworkAvailable
    }
    
    /// Get translation using available methods
    static func getTranslation(for word: String) async -> String {
        if #available(iOS 17.4, *), CompatibilityHelper.isTranslationFrameworkAvailable {
            // Use Apple's Translation framework on iOS 17.4+
            return await getAppleTranslation(for: word)
        } else {
            // Fallback to local dictionary
            return await getLocalTranslation(for: word)
        }
    }
    
    @available(iOS 17.4, *)
    private static func getAppleTranslation(for word: String) async -> String {
        // This would use Apple's Translation framework
        // For now, fallback to local dictionary
        return await getLocalTranslation(for: word)
    }
    
    private static func getLocalTranslation(for word: String) async -> String {
        return await TranslationService.shared.getTranslationWithFallback(for: word)
    }
}

/// Wrapper for Vision framework compatibility
struct VisionCompatibility {
    
    /// Check if advanced OCR features are available
    static func hasAdvancedOCR() -> Bool {
        return CompatibilityHelper.isAdvancedVisionAvailable
    }
    
    /// Get OCR configuration based on iOS version
    static func getOCRConfiguration() -> OCRConfiguration {
        if CompatibilityHelper.isAdvancedVisionAvailable {
            return OCRConfiguration(
                recognitionLevel: "accurate",
                languages: ["nl", "en"],
                usesLanguageCorrection: true,
                supportsLiveText: true
            )
        } else {
            return OCRConfiguration(
                recognitionLevel: "fast",
                languages: ["en"], // More limited on older iOS
                usesLanguageCorrection: false,
                supportsLiveText: false
            )
        }
    }
}

struct OCRConfiguration {
    let recognitionLevel: String // "accurate" or "fast"
    let languages: [String]
    let usesLanguageCorrection: Bool
    let supportsLiveText: Bool
} 