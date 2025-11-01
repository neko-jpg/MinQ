import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/sync/offline_operations_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/main.dart' as app;
import 'package:mocktail/mocktail.dart';

class MockNetworkStatusService extends Mock implements NetworkStatusService {}

class MockSyncQueueManager extends Mock implements SyncQueueManager {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Sync Integration Tests', () {
    late Isar isar;
    late MockNetworkStatusService mockNetworkService;
    late MockSyncQueueManager mockSyncQueueManager;
    late OfflineOperationsService offlineService;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await Isar.open([
        LocalQuestSchema,
        LocalUserSchema,
        LocalChallengeSchema,
        LocalQuestLogSchema,
      ], directory: '');

      mockNetworkService = MockNetworkStatusService();
      mockSyncQueueManager = MockSyncQueueManager();

      offlineService = OfflineOperationsService(
        isar: isar,
        syncQueueManager: mockSyncQueueManager,
      );

      // Setup default mock behaviors
      when(() => mockNetworkService.isOnline).thenReturn(false);
      when(
        () => mockSyncQueueManager.enqueueSyncJob(any()),
      ).thenAnswer((_) async {});
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    testWidgets('Complete offline quest creation and sync workflow', (
      tester,
    ) async {
      // Start with offline state
      when(() => mockNetworkService.isOnline).thenReturn(false);

      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();

      // Navigate to quest creation
      await tester.tap(find.byKey(const Key('create_quest_fab')));
      await tester.pumpAndSettle();

      // Fill quest form
      await tester.enterText(
        find.byKey(const Key('quest_title_field')),
        'Morning Exercise',
      );
      await tester.enterText(
        find.byKey(const Key('quest_description_field')),
        '30 minutes of morning exercise',
      );

      // Save quest offline
      await tester.tap(find.byKey(const Key('save_quest_button')));
      await tester.pumpAndSettle();

      // Verify offline banner is shown
      expect(find.byKey(const Key('offline_banner')), findsOneWidget);

      // Verify quest is saved locally
      final localQuests = await isar.localQuests.where().findAll();
      expect(localQuests.length, equals(1));
      expect(localQuests.first.title, equals('Morning Exercise'));
      expect(localQuests.first.needsSync, isTrue);
      expect(localQuests.first.syncStatus, equals(SyncStatus.pending));

      // Verify sync job was enqueued
      verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(1);

      // Simulate network coming back online
      when(() => mockNetworkService.isOnline).thenReturn(true);
      when(() => mockSyncQueueManager.processPendingJobs()).thenAnswer((
        _,
      ) async {
        // Simulate successful sync
        final quest = localQuests.first;
        quest.needsSync = false;
        quest.syncStatus = SyncStatus.synced;
        await isar.writeTxn(() => isar.localQuests.put(quest));
      });

      // Trigger network status change
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump(const Duration(seconds: 2));

      // Verify offline banner is hidden
      expect(find.byKey(const Key('offline_banner')), findsNothing);

      // Verify quest is marked as synced
      final syncedQuests = await isar.localQuests.where().findAll();
      expect(syncedQuests.first.needsSync, isFalse);
      expect(syncedQuests.first.syncStatus, equals(SyncStatus.synced));

      // Verify sync was processed
      verify(() => mockSyncQueueManager.processPendingJobs()).called(1);
    });

    testWidgets('Offline quest completion with XP gain', (tester) async {
      // Setup: Create a user and quest offline
      final user =
          LocalUser()
            ..uid = 'test-user'
            ..displayName = 'Test User'
            ..currentXP = 100
            ..totalPoints = 500
            ..currentLevel = 2
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      final quest =
          LocalQuest()
            ..questId = 'test-quest'
            ..owner = 'test-user'
            ..title = 'Test Quest'
            ..category = 'health'
            ..status = QuestStatus.active
            ..xpReward = 25
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.localUsers.put(user);
        await isar.localQuests.put(quest);
      });

      when(() => mockNetworkService.isOnline).thenReturn(false);

      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();

      // Navigate to quest and complete it
      await tester.tap(find.text('Test Quest'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('complete_quest_button')));
      await tester.pumpAndSettle();

      // Verify XP gain animation is shown
      expect(find.byKey(const Key('xp_gain_animation')), findsOneWidget);
      expect(find.text('+25 XP'), findsOneWidget);

      // Wait for animation to complete
      await tester.pump(const Duration(seconds: 3));

      // Verify quest log was created
      final questLogs = await isar.localQuestLogs.where().findAll();
      expect(questLogs.length, equals(1));
      expect(questLogs.first.questId, equals('test-quest'));
      expect(questLogs.first.xpEarned, equals(25));
      expect(questLogs.first.needsSync, isTrue);

      // Verify user XP was updated
      final updatedUser =
          await isar.localUsers.filter().uidEqualTo('test-user').findFirst();
      expect(updatedUser!.totalPoints, equals(525)); // 500 + 25
      expect(updatedUser.needsSync, isTrue);

      // Verify sync jobs were enqueued (quest log + user update)
      verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(2);
    });

    testWidgets('Offline challenge progress update', (tester) async {
      // Setup: Create a challenge offline
      final challenge =
          LocalChallenge()
            ..challengeId = 'test-challenge'
            ..title = '7-Day Fitness Challenge'
            ..description = 'Complete 7 days of exercise'
            ..startDate = DateTime.now().subtract(const Duration(days: 1))
            ..endDate = DateTime.now().add(const Duration(days: 6))
            ..isActive = true
            ..progress = 2
            ..targetValue = 7
            ..xpReward = 100
            ..participants = ['test-user']
            ..updatedAt = DateTime.now();

      await isar.writeTxn(() => isar.localChallenges.put(challenge));

      when(() => mockNetworkService.isOnline).thenReturn(false);

      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();

      // Navigate to challenges
      await tester.tap(find.byKey(const Key('challenges_tab')));
      await tester.pumpAndSettle();

      // Find and tap the challenge
      await tester.tap(find.text('7-Day Fitness Challenge'));
      await tester.pumpAndSettle();

      // Update progress
      await tester.tap(find.byKey(const Key('update_progress_button')));
      await tester.pumpAndSettle();

      // Verify progress was updated locally
      final updatedChallenge =
          await isar.localChallenges
              .filter()
              .challengeIdEqualTo('test-challenge')
              .findFirst();
      expect(updatedChallenge!.progress, equals(3)); // 2 + 1
      expect(updatedChallenge.needsSync, isTrue);
      expect(updatedChallenge.syncStatus, equals(SyncStatus.pending));

      // Verify sync job was enqueued
      verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(1);
    });

    testWidgets('Sync conflict resolution workflow', (tester) async {
      // Setup: Create a quest that exists both locally and remotely with conflicts
      final localQuest =
          LocalQuest()
            ..questId = 'conflict-quest'
            ..owner = 'test-user'
            ..title = 'Local Title'
            ..category = 'health'
            ..status = QuestStatus.active
            ..updatedAt = DateTime.now()
            ..needsSync = true
            ..syncStatus = SyncStatus.pending;

      await isar.writeTxn(() => isar.localQuests.put(localQuest));

      // Simulate sync conflict
      when(() => mockSyncQueueManager.processPendingJobs()).thenAnswer((
        _,
      ) async {
        // Simulate conflict detected during sync
        throw SyncConflictException(
          entityId: 'conflict-quest',
          entityType: 'quest',
          localData: {'title': 'Local Title'},
          remoteData: {'title': 'Remote Title'},
        );
      });

      when(() => mockNetworkService.isOnline).thenReturn(true);

      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();

      // Trigger sync
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/connectivity',
        null,
        (data) {},
      );
      await tester.pump(const Duration(seconds: 2));

      // Verify conflict resolution dialog is shown
      expect(find.byKey(const Key('sync_conflict_dialog')), findsOneWidget);
      expect(find.text('Sync Conflict Detected'), findsOneWidget);
      expect(find.text('Local Title'), findsOneWidget);
      expect(find.text('Remote Title'), findsOneWidget);

      // Choose local version
      await tester.tap(find.byKey(const Key('use_local_button')));
      await tester.pumpAndSettle();

      // Verify conflict was resolved
      expect(find.byKey(const Key('sync_conflict_dialog')), findsNothing);
    });

    testWidgets('Bulk sync operation with progress indicator', (tester) async {
      // Setup: Create multiple items that need sync
      final items = <LocalQuest>[];
      for (int i = 0; i < 10; i++) {
        items.add(
          LocalQuest()
            ..questId = 'quest-$i'
            ..owner = 'test-user'
            ..title = 'Quest $i'
            ..category = 'health'
            ..status = QuestStatus.active
            ..createdAt = DateTime.now()
            ..updatedAt = DateTime.now()
            ..needsSync = true
            ..syncStatus = SyncStatus.pending,
        );
      }

      await isar.writeTxn(() => isar.localQuests.putAll(items));

      // Setup progressive sync simulation
      int syncedCount = 0;
      when(() => mockSyncQueueManager.processPendingJobs()).thenAnswer((
        _,
      ) async {
        // Simulate progressive sync with delays
        for (final item in items) {
          await Future.delayed(const Duration(milliseconds: 100));
          item.needsSync = false;
          item.syncStatus = SyncStatus.synced;
          await isar.writeTxn(() => isar.localQuests.put(item));
          syncedCount++;
        }
      });

      when(() => mockNetworkService.isOnline).thenReturn(true);

      await tester.pumpWidget(app.MinQApp());
      await tester.pumpAndSettle();

      // Navigate to sync status screen
      await tester.tap(find.byKey(const Key('settings_tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sync_status_tile')));
      await tester.pumpAndSettle();

      // Trigger manual sync
      await tester.tap(find.byKey(const Key('manual_sync_button')));
      await tester.pump();

      // Verify sync progress indicator is shown
      expect(find.byKey(const Key('sync_progress_indicator')), findsOneWidget);
      expect(find.text('Syncing...'), findsOneWidget);

      // Wait for sync to complete
      await tester.pump(const Duration(seconds: 2));

      // Verify sync completion
      expect(find.byKey(const Key('sync_progress_indicator')), findsNothing);
      expect(find.text('Sync Complete'), findsOneWidget);

      // Verify all items are synced
      final syncedItems = await isar.localQuests.where().findAll();
      expect(syncedItems.every((item) => !item.needsSync), isTrue);
      expect(
        syncedItems.every((item) => item.syncStatus == SyncStatus.synced),
        isTrue,
      );
    });
  });
}

class SyncConflictException implements Exception {
  final String entityId;
  final String entityType;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;

  SyncConflictException({
    required this.entityId,
    required this.entityType,
    required this.localData,
    required this.remoteData,
  });
}
