import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dutch_word_exercise.dart';
import '../providers/dutch_word_exercise_provider.dart';
import 'dutch_word_exercise_detail_view.dart';
import 'dutch_words_practice_view.dart';

class DutchWordsDeckView extends StatefulWidget {
  final String deckId;
  final String deckName;
  final List<DutchWordExercise> exercises;

  const DutchWordsDeckView({
    super.key,
    required this.deckId,
    required this.deckName,
    required this.exercises,
  });

  @override
  State<DutchWordsDeckView> createState() => _DutchWordsDeckViewState();
}

class _DutchWordsDeckViewState extends State<DutchWordsDeckView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _getFilteredExercises();

    // If no exercises in deck, show empty state
    if (widget.exercises.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.deckName),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deckName),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () {
              // TODO: Start practice mode for all words in deck
              _showPracticeModeDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search words in this deck...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Words list
          Expanded(
            child: filteredExercises.isEmpty
                ? _buildEmptyState()
                : _buildWordsList(filteredExercises),
          ),
        ],
      ),
    );
  }

  Widget _buildWordsList(List<DutchWordExercise> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                exercise.targetWord[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              exercise.targetWord,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exercise.wordTranslation),
                const SizedBox(height: 4),
                Text(
                  '${exercise.exercises.length} exercises',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteWordDialog(context, exercise),
                ),
                const Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DutchWordExerciseDetailView(
                    wordExercise: exercise,
                  ),
                ),
              );
            },
          ),
        );
      },
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
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No words found in this deck',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or add more words to this deck',
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

  List<DutchWordExercise> _getFilteredExercises() {
    if (_searchQuery.isEmpty) {
      return widget.exercises;
    }
    
    return widget.exercises.where((exercise) {
      return exercise.targetWord.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             exercise.wordTranslation.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _showDeleteWordDialog(BuildContext context, DutchWordExercise exercise) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Word'),
        content: Text(
          'Are you sure you want to delete "${exercise.targetWord}"?\n\n'
          'This will permanently delete ${exercise.exercises.length} exercises.\n\n'
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
              _deleteWord(exercise);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteWord(DutchWordExercise exercise) {
    final provider = context.read<DutchWordExerciseProvider>();
    provider.deleteWordExercise(exercise.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${exercise.targetWord}" deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPracticeModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Practice Mode'),
        content: Text('Practice all ${widget.exercises.length} words in "${widget.deckName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DutchWordsPracticeView(
                    deckId: widget.deckId,
                    deckName: widget.deckName,
                    exercises: widget.exercises,
                  ),
                ),
              );
            },
            child: const Text('Start Practice'),
          ),
        ],
      ),
    );
  }
} 