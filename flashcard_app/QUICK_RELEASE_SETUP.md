# Quick Release Setup Guide

## 🎯 Fastest Way to Release Configuration

### Step 1: Open Xcode
```bash
cd flashcard_app
open ios/Runner.xcworkspace
```

### Step 2: Find Scheme Dropdown
Look at the **top toolbar** for:
```
[Runner ▼] [iPhone Name] [▶️ Run]
   ↑
Click here
```

### Step 3: Edit Scheme
1. **Click "Runner"** dropdown
2. **Select "Edit Scheme..."**

### Step 4: Change to Release
1. **Select "Run"** in left sidebar
2. **Change "Build Configuration"** to **"Release"**
3. **Click "Close"**

### Step 5: Build and Install
1. **Click Run (▶️)** or press **Cmd+R**
2. **Trust certificate** on iPhone when prompted
3. **App will install and stay permanently**

## 🔍 Alternative Methods

### Method 2: Menu Bar
- **Product** → **Scheme** → **Edit Scheme...**

### Method 3: Keyboard
- Press **Cmd + <** (Command + Less Than)

## ✅ Success Checklist

- [ ] Scheme dropdown shows "Runner"
- [ ] Build Configuration shows "Release"
- [ ] iPhone is selected as target device
- [ ] Build completes without errors
- [ ] App installs on iPhone
- [ ] App stays when Xcode is closed
- [ ] App works when disconnected from Mac

## 🎯 Key Point

**You MUST use "Release" configuration for the app to stay on your iPhone permanently!**

Debug configuration = App disappears when Xcode closes
**Release configuration = App stays permanently** ✅

