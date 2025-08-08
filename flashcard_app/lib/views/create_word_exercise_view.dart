import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/dutch_word_exercise.dart';
import '../providers/dutch_word_exercise_provider.dart';
import '../providers/flashcard_provider.dart';

class CreateWordExerciseView extends StatefulWidget {
  final DutchWordExercise? editingExercise;
  
  const CreateWordExerciseView({
    super.key,
    this.editingExercise,
  });

  @override
  State<CreateWordExerciseView> createState() => _CreateWordExerciseViewState();
}

class _CreateWordExerciseViewState extends State<CreateWordExerciseView> {
  final _formKey = GlobalKey<FormState>();
  final _targetWordController = TextEditingController();
  final _translationController = TextEditingController();
  final _deckNameController = TextEditingController();
  String? _selectedDeckId;
  bool _isCreatingNewDeck = false;
  bool _isPickingExistingWord = false;
  String? _selectedWordId;
  
  final List<WordExercise> _exercises = [];
  final List<TextEditingController> _promptControllers = [];
  final List<List<TextEditingController>> _optionControllers = [];
  final List<TextEditingController> _correctAnswerControllers = [];
  final List<TextEditingController> _explanationControllers = [];
  final List<ExerciseType> _exerciseTypes = [];

  @override
  void initState() {
    super.initState();
    
    if (widget.editingExercise != null) {
      _loadExerciseForEditing();
    } else {
      _addExercise(); // Start with one exercise
    }
  }

  @override
  void dispose() {
    _targetWordController.dispose();
    _translationController.dispose();
    _deckNameController.dispose();
    for (final controller in _promptControllers) {
      controller.dispose();
    }
    for (final optionList in _optionControllers) {
      for (final controller in optionList) {
        controller.dispose();
      }
    }
    for (final controller in _correctAnswerControllers) {
      controller.dispose();
    }
    for (final controller in _explanationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingExercise != null ? 'Edit Word Exercise' : 'Create Word Exercise'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveExercise,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word information
              _buildWordInfoSection(),
              
              const SizedBox(height: 24),
              
              // Exercises section
              _buildExercisesSection(),
              
              const SizedBox(height: 24),
              
              // Add exercise button
              _buildAddExerciseButton(),
              
              const SizedBox(height: 24),
              
              // Save button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Word Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Word selection options
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Enter New Word'),
                    value: false,
                    groupValue: _isPickingExistingWord,
                    onChanged: (value) {
                      setState(() {
                        _isPickingExistingWord = false;
                        _selectedWordId = null;
                        _targetWordController.clear();
                        _translationController.clear();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Pick Existing Word'),
                    value: true,
                    groupValue: _isPickingExistingWord,
                    onChanged: (value) {
                      setState(() {
                        _isPickingExistingWord = true;
                        _targetWordController.clear();
                        _translationController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (!_isPickingExistingWord) ...[
              // Target word
              TextFormField(
                controller: _targetWordController,
                decoration: const InputDecoration(
                  labelText: 'Dutch Word',
                  hintText: 'e.g., terecht',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Dutch word';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Translation
              TextFormField(
                controller: _translationController,
                decoration: const InputDecoration(
                  labelText: 'Translation',
                  hintText: 'e.g., justified',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a translation';
                  }
                  return null;
                },
              ),
            ] else ...[
              // Existing word selection
              Consumer<FlashcardProvider>(
                builder: (context, flashcardProvider, child) {
                  final cards = flashcardProvider.cards;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Existing Word',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ListView.builder(
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            final isSelected = _selectedWordId == card.id;
                            
                            return ListTile(
                              title: Text(card.word),
                              subtitle: Text(card.definition),
                              trailing: isSelected 
                                ? const Icon(Icons.check, color: Colors.green)
                                : null,
                              onTap: () {
                                setState(() {
                                  _selectedWordId = card.id;
                                  _targetWordController.text = card.word;
                                  _translationController.text = card.definition;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Deck selection
            _buildDeckSelectionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckSelectionSection() {
    return Consumer<DutchWordExerciseProvider>(
      builder: (context, provider, child) {
        final existingDecks = provider.getDeckNames();
        final deckIds = provider.getDecks();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deck',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            
            // Deck selection options
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Select Existing Deck'),
                    value: 'existing',
                    groupValue: _isCreatingNewDeck ? 'new' : 'existing',
                    onChanged: (value) {
                      setState(() {
                        _isCreatingNewDeck = false;
                        _selectedDeckId = null;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Create New Deck'),
                    value: 'new',
                    groupValue: _isCreatingNewDeck ? 'new' : 'existing',
                    onChanged: (value) {
                      setState(() {
                        _isCreatingNewDeck = true;
                        _selectedDeckId = null;
                        _deckNameController.clear();
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Existing deck dropdown or new deck input
            if (!_isCreatingNewDeck) ...[
              if (existingDecks.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedDeckId,
                  decoration: const InputDecoration(
                    labelText: 'Choose Deck',
                    border: OutlineInputBorder(),
                  ),
                  items: deckIds.map((deckId) {
                    return DropdownMenuItem(
                      value: deckId,
                      child: Text(existingDecks[deckId] ?? deckId),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDeckId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a deck';
                    }
                    return null;
                  },
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No existing decks found. Please create a new deck.',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              TextFormField(
                controller: _deckNameController,
                decoration: const InputDecoration(
                  labelText: 'New Deck Name',
                  hintText: 'e.g., Common Words, Business Terms',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a deck name';
                  }
                  return null;
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Exercises',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_exercises.length} exercises',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Exercise list
        ...List.generate(_exercises.length, (index) {
          return _buildExerciseCard(index);
        }),
      ],
    );
  }

  Widget _buildExerciseCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Exercise ${index + 1}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExercise(index),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Exercise type
            DropdownButtonFormField<ExerciseType>(
              value: _exerciseTypes[index],
              decoration: const InputDecoration(
                labelText: 'Exercise Type',
                border: OutlineInputBorder(),
              ),
              items: ExerciseType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_getExerciseTypeName(type)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _exerciseTypes[index] = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Prompt
            TextFormField(
              controller: _promptControllers[index],
              decoration: const InputDecoration(
                labelText: 'Prompt/Question',
                hintText: 'Enter the question or prompt',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a prompt';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Options (for multiple choice and fill in blank)
            if (_exerciseTypes[index] == ExerciseType.multipleChoice ||
                _exerciseTypes[index] == ExerciseType.fillInBlank)
              _buildOptionsSection(index),
            
            // Sentence building preview
            if (_exerciseTypes[index] == ExerciseType.sentenceBuilding)
              _buildSentenceBuildingPreview(index),
            
            const SizedBox(height: 16),
            
            // Correct answer
            TextFormField(
              controller: _correctAnswerControllers[index],
              decoration: const InputDecoration(
                labelText: 'Correct Answer',
                hintText: 'Enter the correct answer',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the correct answer';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Explanation
            TextFormField(
              controller: _explanationControllers[index],
              decoration: const InputDecoration(
                labelText: 'Explanation',
                hintText: 'Explain why this is correct',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an explanation';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsSection(int exerciseIndex) {
    final options = _optionControllers[exerciseIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextButton.icon(
              onPressed: () => _addOption(exerciseIndex),
              icon: const Icon(Icons.add),
              label: const Text('Add Option'),
            ),
          ],
        ),
        
        ...List.generate(options.length, (optionIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: options[optionIndex],
                    decoration: InputDecoration(
                      labelText: 'Option ${optionIndex + 1}',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an option';
                      }
                      return null;
                    },
                  ),
                ),
                if (options.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove, color: Colors.red),
                    onPressed: () => _removeOption(exerciseIndex, optionIndex),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSentenceBuildingPreview(int exerciseIndex) {
    final correctAnswer = _correctAnswerControllers[exerciseIndex].text;
    final words = correctAnswer.split(' ').where((word) => word.isNotEmpty).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Word Options (Auto-generated from correct answer)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (words.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Correct Answer: "$correctAnswer"',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Words will be: ${words.map((word) => '"$word"').join(', ')}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: const Text(
              'Enter a correct answer to see the word options',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddExerciseButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _addExercise,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _saveExercise,
        icon: const Icon(Icons.save),
        label: const Text('Save Word Exercise'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _addExercise() {
    setState(() {
      _exercises.add(WordExercise(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: ExerciseType.multipleChoice,
        prompt: '',
        options: ['', '', '', ''],
        correctAnswer: '',
        explanation: '',
        difficulty: ExerciseDifficulty.beginner,
      ));
      
      _promptControllers.add(TextEditingController());
      _correctAnswerControllers.add(TextEditingController());
      _explanationControllers.add(TextEditingController());
      _exerciseTypes.add(ExerciseType.multipleChoice);
      
      // Add option controllers
      final optionControllers = <TextEditingController>[];
      for (int i = 0; i < 4; i++) {
        optionControllers.add(TextEditingController());
      }
      _optionControllers.add(optionControllers);
    });
  }

  void _removeExercise(int index) {
    if (_exercises.length > 1) {
      setState(() {
        _exercises.removeAt(index);
        _promptControllers[index].dispose();
        _promptControllers.removeAt(index);
        _correctAnswerControllers[index].dispose();
        _correctAnswerControllers.removeAt(index);
        _explanationControllers[index].dispose();
        _explanationControllers.removeAt(index);
        _exerciseTypes.removeAt(index);
        
        // Dispose option controllers
        for (final controller in _optionControllers[index]) {
          controller.dispose();
        }
        _optionControllers.removeAt(index);
      });
    }
  }

  void _addOption(int exerciseIndex) {
    setState(() {
      _optionControllers[exerciseIndex].add(TextEditingController());
    });
  }

  void _removeOption(int exerciseIndex, int optionIndex) {
    if (_optionControllers[exerciseIndex].length > 2) {
      setState(() {
        _optionControllers[exerciseIndex][optionIndex].dispose();
        _optionControllers[exerciseIndex].removeAt(optionIndex);
      });
    }
  }

  void _saveExercise() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate word selection
    if (_isPickingExistingWord && _selectedWordId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an existing word'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_isPickingExistingWord && (_targetWordController.text.isEmpty || _translationController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Dutch word and translation'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Build exercises from form data
    final exercises = <WordExercise>[];
    
    for (int i = 0; i < _exercises.length; i++) {
      List<String> options;
      
      if (_exerciseTypes[i] == ExerciseType.sentenceBuilding) {
        // For sentence building, split the correct answer into individual words
        final correctAnswer = _correctAnswerControllers[i].text;
        options = correctAnswer.split(' ').where((word) => word.isNotEmpty).toList();
      } else {
        // For other exercise types, use the options from the form
        options = _optionControllers[i].map((c) => c.text).toList();
      }
      
      exercises.add(WordExercise(
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
        type: _exerciseTypes[i],
        prompt: _promptControllers[i].text,
        options: options,
        correctAnswer: _correctAnswerControllers[i].text,
        explanation: _explanationControllers[i].text,
        difficulty: ExerciseDifficulty.beginner,
      ));
    }

    // Determine deck information
    String deckId;
    String deckName;
    
    if (_isCreatingNewDeck) {
      deckId = _deckNameController.text.toLowerCase().replaceAll(' ', '_');
      deckName = _deckNameController.text;
    } else {
      final provider = context.read<DutchWordExerciseProvider>();
      final existingDecks = provider.getDeckNames();
      deckId = _selectedDeckId!;
      deckName = existingDecks[deckId] ?? deckId;
    }

    // Create or update the word exercise
    final wordExercise = DutchWordExercise(
      id: widget.editingExercise?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      targetWord: _targetWordController.text,
      wordTranslation: _translationController.text,
      deckId: deckId,
      deckName: deckName,
      category: WordCategory.common, // Default category
      difficulty: ExerciseDifficulty.beginner, // Default difficulty
      exercises: exercises,
      createdAt: widget.editingExercise?.createdAt ?? DateTime.now(),
    );

    // Save to provider
    final provider = context.read<DutchWordExerciseProvider>();
    if (widget.editingExercise != null) {
      provider.updateWordExercise(wordExercise);
    } else {
      provider.addWordExercise(wordExercise);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Word exercise "${wordExercise.targetWord}" ${widget.editingExercise != null ? 'updated' : 'created'} successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.of(context).pop();
  }

  void _loadExerciseForEditing() {
    final exercise = widget.editingExercise!;
    
    // Set word information
    _targetWordController.text = exercise.targetWord;
    _translationController.text = exercise.wordTranslation;
    _deckNameController.text = exercise.deckName;
    _selectedDeckId = exercise.deckId;
    _isCreatingNewDeck = false;
    
    // Clear existing exercises
    _exercises.clear();
    _promptControllers.clear();
    _optionControllers.clear();
    _correctAnswerControllers.clear();
    _explanationControllers.clear();
    _exerciseTypes.clear();
    
    // Load exercises
    for (final wordExercise in exercise.exercises) {
      _exercises.add(wordExercise);
      _promptControllers.add(TextEditingController(text: wordExercise.prompt));
      _correctAnswerControllers.add(TextEditingController(text: wordExercise.correctAnswer));
      _explanationControllers.add(TextEditingController(text: wordExercise.explanation));
      _exerciseTypes.add(wordExercise.type);
      
      // Add option controllers
      final optionControllers = <TextEditingController>[];
      for (final option in wordExercise.options) {
        optionControllers.add(TextEditingController(text: option));
      }
      _optionControllers.add(optionControllers);
    }
  }

  String _getExerciseTypeName(ExerciseType type) {
    switch (type) {
      case ExerciseType.fillInBlank:
        return 'Fill in the Blank';
      case ExerciseType.missingWord:
        return 'Missing Word';
      case ExerciseType.matchMeaning:
        return 'Match Meaning';
      case ExerciseType.useInSentence:
        return 'Use in Sentence';
      case ExerciseType.sentenceBuilding:
        return 'Sentence Building';
      case ExerciseType.multipleChoice:
        return 'Multiple Choice';
      case ExerciseType.trueFalse:
        return 'True/False';
      case ExerciseType.wordOrder:
        return 'Word Order';
      case ExerciseType.translation:
        return 'Translation';
      case ExerciseType.contextClue:
        return 'Context Clue';
    }
  }
} 