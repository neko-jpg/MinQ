import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:minq/core/challenges/challenge_service.dart';
import 'package:minq/core/logging/app_logger.dart';

// Provider for the service
final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  final challengeService = ref.watch(challengeServiceProvider);
  if (challengeService == null) {
    throw Exception('ChallengeService not available');
  }
  return HealthSyncService(challengeService);
});

class HealthSyncService {
  final Health _health = Health();
  final ChallengeService _challengeService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HealthSyncService(this._challengeService);

  /// Requests permission to access health data.
  Future<bool> requestPermissions() async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      bool requested = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      return requested;
    } catch (e) {
      logger.error('Error requesting health permissions: $e');
      return false;
    }
  }

  /// Fetches health data for a given period.
  Future<List<HealthDataPoint>> syncHealthData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: endDate,
        types: types,
      );
      // Remove duplicates
      healthData = _health.removeDuplicates(healthData);
      return healthData;
    } catch (e) {
      logger.error('Error fetching health data: $e');
      return [];
    }
  }

  /// Auto-updates quests based on the fetched health data.
  Future<void> autoUpdateQuestsFromHealthData(
    String userId,
    List<HealthDataPoint> healthData,
  ) async {
    if (healthData.isEmpty) {
      logger.info('No new health data to process.');
      return;
    }

    // 1. Aggregate health data by type
    final aggregatedData = <HealthDataType, num>{};
    for (final point in healthData) {
      final value = (point.value as NumericHealthValue).numericValue;
      aggregatedData.update(
        point.type,
        (currentValue) => currentValue + value,
        ifAbsent: () => value,
      );
    }
    logger.info('Aggregated health data: $aggregatedData');

    // 2. Fetch user's active, uncompleted, health-related quests
    final questSnapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('quests')
            .where('completed', isEqualTo: false)
            .where('healthType', whereIn: ['STEPS', 'SLEEP', 'CALORIES'])
            .get();

    if (questSnapshot.docs.isEmpty) {
      logger.info('No relevant health quests to update.');
      return;
    }

    int completedQuestsCount = 0;

    // 3. Check for completion and update
    for (final questDoc in questSnapshot.docs) {
      final quest = questDoc.data();
      final healthTypeString = quest['healthType'] as String;
      final goal = quest['goal'] as num;

      HealthDataType? healthType;
      switch (healthTypeString) {
        case 'STEPS':
          healthType = HealthDataType.STEPS;
          break;
        case 'SLEEP':
          healthType = HealthDataType.SLEEP_ASLEEP;
          break;
        case 'CALORIES':
          healthType = HealthDataType.ACTIVE_ENERGY_BURNED;
          break;
      }

      if (healthType != null && (aggregatedData[healthType] ?? 0) >= goal) {
        // Mark quest as complete
        await questDoc.reference.update({'completed': true});
        logger.info("Auto-completed quest: ${quest['name']}");
        completedQuestsCount++;

        // Also log the completion
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('quest_logs')
            .add({
              'questId': questDoc.id,
              'name': quest['name'],
              'completedAt': FieldValue.serverTimestamp(),
            });
      }
    }

    // 4. Update challenge progress if any quests were completed
    if (completedQuestsCount > 0) {
      // Assuming daily and weekly challenges are based on quest count
      final dailyChallengeId =
          'daily_${DateTime.now().year}_${DateTime.now().month}_${DateTime.now().day}';
      final weeklyChallengeId =
          'weekly_${DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).year}_${DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).month}_${DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)).day}';

      await _challengeService.updateProgress(
        challengeId: dailyChallengeId,
        incrementBy: completedQuestsCount,
      );
      await _challengeService.updateProgress(
        challengeId: weeklyChallengeId,
        incrementBy: completedQuestsCount,
      );
    }
  }
}
