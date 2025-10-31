import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/profile/profile_service.dart';
import 'package:minq/core/sync/sync_queue_manager.dart';
import 'package:minq/domain/user/user.dart';
import 'package:minq/domain/user/user_profile.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncQueueManager extends Mock implements SyncQueueManager {}

void main() {
  group('ProfileService', () {
    late Isar isar;
    late MockSyncQueueManager mockSyncQueueManager;
    late ProfileService profileService;

    setUpAll(() async {
      await Isar.initializeIsarCore(download: true);
    });

    setUp(() async {
      isar = await Isar.open([
        UserSchema,
        SyncJobSchema,
      ], directory: '');
      
      mockSyncQueueManager = MockSyncQueueManager();
      profileService = ProfileService(
        isar: isar,
        syncQueueManager: mockSyncQueueManager,
      );
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    group('updateProfile', () {
      test('should update user profile successfully', () async {
        // Arrange
        final user = User()
          ..uid = 'test-uid'
          ..displayName = 'Old Name'
          ..bio = 'Old bio'
          ..avatarSeed = 'old-seed'
          ..focusTags = ['old-tag']
          ..notificationTimes = []
          ..privacy = 'public'
          ..createdAt = DateTime.now();

        await isar.writeTxn(() => isar.users.put(user));

        final request = ProfileUpdateRequest(
          displayName: 'New Name',
          bio: 'New bio',
          avatarSeed: 'new-seed',
          focusTags: ['new-tag1', 'new-tag2'],
          privacy: 'private',
        );

        // Act
        final result = await profileService.updateProfile('test-uid', request);

        // Assert
        expect(result.isValid, isTrue);
        
        final updatedUser = await isar.users.filter().uidEqualTo('test-uid').findFirst();
        expect(updatedUser?.displayName, equals('New Name'));
        expect(updatedUser?.bio, equals('New bio'));
        expect(updatedUser?.avatarSeed, equals('new-seed'));
        expect(updatedUser?.focusTags, equals(['new-tag1', 'new-tag2']));
        expect(updatedUser?.privacy, equals('private'));
        
        verify(() => mockSyncQueueManager.enqueueSyncJob(any())).called(1);
      });

      test('should validate display name length', () async {
        // Arrange
        final user = User()
          ..uid = 'test-uid'
          ..displayName = 'Test'
          ..createdAt = DateTime.now();

        await isar.writeTxn(() => isar.users.put(user));

        final request = ProfileUpdateRequest(
          displayName: 'This is a very long display name that exceeds the maximum allowed length',
        );

        // Act
        final result = await profileService.updateProfile('test-uid', request);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors['displayName'], contains('30文字以内'));
      });

      test('should validate handle format', () async {
        // Arrange
        final user = User()
          ..uid = 'test-uid'
          ..displayName = 'Test'
          ..createdAt = DateTime.now();

        await isar.writeTxn(() => isar.users.put(user));

        final request = ProfileUpdateRequest(
          handle: 'invalid-handle!',
        );

        // Act
        final result = await profileService.updateProfile('test-uid', request);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors['handle'], contains('英数字とアンダースコア'));
      });

      test('should limit focus tags to 5', () async {
        // Arrange
        final user = User()
          ..uid = 'test-uid'
          ..displayName = 'Test'
          ..createdAt = DateTime.now();

        await isar.writeTxn(() => isar.users.put(user));

        final request = ProfileUpdateRequest(
          focusTags: ['tag1', 'tag2', 'tag3', 'tag4', 'tag5', 'tag6'],
        );

        // Act
        final result = await profileService.updateProfile('test-uid', request);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.errors['focusTags'], contains('最大5つまで'));
      });
    });

    group('getProfile', () {
      test('should return user profile', () async {
        // Arrange
        final user = User()
          ..uid = 'test-uid'
          ..displayName = 'Test User'
          ..bio = 'Test bio'
          ..avatarSeed = 'test-seed'
          ..focusTags = ['tag1', 'tag2']
          ..notificationTimes = ['09:00', '18:00']
          ..privacy = 'public'
          ..longestStreak = 10
          ..currentStreak = 5
          ..currentLevel = 2
          ..totalPoints = 150
          ..createdAt = DateTime.now();

        await isar.writeTxn(() => isar.users.put(user));

        // Act
        final profile = await profileService.getProfile('test-uid');

        // Assert
        expect(profile, isNotNull);
        expect(profile!.uid, equals('test-uid'));
        expect(profile.displayName, equals('Test User'));
        expect(profile.bio, equals('Test bio'));
        expect(profile.avatarSeed, equals('test-seed'));
        expect(profile.focusTags, equals(['tag1', 'tag2']));
        expect(profile.privacy, equals('public'));
        expect(profile.longestStreak, equals(10));
        expect(profile.currentStreak, equals(5));
        expect(profile.currentLevel, equals(2));
        expect(profile.totalPoints, equals(150));
      });

      test('should return null for non-existent user', () async {
        // Act
        final profile = await profileService.getProfile('non-existent-uid');

        // Assert
        expect(profile, isNull);
      });
    });

    group('avatar generation', () {
      test('should generate unique avatar seeds', () {
        // Act
        final seed1 = profileService.generateAvatarSeed();
        final seed2 = profileService.generateAvatarSeed();

        // Assert
        expect(seed1, isNot(equals(seed2)));
        expect(seed1, startsWith('seed-'));
        expect(seed2, startsWith('seed-'));
      });

      test('should provide predefined avatar seeds', () {
        // Act
        final seeds = profileService.getAvailableAvatarSeeds();

        // Assert
        expect(seeds, isNotEmpty);
        expect(seeds.length, equals(10));
        expect(seeds.every((seed) => seed.startsWith('seed-')), isTrue);
      });
    });

    group('focus tags', () {
      test('should provide available focus tags', () {
        // Act
        final tags = profileService.getAvailableFocusTags();

        // Assert
        expect(tags, isNotEmpty);
        expect(tags, contains('Productivity'));
        expect(tags, contains('Health'));
        expect(tags, contains('Learning'));
      });
    });
  });
}