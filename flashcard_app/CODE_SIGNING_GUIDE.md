# iOS Code Signing Guide for Persistent Release Builds

This guide will help you configure code signing so your Flutter app will truly stay on your iPhone without needing to be connected to your Mac or having Xcode open.

## 🎯 The Problem

Even though we're building release versions, Flutter apps need proper code signing to:
- **Persist on device** when disconnected from Mac
- **Work independently** without Xcode running
- **Survive device restarts** and app updates

## 🔐 Code Signing Requirements

### For Persistent Installation
1. **Apple Developer Account** (free or paid)
2. **Development Team** configured in Xcode
3. **Valid provisioning profile** for your device
4. **Code signing identity** properly set up

### Types of Installation
- **Development Build** (default `flutter run`)
  - Requires Mac connection
  - Expires after 7 days
  - Needs Xcode for debugging
  - **Doesn't persist** when disconnected

- **Release Build** (with proper signing) ← **What we want**
  - Works independently
  - Stays on device permanently
  - No Mac connection needed
  - **Persists** when disconnected

## 🚀 Step-by-Step Configuration

### Step 1: Open Xcode Project

```bash
cd flashcard_app
open ios/Runner.xcworkspace
```

### Step 2: Configure Code Signing

1. **Select the Runner project** in the left sidebar
2. **Click on the Runner target** (not the project)
3. **Go to "Signing & Capabilities" tab**
4. **Configure the following:**

#### For Debug Configuration:
- ✅ Check **"Automatically manage signing"**
- Select your **Team** (Apple ID account)
- Bundle Identifier: `com.skmonio.taaltrek2` (or your preferred identifier)

#### For Release Configuration:
- ✅ Check **"Automatically manage signing"**
- Select your **Team** (same as Debug)
- Bundle Identifier: `com.skmonio.taaltrek2` (or your preferred identifier)

### Step 3: Verify Team Selection

Make sure you see:
- **Team**: Your Apple ID or organization name
- **Bundle Identifier**: Unique identifier for your app
- **Provisioning Profile**: Automatically managed

### Step 4: Test the Configuration

1. **Select your iPhone** from the device dropdown
2. **Choose "Release"** configuration
3. **Click the Run button** (▶️) or press Cmd+R
4. **Trust the developer** on your iPhone when prompted

## 🔍 Troubleshooting Code Signing

### Issue: "No development team selected"
**Solution:**
1. Open `ios/Runner.xcodeproj/project.pbxproj`
2. Look for `DEVELOPMENT_TEAM` entries
3. Ensure they have your team ID (not empty)

### Issue: "Code signing is required"
**Solution:**
1. Go to Xcode → Preferences → Accounts
2. Add your Apple ID if not already added
3. Click "Download Manual Profiles"
4. Restart Xcode

### Issue: "Provisioning profile not found"
**Solution:**
1. Check "Automatically manage signing" is selected
2. Select your Team in all configurations
3. Clean and rebuild: `flutter clean && flutter pub get`

### Issue: "Bundle identifier conflicts"
**Solution:**
1. Change the bundle identifier to something unique
2. Use format: `com.yourname.flashcardapp`
3. Update in both Debug and Release configurations

## 🎯 Verification Steps

### Before Running the Script

1. **Check Xcode configuration:**
   ```bash
   # Look for development team in project file
   grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj
   ```

2. **Verify code signing is set up:**
   - Open Xcode
   - Check Signing & Capabilities tab
   - Ensure "Automatically manage signing" is checked
   - Confirm Team is selected

### After Installation

1. **Test persistence:**
   - Install the app using our script
   - Close Xcode completely
   - Disconnect iPhone from Mac
   - Verify app still works and is accessible

2. **Test independence:**
   - Restart your iPhone
   - Check if app is still there and functional
   - Use app without any Mac connection

## 🔄 Complete Workflow

### Initial Setup (One-time)
1. **Configure code signing** in Xcode (see steps above)
2. **Test with Xcode** to ensure everything works
3. **Run our script** to build and install

### Regular Development
```bash
# Make your code changes
cd flashcard_app

# Build and install persistent release version
./build_persistent_release.sh

# App will be installed and stay on device
# No need to keep Mac connected or Xcode open
```

### Updating the App
```bash
# Make changes to your code
cd flashcard_app

# Run the same script to update
./build_persistent_release.sh

# New version will replace the old one
# App remains persistent and independent
```

## 🎯 Key Differences

| Aspect | Development Build | Persistent Release Build |
|--------|------------------|-------------------------|
| Installation | Via `flutter run` | Via release scripts |
| Persistence | 7 days, needs Mac | Permanent, independent |
| Performance | Debug overhead | Optimized |
| Code signing | Automatic (debug) | Manual (release) |
| Device connection | Required | Not needed |
| Xcode dependency | Yes | No |

## 🔍 Common Issues & Solutions

### Issue: App disappears after disconnecting
**Cause:** Not properly code signed for release
**Solution:** Follow the code signing configuration steps above

### Issue: "Can't be opened because it is from an unidentified developer"
**Cause:** Security settings on Mac/iPhone
**Solution:** 
1. Go to System Preferences → Security & Privacy
2. Click "Open Anyway" for the app
3. On iPhone: Settings → General → Device Management → Trust your developer certificate

### Issue: Build fails with code signing errors
**Cause:** Incorrect provisioning profile or team
**Solution:**
1. Check Xcode signing configuration
2. Ensure Apple ID is added to Xcode
3. Download manual profiles if needed

## 🎉 Success Criteria

Your Flutter app is properly configured when:
- ✅ **Opens in Xcode** without signing errors
- ✅ **Builds and installs** via our scripts
- ✅ **Stays on device** when disconnected from Mac
- ✅ **Works independently** without Xcode running
- ✅ **Persists through** device restarts
- ✅ **Survives updates** and app replacements

## 📞 Support

If you're still having issues:

1. **Check Xcode console** for detailed error messages
2. **Verify Apple Developer account** is active
3. **Ensure device is trusted** and unlocked
4. **Check bundle identifier** is unique and consistent
5. **Confirm development team** is properly selected

---

**Once properly configured, your Flutter app will behave exactly like your Swift app - it will stay on your iPhone and work independently! 🎯**
