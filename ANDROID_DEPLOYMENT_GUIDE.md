# Android Deployment Guide for Taal Trek

## 📱 **APK Files Generated**

Your APK files are located at:
- **Debug APK**: `build/app/outputs/flutter-apk/app-debug.apk` (274MB)
- **Release APK**: `build/app/outputs/flutter-apk/app-release.apk` (194MB)

## 🚀 **Install on Physical Android Device**

### Method 1: Direct APK Installation
1. **Transfer APK to your device**:
   - Email the APK to yourself
   - Use AirDrop (if you have an iPhone)
   - Use Google Drive/Dropbox
   - Use USB cable and copy to Downloads folder

2. **Enable Unknown Sources**:
   - Go to Settings → Security → Unknown Sources
   - Enable "Allow installation from unknown sources"
   - Or go to Settings → Apps → Special app access → Install unknown apps

3. **Install the APK**:
   - Open File Manager
   - Navigate to Downloads folder
   - Tap on `app-release.apk`
   - Follow installation prompts

### Method 2: ADB Installation (Developer Mode)
1. **Enable Developer Options**:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect via USB**:
   ```bash
   # Check if device is connected
   adb devices
   
   # Install APK
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

## 📱 **Google Play Store Submission**

### Prerequisites
1. **Google Play Console Account** ($25 one-time fee)
2. **App Signing Key** (for production releases)
3. **Privacy Policy** ✅ (Already created)
4. **App Icons** ✅ (Already generated)
5. **Screenshots** (Need to create)

### Step 1: Create App Signing Key
```bash
# Generate a keystore for production
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Follow prompts:
# - Enter keystore password
# - Enter key password
# - Fill in certificate details
```

### Step 2: Configure App Signing
Create `android/key.properties`:
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore>/upload-keystore.jks
```

Update `android/app/build.gradle.kts`:
```kotlin
// Add at the top
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

### Step 3: Build Production APK
```bash
# Build signed APK
flutter build apk --release

# Or build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

### Step 4: Google Play Console Setup
1. **Create New App**:
   - App name: "Taal Trek"
   - Default language: English
   - App or game: App
   - Free or paid: Free

2. **App Content**:
   - **App description**: Use content from your README.md
   - **Short description**: "Interactive Dutch language learning with flashcards and exercises"
   - **Full description**: Copy from README.md features section
   - **Privacy Policy**: `https://github.com/skmonio/FlashCardWork/blob/main/PRIVACY.md`

3. **Graphics**:
   - **App icon**: Use generated icons from `build/app/outputs/flutter-apk/`
   - **Screenshots**: Take screenshots on different device sizes
   - **Feature graphic**: 1024x500px promotional image

4. **Content Rating**:
   - Complete content rating questionnaire
   - Educational app, no violence, no adult content

5. **Target Audience**:
   - Age: 3+ (Educational)
   - Content: Educational

### Step 5: Upload APK/Bundle
1. **Production Track**:
   - Upload your signed APK or App Bundle
   - Add release notes
   - Set rollout percentage (start with 10%)

2. **Internal Testing** (Optional):
   - Upload APK to internal testing
   - Add testers by email
   - Test before production release

### Step 6: Submit for Review
1. **Review Information**:
   - App category: Education
   - Tags: Language Learning, Education, Dutch
   - Contact details: stephenjohncook@outlook.com

2. **Content Rating**:
   - Complete questionnaire
   - Submit for rating

3. **Pricing & Distribution**:
   - Free app
   - Available in: Netherlands, Belgium, Worldwide
   - Content guidelines compliance

## 📋 **Required Assets for Play Store**

### Screenshots (Required)
Take screenshots on these device sizes:
- **Phone**: 1080x1920 (Portrait)
- **7-inch Tablet**: 1200x1920 (Portrait)
- **10-inch Tablet**: 1920x1200 (Landscape)

### Screenshot Content
1. **Home screen** with deck overview
2. **Flashcard study** interface
3. **Store** with vocabulary packs
4. **Exercises** section
5. **Settings** or profile screen

### Feature Graphic
- **Size**: 1024x500 pixels
- **Content**: App name, tagline, visual elements
- **Format**: PNG or JPEG

## 🔧 **Troubleshooting**

### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --release

# If ML Kit issues persist
flutter build apk --release --no-shrink
```

### Installation Issues
- **"App not installed"**: Check Android version compatibility
- **"Parse error"**: Corrupted APK, rebuild
- **"Permission denied"**: Enable unknown sources

### Play Store Issues
- **Rejected for ML Kit**: Add privacy policy section about camera usage
- **Rejected for permissions**: Justify camera/microphone usage in description
- **Rejected for content**: Ensure educational content only

## 📞 **Support**

For deployment issues:
- **Email**: stephenjohncook@outlook.com
- **GitHub**: https://github.com/skmonio/FlashCardWork/issues
- **Documentation**: [SUPPORT.md](https://github.com/skmonio/FlashCardWork/blob/main/SUPPORT.md)

## 🎯 **Next Steps**

1. **Test on physical device** using the generated APK
2. **Create app signing key** for production
3. **Take screenshots** for Play Store
4. **Set up Google Play Console** account
5. **Submit for review**

Your app is ready for deployment! 🚀
