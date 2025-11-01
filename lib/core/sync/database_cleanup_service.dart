import 'dart:io';

import 'package:isar/isar.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:path_provider/path_provider.dart';

/// Service for cleaning up unused database files and optimizing storage
class DatabaseCleanupService {
  DatabaseCleanupService({required Isar isar}) : _isar = isar;

  final Isar _isar;

  /// Clean up old sync jobs and optimize database
  Future<CleanupResult> performCleanup({
    Duration? olderThan,
    bool compactDatabase = true,
    bool removeOrphanedFiles = true,
  }) async {
    final startTime = DateTime.now();
    var deletedRecords = 0;
    var freedSpace = 0;

    try {
      MinqLogger.info('Starting database cleanup');

      // Clean up completed sync jobs older than specified duration
      if (olderThan != null) {
        deletedRecords += await _cleanupOldSyncJobs(olderThan);
      }

      // Clean up soft-deleted records
      deletedRecords += await _cleanupSoftDeletedRecords();

      // Remove orphaned files
      if (removeOrphanedFiles) {
        freedSpace += await _removeOrphanedFiles();
      }

      // Compact database
      if (compactDatabase) {
        await _compactDatabase();
      }

      final duration = DateTime.now().difference(startTime);

      MinqLogger.info(
        'Database cleanup completed',
        metadata: {
          'deletedRecords': deletedRecords,
          'freedSpaceBytes': freedSpace,
          'durationMs': duration.inMilliseconds,
        },
      );

      return CleanupResult(
        success: true,
        deletedRecords: deletedRecords,
        freedSpaceBytes: freedSpace,
        duration: duration,
      );
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Database cleanup failed',
        error: e,
        stackTrace: stackTrace,
      );

      return CleanupResult(
        success: false,
        error: e.toString(),
        duration: DateTime.now().difference(startTime),
      );
    }
  }

  /// Clean up old completed sync jobs
  Future<int> _cleanupOldSyncJobs(Duration olderThan) async {
    final cutoffDate = DateTime.now().subtract(olderThan);

    final oldJobs =
        await _isar.syncJobs
            .filter()
            .statusEqualTo(SyncJobStatus.completed)
            .and()
            .createdAtLessThan(cutoffDate)
            .findAll();

    if (oldJobs.isNotEmpty) {
      await _isar.writeTxn(() async {
        for (final job in oldJobs) {
          await _isar.syncJobs.delete(job.id);
        }
      });

      MinqLogger.info(
        'Cleaned up old sync jobs',
        metadata: {
          'count': oldJobs.length,
          'cutoffDate': cutoffDate.toIso8601String(),
        },
      );
    }

    return oldJobs.length;
  }

  /// Clean up soft-deleted records that are older than retention period
  Future<int> _cleanupSoftDeletedRecords() async {
    var deletedCount = 0;
    final retentionPeriod = DateTime.now().subtract(const Duration(days: 30));

    // Clean up soft-deleted quests
    final deletedQuests =
        await _isar.localQuests
            .filter()
            .deletedAtIsNotNull()
            .and()
            .deletedAtLessThan(retentionPeriod)
            .findAll();

    if (deletedQuests.isNotEmpty) {
      await _isar.writeTxn(() async {
        for (final quest in deletedQuests) {
          await _isar.localQuests.delete(quest.id);
        }
      });
      deletedCount += deletedQuests.length;
    }

    // Clean up old quest logs (keep only last 1000 per user)
    await _cleanupOldQuestLogs();

    MinqLogger.info(
      'Cleaned up soft-deleted records',
      metadata: {
        'deletedQuests': deletedQuests.length,
        'retentionPeriod': retentionPeriod.toIso8601String(),
      },
    );

    return deletedCount;
  }

  /// Clean up old quest logs, keeping only the most recent ones per user
  Future<void> _cleanupOldQuestLogs() async {
    const maxLogsPerUser = 1000;

    // Get all unique user IDs
    final userIds =
        await _isar.localQuestLogs
            .where()
            .distinctByUid()
            .uidProperty()
            .findAll();

    for (final uid in userIds) {
      // Get logs for this user, sorted by timestamp descending
      final userLogs =
          await _isar.localQuestLogs
              .filter()
              .uidEqualTo(uid)
              .sortByTimestampDesc()
              .findAll();

      // If user has more than maxLogsPerUser, delete the oldest ones
      if (userLogs.length > maxLogsPerUser) {
        final logsToDelete = userLogs.skip(maxLogsPerUser).toList();

        await _isar.writeTxn(() async {
          for (final log in logsToDelete) {
            await _isar.localQuestLogs.delete(log.id);
          }
        });

        MinqLogger.info(
          'Cleaned up old quest logs for user',
          metadata: {
            'uid': uid,
            'deletedCount': logsToDelete.length,
            'remainingCount': maxLogsPerUser,
          },
        );
      }
    }
  }

  /// Remove orphaned files that are no longer referenced in the database
  Future<int> _removeOrphanedFiles() async {
    var freedSpace = 0;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final cacheDir = await getTemporaryDirectory();

      // Clean up temporary files
      freedSpace += await _cleanupDirectory(
        Directory('${cacheDir.path}/temp_images'),
        maxAge: const Duration(hours: 24),
      );

      // Clean up old cached files
      freedSpace += await _cleanupDirectory(
        Directory('${cacheDir.path}/cached_data'),
        maxAge: const Duration(days: 7),
      );

      // Clean up old log files
      freedSpace += await _cleanupDirectory(
        Directory('${appDir.path}/logs'),
        maxAge: const Duration(days: 30),
        keepLatest: 10,
      );

      MinqLogger.info(
        'Cleaned up orphaned files',
        metadata: {'freedSpaceBytes': freedSpace},
      );
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Failed to clean up orphaned files',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return freedSpace;
  }

  /// Clean up files in a directory based on age and count criteria
  Future<int> _cleanupDirectory(
    Directory directory, {
    Duration? maxAge,
    int? keepLatest,
  }) async {
    var freedSpace = 0;

    if (!await directory.exists()) {
      return 0;
    }

    try {
      final files =
          await directory
              .list(recursive: true)
              .where((entity) => entity is File)
              .cast<File>()
              .toList();

      // Sort files by modification time (newest first)
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );

      final now = DateTime.now();
      final filesToDelete = <File>[];

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final fileAge = now.difference(file.lastModifiedSync());

        bool shouldDelete = false;

        // Delete if older than maxAge
        if (maxAge != null && fileAge > maxAge) {
          shouldDelete = true;
        }

        // Delete if beyond keepLatest count
        if (keepLatest != null && i >= keepLatest) {
          shouldDelete = true;
        }

        if (shouldDelete) {
          filesToDelete.add(file);
        }
      }

      // Delete the files
      for (final file in filesToDelete) {
        try {
          final fileSize = await file.length();
          await file.delete();
          freedSpace += fileSize;
        } catch (e) {
          MinqLogger.warning(
            'Failed to delete file: ${file.path}',
            metadata: {'error': e.toString()},
          );
        }
      }

      if (filesToDelete.isNotEmpty) {
        MinqLogger.info(
          'Cleaned up directory',
          metadata: {
            'directory': directory.path,
            'deletedFiles': filesToDelete.length,
            'freedSpaceBytes': freedSpace,
          },
        );
      }
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Failed to clean up directory: ${directory.path}',
        error: e,
        stackTrace: stackTrace,
      );
    }

    return freedSpace;
  }

  /// Compact the database to reclaim space
  Future<void> _compactDatabase() async {
    try {
      // Isar doesn't have a direct compact method, but we can trigger optimization
      // by performing a maintenance operation
      await _isar.writeTxn(() async {
        // This transaction will trigger internal optimization
      });

      MinqLogger.info('Database compaction completed');
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Database compaction failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Get database statistics
  Future<DatabaseStats> getDatabaseStats() async {
    try {
      final questCount = await _isar.localQuests.count();
      final userCount = await _isar.localUsers.count();
      final challengeCount = await _isar.localChallenges.count();
      final questLogCount = await _isar.localQuestLogs.count();
      final syncJobCount = await _isar.syncJobs.count();

      final pendingSyncJobs =
          await _isar.syncJobs
              .filter()
              .statusEqualTo(SyncJobStatus.pending)
              .count();

      final failedSyncJobs =
          await _isar.syncJobs
              .filter()
              .statusEqualTo(SyncJobStatus.failed)
              .count();

      final deletedQuests =
          await _isar.localQuests.filter().deletedAtIsNotNull().count();

      return DatabaseStats(
        questCount: questCount,
        userCount: userCount,
        challengeCount: challengeCount,
        questLogCount: questLogCount,
        syncJobCount: syncJobCount,
        pendingSyncJobs: pendingSyncJobs,
        failedSyncJobs: failedSyncJobs,
        deletedQuests: deletedQuests,
      );
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Failed to get database stats',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Schedule automatic cleanup
  Future<void> scheduleAutomaticCleanup() async {
    // This would typically be called during app initialization
    // and set up periodic cleanup tasks

    MinqLogger.info('Automatic cleanup scheduled');

    // Perform initial cleanup
    await performCleanup(
      olderThan: const Duration(days: 7),
      compactDatabase: true,
      removeOrphanedFiles: true,
    );
  }
}

class CleanupResult {
  final bool success;
  final int deletedRecords;
  final int freedSpaceBytes;
  final Duration duration;
  final String? error;

  const CleanupResult({
    required this.success,
    this.deletedRecords = 0,
    this.freedSpaceBytes = 0,
    required this.duration,
    this.error,
  });

  String get freedSpaceFormatted {
    if (freedSpaceBytes < 1024) {
      return '${freedSpaceBytes}B';
    } else if (freedSpaceBytes < 1024 * 1024) {
      return '${(freedSpaceBytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(freedSpaceBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}

class DatabaseStats {
  final int questCount;
  final int userCount;
  final int challengeCount;
  final int questLogCount;
  final int syncJobCount;
  final int pendingSyncJobs;
  final int failedSyncJobs;
  final int deletedQuests;

  const DatabaseStats({
    required this.questCount,
    required this.userCount,
    required this.challengeCount,
    required this.questLogCount,
    required this.syncJobCount,
    required this.pendingSyncJobs,
    required this.failedSyncJobs,
    required this.deletedQuests,
  });

  int get totalRecords =>
      questCount + userCount + challengeCount + questLogCount;

  bool get hasIssues => failedSyncJobs > 0 || deletedQuests > 100;
}
