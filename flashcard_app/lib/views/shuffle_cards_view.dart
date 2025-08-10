import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/flashcard_provider.dart';
import '../providers/dutch_word_exercise_provider.dart';
import '../models/flash_card.dart';
import '../models/dutch_word_exercise.dart';
import 'multiple_choice_view.dart';
import 'true_false_view.dart';
import 'memory_game_view.dart';
import 'word_scramble_view.dart';
import 'dutch_word_exercise_detail_view.dart';

enum ShuffleMode {
  multipleChoice,
  trueFalse,
  memoryGame,
  wordScramble,
  dutchExercise,
}

class ShuffleCardsView extends StatefulWidget {
  const ShuffleCardsView({super.key});

  @override
  State<ShuffleCardsView> createState() => _ShuffleCardsViewState();
}

class _ShuffleCardsViewState extends State<ShuffleCardsView> {
  int _currentScore = 0;
  int _highScore = 0;
  bool _isGameActive = false;
  ShuffleMode? _currentMode;
  FlashCard? _currentCard;
  DutchWordExercise? _currentExercise;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  void _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('shuffle_high_score') ?? 0;
    });
  }

  void _saveHighScore() async {
    if (_currentScore > _highScore) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('shuffle_high_score', _currentScore);
      setState(() {
        _highScore = _currentScore;
      });
    }
  }

  void _startGame() {
    setState(() {
      _currentScore = 0;
      _isGameActive = true;
    });
    _nextChallenge();
  }

  void _nextChallenge() {
    if (!_isGameActive) return;

    final provider = context.read<FlashcardProvider>();
    final dutchProvider = context.read<DutchWordExerciseProvider>();
    
    // Get all available cards and exercises
    final allCards = provider.cards;
    final allExercises = dutchProvider.wordExercises;
    
    // Debug logging
    print('🔍 ShuffleCardsView: Available cards: ${allCards.length}');
    print('🔍 ShuffleCardsView: Available exercises: ${allExercises.length}');
    
    if (allCards.isEmpty && allExercises.isEmpty) {
      _showGameOver('No cards or exercises available!');
      return;
    }

    // Randomly select a mode
    final availableModes = <ShuffleMode>[];
    
    if (allCards.isNotEmpty) {
      availableModes.addAll([
        ShuffleMode.multipleChoice,
        ShuffleMode.trueFalse,
        ShuffleMode.memoryGame,
        ShuffleMode.wordScramble,
      ]);
    }
    
    if (allExercises.isNotEmpty) {
      availableModes.add(ShuffleMode.dutchExercise);
    }

    if (availableModes.isEmpty) {
      _showGameOver('No content available!');
      return;
    }

    final selectedMode = availableModes[_random.nextInt(availableModes.length)];
    
    // Debug logging
    print('🔍 ShuffleCardsView: Selected mode: $selectedMode');
    print('🔍 ShuffleCardsView: Available modes: $availableModes');
    
    setState(() {
      _currentMode = selectedMode;
    });

    switch (selectedMode) {
      case ShuffleMode.multipleChoice:
      case ShuffleMode.trueFalse:
      case ShuffleMode.memoryGame:
      case ShuffleMode.wordScramble:
        _currentCard = allCards[_random.nextInt(allCards.length)];
        _launchCardMode(selectedMode);
        break;
      case ShuffleMode.dutchExercise:
        _currentExercise = allExercises[_random.nextInt(allExercises.length)];
        _launchDutchExercise();
        break;
    }
  }

  void _launchCardMode(ShuffleMode mode) {
    if (_currentCard == null) return;

    Widget targetView;
    switch (mode) {
      case ShuffleMode.multipleChoice:
        targetView = MultipleChoiceView(
          cards: [_currentCard!],
          title: 'Multiple Choice',
          onComplete: _handleCardModeComplete,
          shuffleMode: true,
        );
        break;
      case ShuffleMode.trueFalse:
        targetView = TrueFalseView(
          cards: [_currentCard!],
          title: 'True or False',
          onComplete: _handleCardModeComplete,
          shuffleMode: true,
        );
        break;
      case ShuffleMode.memoryGame:
        // For memory game, we need multiple cards to create pairs
        // Get 5 random cards for the memory game
        final allCards = context.read<FlashcardProvider>().cards;
        final memoryCards = <FlashCard>[];
        
        // Add the current card first
        memoryCards.add(_currentCard!);
        
        // Add 4 more random cards (avoiding duplicates)
        final otherCards = allCards.where((card) => card.id != _currentCard!.id).toList();
        final random = Random();
        
        for (int i = 0; i < 4 && i < otherCards.length; i++) {
          final randomCard = otherCards[random.nextInt(otherCards.length)];
          if (!memoryCards.any((card) => card.id == randomCard.id)) {
            memoryCards.add(randomCard);
          }
        }
        
        targetView = MemoryGameView(
          cards: memoryCards,
          onComplete: _handleCardModeComplete,
          shuffleMode: true,
        );
        break;
      case ShuffleMode.wordScramble:
        targetView = WordScrambleView(
          cards: [_currentCard!],
          title: 'Word Scramble',
          onComplete: _handleCardModeComplete,
          shuffleMode: true,
        );
        break;
      default:
        return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => targetView,
      ),
    );
  }

  void _launchDutchExercise() {
    if (_currentExercise == null) return;

    // For shuffle mode, we'll create a single-question version
    // by modifying the exercise to only have one question
    final singleQuestionExercise = DutchWordExercise(
      id: _currentExercise!.id,
      targetWord: _currentExercise!.targetWord,
      wordTranslation: _currentExercise!.wordTranslation,
      deckId: _currentExercise!.deckId,
      deckName: _currentExercise!.deckName,
      category: _currentExercise!.category,
      difficulty: _currentExercise!.difficulty,
      exercises: [_currentExercise!.exercises.first], // Only use the first exercise
      createdAt: _currentExercise!.createdAt,
      isUserCreated: _currentExercise!.isUserCreated,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DutchWordExerciseDetailView(
          wordExercise: singleQuestionExercise,
          showEditDeleteButtons: false,
          onComplete: _handleDutchExerciseComplete,
          singleQuestionMode: true,
        ),
      ),
    );
  }

  void _handleCardModeComplete(bool wasCorrect) {
    Navigator.pop(context);
    _handleChallengeComplete(wasCorrect);
  }

  void _handleDutchExerciseComplete(bool wasCorrect) {
    Navigator.pop(context);
    _handleChallengeComplete(wasCorrect);
  }

  // For Dutch exercises, we need to track individual question results
  void _handleDutchExerciseQuestionComplete(bool wasCorrect) {
    if (!wasCorrect) {
      Navigator.pop(context);
      _showGameOver('Game Over! You got one wrong.');
      return;
    }

    setState(() {
      _currentScore++;
    });

    // Show success message briefly
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Correct! Score: $_currentScore'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Wait a moment then continue to next challenge
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_isGameActive) {
        _nextChallenge();
      }
    });
  }

  void _handleChallengeComplete(bool wasCorrect) {
    if (!wasCorrect) {
      _showGameOver('Game Over! You got one wrong.');
      return;
    }

    setState(() {
      _currentScore++;
    });

    // Show success message briefly before next challenge
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Correct! Score: $_currentScore'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );

    // Wait a moment then continue
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_isGameActive) {
        _nextChallenge();
      }
    });
  }

  void _showGameOver(String message) {
    _saveHighScore();
    setState(() {
      _isGameActive = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Text('Final Score: $_currentScore'),
            if (_currentScore > 0) ...[
              const SizedBox(height: 8),
              Text(
                _currentScore > _highScore ? 'New High Score! 🎉' : 'High Score: $_highScore',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _currentScore > _highScore ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset game state when user goes back
        if (_isGameActive) {
          setState(() {
            _isGameActive = false;
            _currentScore = 0;
            _currentMode = null;
            _currentCard = null;
            _currentExercise = null;
          });
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shuffle Your Cards'),
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Reset game state when user goes back
              if (_isGameActive) {
                setState(() {
                  _isGameActive = false;
                  _currentScore = 0;
                  _currentMode = null;
                  _currentCard = null;
                  _currentExercise = null;
                });
              }
              Navigator.of(context).pop();
            },
          ),
        ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Game Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.shuffle,
                    size: 60,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                const Text(
                  'Shuffle Your Cards',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  'Test your knowledge with a mix of all exercise types!\n'
                  'Get as far as you can without making a mistake.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                
                // High Score
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'High Score: $_highScore',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Start Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isGameActive ? null : _startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _isGameActive ? 'Game in Progress...' : 'Start Shuffle',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Current Score (if game is active)
                if (_isGameActive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Current Score: $_currentScore',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                
                // Exercise Types Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exercise Types:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120, // Fixed height to prevent overflow
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildExerciseTypeItem('Multiple Choice', Icons.check_circle, Colors.teal),
                              _buildExerciseTypeItem('True or False', Icons.help_outline, Colors.orange),
                              _buildExerciseTypeItem('Memory Game', Icons.psychology, Colors.purple),
                              _buildExerciseTypeItem('Word Scramble', Icons.text_fields, Colors.blue),
                              _buildExerciseTypeItem('Dutch Exercises', Icons.school, Colors.green),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildExerciseTypeItem(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
