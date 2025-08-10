#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Opening Flutter iOS project in Xcode...${NC}"

# Check if we're in the right directory
if [ ! -d "ios" ]; then
    echo -e "${YELLOW}⚠️  Please run this script from the flashcard_app directory${NC}"
    echo -e "${YELLOW}   Example: cd flashcard_app && ./open_in_xcode.sh${NC}"
    exit 1
fi

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${YELLOW}⚠️  Xcode not found. Please install Xcode from the App Store.${NC}"
    exit 1
fi

# Check if the workspace exists
if [ ! -f "ios/Runner.xcworkspace" ]; then
    echo -e "${YELLOW}⚠️  Runner.xcworkspace not found. Running flutter pub get...${NC}"
    flutter pub get
fi

echo -e "${BLUE}📱 Opening ios/Runner.xcworkspace in Xcode...${NC}"
open ios/Runner.xcworkspace

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Xcode opened successfully!${NC}"
    echo ""
    echo -e "${YELLOW}📋 Next steps for manual installation:${NC}"
    echo -e "${YELLOW}   1. In Xcode, select your iPhone from the device dropdown${NC}"
    echo -e "${YELLOW}   2. Make sure 'Release' configuration is selected${NC}"
    echo -e "${YELLOW}   3. Click the Run button (▶️) or press Cmd+R${NC}"
    echo -e "${YELLOW}   4. Trust the developer certificate on your iPhone if prompted${NC}"
    echo -e "${YELLOW}   5. The app will be installed and stay on your device${NC}"
    echo ""
    echo -e "${GREEN}🎯 Your app will be installed as a release version that stays on your iPhone!${NC}"
else
    echo -e "${YELLOW}❌ Failed to open Xcode. Please open ios/Runner.xcworkspace manually.${NC}"
fi
