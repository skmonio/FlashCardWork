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

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Create pairs of cards (word and definition)
    _memoryCards = [];
    
    for (final card in widget.cards.take(6)) { // Limit to 6 cards for 12 tiles
      // Add word card
      _memoryCards.add(MemoryCard(
        id: '${card.id}_word',
        content: card.word,
        type: MemoryCardType.word,
        originalCard: card,
        isFlipped: widget.startFlipped,
      ));
      
      // Add definition card
      _memoryCards.add(MemoryCard(
        id: '${card.id}_def',
        content: card.definition,
        type: MemoryCardType.definition,
        originalCard: card,
        isFlipped: !widget.startFlipped,
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

  Widget _buildGameStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Moves', '$_moves'),
          _buildStatItem('Matches', '$_matches'),
          _buildStatItem('Pairs', '${_memoryCards.length ~/ 2}'),
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
            fontSize: 24,
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
          crossAxisCount: 3,
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
    return GestureDetector(
      onTap: () => _flipCard(card),
      child: Card(
        elevation: card.isMatched ? 0 : 4,
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
          Icon(
            card.type == MemoryCardType.word ? Icons.text_fields : Icons.translate,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 4),
          Text(
            card.content,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
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
    return Icon(
      Icons.question_mark,
      size: 32,
      color: Colors.white,
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

      // Check if game is complete
      if (_matches == _memoryCards.length ~/ 2) {
        _gameComplete = true;
        _showGameCompleteDialog();
      }
    } else {
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
    // Find unmatched cards and show a hint
    final unmatchedCards = _memoryCards.where((card) => !card.isMatched).toList();
    if (unmatchedCards.isNotEmpty) {
      final randomCard = unmatchedCards[Random().nextInt(unmatchedCards.length)];
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hint: Look for "${randomCard.content}"'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Game Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Congratulations! You matched all the pairs.'),
            const SizedBox(height: 16),
            Text('Moves: $_moves'),
            Text('Pairs: $_matches'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
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