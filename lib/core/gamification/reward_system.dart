import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/reward.dart';
import 'package:flutter/foundation.dart';

// Provider for the system
final rewardSystemProvider = Provider<RewardSystem>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return RewardSystem(firestore);
});

class RewardSystem {
  final FirebaseFirestore? _firestore;

  RewardSystem(this._firestore);

  /// Fetches the list of available rewards.
  Future<List<Reward>> getAvailableRewards() async {
    // Firestoreが利用できない場合は空のリストを返す
    if (_firestore == null) {
      debugPrint('Rewards unavailable (offline mode)');
      return [];
    }

    try {
      final snapshot = await _firestore.collection('rewards').get();
      return snapshot.docs.map((doc) => Reward.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error fetching rewards: $e');
      return [];
    }
  }

  /// Redeems a reward for a user.
  Future<bool> redeemReward({
    required String userId,
    required String rewardId,
  }) async {
    // Firestoreが利用できない場合は失敗
    if (_firestore == null) {
      debugPrint('Reward redemption unavailable (offline mode)');
      return false;
    }

    final userRef = _firestore.collection('users').doc(userId);
    final rewardRef = _firestore.collection('rewards').doc(rewardId);

    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. Get current user points and the reward details
        final rewardSnapshot = await transaction.get(rewardRef);
        if (!rewardSnapshot.exists) {
          throw Exception('Reward not found!');
        }
        final reward = Reward.fromJson(rewardSnapshot.data()!);

        final pointsCollectionSnapshot =
            await userRef.collection('points_transactions').get();
        final currentPoints = pointsCollectionSnapshot.docs
            .map((doc) => doc.data()['value'] as int)
            .fold(0, (prev, el) => prev + el);

        // 2. Check if user has enough points
        if (currentPoints < reward.cost) {
          throw Exception('Not enough points!');
        }

        // 3. Deduct points (by adding a negative transaction)
        final pointsTransactionRef =
            userRef.collection('points_transactions').doc();
        transaction.set(pointsTransactionRef, {
          'value': -reward.cost,
          'reason': 'Redeemed ${reward.name}',
          'createdAt': FieldValue.serverTimestamp(),
          'userId': userId,
        });

        // 4. Add reward to user's inventory
        final userRewardRef = userRef.collection('user_rewards').doc(rewardId);
        transaction.set(userRewardRef, reward.toJson());

        return true;
      });
    } catch (e) {
      debugPrint('Error redeeming reward: $e');
      return false;
    }
  }

  /// Generates a variable (random) reward for the user.
  Future<Reward?> generateVariableReward(String userId) async {
    // This is a simplified example. A real implementation might fetch these from a remote config.
    final potentialRewards = [
      const Reward(
        id: 'surprise_1',
        name: 'Small Point Pouch',
        description: 'A little bonus!',
        cost: 0,
        type: 'consumable',
      ),
      const Reward(
        id: 'surprise_2',
        name: 'Medium Point Pouch',
        description: 'A nice bonus!',
        cost: 0,
        type: 'consumable',
      ),
      const Reward(
        id: 'surprise_3',
        name: 'Exclusive Icon',
        description: 'A rare profile icon!',
        cost: 0,
        type: 'icon',
      ),
    ];

    // Simple rarity simulation
    final rarity = (DateTime.now().millisecondsSinceEpoch % 100); // 0-99
    Reward selectedReward;
    if (rarity < 60) {
      // 60% chance
      selectedReward = potentialRewards[0];
    } else if (rarity < 90) {
      // 30% chance
      selectedReward = potentialRewards[1];
    } else {
      // 10% chance
      selectedReward = potentialRewards[2];
    }

    try {
      // Firestoreが利用できない場合はローカルログのみ
      if (_firestore == null) {
        debugPrint(
          'Surprise reward generated (offline mode): ${selectedReward.name}',
        );
        return selectedReward;
      }

      // For consumable point pouches, directly award points instead of adding to inventory
      if (selectedReward.type == 'consumable') {
        final points = selectedReward.name.contains('Small') ? 25 : 50;
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('points_transactions')
            .add({
              'value': points,
              'reason': 'Surprise Reward: ${selectedReward.name}',
              'createdAt': FieldValue.serverTimestamp(),
              'userId': userId,
            });
        debugPrint('Awarded $points surprise points to user $userId');
      } else {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('user_rewards')
            .doc(selectedReward.id)
            .set(selectedReward.toJson());
        debugPrint('Awarded surprise reward ${selectedReward.name} to user $userId');
      }
      return selectedReward;
    } catch (e) {
      debugPrint('Error generating variable reward: $e');
      return null;
    }
  }
}
