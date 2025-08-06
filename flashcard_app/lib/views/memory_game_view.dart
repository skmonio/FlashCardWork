import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/flashcard_provider.dart';
import '../models/flash_card.dart';
import '../services/sound_manager.dart';

class MemoryGameView extends StatefulWidget {
  final List<FlashCard> cards;
  final bool startFlipped;

  const MemoryGameView({
    super.key,
    required this.cards,
    this.startFlipped = false,
  });

  @override
  State<MemoryGameView> createState() => _MemoryGameViewState();
}

class _MemoryGameViewState extends State<MemoryGameView> {
  List<MemoryCard> _memoryCards = [];
  MemoryCard? _firstCard;
  MemoryCard? _secondCard;
  bool _canSelect = true;
  int _moves = 0;
  int _matches = 0;
  bool _gameComplete = false;
  int _totalPairs = 5; // Fixed to 5 pairs

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create 5 pairs of cards (word and definition)
    _memoryCards = [];
    
    // Use exactly 5 cards for 10 tiles (5 pairs)
    final cardsToUse = widget.cards.take(5).toList();
    
    for (final card in cardsToUse) {
      // Add word card
      _memoryCards.add(MemoryCard(
        id: '${card.id}_word',
        content: card.word,
        type: MemoryCardType.word,
        originalCard: card,
        isMatched: false,
        isSelected: false,
        isWrong: false,
      ));
      
      // Add definition card
      _memoryCards.add(MemoryCard(
        id: '${card.id}_def',
        content: card.definition,
        type: MemoryCardType.definition,
        originalCard: card,
        isMatched: false,
        isSelected: false,
        isWrong: false,
      ));
    }
    
    // Shuffle the cards
    _memoryCards.shuffle();
  }

  @override
  Widget build(BuildContext context) {
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
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios),
                        iconSize: 20,
                      ),
                      const Spacer(),
                      Text(
                        'Memory Game',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                _buildProgressBar(),
              ],
            ),
          ),
          
          // Game board
          Expanded(
            child: _buildGameBoard(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _matches / _totalPairs;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Matches $_matches of $_totalPairs'),
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



  Widget _buildGameBoard() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Left column - Words
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _memoryCards
                    .where((card) => card.type == MemoryCardType.word)
                    .map((card) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMemoryCard(card),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(width: 20),
            // Right column - Definitions
            SizedBox(
              width: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _memoryCards
                    .where((card) => card.type == MemoryCardType.definition)
                    .map((card) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildMemoryCard(card),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryCard(MemoryCard card) {
    Color borderColor;
    Color backgroundColor;
    List<BoxShadow> shadows;
    
    if (card.isMatched) {
      borderColor = Colors.green;
      backgroundColor = Colors.white;
      shadows = [
        BoxShadow(
          color: Colors.green.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (card.isWrong) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      shadows = [
        BoxShadow(
          color: Colors.red.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (card.isSelected) {
      borderColor = Colors.blue;
      backgroundColor = Colors.blue.withValues(alpha: 0.1);
      shadows = [
        BoxShadow(
          color: Colors.blue.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      borderColor = _getCardBorderColor(card.originalCard);
      backgroundColor = Colors.white;
      shadows = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];
    }
    
    return GestureDetector(
      onTap: () => _selectCard(card),
      child: AnimatedOpacity(
        opacity: card.isMatched ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 500),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: card.isSelected || card.isMatched || card.isWrong ? 3 : 2,
            ),
            boxShadow: shadows,
          ),
          child: _buildCardContent(card),
        ),
      ),
    );
  }

  Widget _buildCardContent(MemoryCard card) {
    return Center(
      child: Text(
        card.content,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getCardBorderColor(FlashCard card) {
    // Generate consistent vibrant colors based on card content
    final vibrantColors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF673AB7), // Deep Purple
      const Color(0xFF3F51B5), // Indigo
      const Color(0xFF2196F3), // Blue
      const Color(0xFF03A9F4), // Light Blue
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Teal
      const Color(0xFF4CAF50), // Green
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFCDDC39), // Lime
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFFFC107), // Amber
      const Color(0xFFFF9800), // Orange
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
    ];
    
    // Use card content to generate consistent index
    final hash = card.word.hashCode + card.definition.hashCode;
    final index = hash.abs() % vibrantColors.length;
    return vibrantColors[index];
  }



  void _selectCard(MemoryCard card) {
    if (!_canSelect || card.isMatched) return;

    setState(() {
      card.isSelected = true;
    });

    if (_firstCard == null) {
      _firstCard = card;
    } else {
      _secondCard = card;
      _moves++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (_firstCard == null || _secondCard == null) return;

    final isMatch = _firstCard!.originalCard.id == _secondCard!.originalCard.id;

    if (isMatch) {
      setState(() {
        _firstCard!.isMatched = true;
        _secondCard!.isMatched = true;
        _matches++;
        _firstCard!.isSelected = false;
        _secondCard!.isSelected = false;
      });

      // Play correct sound
      SoundManager().playCorrectSound();

      // Check if game is complete
      if (_matches == _totalPairs) {
        _gameComplete = true;
        _showGameCompleteDialog();
      }
    } else {
      setState(() {
        _firstCard!.isWrong = true;
        _secondCard!.isWrong = true;
        _firstCard!.isSelected = false;
        _secondCard!.isSelected = false;
      });

      // Play wrong sound
      SoundManager().playWrongSound();

      // Reset wrong cards after a delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _firstCard!.isWrong = false;
            _secondCard!.isWrong = false;
            _firstCard = null;
            _secondCard = null;
            _canSelect = true;
          });
        }
      });
    }

    setState(() {
      _firstCard = null;
      _secondCard = null;
      _canSelect = false;
    });

    // Re-enable selection after a delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _canSelect = true;
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      _memoryCards.clear();
      _firstCard = null;
      _secondCard = null;
      _canSelect = true;
      _moves = 0;
      _matches = 0;
      _gameComplete = false;
      _initializeGame();
    });
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Memory Game Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              size: 64,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text('You found all $_totalPairs pairs!'),
            const SizedBox(height: 8),
            Text('Total moves: $_moves'),
            const SizedBox(height: 8),
            Text('Efficiency: ${_totalPairs > 0 ? ((_totalPairs / _moves) * 100).toInt() : 0}%'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }
}

class MemoryCard {
  final String id;
  final String content;
  final MemoryCardType type;
  final FlashCard originalCard;
  bool isMatched;
  bool isSelected;
  bool isWrong;

  MemoryCard({
    required this.id,
    required this.content,
    required this.type,
    required this.originalCard,
    this.isMatched = false,
    this.isSelected = false,
    this.isWrong = false,
  });
}

enum MemoryCardType {
  word,
  definition,
} 