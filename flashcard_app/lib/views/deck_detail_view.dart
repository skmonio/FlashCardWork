import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../components/unified_header.dart';
import '../models/deck.dart';
import '../models/flash_card.dart';
import 'add_card_view.dart';
import 'study_view.dart';

class DeckDetailView extends StatefulWidget {
  final Deck deck;
  
  const DeckDetailView({
    super.key,
    required this.deck,
  });

  @override
  State<DeckDetailView> createState() => _DeckDetailViewState();
}

class _DeckDetailViewState extends State<DeckDetailView> {
  String _searchQuery = '';
  String _sortBy = 'word'; // word, definition, dateCreated, srsLevel

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          UnifiedHeader(
            title: widget.deck.name,
            onBack: () => Navigator.of(context).pop(),
            trailing: PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('Edit Deck'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'study',
                  child: Row(
                    children: [
                      Icon(Icons.school),
                      SizedBox(width: 8),
                      Text('Study Deck'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Export Deck'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete Deck', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Search and Sort
          _buildSearchAndSort(),
          
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCardToDeck(),
        tooltip: 'Add Card to Deck',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndSort() {
    return Container(
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
          
          // Sort Options
          Row(
            children: [
              Text(
                'Sort by: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSortChip('word', 'Word'),
                      _buildSortChip('definition', 'Definition'),
                      _buildSortChip('dateCreated', 'Date Added'),
                      _buildSortChip('srsLevel', 'SRS Level'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _sortBy = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No cards in this deck',
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first card',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addCardToDeck,
            icon: const Icon(Icons.add),
            label: const Text('Add First Card'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(FlashCard card, FlashcardProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getSRSColor(card.srsLevel),
          child: Text(
            card.srsLevel.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                   '${((card.learningPercentage ?? 0) * 100).toInt()}% learned',
                   style: TextStyle(
                     fontSize: 12,
                     color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                   ),
                 ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCardAction(value, card),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'study',
              child: Row(
                children: [
                  Icon(Icons.school, size: 16),
                  SizedBox(width: 8),
                  Text('Study This Card'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showCardDetails(card),
      ),
    );
  }

  Widget _buildProgressIndicator(FlashCard card) {
    return Expanded(
      child: LinearProgressIndicator(
        value: (card.learningPercentage ?? 0).toDouble(),
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
    var cards = provider.cards.where((card) => 
      card.deckIds.contains(widget.deck.id)
    ).toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      cards = cards.where((card) =>
        card.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        card.definition.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        card.example.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Sort cards
    switch (_sortBy) {
      case 'word':
        cards.sort((a, b) => a.word.compareTo(b.word));
        break;
      case 'definition':
        cards.sort((a, b) => a.definition.compareTo(b.definition));
        break;
      case 'dateCreated':
        cards.sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
        break;
      case 'srsLevel':
        cards.sort((a, b) => a.srsLevel.compareTo(b.srsLevel));
        break;
    }

    return cards;
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        _editDeck();
        break;
      case 'study':
        _studyDeck();
        break;
      case 'export':
        _exportDeck();
        break;
      case 'delete':
        _deleteDeck();
        break;
    }
  }

  void _handleCardAction(String action, FlashCard card) {
    switch (action) {
      case 'edit':
        _editCard(card);
        break;
      case 'study':
        _studySingleCard(card);
        break;
      case 'delete':
        _deleteCard(card);
        break;
    }
  }

  void _addCardToDeck() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddCardView(selectedDeck: widget.deck),
      ),
    );
  }

  void _editDeck() {
    final nameController = TextEditingController(text: widget.deck.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Deck'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Deck Name',
            hintText: 'Enter deck name...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                final navigator = Navigator.of(context);
                final provider = context.read<FlashcardProvider>();
                                 final updatedDeck = widget.deck.copyWith(name: nameController.text.trim());
                 await provider.updateDeck(updatedDeck);
                if (mounted) {
                  navigator.pop();
                  setState(() {}); // Refresh the UI
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _studyDeck() {
    final provider = context.read<FlashcardProvider>();
    final deckCards = provider.cards.where((card) => 
      card.deckIds.contains(widget.deck.id)
    ).toList();
    
    if (deckCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No cards in this deck to study')),
      );
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyView(
          cards: deckCards,
          studyMode: StudyMode.multipleChoice,
          title: 'Study ${widget.deck.name}',
        ),
      ),
    );
  }

  void _studySingleCard(FlashCard card) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyView(
          cards: [card],
          studyMode: StudyMode.lookCoverCheck,
          title: 'Study Card',
        ),
      ),
    );
  }

  void _exportDeck() {
    // TODO: Implement deck export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon!')),
    );
  }

  void _deleteDeck() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text(
          'Are you sure you want to delete "${widget.deck.name}"? '
          'This will also remove all cards in this deck.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final provider = context.read<FlashcardProvider>();
              await provider.deleteDeck(widget.deck.id);
              if (mounted) {
                navigator.pop();
                Navigator.of(context).pop(); // Go back to cards view
              }
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editCard(FlashCard card) {
    // TODO: Implement card editing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Card editing coming soon!')),
    );
  }

  void _deleteCard(FlashCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: Text(
          'Are you sure you want to delete "${card.word}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final provider = context.read<FlashcardProvider>();
              await provider.deleteCard(card.id);
              if (mounted) {
                navigator.pop();
                setState(() {}); // Refresh the list
              }
            },
            style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
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
                         Text('Learning Progress: ${((card.learningPercentage ?? 0) * 100).toInt()}%'),
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
              _studySingleCard(card);
            },
            child: const Text('Study This Card'),
          ),
        ],
      ),
    );
  }
} 