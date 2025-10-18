import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';

// Provider for the service
final healthSyncServiceProvider = Provider<HealthSyncService>((ref) {
  return HealthSyncService();
});

class HealthSyncService {
  final HealthFactory _health = HealthFactory();

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
      bool requested = await _health.requestAuthorization(types, permissions: permissions);
      return requested;
    } catch (e) {
      print("Error requesting health permissions: $e");
      return false;
    }
  }

  /// Fetches health data for a given period.
  Future<List<HealthDataPoint>> syncHealthData(DateTime startDate, DateTime endDate) async {
    final types = [
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    try {
      List<HealthDataPoint> healthData = await _health.getHealthDataFromTypes(startDate, endDate, types);
      // Remove duplicates
      healthData = HealthFactory.removeDuplicates(healthData);
      return healthData;
    } catch (e) {
      print("Error fetching health data: $e");
      return [];
    }
  }

  /// Auto-updates quests based on the fetched health data.
  Future<void> autoUpdateQuestsFromHealthData(String userId, List<HealthDataPoint> healthData) async {
    // TODO: Implement logic to:
    // 1. Map health data types to quest types.
    // 2. Check if health data meets quest completion thresholds.
    // 3. Mark corresponding quests as complete.
    print("Auto-updating quests for user $userId based on health data.");
  }
}