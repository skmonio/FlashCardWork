import Foundation
import Translation

@available(iOS 18.0, *)
class TranslationService: ObservableObject {
    static let shared = TranslationService()
    
    private init() {}
    
    /// Check if translation is available for the given language pair
    func isTranslationAvailable(from source: String, to target: String) async -> Bool {
        let availability = LanguageAvailability()
        let sourceLanguage = Locale.Language(identifier: source)
        let targetLanguage = Locale.Language(identifier: target)
        
        let status = await availability.status(from: sourceLanguage, to: targetLanguage)
        
        switch status {
        case .installed, .supported:
            return true
        case .unsupported:
            return false
        @unknown default:
            return false
        }
    }
    
    /// Get list of supported languages
    func getSupportedLanguages() async -> [Locale.Language] {
        let availability = LanguageAvailability()
        return await availability.supportedLanguages
    }
    
    /// Check if Dutch-English translation is available
    func isDutchEnglishTranslationAvailable() async -> Bool {
        return await isTranslationAvailable(from: "nl", to: "en")
    }
    
    /// Prepare Dutch-English translation (download models if needed)
    func prepareDutchEnglishTranslation() async throws {
        // This would be used with TranslationSession.prepareTranslation()
        // but we'll handle this in the UI components for now
    }
    
    /// Translate text using Apple's Translation API
    /// This is handled in the UI components with TranslationSession
    /// but could be extended to support other translation services
    func translate(_ text: String, from source: String, to target: String) async throws -> String {
        // For now, this is a placeholder
        // The actual translation is handled in the UI with TranslationSession
        // This could be extended to support other APIs like:
        // - DeepL API (requires API key)
        // - Google Translate API (requires API key)  
        // - LibreTranslate (free, self-hosted)
        throw TranslationError.notImplemented
    }
}

enum TranslationError: Error, LocalizedError {
    case notImplemented
    case translationFailed
    case unsupportedLanguage
    
    var errorDescription: String? {
        switch self {
        case .notImplemented:
            return "Translation method not implemented"
        case .translationFailed:
            return "Translation failed"
        case .unsupportedLanguage:
            return "Language not supported"
        }
    }
} 