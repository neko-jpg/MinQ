import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/gamification/badge.dart';
import 'package:minq/domain/gamification/points.dart';
import 'package:minq/domain/user/user.dart';

// Provider for the engine
final gamificationEngineProvider = Provider<GamificationEngine>((ref) {
  return GamificationEngine(FirebaseFirestore.instance);
});

class GamificationEngine {
  final FirebaseFirestore _firestore;

  GamificationEngine(this._firestore);

  /// Awards points to a user for completing a quest or action.
  Future<void> awardPoints({
    required String userId,
    required int basePoints,
    required String reason,
    double difficultyMultiplier = 1.0,
    double consistencyMultiplier = 1.0,
  }) async {
    final totalPoints = (basePoints * difficultyMultiplier * consistencyMultiplier).round();
    final pointsTransaction = Points(
      id: '', // Firestore will generate this
      userId: userId,
      value: totalPoints,
      reason: reason,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('points_transactions')
        .add(pointsTransaction.toJson());

    print("Awarded $totalPoints points to user $userId for $reason.");
  }

  /// Checks for and awards any new badges to the user.
  Future<List<Badge>> checkAndAwardBadges(String userId) async {
    // TODO: Implement logic to check user progress against badge criteria
    // e.g., check for streaks, milestones, etc.
    print("Checking for new badges for user $userId.");
    return [];
  }

  /// Calculates the user's current rank based on their total points.
  Future<void> calculateRank(String userId) async {
    // TODO: Fetch user's total points and determine their rank from a predefined rank list.
    print("Calculating rank for user $userId.");
  }
}