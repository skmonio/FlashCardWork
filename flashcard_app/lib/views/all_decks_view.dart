import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/dutch_word_exercise_provider.dart';
import '../models/deck.dart';
import '../models/flash_card.dart';
import '../models/dutch_word_exercise.dart';
import 'add_deck_view.dart';
import 'deck_detail_view.dart';
import 'add_card_view.dart';
import 'edit_deck_view.dart';
import 'dutch_words_practice_view.dart';

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
    // For parent decks, get cards including sub-decks; for sub-decks, get only their own cards
    final cards = deck.isSubDeck 
        ? provider.getCardsForDeck(deck.id)
        : provider.getCardsForDeckWithSubDecks(deck.id);
    final subDecks = provider.getSubDecks(deck.id);
    final isSelected = _selectedDeckIds.contains(deck.id);
    
    // Debug: Print deck info
    print('🔍 AllDecksView: Deck "${deck.name}" (${deck.id}) has ${cards.length} cards (${deck.isSubDeck ? 'sub-deck' : 'parent deck'})');
    for (final card in cards) {
      print('🔍 AllDecksView:   - Card "${card.word}" has ${card.learningPercentage}% (timesShown: ${card.timesShown}, timesCorrect: ${card.timesCorrect})');
    }
    print('🔍 AllDecksView: Deck "${deck.name}" calculated percentage: ${Deck.calculateLearningPercentage(deck.name, cards).round()}%');
    
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
                      Consumer<DutchWordExerciseProvider>(
                        builder: (context, dutchProvider, child) {
                          int totalExercises = 0;
                          for (final card in cards) {
                            final exercise = dutchProvider.getWordExerciseByWord(card.word);
                            totalExercises += exercise?.exercises.length ?? 0;
                          }
                          
                          if (totalExercises > 0) {
                            return Text(
                              '$totalExercises exercise${totalExercises == 1 ? '' : 's'}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green[600],
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
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
                        value: 'study',
                        child: Row(
                          children: [
                            Icon(Icons.quiz, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Study This Deck', style: TextStyle(color: Colors.green)),
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
    final provider = context.read<FlashcardProvider>();
    
    // Separate parent and child decks
    final parentDecks = decks.where((deck) => deck.parentId == null).toList();
    final childDecks = decks.where((deck) => deck.parentId != null).toList();
    
    // Sort parent decks
    parentDecks.sort((a, b) {
      if (_sortOption == 'A-Z') {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });
    
    // Sort child decks within each parent
    childDecks.sort((a, b) {
      // First sort by parent deck name
      final parentA = provider.getDeck(a.parentId!);
      final parentB = provider.getDeck(b.parentId!);
      
      if (parentA != null && parentB != null) {
        final parentComparison = _sortOption == 'A-Z' 
            ? parentA.name.toLowerCase().compareTo(parentB.name.toLowerCase())
            : parentB.name.toLowerCase().compareTo(parentA.name.toLowerCase());
        
        if (parentComparison != 0) {
          return parentComparison;
        }
      }
      
      // Then sort by child deck name
      if (_sortOption == 'A-Z') {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      } else {
        return b.name.toLowerCase().compareTo(a.name.toLowerCase());
      }
    });
    
    // Combine parent and child decks in hierarchical order
    final result = <Deck>[];
    
    // Add parent decks and their children in hierarchical order
    for (final parentDeck in parentDecks) {
      // Add the parent deck
      result.add(parentDeck);
      
      // Add all children of this parent deck immediately after
      final children = childDecks.where((child) => child.parentId == parentDeck.id).toList();
      result.addAll(children);
    }
    
    return result;
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
      case 'study':
        _studyDeck(context, deck);
        break;
      case 'delete':
        _showDeleteDeckDialog(context, deck);
        break;
    }
  }

  void _studyDeck(BuildContext context, Deck deck) {
    // Get all cards in this deck including sub-decks for parent decks
    final provider = context.read<FlashcardProvider>();
    final dutchProvider = context.read<DutchWordExerciseProvider>();
    final deckCards = deck.isSubDeck 
        ? provider.getCardsForDeck(deck.id)
        : provider.getCardsForDeckWithSubDecks(deck.id);
    
    if (deckCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No cards in "${deck.name}"${deck.isSubDeck ? '' : ' or its sub-decks'} to study!')),
      );
      return;
    }
    
    // Create Dutch word exercises from the deck cards, checking for existing exercises first
    final exercises = deckCards.map((card) {
      // Check if there's already an existing exercise for this card
      final existingExercise = dutchProvider.getWordExerciseByWord(card.word);
      
      if (existingExercise != null) {
        // Use existing exercise if found
        print('🔍 AllDecksView: Found existing exercise for "${card.word}" with ${existingExercise.exercises.length} exercises');
        return existingExercise;
      } else {
        // Create a new exercise if none exists
        print('🔍 AllDecksView: Created new exercise for "${card.word}" with 1 exercise');
        return DutchWordExercise(
          id: card.id,
          targetWord: card.word,
          wordTranslation: card.definition,
          deckId: deck.id,
          deckName: deck.name,
          category: WordCategory.common,
          difficulty: ExerciseDifficulty.beginner,
          exercises: [
            WordExercise(
              id: '${card.id}_exercise_1',
              type: ExerciseType.translation,
              prompt: 'Translate "${card.word}" to English',
              correctAnswer: card.definition,
              options: [card.definition, 'Incorrect option 1', 'Incorrect option 2', 'Incorrect option 3'],
              explanation: 'The Dutch word "${card.word}" means "${card.definition}" in English.',
              difficulty: ExerciseDifficulty.beginner,
            ),
          ],
          createdAt: card.dateCreated,
          isUserCreated: true,
        );
      }
    }).toList();
    
    // Navigate to the Dutch words practice view
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DutchWordsPracticeView(
          deckId: deck.id,
          deckName: deck.name,
          exercises: exercises,
        ),
      ),
    );
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