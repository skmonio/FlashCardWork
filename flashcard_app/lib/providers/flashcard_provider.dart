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
      notifyListeners();
      return card;
    } catch (e) {
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