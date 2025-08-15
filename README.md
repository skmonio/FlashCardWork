# Taal Trek - Dutch Language Learning App

<div align="center">
  <img src="assets/images/taal-trek-splash.png" alt="Taal Trek Logo" width="200"/>
  
  **Master Dutch with Interactive Flashcards & Smart Learning**
  
  [![iOS](https://img.shields.io/badge/iOS-15.5+-blue.svg)](https://developer.apple.com/ios/)
  [![Android](https://img.shields.io/badge/Android-6.0+-green.svg)](https://developer.android.com/)
  [![Flutter](https://img.shields.io/badge/Flutter-3.32.8+-blue.svg)](https://flutter.dev/)
  [![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
</div>

## 🌟 Features

### 📚 **Comprehensive Learning Tools**
- **Interactive Flashcards**: Create and study custom Dutch vocabulary cards
- **Smart Exercises**: Multiple choice, fill-in-the-blank, and sentence building
- **Grammar Practice**: Focused exercises for Dutch grammar rules
- **Pronunciation Guide**: Audio support for proper Dutch pronunciation

### 🎯 **Study Modes**
- **Advanced Study Sessions**: Track progress with XP and statistics
- **Multiple Choice Tests**: Test your knowledge with interactive quizzes
- **Writing Practice**: Improve your Dutch writing skills
- **Memory Games**: Fun games to reinforce vocabulary retention
- **True/False Challenges**: Quick knowledge checks

### 🏪 **Content Store**
- **Curated Vocabulary Packs**: Organized by difficulty and topic
- **Chapter-based Learning**: Structured content for systematic learning
- **Exercise Collections**: Grammar and vocabulary exercises
- **Import/Export**: Share your flashcards and exercises

### 📊 **Progress Tracking**
- **XP System**: Gamified learning with experience points
- **Statistics Dashboard**: Monitor your learning progress
- **Achievement System**: Unlock achievements as you learn
- **Study History**: Track your study sessions and performance

## 🚀 Getting Started

### Prerequisites
- iOS 15.5+ or Android 6.0+
- Flutter 3.32.8+ (for development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/skmonio/FlashCardWork.git
   cd FlashCardWork
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**iOS:**
```bash
flutter build ios --release
```

**Android:**
```bash
flutter build apk --release
```

## 📱 Screenshots

<div align="center">
  <img src="assets/images/screenshot1.png" alt="Home Screen" width="200"/>
  <img src="assets/images/screenshot2.png" alt="Study Mode" width="200"/>
  <img src="assets/images/screenshot3.png" alt="Store" width="200"/>
  <img src="assets/images/screenshot4.png" alt="Progress" width="200"/>
</div>

## 🛠️ Technology Stack

- **Framework**: Flutter 3.32.8
- **Language**: Dart
- **State Management**: Provider
- **Audio**: AudioPlayers
- **ML Features**: Google ML Kit
- **Storage**: SharedPreferences
- **Platforms**: iOS, Android, Web

## 📁 Project Structure

```
lib/
├── components/          # Reusable UI components
├── data/               # Data models and constants
├── models/             # App data models
├── providers/          # State management
├── services/           # Business logic and external services
├── utils/              # Utility functions
├── views/              # App screens and pages
└── main.dart           # App entry point

assets/
├── audio/              # Sound effects and audio files
├── data/               # CSV files and content packs
├── fonts/              # Custom fonts
└── images/             # App images and icons
```

## 🔧 Configuration

### Environment Setup

1. **iOS Configuration**
   - Update `ios/Runner/Info.plist` for permissions
   - Configure signing in Xcode
   - Set minimum iOS version to 15.5

2. **Android Configuration**
   - Update `android/app/build.gradle` for version info
   - Configure signing for release builds
   - Set minimum SDK version to 21

### Content Management

The app includes a content store with:
- Vocabulary packs organized by chapter
- Grammar exercises
- Pronunciation guides
- Import/export functionality

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

Need help? Check out our [Support Guide](SUPPORT.md) or contact us:

- **Email**: stephenjohncook@outlook.com
- **Response Time**: 24-48 hours
- **Documentation**: [SUPPORT.md](SUPPORT.md)

### Common Issues

- **App crashes**: Restart the app and ensure you have the latest version
- **Import issues**: Check CSV format and file headers
- **Audio problems**: Verify microphone permissions and device volume
- **Progress not saving**: Check internet connection and storage space

## 🌟 Roadmap

### Upcoming Features
- [ ] Spaced repetition algorithm
- [ ] Social learning features
- [ ] Advanced analytics
- [ ] Offline mode improvements
- [ ] Voice recognition
- [ ] Custom themes

### Known Issues
- See [Issues](https://github.com/skmonio/FlashCardWork/issues) for current bugs and feature requests

## 📊 Analytics

We use analytics to improve the app experience:
- Learning progress tracking
- Feature usage statistics
- Crash reporting
- Performance monitoring

All data is anonymized and used only for app improvement.

## 🔗 Links

- **App Store**: [Coming Soon]
- **Google Play**: [Coming Soon]
- **Website**: [Coming Soon]
- **Documentation**: [SUPPORT.md](SUPPORT.md)
- **Privacy Policy**: [PRIVACY.md](PRIVACY.md)

---

<div align="center">
  **Made with ❤️ for Dutch language learners**
  
  [![GitHub stars](https://img.shields.io/github/stars/skmonio/FlashCardWork.svg?style=social&label=Star)](https://github.com/skmonio/FlashCardWork)
  [![GitHub forks](https://img.shields.io/github/forks/skmonio/FlashCardWork.svg?style=social&label=Fork)](https://github.com/skmonio/FlashCardWork/fork)
  [![GitHub issues](https://img.shields.io/github/issues/skmonio/FlashCardWork.svg)](https://github.com/skmonio/FlashCardWork/issues)
</div>
