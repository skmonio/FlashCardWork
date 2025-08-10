import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../models/game_session.dart';
import '../providers/user_profile_provider.dart';

class XpService {
  static void recordAnswer(GameSession gameSession, bool isCorrect) {
    gameSession.recordAnswer(isCorrect);
    debugPrint('🔍 XpService: Answer recorded - Correct: $isCorrect, Total XP: ${gameSession.xpGained}');
  }
  
  static Future<void> awardSessionXp(context, GameSession gameSession, {bool isShuffleMode = false}) async {
    if (!isShuffleMode && gameSession.xpGained > 0) {
      await context.read<UserProfileProvider>().addXp(gameSession.xpGained);
      debugPrint('🔍 XpService: Awarded ${gameSession.xpGained} XP to user profile');
    }
  }
  
  static Map<String, dynamic> getSessionSummary(GameSession gameSession) {
    return {
      'xpGained': gameSession.xpGained,
      'correctAnswers': gameSession.correctAnswers,
      'totalAnswers': gameSession.totalAnswers,
      'accuracy': gameSession.accuracy,
      'accuracyPercentage': gameSession.accuracyPercentage,
    };
  }
}
