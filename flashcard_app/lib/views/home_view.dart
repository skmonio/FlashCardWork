import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/deck.dart';
import 'study_type_selection_view.dart';
import 'memory_game_view.dart';
import 'bubble_word_view.dart';
import 'advanced_study_view.dart';
import 'multiple_choice_view.dart';
import 'true_false_view.dart';
import 'writing_view.dart';
import 'word_scramble_view.dart';
import '../services/sample_data_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentStreak = 7; // TODO: Connect to streak manager

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // Header with streak and title - wrapped in SafeArea to avoid system UI
          SafeArea(
            child: _buildHeader(),
          ),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Lessons Section
                  _buildLessonsSection(),
                  
                  // Study Modes Section
                  _buildStudyModesSection(),
                  
                  // Games Section
                  _buildGamesSection(),
                  
                  // Resources Section
                  _buildResourcesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Streak indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _currentStreak > 0 ? Colors.orange.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 20,
                  color: _currentStreak > 0 ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_currentStreak',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _currentStreak > 0 ? Colors.orange : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Title
          const Text(
            'Taal Trek',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const Spacer(),
          
          // Empty space to balance the layout
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lessons',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          'Dutch Lessons',
          Icons.book,
          Colors.blue,
          () => _navigateToLessons(context),
        ),
      ],
    );
  }

  Widget _buildStudyModesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Study Modes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          'Study Your Cards',
          Icons.school,
          Colors.teal,
          () => _navigateToStudy(context),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Test Your Cards',
          Icons.quiz,
          Colors.orange,
          () => _navigateToTest(context),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'True or False',
          Icons.help_outline,
          const Color(0xFFFF6B4D),
          () => _navigateToTrueFalse(context),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Write Your Card',
          Icons.edit,
          const Color(0xFFFF9800),
          () => _navigateToWriting(context),
        ),
      ],
    );
  }

  Widget _buildGamesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Games',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          'Remember Your Cards',
          Icons.psychology,
          Colors.orange,
          () => _navigateToMemoryGame(context),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Jumble Your Cards',
          Icons.text_fields,
          const Color(0xFFFF6B4D),
          () => _navigateToWordScramble(context),
        ),
      ],
    );
  }

  Widget _buildResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Resources',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 16),
        _buildMenuButton(
          'Bubble Word',
          Icons.bubble_chart,
          Colors.purple,
          () => _navigateToBubbleWord(context),
        ),
        const SizedBox(height: 12),
        _buildMenuButton(
          'Dutch Grammar',
          Icons.language,
          Colors.indigo,
          () => _navigateToGrammar(context),
        ),
      ],
    );
  }

  Widget _buildMenuButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToLessons(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dutch Lessons coming soon!')),
    );
  }

  void _navigateToStudy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyTypeSelectionView(
          gameMode: GameMode.study,
        ),
      ),
    );
  }

  void _navigateToTest(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyTypeSelectionView(
          gameMode: GameMode.test,
        ),
      ),
    );
  }

  void _navigateToTrueFalse(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyTypeSelectionView(
          gameMode: GameMode.trueFalse,
        ),
      ),
    );
  }

  void _navigateToWriting(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyTypeSelectionView(
          gameMode: GameMode.write,
        ),
      ),
    );
  }

  void _navigateToMemoryGame(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyTypeSelectionView(
          gameMode: GameMode.game,
        ),
      ),
    );
  }

  void _navigateToWordScramble(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyTypeSelectionView(
          gameMode: GameMode.bubbleWord,
        ),
      ),
    );
  }

  void _navigateToBubbleWord(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BubbleWordView(),
      ),
    );
  }

  void _navigateToGrammar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dutch Grammar guide coming soon!')),
    );
  }

  void _addSampleData(BuildContext context) async {
    final provider = context.read<FlashcardProvider>();
    await SampleDataService.addSampleData(provider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sample Dutch vocabulary added!')),
    );
  }
}