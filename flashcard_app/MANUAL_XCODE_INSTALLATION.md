# Manual Xcode Installation Guide

## 🎯 Why Manual Installation?

If the automatic scripts don't work, this manual method will definitely work to install a persistent release build on your iPhone.

## 🚀 Step-by-Step Instructions

### Step 1: Open Xcode Project
```bash
cd flashcard_app
open ios/Runner.xcworkspace
```

### Step 2: Configure for Release Build

1. **Select your iPhone** from the device dropdown at the top
2. **Change configuration to "Release"**:
   - Click on the scheme dropdown (next to the device dropdown)
   - Select "Runner" → "Release"
   - OR go to Product → Scheme → Edit Scheme → Run → Build Configuration → Release

### Step 3: Verify Code Signing

1. **Select the Runner project** in the left sidebar
2. **Click on the Runner target** (not the project)
3. **Go to "Signing & Capabilities" tab**
4. **Ensure:**
   - ✅ "Automatically manage signing" is checked
   - ✅ Your Team is selected (e.g., "S Cook")
   - ✅ Bundle Identifier is unique (e.g., "com.skmonio.taaltrek2")

### Step 4: Build and Install

1. **Make sure "Release" configuration is selected**
2. **Click the Run button (▶️)** or press **Cmd+R**
3. **Wait for the build to complete**
4. **Trust the developer certificate** on your iPhone when prompted
5. **The app will install and open on your device**

### Step 5: Test Persistence

1. **Close Xcode completely** (Cmd+Q)
2. **Disconnect your iPhone** from your Mac
3. **Find your app** on your iPhone's home screen
4. **Open and test the app** - it should work independently
5. **Restart your iPhone** - the app should still be there

## 🔍 Important Notes

### Configuration Differences

| Setting | Debug (Default) | Release (What we want) |
|---------|----------------|------------------------|
| **Build Configuration** | Debug | **Release** |
| **Performance** | Debug symbols, slower | **Optimized, faster** |
| **Persistence** | 7 days, needs Mac | **Permanent, independent** |
| **App Size** | Larger | **Smaller** |

### Troubleshooting

#### Issue: App still disappears after closing Xcode
**Solution**: Make sure you're using "Release" configuration, not "Debug"

#### Issue: "Can't be opened because it is from an unidentified developer"
**Solution**: 
1. On iPhone: Settings → General → Device Management
2. Trust your developer certificate

#### Issue: Build fails
**Solution**:
1. Check code signing configuration
2. Ensure your Team is selected
3. Try cleaning: Product → Clean Build Folder

#### Issue: Device not showing in Xcode
**Solution**:
1. Make sure iPhone is unlocked
2. Trust the computer on your iPhone
3. Check if iPhone is in developer mode

## 🎯 Success Criteria

Your app is successfully installed when:
- ✅ **App appears on iPhone home screen**
- ✅ **App opens and works normally**
- ✅ **App stays on device when Xcode is closed**
- ✅ **App works when iPhone is disconnected from Mac**
- ✅ **App persists through iPhone restarts**

## 🔄 For Future Updates

To update your app:
1. **Make your code changes**
2. **Follow the same steps above**
3. **Build and install the new version**
4. **The new version will replace the old one**
5. **App remains persistent and independent**

## 📞 Support

If you still have issues:
1. **Check Xcode console** for error messages
2. **Verify code signing** is properly configured
3. **Ensure you're using Release configuration**
4. **Make sure your device is trusted and unlocked**

---

**This manual method will definitely work to install a persistent release build on your iPhone! 🎯**

