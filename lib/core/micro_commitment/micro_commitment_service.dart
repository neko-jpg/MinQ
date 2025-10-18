import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uuid/uuid.dart';

// Provider for the service
final microCommitmentServiceProvider = Provider<MicroCommitmentService>((ref) {
  return MicroCommitmentService(FirebaseFirestore.instance);
});

class MicroCommitmentService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  MicroCommitmentService(this._firestore);

  /// Creates a "micro-quest" - a very short, easy-to-complete version of a task.
  Future<void> createMicroQuest({
    required String userId,
    required String title,
    String? originalQuestId, // Optional: link to the original quest it's a fallback for
  }) async {
    final questId = _uuid.v4();
    try {
      await _firestore.collection('users').doc(userId).collection('quests').doc(questId).set({
        'id': questId,
        'name': title,
        'description': 'A small step to build momentum!',
        'isMicro': true,
        'completed': false,
        'createdAt': FieldValue.serverTimestamp(),
        'originalQuestId': originalQuestId,
      });
      print("Creating micro-quest '$title' for user $userId.");
    } catch (e) {
      print("Error creating micro-quest: $e");
    }
  }

  /// Suggests expanding a micro-quest after consistent completion.
  Future<String?> suggestExpansion({
    required String userId,
    required String microQuestName, // Check by name for simplicity
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quest_logs')
          .where('name', isEqualTo: microQuestName)
          .where('isMicro', isEqualTo: true)
          .orderBy('completedAt', descending: true)
          .limit(5)
          .get();

      if (snapshot.docs.length < 5) {
        return null; // Not enough completions to suggest expansion
      }

      // Check if the last 5 completions were on consecutive days (or close)
      final completionDates = snapshot.docs.map((doc) => (doc['completedAt'] as Timestamp).toDate()).toList();
      final daysDifference = completionDates.first.difference(completionDates.last).inDays;

      if (daysDifference <= 7) {
        final suggestion = "You've been consistent with '$microQuestName'! Ready to make it a regular habit?";
        print(suggestion);
        // In a real app, this might set a flag in the user's profile to show a UI prompt.
        return suggestion;
      }
    } catch (e) {
      print("Error suggesting expansion for $microQuestName: $e");
    }
    return null;
  }

  /// Offers a micro-quest version as a fallback when a regular quest is failed.
  void offerMicroFallback({
    required String userId,
    required String failedQuestName,
  }) {
    // This method's primary role is to trigger a UI change.
    // The logic here is simplified to demonstrate the concept.
    // In a real app, this might use a state management solution to show a dialog.
    print("UI TRIGGER: Offer micro-fallback for '$failedQuestName' to user $userId.");
    print("Suggestion: 'Feeling stuck on $failedQuestName? How about trying a 1-minute version instead?'");

    // For demonstration, we can directly create the micro-quest.
    createMicroQuest(userId: userId, title: "1-minute $failedQuestName");
  }
}