# Flutter iOS Release Build Guide

This guide explains how to build and install release versions of the Flutter app on your iPhone that will stay on the device without needing to be connected to your Mac.

## 🎯 What You'll Get

- **Release builds**: Optimized, faster, smaller app size
- **Persistent installation**: App stays on your iPhone when disconnected from Mac
- **No debug overhead**: Removes debug code and symbols
- **Better performance**: Optimized for production use

## 🚀 Quick Start

### Option 1: Automatic Build & Install (Recommended)

1. **Connect your iPhone** to your Mac via USB cable
2. **Trust the computer** when prompted on your iPhone
3. **Run the build script**:
   ```bash
   cd flashcard_app
   ./build_and_install_release.sh
   ```

This script will:
- ✅ Check for connected iOS devices
- ✅ Clean previous builds
- ✅ Build the release version
- ✅ Install it on your iPhone
- ✅ Confirm the app will stay on your device

### Option 2: Manual Build Only

If you just want to build the release version without automatic installation:

```bash
cd flashcard_app
./build_release.sh
```

Then manually install using Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your iPhone as the target device
3. Click the Run button (or press Cmd+R)

## 🔧 Prerequisites

### Flutter Setup
- Flutter SDK installed and in PATH
- iOS development tools (Xcode) installed
- Valid Apple Developer account (for signing)

### Device Setup
- iPhone connected via USB cable
- iPhone trusted on Mac
- iPhone unlocked and accessible

## 📱 Device Preparation

1. **Connect iPhone** to Mac with USB cable
2. **Trust computer** when prompted on iPhone
3. **Unlock iPhone** (needed for installation)
4. **Keep iPhone awake** during installation

## 🏗️ Build Process Details

### What the Scripts Do

1. **Environment Check**
   - Verify Flutter is installed
   - Check for connected iOS devices
   - Validate build environment

2. **Clean Build**
   - Remove previous build artifacts
   - Update dependencies
   - Fresh build environment

3. **Release Build**
   - Build optimized release version
   - Remove debug code and symbols
   - Optimize for performance

4. **Installation**
   - Install on connected device
   - Verify installation success
   - Confirm app persistence

### Build Configurations

- **Debug**: Development builds (what you get with `flutter run`)
  - Larger app size
  - Debug symbols included
  - Performance overhead
  - Needs Mac connection

- **Release**: Production builds (what these scripts create)
  - Smaller app size
  - Optimized performance
  - No debug overhead
  - Stays on device

## 🎨 Scripts Overview

### `build_and_install_release.sh`
- **Purpose**: Complete build and install process
- **Use case**: When you want to test the release version immediately
- **Output**: App installed and running on your iPhone

### `build_release.sh`
- **Purpose**: Build only (no automatic installation)
- **Use case**: When you want to install manually or archive
- **Output**: Built app in `build/ios/iphoneos/Release-iphoneos/`

## 🔍 Troubleshooting

### Common Issues

#### "No iOS devices found"
- **Solution**: Make sure iPhone is connected and trusted
- **Check**: Run `flutter devices` to verify device detection

#### "Build failed"
- **Solution**: Check Flutter installation and dependencies
- **Check**: Run `flutter doctor` for issues

#### "Installation failed"
- **Solution**: Try manual installation via Xcode
- **Check**: Ensure iPhone is unlocked and trusted

#### "Code signing issues"
- **Solution**: Open project in Xcode and configure signing
- **Check**: Verify Apple Developer account and certificates

### Manual Installation Steps

If automatic installation fails:

1. **Open Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Select Device**:
   - Choose your iPhone from the device dropdown
   - Make sure it's connected and trusted

3. **Build & Run**:
   - Select "Release" configuration
   - Click the Run button (▶️) or press Cmd+R

4. **Verify Installation**:
   - App should appear on your iPhone
   - App should work without Mac connection

## 📊 Performance Comparison

| Aspect | Debug Build | Release Build |
|--------|-------------|---------------|
| App Size | ~50-100MB | ~20-40MB |
| Performance | Slower | Optimized |
| Debug Info | Included | Removed |
| Device Persistence | No | Yes |
| Mac Connection | Required | Not needed |

## 🎯 Best Practices

1. **Always use release builds** for testing production behavior
2. **Test thoroughly** before distributing
3. **Keep backups** of your app data
4. **Monitor performance** after installation
5. **Update regularly** as you develop new features

## 🔄 Updating the App

To update the installed release version:

1. **Make your code changes**
2. **Run the build script again**:
   ```bash
   ./build_and_install_release.sh
   ```
3. **The new version will replace the old one**

## 📞 Support

If you encounter issues:

1. **Check this guide** for common solutions
2. **Run `flutter doctor`** for environment issues
3. **Check Xcode console** for detailed error messages
4. **Verify device connection** and trust settings

## 🎉 Success!

Once you've successfully built and installed the release version:

- ✅ Your app is installed on your iPhone
- ✅ It will work without being connected to your Mac
- ✅ It's optimized for performance
- ✅ It's ready for production use

**Enjoy your Flutter app! 🚀**
