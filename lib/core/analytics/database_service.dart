import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/domain/quest/quest.dart';

/// Database service abstraction for analytics
class DatabaseService {
  final Isar _isar;

  DatabaseService(this._isar);

  /// Get quests in date range
  Future<List<Quest>> getQuestsInDateRange(DateTime startDate, DateTime endDate) async {
    return await _isar.quests
        .filter()
        .createdAtBetween(startDate, endDate)
        .findAll();
  }

  /// Get all completed quests
  Future<List<Quest>> getAllCompletedQuests() async {
    return await _isar.quests
        .filter()
        .statusEqualTo(QuestStatus.active) // Assuming active means completed
        .findAll();
  }

  /// Get failed quests (placeholder implementation)
  Future<List<Quest>> getFailedQuests() async {
    // TODO: Implement proper failed quest logic based on your domain model
    return await _isar.quests
        .filter()
        .statusEqualTo(QuestStatus.paused) // Assuming paused means failed
        .findAll();
  }

  /// Get user dashboards
  Future<List<CustomDashboardConfig>> getUserDashboards(String userId) async {
    // TODO: Implement dashboard storage in Isar
    // For now, return empty list to trigger default dashboard creation
    return [];
  }

  /// Save dashboard config
  Future<void> saveDashboardConfig(String userId, CustomDashboardConfig config) async {
    // TODO: Implement dashboard storage in Isar
    // This is a placeholder implementation
  }

  /// Delete dashboard
  Future<void> deleteDashboard(String userId, String dashboardId) async {
    // TODO: Implement dashboard deletion in Isar
    // This is a placeholder implementation
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  return DatabaseService(isar);
});