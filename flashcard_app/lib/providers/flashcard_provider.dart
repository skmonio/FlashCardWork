import 'package:flutter/foundation.dart';
import '../models/flash_card.dart';
import '../models/deck.dart';
import '../services/flashcard_service.dart';

class FlashcardProvider extends ChangeNotifier {
  final FlashcardService _service = FlashcardService();
  
  List<Deck> _decks = [];
  List<FlashCard> _cards = [];
  Map<String, dynamic> _settings = {};
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Deck> get decks => _decks;
  List<FlashCard> get cards => _cards;
  Map<String, dynamic> get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize the provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      await _service.initialize();
      _decks = _service.decks;
      _cards = _service.cards;
      _settings = _service.settings;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  // MARK: - Deck Management
  
  Future<Deck?> createDeck(String name, {String? parentId}) async {
    try {
      final deck = await _service.createDeck(name, parentId: parentId);
      _decks.add(deck);
      notifyListeners();
      return deck;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }
  
  Future<bool> updateDeck(Deck deck) async {
    try {
      await _service.updateDeck(deck);
      final index = _decks.indexWhere((d) => d.id == deck.id);
      if (index != -1) {
        _decks[index] = deck;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  Future<bool> deleteDeck(String deckId) async {
    try {
      await _service.deleteDeck(deckId);
      _decks.removeWhere((deck) => deck.id == deckId);
      _cards.removeWhere((card) => card.deckIds.contains(deckId));
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  Deck? getDeck(String deckId) {
    return _service.getDeck(deckId);
  }
  
  List<Deck> getRootDecks() {
    return _service.getRootDecks();
  }
  
  List<Deck> getSubDecks(String parentDeckId) {
    return _service.getSubDecks(parentDeckId);
  }
  
  List<Deck> getAllDecksHierarchical() {
    // Returns all decks organized hierarchically (parents first, then their children)
    List<Deck> result = [];
    final topLevel = getRootDecks()..sort((a, b) => a.name.compareTo(b.name));
    
    for (final deck in topLevel) {
      result.add(deck);
      final subDecks = getSubDecks(deck.id)..sort((a, b) => a.name.compareTo(b.name));
      result.addAll(subDecks);
    }
    
    return result;
  }
  
  // MARK: - Card Management
  
  Future<FlashCard?> createCard({
    required String word,
    required String definition,
    required String example,
    Set<String>? deckIds,
    String article = '',
    String plural = '',
    String pastTense = '',
    String futureTense = '',
    String pastParticiple = '',
  }) async {
    try {
      print('Provider: Creating card: $word');
      final card = await _service.createCard(
        word: word,
        definition: definition,
        example: example,
        deckIds: deckIds,
        article: article,
        plural: plural,
        pastTense: pastTense,
        futureTense: futureTense,
        pastParticiple: pastParticiple,
      );
      _cards.add(card);
      print('Provider: Card created and added. Total cards: ${_cards.length}');
      notifyListeners();
      return card;
    } catch (e) {
      print('Provider: Error creating card: $e');
      _setError(e.toString());
      return null;
    }
  }
  
  Future<bool> updateCard(FlashCard card) async {
    try {
      await _service.updateCard(card);
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  Future<bool> deleteCard(String cardId) async {
    try {
      await _service.deleteCard(cardId);
      _cards.removeWhere((card) => card.id == cardId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  FlashCard? getCard(String cardId) {
    return _service.getCard(cardId);
  }
  
  List<FlashCard> getCardsForDeck(String deckId) {
    return _service.getCardsForDeck(deckId);
  }
  
  List<FlashCard> getCardsForDecks(List<String> deckIds) {
    return _service.getCardsForDecks(deckIds);
  }
  
  // MARK: - Study Session Management
  
  List<FlashCard> getDueCardsForDeck(String deckId) {
    return _service.getDueCardsForDeck(deckId);
  }
  
  List<FlashCard> getNewCardsForDeck(String deckId, {int limit = 20}) {
    return _service.getNewCardsForDeck(deckId, limit: limit);
  }
  
  List<FlashCard> getLearningCardsForDeck(String deckId) {
    return _service.getLearningCardsForDeck(deckId);
  }
  
  List<FlashCard> getReviewCardsForDeck(String deckId) {
    return _service.getReviewCardsForDeck(deckId);
  }
  
  // MARK: - Card Progress Updates
  
  Future<bool> markCardCorrect(FlashCard card) async {
    try {
      card.markCorrect();
      await _service.updateCard(card);
      
      // Update the card in our local list
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  Future<bool> markCardIncorrect(FlashCard card) async {
    try {
      card.markIncorrect();
      await _service.updateCard(card);
      
      // Update the card in our local list
      final index = _cards.indexWhere((c) => c.id == card.id);
      if (index != -1) {
        _cards[index] = card;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  // MARK: - Statistics
  
  Map<String, dynamic> getDeckStatistics(String deckId) {
    return _service.getDeckStatistics(deckId);
  }
  
  Map<String, dynamic> getOverallStatistics() {
    int totalCards = _cards.length;
    int newCards = _cards.where((card) => card.isNew).length;
    int learningCards = _cards.where((card) => card.isLearning).length;
    int reviewCards = _cards.where((card) => card.isReviewing).length;
    int learnedCards = _cards.where((card) => card.isFullyLearned).length;
    
    int totalShown = 0;
    int totalCorrect = 0;
    
    for (final card in _cards) {
      totalShown += card.timesShown;
      totalCorrect += card.timesCorrect;
    }
    
    double accuracy = totalShown > 0 ? (totalCorrect / totalShown) * 100 : 0.0;
    
    return {
      'totalCards': totalCards,
      'newCards': newCards,
      'learningCards': learningCards,
      'reviewCards': reviewCards,
      'learnedCards': learnedCards,
      'totalShown': totalShown,
      'totalCorrect': totalCorrect,
      'accuracy': accuracy,
      'totalDecks': _decks.length,
    };
  }
  
  // MARK: - Settings Management
  
  Future<bool> updateSetting(String key, dynamic value) async {
    try {
      await _service.updateSetting(key, value);
      _settings[key] = value;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  T? getSetting<T>(String key, {T? defaultValue}) {
    return _service.getSetting<T>(key, defaultValue: defaultValue);
  }
  
  // MARK: - Search and Filter
  
  List<FlashCard> searchCards(String query) {
    return _service.searchCards(query);
  }
  
  List<Deck> searchDecks(String query) {
    return _service.searchDecks(query);
  }
  
  // MARK: - Data Import/Export
  
  Future<Map<String, dynamic>?> exportData() async {
    try {
      return await _service.exportData();
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }
  
  Future<bool> importData(Map<String, dynamic> data) async {
    try {
      await _service.importData(data);
      _decks = _service.decks;
      _cards = _service.cards;
      _settings = _service.settings;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }
  
  // MARK: - CSV Export/Import
  
  String exportDecksToCSV(Set<String> deckIds) {
    final headers = [
      'Word', 'Definition', 'Example', 'Article', 'Plural', 
      'Past Tense', 'Future Tense', 'Past Participle', 'Decks', 
      'Success Count', 'Times Shown', 'Times Correct'
    ];
    
    var csvContent = headers.join(',') + '\n';
    
    // Collect all cards from selected decks (including hierarchy)
    final allCards = <FlashCard>{};
    
    for (final deckId in deckIds) {
      final deck = _decks.firstWhere((d) => d.id == deckId);
      final deckCards = getCardsForDeck(deck.id);
      allCards.addAll(deckCards);
      
      // Add cards from sub-decks
      final subDecks = getSubDecks(deck.id);
      for (final subDeck in subDecks) {
        final subDeckCards = getCardsForDeck(subDeck.id);
        allCards.addAll(subDeckCards);
      }
    }
    
    // Convert to sorted list for consistent output
    final sortedCards = allCards.toList()
      ..sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
    
    for (final card in sortedCards) {
      final deckNames = getDeckNamesForCard(card).join('; ');
      
      final row = [
        _escapeCSVField(card.word),
        _escapeCSVField(card.definition),
        _escapeCSVField(card.example),
        _escapeCSVField(card.article),
        _escapeCSVField(card.plural),
        _escapeCSVField(card.pastTense),
        _escapeCSVField(card.futureTense),
        _escapeCSVField(card.pastParticiple),
        _escapeCSVField(deckNames),
        card.successCount.toString(),
        card.timesShown.toString(),
        card.timesCorrect.toString(),
      ];
      
      csvContent += row.join(',') + '\n';
    }
    
    return csvContent;
  }
  
  Future<Map<String, dynamic>> importFromCSV(String csvContent) async {
    final lines = csvContent.split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
    
    if (lines.length < 2) {
      return {
        'success': 0,
        'errors': ['CSV file appears to be empty or invalid']
      };
    }
    
    var successCount = 0;
    final errors = <String>[];
    
    // Ensure Uncategorized deck exists
    Deck uncategorizedDeck;
    try {
      uncategorizedDeck = _decks.firstWhere((d) => d.name == 'Uncategorized');
    } catch (e) {
      final newDeck = await createDeck('Uncategorized');
      if (newDeck != null) {
        uncategorizedDeck = newDeck;
      } else {
        throw Exception('Failed to create Uncategorized deck');
      }
    }
    
    // Skip header row
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      final lineNumber = i + 1; // 1-based indexing
      
      try {
        final fields = _parseCSVLine(line);
        
        // Validate minimum required fields
        if (fields.length < 2 || 
            fields[0].trim().isEmpty || 
            fields[1].trim().isEmpty) {
          errors.add('Line $lineNumber: Missing required word or definition');
          continue;
        }
        
        final word = fields[0].trim();
        final definition = fields[1].trim();
        final example = fields.length > 2 ? fields[2].trim() : '';
        final article = fields.length > 3 ? fields[3].trim() : '';
        final plural = fields.length > 4 ? fields[4].trim() : '';
        final pastTense = fields.length > 5 ? fields[5].trim() : '';
        final futureTense = fields.length > 6 ? fields[6].trim() : '';
        final pastParticiple = fields.length > 7 ? fields[7].trim() : '';
        
        // Handle deck assignment
        final deckNames = fields.length > 8 ? fields[8].trim() : '';
        final deckIds = <String>{};
        
        if (deckNames.isNotEmpty) {
          final deckNameList = deckNames.split(';').map((name) => name.trim()).toList();
          for (final deckName in deckNameList) {
            if (deckName.isNotEmpty) {
              try {
                final deck = _decks.firstWhere((d) => d.name == deckName);
                deckIds.add(deck.id);
              } catch (e) {
                // Create deck if it doesn't exist
                final newDeck = await createDeck(deckName);
                if (newDeck != null) {
                  deckIds.add(newDeck.id);
                }
              }
            }
          }
        }
        
        // If no decks specified, add to Uncategorized
        if (deckIds.isEmpty) {
          deckIds.add(uncategorizedDeck.id);
        }
        
        // Handle statistics
        int successCount = 0;
        int timesShown = 0;
        int timesCorrect = 0;
        
        if (fields.length > 9) {
          successCount = int.tryParse(fields[9].trim()) ?? 0;
        }
        if (fields.length > 10) {
          timesShown = int.tryParse(fields[10].trim()) ?? 0;
        }
        if (fields.length > 11) {
          timesCorrect = int.tryParse(fields[11].trim()) ?? 0;
        }
        
        // Create the card
        final newCard = await createCard(
          word: word,
          definition: definition,
          example: example,
          deckIds: deckIds,
          article: article,
          plural: plural,
          pastTense: pastTense,
          futureTense: futureTense,
          pastParticiple: pastParticiple,
        );
        
        if (newCard != null) {
          // Update statistics if provided
          newCard.successCount = successCount;
          newCard.timesShown = timesShown;
          newCard.timesCorrect = timesCorrect;
          
          // Update the card in the service
          await _service.updateCard(newCard);
          
          successCount++;
        }
      } catch (e) {
        errors.add('Line $lineNumber: ${e.toString()}');
      }
    }
    
    // Refresh data after import
    refresh();
    
    return {
      'success': successCount,
      'errors': errors,
    };
  }
  
  String _escapeCSVField(String field) {
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
  
  List<String> _parseCSVLine(String line) {
    final fields = <String>[];
    var currentField = '';
    var inQuotes = false;
    
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          currentField += '"';
          i++; // Skip next quote
        } else {
          // Toggle quote state
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // End of field
        fields.add(currentField);
        currentField = '';
      } else {
        currentField += char;
      }
    }
    
    // Add the last field
    fields.add(currentField);
    
    return fields;
  }
  
  List<String> getDeckNamesForCard(FlashCard card) {
    return card.deckIds.map((deckId) {
      try {
        return _decks.firstWhere((d) => d.id == deckId).name;
      } catch (e) {
        return 'Unknown Deck';
      }
    }).toList();
  }
  
  // MARK: - Utility Methods
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void refresh() {
    _decks = _service.decks;
    _cards = _service.cards;
    _settings = _service.settings;
    notifyListeners();
  }
} 