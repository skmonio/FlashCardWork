import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flash_card.dart';
import '../components/unified_header.dart';
import '../services/sound_manager.dart';

class WordScrambleView extends StatefulWidget {
  final List<FlashCard> cards;
  final String title;

  const WordScrambleView({
    super.key,
    required this.cards,
    required this.title,
  });

  @override
  State<WordScrambleView> createState() => _WordScrambleViewState();
}

class _WordScrambleViewState extends State<WordScrambleView> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _showingResults = false;
  bool _answered = false;
  String _correctWord = '';
  List<String> _scrambledLetters = [];
  List<String> _userAnswer = [];
  List<String> _originalLetters = [];
  bool _isQuestionMode = true; // true = definition to word, false = word to definition
  
  // Track answered questions and their answers
  Map<int, List<String>> _answeredQuestions = {}; // question index -> user answer
  Map<int, bool> _correctAnswersMap = {}; // question index -> is correct
  Map<int, String> _correctWords = {}; // question index -> correct word
  Map<int, List<String>> _scrambledLettersMap = {}; // question index -> scrambled letters
  Map<int, bool> _questionModes = {}; // question index -> is question mode

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    if (_currentIndex >= widget.cards.length) {
      setState(() {
        _showingResults = true;
      });
      return;
    }

    // Check if this question has already been answered
    if (_answeredQuestions.containsKey(_currentIndex)) {
      // Load existing question data
      _isQuestionMode = _questionModes[_currentIndex]!;
      _correctWord = _correctWords[_currentIndex]!;
      _scrambledLetters = List<String>.from(_scrambledLettersMap[_currentIndex]!);
      _userAnswer = List<String>.from(_answeredQuestions[_currentIndex]!);
      _answered = true;
      return;
    }

    final currentCard = widget.cards[_currentIndex];
    final random = Random();
    
    // Randomly choose question mode
    _isQuestionMode = random.nextBool();
    
    // Get correct word
    _correctWord = _isQuestionMode ? currentCard.word : currentCard.definition;
    
    // Create scrambled pieces (2-3 letters each, excluding spaces)
    final letters = _correctWord.split('').where((char) => char != ' ').toList();
    _scrambledLetters = _createPieces(letters, random);
    
    // Store original letters for comparison
    _originalLetters = letters;
    
    // Store question data for future reference
    _correctWords[_currentIndex] = _correctWord;
    _scrambledLettersMap[_currentIndex] = List<String>.from(_scrambledLetters);
    _questionModes[_currentIndex] = _isQuestionMode;
    
    setState(() {
      _answered = false;
      _userAnswer = [];
    });
  }

  void _addPiece(String piece) {
    if (_answered || piece.isEmpty) return;
    
    setState(() {
      _userAnswer.add(piece);
    });
    
    // Auto-check answer if we have used all non-empty pieces
    final nonEmptyPieces = _scrambledLetters.where((p) => p.isNotEmpty).length;
    final nonEmptyUserAnswer = _userAnswer.where((p) => p.isNotEmpty).length;
    if (nonEmptyUserAnswer == nonEmptyPieces) {
      _checkAnswer();
    }
  }

  void _removeLetterAt(int index) {
    if (_answered || index < 0 || index >= _userAnswer.length) return;
    
    setState(() {
      _userAnswer.removeAt(index);
    });
  }

  void _checkAnswer() {
    if (_answered || _userAnswer.isEmpty) return;
    
    final userWord = _userAnswer.join('');
    final correctWordWithoutSpaces = _correctWord.replaceAll(' ', '').toLowerCase();
    final isCorrect = userWord.toLowerCase() == correctWordWithoutSpaces;
    
    setState(() {
      _answered = true;
      _totalAnswered++;
      
      if (isCorrect) {
        _correctAnswers++;
        _correctAnswersMap[_currentIndex] = true;
        SoundManager().playCorrectSound();
      } else {
        _correctAnswersMap[_currentIndex] = false;
        SoundManager().playWrongSound();
      }
      
      // Store the answer for navigation
      _answeredQuestions[_currentIndex] = List<String>.from(_userAnswer);
    });
  }

  void _goToPreviousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _generateQuestion();
    }
  }

  void _goToNextQuestion() {
    if (_currentIndex < widget.cards.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _generateQuestion();
    }
  }
  
  List<String> _createPieces(List<String> letters, Random random) {
    final pieces = <String>[];
    
    // Ensure we always have at least 2 pieces
    if (letters.length <= 3) {
      // For short words (3 letters or less), split into 2 pieces
      if (letters.length == 3) {
        // "dog" -> ["do", "g"] or ["d", "og"]
        if (random.nextBool()) {
          pieces.add(letters.sublist(0, 2).join('')); // "do"
          pieces.add(letters[2]); // "g"
        } else {
          pieces.add(letters[0]); // "d"
          pieces.add(letters.sublist(1, 3).join('')); // "og"
        }
      } else if (letters.length == 2) {
        // "hi" -> ["h", "i"]
        pieces.add(letters[0]);
        pieces.add(letters[1]);
      } else if (letters.length == 1) {
        // Single letter, create two pieces with one empty (edge case)
        pieces.add(letters[0]);
        pieces.add('');
      }
    } else {
      // For longer words, create pieces of 2-3 letters
      int index = 0;
      while (index < letters.length) {
        // Determine piece size (2-3 letters)
        int pieceSize;
        if (index + 3 <= letters.length) {
          // Can make a piece of 2 or 3 letters
          pieceSize = random.nextBool() ? 2 : 3;
        } else if (index + 2 <= letters.length) {
          // Can make a piece of 2 letters
          pieceSize = 2;
        } else {
          // Only 1 letter left, add it to the last piece
          if (pieces.isNotEmpty) {
            pieces[pieces.length - 1] += letters[index];
          } else {
            // This shouldn't happen with the minimum 2 pieces rule
            pieces.add(letters[index]);
          }
          break;
        }
        
        // Create the piece
        final piece = letters.sublist(index, index + pieceSize).join('');
        pieces.add(piece);
        index += pieceSize;
      }
    }
    
    // Shuffle the pieces
    pieces.shuffle(random);
    return pieces;
  }

  bool _isPieceUsed(String piece, int index) {
    // Empty pieces are always considered "used"
    if (piece.isEmpty) return true;
    
    int usedCount = 0;
    for (int i = 0; i < index; i++) {
      if (_scrambledLetters[i] == piece) {
        usedCount++;
      }
    }
    
    int userCount = _userAnswer.where((p) => p == piece).length;
    return userCount >= usedCount + 1;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('No cards available for word scramble'),
        ),
      );
    }

    if (_showingResults) {
      return _buildResultsView();
    }

    final currentCard = widget.cards[_currentIndex];
    final question = _isQuestionMode ? currentCard.definition : currentCard.word;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Small header with progress bar
          SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _showCloseConfirmation(),
                        icon: const Icon(Icons.arrow_back_ios),
                        iconSize: 20,
                      ),
                      const Spacer(),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48), // Balance the layout
                    ],
                  ),
                ),
                // Progress bar
                _buildProgressBar(),
              ],
            ),
          ),
          
          // Question area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), // Reduced top padding
              child: Column(
                children: [
                  // Question text above card
                  Text(
                    'Arrange the letters to translate',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Reduced spacing
                  
                  // Card with white background and colored outline
                  Container(
                    width: double.infinity,
                    height: 200, // Reduced height
                    padding: const EdgeInsets.all(24), // Reduced padding
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20), // Slightly smaller radius
                      border: Border.all(
                        color: _getCardBorderColor(currentCard),
                        width: 4, // Slightly thinner border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getCardBorderColor(currentCard).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        question,
                        style: const TextStyle(
                          fontSize: 32, // Smaller font size
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Reduced spacing
                  
                  // Answer box
                  Container(
                    width: double.infinity,
                    height: 80, // Fixed height for consistency
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: _userAnswer.isEmpty
                        ? Center(
                            child: Text(
                              'Tap pieces to build the word',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _buildUserAnswerDisplay(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navigation buttons (only show if question is answered)
                  if (_answered)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          // Back button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _currentIndex > 0 ? _goToPreviousQuestion : null,
                              icon: const Icon(Icons.arrow_back, size: 18),
                              label: const Text('Back'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _currentIndex > 0 ? Colors.blue : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Next button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _currentIndex < widget.cards.length - 1 ? _goToNextQuestion : null,
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: const Text('Next'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _currentIndex < widget.cards.length - 1 ? Colors.green : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  // Scrambled letters
                  Text(
                    'Available pieces:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScrambledLetters(),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _currentIndex / widget.cards.length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Question ${_currentIndex + 1} of ${widget.cards.length}'),
              Text('${(progress * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnswerDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_userAnswer.isEmpty)
          Text(
            'Tap pieces to build your answer',
            style: TextStyle(
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          )
        else
          ..._userAnswer.asMap().entries.map((entry) {
            final index = entry.key;
            final piece = entry.value;
            
            return GestureDetector(
              onTap: _answered ? null : () => _removeLetterAt(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: piece.length > 2 ? 50 : 40, // Wider for longer pieces
                height: 40,
                decoration: BoxDecoration(
                  color: _answered 
                      ? (_userAnswer.join('').toLowerCase() == _correctWord.replaceAll(' ', '').toLowerCase() 
                          ? Colors.green.withValues(alpha: 0.2) 
                          : Colors.red.withValues(alpha: 0.2))
                      : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  border: Border.all(
                    color: _answered 
                        ? (_userAnswer.join('').toLowerCase() == _correctWord.replaceAll(' ', '').toLowerCase() 
                            ? Colors.green 
                            : Colors.red)
                        : Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    piece,
                    style: TextStyle(
                      fontSize: piece.length > 2 ? 14 : 16, // Smaller font for longer pieces
                      fontWeight: FontWeight.bold,
                      color: _answered 
                          ? (_userAnswer.join('').toLowerCase() == _correctWord.replaceAll(' ', '').toLowerCase() 
                              ? Colors.green 
                              : Colors.red)
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildScrambledLetters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _scrambledLetters.asMap().entries.map((entry) {
        final index = entry.key;
        final piece = entry.value;
        final isUsed = _isPieceUsed(piece, index);
        
        return GestureDetector(
          onTap: _answered || isUsed || piece.isEmpty ? null : () => _addPiece(piece),
          child: Container(
            width: piece.length > 2 ? 70 : 60, // Wider for longer pieces
            height: 50,
            decoration: BoxDecoration(
              color: isUsed || piece.isEmpty
                  ? Colors.grey.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: isUsed || piece.isEmpty
                    ? Colors.grey.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                piece.isEmpty ? '•' : piece, // Show dot for empty pieces
                style: TextStyle(
                  fontSize: piece.length > 2 ? 16 : 18, // Smaller font for longer pieces
                  fontWeight: FontWeight.bold,
                  color: isUsed || piece.isEmpty
                      ? Colors.grey.withValues(alpha: 0.5)
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildResultsView() {
    final accuracy = _totalAnswered > 0 ? (_correctAnswers / _totalAnswered * 100).toInt() : 0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          UnifiedHeader(
            title: 'Scramble Complete',
            onBack: () => Navigator.of(context).pop(),
          ),
          
          // Results content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Score
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: accuracy >= 80 ? Colors.green.withValues(alpha: 0.1) : 
                             accuracy >= 60 ? Colors.orange.withValues(alpha: 0.1) : 
                             Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$accuracy%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: accuracy >= 80 ? Colors.green : 
                                 accuracy >= 60 ? Colors.orange : 
                                 Colors.red,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Stats
                  _buildStatCard('Questions', _totalAnswered.toString(), Icons.text_fields),
                  const SizedBox(height: 16),
                  _buildStatCard('Correct', _correctAnswers.toString(), Icons.check_circle, Colors.green),
                  const SizedBox(height: 16),
                  _buildStatCard('Incorrect', (_totalAnswered - _correctAnswers).toString(), Icons.cancel, Colors.red),
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentIndex = 0;
                              _correctAnswers = 0;
                              _totalAnswered = 0;
                              _showingResults = false;
                              _answered = false;
                              _userAnswer = [];
                              // Reset all navigation state
                              _answeredQuestions.clear();
                              _correctAnswersMap.clear();
                              _correctWords.clear();
                              _scrambledLettersMap.clear();
                              _questionModes.clear();
                            });
                            _generateQuestion();
                          },
                          child: const Text('Scramble Again'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, [Color? color]) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCardBorderColor(FlashCard card) {
    // Generate a consistent color based on the card's ID
    final hash = card.id.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  void _showCloseConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Scramble?'),
        content: const Text('Are you sure you want to end this word scramble session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
} 