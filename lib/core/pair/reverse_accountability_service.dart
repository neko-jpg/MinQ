import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the service
final reverseAccountabilityServiceProvider = Provider<ReverseAccountabilityService>((ref) {
  return ReverseAccountabilityService(FirebaseFirestore.instance);
});

class ReverseAccountabilityService {
  final FirebaseFirestore _firestore;

  ReverseAccountabilityService(this._firestore);

  /// Notifies a user's pair when they complete a quest.
  Future<void> notifyPairOfSuccess({
    required String userId,
    required String pairId,
  }) async {
    // TODO: Send a gentle, positive notification to the pair.
    // e.g., "あなたのペアが今日も頑張りました！"
    print("Notifying pair $pairId of success for user $userId.");
  }

  /// Creates a "resonance bonus" when both members of a pair complete their daily quests.
  Future<void> createResonanceBonus({
    required String pairId,
    required String user1Id,
    required String user2Id,
  }) async {
    // TODO: Check if both users have completed their daily quests.
    // If so, award a special "共鳴ボーナス" reward to both.
    print("Checking for resonance bonus for pair $pairId.");
  }

  /// Prompts a user to send a supportive message to their partner if they are struggling.
  void sendSupportPrompt({
    required String userId,
    required String strugglingPairId,
  }) {
    // TODO: Trigger a UI prompt with pre-written supportive message templates.
    print("Prompting user $userId to support struggling pair $strugglingPairId.");
  }
}