import 'package:flutter_test/flutter_test.dart';
import 'package:minq/domain/pair/pair_connection.dart';
import 'package:minq/domain/pair/pair_invitation.dart';
import 'package:minq/domain/pair/pair_message.dart';
import 'package:minq/domain/pair/progress_share.dart';

void main() {
  group('Pair Domain Models', () {
    group('PairConnection', () {
      test('should create PairConnection with correct properties', () {
        // Arrange
        final now = DateTime.now();
        final settings = PairSettings.defaultSettings();
        final statistics = PairStatistics.empty();

        // Act
        final connection = PairConnection(
          id: 'pair123',
          user1Id: 'user1',
          user2Id: 'user2',
          status: PairStatus.active,
          category: 'fitness',
          createdAt: now,
          settings: settings,
          statistics: statistics,
        );

        // Assert
        expect(connection.id, equals('pair123'));
        expect(connection.user1Id, equals('user1'));
        expect(connection.user2Id, equals('user2'));
        expect(connection.status, equals(PairStatus.active));
        expect(connection.category, equals('fitness'));
        expect(connection.createdAt, equals(now));
        expect(connection.isActive, isTrue);
        expect(connection.members, equals(['user1', 'user2']));
      });

      test('should get partner ID correctly', () {
        // Arrange
        final connection = PairConnection(
          id: 'pair123',
          user1Id: 'user1',
          user2Id: 'user2',
          status: PairStatus.active,
          category: 'fitness',
          createdAt: DateTime.now(),
          settings: PairSettings.defaultSettings(),
          statistics: PairStatistics.empty(),
        );

        // Act & Assert
        expect(connection.getPartnerId('user1'), equals('user2'));
        expect(connection.getPartnerId('user2'), equals('user1'));
        expect(() => connection.getPartnerId('user3'), throwsArgumentError);
      });

      test('should create copy with updated properties', () {
        // Arrange
        final original = PairConnection(
          id: 'pair123',
          user1Id: 'user1',
          user2Id: 'user2',
          status: PairStatus.active,
          category: 'fitness',
          createdAt: DateTime.now(),
          settings: PairSettings.defaultSettings(),
          statistics: PairStatistics.empty(),
        );

        // Act
        final updated = original.copyWith(
          status: PairStatus.ended,
          endReason: 'User request',
        );

        // Assert
        expect(updated.id, equals(original.id));
        expect(updated.status, equals(PairStatus.ended));
        expect(updated.endReason, equals('User request'));
        expect(updated.user1Id, equals(original.user1Id));
      });
    });

    group('PairSettings', () {
      test('should create default settings', () {
        // Act
        final settings = PairSettings.defaultSettings();

        // Assert
        expect(settings.progressNotifications, isTrue);
        expect(settings.chatNotifications, isTrue);
        expect(settings.challengeInvites, isTrue);
        expect(settings.weeklyReports, isTrue);
        expect(settings.shareStreaks, isTrue);
        expect(settings.shareCompletions, isTrue);
        expect(settings.allowEncouragement, isTrue);
      });

      test('should create from map', () {
        // Arrange
        final map = {
          'progressNotifications': false,
          'chatNotifications': true,
          'challengeInvites': false,
          'weeklyReports': true,
          'shareStreaks': false,
          'shareCompletions': true,
          'allowEncouragement': false,
        };

        // Act
        final settings = PairSettings.fromMap(map);

        // Assert
        expect(settings.progressNotifications, isFalse);
        expect(settings.chatNotifications, isTrue);
        expect(settings.challengeInvites, isFalse);
        expect(settings.weeklyReports, isTrue);
        expect(settings.shareStreaks, isFalse);
        expect(settings.shareCompletions, isTrue);
        expect(settings.allowEncouragement, isFalse);
      });

      test('should convert to firestore map', () {
        // Arrange
        final settings = PairSettings(
          progressNotifications: false,
          chatNotifications: true,
          challengeInvites: false,
          weeklyReports: true,
          shareStreaks: false,
          shareCompletions: true,
          allowEncouragement: false,
        );

        // Act
        final map = settings.toFirestore();

        // Assert
        expect(map['progressNotifications'], isFalse);
        expect(map['chatNotifications'], isTrue);
        expect(map['challengeInvites'], isFalse);
        expect(map['weeklyReports'], isTrue);
        expect(map['shareStreaks'], isFalse);
        expect(map['shareCompletions'], isTrue);
        expect(map['allowEncouragement'], isFalse);
      });
    });

    group('PairMessage', () {
      test('should create text message', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final message = PairMessage.text(
          id: 'msg123',
          senderId: 'user1',
          text: 'Hello world!',
          timestamp: timestamp,
        );

        // Assert
        expect(message.id, equals('msg123'));
        expect(message.senderId, equals('user1'));
        expect(message.type, equals(MessageType.text));
        expect(message.text, equals('Hello world!'));
        expect(message.timestamp, equals(timestamp));
        expect(message.reactions, isEmpty);
        expect(message.isRead, isFalse);
      });

      test('should create encouragement message', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final message = PairMessage.encouragement(
          id: 'msg123',
          senderId: 'user1',
          text: 'Keep going!',
          timestamp: timestamp,
        );

        // Assert
        expect(message.type, equals(MessageType.encouragement));
        expect(message.text, equals('Keep going!'));
      });

      test('should create system message', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final message = PairMessage.system(
          id: 'msg123',
          text: 'User joined the pair',
          timestamp: timestamp,
        );

        // Assert
        expect(message.senderId, equals('system'));
        expect(message.type, equals(MessageType.system));
        expect(message.isRead, isTrue);
      });

      test('should mark message as read', () {
        // Arrange
        final message = PairMessage.text(
          id: 'msg123',
          senderId: 'user1',
          text: 'Hello',
          timestamp: DateTime.now(),
        );

        // Act
        final readMessage = message.markAsRead();

        // Assert
        expect(readMessage.isRead, isTrue);
        expect(readMessage.readAt, isNotNull);
        expect(message.isRead, isFalse); // Original unchanged
      });

      test('should toggle reactions correctly', () {
        // Arrange
        final message = PairMessage.text(
          id: 'msg123',
          senderId: 'user1',
          text: 'Hello',
          timestamp: DateTime.now(),
        );

        // Act - Add reaction
        final withReaction = message.toggleReaction('👍', 'user2');

        // Assert - Reaction added
        expect(withReaction.reactions['👍'], contains('user2'));

        // Act - Remove reaction
        final withoutReaction = withReaction.toggleReaction('👍', 'user2');

        // Assert - Reaction removed
        expect(withoutReaction.reactions.containsKey('👍'), isFalse);
      });
    });

    group('ProgressShare', () {
      test('should create quest completed progress share', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final share = ProgressShare.questCompleted(
          id: 'quest123',
          userId: 'user1',
          questTitle: 'Morning Exercise',
          description: 'Completed 30 minutes of cardio',
          timestamp: timestamp,
          score: 85,
          tags: ['fitness', 'cardio'],
        );

        // Assert
        expect(share.type, equals(ProgressShareType.questCompleted));
        expect(share.title, equals('Morning Exercise'));
        expect(share.description, equals('Completed 30 minutes of cardio'));
        expect(share.score, equals(85));
        expect(share.tags, equals(['fitness', 'cardio']));
      });

      test('should create streak achieved progress share', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final share = ProgressShare.streakAchieved(
          id: 'streak123',
          userId: 'user1',
          streakDays: 7,
          timestamp: timestamp,
          tags: ['consistency'],
        );

        // Assert
        expect(share.type, equals(ProgressShareType.streakAchieved));
        expect(share.title, equals('7日連続達成！'));
        expect(share.description, equals('継続は力なり！素晴らしいストリークです。'));
        expect(share.score, equals(70)); // 7 * 10
        expect(share.metadata['streakDays'], equals(7));
      });

      test('should create encouragement progress share', () {
        // Arrange
        final timestamp = DateTime.now();

        // Act
        final share = ProgressShare.encouragement(
          id: 'enc123',
          userId: 'user1',
          message: 'You can do it!',
          timestamp: timestamp,
        );

        // Assert
        expect(share.type, equals(ProgressShareType.encouragement));
        expect(share.title, equals('励ましメッセージ'));
        expect(share.description, equals('You can do it!'));
        expect(share.score, isNull);
      });
    });
  });
}
