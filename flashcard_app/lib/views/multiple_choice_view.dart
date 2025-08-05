import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flash_card.dart';
import '../components/unified_header.dart';

class MultipleChoiceView extends StatefulWidget {
  final List<FlashCard> cards;
  final String title;

  const MultipleChoiceView({
    super.key,
    required this.cards,
    required this.title,
  });

  @override
  State<MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<MultipleChoiceView> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _showingResults = false;
  bool _answered = false;
  int? _selectedAnswer;
  int? _correctAnswerIndex;
  List<String> _options = [];
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
    final wrongOptions = <String>[];
    
    // Get 3 wrong options
    for (int i = 0; i < 3 && i < otherCards.length; i++) {
      final randomCard = otherCards[random.nextInt(otherCards.length)];
      final wrongOption = _isQuestionMode ? randomCard.definition : randomCard.word;
      if (!wrongOptions.contains(wrongOption) && wrongOption != correctAnswer) {
        wrongOptions.add(wrongOption);
      }
    }
    
    // If we don't have enough wrong options, add some generic ones
    while (wrongOptions.length < 3) {
      final genericOptions = _isQuestionMode 
          ? ['Not sure', 'Maybe this', 'Could be']
          : ['Unknown', 'Something', 'Other'];
      wrongOptions.add(genericOptions[wrongOptions.length]);
    }
    
    // Create options list with correct answer
    _options = [...wrongOptions, correctAnswer];
    _options.shuffle(random);
    
    // Find correct answer index
    _correctAnswerIndex = _options.indexOf(correctAnswer);
    
    setState(() {
      _answered = false;
      _selectedAnswer = null;
    });
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      _totalAnswered++;
      
      if (index == _correctAnswerIndex) {
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

  Color _getOptionColor(int index) {
    if (!_answered) return Colors.transparent;
    
    if (index == _correctAnswerIndex) {
      return Colors.green.withValues(alpha: 0.2);
    } else if (index == _selectedAnswer && index != _correctAnswerIndex) {
      return Colors.red.withValues(alpha: 0.2);
    }
    
    return Colors.transparent;
  }

  Color _getOptionBorderColor(int index) {
    if (!_answered) return Colors.grey.withValues(alpha: 0.3);
    
    if (index == _correctAnswerIndex) {
      return Colors.green;
    } else if (index == _selectedAnswer && index != _correctAnswerIndex) {
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

    final currentCard = widget.cards[_currentIndex];
    final question = _isQuestionMode ? currentCard.word : currentCard.definition;

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
                          _isQuestionMode ? 'What does this word mean?' : 'What is this definition for?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          question,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Options
                  Expanded(
                    child: Column(
                      children: _options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildOptionButton(index, option),
                        );
                      }).toList(),
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

  Widget _buildOptionButton(int index, String option) {
    return Container(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getOptionColor(index),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getOptionBorderColor(index),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getOptionBorderColor(index).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getOptionBorderColor(index),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_answered && index == _correctAnswerIndex)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
                if (_answered && index == _selectedAnswer && index != _correctAnswerIndex)
                  const Icon(Icons.cancel, color: Colors.red, size: 24),
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