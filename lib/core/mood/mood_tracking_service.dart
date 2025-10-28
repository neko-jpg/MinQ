import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/domain/mood/mood_state.dart';
import 'package:uuid/uuid.dart';

// Provider for the service
final moodTrackingServiceProvider = Provider<MoodTrackingService>((ref) {
  return MoodTrackingService(FirebaseFirestore.instance);
});

class MoodTrackingService {
  final FirebaseFirestore _firestore;
  final Uuid _uuid = const Uuid();

  MoodTrackingService(this._firestore);

  /// Records a user's mood at a specific moment.
  Future<void> recordMood({
    required String userId,
    required String mood,
    required int rating,
  }) async {
    final moodState = MoodState(
      id: _uuid.v4(),
      userId: userId,
      mood: mood,
      rating: rating,
      createdAt: DateTime.now(),
    );
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('mood_logs')
          .doc(moodState.id)
          .set(moodState.toJson());
      MinqLogger.info(
        'Recorded mood for user',
        metadata: {'userId': userId, 'mood': mood, 'rating': rating},
      );
    } catch (e) {
      MinqLogger.error(
        'Error recording mood',
        exception: e,
        metadata: {'userId': userId},
      );
    }
  }

  /// Analyzes the correlation between a user's mood and their habit success rates.
  Future<void> analyzeMoodHabitCorrelation(String userId) async {
    try {
      // 1. Fetch user's mood logs and quest logs
      final moodLogsSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('mood_logs')
              .orderBy('createdAt', descending: true)
              .limit(100) // Limit to recent data for performance
              .get();
      final questLogsSnapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('quest_logs')
              .orderBy('completedAt', descending: true)
              .limit(300) // Limit to recent data
              .get();

      if (moodLogsSnapshot.docs.isEmpty || questLogsSnapshot.docs.isEmpty) {
        MinqLogger.info(
          'Not enough data to analyze mood-habit correlation',
          metadata: {'userId': userId},
        );
        return;
      }

      final moodLogs =
          moodLogsSnapshot.docs
              .map((doc) => MoodState.fromJson(doc.data()))
              .toList();
      final questLogs =
          questLogsSnapshot.docs
              .map((doc) => doc.data()['completedAt'] as Timestamp)
              .toList();

      // 2. Group quests by date
      final questsByDate = <DateTime, int>{};
      for (final ts in questLogs) {
        final date = DateTime(
          ts.toDate().year,
          ts.toDate().month,
          ts.toDate().day,
        );
        questsByDate.update(date, (count) => count + 1, ifAbsent: () => 1);
      }

      // 3. Calculate correlation
      final correlationData = <String, Map<String, double>>{};
      final uniqueMoods = moodLogs.map((log) => log.mood).toSet();

      for (final mood in uniqueMoods) {
        int daysWithMood = 0;
        int questsOnMoodDays = 0;

        final moodDays =
            moodLogs
                .where((log) => log.mood == mood)
                .map(
                  (log) => DateTime(
                    log.createdAt.year,
                    log.createdAt.month,
                    log.createdAt.day,
                  ),
                )
                .toSet();

        daysWithMood = moodDays.length;

        for (final day in moodDays) {
          questsOnMoodDays += questsByDate[day] ?? 0;
        }

        final avgQuestsOnMoodDay =
            (daysWithMood > 0) ? questsOnMoodDays / daysWithMood : 0.0;

        correlationData[mood] = {
          'average_quests': avgQuestsOnMoodDay,
          'mood_day_count': daysWithMood.toDouble(),
        };
      }

      // 4. Save the correlation results
      await _firestore.collection('users').doc(userId).update({
        'moodHabitCorrelation': correlationData,
        'lastCorrelationAnalysis': FieldValue.serverTimestamp(),
      });

      MinqLogger.info(
        'Successfully analyzed and saved mood-habit correlation for user',
        metadata: {'userId': userId},
      );
    } catch (e) {
      MinqLogger.error(
        'Error analyzing mood-habit correlation',
        exception: e,
        metadata: {'userId': userId},
      );
    }
  }
}
