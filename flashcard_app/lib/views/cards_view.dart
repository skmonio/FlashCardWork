import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/deck.dart';
import '../models/flash_card.dart';
import 'add_card_view.dart';
import 'add_deck_view.dart';
import 'deck_detail_view.dart';
import 'all_cards_view.dart';

class CardsView extends StatefulWidget {
  const CardsView({super.key});

  @override
  State<CardsView> createState() => _CardsViewState();
}

class _CardsViewState extends State<CardsView> {
  bool _showingAddCardView = false;
  bool _showingAddDeckView = false;
  bool _showingCardsInfoView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          _buildHeader(context),
          
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
        onPressed: () => _showAddCardDialog(context),
        tooltip: 'Add New Card',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Profile button placeholder
          const SizedBox(width: 48),
          const Spacer(),
          // Title
          const Text(
            'Cards & Decks',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // How to Add Cards button
          TextButton(
            onPressed: () => _showCardsInfo(context),
            child: const Text(
              'Help',
              style: TextStyle(fontSize: 12, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, FlashcardProvider provider) {
    final rootDecks = provider.getRootDecks();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildQuickActionsSection(context),
          const SizedBox(height: 24),
          
          // All Cards Section
          _buildAllCardsSection(context, provider),
          const SizedBox(height: 24),
          
          // Decks Section
          _buildDecksSection(context, provider, rootDecks),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCardDialog(context),
                    icon: const Icon(Icons.add_card),
                    label: const Text('Add Card'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddDeckDialog(context),
                    icon: const Icon(Icons.folder),
                    label: const Text('Create Deck'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCardsSection(BuildContext context, FlashcardProvider provider) {
    final allCards = provider.cards;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Cards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${allCards.length} cards',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (allCards.isEmpty)
              _buildEmptyCardsState(context)
            else
              _buildAllCardsPreview(context, provider, allCards),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCardsState(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.credit_card,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'No cards yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add your first card to get started',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildAllCardsPreview(BuildContext context, FlashcardProvider provider, List<FlashCard> allCards) {
    final previewCards = allCards.take(3).toList();
    
    return Column(
      children: [
        ...previewCards.map((card) => _buildCardPreviewItem(card)),
        if (allCards.length > 3) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _viewAllCards(context),
              child: Text('View All ${allCards.length} Cards'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardPreviewItem(FlashCard card) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Text(
          card.word.isNotEmpty ? card.word[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        card.word,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        card.definition,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        'SRS ${card.srsLevel}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  void _viewAllCards(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AllCardsView(),
      ),
    );
  }

  Widget _buildDecksSection(BuildContext context, FlashcardProvider provider, List<Deck> rootDecks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Decks',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () => _showAddDeckDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('New Deck'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (rootDecks.isEmpty)
          _buildEmptyDecksState(context)
        else
          _buildDecksList(context, provider, rootDecks),
      ],
    );
  }

  Widget _buildEmptyDecksState(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Decks Yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first deck to start organizing your flashcards',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddDeckDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create First Deck'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecksList(BuildContext context, FlashcardProvider provider, List<Deck> decks) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: decks.length,
      itemBuilder: (context, index) {
        final deck = decks[index];
        return _buildDeckCard(context, provider, deck);
      },
    );
  }

  Widget _buildDeckCard(BuildContext context, FlashcardProvider provider, Deck deck) {
    final cards = provider.getCardsForDeck(deck.id);
    final subDecks = provider.getSubDecks(deck.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openDeck(context, deck),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.folder,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
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
                      ],
                    ),
                  ),
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
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatChip(
                    context,
                    Icons.style,
                    '${cards.length} cards',
                    Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.folder,
                    '${subDecks.length} sub-decks',
                    Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    Icons.school,
                    '${deck.learningPercentage.toStringAsFixed(0)}% learned',
                    Colors.orange,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddCardView(),
      ),
    );
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
        // TODO: Implement edit deck
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

  void _showCardsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Add Cards'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Tap the + button to add a new card'),
            SizedBox(height: 8),
            Text('2. Fill in the word and definition'),
            SizedBox(height: 8),
            Text('3. Select which deck(s) to add it to'),
            SizedBox(height: 8),
            Text('4. Add optional details like examples'),
            SizedBox(height: 8),
            Text('5. Tap "Create Card" to save'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
} 