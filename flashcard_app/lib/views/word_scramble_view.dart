import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flash_card.dart';
import '../components/unified_header.dart';

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

    final currentCard = widget.cards[_currentIndex];
    final random = Random();
    
    // Randomly choose question mode
    _isQuestionMode = random.nextBool();
    
    // Get correct word
    _correctWord = _isQuestionMode ? currentCard.word : currentCard.definition;
    
    // Create scrambled letters
    _originalLetters = _correctWord.split('');
    _scrambledLetters = List<String>.from(_originalLetters);
    
    // Shuffle the letters
    _scrambledLetters.shuffle(random);
    
    setState(() {
      _answered = false;
      _userAnswer = [];
    });
  }

  void _addLetter(String letter) {
    if (_answered) return;
    
    setState(() {
      _userAnswer.add(letter);
    });
    
    // Auto-check answer if we have the correct number of letters
    if (_userAnswer.length == _correctWord.length) {
      _checkAnswer();
    }
  }

  void _removeLetter() {
    if (_answered || _userAnswer.isEmpty) return;
    
    setState(() {
      _userAnswer.removeLast();
    });
  }

  void _clearAnswer() {
    if (_answered) return;
    
    setState(() {
      _userAnswer.clear();
    });
  }

  void _checkAnswer() {
    if (_answered || _userAnswer.isEmpty) return;
    
    final userWord = _userAnswer.join('');
    final isCorrect = userWord.toLowerCase() == _correctWord.toLowerCase();
    
    setState(() {
      _answered = true;
      _totalAnswered++;
      
      if (isCorrect) {
        _correctAnswers++;
      }
    });
    
    // Show result for 2 seconds then move to next question
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
        });
        _generateQuestion();
      }
    });
  }

  bool _isLetterUsed(String letter, int index) {
    int usedCount = 0;
    for (int i = 0; i < index; i++) {
      if (_scrambledLetters[i] == letter) {
        usedCount++;
      }
    }
    
    int userCount = _userAnswer.where((l) => l == letter).length;
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
          // Header
          UnifiedHeader(
            title: widget.title,
            onBack: () => _showCloseConfirmation(),
          ),
          
          // Progress bar
          _buildProgressBar(),
          
          // Question area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _isQuestionMode ? 'Unscramble the word for:' : 'Unscramble the definition for:',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // User answer area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _answered 
                            ? (_userAnswer.join('').toLowerCase() == _correctWord.toLowerCase() 
                                ? Colors.green 
                                : Colors.red)
                            : Colors.grey.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your answer:',
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            Text(
                              '${_userAnswer.length}/${_correctWord.length}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildUserAnswerDisplay(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _answered ? null : _removeLetter,
                              icon: const Icon(Icons.backspace),
                              label: const Text('Delete'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _answered ? null : _clearAnswer,
                              icon: const Icon(Icons.clear),
                              label: const Text('Clear'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Scrambled letters
                  Text(
                    'Available letters:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildScrambledLetters(),
                  
                  const SizedBox(height: 24),
                  
                  // Check answer button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _userAnswer.isNotEmpty && !_answered && _userAnswer.length < _correctWord.length ? _checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        _userAnswer.length == _correctWord.length ? 'Auto-checking...' : 'Check Answer',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _answered 
              ? (_userAnswer.join('').toLowerCase() == _correctWord.toLowerCase() 
                  ? Colors.green 
                  : Colors.red)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_userAnswer.isEmpty)
            Text(
              'Tap letters to build your answer',
              style: TextStyle(
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ..._userAnswer.map((letter) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 30,
              height: 40,
              decoration: BoxDecoration(
                color: _answered 
                    ? (_userAnswer.join('').toLowerCase() == _correctWord.toLowerCase() 
                        ? Colors.green.withValues(alpha: 0.2) 
                        : Colors.red.withValues(alpha: 0.2))
                    : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: _answered 
                      ? (_userAnswer.join('').toLowerCase() == _correctWord.toLowerCase() 
                          ? Colors.green 
                          : Colors.red)
                      : Theme.of(context).colorScheme.primary,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _answered 
                        ? (_userAnswer.join('').toLowerCase() == _correctWord.toLowerCase() 
                            ? Colors.green 
                            : Colors.red)
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildScrambledLetters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _scrambledLetters.asMap().entries.map((entry) {
        final index = entry.key;
        final letter = entry.value;
        final isUsed = _isLetterUsed(letter, index);
        
        return GestureDetector(
          onTap: _answered || isUsed ? null : () => _addLetter(letter),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUsed 
                  ? Colors.grey.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              border: Border.all(
                color: isUsed 
                    ? Colors.grey.withValues(alpha: 0.5)
                    : Theme.of(context).colorScheme.primary,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isUsed 
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