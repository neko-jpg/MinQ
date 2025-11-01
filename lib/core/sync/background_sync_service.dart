import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:workmanager/workmanager.dart';

/// Service for managing background synchronization
class BackgroundSyncService {
  BackgroundSyncService({
    required SyncQueueManager syncQueueManager,
    required NetworkStatusService networkService,
    required CloudDatabaseService cloudService,
  }) : _syncQueueManager = syncQueueManager,
       _networkService = networkService,
       _cloudService = cloudService;

  final SyncQueueManager _syncQueueManager;
  final NetworkStatusService _networkService;
  final CloudDatabaseService _cloudService;

  static const String _syncTaskName = 'background_sync_task';
  static const String _periodicSyncTaskName = 'periodic_sync_task';

  Timer? _syncTimer;
  bool _isInitialized = false;

  /// Initialize background sync service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize WorkManager for background tasks
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Register periodic sync task
      await _registerPeriodicSync();

      // Listen to network status changes
      _networkService.statusStream.listen((status) {
        if (status != NetworkStatus.offline) {
          _scheduleSyncTask();
        }
      });

      // Start periodic sync timer
      _startPeriodicSync();

      _isInitialized = true;
      MinqLogger.info('Background sync service initialized');
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Failed to initialize background sync service',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Register periodic background sync task
  Future<void> _registerPeriodicSync() async {
    try {
      await Workmanager().registerPeriodicTask(
        _periodicSyncTaskName,
        _periodicSyncTaskName,
        frequency: const Duration(hours: 1), // Sync every hour
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
      );

      MinqLogger.info('Periodic sync task registered');
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Failed to register periodic sync task',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Schedule immediate sync task
  Future<void> _scheduleSyncTask() async {
    if (!_networkService.isOnline) {
      MinqLogger.info('Skipping sync task - device is offline');
      return;
    }

    try {
      await Workmanager().registerOneOffTask(
        _syncTaskName,
        _syncTaskName,
        constraints: Constraints(networkType: NetworkType.connected),
      );

      MinqLogger.info('One-off sync task scheduled');
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Failed to schedule sync task',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Start periodic sync timer for foreground sync
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_networkService.isOnline) {
        _performForegroundSync();
      }
    });
  }

  /// Perform foreground sync
  Future<void> _performForegroundSync() async {
    try {
      await _syncQueueManager.processPendingJobs();
      MinqLogger.info('Foreground sync completed');
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Foreground sync failed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Force immediate sync
  Future<SyncResult> forceSyncNow() async {
    if (!_networkService.isOnline) {
      return const SyncResult(
        success: false,
        error: 'Device is offline',
        syncedItems: 0,
      );
    }

    try {
      MinqLogger.info('Starting forced sync');

      final startTime = DateTime.now();
      await _syncQueueManager.processPendingJobs();
      final duration = DateTime.now().difference(startTime);

      final status = await _syncQueueManager.getStatus();

      MinqLogger.info(
        'Forced sync completed',
        metadata: {
          'durationMs': duration.inMilliseconds,
          'pendingJobs': status.pendingJobs,
          'failedJobs': status.failedJobs,
        },
      );

      return SyncResult(
        success: true,
        syncedItems: status.pendingJobs,
        duration: duration,
      );
    } catch (e, stackTrace) {
      MinqLogger.error('Forced sync failed', error: e, stackTrace: stackTrace);

      return SyncResult(success: false, error: e.toString(), syncedItems: 0);
    }
  }

  /// Get sync status
  Future<BackgroundSyncStatus> getSyncStatus() async {
    final queueStatus = await _syncQueueManager.getStatus();

    return BackgroundSyncStatus(
      isOnline: _networkService.isOnline,
      pendingJobs: queueStatus.pendingJobs,
      failedJobs: queueStatus.failedJobs,
      isProcessing: queueStatus.isProcessing,
      lastSyncTime: await _getLastSyncTime(),
    );
  }

  /// Get last sync time from preferences
  Future<DateTime?> _getLastSyncTime() async {
    // This would typically read from SharedPreferences
    // For now, return null
    return null;
  }

  /// Set last sync time
  Future<void> _setLastSyncTime(DateTime time) async {
    // This would typically write to SharedPreferences
    MinqLogger.info(
      'Last sync time updated',
      metadata: {'time': time.toIso8601String()},
    );
  }

  /// Enable/disable background sync
  Future<void> setBackgroundSyncEnabled(bool enabled) async {
    try {
      if (enabled) {
        await _registerPeriodicSync();
        _startPeriodicSync();
        MinqLogger.info('Background sync enabled');
      } else {
        await Workmanager().cancelByUniqueName(_periodicSyncTaskName);
        _syncTimer?.cancel();
        MinqLogger.info('Background sync disabled');
      }
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Failed to toggle background sync',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    _syncTimer?.cancel();
    await Workmanager().cancelAll();
    _isInitialized = false;
    MinqLogger.info('Background sync service disposed');
  }
}

/// Background task callback dispatcher
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      MinqLogger.info('Background task started', metadata: {'task': task});

      switch (task) {
        case BackgroundSyncService._syncTaskName:
        case BackgroundSyncService._periodicSyncTaskName:
          await _performBackgroundSync();
          break;
        default:
          MinqLogger.warning(
            'Unknown background task',
            metadata: {'task': task},
          );
          return false;
      }

      MinqLogger.info('Background task completed', metadata: {'task': task});
      return true;
    } catch (e, stackTrace) {
      MinqLogger.error(
        'Background task failed',
        error: e,
        stackTrace: stackTrace,
        metadata: {'task': task},
      );
      return false;
    }
  });
}

/// Perform background sync operation
Future<void> _performBackgroundSync() async {
  // This would need to be implemented with proper dependency injection
  // For now, just log the operation
  MinqLogger.info('Performing background sync');

  // In a real implementation, you would:
  // 1. Initialize necessary services
  // 2. Check network connectivity
  // 3. Process pending sync jobs
  // 4. Update last sync time

  await Future.delayed(const Duration(seconds: 2)); // Simulate work
  MinqLogger.info('Background sync completed');
}

class SyncResult {
  final bool success;
  final String? error;
  final int syncedItems;
  final Duration? duration;

  const SyncResult({
    required this.success,
    this.error,
    required this.syncedItems,
    this.duration,
  });
}

class BackgroundSyncStatus {
  final bool isOnline;
  final int pendingJobs;
  final int failedJobs;
  final bool isProcessing;
  final DateTime? lastSyncTime;

  const BackgroundSyncStatus({
    required this.isOnline,
    required this.pendingJobs,
    required this.failedJobs,
    required this.isProcessing,
    this.lastSyncTime,
  });

  bool get hasIssues => failedJobs > 0 || (!isOnline && pendingJobs > 0);

  String get statusText {
    if (!isOnline) return 'Offline';
    if (isProcessing) return 'Syncing...';
    if (failedJobs > 0) return 'Sync Issues';
    if (pendingJobs > 0) return 'Pending Sync';
    return 'Up to Date';
  }
}
