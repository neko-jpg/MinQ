import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for the service
final progressVisualizationServiceProvider = Provider<ProgressVisualizationService>((ref) {
  return ProgressVisualizationService(FirebaseFirestore.instance);
});

class ProgressVisualizationService {
  final FirebaseFirestore _firestore;

  ProgressVisualizationService(this._firestore);

  /// Calculates the current quest completion streak for a user.
  Future<int> calculateStreak(String userId) async {
    // TODO: Implement logic to analyze quest_logs and calculate the
    // number of consecutive days with at least one completed quest.
    print("Calculating streak for user $userId.");
    return 0; // Placeholder
  }

  /// Detects if a user has reached a significant milestone.
  Future<List<String>> detectMilestones(String userId) async {
    // TODO: Check for milestones like 7, 30, 100 day streaks.
    // This could be triggered after a streak calculation.
    print("Detecting milestones for user $userId.");
    return []; // e.g., ['7-day-streak', '100-quests-completed']
  }

  /// Detects if a user is at risk of breaking their streak.
  Future<bool> isStreakAtRisk(String userId) async {
    // TODO: Check if the user has completed a quest today.
    // If not, and they have an active streak, it's at risk.
    return false;
  }
}