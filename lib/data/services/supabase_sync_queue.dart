import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:minq/domain/sync/pending_sync_job.dart';
import 'package:minq/domain/user/user.dart';

class SupabaseSyncQueue {
  SupabaseSyncQueue(this._isar, this._api);

  final Isar _isar;
  final SupabaseSyncApi _api;

  Future<void> enqueueUserProfile(User user) async {
    final payload = _userPayloadFor(user);

    await _isar.writeTxn(() async {
      await _isar.pendingSyncJobs
          .filter()
          .uidEqualTo(user.uid)
          .typeEqualTo(SyncJobTypes.userProfileUpsert)
          .deleteAll();

      await _isar.pendingSyncJobs.put(
        PendingSyncJob()
          ..uid = user.uid
          ..type = SyncJobTypes.userProfileUpsert
          ..payload = jsonEncode(payload)
          ..createdAt = DateTime.now().toUtc()
          ..attemptCount = 0
          ..lastAttemptAt = null
          ..lastError = null,
      );
    });
  }

  Future<int> pendingCount({String? uid}) async {
    return _isar.pendingSyncJobs
        .filter()
        .optional(uid != null, (q) => q.uidEqualTo(uid))
        .count();
  }

  Future<SyncQueueSummary> processPendingJobs({String? uid}) async {
    final jobs =
        await _isar.pendingSyncJobs
            .filter()
            .optional(uid != null, (q) => q.uidEqualTo(uid))
            .sortByCreatedAt()
            .findAll();

    if (jobs.isEmpty) {
      return const SyncQueueSummary(processed: 0, failed: 0, remaining: 0);
    }

    var processed = 0;
    var failed = 0;

    for (final job in jobs) {
      try {
        await _dispatch(job);
        await _isar.writeTxn(() => _isar.pendingSyncJobs.delete(job.id));
        processed++;
      } catch (error, stackTrace) {
        failed++;
        MinqLogger.error(
          'Supabase sync job failed',
          error: error,
          stackTrace: stackTrace,
          metadata: {'jobId': job.id, 'type': job.type},
        );
        await _markFailure(job, error);
      }
    }

    final remaining = await pendingCount(uid: uid);
    return SyncQueueSummary(
      processed: processed,
      failed: failed,
      remaining: remaining,
    );
  }

  Future<void> _dispatch(PendingSyncJob job) async {
    final payload = jsonDecode(job.payload) as Map<String, dynamic>;
    switch (job.type) {
      case SyncJobTypes.userProfileUpsert:
        await _api.upsertUserProfile(payload);
        break;
      default:
        throw UnsupportedError('Unknown sync job type: ${job.type}');
    }
  }

  Future<void> _markFailure(PendingSyncJob job, Object error) async {
    await _isar.writeTxn(() async {
      job
        ..attemptCount = job.attemptCount + 1
        ..lastAttemptAt = DateTime.now().toUtc()
        ..lastError = error.toString();
      await _isar.pendingSyncJobs.put(job);
    });
  }

  Map<String, dynamic> _userPayloadFor(User user) {
    return <String, dynamic>{
      'uid': user.uid,
      'displayName': user.displayName,
      'handle': user.handle,
      'bio': user.bio,
      'avatarSeed': user.avatarSeed,
      'focusTags': user.focusTags,
      'notificationTimes': user.notificationTimes,
      'currentStreak': user.currentStreak,
      'longestStreak': user.longestStreak,
      'longestStreakReachedAt': user.longestStreakReachedAt?.toIso8601String(),
      'pairId': user.pairId,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

class SyncQueueSummary {
  const SyncQueueSummary({
    required this.processed,
    required this.failed,
    required this.remaining,
  });

  final int processed;
  final int failed;
  final int remaining;
}

abstract class SupabaseSyncApi {
  Future<void> upsertUserProfile(Map<String, dynamic> payload);
}

class NoopSupabaseSyncApi implements SupabaseSyncApi {
  const NoopSupabaseSyncApi();

  @override
  Future<void> upsertUserProfile(Map<String, dynamic> payload) async {
    MinqLogger.debug(
      'Supabase sync skipped - Noop API in use',
      metadata: {'payload': payload},
    );
  }
}
