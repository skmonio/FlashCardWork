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
          
          // Game stats
          _buildGameStats(),
          
          // Game board
          Expanded(
            child: _buildGameBoard(),
          ),
          
          // Footer
          _buildFooter(),
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

  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Moves', '$_moves'),
          _buildStatItem('Matches', '$_matches/$_totalPairs'),
          _buildStatItem('Progress', '${((_matches / _totalPairs) * 100).toInt()}%'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: _memoryCards.length,
        itemBuilder: (context, index) {
          return _buildMemoryCard(_memoryCards[index]);
        },
      ),
    );
  }

  Widget _buildMemoryCard(MemoryCard card) {
    Color cardColor;
    Color borderColor;
    
    if (card.isMatched) {
      cardColor = Colors.green.withValues(alpha: 0.1);
      borderColor = Colors.green;
    } else if (card.isWrong) {
      cardColor = Colors.red.withValues(alpha: 0.1);
      borderColor = Colors.red;
    } else if (card.isSelected) {
      cardColor = Colors.blue.withValues(alpha: 0.1);
      borderColor = Colors.blue;
    } else {
      cardColor = Theme.of(context).colorScheme.surface;
      borderColor = Colors.grey.withValues(alpha: 0.3);
    }
    
    return GestureDetector(
      onTap: () => _selectCard(card),
      child: Card(
        elevation: card.isMatched ? 0 : 4,
        color: cardColor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor,
              width: card.isSelected || card.isMatched || card.isWrong ? 3 : 1,
            ),
          ),
          child: _buildCardContent(card),
        ),
      ),
    );
  }

  Widget _buildCardContent(MemoryCard card) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: card.type == MemoryCardType.word 
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              card.type == MemoryCardType.word ? Icons.text_fields : Icons.translate,
              size: 16,
              color: card.type == MemoryCardType.word ? Colors.blue : Colors.orange,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            card.content,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: card.type == MemoryCardType.word ? Colors.blue : Colors.orange,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
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