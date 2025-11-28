import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

// Provider for the service
final progressVisualizationServiceProvider =
    Provider<ProgressVisualizationService>((ref) {
      return ProgressVisualizationService(FirebaseFirestore.instance);
    });

class ProgressVisualizationService {
  final FirebaseFirestore _firestore;

  ProgressVisualizationService(this._firestore);

  Future<QuerySnapshot> _getQuestLogs(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quest_logs')
        .orderBy('completedAt', descending: true)
        .get();
  }

  /// Calculates the current quest completion streak for a user.
  Future<int> calculateStreak(String userId) async {
    final snapshot = await _getQuestLogs(userId);
    if (snapshot.docs.isEmpty) return 0;

    final completionDates =
        snapshot.docs
            .map(
              (doc) =>
                  (doc.data() as Map<String, dynamic>)['completedAt']
                      as Timestamp,
            )
            .map((ts) => ts.toDate())
            .toSet() // Use a set to count unique days
            .toList();

    completionDates.sort((a, b) => b.compareTo(a)); // Sort descending

    int streak = 0;
    if (completionDates.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if the most recent completion was today or yesterday
    if (todayDate.difference(completionDates.first).inDays > 1) {
      return 0;
    }

    streak = 1;
    DateTime lastDate = completionDates.first;

    for (int i = 1; i < completionDates.length; i++) {
      final currentDate = completionDates[i];
      final difference = lastDate.difference(currentDate).inDays;

      if (difference == 1) {
        streak++;
      } else if (difference > 1) {
        break; // Streak is broken
      }
      // if difference is 0, it's the same day, so we just continue
      lastDate = currentDate;
    }

    return streak;
  }

  /// Detects if a user has reached a significant milestone.
  Future<List<String>> detectMilestones(String userId) async {
    final milestones = <String>[];
    final snapshot = await _getQuestLogs(userId);
    final totalQuests = snapshot.docs.length;
    final streak = await calculateStreak(userId);

    if (totalQuests >= 1) milestones.add('1-quest-completed');
    if (totalQuests >= 10) milestones.add('10-quests-completed');
    if (totalQuests >= 50) milestones.add('50-quests-completed');
    if (totalQuests >= 100) milestones.add('100-quests-completed');

    if (streak >= 3) milestones.add('3-day-streak');
    if (streak >= 7) milestones.add('7-day-streak');
    if (streak >= 30) milestones.add('30-day-streak');
    if (streak >= 100) milestones.add('100-day-streak');

    debugPrint('Detected milestones for user $userId: $milestones');
    return milestones;
  }

  /// Detects if a user is at risk of breaking their streak.
  Future<bool> isStreakAtRisk(String userId) async {
    final streak = await calculateStreak(userId);
    if (streak == 0) return false;

    final snapshot = await _getQuestLogs(userId);
    if (snapshot.docs.isEmpty) return false;

    final lastCompletion =
        (snapshot.docs.first.data() as Map<String, dynamic>)['completedAt']
            as Timestamp;
    final lastCompletionDate = lastCompletion.toDate();
    final today = DateTime.now();

    final isToday =
        lastCompletionDate.year == today.year &&
        lastCompletionDate.month == today.month &&
        lastCompletionDate.day == today.day;

    return !isToday;
  }
}
