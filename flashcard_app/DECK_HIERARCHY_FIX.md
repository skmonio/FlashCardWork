# Deck Hierarchy Sorting Fix

## Problem Description

Previously, sub-decks were being displayed at the bottom of the deck list after all parent folders, instead of appearing directly under their respective parent decks in a hierarchical structure.

### Before Fix:
```
Animals (parent)
Colors (parent)
Zebra (child of Animals) - appeared at bottom
Antelope (child of Animals) - appeared at bottom
Red (child of Colors) - appeared at bottom
```

### After Fix:
```
Animals (parent)
Zebra (child of Animals) - appears immediately after parent
Antelope (child of Animals) - appears immediately after parent
Colors (parent)
Red (child of Colors) - appears immediately after parent
```

## Root Cause

The `_sortDecks` method in `all_decks_view.dart` was:
1. **Separating** parent and child decks correctly
2. **Sorting** them alphabetically within their groups
3. **Combining** them incorrectly by adding all parent decks first, then all child decks

This resulted in a flat structure instead of a hierarchical one.

## Solution Applied

### Modified `_sortDecks` Method

**File**: `flashcard_app/lib/views/all_decks_view.dart`

**Before**:
```dart
// Combine parent and child decks in hierarchical order
final result = <Deck>[];

// Add parent decks first
result.addAll(parentDecks);

// Add child decks after their parents
for (final parentDeck in parentDecks) {
  final children = childDecks.where((child) => child.parentId == parentDeck.id).toList();
  result.addAll(children);
}
```

**After**:
```dart
// Combine parent and child decks in hierarchical order
final result = <Deck>[];

// Add parent decks and their children in hierarchical order
for (final parentDeck in parentDecks) {
  // Add the parent deck
  result.add(parentDeck);
  
  // Add all children of this parent deck immediately after
  final children = childDecks.where((child) => child.parentId == parentDeck.id).toList();
  result.addAll(children);
}
```

## Key Changes

### 1. Hierarchical Ordering
- **Before**: All parents → All children (flat structure)
- **After**: Parent → Children → Parent → Children (hierarchical structure)

### 2. Immediate Child Placement
- **Before**: Children were collected and added at the end
- **After**: Children are added immediately after their parent

### 3. Maintained Sorting
- **Parent decks**: Still sorted alphabetically (A-Z or Z-A)
- **Child decks**: Still sorted alphabetically within their parent group
- **Hierarchy**: Preserved while maintaining alphabetical order

## Technical Implementation

### Sorting Logic
1. **Separate**: Parent and child decks into different lists
2. **Sort Parents**: Alphabetically by name (A-Z or Z-A based on user preference)
3. **Sort Children**: First by parent name, then by child name
4. **Combine Hierarchically**: For each parent, add it followed by all its children

### Visual Indicators
The UI already includes visual indicators for sub-decks:
- **Indentation**: 16px left margin
- **Arrow Icon**: `Icons.subdirectory_arrow_right`
- **"Sub-deck" Label**: Small text indicator

## Benefits

### 1. Improved Organization
- **Logical Structure**: Sub-decks appear under their parent decks
- **Better Navigation**: Users can easily find related content
- **Clear Hierarchy**: Visual relationship between parent and child decks

### 2. Enhanced User Experience
- **Intuitive Layout**: Follows expected folder structure
- **Reduced Scrolling**: Related content is grouped together
- **Better Discovery**: Users can see all related decks at once

### 3. Maintained Functionality
- **Sorting Preserved**: A-Z and Z-A sorting still works
- **Search Compatible**: Search functionality works with hierarchical display
- **Selection Mode**: Multi-selection works with hierarchical structure

## Example Scenarios

### Scenario 1: A-Z Sorting
**Input Decks**:
- Animals (parent)
- Colors (parent)
- Zebra (child of Animals)
- Antelope (child of Animals)
- Red (child of Colors)

**Output Order**:
1. Animals (parent)
2. Antelope (child of Animals)
3. Zebra (child of Animals)
4. Colors (parent)
5. Red (child of Colors)

### Scenario 2: Z-A Sorting
**Input Decks**:
- Animals (parent)
- Colors (parent)
- Zebra (child of Animals)
- Antelope (child of Animals)
- Red (child of Colors)

**Output Order**:
1. Colors (parent)
2. Red (child of Colors)
3. Animals (parent)
4. Antelope (child of Animals)
5. Zebra (child of Animals)

## Testing

### Manual Testing
1. **Create Parent Decks**: Create multiple parent decks
2. **Create Sub-decks**: Create sub-decks for different parents
3. **Verify Hierarchy**: Check that sub-decks appear under their parents
4. **Test Sorting**: Switch between A-Z and Z-A sorting
5. **Test Search**: Search for deck names and verify hierarchy is maintained

### Visual Verification
- Sub-decks should be indented with arrow icons
- Sub-decks should appear immediately after their parent
- Parent decks should be sorted alphabetically
- Child decks should be sorted alphabetically within their parent group

## Status

✅ **Issue Resolved**
- Sub-decks now appear under their parent decks
- Hierarchical structure is maintained
- Alphabetical sorting is preserved
- Visual indicators work correctly
- All existing functionality is maintained

## Notes

- The fix maintains backward compatibility
- No changes to the data model were required
- The UI already had proper visual indicators for sub-decks
- The sorting logic was already robust, only the combination logic needed adjustment
- Future deck hierarchy features will benefit from this improved structure
