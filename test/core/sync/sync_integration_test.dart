import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/sync/background_sync_service.dart';
import 'package:minq/core/sync/cloud_database_service.dart';
import 'package:minq/core/sync/conflict_resolution_service.dart';
import 'package:minq/core/sync/database_cleanup_service.dart';
import 'package:minq/core/sync/offline_operations_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkStatusService extends Mock implements NetworkStatusService {}

class MockCloudDatabaseService extends Mock implements CloudDatabaseService {}

void main() {
  group('Sync System Integration Tests', () {
    late Isar isar;
    late MockNetworkStatusService mockNetworkService;
    late MockCloudDatabaseService mockCloudService;
    late SyncQueueManager syncQueueManager;
    late OfflineOperationsService offlineOperationsService;
    late ConflictResolutionService conflictResolutionService;
    late DatabaseCleanupService cleanupService;
    late BackgroundSyncService backgroundSyncService;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await Isar.open([
        LocalQuestSchema,
        LocalUserSchema,
        LocalChallengeSchema,
        LocalQuestLogSchema,
        SyncJobSchema,
      ], directory: '');

      mockNetworkService = MockNetworkStatusService();
      mockCloudService = MockCloudDatabaseService();

      // Setup default network service behavior
      when(() => mockNetworkService.isOnline).thenReturn(true);
      when(() => mockNetworkService.isOffline).thenReturn(false);
      when(
        () => mockNetworkService.statusStream,
      ).thenAnswer((_) => Stream.value(NetworkStatus.online));

      // Setup default cloud service behavior
      when(
        () => mockCloudService.upsertQuest(any()),
      ).thenAnswer((_) async => SyncResult.success());
      when(
        () => mockCloudService.upsertUser(any()),
      ).thenAnswer((_) async => SyncResult.success());
      when(
        () => mockCloudService.upsertQuestLog(any()),
      ).thenAnswer((_) async => SyncResult.success());

      syncQueueManager = SyncQueueManager(
        isar: isar,
        networkService: mockNetworkService,
        cloudService: mockCloudService,
      );

      offlineOperationsService = OfflineOperationsService(
        isar: isar,
        syncQueueManager: syncQueueManager,
      );

      conflictResolutionService = ConflictResolutionService(isar: isar);
      cleanupService = DatabaseCleanupService(isar: isar);

      backgroundSyncService = BackgroundSyncService(
        syncQueueManager: syncQueueManager,
        networkService: mockNetworkService,
        cloudService: mockCloudService,
      );

      await syncQueueManager.initialize();
    });

    tearDown(() async {
      await backgroundSyncService.dispose();
      await isar.close(deleteFromDisk: true);
    });

    group('End-to-End Offline Operations', () {
      test('should create quest offline and sync when online', () async {
        // Arrange - Start offline
        when(() => mockNetworkService.isOnline).thenReturn(false);
        when(() => mockNetworkService.isOffline).thenReturn(true);

        // Act - Create quest offline
        final quest = await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Offline Quest',
          category: 'health',
        );

        // Assert - Quest created locally
        expect(quest.needsSync, isTrue);
        expect(quest.syncStatus, equals(SyncStatus.pending));

        // Verify sync job was enqueued
        final pendingJobs =
            await isar.syncJobs
                .filter()
                .statusEqualTo(SyncJobStatus.pending)
                .findAll();
        expect(pendingJobs.length, equals(1));
        expect(pendingJobs.first.entityType, equals('quest'));

        // Arrange - Go online
        when(() => mockNetworkService.isOnline).thenReturn(true);
        when(() => mockNetworkService.isOffline).thenReturn(false);

        // Act - Process sync queue
        await syncQueueManager.processPendingJobs();

        // Assert - Sync job completed
        final completedJobs =
            await isar.syncJobs
                .filter()
                .statusEqualTo(SyncJobStatus.pending)
                .findAll();
        expect(completedJobs.length, equals(0));

        // Verify cloud service was called
        verify(() => mockCloudService.upsertQuest(any())).called(1);
      });

      test('should handle sync failure and retry', () async {
        // Arrange - Setup cloud service to fail initially
        var callCount = 0;
        when(() => mockCloudService.upsertQuest(any())).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) {
            return SyncResult.failure('Network error');
          }
          return SyncResult.success();
        });

        // Act - Create quest
        await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Test Quest',
          category: 'health',
        );

        // First sync attempt (should fail)
        await syncQueueManager.processPendingJobs();

        // Assert - Job should be marked for retry
        final failedJobs =
            await isar.syncJobs
                .filter()
                .statusEqualTo(SyncJobStatus.pending)
                .and()
                .retryCountGreaterThan(0)
                .findAll();
        expect(failedJobs.length, equals(1));

        // Second sync attempt (should succeed)
        await syncQueueManager.processPendingJobs();

        // Assert - Job should be completed
        final remainingJobs =
            await isar.syncJobs
                .filter()
                .statusEqualTo(SyncJobStatus.pending)
                .findAll();
        expect(remainingJobs.length, equals(0));

        // Verify cloud service was called twice
        verify(() => mockCloudService.upsertQuest(any())).called(2);
      });

      test('should complete quest offline and sync user XP', () async {
        // Arrange - Create user and quest
        const uid = 'test-user';
        final user =
            LocalUser()
              ..uid = uid
              ..displayName = 'Test User'
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now()
              ..currentXP = 100
              ..totalPoints = 500
              ..currentLevel = 2;

        await isar.writeTxn(() => isar.localUsers.put(user));

        final quest = await offlineOperationsService.createQuest(
          owner: uid,
          title: 'Test Quest',
          category: 'health',
        );

        // Act - Complete quest
        final questLog = await offlineOperationsService.completeQuest(
          uid: uid,
          questId: quest.questId,
          proofType: ProofType.check,
          xpEarned: 25,
        );

        // Assert - Quest log created and user XP updated
        expect(questLog.uid, equals(uid));
        expect(questLog.questId, equals(quest.questId));
        expect(questLog.xpEarned, equals(25));

        final updatedUser = await offlineOperationsService.getUser(uid);
        expect(updatedUser!.totalPoints, equals(525)); // 500 + 25

        // Verify sync jobs were created (quest log + user update)
        final pendingJobs =
            await isar.syncJobs
                .filter()
                .statusEqualTo(SyncJobStatus.pending)
                .findAll();
        expect(pendingJobs.length, greaterThanOrEqualTo(2));

        // Process sync
        await syncQueueManager.processPendingJobs();

        // Verify cloud services were called
        verify(() => mockCloudService.upsertQuestLog(any())).called(1);
        verify(() => mockCloudService.upsertUser(any())).called(atLeast(1));
      });
    });

    group('Conflict Resolution', () {
      test('should resolve quest conflict by preferring newer data', () async {
        // Arrange - Create local quest
        final quest = await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Local Title',
          category: 'health',
        );

        // Simulate server data that's newer
        final serverData = {
          'questId': quest.questId,
          'owner': 'test-user',
          'title': 'Server Title',
          'category': 'fitness',
          'updatedAt':
              DateTime.now().add(const Duration(minutes: 1)).toIso8601String(),
        };

        // Act - Resolve conflict
        final resolution = await conflictResolutionService.resolveQuestConflict(
          quest,
          serverData,
        );

        // Assert - Should prefer server data (newer)
        expect(resolution.resolution, equals(ConflictResolutionType.useServer));
        expect(resolution.resolvedData!['title'], equals('Server Title'));
        expect(resolution.resolvedData!['category'], equals('fitness'));

        // Apply resolution
        await conflictResolutionService.applyResolution(
          'quest',
          quest.questId,
          resolution,
        );

        // Verify quest was updated
        final updatedQuest =
            await isar.localQuests
                .filter()
                .questIdEqualTo(quest.questId)
                .findFirst();
        expect(updatedQuest!.title, equals('Server Title'));
        expect(updatedQuest.category, equals('fitness'));
        expect(updatedQuest.syncStatus, equals(SyncStatus.synced));
      });

      test('should auto-merge non-critical differences', () async {
        // Arrange - Create local quest
        final quest = await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Same Title',
          category: 'health',
          estimatedMinutes: 10,
          tags: ['local-tag'],
        );

        // Simulate server data with same timestamp but different non-critical fields
        final serverData = {
          'questId': quest.questId,
          'owner': 'test-user',
          'title': 'Same Title',
          'category': 'health',
          'estimatedMinutes': 15, // Different
          'tags': ['server-tag'], // Different
          'updatedAt': quest.updatedAt.toIso8601String(), // Same timestamp
        };

        // Act - Resolve conflict
        final resolution = await conflictResolutionService.resolveQuestConflict(
          quest,
          serverData,
        );

        // Assert - Should auto-merge, preferring local for mergeable fields
        expect(
          resolution.resolution,
          equals(ConflictResolutionType.autoMerged),
        );
        expect(
          resolution.resolvedData!['estimatedMinutes'],
          equals(10),
        ); // Local preferred
        expect(
          resolution.resolvedData!['tags'],
          equals(['local-tag']),
        ); // Local preferred
      });
    });

    group('Database Cleanup', () {
      test('should clean up old sync jobs and soft-deleted records', () async {
        // Arrange - Create old completed sync job
        final oldJob =
            SyncJob()
              ..entityType = 'quest'
              ..entityId = 'old-quest'
              ..operation = 'create'
              ..data = {}
              ..createdAt = DateTime.now().subtract(const Duration(days: 10))
              ..status = SyncJobStatus.completed;

        await isar.writeTxn(() => isar.syncJobs.put(oldJob));

        // Create soft-deleted quest
        final deletedQuest =
            LocalQuest()
              ..questId = 'deleted-quest'
              ..owner = 'test-user'
              ..title = 'Deleted Quest'
              ..category = 'health'
              ..status = QuestStatus.active
              ..createdAt = DateTime.now().subtract(const Duration(days: 40))
              ..updatedAt = DateTime.now().subtract(const Duration(days: 35))
              ..deletedAt = DateTime.now().subtract(const Duration(days: 35));

        await isar.writeTxn(() => isar.localQuests.put(deletedQuest));

        // Act - Perform cleanup
        final result = await cleanupService.performCleanup(
          olderThan: const Duration(days: 7),
        );

        // Assert - Cleanup was successful
        expect(result.success, isTrue);
        expect(result.deletedRecords, greaterThan(0));

        // Verify old sync job was deleted
        final remainingJobs = await isar.syncJobs.findAll();
        expect(remainingJobs.any((job) => job.id == oldJob.id), isFalse);

        // Verify soft-deleted quest was removed
        final remainingQuests = await isar.localQuests.findAll();
        expect(
          remainingQuests.any((quest) => quest.questId == 'deleted-quest'),
          isFalse,
        );
      });

      test('should get accurate database statistics', () async {
        // Arrange - Create test data
        await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Test Quest 1',
          category: 'health',
        );
        await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Test Quest 2',
          category: 'fitness',
        );

        // Act - Get stats
        final stats = await cleanupService.getDatabaseStats();

        // Assert - Stats are accurate
        expect(stats.questCount, equals(2));
        expect(
          stats.syncJobCount,
          greaterThanOrEqualTo(2),
        ); // At least 2 from quest creation
        expect(stats.totalRecords, greaterThanOrEqualTo(2));
      });
    });

    group('Background Sync', () {
      test('should get sync status correctly', () async {
        // Arrange - Create some pending jobs
        await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Test Quest',
          category: 'health',
        );

        // Act - Get sync status
        final status = await backgroundSyncService.getSyncStatus();

        // Assert - Status reflects current state
        expect(status.isOnline, isTrue);
        expect(status.pendingJobs, greaterThan(0));
        expect(status.statusText, isNotEmpty);
      });

      test('should force sync when requested', () async {
        // Arrange - Create quest to sync
        await offlineOperationsService.createQuest(
          owner: 'test-user',
          title: 'Test Quest',
          category: 'health',
        );

        // Act - Force sync
        final result = await backgroundSyncService.forceSyncNow();

        // Assert - Sync was successful
        expect(result.success, isTrue);
        expect(result.syncedItems, greaterThanOrEqualTo(0));

        // Verify cloud service was called
        verify(() => mockCloudService.upsertQuest(any())).called(1);
      });

      test('should handle offline state correctly', () async {
        // Arrange - Set offline
        when(() => mockNetworkService.isOnline).thenReturn(false);
        when(() => mockNetworkService.isOffline).thenReturn(true);

        // Act - Try to force sync
        final result = await backgroundSyncService.forceSyncNow();

        // Assert - Sync should fail gracefully
        expect(result.success, isFalse);
        expect(result.error, contains('offline'));

        // Verify cloud service was not called
        verifyNever(() => mockCloudService.upsertQuest(any()));
      });
    });

    group('Full System Integration', () {
      test('should handle complete offline-to-online workflow', () async {
        // Arrange - Start offline
        when(() => mockNetworkService.isOnline).thenReturn(false);

        // Act - Perform offline operations
        const uid = 'test-user';

        // Create user
        final user =
            LocalUser()
              ..uid = uid
              ..displayName = 'Test User'
              ..createdAt = DateTime.now()
              ..updatedAt = DateTime.now()
              ..currentXP = 0
              ..totalPoints = 0
              ..currentLevel = 1;

        await isar.writeTxn(() => isar.localUsers.put(user));

        // Create quest
        final quest = await offlineOperationsService.createQuest(
          owner: uid,
          title: 'Offline Quest',
          category: 'health',
        );

        // Complete quest
        await offlineOperationsService.completeQuest(
          uid: uid,
          questId: quest.questId,
          proofType: ProofType.check,
          xpEarned: 50,
        );

        // Update quest
        await offlineOperationsService.updateQuest(
          quest.questId,
          title: 'Updated Offline Quest',
        );

        // Assert - All operations created sync jobs
        final pendingJobs =
            await isar.syncJobs
                .filter()
                .statusEqualTo(SyncJobStatus.pending)
                .findAll();
        expect(
          pendingJobs.length,
          greaterThanOrEqualTo(3),
        ); // Quest create, quest log, user update, quest update

        // Arrange - Go online
        when(() => mockNetworkService.isOnline).thenReturn(true);
        when(() => mockNetworkService.isOffline).thenReturn(false);

        // Act - Sync all changes
        await syncQueueManager.processPendingJobs();

        // Assert - All sync jobs completed
        final remainingJobs =
            await isar.syncJobs
                .filter()
                .statusEqualTo(SyncJobStatus.pending)
                .findAll();
        expect(remainingJobs.length, equals(0));

        // Verify all cloud services were called
        verify(
          () => mockCloudService.upsertQuest(any()),
        ).called(atLeast(2)); // Create + Update
        verify(() => mockCloudService.upsertQuestLog(any())).called(1);
        verify(() => mockCloudService.upsertUser(any())).called(atLeast(1));

        // Verify final state
        final finalUser = await offlineOperationsService.getUser(uid);
        expect(finalUser!.totalPoints, equals(50));

        final finalQuest =
            await isar.localQuests
                .filter()
                .questIdEqualTo(quest.questId)
                .findFirst();
        expect(finalQuest!.title, equals('Updated Offline Quest'));
      });
    });
  });
}
