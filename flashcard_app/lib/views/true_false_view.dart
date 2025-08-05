import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flash_card.dart';
import '../components/unified_header.dart';

class TrueFalseView extends StatefulWidget {
  final List<FlashCard> cards;
  final String title;

  const TrueFalseView({
    super.key,
    required this.cards,
    required this.title,
  });

  @override
  State<TrueFalseView> createState() => _TrueFalseViewState();
}

class _TrueFalseViewState extends State<TrueFalseView> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _showingResults = false;
  bool _answered = false;
  bool? _selectedAnswer;
  bool? _correctAnswer;
  String _question = '';
  bool _isQuestionMode = true; // true = word to definition, false = definition to word

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
    
    // Get correct answer
    final correctAnswer = _isQuestionMode ? currentCard.definition : currentCard.word;
    
    // Get other cards for wrong options
    final otherCards = widget.cards.where((card) => card.id != currentCard.id).toList();
    
    // 50% chance of true, 50% chance of false
    final isTrue = random.nextBool();
    
    if (isTrue) {
      // True question - use correct answer
      _question = _isQuestionMode 
          ? '${currentCard.word} means "${correctAnswer}"'
          : '"${correctAnswer}" means ${currentCard.word}';
      _correctAnswer = true;
    } else {
      // False question - use wrong answer from another card
      if (otherCards.isNotEmpty) {
        final randomCard = otherCards[random.nextInt(otherCards.length)];
        final wrongAnswer = _isQuestionMode ? randomCard.definition : randomCard.word;
        _question = _isQuestionMode 
            ? '${currentCard.word} means "${wrongAnswer}"'
            : '"${wrongAnswer}" means ${currentCard.word}';
      } else {
        // Fallback for false question
        _question = _isQuestionMode 
            ? '${currentCard.word} means "something else"'
            : '"something else" means ${currentCard.word}';
      }
      _correctAnswer = false;
    }
    
    setState(() {
      _answered = false;
      _selectedAnswer = null;
    });
  }

  void _selectAnswer(bool answer) {
    if (_answered) return;
    
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _totalAnswered++;
      
      if (answer == _correctAnswer) {
        _correctAnswers++;
      }
    });
    
    // Show result for 1.5 seconds then move to next question
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
        });
        _generateQuestion();
      }
    });
  }

  Color _getButtonColor(bool isTrue) {
    if (!_answered) return Colors.transparent;
    
    if (isTrue == _correctAnswer) {
      return Colors.green.withValues(alpha: 0.2);
    } else if (isTrue == _selectedAnswer && isTrue != _correctAnswer) {
      return Colors.red.withValues(alpha: 0.2);
    }
    
    return Colors.transparent;
  }

  Color _getButtonBorderColor(bool isTrue) {
    if (!_answered) return Colors.grey.withValues(alpha: 0.3);
    
    if (isTrue == _correctAnswer) {
      return Colors.green;
    } else if (isTrue == _selectedAnswer && isTrue != _correctAnswer) {
      return Colors.red;
    }
    
    return Colors.grey.withValues(alpha: 0.3);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('No cards available for testing'),
        ),
      );
    }

    if (_showingResults) {
      return _buildResultsView();
    }

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
                          'True or False?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _question,
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
                  
                  // True/False buttons
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAnswerButton(true),
                        const SizedBox(height: 24),
                        _buildAnswerButton(false),
                      ],
                    ),
                  ),
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

  Widget _buildAnswerButton(bool isTrue) {
    return Container(
      width: double.infinity,
      height: 80,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(isTrue),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getButtonColor(isTrue),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getButtonBorderColor(isTrue),
                width: 3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getButtonBorderColor(isTrue).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isTrue ? 'T' : 'F',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getButtonBorderColor(isTrue),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  isTrue ? 'TRUE' : 'FALSE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _getButtonBorderColor(isTrue),
                  ),
                ),
                const SizedBox(width: 16),
                if (_answered && isTrue == _correctAnswer)
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                if (_answered && isTrue == _selectedAnswer && isTrue != _correctAnswer)
                  const Icon(Icons.cancel, color: Colors.red, size: 32),
              ],
            ),
          ),
        ),
      ),
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
            title: 'Test Complete',
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
                  _buildStatCard('Questions', _totalAnswered.toString(), Icons.quiz),
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
                          child: const Text('Test Again'),
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
        title: const Text('End Test?'),
        content: const Text('Are you sure you want to end this test?'),
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
            child: const Text('End Test'),
          ),
        ],
      ),
    );
  }
} 