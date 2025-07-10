# 🫧 Bubble Word Feature

## Overview

Bubble Word is an interactive word bubble diagram feature that allows users to create, organize, and connect vocabulary words visually. Perfect for mind mapping, vocabulary building, concept organization, and brainstorming.

## Features

### Core Functionality
- **Interactive Word Bubbles**: Tap to select, double-tap to edit, drag to move
- **Visual Connections**: Tap two bubbles to create connecting lines between them
- **Zoom & Pan**: Pinch to zoom in/out, drag with two fingers to pan around
- **Data Persistence**: Automatically saves to UserDefaults
- **Random Colors**: 9 different bubble colors assigned automatically
- **Toolbar Controls**: Zoom in/out, reset view, add words, disconnect nodes
- **Delete Functionality**: Remove unwanted bubbles

### User Interface
- **Toolbar**: Zoom controls, reset view, disconnect options
- **Add Word Sheet**: Modal interface for adding new words
- **Edit Word Sheet**: Placeholder for future word editing functionality
- **Alerts**: Confirmation dialogs for destructive actions

## How to Use

### Adding Words
1. Tap the "Add Word" button in the navigation bar
2. Enter a word in the text field
3. Tap "Add Word" to create the bubble

### Creating Connections
1. Tap on one bubble to select it
2. Tap on another bubble to create a connection between them
3. The connection will be drawn as a gray line

### Moving Bubbles
- Drag any bubble to move it around the canvas
- Connections will automatically update to follow the bubbles

### Zooming and Panning
- **Zoom In/Out**: Use the toolbar buttons or pinch gestures
- **Pan**: Drag with two fingers to move around the canvas
- **Reset View**: Tap "Reset View" to return to the original position and scale

### Managing Connections
1. Select a bubble that has connections
2. Tap "Disconnect" in the toolbar
3. Confirm the disconnection in the alert dialog

### Deleting Bubbles
1. Tap on a bubble to select it
2. Tap the red "X" button that appears below the bubble
3. The bubble and all its connections will be removed

### Resetting Everything
1. Tap "Reset" in the navigation bar
2. Confirm the action in the alert dialog
3. All words and connections will be deleted

## Technical Implementation

### Files Created
- `FlashCard/Models/WordNode.swift` - Data models and state management
- `FlashCard/Views/BubbleWordView.swift` - Main view and bubble component

### Data Models
- `WordNode`: Represents a word bubble with position, color, and connections
- `WordConnection`: Represents a connection between two bubbles
- `BubbleWordManager`: ObservableObject that manages the state and persistence

### Integration
- Added to `NavigationDestination` enum as `.bubbleWord`
- Integrated into `MainNavigationView` destination routing
- Added button to Resources section in home tab

### Persistence
- Uses UserDefaults to save nodes and connections
- Automatically loads data when the view appears
- Saves changes immediately when modifications are made

## Customization Options

### Colors
The feature uses 9 predefined colors:
- Blue, Green, Orange, Purple, Red, Pink, Yellow, Mint, Indigo

### Bubble Styling
- Corner radius: 20 points
- Shadow effects for depth
- White border when selected
- Scale animation on selection

### Positioning
- Smart positioning algorithm to avoid overlaps
- Minimum spacing of 150 points between bubbles
- Fallback to random positioning if needed

## Future Enhancements

### Planned Features
- Word editing functionality
- Export/import bubble diagrams
- Custom color selection
- Text size adjustment
- Connection labels
- Undo/redo functionality
- Search and filter bubbles

### Integration Ideas
- Connect with existing flashcard vocabulary
- Import words from study sessions
- Export to study decks
- Share bubble diagrams

## Troubleshooting

### Common Issues
1. **Bubbles not appearing**: Check if UserDefaults data is corrupted
2. **Gestures not working**: Ensure no overlapping gesture recognizers
3. **Performance issues**: Limit the number of bubbles for optimal performance

### Debug Tips
- Use the reset function to clear corrupted data
- Check console for any error messages
- Verify that all files are included in the Xcode project target

## Requirements

- **iOS**: 16.0+
- **Swift**: 5.0+
- **SwiftUI**: Required
- **Xcode**: 14.0+ (recommended)

## Usage Statistics

The feature tracks:
- Number of words created
- Number of connections made
- Usage frequency
- Session duration

This data helps improve the feature and understand user behavior patterns. 