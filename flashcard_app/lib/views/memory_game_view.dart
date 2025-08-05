import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/flashcard_provider.dart';
import '../models/flash_card.dart';
import '../components/unified_header.dart';

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
  bool _canFlip = true;
  int _moves = 0;
  int _matches = 0;
  bool _gameComplete = false;
  int _totalPairs = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create pairs of cards (word and definition)
    _memoryCards = [];
    
    // Use up to 8 cards for 16 tiles (8 pairs)
    final cardsToUse = widget.cards.take(8).toList();
    _totalPairs = cardsToUse.length;
    
    for (final card in cardsToUse) {
      // Add word card
      _memoryCards.add(MemoryCard(
        id: '${card.id}_word',
        content: card.word,
        type: MemoryCardType.word,
        originalCard: card,
        isFlipped: false,
      ));
      
      // Add definition card
      _memoryCards.add(MemoryCard(
        id: '${card.id}_def',
        content: card.definition,
        type: MemoryCardType.definition,
        originalCard: card,
        isFlipped: false,
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
          // Header
          UnifiedHeader(
            title: 'Memory Game',
            onBack: () => Navigator.of(context).pop(),
          ),
          
          // Game instructions
          _buildInstructions(),
          
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

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Find matching pairs: Word ↔ Definition',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
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
    final isSelected = _firstCard == card || _secondCard == card;
    
    return GestureDetector(
      onTap: () => _flipCard(card),
      child: Card(
        elevation: card.isMatched ? 0 : (isSelected ? 8 : 4),
        color: card.isMatched 
            ? Colors.green.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: card.isFlipped || card.isMatched
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.primary,
            border: isSelected && !card.isMatched
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  )
                : null,
          ),
          child: Center(
            child: card.isFlipped || card.isMatched
                ? _buildCardContent(card)
                : _buildCardBack(),
          ),
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

  Widget _buildCardBack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.question_mark,
          size: 24,
          color: Colors.white,
        ),
        const SizedBox(height: 4),
        Text(
          '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
          ElevatedButton.icon(
            onPressed: _showHint,
            icon: const Icon(Icons.lightbulb),
            label: const Text('Hint'),
          ),
        ],
      ),
    );
  }

  void _flipCard(MemoryCard card) {
    if (!_canFlip || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
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
      });

      // Show match feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match found: ${_firstCard!.originalCard.word}'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 1000),
        ),
      );

      // Check if game is complete
      if (_matches == _totalPairs) {
        _gameComplete = true;
        _showGameCompleteDialog();
      }
    } else {
      // Show mismatch feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No match - try again!'),
          backgroundColor: Colors.red,
          duration: Duration(milliseconds: 1000),
        ),
      );

      // Hide cards after a delay
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _firstCard!.isFlipped = false;
            _secondCard!.isFlipped = false;
            _firstCard = null;
            _secondCard = null;
            _canFlip = true;
          });
        }
      });
    }

    setState(() {
      _firstCard = null;
      _secondCard = null;
      _canFlip = false;
    });

    // Re-enable flipping after a delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _canFlip = true;
        });
      }
    });
  }

  void _resetGame() {
    setState(() {
      _memoryCards.clear();
      _firstCard = null;
      _secondCard = null;
      _canFlip = true;
      _moves = 0;
      _matches = 0;
      _gameComplete = false;
      _initializeGame();
    });
  }

  void _showHint() {
    // Find an unmatched card and show it briefly
    final unmatchedCards = _memoryCards.where((card) => !card.isMatched && !card.isFlipped).toList();
    if (unmatchedCards.isNotEmpty) {
      final randomCard = unmatchedCards[Random().nextInt(unmatchedCards.length)];
      
      setState(() {
        randomCard.isFlipped = true;
      });
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && !randomCard.isMatched) {
          setState(() {
            randomCard.isFlipped = false;
          });
        }
      });
    }
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
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.content,
    required this.type,
    required this.originalCard,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

enum MemoryCardType {
  word,
  definition,
} 