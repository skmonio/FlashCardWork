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

echo -e "${GREEN}🚀 Flutter iOS Release Build & Install${NC}"
echo -e "${BLUE}This will build a release version that stays on your iPhone${NC}"
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
    echo -e "${YELLOW}   1. Connect your iPhone to your Mac${NC}"
    echo -e "${YELLOW}   2. Trust the computer on your iPhone${NC}"
    echo -e "${YELLOW}   3. Run this script again${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Found iOS devices:${NC}"
    echo "$DEVICES"
fi

# Get the device ID
DEVICE_ID=$(flutter devices | grep -i "iphone\|ipad" | head -1 | awk '{print $1}' | sed 's/.*\([a-zA-Z0-9-]*\)/\1/')

if [ -z "$DEVICE_ID" ]; then
    echo -e "${RED}❌ Could not determine device ID${NC}"
    exit 1
fi

echo -e "${YELLOW}🎯 Target device: $DEVICE_ID${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Build release version for iOS
echo -e "${YELLOW}🔨 Building release version for iOS...${NC}"
flutter build ios --release

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Release build completed successfully!${NC}"

# Install on device
echo -e "${YELLOW}📱 Installing release version on device...${NC}"
flutter install --release

if [ $? -eq 0 ]; then
    echo -e "${GREEN}🎉 Successfully installed release version!${NC}"
    echo -e "${GREEN}✅ Your app is now installed and will stay on your device${NC}"
    echo -e "${GREEN}✅ You can disconnect your iPhone from your Mac${NC}"
    echo -e "${GREEN}✅ The app will continue to work without needing to be connected${NC}"
else
    echo -e "${RED}❌ Installation failed!${NC}"
    echo -e "${YELLOW}You can manually install using Xcode:${NC}"
    echo -e "${YELLOW}   1. Open ios/Runner.xcworkspace in Xcode${NC}"
    echo -e "${YELLOW}   2. Select your iPhone as the target device${NC}"
    echo -e "${YELLOW}   3. Click the Run button (or Cmd+R)${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}🎯 Summary:${NC}"
echo -e "${GREEN}   • Release build completed${NC}"
echo -e "${GREEN}   • App installed on your iPhone${NC}"
echo -e "${GREEN}   • App will stay on device when disconnected${NC}"
echo -e "${GREEN}   • No need to keep iPhone connected to Mac${NC}"
