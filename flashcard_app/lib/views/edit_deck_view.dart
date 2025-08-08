import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../components/unified_header.dart';
import '../models/deck.dart';

class EditDeckView extends StatefulWidget {
  final Deck deck;
  
  const EditDeckView({
    super.key,
    required this.deck,
  });

  @override
  State<EditDeckView> createState() => _EditDeckViewState();
}

class _EditDeckViewState extends State<EditDeckView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedParentDeckId = '';
  bool _isSubDeck = false;

  @override
  void initState() {
    super.initState();
    // Pre-populate the form with existing deck data
    _nameController.text = widget.deck.name;
    _selectedParentDeckId = widget.deck.parentId ?? '';
    _isSubDeck = widget.deck.parentId != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          UnifiedHeader(
            title: 'Edit Deck',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBasicInfoSection(),
                    const SizedBox(height: 24),
                    _buildParentDeckSection(),
                    const SizedBox(height: 24),
                    _buildActionsSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Deck Name *',
                hintText: 'Enter deck name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a deck name';
                }
                return null;
              },
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildParentDeckSection() {
    return Consumer<FlashcardProvider>(
      builder: (context, provider, child) {
        final rootDecks = provider.decks.where((deck) => deck.parentId == null && deck.id != widget.deck.id).toList();
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deck Organization',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Make this a sub-deck'),
                  subtitle: const Text('Organize under another deck'),
                  value: _isSubDeck,
                  onChanged: (value) {
                    setState(() {
                      _isSubDeck = value ?? false;
                      if (!_isSubDeck) {
                        _selectedParentDeckId = '';
                      }
                    });
                  },
                ),
                if (_isSubDeck) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedParentDeckId.isEmpty ? null : _selectedParentDeckId,
                    decoration: const InputDecoration(
                      labelText: 'Parent Deck *',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Select a parent deck'),
                      ),
                      ...rootDecks.map((deck) => DropdownMenuItem(
                        value: deck.id,
                        child: Text(deck.name),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedParentDeckId = value ?? '';
                      });
                    },
                    validator: _isSubDeck ? (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a parent deck';
                      }
                      return null;
                    } : null,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionsSection() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _updateDeck,
            child: const Text('Update Deck'),
          ),
        ),
      ],
    );
  }

  void _updateDeck() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<FlashcardProvider>();
    final deckName = _nameController.text.trim();
    final parentId = _isSubDeck ? _selectedParentDeckId : null;

    // Create updated deck
    final updatedDeck = Deck(
      id: widget.deck.id,
      name: deckName,
      cards: widget.deck.cards,
      parentId: parentId,
      subDeckIds: widget.deck.subDeckIds,
      dateCreated: widget.deck.dateCreated,
      lastModified: DateTime.now(),
      cloudKitRecordName: widget.deck.cloudKitRecordName,
    );

    // Update the deck
    provider.updateDeck(updatedDeck);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deck "$deckName" updated successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }
} 