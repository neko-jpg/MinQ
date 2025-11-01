import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/providers.dart';

/// Core database service for managing Isar database operations
class DatabaseService {
  DatabaseService(this._isar);

  final Isar _isar;

  /// Get the Isar instance
  Isar get isar => _isar;

  /// Execute a transaction
  Future<T> transaction<T>(Future<T> Function() callback) async {
    return await _isar.writeTxn(callback);
  }

  /// Execute a read transaction
  Future<T> readTransaction<T>(Future<T> Function() callback) async {
    return await _isar.txn(callback);
  }

  /// Close the database
  Future<void> close() async {
    await _isar.close();
  }

  /// Get quests in date range
  Future<List<dynamic>> getQuestsInDateRange(DateTime start, DateTime end) async {
    return await _isar.localQuests
        .filter()
        .createdAtBetween(start, end)
        .findAll();
  }

  /// Get all completed quests
  Future<List<dynamic>> getAllCompletedQuests() async {
    return await _isar.localQuests
        .filter()
        .statusEqualTo(QuestStatus.active) // Assuming completed quests are marked differently
        .findAll();
  }

  /// Get failed quests (placeholder implementation)
  Future<List<Quest>> getFailedQuests() async {
    // TODO: Implement proper failed quest logic based on your domain model.
    return [];
  }

  /// Get user dashboards (placeholder implementation)
  Future<List<CustomDashboardConfig>> getUserDashboards(String userId) async {
    // TODO: Implement dashboard storage in Isar.
    return [];
  }

  /// Save dashboard config (placeholder implementation)
  Future<void> saveDashboardConfig(
    String userId,
    CustomDashboardConfig config,
  ) async {
    // TODO: Persist dashboard configuration to Isar.
  }

  /// Delete dashboard (placeholder implementation)
  Future<void> deleteDashboard(String userId, String dashboardId) async {
    // TODO: Implement dashboard deletion in Isar.
  }
}

/// Provider for the database service
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.when(
    data: (data) => DatabaseService(data),
    loading: () => throw StateError('Database not ready'),
    error: (error, stack) => throw error,
  );
});
