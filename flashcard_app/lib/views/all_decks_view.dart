import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/deck.dart';
import '../models/flash_card.dart';
import 'add_deck_view.dart';
import 'deck_detail_view.dart';
import 'add_card_view.dart';
import 'edit_deck_view.dart';

class AllDecksView extends StatefulWidget {
  const AllDecksView({super.key});

  @override
  State<AllDecksView> createState() => _AllDecksViewState();
}

class _AllDecksViewState extends State<AllDecksView> {
  String _searchText = '';
  String _sortOption = 'A-Z';
  bool _isSelectionMode = false;
  Set<String> _selectedDeckIds = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          SafeArea(
            child: _buildHeader(context),
          ),
          
          // Search and Sort Bar
          _buildSearchSortBar(),
          
          // Main content
          Expanded(
            child: Consumer<FlashcardProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildContent(context, provider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDeckDialog(context),
        tooltip: 'Add New Deck',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          const Spacer(),
          const Text(
            'All Decks',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_isSelectionMode)
            TextButton(
              onPressed: _cancelSelection,
              child: const Text('Cancel'),
            )
          else
            IconButton(
              onPressed: _toggleSelectionMode,
              icon: const Icon(Icons.select_all),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search decks...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _searchText = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sort Button
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _sortOption = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'A-Z',
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward),
                    SizedBox(width: 8),
                    Text('A-Z'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Z-A',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward),
                    SizedBox(width: 8),
                    Text('Z-A'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sortOption == 'A-Z' ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(_sortOption),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, FlashcardProvider provider) {
    final allDecks = provider.getAllDecksHierarchical();
    final filteredDecks = _filterDecks(allDecks);
    final sortedDecks = _sortDecks(filteredDecks);

    if (sortedDecks.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDecks.length,
      itemBuilder: (context, index) {
        final deck = sortedDecks[index];
        return _buildDeckCard(context, provider, deck);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Decks Found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchText.isNotEmpty
                ? 'Try adjusting your search terms'
                : 'Create your first deck to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          if (_searchText.isEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddDeckDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Deck'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeckCard(BuildContext context, FlashcardProvider provider, Deck deck) {
    final cards = provider.getCardsForDeck(deck.id);
    final subDecks = provider.getSubDecks(deck.id);
    final isSelected = _selectedDeckIds.contains(deck.id);
    
    // Debug: Print deck info
    print('🔍 AllDecksView: Deck "${deck.name}" (${deck.id}) has ${cards.length} cards');
    for (final card in cards) {
      print('🔍 AllDecksView:   - Card "${card.word}" has ${card.learningPercentage}% (timesShown: ${card.timesShown}, timesCorrect: ${card.timesCorrect})');
    }
    print('🔍 AllDecksView: Deck "${deck.name}" calculated percentage: ${deck.learningPercentage.round()}%');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _isSelectionMode ? () => _toggleDeckSelection(deck.id) : () => _openDeck(context, deck),
        onLongPress: () => _toggleSelectionMode(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_isSelectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) => _toggleDeckSelection(deck.id),
                  ),
                  const SizedBox(width: 8),
                ],
                // Indentation for sub-decks
                if (deck.isSubDeck) ...[
                  const SizedBox(width: 16),
                  Icon(
                    Icons.subdirectory_arrow_right,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                ],
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                                      child: Text(
                    '${Deck.calculateLearningPercentage(deck.name, cards).round()}%',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deck.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (deck.isSubDeck)
                        Text(
                          'Sub-deck',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        '${cards.length} cards',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!_isSelectionMode)
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleDeckMenuAction(context, deck, value),
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
                        value: 'add_card',
                        child: Row(
                          children: [
                            Icon(Icons.add_card),
                            SizedBox(width: 8),
                            Text('Add Card'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'add_subdeck',
                        child: Row(
                          children: [
                            Icon(Icons.create_new_folder),
                            SizedBox(width: 8),
                            Text('Add Sub-deck'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Deck> _filterDecks(List<Deck> decks) {
    if (_searchText.isEmpty) return decks;
    
    return decks.where((deck) =>
        deck.name.toLowerCase().contains(_searchText.toLowerCase())
    ).toList();
  }

  List<Deck> _sortDecks(List<Deck> decks) {
    final sorted = List<Deck>.from(decks);
    sorted.sort((a, b) {
      if (_sortOption == 'A-Z') {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });
    return sorted;
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedDeckIds.clear();
      }
    });
  }

  void _cancelSelection() {
    setState(() {
      _isSelectionMode = false;
      _selectedDeckIds.clear();
    });
  }

  void _toggleDeckSelection(String deckId) {
    setState(() {
      if (_selectedDeckIds.contains(deckId)) {
        _selectedDeckIds.remove(deckId);
      } else {
        _selectedDeckIds.add(deckId);
      }
    });
  }

  void _showAddDeckDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddDeckView(),
      ),
    );
  }

  void _openDeck(BuildContext context, Deck deck) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeckDetailView(deck: deck),
      ),
    );
  }

  void _handleDeckMenuAction(BuildContext context, Deck deck, String action) {
    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EditDeckView(deck: deck),
          ),
        );
        break;
      case 'add_card':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddCardView(selectedDeck: deck),
          ),
        );
        break;
      case 'add_subdeck':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AddDeckView(parentDeckId: deck.id),
          ),
        );
        break;
      case 'delete':
        _showDeleteDeckDialog(context, deck);
        break;
    }
  }

  void _showDeleteDeckDialog(BuildContext context, Deck deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text('Are you sure you want to delete "${deck.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FlashcardProvider>().deleteDeck(deck.id);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 