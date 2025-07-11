import Foundation

// MARK: - Build Configuration Helper
// This file manages feature flags for different app versions (Full vs Lite)

struct BuildConfiguration {
    
    // MARK: - Feature Flags
    
    /// Whether this is the lite version of the app
    static let isLiteVersion: Bool = {
        #if LITE_VERSION
        return true
        #else
        return false
        #endif
    }()
    
    /// Whether Dutch grammar features should be included
    static let includeDutchGrammar: Bool = {
        #if LITE_VERSION
        return false
        #else
        return true
        #endif
    }()
    
    /// Whether Dutch lessons should be included
    static let includeDutchLessons: Bool = {
        #if LITE_VERSION
        return false
        #else
        return true
        #endif
    }()
    
    /// Whether Dutch vocabulary features should be included
    static let includeDutchVocabulary: Bool = {
        #if LITE_VERSION
        return false
        #else
        return true
        #endif
    }()
    
    /// Whether translation service should be included
    static let includeTranslationService: Bool = {
        #if LITE_VERSION
        return false
        #else
        return true
        #endif
    }()
    
    /// Whether additional grammar features should be included
    static let includeAdditionalGrammar: Bool = {
        #if LITE_VERSION
        return false
        #else
        return true
        #endif
    }()
    
    /// Whether Dutch translation features should be included
    static let includeDutchTranslation: Bool = {
        #if LITE_VERSION
        return false
        #else
        return true
        #endif
    }()
    
    // MARK: - App Information
    
    /// App name based on version
    static var appName: String {
        if isLiteVersion {
            return "Taal Trek Lite"
        } else {
            return "Taal Trek"
        }
    }
    
    /// App description based on version
    static var appDescription: String {
        if isLiteVersion {
            return "A streamlined flashcard app for language learning"
        } else {
            return "A comprehensive Dutch language learning app with grammar, vocabulary, and interactive lessons"
        }
    }
    
    // MARK: - Feature Availability
    
    /// Check if a specific feature is available
    static func isFeatureAvailable(_ feature: AppFeature) -> Bool {
        switch feature {
        case .dutchGrammar:
            return includeDutchGrammar
        case .dutchLessons:
            return includeDutchLessons
        case .dutchVocabulary:
            return includeDutchVocabulary
        case .translationService:
            return includeTranslationService
        case .additionalGrammar:
            return includeAdditionalGrammar
        case .dutchTranslation:
            return includeDutchTranslation
        case .bubbleWordMaps:
            return true // Available in both versions
        case .basicFlashcards:
            return true // Available in both versions
        case .studyModes:
            return true // Available in both versions
        case .statistics:
            return true // Available in both versions
        }
    }
}

// MARK: - App Features Enum

enum AppFeature {
    case dutchGrammar
    case dutchLessons
    case dutchVocabulary
    case translationService
    case additionalGrammar
    case dutchTranslation
    case bubbleWordMaps
    case basicFlashcards
    case studyModes
    case statistics
} 