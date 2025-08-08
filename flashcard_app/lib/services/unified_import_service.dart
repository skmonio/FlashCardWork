import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import '../models/flash_card.dart';
import '../models/dutch_word_exercise.dart';

class UnifiedImportService {
  // Actual CSV format: Deck,Word,Definition,Exercise Type,Question,Correct Answer,Options,Explanation
  static const List<String> csvHeaders = [
    'Deck', 'Word', 'Definition', 'Exercise Type', 'Question', 
    'Correct Answer', 'Options', 'Explanation'
  ];

  static Future<Map<String, dynamic>> parseUnifiedCSV(String csvContent) async {
    final lines = csvContent.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    if (lines.length < 2) {
      return {
        'success': false,
        'errors': ['CSV file appears to be empty or invalid']
      };
    }

    // Parse header
    final headers = lines[0].split(',').map((h) => h.trim().replaceAll('"', '')).toList();
    
    // Validate headers
    for (final requiredHeader in csvHeaders) {
      if (!headers.contains(requiredHeader)) {
        return {
          'success': false,
          'errors': ['Missing required header: $requiredHeader']
        };
      }
    }

    final cards = <FlashCard>[];
    final exercises = <DutchWordExercise>[];
    final errors = <String>[];

    // Group by word to handle multiple exercises per word
    final wordMap = <String, Map<String, dynamic>>{};

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final values = _parseCSVLine(line);
        if (values.length < headers.length) {
          errors.add('Line ${i + 1}: Insufficient data');
          continue;
        }

        final deckName = values[headers.indexOf('Deck')].trim();
        final word = values[headers.indexOf('Word')].trim();
        final definition = values[headers.indexOf('Definition')].trim();
        final exerciseType = values[headers.indexOf('Exercise Type')].trim();
        final question = values[headers.indexOf('Question')].trim();
        final correctAnswer = values[headers.indexOf('Correct Answer')].trim();
        final options = values[headers.indexOf('Options')].trim();
        final explanation = values[headers.indexOf('Explanation')].trim();
        
        print('🔍 CSV parsing: Word="$word", DeckName="$deckName"');

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
            'exercises': <Map<String, dynamic>>[],
          };
        }

        // Add exercise if provided and valid
        if (exerciseType.isNotEmpty && 
            exerciseType.toLowerCase() != 'basic' &&
            question.isNotEmpty && 
            correctAnswer.isNotEmpty) {
          wordMap[word]!['exercises'].add({
            'type': _convertExerciseType(exerciseType),
            'prompt': question,
            'options': _parseOptions(options, exerciseType),
            'correctAnswer': correctAnswer,
            'explanation': explanation,
          });
        }
      } catch (e) {
        errors.add('Line ${i + 1}: ${e.toString()}');
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
        final wordExercises = <WordExercise>[];
        for (final ex in wordData['exercises']) {
          print('Creating exercise: ${ex['type']} - ${ex['prompt']}');
          wordExercises.add(WordExercise(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            type: _convertExerciseTypeToEnum(ex['type']),
            prompt: ex['prompt'],
            options: List<String>.from(ex['options']),
            correctAnswer: ex['correctAnswer'],
            explanation: ex['explanation'],
            difficulty: ExerciseDifficulty.beginner,
          ));
        }
        
        final exercise = DutchWordExercise(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          targetWord: wordData['word'],
          wordTranslation: wordData['definition'],
          exercises: wordExercises,
          deckId: _getPrimaryDeckId(wordData['deckNames']),
          deckName: _getPrimaryDeckName(wordData['deckNames']),
          category: WordCategory.common,
          difficulty: ExerciseDifficulty.beginner,
          createdAt: DateTime.now(),
          isUserCreated: true,
        );
        exercises.add(exercise);
      }
    }

    print('Import completed: ${cards.length} cards, ${exercises.length} exercises, ${errors.length} errors');
    return {
      'success': true,
      'cards': cards,
      'exercises': exercises,
      'errors': errors,
    };
  }

  static String exportUnifiedCSV(List<FlashCard> cards, List<DutchWordExercise> exercises) {
    final lines = <String>[csvHeaders.join(',')];

    // Create a map of exercises by word for easy lookup
    final exerciseMap = <String, DutchWordExercise>{};
    for (final exercise in exercises) {
      exerciseMap[exercise.targetWord.toLowerCase()] = exercise;
    }

    for (final card in cards) {
      final exercise = exerciseMap[card.word.toLowerCase()];
      
      if (exercise != null && exercise.exercises.isNotEmpty) {
        // Export each exercise as a separate row
        for (final wordExercise in exercise.exercises) {
          final row = [
            _escapeCSVField(_getDeckNames(card.deckIds)),
            _escapeCSVField(card.word),
            _escapeCSVField(card.definition),
            _escapeCSVField(_convertExerciseTypeToCSV(wordExercise.type)),
            _escapeCSVField(wordExercise.prompt),
            _escapeCSVField(wordExercise.correctAnswer),
            _escapeCSVField(wordExercise.options.join(';')),
            _escapeCSVField(wordExercise.explanation),
          ];
          lines.add(row.join(','));
        }
      } else {
        // Export as basic flashcard (no exercises)
        final row = [
          _escapeCSVField(_getDeckNames(card.deckIds)),
          _escapeCSVField(card.word),
          _escapeCSVField(card.definition),
          '', // No exercise type
          '', // No question
          '', // No correct answer
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

  static String _convertExerciseType(String csvType) {
    switch (csvType.toLowerCase()) {
      case 'sentence building':
        return 'sentenceBuilding';
      case 'multiple choice':
        return 'multipleChoice';
      case 'fill in the blank':
      case 'fill in blank':
        return 'fillInBlank';
      default:
        return 'multipleChoice';
    }
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

  static List<String> _parseOptions(String options, String exerciseType) {
    if (options.isEmpty) return [];
    
    if (exerciseType.toLowerCase() == 'sentence building') {
      return options.split(';').map((o) => o.trim()).toList();
    } else {
      return options.split(';').map((o) => o.trim()).toList();
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