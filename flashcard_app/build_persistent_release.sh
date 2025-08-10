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

echo -e "${GREEN}🚀 Flutter iOS Persistent Release Build${NC}"
echo -e "${BLUE}This will build a release version that truly stays on your iPhone${NC}"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check if iOS device is connected
echo -e "${YELLOW}📱 Checking for connected iOS devices...${NC}"
DEVICES=$(flutter devices | grep -i "iphone\|ipad" || true)

if [ -z "$DEVICES" ]; then
    echo -e "${RED}❌ No iOS devices found!${NC}"
    echo -e "${YELLOW}Please:${NC}"
    echo -e "${YELLOW}   1. Connect your iPhone to your Mac via USB cable${NC}"
    echo -e "${YELLOW}   2. OR ensure iPhone is on same WiFi network as Mac${NC}"
    echo -e "${YELLOW}   3. Trust the computer on your iPhone${NC}"
    echo -e "${YELLOW}   4. Run this script again${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Found iOS devices:${NC}"
    echo "$DEVICES"
fi

# Get the device ID (handle both USB and network connections)
DEVICE_ID=$(flutter devices | grep -i "iphone\|ipad" | head -1 | awk '{print $2}' | sed 's/[,•]//g' | tr -d ' ')

if [ -z "$DEVICE_ID" ] || [ "$DEVICE_ID" = "mobile" ] || [ "$DEVICE_ID" = "ios" ]; then
    # Try alternative method to get device ID
    DEVICE_ID=$(flutter devices | grep -i "iphone\|ipad" | head -1 | awk '{for(i=1;i<=NF;i++) if($i ~ /^[a-zA-Z0-9-]+$/) print $i}' | head -1)
fi

if [ -z "$DEVICE_ID" ]; then
    echo -e "${YELLOW}⚠️  Could not determine exact device ID, but will proceed with installation${NC}"
    DEVICE_ID="auto"
else
    echo -e "${YELLOW}🎯 Target device: $DEVICE_ID${NC}"
fi

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Check if we need to configure code signing
echo -e "${YELLOW}🔐 Checking code signing configuration...${NC}"

# Check if there's a valid development team configured
DEVELOPMENT_TEAM=$(grep -r "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj | head -1 | sed 's/.*DEVELOPMENT_TEAM = \([^;]*\);.*/\1/')

if [ -z "$DEVELOPMENT_TEAM" ] || [ "$DEVELOPMENT_TEAM" = "" ]; then
    echo -e "${YELLOW}⚠️  No development team configured. This is required for persistent installation.${NC}"
    echo -e "${YELLOW}   Please configure code signing in Xcode first:${NC}"
    echo -e "${YELLOW}   1. Open ios/Runner.xcworkspace in Xcode${NC}"
    echo -e "${YELLOW}   2. Select the Runner project${NC}"
    echo -e "${YELLOW}   3. Go to Signing & Capabilities tab${NC}"
    echo -e "${YELLOW}   4. Check 'Automatically manage signing'${NC}"
    echo -e "${YELLOW}   5. Select your Team${NC}"
    echo -e "${YELLOW}   6. Run this script again${NC}"
    
    # Open Xcode to help with configuration
    echo -e "${YELLOW}📱 Opening Xcode for code signing configuration...${NC}"
    open ios/Runner.xcworkspace
    exit 1
else
    echo -e "${GREEN}✅ Development team configured: $DEVELOPMENT_TEAM${NC}"
fi

# Build release version for iOS
echo -e "${YELLOW}🔨 Building persistent release version for iOS...${NC}"
flutter build ios --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Release build completed successfully!${NC}"

# Install on device
echo -e "${YELLOW}📱 Installing persistent release version on device...${NC}"
flutter install --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}🎉 Successfully installed persistent release version!${NC}"
    echo -e "${GREEN}✅ Your app is now installed and will stay on your device${NC}"
    echo -e "${GREEN}✅ You can disconnect your iPhone from your Mac${NC}"
    echo -e "${GREEN}✅ The app will continue to work without needing to be connected${NC}"
    echo -e "${GREEN}✅ You can close Xcode - the app will remain${NC}"
    
    # Additional verification
    echo -e "${YELLOW}🔍 Verifying installation...${NC}"
    if flutter devices | grep -q -i "iphone\|ipad"; then
        echo -e "${GREEN}✅ Device still connected and app installed${NC}"
    fi
    
else
    echo -e "${RED}❌ Installation failed!${NC}"
    echo -e "${YELLOW}This might be due to code signing issues. Please:${NC}"
    echo -e "${YELLOW}   1. Open ios/Runner.xcworkspace in Xcode${NC}"
    echo -e "${YELLOW}   2. Check the Signing & Capabilities tab${NC}"
    echo -e "${YELLOW}   3. Ensure 'Automatically manage signing' is checked${NC}"
    echo -e "${YELLOW}   4. Select your development team${NC}"
    echo -e "${YELLOW}   5. Build and run directly from Xcode (Cmd+R)${NC}"
    echo -e "${YELLOW}   6. OR try the manual installation method below${NC}"
    echo ""
    echo -e "${YELLOW}Manual Installation Method:${NC}"
    echo -e "${YELLOW}   1. Open ios/Runner.xcworkspace in Xcode${NC}"
    echo -e "${YELLOW}   2. Select your iPhone from the device dropdown${NC}"
    echo -e "${YELLOW}   3. Choose 'Release' configuration (not Debug)${NC}"
    echo -e "${YELLOW}   4. Click the Run button (▶️) or press Cmd+R${NC}"
    echo -e "${YELLOW}   5. Trust the developer certificate on your iPhone${NC}"
    echo -e "${YELLOW}   6. The app will be installed and stay on your device${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎯 Summary:${NC}"
echo -e "${GREEN}   • Persistence release build completed${NC}"
echo -e "${GREEN}   • App installed on your iPhone${NC}"
echo -e "${GREEN}   • App will stay on device when disconnected${NC}"
echo -e "${GREEN}   • No need to keep iPhone connected to Mac${NC}"
echo -e "${GREEN}   • You can close Xcode - app will remain${NC}"
echo ""
echo -e "${BLUE}💡 Tip: If you want to update the app later, just run this script again!${NC}"
echo ""
echo -e "${YELLOW}🔍 To verify persistence:${NC}"
echo -e "${YELLOW}   1. Close Xcode completely${NC}"
echo -e "${YELLOW}   2. Disconnect your iPhone from Mac${NC}"
echo -e "${YELLOW}   3. Find your app on your iPhone and test it${NC}"
echo -e "${YELLOW}   4. The app should work independently and stay there${NC}"
