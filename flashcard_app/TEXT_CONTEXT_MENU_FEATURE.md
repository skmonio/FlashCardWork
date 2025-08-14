# Text Context Menu Feature

## Overview

The Text Context Menu feature enhances the user experience in exercises by providing quick access to useful actions when text is selected. Users can now select any text in exercise prompts, explanations, hints, and answer options to access a context menu with various options.

## Features

### Available Actions

1. **Copy** - Copy selected text to clipboard
2. **Translate** - Translate selected text from Dutch to English using Google Translate API
3. **Add to Deck** - Add selected word to a flashcard deck (placeholder for future implementation)
4. **Search** - Search for selected word in existing flashcards (placeholder for future implementation)

### Where It Works

The context menu is available in the following exercise views:

- **Dutch Word Exercise Detail View** (`dutch_word_exercise_detail_view.dart`)
  - Exercise prompts
  - Explanations
  - Correct answers
  - Hints

- **Dutch Words Practice View** (`dutch_words_practice_view.dart`)
  - Exercise prompts
  - Explanations
  - Correct answers
  - Hints

- **Dutch Grammar Exercise View** (`dutch_grammar_exercise_view.dart`)
  - Exercise questions
  - Answer options

## Implementation Details

### Components

- **TextContextMenu** (`components/text_context_menu.dart`) - The main context menu widget
- **TranslationService** (`services/translation_service.dart`) - Handles translation requests

### How to Use

1. **Select Text**: Long press and drag to select any text in exercises
2. **Access Menu**: A context menu will appear with available actions
3. **Choose Action**: Tap on the desired action

### Technical Implementation

The context menu is implemented by replacing the default `contextMenuBuilder` in `SelectableText` widgets:

```dart
SelectableText(
  text,
  contextMenuBuilder: (context, editableTextState) {
    final selectedText = editableTextState.textEditingValue.selection.textInside(text);
    if (selectedText.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return TextContextMenu(
      selectedText: selectedText,
      onCopy: () { /* handled internally */ },
      onTranslate: () { /* handled internally */ },
      onAddToDeck: () { _addWordToDeck(selectedText); },
      onSearch: () { _searchWord(selectedText); },
    );
  },
)
```

### Translation Service

The translation feature uses Google Translate API through a free endpoint:

- **Endpoint**: `https://translate.googleapis.com/translate_a/single`
- **Source Language**: Dutch (nl)
- **Target Language**: English (en)
- **Fallback**: Local dictionary for common words

### Future Enhancements

1. **Add to Deck**: Implement actual functionality to add selected words to flashcard decks
2. **Search**: Implement search functionality to find words in existing flashcards
3. **Offline Translation**: Add offline translation capabilities
4. **Custom Actions**: Allow users to add custom actions to the context menu
5. **Multiple Languages**: Support translation to languages other than English

## Testing

The feature includes comprehensive tests in `test/text_context_menu_test.dart` that verify:

- Text preview display
- All menu options are present
- Conditional display of options
- Callback functionality
- Translation service integration

## Usage Examples

### Basic Usage
```dart
TextContextMenu(
  selectedText: "selected word",
)
```

### Custom Options
```dart
TextContextMenu(
  selectedText: "selected word",
  showAddToDeck: false,  // Hide add to deck option
  showSearch: false,     // Hide search option
  onCopy: () {
    // Custom copy action
  },
)
```

## Dependencies

- `flutter/services.dart` - For clipboard functionality
- `http` package - For translation API calls
- `provider` package - For state management (in parent components)

## Notes

- The translation service includes rate limiting (300ms delay between requests)
- Copy functionality works immediately without network requests
- Add to Deck and Search are currently placeholder implementations
- The context menu is responsive and works on all screen sizes
