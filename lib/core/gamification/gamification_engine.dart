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
    final userBadgesRef =
        _firestore.collection('users').doc(userId).collection('badges');
    final questLogsRef =
        _firestore.collection('users').doc(userId).collection('quest_logs');

    final awardedBadges = <Badge>[];

    // Get user's existing badges
    final existingBadgesSnapshot = await userBadgesRef.get();
    final existingBadgeIds =
        existingBadgesSnapshot.docs.map((doc) => doc.id).toSet();

    // Get quest logs
    final questLogsSnapshot = await questLogsRef.get();
    final completedQuests = questLogsSnapshot.docs.length;

    // Define all possible badges
    final allBadges = _getBadgeDefinitions(completedQuests);

    for (final badgeDef in allBadges) {
      if (!existingBadgeIds.contains(badgeDef.id) && badgeDef.isEarned) {
        final newBadge = badgeDef.toBadge();
        await userBadgesRef.doc(newBadge.id).set(newBadge.toJson());
        awardedBadges.add(newBadge);
      }
    }

    if (awardedBadges.isNotEmpty) {
      print("Awarded ${awardedBadges.length} new badges to user $userId.");
    }

    return awardedBadges;
  }

  // Temporary method to define badges. In a real app, this would come from a remote config or Firestore.
  List<_BadgeDefinition> _getBadgeDefinitions(int completedQuests) {
    return [
      _BadgeDefinition(
        id: 'quest_master_1',
        name: 'First Step',
        description: 'You completed your first quest!',
        imageUrl: 'assets/images/badges/first_step.png',
        isEarned: completedQuests >= 1,
      ),
      _BadgeDefinition(
        id: 'quest_master_10',
        name: 'Quest Apprentice',
        description: 'You completed 10 quests!',
        imageUrl: 'assets/images/badges/quest_apprentice.png',
        isEarned: completedQuests >= 10,
      ),
      _BadgeDefinition(
        id: 'quest_master_50',
        name: 'Quest Journeyman',
        description: 'You completed 50 quests!',
        imageUrl: 'assets/images/badges/quest_journeyman.png',
        isEarned: completedQuests >= 50,
      ),
      _BadgeDefinition(
        id: 'quest_master_100',
        name: 'Quest Master',
        description: 'You completed 100 quests!',
        imageUrl: 'assets/images/badges/quest_master.png',
        isEarned: completedQuests >= 100,
      ),
    ];
  }


  /// Calculates the user's current rank based on their total points.
  Future<void> calculateRank(String userId) async {
    final pointsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('points_transactions')
        .get();

    if (pointsSnapshot.docs.isEmpty) {
      print("User $userId has no points yet.");
      return;
    }

    final totalPoints = pointsSnapshot.docs
        .map((doc) => Points.fromJson(doc.data()).value)
        .fold(0, (prev, current) => prev + current);

    final rank = _getRankForPoints(totalPoints);

    await _firestore.collection('users').doc(userId).update({'rank': rank});
    print("User $userId rank updated to $rank.");
  }

  String _getRankForPoints(int points) {
    if (points < 100) return 'Novice';
    if (points < 500) return 'Apprentice';
    if (points < 1000) return 'Adept';
    if (points < 5000) return 'Master';
    return 'Grandmaster';
  }
}

// Helper class to hold badge definition and earned status
class _BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isEarned;

  _BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isEarned = false,
  });

  Badge toBadge() {
    return Badge(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      earnedAt: DateTime.now(),
    );
  }
}