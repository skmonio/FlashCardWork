#!/bin/bash

# Set up environment
export PATH="$PATH:$HOME/flutter/bin"
export ANDROID_HOME=/Users/stephen/Library/Android/sdk
export JAVA_HOME=/opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk/Contents/Home

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Flutter iOS Release Build...${NC}"

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

# Check if iOS device is connected
echo -e "${YELLOW}📱 Checking for connected iOS devices...${NC}"
DEVICES=$(flutter devices | grep -i "iphone\|ipad" || true)

if [ -z "$DEVICES" ]; then
    echo -e "${YELLOW}⚠️  No iOS devices found. Make sure your iPhone is connected and trusted.${NC}"
    echo -e "${YELLOW}   You can still build the release version, but you'll need to install it manually.${NC}"
else
    echo -e "${GREEN}✅ Found iOS devices:${NC}"
    echo "$DEVICES"
fi

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Build release version for iOS
echo -e "${YELLOW}🔨 Building release version for iOS...${NC}"
flutter build ios --release --no-codesign

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Release build completed successfully!${NC}"
    echo -e "${GREEN}📁 Build artifacts are in: build/ios/iphoneos/Release-iphoneos/${NC}"
    
    # Check if device is connected for installation
    if [ ! -z "$DEVICES" ]; then
        echo -e "${YELLOW}📱 Installing on connected device...${NC}"
        flutter install --release
    else
        echo -e "${YELLOW}📋 To install on your iPhone:${NC}"
        echo -e "${YELLOW}   1. Open Xcode${NC}"
        echo -e "${YELLOW}   2. Open ios/Runner.xcworkspace${NC}"
        echo -e "${YELLOW}   3. Select your iPhone as the target device${NC}"
        echo -e "${YELLOW}   4. Click the Run button (or Cmd+R)${NC}"
        echo -e "${YELLOW}   5. The app will be installed and stay on your device${NC}"
    fi
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 Release build process completed!${NC}"
