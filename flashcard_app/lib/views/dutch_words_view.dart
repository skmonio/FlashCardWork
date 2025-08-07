import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dutch_word_exercise_provider.dart';
import '../models/dutch_word_exercise.dart';
import 'dutch_word_exercise_detail_view.dart';
import 'dutch_words_deck_view.dart';
import 'create_word_exercise_view.dart';
import 'import_word_exercises_view.dart';
import 'export_word_exercises_view.dart';

class DutchWordsView extends StatefulWidget {
  const DutchWordsView({super.key});

  @override
  State<DutchWordsView> createState() => _DutchWordsViewState();
}

class _DutchWordsViewState extends State<DutchWordsView> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DutchWordExerciseProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dutch Words'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,

      ),
      body: Consumer<DutchWordExerciseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${provider.error}'),
                  ElevatedButton(
                    onPressed: () => provider.clearError(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredExercises = _getFilteredExercises(provider);

          return Column(
            children: [
              // Search and filter section
              _buildSearchAndFilterSection(),
              
              // Action buttons
              _buildActionButtons(),
              
              // Statistics cards removed
              
              // Exercises list
              Expanded(
                child: filteredExercises.isEmpty
                    ? _buildEmptyState()
                    : _buildExercisesList(filteredExercises),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search words...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          

        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateWordExerciseView(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImportWordExercisesView(
                      onImportComplete: () {
                        // Refresh the view when import is complete
                        setState(() {});
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.file_upload),
              label: const Text('Import'),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ExportWordExercisesView(),
                  ),
                );
              },
              icon: const Icon(Icons.file_download),
              label: const Text('Export'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(DutchWordExerciseProvider provider) {
    // Removed statistics cards as requested
    return const SizedBox.shrink();
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(List<DutchWordExercise> exercises) {
    // Group exercises by deck
    final Map<String, List<DutchWordExercise>> deckGroups = {};
    for (final exercise in exercises) {
      if (!deckGroups.containsKey(exercise.deckId)) {
        deckGroups[exercise.deckId] = [];
      }
      deckGroups[exercise.deckId]!.add(exercise);
    }

    final deckIds = deckGroups.keys.toList()..sort();
    
    // Filter out empty decks
    final nonEmptyDeckIds = deckIds.where((deckId) => deckGroups[deckId]!.isNotEmpty).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: nonEmptyDeckIds.length,
      itemBuilder: (context, index) {
        final deckId = nonEmptyDeckIds[index];
        final deckExercises = deckGroups[deckId]!;
        final deckName = deckExercises.first.deckName;
        final totalExercises = deckExercises.fold<int>(0, (sum, exercise) => sum + exercise.exercises.length);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.folder,
                color: Colors.blue[700],
                size: 24,
              ),
            ),
            title: Text(
              deckName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${deckExercises.length} words • $totalExercises exercises',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDeckDialog(context, deckId, deckName, deckExercises),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DutchWordsDeckView(
                    deckId: deckId,
                    deckName: deckName,
                    exercises: deckExercises,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteDeckDialog(BuildContext context, String deckId, String deckName, List<DutchWordExercise> deckExercises) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text(
          'Are you sure you want to delete the deck "$deckName"?\n\n'
          'This will permanently delete ${deckExercises.length} words and ${deckExercises.fold<int>(0, (sum, exercise) => sum + exercise.exercises.length)} exercises.\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDeck(deckId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteDeck(String deckId) {
    final provider = context.read<DutchWordExerciseProvider>();
    final exercisesToDelete = provider.getExercisesByDeck(deckId);
    
    for (final exercise in exercisesToDelete) {
      provider.deleteWordExercise(exercise.id);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deck deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.text_fields,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No word exercises found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first word exercise or import some examples',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<DutchWordExercise> _getFilteredExercises(DutchWordExerciseProvider provider) {
    return provider.searchWordExercises(_searchQuery);
  }

  Color _getCategoryColor(WordCategory category) {
    switch (category) {
      case WordCategory.common:
        return Colors.blue;
      case WordCategory.business:
        return Colors.green;
      case WordCategory.academic:
        return Colors.purple;
      case WordCategory.casual:
        return Colors.orange;
      case WordCategory.formal:
        return Colors.indigo;
      case WordCategory.technical:
        return Colors.red;
      case WordCategory.cultural:
        return Colors.teal;
      case WordCategory.other:
        return Colors.grey;
    }
  }

  Color _getDifficultyColor(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return Colors.green;
      case ExerciseDifficulty.intermediate:
        return Colors.orange;
      case ExerciseDifficulty.advanced:
        return Colors.red;
    }
  }
} 