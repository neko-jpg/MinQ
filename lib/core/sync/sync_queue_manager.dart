import 'dart:async';
import 'dart:math' as math;

import 'package:isar/isar.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/data/logging/minq_logger.dart';

part 'sync_queue_manager.g.dart';

/// Manages the synchronization queue for offline-first operations
class SyncQueueManager {
  SyncQueueManager({
    required Isar isar,
    required NetworkStatusService networkService,
    required CloudDatabaseService cloudService,
  }) : _isar = isar, _networkService = networkService, _cloudService = cloudService;

  final Isar _isar;
  final NetworkStatusService _networkService;
  final CloudDatabaseService _cloudService;
  
  static const int maxRetries = 5;
  static const Duration baseRetryDelay = Duration(seconds: 2);
  
  Timer? _processingTimer;
  bool _isProcessing = false;
  
  final StreamController<SyncStatus> _statusController = 
      StreamController<SyncStatus>.broadcast();
  
  Stream<SyncStatus> get statusStream => _statusController.stream;
  
  /// Initialize the sync queue manager
  Future<void> initialize() async {
    // Listen to network status changes
    _networkService.statusStream.listen((status) {
      if (status != NetworkStatus.offline && !_isProcessing) {
        _scheduleProcessing();
      }
    });
    
    // Start periodic processing if online
    if (_networkService.isOnline) {
      _scheduleProcessing();
    }
  }
  
  /// Enqueue a sync job
  Future<void> enqueueSyncJob(SyncJob job) async {
    await _isar.writeTxn(() async {
      await _isar.syncJobs.put(job);
    });
    
    MinqLogger.info('Sync job enqueued', metadata: {
      'entityType': job.entityType,
      'operation': job.operation,
      'entityId': job.entityId,
    });
    
    // Trigger immediate processing if online
    if (_networkService.isOnline && !_isProcessing) {
      _scheduleProcessing();
    }
  }
  
  /// Process pending sync jobs
  Future<void> processPendingJobs() async {
    if (_isProcessing || _networkService.isOffline) {
      return;
    }
    
    _isProcessing = true;
    _statusController.add(SyncStatus.syncing);
    
    try {
      final pendingJobs = await _isar.syncJobs
          .filter()
          .statusEqualTo(SyncJobStatus.pending)
          .or()
          .statusEqualTo(SyncJobStatus.failed)
          .and()
          .nextRetryAtIsNull()
          .or()
          .nextRetryAtLessThan(DateTime.now())
          .sortByPriority()
          .findAll();
      
      MinqLogger.info('Processing sync jobs', metadata: {
        'count': pendingJobs.length,
      });
      
      for (final job in pendingJobs) {
        if (_networkService.isOffline) {
          break; // Stop processing if network goes offline
        }
        
        await _processSyncJob(job);
      }
      
      final remainingJobs = await _getPendingJobsCount();
      if (remainingJobs > 0) {
        _statusController.add(SyncStatus.pending);
        _scheduleProcessing(); // Schedule retry for failed jobs
      } else {
        _statusController.add(SyncStatus.synced);
      }
    } catch (e, stackTrace) {
      MinqLogger.error('Error processing sync jobs', error: e, stackTrace: stackTrace);
      _statusController.add(SyncStatus.failed);
    } finally {
      _isProcessing = false;
    }
  }
  
  /// Process a single sync job
  Future<void> _processSyncJob(SyncJob job) async {
    try {
      // Update job status to syncing
      job.status = SyncJobStatus.syncing;
      job.lastAttemptAt = DateTime.now();
      await _isar.writeTxn(() => _isar.syncJobs.put(job));
      
      final result = await _executeSyncJob(job);
      
      if (result.isSuccess) {
        // Remove successful job from queue
        await _isar.writeTxn(() => _isar.syncJobs.delete(job.id));
        MinqLogger.info('Sync job completed successfully', metadata: {
          'entityType': job.entityType,
          'operation': job.operation,
          'entityId': job.entityId,
        });
      } else {
        // Handle failure
        job.retryCount++;
        job.lastError = result.error;
        
        if (job.retryCount >= maxRetries) {
          job.status = SyncJobStatus.failed;
          job.nextRetryAt = null; // Stop retrying
          MinqLogger.error('Sync job failed permanently', metadata: {
            'entityType': job.entityType,
            'operation': job.operation,
            'entityId': job.entityId,
            'error': result.error,
          });
        } else {
          job.status = SyncJobStatus.pending;
          job.nextRetryAt = DateTime.now().add(
            Duration(seconds: baseRetryDelay.inSeconds * math.pow(2, job.retryCount).toInt())
          );
          MinqLogger.warning('Sync job failed, will retry', metadata: {
            'entityType': job.entityType,
            'operation': job.operation,
            'entityId': job.entityId,
            'retryCount': job.retryCount,
            'nextRetry': job.nextRetryAt?.toIso8601String(),
            'error': result.error,
          });
        }
        
        await _isar.writeTxn(() => _isar.syncJobs.put(job));
      }
    } catch (e, stackTrace) {
      MinqLogger.error('Error processing sync job', error: e, stackTrace: stackTrace, metadata: {
        'entityType': job.entityType,
        'operation': job.operation,
        'entityId': job.entityId,
      });
      
      // Mark job as failed
      job.retryCount++;
      job.status = job.retryCount >= maxRetries 
          ? SyncJobStatus.failed 
          : SyncJobStatus.pending;
      job.lastError = e.toString();
      job.nextRetryAt = job.retryCount < maxRetries 
          ? DateTime.now().add(Duration(seconds: baseRetryDelay.inSeconds * math.pow(2, job.retryCount).toInt()))
          : null;
      
      await _isar.writeTxn(() => _isar.syncJobs.put(job));
    }
  }
  
  /// Execute a sync job
  Future<SyncResult> _executeSyncJob(SyncJob job) async {
    switch (job.entityType) {
      case 'quest':
        return await _syncQuest(job);
      case 'user':
        return await _syncUser(job);
      case 'challenge':
        return await _syncChallenge(job);
      case 'questLog':
        return await _syncQuestLog(job);
      default:
        return SyncResult.failure('Unknown entity type: ${job.entityType}');
    }
  }
  
  /// Sync quest data
  Future<SyncResult> _syncQuest(SyncJob job) async {
    try {
      switch (job.operation) {
        case 'create':
        case 'update':
          final result = await _cloudService.upsertQuest(job.data);
          return result.isSuccess 
              ? SyncResult.success() 
              : SyncResult.failure(result.error);
        case 'delete':
          final result = await _cloudService.deleteQuest(job.entityId);
          return result.isSuccess 
              ? SyncResult.success() 
              : SyncResult.failure(result.error);
        default:
          return SyncResult.failure('Unknown operation: ${job.operation}');
      }
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Sync user data
  Future<SyncResult> _syncUser(SyncJob job) async {
    try {
      switch (job.operation) {
        case 'create':
        case 'update':
          final result = await _cloudService.upsertUser(job.data);
          return result.isSuccess 
              ? SyncResult.success() 
              : SyncResult.failure(result.error);
        default:
          return SyncResult.failure('Unknown operation: ${job.operation}');
      }
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Sync challenge data
  Future<SyncResult> _syncChallenge(SyncJob job) async {
    try {
      switch (job.operation) {
        case 'create':
        case 'update':
          final result = await _cloudService.upsertChallenge(job.data);
          return result.isSuccess 
              ? SyncResult.success() 
              : SyncResult.failure(result.error);
        case 'delete':
          final result = await _cloudService.deleteChallenge(job.entityId);
          return result.isSuccess 
              ? SyncResult.success() 
              : SyncResult.failure(result.error);
        default:
          return SyncResult.failure('Unknown operation: ${job.operation}');
      }
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Sync quest log data
  Future<SyncResult> _syncQuestLog(SyncJob job) async {
    try {
      switch (job.operation) {
        case 'create':
        case 'update':
          final result = await _cloudService.upsertQuestLog(job.data);
          return result.isSuccess 
              ? SyncResult.success() 
              : SyncResult.failure(result.error);
        case 'delete':
          final result = await _cloudService.deleteQuestLog(job.entityId);
          return result.isSuccess 
              ? SyncResult.success() 
              : SyncResult.failure(result.error);
        default:
          return SyncResult.failure('Unknown operation: ${job.operation}');
      }
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }
  
  /// Get count of pending jobs
  Future<int> _getPendingJobsCount() async {
    return await _isar.syncJobs
        .filter()
        .statusEqualTo(SyncJobStatus.pending)
        .or()
        .statusEqualTo(SyncJobStatus.failed)
        .and()
        .nextRetryAtIsNotNull()
        .and()
        .nextRetryAtLessThan(DateTime.now())
        .count();
  }
  
  /// Schedule processing with delay
  void _scheduleProcessing() {
    _processingTimer?.cancel();
    _processingTimer = Timer(const Duration(seconds: 1), () {
      processPendingJobs();
    });
  }
  
  /// Get sync queue status
  Future<SyncQueueStatus> getStatus() async {
    final pendingCount = await _isar.syncJobs
        .filter()
        .statusEqualTo(SyncJobStatus.pending)
        .count();
    
    final failedCount = await _isar.syncJobs
        .filter()
        .statusEqualTo(SyncJobStatus.failed)
        .count();
    
    final syncingCount = await _isar.syncJobs
        .filter()
        .statusEqualTo(SyncJobStatus.syncing)
        .count();
    
    return SyncQueueStatus(
      pendingJobs: pendingCount,
      failedJobs: failedCount,
      syncingJobs: syncingCount,
      isOnline: _networkService.isOnline,
      isProcessing: _isProcessing,
    );
  }
  
  /// Clear all failed jobs
  Future<void> clearFailedJobs() async {
    await _isar.writeTxn(() async {
      await _isar.syncJobs
          .filter()
          .statusEqualTo(SyncJobStatus.failed)
          .deleteAll();
    });
  }
  
  /// Retry all failed jobs
  Future<void> retryFailedJobs() async {
    await _isar.writeTxn(() async {
      final failedJobs = await _isar.syncJobs
          .filter()
          .statusEqualTo(SyncJobStatus.failed)
          .findAll();
      
      for (final job in failedJobs) {
        job.status = SyncJobStatus.pending;
        job.retryCount = 0;
        job.nextRetryAt = null;
        job.lastError = null;
        await _isar.syncJobs.put(job);
      }
    });
    
    if (_networkService.isOnline) {
      _scheduleProcessing();
    }
  }
  
  /// Dispose resources
  Future<void> dispose() async {
    _processingTimer?.cancel();
    await _statusController.close();
  }
}

@Collection()
class SyncJob {
  Id id = Isar.autoIncrement;
  
  late String entityType; // 'quest', 'user', 'challenge', 'questLog'
  late String entityId;
  late String operation; // 'create', 'update', 'delete'
  late Map<String, dynamic> data;
  
  late DateTime createdAt;
  DateTime? nextRetryAt;
  DateTime? lastAttemptAt;
  
  int retryCount = 0;
  int priority = 0; // Higher number = higher priority
  
  @Enumerated(EnumType.name)
  SyncJobStatus status = SyncJobStatus.pending;
  
  String? lastError;
}

enum SyncJobStatus { pending, syncing, completed, failed }

enum SyncStatus { synced, pending, syncing, failed, conflict }

class SyncResult {
  final bool isSuccess;
  final String? error;
  final Map<String, dynamic>? data;
  
  const SyncResult._({
    required this.isSuccess,
    this.error,
    this.data,
  });
  
  factory SyncResult.success([Map<String, dynamic>? data]) {
    return SyncResult._(isSuccess: true, data: data);
  }
  
  factory SyncResult.failure(String error) {
    return SyncResult._(isSuccess: false, error: error);
  }
}

class SyncQueueStatus {
  final int pendingJobs;
  final int failedJobs;
  final int syncingJobs;
  final bool isOnline;
  final bool isProcessing;
  
  const SyncQueueStatus({
    required this.pendingJobs,
    required this.failedJobs,
    required this.syncingJobs,
    required this.isOnline,
    required this.isProcessing,
  });
  
  bool get hasJobs => pendingJobs > 0 || failedJobs > 0 || syncingJobs > 0;
  bool get isIdle => !hasJobs && !isProcessing;
}

/// Abstract interface for cloud database operations
abstract class CloudDatabaseService {
  Future<SyncResult> upsertQuest(Map<String, dynamic> data);
  Future<SyncResult> deleteQuest(String questId);
  Future<SyncResult> upsertUser(Map<String, dynamic> data);
  Future<SyncResult> upsertChallenge(Map<String, dynamic> data);
  Future<SyncResult> deleteChallenge(String challengeId);
  Future<SyncResult> upsertQuestLog(Map<String, dynamic> data);
  Future<SyncResult> deleteQuestLog(String logId);
}