import 'package:isar/isar.dart';
import 'package:minq/core/database/database_performance_monitor.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/domain/log/quest_log.dart';

/// Enhanced quest log repository with performance monitoring and memory management
class EnhancedQuestLogRepository extends QuestLogRepository with DatabasePerformanceTracking {
  EnhancedQuestLogRepository(super.isar);

  @override
  Future<List<QuestLog>> getLogsForUser(String uid) {
    return trackOperation('quest_log_get_by_user', () => super.getLogsForUser(uid));
  }

  @override
  Future<List<QuestLog>> getLogsForDay(String uid, DateTime day) {
    return trackOperation('quest_log_get_by_day', () => super.getLogsForDay(uid, day));
  }

  @override
  Future<int> countLogsForDay(String uid, DateTime day) {
    return trackOperation('quest_log_count_by_day', () => super.countLogsForDay(uid, day));
  }

  @override
  Future<void> addLog(QuestLog log) {
    return trackOperation('quest_log_add', () => super.addLog(log));
  }

  @override
  Future<void> deleteLog(int logId) {
    return trackOperation('quest_log_delete', () => super.deleteLog(logId));
  }

  @override
  Future<int> calculateStreak(String uid) {
    return trackOperation('quest_log_calculate_streak', () => super.calculateStreak(uid));
  }

  @override
  Future<int> calculateLongestStreak(String uid) {
    return trackOperation('quest_log_calculate_longest_streak', () => super.calculateLongestStreak(uid));
  }

  @override
  Future<Map<DateTime, int>> getHeatmapData(String uid) {
    return trackOperation('quest_log_get_heatmap', () => super.getHeatmapData(uid));
  }

  @override
  Future<bool> hasCompletedDailyGoal(String uid, {DateTime? day, int targetCount = 3}) {
    return trackOperation('quest_log_check_daily_goal', () => super.hasCompletedDailyGoal(uid, day: day, targetCount: targetCount));
  }

  @override
  Future<bool> hasUnsyncedLogs(String uid) {
    return trackOperation('quest_log_check_unsynced', () => super.hasUnsyncedLogs(uid));
  }

  @override
  Future<void> markLogsAsSynced(List<int> ids) {
    return trackOperation('quest_log_mark_synced', () => super.markLogsAsSynced(ids));
  }

  /// Optimized batch operations
  Future<void> saveLogsBatch(List<QuestLog> logs) {
    return trackOperation('quest_log_save_batch', () async {
      await isar.writeTxn(() async {
        await isar.questLogs.putAll(logs);
      });
    });
  }

  /// Clean up old logs to free memory and storage
  Future<int> cleanupOldLogs({
    Duration olderThan = const Duration(days: 365),
    bool keepSyncedOnly = false,
  }) {
    return trackOperation('quest_log_cleanup', () async {
      final cutoffDate = DateTime.now().subtract(olderThan);

      return await isar.writeTxn(() async {
        var query = isar.questLogs.filter().tsLessThan(cutoffDate);

        if (keepSyncedOnly) {
          query = query.and().syncedEqualTo(true);
        }

        final oldLogs = await query.findAll();
        final idsToDelete = oldLogs.map((log) => log.id).toList();

        await isar.questLogs.deleteAll(idsToDelete);

        return idsToDelete.length;
      });
    });
  }

  /// Get logs within date range with pagination
  Future<List<QuestLog>> getLogsInRange(
    String uid,
    DateTime startDate,
    DateTime endDate, {
    int? limit,
    int offset = 0,
  }) {
    return trackOperation('quest_log_get_range', () async {
      var query = isar.questLogs
          .filter()
          .uidEqualTo(uid)
          .and()
          .tsBetween(startDate, endDate)
          .sortByTsDesc();

      if (offset > 0) {
        query = query.offset(offset);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return await query.findAll();
    });
  }

  /// Get aggregated statistics for performance monitoring
  Future<QuestLogRepositoryStats> getStats(String uid) {
    return trackOperation('quest_log_get_stats', () async {
      final totalLogs = await isar.questLogs.filter().uidEqualTo(uid).count();
      final syncedLogs = await isar.questLogs
          .filter()
          .uidEqualTo(uid)
          .and()
          .syncedEqualTo(true)
          .count();
      final unsyncedLogs = totalLogs - syncedLogs;

      final currentStreak = await calculateStreak(uid);
      final longestStreak = await calculateLongestStreak(uid);

      return QuestLogRepositoryStats(
        totalLogs: totalLogs,
        syncedLogs: syncedLogs,
        unsyncedLogs: unsyncedLogs,
        currentStreak: currentStreak,
        longestStreak: longestStreak,
      );
    });
  }

  /// Optimize database indexes for better performance
  Future<void> optimizeIndexes() {
    return trackOperation('quest_log_optimize_indexes', () async {
      // Isar automatically manages indexes, but we can trigger optimization
      // by performing queries that use different indexes

      await isar.questLogs.filter().uidIsNotEmpty().count();
      await isar.questLogs.filter().syncedEqualTo(false).count();
      await isar.questLogs.filter().questIdGreaterThan(0).count();
    });
  }
}

/// Quest log repository statistics
class QuestLogRepositoryStats {
  final int totalLogs;
  final int syncedLogs;
  final int unsyncedLogs;
  final int currentStreak;
  final int longestStreak;

  const QuestLogRepositoryStats({
    required this.totalLogs,
    required this.syncedLogs,
    required this.unsyncedLogs,
    required this.currentStreak,
    required this.longestStreak,
  });

  @override
  String toString() {
    return 'QuestLogRepositoryStats('
        'total: $totalLogs, '
        'synced: $syncedLogs, '
        'unsynced: $unsyncedLogs, '
        'currentStreak: $currentStreak, '
        'longestStreak: $longestStreak)';
  }
}