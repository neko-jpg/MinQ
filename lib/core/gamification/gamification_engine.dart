import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/badge.dart';
import 'package:minq/domain/gamification/pending_transaction.dart';
import 'package:minq/domain/gamification/points.dart';

// Provider for the engine
final gamificationEngineProvider = Provider<GamificationEngine>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final isar = ref.watch(isarProvider).value;
  return GamificationEngine(firestore, isar);
});

class GamificationEngine {
  final FirebaseFirestore? _firestore;
  final Isar? _isar;

  GamificationEngine(this._firestore, this._isar);

  /// Awards points to a user for completing a quest or action.
  Future<void> awardPoints({
    required String userId,
    required int basePoints,
    required String reason,
    double difficultyMultiplier = 1.0,
    double consistencyMultiplier = 1.0,
  }) async {
    final totalPoints =
        (basePoints * difficultyMultiplier * consistencyMultiplier).round();

    // Firestoreが利用できない場合はローカルに保存
    if (_firestore == null) {
      await _savePendingTransaction(
        userId: userId,
        method: 'awardPoints',
        payload: {
          'userId': userId,
          'basePoints': basePoints,
          'reason': reason,
          'difficultyMultiplier': difficultyMultiplier,
          'consistencyMultiplier': consistencyMultiplier,
        },
      );
      MinqLogger.info(
        'Awarded $totalPoints points to user $userId for $reason (offline mode - queued).',
      );
      return;
    }

    final pointsTransaction = Points(
      id: '', // Firestore will generate this
      userId: userId,
      value: totalPoints,
      reason: reason,
      createdAt: DateTime.now(),
    );

    try {
      final batch = _firestore!.batch();

      // Add points transaction
      final pointsRef =
          _firestore!
              .collection('users')
              .doc(userId)
              .collection('points_transactions')
              .doc();
      batch.set(pointsRef, pointsTransaction.toJson());

      // Increment completedQuestsCount if the reason implies a quest completion
      // This is a heuristic; ideally we'd have a specific flag or method for quest completion
      if (reason.contains('Quest') || reason.contains('quest')) {
        final userRef = _firestore!.collection('users').doc(userId);
        batch.set(userRef, {
          'completedQuestsCount': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      MinqLogger.info(
        'Awarded $totalPoints points to user $userId for $reason.',
      );
    } catch (e) {
      MinqLogger.error('Failed to award points: $e');
      // Fallback to offline queue on error
      await _savePendingTransaction(
        userId: userId,
        method: 'awardPoints',
        payload: {
          'userId': userId,
          'basePoints': basePoints,
          'reason': reason,
          'difficultyMultiplier': difficultyMultiplier,
          'consistencyMultiplier': consistencyMultiplier,
        },
      );
    }
  }

  /// Checks for and awards any new badges to the user.
  Future<List<Badge>> checkAndAwardBadges(String userId) async {
    if (_firestore == null) {
      MinqLogger.info('Badge check skipped (offline mode).');
      return [];
    }

    try {
      final userRef = _firestore!.collection('users').doc(userId);
      final userBadgesRef = userRef.collection('badges');

      final awardedBadges = <Badge>[];

      // Get user's existing badges
      final existingBadgesSnapshot = await userBadgesRef.get();
      final existingBadgeIds =
          existingBadgesSnapshot.docs.map((doc) => doc.id).toSet();

      // Get completed quests count efficiently
      final userSnapshot = await userRef.get();
      final userData = userSnapshot.data();
      final completedQuests = (userData?['completedQuestsCount'] as int?) ?? 0;

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
        MinqLogger.info(
          'Awarded ${awardedBadges.length} new badges to user $userId.',
        );
      }

      return awardedBadges;
    } catch (e) {
      MinqLogger.error('Failed to check badges: $e');
      return [];
    }
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
    if (_firestore == null) {
      MinqLogger.info('Rank calculation skipped (offline mode).');
      return;
    }

    try {
      // Note: For total points, we might also want to maintain a counter in the user doc
      // to avoid reading all transactions. For now, keeping as is but adding logging.
      final pointsSnapshot =
          await _firestore!
              .collection('users')
              .doc(userId)
              .collection('points_transactions')
              .get();

      if (pointsSnapshot.docs.isEmpty) {
        MinqLogger.info('User $userId has no points yet.');
        return;
      }

      final totalPoints = pointsSnapshot.docs
          .map((doc) => Points.fromJson(doc.data()).value)
          .fold<int>(0, (prev, current) => prev + current);

      final rank = _getRankForPoints(totalPoints);

      await _firestore!.collection('users').doc(userId).update({'rank': rank});
      MinqLogger.info('User $userId rank updated to $rank.');
    } catch (e) {
      MinqLogger.error('Failed to calculate rank: $e');
    }
  }

  String _getRankForPoints(int points) {
    if (points < 100) return 'Novice';
    if (points < 500) return 'Apprentice';
    if (points < 1000) return 'Adept';
    if (points < 5000) return 'Master';
    return 'Grandmaster';
  }

  /// Gets the user's total points
  Future<int> getUserPoints(String userId) async {
    if (_firestore == null) {
      return 0;
    }

    try {
      final pointsSnapshot =
          await _firestore!
              .collection('users')
              .doc(userId)
              .collection('points_transactions')
              .get();

      if (pointsSnapshot.docs.isEmpty) {
        return 0;
      }

      return pointsSnapshot.docs
          .map((doc) => Points.fromJson(doc.data()).value)
          .fold<int>(0, (prev, current) => prev + current);
    } catch (e) {
      MinqLogger.error('Failed to get user points: $e');
      return 0;
    }
  }

  /// Gets the rank for a given number of points
  ({String name, int minPoints}) getRankForPoints(int points) {
    if (points < 1000) {
      return (name: 'rank_bronze', minPoints: 0);
    }
    if (points < 5000) {
      return (name: 'rank_silver', minPoints: 1000);
    }
    if (points < 15000) {
      return (name: 'rank_gold', minPoints: 5000);
    }
    if (points < 50000) {
      return (name: 'rank_platinum', minPoints: 15000);
    }
    return (name: 'rank_diamond', minPoints: 50000);
  }

  Future<void> _savePendingTransaction({
    required String userId,
    required String method,
    required Map<String, dynamic> payload,
  }) async {
    if (_isar == null) return;

    final transaction =
        PendingTransaction()
          ..userId = userId
          ..method = method
          ..payloadJson = jsonEncode(payload)
          ..createdAt = DateTime.now();

    await _isar!.writeTxn(() async {
      await _isar!.pendingTransactions.put(transaction);
    });
  }

  Future<void> syncPendingTransactions() async {
    if (_firestore == null || _isar == null) return;

    final pending =
        await _isar!.pendingTransactions
            .filter()
            .isSyncedEqualTo(false)
            .findAll();

    if (pending.isEmpty) return;

    MinqLogger.info('Syncing ${pending.length} pending transactions...');

    for (final transaction in pending) {
      try {
        final payload = jsonDecode(transaction.payloadJson);
        if (transaction.method == 'awardPoints') {
          await awardPoints(
            userId: transaction.userId,
            basePoints: payload['basePoints'],
            reason: payload['reason'],
            difficultyMultiplier: payload['difficultyMultiplier'],
            consistencyMultiplier: payload['consistencyMultiplier'],
          );
        }
        // Add other methods as needed

        await _isar!.writeTxn(() async {
          transaction.isSynced = true;
          await _isar!.pendingTransactions.put(transaction);
        });
      } catch (e) {
        MinqLogger.error('Failed to sync transaction ${transaction.id}: $e');
      }
    }
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
