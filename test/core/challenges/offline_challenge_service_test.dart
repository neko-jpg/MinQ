import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/challenges/offline_challenge_service.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/sync/offline_operations_service.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:mocktail/mocktail.dart';

class MockIsar extends Mock implements Isar {}

class MockOfflineOperationsService extends Mock
    implements OfflineOperationsService {}

class MockNetworkStatusService extends Mock implements NetworkStatusService {}

class MockIsarCollection extends Mock
    implements IsarCollection<LocalChallenge> {}

class MockQueryBuilder extends Mock
    implements QueryBuilder<LocalChallenge, LocalChallenge, QQueryOperations> {}

void main() {
  group('OfflineChallengeService', () {
    late OfflineChallengeService service;
    late MockIsar mockIsar;
    late MockOfflineOperationsService mockOfflineOperations;
    late MockNetworkStatusService mockNetworkService;
    late MockIsarCollection mockCollection;

    const testUserId = 'test-user-id';

    setUp(() {
      mockIsar = MockIsar();
      mockOfflineOperations = MockOfflineOperationsService();
      mockNetworkService = MockNetworkStatusService();
      mockCollection = MockIsarCollection();

      // Setup default mocks
      when(() => mockIsar.localChallenges).thenReturn(mockCollection);
      when(() => mockNetworkService.isOffline).thenReturn(false);
      when(() => mockNetworkService.isOnline).thenReturn(true);

      service = OfflineChallengeService(
        isar: mockIsar,
        offlineOperations: mockOfflineOperations,
        networkService: mockNetworkService,
        userId: testUserId,
      );
    });

    group('getActiveChallenges', () {
      test('returns active challenges within date range', () async {
        // Arrange
        final now = DateTime.now();
        final activeChallenge =
            LocalChallenge()
              ..challengeId = 'challenge-1'
              ..title = 'Test Challenge'
              ..description = 'Test Description'
              ..startDate = now.subtract(const Duration(days: 1))
              ..endDate = now.add(const Duration(days: 7))
              ..isActive = true
              ..progress = 50
              ..targetValue = 100
              ..xpReward = 100
              ..participants = [testUserId]
              ..updatedAt = now
              ..needsSync = false
              ..syncStatus = SyncStatus.synced;

        final mockQuery = MockQueryBuilder();
        when(() => mockCollection.filter()).thenReturn(mockQuery);
        when(() => mockQuery.isActiveEqualTo(true)).thenReturn(mockQuery);
        when(() => mockQuery.and()).thenReturn(mockQuery);
        when(
          () => mockQuery.startDateLessThanOrEqualTo(any()),
        ).thenReturn(mockQuery);
        when(
          () => mockQuery.endDateGreaterThanOrEqualTo(any()),
        ).thenReturn(mockQuery);
        when(() => mockQuery.sortByStartDateDesc()).thenReturn(mockQuery);
        when(
          () => mockQuery.findAll(),
        ).thenAnswer((_) async => [activeChallenge]);

        // Act
        final result = await service.getActiveChallenges();

        // Assert
        expect(result, hasLength(1));
        expect(result.first.challengeId, equals('challenge-1'));
        expect(result.first.isActive, isTrue);
      });

      test('returns empty list when no active challenges', () async {
        // Arrange
        final mockQuery = MockQueryBuilder();
        when(() => mockCollection.filter()).thenReturn(mockQuery);
        when(() => mockQuery.isActiveEqualTo(true)).thenReturn(mockQuery);
        when(() => mockQuery.and()).thenReturn(mockQuery);
        when(
          () => mockQuery.startDateLessThanOrEqualTo(any()),
        ).thenReturn(mockQuery);
        when(
          () => mockQuery.endDateGreaterThanOrEqualTo(any()),
        ).thenReturn(mockQuery);
        when(() => mockQuery.sortByStartDateDesc()).thenReturn(mockQuery);
        when(() => mockQuery.findAll()).thenAnswer((_) async => []);

        // Act
        final result = await service.getActiveChallenges();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('updateChallengeProgress', () {
      test(
        'updates progress successfully when challenge exists and is active',
        () async {
          // Arrange
          final now = DateTime.now();
          final challenge =
              LocalChallenge()
                ..challengeId = 'challenge-1'
                ..title = 'Test Challenge'
                ..description = 'Test Description'
                ..startDate = now.subtract(const Duration(days: 1))
                ..endDate = now.add(const Duration(days: 7))
                ..isActive = true
                ..progress = 50
                ..targetValue = 100
                ..xpReward = 100
                ..participants = [testUserId]
                ..updatedAt = now
                ..needsSync = false
                ..syncStatus = SyncStatus.synced;

          final mockQuery = MockQueryBuilder();
          when(() => mockCollection.filter()).thenReturn(mockQuery);
          when(
            () => mockQuery.challengeIdEqualTo('challenge-1'),
          ).thenReturn(mockQuery);
          when(() => mockQuery.findFirst()).thenAnswer((_) async => challenge);

          when(
            () => mockOfflineOperations.updateChallengeProgress(
              'challenge-1',
              progressIncrement: 25,
              uid: testUserId,
            ),
          ).thenAnswer((_) async => challenge);

          // Act
          final result = await service.updateChallengeProgress(
            challengeId: 'challenge-1',
            progressIncrement: 25,
          );

          // Assert
          expect(result.challengeId, equals('challenge-1'));
          expect(result.progress, equals(75)); // 50 + 25
          expect(result.completed, isFalse);
          verify(
            () => mockOfflineOperations.updateChallengeProgress(
              'challenge-1',
              progressIncrement: 25,
              uid: testUserId,
            ),
          ).called(1);
        },
      );

      test(
        'throws ChallengeNotFoundException when challenge does not exist',
        () async {
          // Arrange
          final mockQuery = MockQueryBuilder();
          when(() => mockCollection.filter()).thenReturn(mockQuery);
          when(
            () => mockQuery.challengeIdEqualTo('nonexistent'),
          ).thenReturn(mockQuery);
          when(() => mockQuery.findFirst()).thenAnswer((_) async => null);

          // Act & Assert
          expect(
            () => service.updateChallengeProgress(
              challengeId: 'nonexistent',
              progressIncrement: 25,
            ),
            throwsA(isA<ChallengeNotFoundException>()),
          );
        },
      );

      test(
        'throws ChallengeExpiredException when challenge is expired',
        () async {
          // Arrange
          final now = DateTime.now();
          final expiredChallenge =
              LocalChallenge()
                ..challengeId = 'expired-challenge'
                ..title = 'Expired Challenge'
                ..description = 'Test Description'
                ..startDate = now.subtract(const Duration(days: 10))
                ..endDate = now.subtract(const Duration(days: 1)) // Expired
                ..isActive = true
                ..progress = 50
                ..targetValue = 100
                ..xpReward = 100
                ..participants = [testUserId]
                ..updatedAt = now
                ..needsSync = false
                ..syncStatus = SyncStatus.synced;

          final mockQuery = MockQueryBuilder();
          when(() => mockCollection.filter()).thenReturn(mockQuery);
          when(
            () => mockQuery.challengeIdEqualTo('expired-challenge'),
          ).thenReturn(mockQuery);
          when(
            () => mockQuery.findFirst(),
          ).thenAnswer((_) async => expiredChallenge);

          // Act & Assert
          expect(
            () => service.updateChallengeProgress(
              challengeId: 'expired-challenge',
              progressIncrement: 25,
            ),
            throwsA(isA<ChallengeExpiredException>()),
          );
        },
      );

      test('awards XP when challenge is completed', () async {
        // Arrange
        final now = DateTime.now();
        final nearCompletionChallenge =
            LocalChallenge()
              ..challengeId = 'near-completion'
              ..title = 'Near Completion Challenge'
              ..description = 'Test Description'
              ..startDate = now.subtract(const Duration(days: 1))
              ..endDate = now.add(const Duration(days: 7))
              ..isActive = true
              ..progress =
                  90 // Near completion
              ..targetValue = 100
              ..xpReward = 200
              ..participants = [testUserId]
              ..updatedAt = now
              ..needsSync = false
              ..syncStatus = SyncStatus.synced;

        final mockQuery = MockQueryBuilder();
        when(() => mockCollection.filter()).thenReturn(mockQuery);
        when(
          () => mockQuery.challengeIdEqualTo('near-completion'),
        ).thenReturn(mockQuery);
        when(
          () => mockQuery.findFirst(),
        ).thenAnswer((_) async => nearCompletionChallenge);

        when(
          () => mockOfflineOperations.updateChallengeProgress(
            'near-completion',
            progressIncrement: 10,
            uid: testUserId,
          ),
        ).thenAnswer((_) async => nearCompletionChallenge);

        when(
          () => mockOfflineOperations.updateUserXP(
            testUserId,
            xpGained: 200,
            reason: 'challenge_completion:near-completion',
          ),
        ).thenAnswer((_) async => LocalUser());

        // Act
        final result = await service.updateChallengeProgress(
          challengeId: 'near-completion',
          progressIncrement:
              15, // This will complete the challenge (90 + 15 = 105, clamped to 100)
        );

        // Assert
        expect(result.completed, isTrue);
        expect(result.xpAwarded, equals(200));
        verify(
          () => mockOfflineOperations.updateUserXP(
            testUserId,
            xpGained: 200,
            reason: 'challenge_completion:near-completion',
          ),
        ).called(1);
      });
    });

    group('getChallengeProgress', () {
      test('returns progress data for existing challenge', () async {
        // Arrange
        final now = DateTime.now();
        final challenge =
            LocalChallenge()
              ..challengeId = 'challenge-1'
              ..title = 'Test Challenge'
              ..description = 'Test Description'
              ..startDate = now.subtract(const Duration(days: 1))
              ..endDate = now.add(const Duration(days: 7))
              ..isActive = true
              ..progress = 75
              ..targetValue = 100
              ..xpReward = 100
              ..participants = [testUserId]
              ..updatedAt = now
              ..needsSync = false
              ..syncStatus = SyncStatus.synced;

        final mockQuery = MockQueryBuilder();
        when(() => mockCollection.filter()).thenReturn(mockQuery);
        when(
          () => mockQuery.challengeIdEqualTo('challenge-1'),
        ).thenReturn(mockQuery);
        when(() => mockQuery.findFirst()).thenAnswer((_) async => challenge);

        // Act
        final result = await service.getChallengeProgress('challenge-1');

        // Assert
        expect(result, isNotNull);
        expect(result!.challengeId, equals('challenge-1'));
        expect(result.progress, equals(75));
        expect(result.targetValue, equals(100));
        expect(result.progressPercentage, equals(0.75));
        expect(result.completed, isFalse);
        expect(result.remainingProgress, equals(25));
        expect(result.isNearCompletion, isTrue); // >= 0.8
      });

      test('returns null for non-existent challenge', () async {
        // Arrange
        final mockQuery = MockQueryBuilder();
        when(() => mockCollection.filter()).thenReturn(mockQuery);
        when(
          () => mockQuery.challengeIdEqualTo('nonexistent'),
        ).thenReturn(mockQuery);
        when(() => mockQuery.findFirst()).thenAnswer((_) async => null);

        // Act
        final result = await service.getChallengeProgress('nonexistent');

        // Assert
        expect(result, isNull);
      });
    });

    group('createChallenge', () {
      test('creates new challenge successfully', () async {
        // Arrange
        when(() => mockIsar.writeTxn(any())).thenAnswer((invocation) async {
          final function = invocation.positionalArguments[0] as Function();
          return await function();
        });
        when(() => mockCollection.put(any())).thenAnswer((_) async => 1);

        // Act
        final result = await service.createChallenge(
          title: 'New Challenge',
          description: 'Test Description',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          targetValue: 100,
          xpReward: 150,
        );

        // Assert
        expect(result.title, equals('New Challenge'));
        expect(result.description, equals('Test Description'));
        expect(result.targetValue, equals(100));
        expect(result.xpReward, equals(150));
        expect(result.progress, equals(0));
        expect(result.isActive, isTrue);
        expect(result.needsSync, isTrue);
        expect(result.syncStatus, equals(SyncStatus.pending));
      });
    });

    group('ChallengeProgressData', () {
      test('calculates progress percentage correctly', () {
        // Arrange
        final progressData = ChallengeProgressData(
          challengeId: 'test',
          userId: testUserId,
          progress: 75,
          targetValue: 100,
          completed: false,
          lastUpdated: DateTime.now(),
          isOffline: false,
        );

        // Assert
        expect(progressData.progressPercentage, equals(0.75));
        expect(progressData.remainingProgress, equals(25));
        expect(progressData.isNearCompletion, isTrue);
      });

      test('handles zero target value', () {
        // Arrange
        final progressData = ChallengeProgressData(
          challengeId: 'test',
          userId: testUserId,
          progress: 50,
          targetValue: 0,
          completed: false,
          lastUpdated: DateTime.now(),
          isOffline: false,
        );

        // Assert
        expect(progressData.progressPercentage, equals(0.0));
        expect(progressData.remainingProgress, equals(0));
        expect(progressData.isNearCompletion, isFalse);
      });
    });
  });
}
