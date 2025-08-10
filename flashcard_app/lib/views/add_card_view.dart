import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../components/unified_header.dart';
import '../models/deck.dart';

class AddCardView extends StatefulWidget {
  final Deck? selectedDeck;
  
  const AddCardView({
    super.key,
    this.selectedDeck,
  });

  @override
  State<AddCardView> createState() => _AddCardViewState();
}

class _AddCardViewState extends State<AddCardView> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  final _pluralController = TextEditingController();
  final _pastTenseController = TextEditingController();
  final _futureTenseController = TextEditingController();
  final _pastParticipleController = TextEditingController();
  
  String _selectedArticle = '';
  List<String> _selectedDeckIds = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedDeck != null) {
      _selectedDeckIds = [widget.selectedDeck!.id];
    }
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _pluralController.dispose();
    _pastTenseController.dispose();
    _futureTenseController.dispose();
    _pastParticipleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header
          UnifiedHeader(
            title: 'Add Card',
            onBack: () => Navigator.of(context).pop(),
          ),
          
          // Form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    
                    // Dutch Word
                    TextFormField(
                      controller: _wordController,
                      decoration: const InputDecoration(
                        labelText: 'Dutch Word *',
                        hintText: 'e.g., huis',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_fields),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a Dutch word';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Article Selection
                    _buildArticleSelector(),
                    const SizedBox(height: 16),
                    
                    // English Definition
                    TextFormField(
                      controller: _definitionController,
                      decoration: const InputDecoration(
                        labelText: 'English Definition *',
                        hintText: 'e.g., house',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.translate),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an English definition';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Example Sentence
                    TextFormField(
                      controller: _exampleController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Example Sentence',
                        hintText: 'e.g., Ik woon in een groot huis.',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.format_quote),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Grammar Section
                    _buildSectionHeader('Grammar'),
                    const SizedBox(height: 16),
                    
                    // Plural Form
                    TextFormField(
                      controller: _pluralController,
                      decoration: const InputDecoration(
                        labelText: 'Plural Form',
                        hintText: 'e.g., huizen',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.list),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Verb Forms (if applicable)
                    _buildVerbForms(),
                    const SizedBox(height: 24),
                    
                    // Deck Selection
                    _buildSectionHeader('Deck Assignment'),
                    const SizedBox(height: 16),
                    
                    _buildDeckSelection(),
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitCard,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Add Card',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildArticleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Article (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildArticleOption('de', 'De (masculine/feminine)'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildArticleOption('het', 'Het (neuter)'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArticleOption(String article, String label) {
    final isSelected = _selectedArticle == article;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedArticle = article;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary 
                : Theme.of(context).colorScheme.outline,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : null,
        ),
        child: Column(
          children: [
            Text(
              article.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary 
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerbForms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verb Forms (if applicable)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _pastTenseController,
                decoration: const InputDecoration(
                  labelText: 'Past Tense',
                  hintText: 'e.g., woonde',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _futureTenseController,
                decoration: const InputDecoration(
                  labelText: 'Future Tense',
                  hintText: 'e.g., zal wonen',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pastParticipleController,
          decoration: const InputDecoration(
            labelText: 'Past Participle',
            hintText: 'e.g., gewoond',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDeckSelection() {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        final decks = provider.getAllDecksHierarchical();
        
        if (decks.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.folder_open, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text(
                  'No decks available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _createNewDeck(context),
                  child: const Text('Create New Deck'),
                ),
              ],
            ),
          );
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Decks:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...decks.map((deck) => _buildDeckCheckbox(deck)),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _createNewDeck(context),
              icon: const Icon(Icons.add),
              label: const Text('Create New Deck'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDeckCheckbox(Deck deck) {
    final isSelected = _selectedDeckIds.contains(deck.id);
    
    return CheckboxListTile(
      title: Row(
        children: [
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
          Expanded(
            child: Text(deck.name),
          ),
        ],
      ),
      subtitle: Consumer<FlashcardProvider>(
        builder: (context, provider, child) {
          final cardCount = provider.cards.where((card) => card.deckIds.contains(deck.id)).length;
          return Text('$cardCount cards');
        },
      ),
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedDeckIds.add(deck.id);
          } else {
            _selectedDeckIds.remove(deck.id);
          }
        });
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  void _createNewDeck(BuildContext context) {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Deck'),
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
                final newDeck = await provider.createDeck(nameController.text.trim());
                if (mounted && newDeck != null) {
                  setState(() {
                    _selectedDeckIds.add(newDeck.id);
                  });
                  navigator.pop();
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _submitCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    

    
    if (_selectedDeckIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one deck')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final provider = context.read<FlashcardProvider>();
      await provider.createCard(
        word: _wordController.text.trim(),
        definition: _definitionController.text.trim(),
        example: _exampleController.text.trim(),
        article: _selectedArticle,
        plural: _pluralController.text.trim(),
        pastTense: _pastTenseController.text.trim(),
        futureTense: _futureTenseController.text.trim(),
        pastParticiple: _pastParticipleController.text.trim(),
        deckIds: _selectedDeckIds.toSet(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card added successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding card: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
} 