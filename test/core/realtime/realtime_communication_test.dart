import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:minq/core/realtime/websocket_manager.dart';
import 'package:minq/core/realtime/realtime_service.dart';
import 'package:minq/core/realtime/realtime_message.dart';
import 'package:minq/core/network/network_status_service.dart';
import 'package:minq/core/notifications/advanced_notification_service.dart';

class MockNetworkStatusService extends Mock implements NetworkStatusService {}

class MockAdvancedNotificationService extends Mock
    implements AdvancedNotificationService {}

void main() {
  group('Realtime Communication System', () {
    late MockNetworkStatusService mockNetworkService;
    late MockAdvancedNotificationService mockNotificationService;
    late WebSocketManager webSocketManager;
    late RealtimeService realtimeService;

    setUp(() {
      mockNetworkService = MockNetworkStatusService();
      mockNotificationService = MockAdvancedNotificationService();

      // Mock network service streams
      when(
        () => mockNetworkService.statusStream,
      ).thenAnswer((_) => Stream.value(NetworkStatus.online));
      when(() => mockNetworkService.isOnline).thenReturn(true);

      webSocketManager = WebSocketManager(mockNetworkService);
      realtimeService = RealtimeService(
        webSocketManager,
        mockNotificationService,
      );
    });

    tearDown(() {
      webSocketManager.dispose();
      realtimeService.dispose();
    });

    group('WebSocketManager', () {
      test('should initialize with disconnected status', () {
        expect(webSocketManager.status, equals(WebSocketStatus.disconnected));
        expect(webSocketManager.isConnected, isFalse);
      });

      test('should create heartbeat message correctly', () {
        final heartbeat = RealtimeMessage.heartbeat();

        expect(heartbeat.type, equals(MessageType.heartbeat));
        expect(heartbeat.senderId, equals('client'));
        expect(heartbeat.payload, isEmpty);
      });

      test('should create pair message correctly', () {
        final message = RealtimeMessage.pairMessage(
          messageId: 'msg123',
          senderId: 'user1',
          recipientId: 'user2',
          text: 'Hello!',
        );

        expect(message.type, equals(MessageType.pairMessage));
        expect(message.senderId, equals('user1'));
        expect(message.recipientId, equals('user2'));
        expect(message.payload['messageId'], equals('msg123'));
        expect(message.payload['text'], equals('Hello!'));
      });

      test('should create progress share message correctly', () {
        final message = RealtimeMessage.progressShare(
          senderId: 'user1',
          recipientId: 'user2',
          shareId: 'share123',
          title: 'Quest Completed',
          description: 'Finished morning exercise',
          score: 85,
          tags: ['fitness', 'morning'],
        );

        expect(message.type, equals(MessageType.pairProgressShare));
        expect(message.payload['shareId'], equals('share123'));
        expect(message.payload['title'], equals('Quest Completed'));
        expect(message.payload['score'], equals(85));
        expect(message.payload['tags'], equals(['fitness', 'morning']));
      });

      test('should create encouragement message correctly', () {
        final message = RealtimeMessage.encouragement(
          senderId: 'user1',
          recipientId: 'user2',
          message: 'Keep going!',
          questId: 'quest123',
        );

        expect(message.type, equals(MessageType.pairEncouragement));
        expect(message.payload['message'], equals('Keep going!'));
        expect(message.payload['questId'], equals('quest123'));
      });

      test('should create XP gained message correctly', () {
        final message = RealtimeMessage.xpGained(
          userId: 'user1',
          xpAmount: 50,
          reason: 'Quest completed',
          questId: 'quest123',
        );

        expect(message.type, equals(MessageType.xpGained));
        expect(message.recipientId, equals('user1'));
        expect(message.payload['xpAmount'], equals(50));
        expect(message.payload['reason'], equals('Quest completed'));
      });

      test('should create level up message correctly', () {
        final message = RealtimeMessage.levelUp(
          userId: 'user1',
          newLevel: 5,
          totalXP: 1000,
          rewards: ['badge', 'title'],
        );

        expect(message.type, equals(MessageType.levelUp));
        expect(message.payload['newLevel'], equals(5));
        expect(message.payload['totalXP'], equals(1000));
        expect(message.payload['rewards'], equals(['badge', 'title']));
      });

      test('should create ranking change message correctly', () {
        final message = RealtimeMessage.rankingChange(
          userId: 'user1',
          league: 'gold',
          oldRank: 15,
          newRank: 10,
          weeklyXP: 500,
        );

        expect(message.type, equals(MessageType.rankingChange));
        expect(message.payload['league'], equals('gold'));
        expect(message.payload['oldRank'], equals(15));
        expect(message.payload['newRank'], equals(10));
        expect(message.payload['weeklyXP'], equals(500));
      });

      test('should create push notification message correctly', () {
        final message = RealtimeMessage.pushNotification(
          recipientId: 'user1',
          title: 'New Message',
          body: 'You have a new message from your pair',
          data: {'type': 'pair_message', 'senderId': 'user2'},
        );

        expect(message.type, equals(MessageType.pushNotification));
        expect(message.payload['title'], equals('New Message'));
        expect(
          message.payload['body'],
          equals('You have a new message from your pair'),
        );
        expect(message.payload['data']['type'], equals('pair_message'));
      });
    });

    group('RealtimeService', () {
      test('should initialize with correct streams', () {
        expect(
          realtimeService.pairMessageStream,
          isA<Stream<RealtimeMessage>>(),
        );
        expect(
          realtimeService.progressShareStream,
          isA<Stream<RealtimeMessage>>(),
        );
        expect(
          realtimeService.gamificationStream,
          isA<Stream<RealtimeMessage>>(),
        );
        expect(
          realtimeService.notificationStream,
          isA<Stream<RealtimeMessage>>(),
        );
      });

      test('should handle connection status correctly', () {
        expect(realtimeService.isConnected, isFalse);
        expect(
          realtimeService.connectionStatusStream,
          isA<Stream<WebSocketStatus>>(),
        );
      });
    });

    group('Message Type Enum', () {
      test('should have all required message types', () {
        expect(MessageType.values, contains(MessageType.heartbeat));
        expect(MessageType.values, contains(MessageType.pairMessage));
        expect(MessageType.values, contains(MessageType.pairProgressShare));
        expect(MessageType.values, contains(MessageType.pairEncouragement));
        expect(MessageType.values, contains(MessageType.xpGained));
        expect(MessageType.values, contains(MessageType.levelUp));
        expect(MessageType.values, contains(MessageType.rankingChange));
        expect(MessageType.values, contains(MessageType.pushNotification));
        expect(MessageType.values, contains(MessageType.challengeInvite));
        expect(MessageType.values, contains(MessageType.challengeUpdate));
        expect(MessageType.values, contains(MessageType.challengeCompleted));
      });
    });

    group('WebSocket Status Enum', () {
      test('should have all required status types', () {
        expect(WebSocketStatus.values, contains(WebSocketStatus.disconnected));
        expect(WebSocketStatus.values, contains(WebSocketStatus.connecting));
        expect(WebSocketStatus.values, contains(WebSocketStatus.connected));
        expect(WebSocketStatus.values, contains(WebSocketStatus.reconnecting));
        expect(WebSocketStatus.values, contains(WebSocketStatus.error));
      });
    });
  });
}
