import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/flash_card.dart';
import '../models/dutch_word_exercise.dart';

class UnifiedImportService {
  // Actual CSV format: Deck,Word,Definition,Exercise Type,Question,Correct Answer,Options,Explanation
  static const List<String> csvHeaders = [
    'Deck',
    'Word', 
    'Definition',
    'Exercise Type',
    'Question',
    'Options',
    'Explanation',
    'ID', // Optional ID column
  ];

  static Future<Map<String, dynamic>> parseUnifiedCSV(String csvContent) async {
    final lines = csvContent.trim().split('\n');
    if (lines.isEmpty) return {'cards': [], 'exercises': []};

    final headers = lines[0].split(',').map((h) => h.trim()).toList();
    final data = lines.skip(1).where((line) => line.trim().isNotEmpty).toList();

    final cards = <FlashCard>[];
    final wordExercises = <DutchWordExercise>[];
    final wordMap = <String, Map<String, dynamic>>{};
    
    // Counter for unique ID generation
    int idCounter = 0;

    for (int i = 0; i < data.length; i++) {
      final line = data[i].trim();
      if (line.isEmpty) continue;

      try {
        final values = _parseCSVLine(line);
        if (values.length < headers.length) {
          continue;
        }

        final deckName = values[headers.indexOf('Deck')].trim();
        final word = values[headers.indexOf('Word')].trim();
        final definition = values[headers.indexOf('Definition')].trim();
        final exerciseType = values[headers.indexOf('Exercise Type')].trim();
        final question = values[headers.indexOf('Question')].trim();
        final options = values[headers.indexOf('Options')].trim();
        final explanation = values[headers.indexOf('Explanation')].trim();
        
        // Handle optional ID column
        String? customId;
        if (headers.contains('ID') && values.length > headers.indexOf('ID')) {
          customId = values[headers.indexOf('ID')].trim();
          if (customId.isEmpty) customId = null;
        }
        
        print('🔍 CSV parsing: Word="$word", DeckName="$deckName", CustomID="$customId"');

        // Create or update word entry
        if (!wordMap.containsKey(word)) {
          wordMap[word] = {
            'word': word,
            'definition': definition,
            'example': '', // Optional field - empty for this CSV
            'article': '', // Optional field - empty for this CSV
            'plural': '', // Optional field - empty for this CSV
            'pastTense': '', // Optional field - empty for this CSV
            'futureTense': '', // Optional field - empty for this CSV
            'pastParticiple': '', // Optional field - empty for this CSV
            'deckNames': deckName,
            'customId': customId, // Store custom ID if provided
            'exercises': <Map<String, dynamic>>[],
          };
          print('🔍 Created new word entry for "$word" with deck "$deckName" and custom ID "$customId"');
        } else {
          // Update existing word entry
          wordMap[word]!['deckNames'] = deckName;
          if (customId != null) {
            wordMap[word]!['customId'] = customId;
          }
          print('🔍 Updated existing word entry for "$word" with deck "$deckName" and custom ID "$customId"');
        }

        // Only add exercise if it has valid data
        if (exerciseType.isNotEmpty && 
            exerciseType.toLowerCase() != 'basic' &&
            question.isNotEmpty && 
            options.isNotEmpty) {
          
          // Parse options - first option is always correct
          final parsedOptions = _parseOptions(options, exerciseType);
          final correctAnswer = parsedOptions.first; // Correct answer is always option 1
          
          wordMap[word]!['exercises'].add({
            'type': _convertExerciseTypeToEnum(exerciseType),
            'prompt': question,
            'options': parsedOptions,
            'correctAnswer': correctAnswer,
            'explanation': explanation,
          });
        }
      } catch (e) {
        print('Error parsing line ${i + 1}: ${e.toString()}');
        continue;
      }
    }

    // Convert to FlashCard and DutchWordExercise objects
    print('Processing ${wordMap.length} unique words...');
    for (final wordData in wordMap.values) {
      print('Creating card for word: ${wordData['word']}');
              // Create FlashCard
        final deckIds = _parseDeckNames(wordData['deckNames']);
        print('🔍 Creating card for "${wordData['word']}" with deckIds: $deckIds');
        
        final card = FlashCard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          word: wordData['word'],
          definition: wordData['definition'],
          example: wordData['example'] ?? '', // Optional field
          article: wordData['article'] ?? '', // Optional field
          plural: wordData['plural'] ?? '', // Optional field
          pastTense: wordData['pastTense'] ?? '', // Optional field
          futureTense: wordData['futureTense'] ?? '', // Optional field
          pastParticiple: wordData['pastParticiple'] ?? '', // Optional field
          deckIds: deckIds,
          dateCreated: DateTime.now(),
        );
      cards.add(card);

      // Create DutchWordExercise if exercises exist
      if (wordData['exercises'].isNotEmpty) {
        print('Creating ${wordData['exercises'].length} exercises for word: ${wordData['word']}');
        final individualExercises = <WordExercise>[];
        for (final ex in wordData['exercises']) {
          print('Creating exercise: ${ex['type']} - ${ex['prompt']}');
          individualExercises.add(WordExercise(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: ex['type'], // Already an enum
            prompt: ex['prompt'],
            options: List<String>.from(ex['options']),
            correctAnswer: ex['correctAnswer'],
            explanation: ex['explanation'],
            difficulty: ExerciseDifficulty.beginner,
          ));
        }
        
        // Create DutchWordExercise
        final deckId = _getPrimaryDeckId(wordData['deckNames']);
        final deckName = _getPrimaryDeckName(wordData['deckNames']);
        final customId = wordData['customId'] as String?;
        
        // Use custom ID if provided, otherwise generate timestamp-based ID
        final exerciseId = customId ?? '${DateTime.now().millisecondsSinceEpoch}_${idCounter++}';
        
        print('🔍 Creating DutchWordExercise for "${wordData['word']}" with deckId: "$deckId", deckName: "$deckName", ID: "$exerciseId"');
        
        final dutchWordExercise = DutchWordExercise(
          id: exerciseId,
          targetWord: wordData['word'],
          wordTranslation: wordData['definition'],
          deckId: deckId,
          deckName: deckName,
          category: WordCategory.common,
          difficulty: ExerciseDifficulty.beginner,
          exercises: individualExercises,
          createdAt: DateTime.now(),
          isUserCreated: false,
          learningProgress: LearningProgress(),
        );
        wordExercises.add(dutchWordExercise);
      }
    }

    print('Import completed: ${cards.length} cards, ${wordExercises.length} exercises');
    return {
      'cards': cards,
      'exercises': wordExercises,
    };
  }

  static String exportUnifiedCSV(List<FlashCard> cards, List<DutchWordExercise> exercises) {
    final lines = <String>[];
    
    // Add header
    lines.add(csvHeaders.join(','));
    
    // Group exercises by word for easier lookup
    final exerciseMap = <String, DutchWordExercise>{};
    for (final exercise in exercises) {
      exerciseMap[exercise.targetWord] = exercise;
    }
    
    // Export each card
    for (final card in cards) {
      final exercise = exerciseMap[card.word];
      
      if (exercise != null && exercise.exercises.isNotEmpty) {
        // Add word data
        lines.add([
          _escapeCSVField(_getDeckNames(card.deckIds)),
          _escapeCSVField(card.word),
          _escapeCSVField(card.definition),
          '', // No exercise type
          '', // No question
          '', // No options
          '', // No explanation
        ].join(','));
        
        // Add exercises
        for (final ex in exercise.exercises) {
          lines.add([
            _escapeCSVField(_getDeckNames(card.deckIds)),
            _escapeCSVField(card.word),
            _escapeCSVField(card.definition),
            _escapeCSVField(_convertExerciseTypeToCSV(ex.type)),
            _escapeCSVField(ex.prompt),
            _escapeCSVField(ex.options.join(';')),
            _escapeCSVField(ex.explanation),
          ].join(','));
        }
      } else {
        // Export as basic flashcard (no exercises)
        final row = [
          _escapeCSVField(_getDeckNames(card.deckIds)),
          _escapeCSVField(card.word),
          _escapeCSVField(card.definition),
          '', // No exercise type
          '', // No question
          '', // No options
          '', // No explanation
        ];
        lines.add(row.join(','));
      }
    }

    return lines.join('\n');
  }

  // Helper methods
  static List<String> _parseCSVLine(String line) {
    final List<String> result = [];
    bool inQuotes = false;
    String current = '';
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        inQuotes = !inQuotes;
      } else if (char == ',' && !inQuotes) {
        result.add(current.trim());
        current = '';
      } else {
        current += char;
      }
    }
    
    result.add(current.trim());
    return result;
  }

  static List<String> _parseOptions(String options, String exerciseType) {
    if (options.isEmpty) return [];
    
    // Split by semicolon and trim each option
    final optionList = options.split(';').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    
    // For sentence building, we might have more options than needed
    if (exerciseType.toLowerCase() == 'sentence building') {
      return optionList;
    }
    
    return optionList;
  }

  static ExerciseType _convertExerciseTypeToEnum(String csvType) {
    switch (csvType.toLowerCase()) {
      case 'sentence building':
        return ExerciseType.sentenceBuilding;
      case 'multiple choice':
        return ExerciseType.multipleChoice;
      case 'fill in the blank':
      case 'fill in blank':
        return ExerciseType.fillInBlank;
      default:
        return ExerciseType.multipleChoice; // Default fallback
    }
  }

  static String _convertExerciseTypeToCSV(ExerciseType type) {
    switch (type) {
      case ExerciseType.sentenceBuilding:
        return 'Sentence Building';
      case ExerciseType.multipleChoice:
        return 'Multiple Choice';
      case ExerciseType.fillInBlank:
        return 'Fill in Blank';
      default:
        return 'Multiple Choice';
    }
  }

  static Set<String> _parseDeckNames(String deckNames) {
    if (deckNames.isEmpty) return {'uncategorized'};
    return deckNames.split(';').map((name) => name.trim()).toSet();
  }

  static String _getPrimaryDeckId(String deckNames) {
    if (deckNames.isEmpty) return 'uncategorized';
    final names = deckNames.split(';');
    return names.first.trim();
  }

  static String _getPrimaryDeckName(String deckNames) {
    if (deckNames.isEmpty) return 'Uncategorized';
    final names = deckNames.split(';');
    return names.first.trim();
  }

  static String _getDeckNames(Set<String> deckIds) {
    // This would need to be implemented with actual deck name lookup
    // For now, return the first deck ID
    return deckIds.isNotEmpty ? deckIds.first : 'Uncategorized';
  }

  static String _escapeCSVField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
} 