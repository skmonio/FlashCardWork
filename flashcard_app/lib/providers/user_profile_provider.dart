import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  static const String _profileKey = 'user_profile';
  
  UserProfile _profile = UserProfile(
    username: 'Learner',
    selectedAvatar: 'person',
    xp: 0,
    level: 1,
    achievements: UserProfileDefaults.defaultAchievements,
    levelRewards: UserProfileDefaults.defaultLevelRewards,
    totalSessions: 0,
    currentStreak: 0,
    bestStreak: 0,
    accuracy: 0.0,
    totalCardsStudied: 0,
    perfectSessions: 0,
  );

  bool _isLoading = false;
  String? _error;

  // Getters
  UserProfile get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Computed properties
  String get username => _profile.username;
  String get selectedAvatar => _profile.selectedAvatar;
  String? get profileImageData => _profile.profileImageData;
  int get xp => _profile.xp;
  int get level => _profile.level;
  List<Achievement> get achievements => _profile.achievements;
  List<LevelReward> get levelRewards => _profile.levelRewards;
  int get totalSessions => _profile.totalSessions;
  int get currentStreak => _profile.currentStreak;
  int get bestStreak => _profile.bestStreak;
  double get accuracy => _profile.accuracy;
  int get totalCardsStudied => _profile.totalCardsStudied;
  int get perfectSessions => _profile.perfectSessions;
  double get progressToNextLevel => _profile.progressToNextLevel;

  // Initialize the provider
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadFromStorage();
    } catch (e) {
      _error = 'Failed to load profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load profile from storage
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    
    if (profileJson != null) {
      try {
        final profileData = json.decode(profileJson);
        _profile = UserProfile.fromJson(profileData);
      } catch (e) {
        // If loading fails, use default profile
        _profile = UserProfile(
          username: 'Learner',
          selectedAvatar: 'person',
          xp: 0,
          level: 1,
          achievements: UserProfileDefaults.defaultAchievements,
          levelRewards: UserProfileDefaults.defaultLevelRewards,
          totalSessions: 0,
          currentStreak: 0,
          bestStreak: 0,
          accuracy: 0.0,
          totalCardsStudied: 0,
          perfectSessions: 0,
        );
      }
    }
  }

  // Save profile to storage
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(_profile.toJson());
      await prefs.setString(_profileKey, profileJson);
    } catch (e) {
      _error = 'Failed to save profile: $e';
      notifyListeners();
    }
  }

  // Update username
  Future<void> updateUsername(String newUsername) async {
    _profile = _profile.copyWith(username: newUsername);
    await _saveToStorage();
    notifyListeners();
  }

  // Update avatar
  Future<void> updateAvatar(String newAvatar) async {
    _profile = _profile.copyWith(selectedAvatar: newAvatar);
    await _saveToStorage();
    notifyListeners();
  }

  // Update profile image
  Future<void> updateProfileImage(String? imageData) async {
    _profile = _profile.copyWith(profileImageData: imageData);
    await _saveToStorage();
    notifyListeners();
  }

  // Add XP and check for level up
  Future<void> addXp(int xpToAdd) async {
    final oldLevel = _profile.level;
    final newXp = _profile.xp + xpToAdd;
    
    // Calculate new level
    int newLevel = oldLevel;
    while (_getXpForLevel(newLevel + 1) <= newXp) {
      newLevel++;
    }
    
    _profile = _profile.copyWith(xp: newXp, level: newLevel);
    
    // Check for level up
    if (newLevel > oldLevel) {
      _checkLevelRewards(newLevel);
    }
    
    // Check achievements
    _checkAchievements();
    
    await _saveToStorage();
    notifyListeners();
  }

  // Update session statistics
  Future<void> updateSessionStats({
    required int cardsStudied,
    required double sessionAccuracy,
    required bool isPerfect,
  }) async {
    final newTotalSessions = _profile.totalSessions + 1;
    final newTotalCardsStudied = _profile.totalCardsStudied + cardsStudied;
    final newPerfectSessions = _profile.perfectSessions + (isPerfect ? 1 : 0);
    
    // Calculate new accuracy
    final totalAccuracy = (_profile.accuracy * _profile.totalSessions) + sessionAccuracy;
    final newAccuracy = totalAccuracy / newTotalSessions;
    
    _profile = _profile.copyWith(
      totalSessions: newTotalSessions,
      totalCardsStudied: newTotalCardsStudied,
      perfectSessions: newPerfectSessions,
      accuracy: newAccuracy,
    );
    
    // Check achievements
    _checkAchievements();
    
    await _saveToStorage();
    notifyListeners();
  }

  // Update streak
  Future<void> updateStreak(int newStreak) async {
    final newBestStreak = newStreak > _profile.bestStreak ? newStreak : _profile.bestStreak;
    
    _profile = _profile.copyWith(
      currentStreak: newStreak,
      bestStreak: newBestStreak,
    );
    
    // Check achievements
    _checkAchievements();
    
    await _saveToStorage();
    notifyListeners();
  }

  // Check and unlock achievements
  void _checkAchievements() {
    final updatedAchievements = List<Achievement>.from(_profile.achievements);
    bool hasChanges = false;
    
    for (int i = 0; i < updatedAchievements.length; i++) {
      final achievement = updatedAchievements[i];
      
      if (!achievement.isUnlocked) {
        bool shouldUnlock = false;
        
        switch (achievement.type) {
          case AchievementType.xp:
            shouldUnlock = _profile.xp >= achievement.xpRequired;
            break;
          case AchievementType.level:
            shouldUnlock = _profile.level >= achievement.levelRequired;
            break;
          case AchievementType.streak:
            shouldUnlock = _profile.currentStreak >= achievement.xpRequired;
            break;
          case AchievementType.sessions:
            shouldUnlock = _profile.totalSessions >= achievement.xpRequired;
            break;
          case AchievementType.perfect:
            shouldUnlock = _profile.perfectSessions >= achievement.xpRequired;
            break;
          case AchievementType.accuracy:
            shouldUnlock = _profile.accuracy >= (achievement.xpRequired / 100.0);
            break;
        }
        
        if (shouldUnlock) {
          updatedAchievements[i] = achievement.copyWith(
            isUnlocked: true,
            unlockedDate: DateTime.now(),
          );
          hasChanges = true;
        }
      }
    }
    
    if (hasChanges) {
      _profile = _profile.copyWith(achievements: updatedAchievements);
    }
  }

  // Check level rewards
  void _checkLevelRewards(int newLevel) {
    final updatedRewards = List<LevelReward>.from(_profile.levelRewards);
    bool hasChanges = false;
    
    for (int i = 0; i < updatedRewards.length; i++) {
      final reward = updatedRewards[i];
      
      if (!reward.isClaimed && reward.level <= newLevel) {
        // Auto-claim rewards when level is reached
        updatedRewards[i] = reward.copyWith(isClaimed: true);
        hasChanges = true;
        
        // Apply reward effects
        _applyReward(reward);
      }
    }
    
    if (hasChanges) {
      _profile = _profile.copyWith(levelRewards: updatedRewards);
    }
  }

  // Apply reward effects
  void _applyReward(LevelReward reward) {
    switch (reward.type) {
      case LevelRewardType.xp:
        addXp(reward.value);
        break;
      case LevelRewardType.streak:
        // Streak protection logic would go here
        break;
      case LevelRewardType.feature:
        // Feature unlock logic would go here
        break;
      case LevelRewardType.cosmetic:
        // Cosmetic unlock logic would go here
        break;
    }
  }

  // Claim a level reward manually
  Future<void> claimReward(String rewardId) async {
    final updatedRewards = List<LevelReward>.from(_profile.levelRewards);
    final rewardIndex = updatedRewards.indexWhere((r) => r.id == rewardId);
    
    if (rewardIndex != -1) {
      final reward = updatedRewards[rewardIndex];
      if (!reward.isClaimed && reward.level <= _profile.level) {
        updatedRewards[rewardIndex] = reward.copyWith(isClaimed: true);
        _profile = _profile.copyWith(levelRewards: updatedRewards);
        
        // Apply reward effects
        _applyReward(reward);
        
        await _saveToStorage();
        notifyListeners();
      }
    }
  }

  // Reset profile (for testing)
  Future<void> resetProfile() async {
    _profile = UserProfile(
      username: 'Learner',
      selectedAvatar: 'person',
      xp: 0,
      level: 1,
      achievements: UserProfileDefaults.defaultAchievements,
      levelRewards: UserProfileDefaults.defaultLevelRewards,
      totalSessions: 0,
      currentStreak: 0,
      bestStreak: 0,
      accuracy: 0.0,
      totalCardsStudied: 0,
      perfectSessions: 0,
    );
    
    await _saveToStorage();
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Helper method to calculate XP for a level
  int _getXpForLevel(int level) {
    return (100 * pow(level, 1.5)).round();
  }
} 