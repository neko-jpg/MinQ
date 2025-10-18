import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/challenges/challenge.dart';
import 'package:minq/domain/challenges/challenge_progress.dart';

// Provider for the service
final challengeServiceProvider = Provider<ChallengeService>((ref) {
  return ChallengeService(FirebaseFirestore.instance);
});

class ChallengeService {
  final FirebaseFirestore _firestore;

  ChallengeService(this._firestore);

  /// Generates a new daily challenge for a user.
  Future<Challenge> generateDailyChallenge(String userId) async {
    // TODO: Implement logic to create a new daily challenge instance.
    // This will likely involve a predefined template.
    final challenge = Challenge(
      id: 'daily_${DateTime.now().toIso8601String()}',
      name: 'Daily Quest',
      description: 'Complete one quest today!',
      type: 'daily',
      goal: 1,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 1)),
    );
    print("Generated daily challenge for user $userId.");
    return challenge;
  }

  /// Generates a new weekly challenge for a user.
  Future<Challenge> generateWeeklyChallenge(String userId) async {
    // TODO: Implement logic for weekly challenges, e.g., a 7-day streak.
    final challenge = Challenge(
      id: 'weekly_${DateTime.now().toIso8601String()}',
      name: 'Weekly Streak',
      description: 'Maintain a 7-day streak!',
      type: 'weekly',
      goal: 7,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 7)),
    );
    print("Generated weekly challenge for user $userId.");
    return challenge;
  }

  /// Gets the current progress for a specific challenge.
  Future<ChallengeProgress?> getProgress({
    required String userId,
    required String challengeId,
  }) async {
    // TODO: Fetch progress from Firestore.
    return null;
  }

  /// Updates the progress of a challenge.
  Future<void> updateProgress({
    required String userId,
    required String challengeId,
    required int newProgress,
  }) async {
    // TODO: Implement logic to update progress in Firestore.
    print("Updating progress for challenge $challengeId for user $userId.");
  }

  /// Completes a challenge and awards rewards.
  Future<void> completeChallenge({
    required String userId,
    required String challengeId,
  }) async {
    // TODO:
    // 1. Mark challenge as complete.
    // 2. Award points/badges using the GamificationEngine.
    print("Completing challenge $challengeId for user $userId.");
  }
}