import 'package:flutter/material.dart';
import 'dart:math';
import '../models/flash_card.dart';
import '../components/unified_header.dart';

class WritingView extends StatefulWidget {
  final List<FlashCard> cards;
  final String title;

  const WritingView({
    super.key,
    required this.cards,
    required this.title,
  });

  @override
  State<WritingView> createState() => _WritingViewState();
}

class _WritingViewState extends State<WritingView> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _showingResults = false;
  bool _answered = false;
  String _userAnswer = '';
  String _correctAnswer = '';
  String _hint = '';
  bool _isQuestionMode = true; // true = definition to word, false = word to definition
  Set<int> _incorrectPositions = {};
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
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
    _correctAnswer = _isQuestionMode ? currentCard.word : currentCard.definition;
    
    // Create hint with underscores
    _hint = '_' * _correctAnswer.length;
    
    setState(() {
      _answered = false;
      _userAnswer = '';
      _incorrectPositions.clear();
      _textController.clear();
    });
  }

  void _checkAnswer() {
    if (_userAnswer.isEmpty) return;
    
    setState(() {
      _answered = true;
      _totalAnswered++;
      
      // Check if answer is correct
      final isCorrect = _userAnswer.toLowerCase().trim() == _correctAnswer.toLowerCase().trim();
      
      if (isCorrect) {
        _correctAnswers++;
      } else {
        // Find incorrect positions
        _incorrectPositions.clear();
        final userLower = _userAnswer.toLowerCase();
        final correctLower = _correctAnswer.toLowerCase();
        
        for (int i = 0; i < userLower.length && i < correctLower.length; i++) {
          if (userLower[i] != correctLower[i]) {
            _incorrectPositions.add(i);
          }
        }
        
        // Add positions for extra or missing characters
        for (int i = correctLower.length; i < userLower.length; i++) {
          _incorrectPositions.add(i);
        }
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

  void _onTextChanged(String value) {
    setState(() {
      _userAnswer = value;
    });
  }

  Widget _buildHintText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _hint.split('').map((char) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 30,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              char,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserAnswerText() {
    if (_userAnswer.isEmpty) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _userAnswer.split('').asMap().entries.map((entry) {
        final index = entry.key;
        final char = entry.value;
        final isIncorrect = _incorrectPositions.contains(index);
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 30,
          height: 40,
          decoration: BoxDecoration(
            color: isIncorrect ? Colors.red.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
            border: Border.all(
              color: isIncorrect ? Colors.red : Colors.green,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(
              char,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isIncorrect ? Colors.red : Colors.green,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('No cards available for writing'),
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
                          _isQuestionMode ? 'Write the word for:' : 'Write the definition for:',
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
                  
                  // Hint
                  Text(
                    'Hint:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildHintText(),
                  
                  const SizedBox(height: 32),
                  
                  // Text input
                  TextField(
                    controller: _textController,
                    onChanged: _onTextChanged,
                    onSubmitted: (_) => _checkAnswer(),
                    decoration: InputDecoration(
                      hintText: 'Type your answer...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        onPressed: _checkAnswer,
                        icon: const Icon(Icons.check),
                      ),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // User answer display
                  if (_userAnswer.isNotEmpty) ...[
                    Text(
                      'Your answer:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildUserAnswerText(),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _userAnswer.isNotEmpty ? _checkAnswer : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Check Answer',
                        style: TextStyle(fontSize: 18),
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

  Widget _buildResultsView() {
    final accuracy = _totalAnswered > 0 ? (_correctAnswers / _totalAnswered * 100).toInt() : 0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          UnifiedHeader(
            title: 'Writing Complete',
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
                  _buildStatCard('Questions', _totalAnswered.toString(), Icons.edit),
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
                          child: const Text('Write Again'),
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
        title: const Text('End Writing?'),
        content: const Text('Are you sure you want to end this writing session?'),
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