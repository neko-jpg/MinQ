import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/sync/offline_operations_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncQueueManager extends Mock implements SyncQueueManager {}

void main() {
  group('OfflineOperationsService', () {
    late Isar isar;
    late MockSyncQueueManager mockSyncQueueManager;
    late OfflineOperationsService service;

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
      
      mockSyncQueueManager = MockSyncQueueManager();
      service = OfflineOperationsService(
        isar: isar,
        syncQueueManager: mockSyncQueueManager,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    group('Quest Operations', () {
      test('should create quest offline', () async {
        // Arrange
        const owner = 'test-user';
        const title = 'Test Quest';
        const category = 'health';

        // Act
        final quest = await service.createQuest(
          owner: owner,
          title: title,
          category: category,
        );

        // Assert
        expect(quest.owner, equals(owner));
        expect(quest.title, equals(title));
        expect(quest.category, equals(category));
        expect(quest.needsSync, isTrue);
        expect(quest.syncStatus, equals(SyncStatus.pending));
        
        // Verify quest is stored in database
        final storedQuest = await isar.localQuests
            .filter()
            .questIdEqualTo(quest.questId)
            .findFirst();
        expect(storedQuest, isNotNull);
        expect(storedQuest!.title, equals(title));
        
        // Verify sync job was enqueued
        verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(1);
      });

      test('should update quest offline', () async {
        // Arrange
        final quest = await service.createQuest(
          owner: 'test-user',
          title: 'Original Title',
          category: 'health',
        );
        
        const newTitle = 'Updated Title';
        const newCategory = 'fitness';

        // Act
        final updatedQuest = await service.updateQuest(
          quest.questId,
          title: newTitle,
          category: newCategory,
        );

        // Assert
        expect(updatedQuest.title, equals(newTitle));
        expect(updatedQuest.category, equals(newCategory));
        expect(updatedQuest.needsSync, isTrue);
        expect(updatedQuest.syncStatus, equals(SyncStatus.pending));
        
        // Verify sync job was enqueued for update
        verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(2); // Create + Update
      });

      test('should delete quest offline', () async {
        // Arrange
        final quest = await service.createQuest(
          owner: 'test-user',
          title: 'Test Quest',
          category: 'health',
        );

        // Act
        await service.deleteQuest(quest.questId);

        // Assert
        final deletedQuest = await isar.localQuests
            .filter()
            .questIdEqualTo(quest.questId)
            .findFirst();
        expect(deletedQuest, isNotNull);
        expect(deletedQuest!.deletedAt, isNotNull);
        expect(deletedQuest.needsSync, isTrue);
        
        // Verify sync job was enqueued for delete
        verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(2); // Create + Delete
      });

      test('should get active quests for user', () async {
        // Arrange
        const uid = 'test-user';
        await service.createQuest(
          owner: uid,
          title: 'Active Quest 1',
          category: 'health',
        );
        await service.createQuest(
          owner: uid,
          title: 'Active Quest 2',
          category: 'fitness',
        );
        
        final pausedQuest = await service.createQuest(
          owner: uid,
          title: 'Paused Quest',
          category: 'health',
        );
        await service.updateQuest(pausedQuest.questId, status: QuestStatus.paused);

        // Act
        final activeQuests = await service.getActiveQuests(uid);

        // Assert
        expect(activeQuests.length, equals(2));
        expect(activeQuests.every((q) => q.status == QuestStatus.active), isTrue);
        expect(activeQuests.every((q) => q.owner == uid), isTrue);
      });
    });

    group('User Operations', () {
      test('should update user XP offline', () async {
        // Arrange
        const uid = 'test-user';
        final user = LocalUser()
          ..uid = uid
          ..displayName = 'Test User'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..currentXP = 100
          ..totalPoints = 500
          ..currentLevel = 2;

        await isar.writeTxn(() => isar.localUsers.put(user));

        const xpGained = 50;

        // Act
        final updatedUser = await service.updateUserXP(
          uid,
          xpGained: xpGained,
          reason: 'quest_completion',
        );

        // Assert
        expect(updatedUser.currentXP, equals(150));
        expect(updatedUser.totalPoints, equals(550));
        expect(updatedUser.needsSync, isTrue);
        expect(updatedUser.syncStatus, equals(SyncStatus.pending));
        
        // Verify sync job was enqueued
        verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(1);
      });

      test('should level up user when XP threshold reached', () async {
        // Arrange
        const uid = 'test-user';
        final user = LocalUser()
          ..uid = uid
          ..displayName = 'Test User'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..currentXP = 90
          ..totalPoints = 90
          ..currentLevel = 1;

        await isar.writeTxn(() => isar.localUsers.put(user));

        const xpGained = 20; // This should trigger level up

        // Act
        final updatedUser = await service.updateUserXP(
          uid,
          xpGained: xpGained,
        );

        // Assert
        expect(updatedUser.totalPoints, equals(110));
        expect(updatedUser.currentLevel, greaterThan(1)); // Should level up
      });
    });

    group('Quest Log Operations', () {
      test('should complete quest offline', () async {
        // Arrange
        const uid = 'test-user';
        const questId = 'test-quest';
        const xpEarned = 25;

        // Create user first
        final user = LocalUser()
          ..uid = uid
          ..displayName = 'Test User'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..currentXP = 100
          ..totalPoints = 500
          ..currentLevel = 2;

        await isar.writeTxn(() => isar.localUsers.put(user));

        // Act
        final questLog = await service.completeQuest(
          uid: uid,
          questId: questId,
          proofType: ProofType.check,
          xpEarned: xpEarned,
        );

        // Assert
        expect(questLog.uid, equals(uid));
        expect(questLog.questId, equals(questId));
        expect(questLog.proofType, equals(ProofType.check));
        expect(questLog.xpEarned, equals(xpEarned));
        expect(questLog.needsSync, isTrue);
        expect(questLog.syncStatus, equals(SyncStatus.pending));
        
        // Verify quest log is stored
        final storedLog = await isar.localQuestLogs
            .filter()
            .logIdEqualTo(questLog.logId)
            .findFirst();
        expect(storedLog, isNotNull);
        
        // Verify user XP was updated
        final updatedUser = await service.getUser(uid);
        expect(updatedUser!.totalPoints, equals(525)); // 500 + 25
        
        // Verify sync jobs were enqueued (quest log + user update)
        verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(2);
      });

      test('should get user quest logs', () async {
        // Arrange
        const uid = 'test-user';
        
        // Create user first
        final user = LocalUser()
          ..uid = uid
          ..displayName = 'Test User'
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now()
          ..currentXP = 100
          ..totalPoints = 500
          ..currentLevel = 2;

        await isar.writeTxn(() => isar.localUsers.put(user));

        // Complete multiple quests
        await service.completeQuest(
          uid: uid,
          questId: 'quest-1',
          proofType: ProofType.check,
          xpEarned: 10,
        );
        await service.completeQuest(
          uid: uid,
          questId: 'quest-2',
          proofType: ProofType.photo,
          proofValue: 'photo-url',
          xpEarned: 15,
        );

        // Act
        final questLogs = await service.getUserQuestLogs(uid, limit: 10);

        // Assert
        expect(questLogs.length, equals(2));
        expect(questLogs.every((log) => log.uid == uid), isTrue);
        expect(questLogs.first.timestamp.isAfter(questLogs.last.timestamp), isTrue); // Sorted by timestamp desc
      });
    });

    group('Challenge Operations', () {
      test('should update challenge progress offline', () async {
        // Arrange
        const challengeId = 'test-challenge';
        final challenge = LocalChallenge()
          ..challengeId = challengeId
          ..title = 'Test Challenge'
          ..description = 'Test Description'
          ..startDate = DateTime.now().subtract(const Duration(days: 1))
          ..endDate = DateTime.now().add(const Duration(days: 30))
          ..isActive = true
          ..progress = 50
          ..targetValue = 100
          ..xpReward = 100
          ..participants = ['user1', 'user2']
          ..updatedAt = DateTime.now();

        await isar.writeTxn(() => isar.localChallenges.put(challenge));

        const progressIncrement = 25;

        // Act
        final updatedChallenge = await service.updateChallengeProgress(
          challengeId,
          progressIncrement: progressIncrement,
        );

        // Assert
        expect(updatedChallenge.progress, equals(75)); // 50 + 25
        expect(updatedChallenge.needsSync, isTrue);
        expect(updatedChallenge.syncStatus, equals(SyncStatus.pending));
        
        // Verify sync job was enqueued
        verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(1);
      });

      test('should get active challenges', () async {
        // Arrange
        final now = DateTime.now();
        
        // Active challenge
        final activeChallenge = LocalChallenge()
          ..challengeId = 'active-challenge'
          ..title = 'Active Challenge'
          ..description = 'Active Description'
          ..startDate = now.subtract(const Duration(days: 1))
          ..endDate = now.add(const Duration(days: 30))
          ..isActive = true
          ..progress = 0
          ..targetValue = 100
          ..xpReward = 100
          ..participants = []
          ..updatedAt = now;

        // Inactive challenge
        final inactiveChallenge = LocalChallenge()
          ..challengeId = 'inactive-challenge'
          ..title = 'Inactive Challenge'
          ..description = 'Inactive Description'
          ..startDate = now.subtract(const Duration(days: 1))
          ..endDate = now.add(const Duration(days: 30))
          ..isActive = false
          ..progress = 0
          ..targetValue = 100
          ..xpReward = 100
          ..participants = []
          ..updatedAt = now;

        // Expired challenge
        final expiredChallenge = LocalChallenge()
          ..challengeId = 'expired-challenge'
          ..title = 'Expired Challenge'
          ..description = 'Expired Description'
          ..startDate = now.subtract(const Duration(days: 60))
          ..endDate = now.subtract(const Duration(days: 30))
          ..isActive = true
          ..progress = 0
          ..targetValue = 100
          ..xpReward = 100
          ..participants = []
          ..updatedAt = now;

        await isar.writeTxn(() async {
          await isar.localChallenges.putAll([
            activeChallenge,
            inactiveChallenge,
            expiredChallenge,
          ]);
        });

        // Act
        final activeChallenges = await service.getActiveChallenges();

        // Assert
        expect(activeChallenges.length, equals(1));
        expect(activeChallenges.first.challengeId, equals('active-challenge'));
      });
    });

    group('Error Handling', () {
      test('should throw exception when updating non-existent quest', () async {
        // Act & Assert
        expect(
          () => service.updateQuest('non-existent-quest', title: 'New Title'),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when deleting non-existent quest', () async {
        // Act & Assert
        expect(
          () => service.deleteQuest('non-existent-quest'),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when updating XP for non-existent user', () async {
        // Act & Assert
        expect(
          () => service.updateUserXP('non-existent-user', xpGained: 10),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when updating non-existent challenge', () async {
        // Act & Assert
        expect(
          () => service.updateChallengeProgress('non-existent-challenge', progressIncrement: 10),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}