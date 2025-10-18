import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the service
final microCommitmentServiceProvider = Provider<MicroCommitmentService>((ref) {
  return MicroCommitmentService(FirebaseFirestore.instance);
});

class MicroCommitmentService {
  final FirebaseFirestore _firestore;

  MicroCommitmentService(this._firestore);

  /// Creates a "micro-quest" - a very short, easy-to-complete version of a task.
  Future<void> createMicroQuest({
    required String userId,
    required String title,
  }) async {
    // TODO: Implement logic to create a new quest with a "micro" type/flag
    // and save it to the user's quest list in Firestore.
    print("Creating micro-quest '$title' for user $userId.");
  }

  /// Suggests expanding a micro-quest after consistent completion.
  Future<void> suggestExpansion({
    required String userId,
    required String microQuestId,
  }) async {
    // TODO: Analyze the completion history of the micro-quest.
    // If the user is consistent, suggest increasing the goal or making it a regular quest.
    print("Checking if micro-quest $microQuestId can be expanded for user $userId.");
  }

  /// Offers a micro-quest version as a fallback when a regular quest is failed.
  void offerMicroFallback({
    required String userId,
    required String failedQuestId,
  }) {
    // TODO: This would likely trigger a UI event to prompt the user.
    // The prompt would offer to do a 10-second version of the failed quest instead.
    print("Offering micro-fallback for failed quest $failedQuestId to user $userId.");
  }
}