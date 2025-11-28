import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/domain/challenges/challenge_progress.dart';

// Provider for the service
final challengeServiceProvider = Provider<ChallengeService>((ref) {
  final firestore = FirebaseFirestore.instance;
  final gamificationEngine = ref.watch(gamificationEngineProvider);
  return ChallengeService(firestore, gamificationEngine);
});

class ChallengeService {
  final FirebaseFirestore _firestore;
  final GamificationEngine _gamificationEngine;

  ChallengeService(this._firestore, this._gamificationEngine);

  Future<void> _createOrUpdateChallengeProgress(
    String userId,
    Challenge challenge,
  ) async {
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('challenge_progress')
        .doc(challenge.id);

    await progressRef.set({
      'userId': userId,
      'challengeId': challenge.id,
      'progress': 0,
      'completed': false,
    }, SetOptions(merge: true));
  }

  /// Generates a new daily challenge for a user.
  Future<Challenge> generateDailyChallenge(String userId) async {
    final today = DateTime.now();
    final challengeId = 'daily_${today.year}_${today.month}_${today.day}';
    final challenge = Challenge(
      id: challengeId,
      name: 'Daily Quest Champion',
      description: 'Complete 3 quests today!',
      type: 'daily',
      goal: 3,
      startDate: DateTime(today.year, today.month, today.day),
      endDate: DateTime(today.year, today.month, today.day, 23, 59, 59),
    );

    // Store the challenge definition globally if it doesn't exist
    await _firestore
        .collection('challenges')
        .doc(challenge.id)
        .set(challenge.toJson(), SetOptions(merge: true));
    // Create progress tracker for the user
    await _createOrUpdateChallengeProgress(userId, challenge);
    print('Generated daily challenge for user $userId.');
    return challenge;
  }

  /// Generates a new weekly challenge for a user.
  Future<Challenge> generateWeeklyChallenge(String userId) async {
    final today = DateTime.now();
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final challengeId =
        'weekly_${weekStart.year}_${weekStart.month}_${weekStart.day}';
    final challenge = Challenge(
      id: challengeId,
      name: 'Weekly Warrior',
      description: 'Complete 15 quests this week!',
      type: 'weekly',
      goal: 15,
      startDate: weekStart,
      endDate: weekStart.add(const Duration(days: 6, hours: 23, minutes: 59)),
    );
    await _firestore
        .collection('challenges')
        .doc(challenge.id)
        .set(challenge.toJson(), SetOptions(merge: true));
    await _createOrUpdateChallengeProgress(userId, challenge);
    print('Generated weekly challenge for user $userId.');
    return challenge;
  }

  /// Gets the current progress for a specific challenge.
  Future<ChallengeProgress?> getProgress({
    required String userId,
    required String challengeId,
  }) async {
    try {
      final doc =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('challenge_progress')
              .doc(challengeId)
              .get();
      return doc.exists ? ChallengeProgress.fromJson(doc.data()!) : null;
    } catch (e) {
      print('Error getting challenge progress: $e');
      return null;
    }
  }

  /// Updates the progress of a challenge.
  Future<void> updateProgress({
    required String userId,
    required String challengeId,
    required int incrementBy,
  }) async {
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('challenge_progress')
        .doc(challengeId);

    final challengeRef = _firestore.collection('challenges').doc(challengeId);

    try {
      final challengeDoc = await challengeRef.get();
      if (!challengeDoc.exists) throw Exception('Challenge not found');
      final challenge = Challenge.fromJson(challengeDoc.data()!);

      final progressDoc = await progressRef.get();
      if (!progressDoc.exists) return; // No progress to update
      final currentProgress = ChallengeProgress.fromJson(progressDoc.data()!);

      if (currentProgress.completed) return; // Already completed

      final newProgress = currentProgress.progress + incrementBy;
      await progressRef.update({'progress': newProgress});

      if (newProgress >= challenge.goal) {
        await completeChallenge(
          userId: userId,
          challengeId: challengeId,
          challenge: challenge,
        );
      }
    } catch (e) {
      print('Error updating progress for challenge $challengeId: $e');
    }
  }

  /// Completes a challenge and awards rewards.
  Future<void> completeChallenge({
    required String userId,
    required String challengeId,
    Challenge? challenge,
  }) async {
    final progressRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('challenge_progress')
        .doc(challengeId);

    try {
      await progressRef.update({
        'completed': true,
        'progress': challenge?.goal ?? FieldValue.increment(0),
      });
      print('Completing challenge $challengeId for user $userId.');

      await _gamificationEngine.awardPoints(
        userId: userId,
        basePoints: 100, // Example points
        reason: 'Completed Challenge: ${challenge?.name ?? challengeId}',
      );
      // Optionally, check for new badges after awarding points
      await _gamificationEngine.checkAndAwardBadges(userId);

      // Request a review on special occasions (e.g., completing a weekly challenge)
      if (challenge?.type == 'weekly') {
        final InAppReview inAppReview = InAppReview.instance;
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
          print('Requested in-app review after weekly challenge completion.');
        }
      }
    } catch (e) {
      print('Error completing challenge $challengeId: $e');
    }
  }
}
