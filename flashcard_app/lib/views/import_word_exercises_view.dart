import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import '../providers/dutch_word_exercise_provider.dart';
import 'dart:io' show Platform;

class ImportWordExercisesView extends StatefulWidget {
  const ImportWordExercisesView({super.key});

  @override
  State<ImportWordExercisesView> createState() => _ImportWordExercisesViewState();
}

class _ImportWordExercisesViewState extends State<ImportWordExercisesView> {
  bool _isImporting = false;
  String? _selectedFileName;
  String? _error;
  String? _successMessage;
  Map<String, dynamic>? _importData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Word Exercises'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Import Instructions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInstructionRow(
                      '1',
                      'Select a JSON file containing Dutch word exercises'
                    ),
                    _buildInstructionRow(
                      '2',
                      'The file should be exported from this app or follow the same format'
                    ),
                    _buildInstructionRow(
                      '3',
                      'Decks will be imported with their original structure'
                    ),
                    _buildInstructionRow(
                      '4',
                      'Review the import data before confirming'
                    ),
                    _buildInstructionRow(
                      '5',
                      'Existing exercises with the same ID will be updated'
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // File selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select File',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isImporting ? null : _pickFile,
                            icon: const Icon(Icons.file_upload),
                            label: const Text('Choose File'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedFileName ?? 'No file selected',
                            style: TextStyle(
                              color: _selectedFileName != null 
                                  ? Colors.green 
                                  : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            if (_importData != null) ...[
              const SizedBox(height: 16),
              
              // Import preview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Import Preview',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPreviewRow('Version', _importData!['metadata']['version'] ?? 'Unknown'),
                      _buildPreviewRow('Author', _importData!['metadata']['author'] ?? 'Unknown'),
                      _buildPreviewRow('Description', _importData!['metadata']['description'] ?? 'No description'),
                      _buildPreviewRow('Export Date', _importData!['metadata']['exportDate'] ?? 'Unknown'),
                      _buildPreviewRow('Total Words', '${(_importData!['exercises'] as List).length}'),
                      _buildPreviewRow('Total Questions', '${(_importData!['exercises'] as List).fold<int>(0, (sum, e) => sum + (e['exercises'] as List).length)}'),
                      _buildPreviewRow('Decks', _getDeckCount(_importData!['exercises'])),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Import button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isImporting ? null : _importExercises,
                  icon: _isImporting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isImporting ? 'Importing...' : 'Import Exercises'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
            
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            if (_successMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _successMessage!,
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _selectedFileName = file.name;
          _error = null;
          _successMessage = null;
          _importData = null;
        });

        // Read and parse the file
        await _parseFile(file);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _parseFile(PlatformFile file) async {
    try {
      if (file.bytes == null) {
        throw Exception('File is empty or could not be read');
      }

      final jsonString = String.fromCharCodes(file.bytes!);
      final data = json.decode(jsonString);

      // Validate the import data structure
      if (data is! Map<String, dynamic> || 
          !data.containsKey('metadata') || 
          !data.containsKey('exercises')) {
        throw Exception('Invalid file format. Expected JSON with metadata and exercises.');
      }

      setState(() {
        _importData = data;
      });

    } catch (e) {
      setState(() {
        _error = 'Failed to parse file: $e';
        _selectedFileName = null;
      });
    }
  }

  Future<void> _importExercises() async {
    if (_importData == null) return;

    setState(() {
      _isImporting = true;
      _error = null;
      _successMessage = null;
    });

    try {
      final provider = context.read<DutchWordExerciseProvider>();
      final jsonString = json.encode(_importData);
      await provider.importFromJson(jsonString);

      setState(() {
        _isImporting = false;
        _successMessage = 'Exercises imported successfully!';
        _importData = null;
        _selectedFileName = null;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercises imported successfully!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      setState(() {
        _isImporting = false;
        _error = 'Import failed: $e';
      });
    }
  }

  String _getDeckCount(List exercises) {
    final Set<String> deckIds = {};
    for (final exercise in exercises) {
      final deckId = exercise['deckId'] ?? 'default';
      deckIds.add(deckId);
    }
    return '${deckIds.length} decks';
  }
} 