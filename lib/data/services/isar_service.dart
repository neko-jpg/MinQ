import 'package:isar/isar.dart';
import 'package:minq/core/database/database_lifecycle_manager.dart';
import 'package:minq/core/database/database_performance_monitor.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/domain/badge/badge.dart';
import 'package:minq/domain/gamification/xp_transaction_isar.dart';
import 'package:minq/domain/log/quest_log.dart';
// import 'package:minq/domain/pair/pair.dart'; // Pair is Firestore-only for now
import 'package:minq/domain/quest/quest.dart';
import 'package:minq/domain/user/user.dart';

class IsarService with DatabasePerformanceTracking {
  final EnhancedIsarService _enhancedService = EnhancedIsarService();

  late final Isar isar;

  Future<Isar> init({
    Function(String message, double progress)? onProgress,
  }) async {
    return trackOperation('isar_init', () async {
      // Start performance monitoring
      DatabasePerformanceMonitor.instance.startMonitoring();

      final existing = Isar.getInstance();
      if (existing != null) {
        isar = existing;
        onProgress?.call('Using existing database instance', 1.0);
        return isar;
      }

      isar = await _enhancedService.init(
        schemas: [
          // Original schemas (for backward compatibility)
          QuestSchema,
          UserSchema,
          QuestLogSchema,
          BadgeSchema,
          // Gamification schemas
          XPTransactionIsarSchema,
          // New offline-first schemas
          LocalQuestSchema,
          LocalUserSchema,
          LocalChallengeSchema,
          LocalQuestLogSchema,
          SyncJobSchema,
        ],
        onProgress: onProgress,
      );

      return isar;
    });
  }

  /// Get database health status
  Future<DatabaseHealthStatus> getHealthStatus() {
    return _enhancedService.checkHealth();
  }

  /// Optimize database storage
  Future<void> optimize() {
    return trackOperation('isar_optimize', () => _enhancedService.optimize());
  }

  /// Check if database is ready
  bool get isReady => _enhancedService.isReady;

  /// Dispose database resources
  Future<void> dispose() async {
    await trackOperation('isar_dispose', () => _enhancedService.dispose());
    DatabasePerformanceMonitor.instance.dispose();
  }
}
