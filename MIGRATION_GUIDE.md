# Migration Guide: Swift to JSON

This guide shows how to migrate from `DutchVocabularyPacks.swift` to the JSON-based vocabulary system.

## 📋 Migration Steps

### Step 1: Add JSON File to Your Project

1. Copy `dutch_vocabulary_complete.json` to your Xcode project
2. Make sure it's added to your target's bundle
3. Verify it appears in your app bundle

### Step 2: Add New Swift File

1. Add `DutchVocabularyJSON.swift` to your project
2. This replaces the functionality of `DutchVocabularyPacks.swift`

### Step 3: Update Your Code

## 🔄 Code Migration Examples

### Before (Using DutchVocabularyPacks.swift):
```swift
// OLD WAY - Direct access to hardcoded packs
let familyPack = DutchVocabularyDatabase.shared.familyA1
let foodPack = DutchVocabularyDatabase.shared.foodA1
let allA1Packs = [
    DutchVocabularyDatabase.shared.familyA1,
    DutchVocabularyDatabase.shared.foodA1,
    // ... more hardcoded references
]
```

### After (Using JSON):
```swift
// NEW WAY - Dynamic loading from JSON
let familyPack = VocabularyLoader.shared.getPack(by: "familie")
let foodPack = VocabularyLoader.shared.getPack(by: "eten_en_drinken")
let allA1Packs = VocabularyLoader.shared.getPacks(for: "A1")
```

## 🎯 Common Migration Patterns

### 1. Loading Specific Packs
```swift
// Before
let verbsPack = DutchVocabularyDatabase.shared.verbsA1

// After
let verbsPack = VocabularyLoader.shared.getPack(by: "werkwoorden")
```

### 2. Getting All Packs by Level
```swift
// Before (manual list)
let a1Packs = [
    DutchVocabularyDatabase.shared.familyA1,
    DutchVocabularyDatabase.shared.foodA1,
    // ... 15 more manual entries
]

// After (automatic)
let a1Packs = VocabularyLoader.shared.getPacks(for: "A1")
```

### 3. Getting Words by Category
```swift
// Before (manual filtering)
let familyWords = DutchVocabularyDatabase.shared.familyA1.words

// After (dynamic filtering)
let familyPacks = VocabularyLoader.shared.getPacks(for: "family")
let familyWords = familyPacks.flatMap { $0.words }
```

### 4. Search Functionality (NEW!)
```swift
// This wasn't easily possible before
let searchResults = VocabularyLoader.shared.searchWords(query: "eten")
```

### 5. Random Words for Practice (NEW!)
```swift
// This also wasn't easily possible before
let practiceWords = VocabularyLoader.shared.getRandomWords(count: 10)
```

## 🔧 Updating Your View Controllers

### FlashCard Selection Screen
```swift
class VocabularySelectionViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Before
        // let packs = DutchVocabularyDatabase.shared.getAllPacks() // This didn't exist
        
        // After
        let packs = VocabularyLoader.shared.getAllPacks()
        setupTableView(with: packs)
    }
    
    func filterByLevel(_ level: String) {
        // Before: Manual filtering of hardcoded list
        
        // After: Simple and dynamic
        let filteredPacks = VocabularyLoader.shared.getPacks(for: level)
        updateTableView(with: filteredPacks)
    }
}
```

### FlashCard Practice Screen
```swift
class FlashCardViewController: UIViewController {
    func loadRandomPracticeSet() {
        // NEW FEATURE - Easy random word selection
        let randomWords = VocabularyLoader.shared.getRandomWords(count: 20)
        startPracticeSession(with: randomWords.map { $0.toFlashCard() })
    }
    
    func searchForWords(_ query: String) {
        // NEW FEATURE - Search across all vocabulary
        let results = VocabularyLoader.shared.searchWords(query: query)
        displaySearchResults(results)
    }
}
```

## ✅ Benefits After Migration

### 1. Easier to Add New Vocabulary
```swift
// Before: Add to Swift file, recompile, redeploy
// After: Update JSON file, no recompilation needed
```

### 2. Better Organization
```swift
// Before: Find specific pack among 39+ lazy vars
let pack = DutchVocabularyDatabase.shared.someSpecificPackA2

// After: Intuitive access by ID or filters
let pack = VocabularyLoader.shared.getPack(by: "some_specific_pack")
let a2Packs = VocabularyLoader.shared.getPacks(for: "A2")
```

### 3. New Features Available
```swift
// Search functionality
let results = VocabularyLoader.shared.searchWords(query: "family")

// Random practice sets
let practice = VocabularyLoader.shared.getRandomWords(count: 15)

// Dynamic filtering
let businessVocab = VocabularyLoader.shared.getPacks(for: "business")
```

## 🚨 What to Remove

Once migration is complete, you can safely remove:

1. ✅ `DutchVocabularyPacks.swift` - Replace with `DutchVocabularyJSON.swift`
2. ✅ All hardcoded pack references
3. ✅ Manual filtering logic

## 🔄 Gradual Migration Approach

If you want to migrate gradually:

1. **Phase 1**: Add JSON loading alongside existing Swift
2. **Phase 2**: Update one screen at a time to use JSON
3. **Phase 3**: Remove Swift file once everything is migrated

```swift
// During transition - keep both working
class VocabularyDataSource {
    func getPacks(useJSON: Bool = true) -> [VocabularyPack] {
        if useJSON {
            return VocabularyLoader.shared.getAllPacks().map { $0.toDutchVocabularyPack() }
        } else {
            return DutchVocabularyDatabase.shared.getAllPacks() // Your existing method
        }
    }
}
```

## 🎉 Final Result

After migration, your vocabulary system will be:
- ✅ **More maintainable** - Update JSON vs Swift code
- ✅ **More flexible** - Easy filtering and searching
- ✅ **More scalable** - Add vocabulary without recompiling
- ✅ **Platform ready** - Same data works on web, Android, etc.
- ✅ **Feature rich** - Search, random selection, dynamic filtering

The JSON approach gives you all the functionality of the original Swift file, plus much more flexibility and maintainability! 