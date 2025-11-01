import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/sync/background_sync_service.dart';
import 'package:minq/core/sync/cloud_database_service.dart';
import 'package:minq/core/sync/conflict_resolution_service.dart';
import 'package:minq/core/sync/database_cleanup_service.dart';
import 'package:minq/core/sync/offline_operations_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/services/isar_service.dart';

/// Provider for cloud database service
final cloudDatabaseServiceProvider = Provider<CloudDatabaseService>((ref) {
  return FirestoreCloudDatabaseService();
});

/// Provider for sync queue manager
final syncQueueManagerProvider = Provider<SyncQueueManager>((ref) {
  final isar = ref.read(isarServiceProvider).isar;
  final networkService = ref.read(networkStatusServiceProvider.notifier);
  final cloudService = ref.read(cloudDatabaseServiceProvider);

  final manager = SyncQueueManager(
    isar: isar,
    networkService: networkService,
    cloudService: cloudService,
  );

  // Initialize the manager
  manager.initialize();

  return manager;
});

/// Provider for offline operations service
final offlineOperationsServiceProvider = Provider<OfflineOperationsService>((
  ref,
) {
  final isar = ref.read(isarServiceProvider).isar;
  final syncQueueManager = ref.read(syncQueueManagerProvider);

  return OfflineOperationsService(
    isar: isar,
    syncQueueManager: syncQueueManager,
  );
});

/// Provider for conflict resolution service
final conflictResolutionServiceProvider = Provider<ConflictResolutionService>((
  ref,
) {
  final isar = ref.read(isarServiceProvider).isar;

  return ConflictResolutionService(isar: isar);
});

/// Provider for sync queue status
final syncQueueStatusProvider = StreamProvider<SyncQueueStatus>((ref) async* {
  final syncManager = ref.read(syncQueueManagerProvider);

  // Initial status
  yield await syncManager.getStatus();

  // Listen to status changes
  await for (final _ in syncManager.statusStream) {
    yield await syncManager.getStatus();
  }
});

/// Provider for checking if there are pending sync jobs
final hasPendingSyncJobsProvider = Provider<bool>((ref) {
  final status = ref.watch(syncQueueStatusProvider);
  return status.when(
    data: (status) => status.hasJobs,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for checking if sync is in progress
final isSyncingProvider = Provider<bool>((ref) {
  final status = ref.watch(syncQueueStatusProvider);
  return status.when(
    data: (status) => status.isProcessing,
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for database cleanup service
final databaseCleanupServiceProvider = Provider<DatabaseCleanupService>((ref) {
  final isar = ref.read(isarServiceProvider).isar;
  return DatabaseCleanupService(isar: isar);
});

/// Provider for background sync service
final backgroundSyncServiceProvider = Provider<BackgroundSyncService>((ref) {
  final syncQueueManager = ref.read(syncQueueManagerProvider);
  final networkService = ref.read(networkStatusServiceProvider.notifier);
  final cloudService = ref.read(cloudDatabaseServiceProvider);

  return BackgroundSyncService(
    syncQueueManager: syncQueueManager,
    networkService: networkService,
    cloudService: cloudService,
  );
});

/// Provider for Isar service (assuming it exists)
final isarServiceProvider = Provider<IsarService>((ref) {
  throw UnimplementedError(
    'IsarService provider should be implemented in the main providers file',
  );
});
