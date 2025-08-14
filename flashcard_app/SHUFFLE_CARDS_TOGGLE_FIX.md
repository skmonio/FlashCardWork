# Shuffle Cards Toggle Fix

## Problem

Users reported that the toggle switches in the shuffle cards customization dialog didn't update visually when tapped, making it impossible to see which exercise types were enabled or disabled.

## Root Cause

The issue was caused by two main problems:

1. **Dialog State Management**: The toggle switches were using the parent widget's state, but the dialog wasn't rebuilding when the state changed because `setState` was called on the parent widget, not the dialog itself.

2. **Missing Persistence**: The enabled/disabled states weren't being saved to SharedPreferences, so settings were lost when the app restarted.

## Solution

### 1. Created Separate Stateful Dialog Widget

Created a new `ShuffleCustomizationDialog` widget that manages its own state:

```dart
class ShuffleCustomizationDialog extends StatefulWidget {
  final Map<ShuffleMode, bool> enabledModes;
  final Function(Map<ShuffleMode, bool>) onSettingsChanged;

  const ShuffleCustomizationDialog({
    super.key,
    required this.enabledModes,
    required this.onSettingsChanged,
  });

  @override
  State<ShuffleCustomizationDialog> createState() => _ShuffleCustomizationDialogState();
}
```

### 2. Added Persistence

Added methods to save and load the enabled modes:

```dart
void _loadEnabledModes() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _enabledModes = {
      ShuffleMode.multipleChoice: prefs.getBool('shuffle_mode_multiple_choice') ?? true,
      ShuffleMode.trueFalse: prefs.getBool('shuffle_mode_true_false') ?? true,
      ShuffleMode.memoryGame: prefs.getBool('shuffle_mode_memory_game') ?? true,
      ShuffleMode.wordScramble: prefs.getBool('shuffle_mode_word_scramble') ?? true,
      ShuffleMode.writing: prefs.getBool('shuffle_mode_writing') ?? true,
      ShuffleMode.dutchExercise: prefs.getBool('shuffle_mode_dutch_exercise') ?? true,
    };
  });
}

void _saveEnabledModes() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('shuffle_mode_multiple_choice', _enabledModes[ShuffleMode.multipleChoice] ?? true);
  await prefs.setBool('shuffle_mode_true_false', _enabledModes[ShuffleMode.trueFalse] ?? true);
  await prefs.setBool('shuffle_mode_memory_game', _enabledModes[ShuffleMode.memoryGame] ?? true);
  await prefs.setBool('shuffle_mode_word_scramble', _enabledModes[ShuffleMode.wordScramble] ?? true);
  await prefs.setBool('shuffle_mode_writing', _enabledModes[ShuffleMode.writing] ?? true);
  await prefs.setBool('shuffle_mode_dutch_exercise', _enabledModes[ShuffleMode.dutchExercise] ?? true);
}
```

### 3. Added Visual Feedback

Added a summary section below the start button that shows which exercise types are currently enabled:

```dart
// Enabled modes summary
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.grey.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.withOpacity(0.3)),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.settings, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            'Enabled Exercise Types:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: _buildEnabledModeChips(),
      ),
    ],
  ),
),
```

### 4. Fixed Dialog Layout

Made the dialog scrollable to prevent layout overflow issues:

```dart
content: SizedBox(
  width: double.maxFinite,
  height: 400, // Fixed height to prevent overflow
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Text('Select which exercise types to include in shuffle mode:'),
      const SizedBox(height: 16),
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Toggle switches here
            ],
          ),
        ),
      ),
    ],
  ),
),
```

## Features Added

### Visual Indicators

- **"All Types Enabled"** - Green chip when all exercise types are enabled
- **"No Types Enabled"** - Red chip when no exercise types are enabled  
- **"X of Y Types"** - Blue chip showing count when some types are enabled

### Persistence

- Settings are automatically saved when changed
- Settings are loaded when the app starts
- Default state is all types enabled

### Improved UX

- Toggle switches now update immediately when tapped
- Visual feedback shows current state
- Dialog is scrollable to prevent overflow
- Settings persist across app restarts

## Testing

Added comprehensive tests in `test/shuffle_cards_persistence_test.dart`:

- ✅ Loads default settings when none saved
- ✅ Saves and loads custom settings
- ✅ Shows settings dialog with correct states
- ✅ Updates toggle state when switched

## Files Modified

- `lib/views/shuffle_cards_view.dart` - Main implementation
- `test/shuffle_cards_persistence_test.dart` - Tests

## Usage

1. **Access Settings**: Tap the settings icon in the app bar
2. **Toggle Exercise Types**: Tap any toggle switch to enable/disable
3. **See Current State**: View the summary below the start button
4. **Settings Persist**: Changes are automatically saved

The fix ensures users can now clearly see which exercise types are enabled and their settings are preserved across app sessions.
