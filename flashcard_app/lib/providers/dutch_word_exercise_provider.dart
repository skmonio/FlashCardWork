import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dutch_word_exercise.dart';

class DutchWordExerciseProvider extends ChangeNotifier {
  static const String _storageKey = 'dutch_word_exercises';
  
  List<DutchWordExercise> _wordExercises = [];
  bool _isLoading = false;
  String? _error;

  List<DutchWordExercise> get wordExercises => _wordExercises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize with example data
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadFromStorage();
      
      // Add example data if no exercises exist
      if (_wordExercises.isEmpty) {
        _wordExercises.addAll(DutchWordExerciseExamples.examples);
        await _saveToStorage();
      }
    } catch (e) {
      _error = 'Failed to initialize: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load exercises from storage
  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _wordExercises = jsonList
            .map((json) => DutchWordExercise.fromJson(json))
            .toList();
      }
    } catch (e) {
      _error = 'Failed to load exercises: $e';
    }
  }

  // Save exercises to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(_wordExercises.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      _error = 'Failed to save exercises: $e';
    }
  }

  // Add a new word exercise
  Future<void> addWordExercise(DutchWordExercise exercise) async {
    _wordExercises.add(exercise);
    await _saveToStorage();
    notifyListeners();
  }

  // Update an existing word exercise
  Future<void> updateWordExercise(DutchWordExercise exercise) async {
    final index = _wordExercises.indexWhere((e) => e.id == exercise.id);
    if (index != -1) {
      _wordExercises[index] = exercise;
      await _saveToStorage();
      notifyListeners();
    }
  }

  // Delete a word exercise
  Future<void> deleteWordExercise(String id) async {
    _wordExercises.removeWhere((e) => e.id == id);
    await _saveToStorage();
    notifyListeners();
  }

  // Get a word exercise by ID
  DutchWordExercise? getWordExercise(String id) {
    try {
      return _wordExercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get all decks
  List<String> getDecks() {
    final deckIds = _wordExercises.map((e) => e.deckId).toSet().toList();
    deckIds.sort();
    return deckIds;
  }

  // Get deck names
  Map<String, String> getDeckNames() {
    final Map<String, String> deckNames = {};
    for (final exercise in _wordExercises) {
      deckNames[exercise.deckId] = exercise.deckName;
    }
    return deckNames;
  }

  // Get exercises by deck
  List<DutchWordExercise> getExercisesByDeck(String deckId) {
    print('🔍 Provider: getExercisesByDeck called with deckId: "$deckId"');
    print('🔍 Provider: Total exercises available: ${_wordExercises.length}');
    for (final exercise in _wordExercises) {
      print('🔍 Provider: Exercise "${exercise.targetWord}" has deckId: "${exercise.deckId}"');
    }
    
    final filteredExercises = _wordExercises.where((e) => e.deckId == deckId).toList();
    print('🔍 Provider: Found ${filteredExercises.length} exercises for deckId: "$deckId"');
    return filteredExercises;
  }

  // Search word exercises
  List<DutchWordExercise> searchWordExercises(String query) {
    if (query.isEmpty) return _wordExercises;
    
    final lowercaseQuery = query.toLowerCase();
    return _wordExercises.where((exercise) {
      return exercise.targetWord.toLowerCase().contains(lowercaseQuery) ||
             exercise.wordTranslation.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Filter word exercises by category
  List<DutchWordExercise> filterByCategory(WordCategory category) {
    return _wordExercises.where((e) => e.category == category).toList();
  }

  // Filter word exercises by difficulty
  List<DutchWordExercise> filterByDifficulty(ExerciseDifficulty difficulty) {
    return _wordExercises.where((e) => e.difficulty == difficulty).toList();
  }

  // Get statistics
  WordExerciseStatistics getStatistics() {
    final userCreated = _wordExercises.where((e) => e.isUserCreated).length;
    final imported = _wordExercises.where((e) => !e.isUserCreated).length;
    
    final categoryBreakdown = <String, int>{};
    final difficultyBreakdown = <String, int>{};
    
    for (final exercise in _wordExercises) {
      final categoryName = exercise.category.toString().split('.').last;
      categoryBreakdown[categoryName] = (categoryBreakdown[categoryName] ?? 0) + 1;
      
      final difficultyName = exercise.difficulty.toString().split('.').last;
      difficultyBreakdown[difficultyName] = (difficultyBreakdown[difficultyName] ?? 0) + 1;
    }
    
    final totalQuestions = _wordExercises.fold<int>(
      0, (sum, exercise) => sum + exercise.exercises.length);
    
    return WordExerciseStatistics(
      totalWordExercises: _wordExercises.length,
      totalQuestions: totalQuestions,
      userCreated: userCreated,
      imported: imported,
      categoryBreakdown: categoryBreakdown,
      difficultyBreakdown: difficultyBreakdown,
      lastActivity: DateTime.now(),
    );
  }

  // Import exercises from JSON
  Future<void> importFromJson(String jsonString) async {
    try {
      final json = jsonDecode(jsonString);
      final import = DutchWordExerciseImport.fromJson(json);
      
      for (final exercise in import.exercises) {
        // Check if exercise already exists
        final existingIndex = _wordExercises.indexWhere((e) => e.id == exercise.id);
        if (existingIndex != -1) {
          // Update existing exercise
          _wordExercises[existingIndex] = exercise;
        } else {
          // Add new exercise
          _wordExercises.add(exercise);
        }
      }
      
      await _saveToStorage();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to import exercises: $e';
      notifyListeners();
    }
  }

  // Export exercises to JSON
  Future<String> exportToJson() async {
    try {
      final import = DutchWordExerciseImport(
        metadata: ImportMetadata(
          version: '1.0',
          exportDate: DateTime.now(),
          description: 'Dutch Word Exercises Export',
          author: 'FlashCard App',
        ),
        exercises: _wordExercises,
      );
      
      return jsonEncode(import.toJson());
    } catch (e) {
      _error = 'Failed to export exercises: $e';
      notifyListeners();
      return '';
    }
  }

  // Clear all exercises
  Future<void> clearAllExercises() async {
    _wordExercises.clear();
    await _saveToStorage();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update learning progress for a word exercise
  Future<void> updateLearningProgress(String exerciseId, bool wasCorrect) async {
    print('🔍 Provider: updateLearningProgress called for ID: $exerciseId, wasCorrect: $wasCorrect');
    final index = _wordExercises.indexWhere((e) => e.id == exerciseId);
    print('🔍 Provider: Found exercise at index: $index');
    if (index != -1) {
      final oldProgress = _wordExercises[index].learningProgress;
      print('🔍 Provider: Old progress - correct: ${oldProgress.correctAnswers}, total: ${oldProgress.totalAttempts}, percentage: ${oldProgress.learningPercentage}');
      
      final updatedExercise = _wordExercises[index].updateProgress(wasCorrect: wasCorrect);
      _wordExercises[index] = updatedExercise;
      
      final newProgress = updatedExercise.learningProgress;
      print('🔍 Provider: New progress - correct: ${newProgress.correctAnswers}, total: ${newProgress.totalAttempts}, percentage: ${newProgress.learningPercentage}');
      
      await _saveToStorage();
      notifyListeners();
      print('🔍 Provider: Progress updated and saved successfully');
    } else {
      print('🔍 Provider: ERROR - Exercise not found with ID: $exerciseId');
    }
  }

  // Get words that need review (spaced repetition)
  List<DutchWordExercise> getWordsForReview() {
    final now = DateTime.now();
    return _wordExercises.where((exercise) {
      return exercise.learningProgress.nextReviewDate.isBefore(now);
    }).toList();
  }

  // Get learning statistics for a deck
  Map<String, dynamic> getDeckLearningStats(String deckId) {
    final deckExercises = getExercisesByDeck(deckId);
    if (deckExercises.isEmpty) {
      return {
        'totalWords': 0,
        'averageProgress': 0.0,
        'masteredWords': 0,
        'needsReview': 0,
      };
    }

    int masteredWords = 0;
    int needsReview = 0;
    double totalProgress = 0.0;
    final now = DateTime.now();

    for (final exercise in deckExercises) {
      totalProgress += exercise.learningProgress.learningPercentage;
      
      if (exercise.learningProgress.masteryLevel >= 4) {
        masteredWords++;
      }
      
      if (exercise.learningProgress.nextReviewDate.isBefore(now)) {
        needsReview++;
      }
    }

    return {
      'totalWords': deckExercises.length,
      'averageProgress': totalProgress / deckExercises.length,
      'masteredWords': masteredWords,
      'needsReview': needsReview,
    };
  }
} 