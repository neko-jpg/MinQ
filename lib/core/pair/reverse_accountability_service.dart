import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/core/logging/app_logger.dart';

// Provider for the service
final reverseAccountabilityServiceProvider =
    Provider<ReverseAccountabilityService>((ref) {
      final gamificationEngine = ref.watch(gamificationEngineProvider);
      return ReverseAccountabilityService(
        FirebaseFirestore.instance,
        gamificationEngine,
      );
    });

class ReverseAccountabilityService {
  final FirebaseFirestore _firestore;
  final GamificationEngine _gamificationEngine;

  ReverseAccountabilityService(this._firestore, this._gamificationEngine);

  /// Notifies a user's pair when they complete a quest.
  Future<void> notifyPairOfSuccess({
    required String userId,
    required String pairId,
    required String questName,
  }) async {
    try {
      final user = await _firestore.collection('users').doc(userId).get();
      final userName = user.data()?['displayName'] ?? 'Your pair';

      final notification = {
        'title': 'Pair Progress!',
        'body': '$userName just completed "$questName"! ✨',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      };
      // This is for in-app notifications list
      await _firestore
          .collection('users')
          .doc(pairId)
          .collection('notifications')
          .add(notification);

      // This triggers a backend function to send the actual push notification
      await _firestore.collection('notifications_to_send').add({
        'targetUserId': pairId,
        'title': notification['title'],
        'body': notification['body'],
      });

      logger.info(
        "Queued push notification for pair $pairId for user $userId's success.",
      );
    } catch (e) {
      logger.error('Error notifying pair: $e');
    }
  }

  /// Creates a "resonance bonus" when both members of a pair complete their daily quests.
  Future<void> createResonanceBonus({
    required String user1Id,
    required String user2Id,
  }) async {
    try {
      // For simplicity, we define a "daily quest" as completing at least 3 quests today.
      final bool user1Completed = await _hasCompletedDailyGoal(user1Id);
      final bool user2Completed = await _hasCompletedDailyGoal(user2Id);

      if (user1Completed && user2Completed) {
        logger.info('Both users completed daily goals! Awarding Resonance Bonus.');
        await _gamificationEngine.awardPoints(
          userId: user1Id,
          basePoints: 50,
          reason: 'Resonance Bonus!',
        );
        await _gamificationEngine.awardPoints(
          userId: user2Id,
          basePoints: 50,
          reason: 'Resonance Bonus!',
        );

        // Maybe create a special notification for this
      } else {
        logger.info('Resonance bonus conditions not met.');
      }
    } catch (e) {
      logger.error('Error creating resonance bonus: $e');
    }
  }

  Future<bool> _hasCompletedDailyGoal(String userId, {int goal = 3}) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('quest_logs')
            .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
            .limit(goal)
            .get();

    return snapshot.docs.length >= goal;
  }

  /// Prompts a user to send a supportive message to their partner if they are struggling.
  void sendSupportPrompt({
    required String activeUserId,
    required String strugglingPairId,
  }) {
    // This would trigger a UI prompt with pre-written supportive message templates.
    // The logic to determine "struggling" would be more complex, e.g., based on broken streaks.
    logger.info(
      'UI TRIGGER: Prompting user $activeUserId to support struggling pair $strugglingPairId.',
    );
    logger.info(
      "Suggestion: 'Your pair might be having a tough time. Send them a message of support?'",
    );
  }
}
