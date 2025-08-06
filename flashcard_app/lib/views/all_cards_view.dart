import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../components/unified_header.dart';
import '../models/flash_card.dart';
import 'advanced_study_view.dart';
import 'multiple_choice_view.dart';
import 'true_false_view.dart';
import 'writing_view.dart';
import 'word_scramble_view.dart';

enum SortOption {
  wordAZ,
  wordZA,
  definitionAZ,
  definitionZA,
  srsLevel,
  learningPercentage,
  dateCreated,
  lastModified,
}

class AllCardsView extends StatefulWidget {
  const AllCardsView({super.key});

  @override
  State<AllCardsView> createState() => _AllCardsViewState();
}

class _AllCardsViewState extends State<AllCardsView> {
  String _searchQuery = '';
  SortOption _sortOption = SortOption.wordAZ;
  bool _isSelectionMode = false;
  Set<String> _selectedCardIds = {};
  bool _selectAll = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          UnifiedHeader(
            title: 'All Cards',
            onBack: () => Navigator.of(context).pop(),
            trailing: _isSelectionMode ? _buildSelectionActions() : _buildHeaderActions(),
          ),
          
          // Search and Sort Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search cards...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Sort and Selection Controls
                Row(
                  children: [
                    // Sort Dropdown
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SortOption>(
                            value: _sortOption,
                            isExpanded: true,
                            items: [
                              DropdownMenuItem(value: SortOption.wordAZ, child: Text('Word A-Z')),
                              DropdownMenuItem(value: SortOption.wordZA, child: Text('Word Z-A')),
                              DropdownMenuItem(value: SortOption.definitionAZ, child: Text('Definition A-Z')),
                              DropdownMenuItem(value: SortOption.definitionZA, child: Text('Definition Z-A')),
                              DropdownMenuItem(value: SortOption.srsLevel, child: Text('SRS Level')),
                              DropdownMenuItem(value: SortOption.learningPercentage, child: Text('Learning %')),
                              DropdownMenuItem(value: SortOption.dateCreated, child: Text('Date Created')),
                              DropdownMenuItem(value: SortOption.lastModified, child: Text('Last Modified')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortOption = value;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Selection Mode Toggle
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isSelectionMode = !_isSelectionMode;
                          if (!_isSelectionMode) {
                            _selectedCardIds.clear();
                            _selectAll = false;
                          }
                        });
                      },
                      icon: Icon(
                        _isSelectionMode ? Icons.close : Icons.select_all,
                        color: _isSelectionMode ? Colors.red : Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: _isSelectionMode ? 'Exit Selection' : 'Select Cards',
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Cards List
          Expanded(
            child: Consumer<FlashcardProvider>(
              builder: (context, provider, child) {
                final cards = _getFilteredAndSortedCards(provider);
                
                if (cards.isEmpty) {
                  return _buildEmptyState();
                }
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return _buildCardItem(cards[index], provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => _showSortInfo(),
          icon: const Icon(Icons.info_outline),
          tooltip: 'Sort Info',
        ),
      ],
    );
  }

  Widget _buildSelectionActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Select All Toggle
        IconButton(
          onPressed: () {
            setState(() {
              if (_selectAll) {
                _selectedCardIds.clear();
                _selectAll = false;
              } else {
                final provider = context.read<FlashcardProvider>();
                final cards = _getFilteredAndSortedCards(provider);
                _selectedCardIds = cards.map((c) => c.id).toSet();
                _selectAll = true;
              }
            });
          },
          icon: Icon(_selectAll ? Icons.check_box : Icons.check_box_outline_blank),
          tooltip: _selectAll ? 'Deselect All' : 'Select All',
        ),
        
        // Delete Selected
        if (_selectedCardIds.isNotEmpty)
          IconButton(
            onPressed: () => _showDeleteConfirmation(),
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Selected',
          ),
        
        // Edit Selected (if only one selected)
        if (_selectedCardIds.length == 1)
          IconButton(
            onPressed: () => _editSelectedCard(),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Card',
          ),
        
        // Selection Count
        if (_selectedCardIds.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_selectedCardIds.length}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.credit_card,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards found',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add some cards',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(FlashCard card, FlashcardProvider provider) {
    final isSelected = _selectedCardIds.contains(card.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: _isSelectionMode ? () => _toggleCardSelection(card.id) : () => _showCardDetails(card),
        onLongPress: () {
          setState(() {
            _isSelectionMode = true;
            _selectedCardIds.add(card.id);
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isSelectionMode)
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleCardSelection(card.id),
                  ),
                CircleAvatar(
                  backgroundColor: _getSRSColor(card.srsLevel),
                  child: Text(
                    card.srsLevel.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            title: Row(
              children: [
                Text(
                  card.article.isNotEmpty ? '${card.article} ' : '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    card.word,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.definition),
                if (card.example.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    card.example,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildProgressIndicator(card),
                    const SizedBox(width: 8),
                    Text(
                      '${card.learningPercentage ?? 0}% learned',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: _isSelectionMode ? null : PopupMenuButton<String>(
              onSelected: (value) => _handleCardAction(value, card, provider),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit Card'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Card', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'reset',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 16),
                      SizedBox(width: 8),
                      Text('Reset Progress'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(FlashCard card) {
    return Expanded(
      child: LinearProgressIndicator(
        value: (card.learningPercentage ?? 0) / 100.0,
        backgroundColor: Colors.grey.withValues(alpha: 0.2),
        valueColor: AlwaysStoppedAnimation<Color>(_getSRSColor(card.srsLevel)),
      ),
    );
  }

  Color _getSRSColor(int srsLevel) {
    switch (srsLevel) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.lightGreen;
      default:
        return Colors.green;
    }
  }

  List<FlashCard> _getFilteredAndSortedCards(FlashcardProvider provider) {
    var cards = List<FlashCard>.from(provider.cards);
    
    print('AllCardsView: Total cards in provider: ${provider.cards.length}');
    print('AllCardsView: Cards after copy: ${cards.length}');

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      cards = cards.where((card) =>
        card.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        card.definition.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        card.example.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
      print('AllCardsView: Cards after search filter: ${cards.length}');
    }

    // Sort cards
    switch (_sortOption) {
      case SortOption.wordAZ:
        cards.sort((a, b) => a.word.compareTo(b.word));
        break;
      case SortOption.wordZA:
        cards.sort((a, b) => b.word.compareTo(a.word));
        break;
      case SortOption.definitionAZ:
        cards.sort((a, b) => a.definition.compareTo(b.definition));
        break;
      case SortOption.definitionZA:
        cards.sort((a, b) => b.definition.compareTo(a.definition));
        break;
      case SortOption.srsLevel:
        cards.sort((a, b) => b.srsLevel.compareTo(a.srsLevel));
        break;
      case SortOption.learningPercentage:
        cards.sort((a, b) => (b.learningPercentage ?? 0).compareTo(a.learningPercentage ?? 0));
        break;
      case SortOption.dateCreated:
        cards.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        break;
      case SortOption.lastModified:
        cards.sort((a, b) => b.lastModified.compareTo(a.lastModified));
        break;
    }

    print('AllCardsView: Final cards to display: ${cards.length}');
    return cards;
  }

  void _toggleCardSelection(String cardId) {
    print('Toggling selection for card: $cardId');
    setState(() {
      if (_selectedCardIds.contains(cardId)) {
        _selectedCardIds.remove(cardId);
        _selectAll = false;
        print('Removed card $cardId from selection. Selected: $_selectedCardIds');
      } else {
        _selectedCardIds.add(cardId);
        // Check if all cards are now selected
        final provider = context.read<FlashcardProvider>();
        final cards = _getFilteredAndSortedCards(provider);
        _selectAll = _selectedCardIds.length == cards.length;
        print('Added card $cardId to selection. Selected: $_selectedCardIds');
      }
    });
  }

  void _handleCardAction(String action, FlashCard card, FlashcardProvider provider) {
    switch (action) {
      case 'edit':
        _editCard(card);
        break;
      case 'delete':
        _showDeleteCardConfirmation(card, provider);
        break;
      case 'reset':
        _resetCardProgress(card, provider);
        break;
    }
  }

  void _editSelectedCard() {
    final provider = context.read<FlashcardProvider>();
    final cardId = _selectedCardIds.first;
    final card = provider.cards.firstWhere((c) => c.id == cardId);
    _editCard(card);
  }

  void _editCard(FlashCard card) {
    final wordController = TextEditingController(text: card.word);
    final definitionController = TextEditingController(text: card.definition);
    final exampleController = TextEditingController(text: card.example);
    final articleController = TextEditingController(text: card.article);
    final pluralController = TextEditingController(text: card.plural);
    final pastTenseController = TextEditingController(text: card.pastTense);
    final futureTenseController = TextEditingController(text: card.futureTense);
    final pastParticipleController = TextEditingController(text: card.pastParticiple);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Card'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordController,
                decoration: const InputDecoration(
                  labelText: 'Word',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: definitionController,
                decoration: const InputDecoration(
                  labelText: 'Definition',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: exampleController,
                decoration: const InputDecoration(
                  labelText: 'Example',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: articleController,
                      decoration: const InputDecoration(
                        labelText: 'Article',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: pluralController,
                      decoration: const InputDecoration(
                        labelText: 'Plural',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pastTenseController,
                      decoration: const InputDecoration(
                        labelText: 'Past Tense',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: futureTenseController,
                      decoration: const InputDecoration(
                        labelText: 'Future Tense',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pastParticipleController,
                decoration: const InputDecoration(
                  labelText: 'Past Participle',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Update the card
              card.word = wordController.text.trim();
              card.definition = definitionController.text.trim();
              card.example = exampleController.text.trim();
              card.article = articleController.text.trim();
              card.plural = pluralController.text.trim();
              card.pastTense = pastTenseController.text.trim();
              card.futureTense = futureTenseController.text.trim();
              card.pastParticiple = pastParticipleController.text.trim();
              
              // Save the updated card
              final provider = context.read<FlashcardProvider>();
              final success = await provider.updateCard(card);
              
              Navigator.of(context).pop();
              
              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Updated card: ${card.word}')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update card'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cards'),
        content: Text(
          'Are you sure you want to delete ${_selectedCardIds.length} card${_selectedCardIds.length == 1 ? '' : 's'}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteSelectedCards();
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCardConfirmation(FlashCard card, FlashcardProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text(
          'Are you sure you want to delete "${card.word}"? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCard(card, provider);
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteSelectedCards() async {
    final provider = context.read<FlashcardProvider>();
    final selectedCount = _selectedCardIds.length;
    
    print('Deleting $selectedCount cards: $_selectedCardIds');
    
    for (final cardId in _selectedCardIds.toList()) {
      print('Deleting card: $cardId');
      final success = await provider.deleteCard(cardId);
      print('Delete result for $cardId: $success');
    }
    
    setState(() {
      _selectedCardIds.clear();
      _selectAll = false;
      _isSelectionMode = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted $selectedCount cards')),
      );
    }
  }

  void _deleteCard(FlashCard card, FlashcardProvider provider) async {
    print('AllCardsView: Deleting card: ${card.word} (${card.id})');
    final success = await provider.deleteCard(card.id);
    print('AllCardsView: Delete result: $success');
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted card: ${card.word}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete card: ${card.word}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetCardProgress(FlashCard card, FlashcardProvider provider) async {
    final resetCard = card.copyWith(
      srsLevel: 0,
      timesShown: 0,
      timesCorrect: 0,
      consecutiveCorrect: 0,
      consecutiveIncorrect: 0,
      easeFactor: 2.5,
      nextReviewDate: null,
      lastReviewDate: null,
      totalReviews: 0,
    );
    
    await provider.updateCard(resetCard);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset progress for: ${card.word}')),
      );
    }
  }

  void _showSortInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Options'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Word A-Z: Alphabetical by word'),
            Text('• Word Z-A: Reverse alphabetical by word'),
            Text('• Definition A-Z: Alphabetical by definition'),
            Text('• Definition Z-A: Reverse alphabetical by definition'),
            Text('• SRS Level: By spaced repetition level'),
            Text('• Learning %: By learning progress percentage'),
            Text('• Date Created: By creation date (newest first)'),
            Text('• Last Modified: By last modification date'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }

  void _showCardDetails(FlashCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              card.article.isNotEmpty ? '${card.article} ' : '',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Expanded(child: Text(card.word)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              card.definition,
              style: const TextStyle(fontSize: 16),
            ),
            if (card.example.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Example:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.example,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            if (card.plural.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Plural: ${card.plural}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Text('SRS Level: '),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getSRSColor(card.srsLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    card.srsLevel.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Learning Progress: ${card.learningPercentage ?? 0}%'),
            const SizedBox(height: 8),
            Text('Times Shown: ${card.timesShown}'),
            Text('Times Correct: ${card.timesCorrect}'),
            Text('Consecutive Correct: ${card.consecutiveCorrect}'),
            Text('Ease Factor: ${card.easeFactor.toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showStudyOptions(card);
            },
            child: const Text('Study This Card'),
          ),
        ],
      ),
    );
  }

  void _showStudyOptions(FlashCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Study "${card.word}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose a study mode:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            _buildStudyOption(
              context,
              'Study Your Card',
              'Flip and swipe to study',
              Icons.flip,
              () => _startStudyMode(card, 'study'),
            ),
            const SizedBox(height: 8),
            _buildStudyOption(
              context,
              'Test Your Card',
              'Multiple choice quiz',
              Icons.quiz,
              () => _startStudyMode(card, 'test'),
            ),
            const SizedBox(height: 8),
            _buildStudyOption(
              context,
              'True or False',
              'True/false questions',
              Icons.check_circle_outline,
              () => _startStudyMode(card, 'truefalse'),
            ),
            const SizedBox(height: 8),
            _buildStudyOption(
              context,
              'Write Your Card',
              'Type the translation',
              Icons.edit_note,
              () => _startStudyMode(card, 'write'),
            ),
            const SizedBox(height: 8),
            _buildStudyOption(
              context,
              'Jumble Your Card',
              'Arrange letters',
              Icons.shuffle,
              () => _startStudyMode(card, 'jumble'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudyOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _startStudyMode(FlashCard card, String mode) {
    Navigator.of(context).pop(); // Close the study options dialog
    
    switch (mode) {
      case 'study':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AdvancedStudyView(
              cards: [card],
              startFlipped: false,
              title: 'Study "${card.word}"',
            ),
          ),
        );
        break;
      case 'test':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultipleChoiceView(
              cards: [card],
              title: 'Test "${card.word}"',
            ),
          ),
        );
        break;
      case 'truefalse':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrueFalseView(
              cards: [card],
              title: 'True or False "${card.word}"',
            ),
          ),
        );
        break;
      case 'write':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WritingView(
              cards: [card],
              title: 'Write "${card.word}"',
            ),
          ),
        );
        break;
      case 'jumble':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => WordScrambleView(
              cards: [card],
              title: 'Jumble "${card.word}"',
            ),
          ),
        );
        break;
    }
  }
} 