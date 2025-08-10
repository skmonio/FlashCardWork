#!/bin/bash

# Set up environment
export PATH="$PATH:$HOME/flutter/bin"
export ANDROID_HOME=/Users/stephen/Library/Android/sdk
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Flutter iOS Persistent Release Configuration & Build${NC}"
echo -e "${BLUE}This will configure code signing and build a truly persistent release${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "ios" ]; then
    echo -e "${YELLOW}⚠️  Please run this script from the flashcard_app directory${NC}"
    echo -e "${YELLOW}   Example: cd flashcard_app && ./configure_and_build_persistent.sh${NC}"
    exit 1
fi

# Check if iOS device is connected
echo -e "${YELLOW}📱 Checking for connected iOS devices...${NC}"
DEVICES=$(flutter devices | grep -i "iphone\|ipad" || true)

if [ -z "$DEVICES" ]; then
    echo -e "${YELLOW}⚠️  No iOS devices found.${NC}"
    echo -e "${YELLOW}   This script will still configure code signing, but you'll need to:${NC}"
    echo -e "${YELLOW}   1. Connect your iPhone to your Mac${NC}"
    echo -e "${YELLOW}   2. Trust the computer on your iPhone${NC}"
    echo -e "${YELLOW}   3. Run this script again${NC}"
else
    echo -e "${GREEN}✅ Found iOS devices:${NC}"
    echo "$DEVICES"
fi

# Check current code signing configuration
echo -e "${YELLOW}🔐 Checking code signing configuration...${NC}"

DEVELOPMENT_TEAM=$(grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*DEVELOPMENT_TEAM = \([^;]*\);.*/\1/')

if [ -z "$DEVELOPMENT_TEAM" ] || [ "$DEVELOPMENT_TEAM" = "" ]; then
    echo -e "${RED}❌ No development team configured!${NC}"
    echo -e "${YELLOW}   This is required for persistent installation.${NC}"
else
    echo -e "${GREEN}✅ Development team configured: $DEVELOPMENT_TEAM${NC}"
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode not found! Please install Xcode from the App Store.${NC}"
    exit 1
fi

echo -e "${YELLOW}🔍 Opening Xcode for code signing configuration...${NC}"

# Open Xcode project
open ios/Runner.xcworkspace

echo ""
echo -e "${BLUE}📋 Manual Configuration Steps Required:${NC}"
echo ""
echo -e "${YELLOW}1. In Xcode (now open):${NC}"
echo -e "${YELLOW}   • Select the 'Runner' project in the left sidebar${NC}"
echo -e "${YELLOW}   • Click on the 'Runner' target (not the project)${NC}"
echo -e "${YELLOW}   • Go to 'Signing & Capabilities' tab${NC}"
echo ""
echo -e "${YELLOW}2. Configure both Debug and Release:${NC}"
echo -e "${YELLOW}   • ✅ Check 'Automatically manage signing'${NC}"
echo -e "${YELLOW}   • Select your 'Team' (Apple ID account)${NC}"
echo -e "${YELLOW}   • Ensure Bundle Identifier is unique${NC}"
echo ""
echo -e "${YELLOW}3. Test the configuration:${NC}"
echo -e "${YELLOW}   • Select your iPhone from the device dropdown${NC}"
echo -e "${YELLOW}   • Choose 'Release' configuration${NC}"
echo -e "${YELLOW}   • Click Run (▶️) or press Cmd+R${NC}"
echo -e "${YELLOW}   • Trust the developer on your iPhone if prompted${NC}"
echo ""

# Wait for user to configure
read -p "Press Enter when you've completed the configuration steps above..."

# Check configuration again
echo -e "${YELLOW}🔍 Re-checking code signing configuration...${NC}"
DEVELOPMENT_TEAM=$(grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*DEVELOPMENT_TEAM = \([^;]*\);.*/\1/')

if [ -z "$DEVELOPMENT_TEAM" ] || [ "$DEVELOPMENT_TEAM" = "" ]; then
    echo -e "${RED}❌ Development team still not configured!${NC}"
    echo -e "${YELLOW}   Please complete the configuration steps above and try again.${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Development team configured: $DEVELOPMENT_TEAM${NC}"
fi

# Check if iOS device is now connected
if [ -z "$DEVICES" ]; then
    echo -e "${YELLOW}📱 Checking for iOS devices again...${NC}"
    DEVICES=$(flutter devices | grep -i "iphone\|ipad" || true)
    
    if [ -z "$DEVICES" ]; then
        echo -e "${RED}❌ Still no iOS devices found!${NC}"
        echo -e "${YELLOW}   Please connect your iPhone and trust the computer, then run:${NC}"
        echo -e "${YELLOW}   ./build_persistent_release.sh${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Found iOS devices:${NC}"
        echo "$DEVICES"
    fi
fi

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Build persistent release version
echo -e "${YELLOW}🔨 Building persistent release version...${NC}"
flutter build ios --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    echo -e "${YELLOW}   Please check the error messages above and ensure:${NC}"
    echo -e "${YELLOW}   1. Code signing is properly configured in Xcode${NC}"
    echo -e "${YELLOW}   2. Your Apple ID is added to Xcode${NC}"
    echo -e "${YELLOW}   3. Your device is trusted and unlocked${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Release build completed successfully!${NC}"

# Install on device
echo -e "${YELLOW}📱 Installing persistent release version...${NC}"
flutter install --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}🎉 Successfully installed persistent release version!${NC}"
    echo ""
    echo -e "${GREEN}✅ Your app is now installed and will stay on your device!${NC}"
    echo -e "${GREEN}✅ You can:${NC}"
    echo -e "${GREEN}   • Close Xcode completely${NC}"
    echo -e "${GREEN}   • Disconnect your iPhone from your Mac${NC}"
    echo -e "${GREEN}   • Restart your iPhone${NC}"
    echo -e "${GREEN}   • Use the app without any Mac connection${NC}"
    echo ""
    echo -e "${BLUE}🎯 The app will behave exactly like your Swift app - truly persistent!${NC}"
    echo ""
    echo -e "${YELLOW}🔍 To verify persistence:${NC}"
    echo -e "${YELLOW}   1. Close Xcode completely${NC}"
    echo -e "${YELLOW}   2. Disconnect your iPhone from Mac${NC}"
    echo -e "${YELLOW}   3. Find your app on your iPhone and test it${NC}"
    echo -e "${YELLOW}   4. The app should work independently${NC}"
else
    echo -e "${RED}❌ Installation failed!${NC}"
    echo -e "${YELLOW}   This might be due to code signing issues. Please:${NC}"
    echo -e "${YELLOW}   1. Check Xcode for any signing errors${NC}"
    echo -e "${YELLOW}   2. Ensure your device is unlocked and trusted${NC}"
    echo -e "${YELLOW}   3. Try building and running directly from Xcode first${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎯 Summary:${NC}"
echo -e "${GREEN}   • Code signing configured${NC}"
echo -e "${GREEN}   • Persistent release build completed${NC}"
echo -e "${GREEN}   • App installed and will stay on device${NC}"
echo -e "${GREEN}   • App works independently without Mac connection${NC}"
echo ""
echo -e "${BLUE}💡 For future updates, just run: ./build_persistent_release.sh${NC}"
