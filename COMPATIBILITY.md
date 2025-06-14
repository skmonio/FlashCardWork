# iOS Compatibility Guide

This document outlines the iOS version compatibility features implemented in the FlashCard app.

## Supported iOS Versions

- **Minimum iOS Version**: iOS 16.0
- **Recommended iOS Version**: iOS 17.4+ (for full feature set)
- **Originally Developed For**: iOS 18.5

## Feature Compatibility Matrix

| Feature | iOS 16.0 | iOS 17.0 | iOS 17.4+ | Status |
|---------|----------|----------|-----------|---------|
| Core Flashcard Functionality | ✅ | ✅ | ✅ | Full Support |
| Local Dictionary Translation | ✅ | ✅ | ✅ | Full Support |
| Apple Translation Framework | ❌ | ❌ | ✅ | iOS 17.4+ Only |
| Basic OCR (Text Recognition) | ✅ | ✅ | ✅ | Full Support |
| Advanced OCR Features | ❌ | ✅ | ✅ | iOS 17.0+ |
| Live Text Scanning | ✅ | ✅ | ✅ | iOS 16.0+ |
| Modern Toolbar API | ✅ | ✅ | ✅ | iOS 14.0+ |
| Audio Recording/Playback | ✅ | ✅ | ✅ | Full Support |
| Dutch Speech Synthesis | ✅ | ✅ | ✅ | Full Support |

## Compatibility Implementation

### Translation Features

#### iOS 17.4+ (Full Translation Support)
- Uses Apple's Translation framework for real-time translation
- Supports automatic translation suggestions
- Enhanced translation accuracy
- Network-based translation when available

#### iOS 16.0 - 17.3 (Limited Translation Support)
- Uses local dictionary with 200+ common Dutch words
- Manual translation requests only
- Shows compatibility notice to users
- Fallback to local dictionary for all translation needs

### OCR (Optical Character Recognition)

#### iOS 17.0+ (Advanced OCR)
- High accuracy text recognition
- Multi-language support (Dutch + English)
- Language correction enabled
- Better handling of complex text layouts

#### iOS 16.0 - 16.9 (Basic OCR)
- Standard accuracy text recognition
- English language support primarily
- No language correction
- Basic text extraction capabilities

### User Experience Adaptations

#### Compatibility Notifications
- Orange info icons next to features with limited functionality
- Contextual messages explaining feature limitations
- Upgrade suggestions for enhanced features
- Non-intrusive compatibility alerts

#### Graceful Degradation
- All core functionality remains available on older iOS versions
- Features automatically adapt based on iOS version
- No crashes or errors due to unavailable APIs
- Seamless user experience across all supported versions

## Technical Implementation

### Compatibility Helper
The `CompatibilityHelper` struct provides centralized version checking:

```swift
// Check if Translation framework is available
CompatibilityHelper.isTranslationFrameworkAvailable

// Check if advanced Vision features are available
CompatibilityHelper.isAdvancedVisionAvailable

// Show appropriate user messages
CompatibilityHelper.getUnavailableFeatureMessage(for: .translation)
```

### Translation Compatibility Wrapper
The `TranslationCompatibility` struct provides unified translation access:

```swift
// Automatically uses best available translation method
let translation = await TranslationCompatibility.getTranslation(for: word)
```

### Conditional Imports
Framework imports are wrapped in availability checks:

```swift
#if canImport(Translation)
@preconcurrency import Translation
#endif
```

### Runtime Feature Detection
Features are enabled/disabled based on runtime availability:

```swift
@available(iOS 17.4, *)
private func useAppleTranslation() {
    // Apple Translation framework code
}
```

## User-Facing Changes

### Translation Interface
- **iOS 17.4+**: Shows "Get Translation" button with full Apple Translation support
- **iOS 16.0-17.3**: Shows "Get Translation" button with local dictionary + compatibility notice

### OCR Interface
- **iOS 17.0+**: Enhanced text recognition with better accuracy
- **iOS 16.0-16.9**: Basic text recognition with standard accuracy

### Visual Indicators
- Orange info icons indicate limited functionality
- Compatibility notices explain feature limitations
- Upgrade suggestions provided where appropriate

## Testing Recommendations

### Device Testing
- Test on physical devices running iOS 16.0, 17.0, and 17.4+
- Verify all features work as expected on each version
- Confirm compatibility notices appear correctly

### Feature Testing
- Translation functionality on different iOS versions
- OCR accuracy across iOS versions
- Audio features on all supported versions
- UI/UX consistency across versions

## Future Considerations

### Potential Enhancements
- Add more words to local dictionary for better offline translation
- Implement caching for Apple Translation results
- Add user preference for translation method selection
- Consider third-party translation APIs for broader compatibility

### Maintenance
- Monitor iOS adoption rates to adjust minimum supported version
- Update compatibility checks as new iOS versions are released
- Regularly test on new iOS beta versions
- Update documentation as features evolve

## Troubleshooting

### Common Issues
1. **Translation not working**: Check iOS version and network connectivity
2. **OCR accuracy issues**: Ensure good lighting and clear text in images
3. **Audio playback issues**: Check device volume and audio permissions
4. **UI layout issues**: Test on different screen sizes and orientations

### Debug Information
- Check device iOS version in Settings > General > About
- Verify app permissions in Settings > Privacy & Security
- Review app logs for compatibility warnings
- Test with different network conditions 