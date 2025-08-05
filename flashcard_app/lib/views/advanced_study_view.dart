import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/flashcard_provider.dart';
import '../models/flash_card.dart';
import '../components/unified_header.dart';

enum SwipeDirection {
  none,
  left,   // Don't Know
  right,  // Known
  up,     // Review
  down,   // Skip
}

class AdvancedStudyView extends StatefulWidget {
  final List<FlashCard> cards;
  final bool startFlipped;
  final String title;

  const AdvancedStudyView({
    super.key,
    required this.cards,
    this.startFlipped = false,
    required this.title,
  });

  @override
  State<AdvancedStudyView> createState() => _AdvancedStudyViewState();
}

class _AdvancedStudyViewState extends State<AdvancedStudyView> 
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Set<String> _knownCards = {};
  Set<String> _unknownCards = {};
  Set<String> _skippedCards = {};
  bool _isShowingFront = true;
  Offset _dragOffset = Offset.zero;
  bool _nextCardActive = false;
  bool _showingResults = false;
  SwipeDirection _swipeDirection = SwipeDirection.none;
  double _swipeIntensity = 0;
  
  // Animation controllers
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  
  // Session tracking
  DateTime _sessionStartTime = DateTime.now();
  int _sessionXP = 0;
  int _combo = 0;
  int _maxCombo = 0;

  @override
  void initState() {
    super.initState();
    _isShowingFront = !widget.startFlipped;
    
    // Initialize flip animation
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _flipController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(
          child: Text('No cards available for study'),
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
          
          // Main card area
          Expanded(
            child: _buildCardArea(),
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
              Text('Card ${_currentIndex + 1} of ${widget.cards.length}'),
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

  Widget _buildCardArea() {
    final currentCard = widget.cards[_currentIndex];
    
    return GestureDetector(
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTap: _handleCardTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Transform.translate(
            offset: _dragOffset,
            child: Transform.rotate(
              angle: _swipeIntensity * 0.1,
              child: _buildCard(currentCard),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(FlashCard card) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isFlipped = _flipAnimation.value >= 0.5;
        
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_flipAnimation.value * pi),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateY(isFlipped ? pi : 0),
            child: isFlipped ? _buildCardBack(card) : _buildCardFront(card),
          ),
        );
      },
    );
  }

  Widget _buildCardFront(FlashCard card) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _getSwipeColor(),
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleCardTap,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  card.word,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack(FlashCard card) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _getSwipeColor(),
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleCardTap,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  card.definition,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_nextCardActive) return;
    
    setState(() {
      _dragOffset += details.delta;
      _swipeIntensity = _dragOffset.distance / 100;
      
      // Determine swipe direction
      if (_dragOffset.dx.abs() > _dragOffset.dy.abs()) {
        _swipeDirection = _dragOffset.dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      } else {
        _swipeDirection = _dragOffset.dy > 0 ? SwipeDirection.down : SwipeDirection.up;
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_nextCardActive) return;
    
    final velocity = details.velocity.pixelsPerSecond;
    final distance = _dragOffset.distance;
    
    if (distance > 100 || velocity.distance > 500) {
      _handleSwipe(_swipeDirection);
    } else {
      setState(() {
        _dragOffset = Offset.zero;
        _swipeDirection = SwipeDirection.none;
        _swipeIntensity = 0;
      });
    }
  }

  void _handleCardTap() {
    if (_nextCardActive) return;
    
    if (_flipController.status == AnimationStatus.completed) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
  }

  void _handleSwipe(SwipeDirection direction) {
    if (_nextCardActive) return;
    
    final currentCard = widget.cards[_currentIndex];
    
    switch (direction) {
      case SwipeDirection.left: // Don't Know
        _unknownCards.add(currentCard.id);
        _combo = 0;
        break;
      case SwipeDirection.right: // Known
        _knownCards.add(currentCard.id);
        _combo++;
        if (_combo > _maxCombo) _maxCombo = _combo;
        break;
      case SwipeDirection.up: // Review
        // Don't add to any set, just skip
        break;
      case SwipeDirection.down: // Skip
        _skippedCards.add(currentCard.id);
        _combo = 0;
        break;
      default:
        return;
    }
    
    _nextCard();
  }

  void _nextCard() {
    setState(() {
      _nextCardActive = true;
      _dragOffset = Offset.zero;
      _swipeDirection = SwipeDirection.none;
      _swipeIntensity = 0;
    });
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _currentIndex++;
          _nextCardActive = false;
          
          if (_currentIndex >= widget.cards.length) {
            _showingResults = true;
          } else {
            _isShowingFront = !widget.startFlipped;
            _flipController.reset();
          }
        });
      }
    });
  }

  Color _getSwipeColor([SwipeDirection? direction]) {
    final dir = direction ?? _swipeDirection;
    switch (dir) {
      case SwipeDirection.left:
        return Colors.red;
      case SwipeDirection.right:
        return Colors.green;
      case SwipeDirection.up:
        return Colors.blue;
      case SwipeDirection.down:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getSwipeIcon(SwipeDirection direction) {
    switch (direction) {
      case SwipeDirection.left:
        return Icons.close;
      case SwipeDirection.right:
        return Icons.check;
      case SwipeDirection.up:
        return Icons.refresh;
      case SwipeDirection.down:
        return Icons.skip_next;
      default:
        return Icons.help;
    }
  }

  void _showCloseConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Study Session?'),
        content: const Text('Are you sure you want to end this study session?'),
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

  Widget _buildResultsView() {
    final totalCards = _knownCards.length + _unknownCards.length + _skippedCards.length;
    final accuracy = totalCards > 0 ? (_knownCards.length / totalCards * 100).toInt() : 0;
    final sessionDuration = DateTime.now().difference(_sessionStartTime);
    
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          UnifiedHeader(
            title: 'Study Complete',
            onBack: () => Navigator.of(context).pop(),
          ),
          
          // Results content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Session stats
                  _buildStatCard('Cards Studied', totalCards.toString(), Icons.school),
                  const SizedBox(height: 16),
                  _buildStatCard('Known', _knownCards.length.toString(), Icons.check_circle, Colors.green),
                  const SizedBox(height: 16),
                  _buildStatCard('Unknown', _unknownCards.length.toString(), Icons.cancel, Colors.red),
                  const SizedBox(height: 16),
                  _buildStatCard('Skipped', _skippedCards.length.toString(), Icons.skip_next, Colors.orange),
                  const SizedBox(height: 24),
                  _buildStatCard('Accuracy', '$accuracy%', Icons.analytics, Colors.blue),
                  const SizedBox(height: 16),
                  _buildStatCard('Max Combo', _maxCombo.toString(), Icons.local_fire_department, Colors.orange),
                  const SizedBox(height: 32),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _currentIndex = 0;
                              _knownCards.clear();
                              _unknownCards.clear();
                              _skippedCards.clear();
                              _combo = 0;
                              _maxCombo = 0;
                              _sessionStartTime = DateTime.now();
                              _showingResults = false;
                              _isShowingFront = !widget.startFlipped;
                              _flipController.reset();
                            });
                          },
                          child: const Text('Study Again'),
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
} 