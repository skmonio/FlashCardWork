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

echo -e "${GREEN}🚀 Installing Persistent Release Build on iPhone${NC}"
echo -e "${BLUE}This will install a release version that stays on your device${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check if we're in the right directory
if [ ! -d "ios" ]; then
    echo -e "${YELLOW}⚠️  Please run this script from the flashcard_app directory${NC}"
    echo -e "${YELLOW}   Example: cd flashcard_app && ./install_persistent_release.sh${NC}"
    exit 1
fi

# Check if iOS device is connected
echo -e "${YELLOW}📱 Checking for connected iOS devices...${NC}"
DEVICES=$(flutter devices | grep -i "iphone\|ipad" || true)

if [ -z "$DEVICES" ]; then
    echo -e "${RED}❌ No iOS devices found!${NC}"
    echo -e "${YELLOW}Please ensure:${NC}"
    echo -e "${YELLOW}   1. iPhone is connected via USB cable OR on same WiFi network${NC}"
    echo -e "${YELLOW}   2. iPhone is unlocked and trusted on this Mac${NC}"
    echo -e "${YELLOW}   3. iPhone is not in airplane mode${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Found iOS devices:${NC}"
    echo "$DEVICES"
fi

# Clean and prepare
echo -e "${YELLOW}🧹 Preparing build environment...${NC}"
flutter clean
flutter pub get

# Check code signing configuration
echo -e "${YELLOW}🔐 Checking code signing configuration...${NC}"
DEVELOPMENT_TEAM=$(grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*DEVELOPMENT_TEAM = \([^;]*\);.*/\1/')

if [ -z "$DEVELOPMENT_TEAM" ] || [ "$DEVELOPMENT_TEAM" = "" ]; then
    echo -e "${RED}❌ No development team configured!${NC}"
    echo -e "${YELLOW}Please configure code signing first:${NC}"
    echo -e "${YELLOW}   1. Open ios/Runner.xcworkspace in Xcode${NC}"
    echo -e "${YELLOW}   2. Select Runner project → Runner target${NC}"
    echo -e "${YELLOW}   3. Go to Signing & Capabilities tab${NC}"
    echo -e "${YELLOW}   4. Check 'Automatically manage signing'${NC}"
    echo -e "${YELLOW}   5. Select your Team${NC}"
    echo -e "${YELLOW}   6. Run this script again${NC}"
    open ios/Runner.xcworkspace
    exit 1
else
    echo -e "${GREEN}✅ Development team configured: $DEVELOPMENT_TEAM${NC}"
fi

# Build release version
echo -e "${YELLOW}🔨 Building release version...${NC}"
flutter build ios --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    echo -e "${YELLOW}Please check the error messages above.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Release build completed successfully!${NC}"

# Install on device using Flutter
echo -e "${YELLOW}📱 Installing release version on device...${NC}"
flutter install --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}🎉 Successfully installed persistent release version!${NC}"
    echo ""
    echo -e "${GREEN}✅ Your app is now installed and will stay on your device!${NC}"
    echo -e "${GREEN}✅ You can now:${NC}"
    echo -e "${GREEN}   • Close Xcode completely${NC}"
    echo -e "${GREEN}   • Disconnect your iPhone from Mac${NC}"
    echo -e "${GREEN}   • Restart your iPhone${NC}"
    echo -e "${GREEN}   • Use the app without any Mac connection${NC}"
    echo ""
    echo -e "${BLUE}🎯 The app will behave exactly like your Swift app - truly persistent!${NC}"
    echo ""
    echo -e "${YELLOW}🔍 To verify persistence:${NC}"
    echo -e "${YELLOW}   1. Close Xcode completely${NC}"
    echo -e "${YELLOW}   2. Disconnect your iPhone from Mac${NC}"
    echo -e "${YELLOW}   3. Find your app on your iPhone and test it${NC}"
    echo -e "${YELLOW}   4. The app should work independently and stay there${NC}"
else
    echo -e "${RED}❌ Installation failed!${NC}"
    echo ""
    echo -e "${YELLOW}🔧 Alternative Installation Method:${NC}"
    echo -e "${YELLOW}Let's try installing through Xcode directly:${NC}"
    echo ""
    echo -e "${YELLOW}1. Open Xcode:${NC}"
    echo -e "${YELLOW}   open ios/Runner.xcworkspace${NC}"
    echo ""
    echo -e "${YELLOW}2. In Xcode:${NC}"
    echo -e "${YELLOW}   • Select your iPhone from the device dropdown${NC}"
    echo -e "${YELLOW}   • Choose 'Release' configuration (NOT Debug)${NC}"
    echo -e "${YELLOW}   • Click Run (▶️) or press Cmd+R${NC}"
    echo -e "${YELLOW}   • Trust the developer certificate on your iPhone${NC}"
    echo ""
    echo -e "${YELLOW}3. Important:${NC}"
    echo -e "${YELLOW}   • Make sure you're using 'Release' configuration${NC}"
    echo -e "${YELLOW}   • NOT 'Debug' configuration${NC}"
    echo -e "${YELLOW}   • The app will be installed and stay on your device${NC}"
    echo ""
    echo -e "${YELLOW}4. After installation:${NC}"
    echo -e "${YELLOW}   • Close Xcode completely${NC}"
    echo -e "${YELLOW}   • Disconnect your iPhone from Mac${NC}"
    echo -e "${YELLOW}   • Test the app on your iPhone${NC}"
    echo -e "${YELLOW}   • It should work independently and stay there${NC}"
    
    # Open Xcode for manual installation
    echo ""
    echo -e "${YELLOW}📱 Opening Xcode for manual installation...${NC}"
    open ios/Runner.xcworkspace
fi

echo ""
echo -e "${GREEN}🎯 Summary:${NC}"
echo -e "${GREEN}   • Release build completed${NC}"
echo -e "${GREEN}   • App should be installed on your iPhone${NC}"
echo -e "${GREEN}   • App will stay on device when disconnected${NC}"
echo -e "${GREEN}   • No need to keep iPhone connected to Mac${NC}"
echo -e "${GREEN}   • You can close Xcode - app will remain${NC}"
echo ""
echo -e "${BLUE}💡 For future updates, just run this script again!${NC}"

