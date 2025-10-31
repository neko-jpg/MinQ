import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

import 'package:minq/core/realtime/realtime_message.dart';
import 'package:minq/core/realtime/websocket_manager.dart';

/// Bridges realtime WebSocket events into typed streams and handles
/// lightweight fan-out for the rest of the app.
class RealtimeService {
  RealtimeService(
    this._webSocketManager, [
    this._notificationService,
  ]) {
    _messageSubscription = _webSocketManager.messageStream.listen(
      _handleRealtimeMessage,
      onError: (error, stackTrace) {
        _logger.e('Realtime message stream error', error, stackTrace);
      },
    );

    _statusSubscription = _webSocketManager.statusStream.listen(
      (status) => _statusController.add(status),
      onError: (error, stackTrace) {
        _logger.w('Realtime status stream error', error, stackTrace);
      },
    );
  }

  final WebSocketManager _webSocketManager;
  final FlutterLocalNotificationsPlugin? _notificationService;
  final Logger _logger = Logger();

  late final StreamSubscription<RealtimeMessage> _messageSubscription;
  late final StreamSubscription<WebSocketStatus> _statusSubscription;

  final _pairMessageController =
      StreamController<RealtimeMessage>.broadcast(sync: true);
  final _progressShareController =
      StreamController<RealtimeMessage>.broadcast(sync: true);
  final _gamificationController =
      StreamController<RealtimeMessage>.broadcast(sync: true);
  final _notificationController =
      StreamController<RealtimeMessage>.broadcast(sync: true);
  final _statusController =
      StreamController<WebSocketStatus>.broadcast(sync: true);

  Stream<RealtimeMessage> get pairMessageStream =>
      _pairMessageController.stream;
  Stream<RealtimeMessage> get progressShareStream =>
      _progressShareController.stream;
  Stream<RealtimeMessage> get gamificationStream =>
      _gamificationController.stream;
  Stream<RealtimeMessage> get notificationStream =>
      _notificationController.stream;
  Stream<WebSocketStatus> get connectionStatusStream =>
      _statusController.stream;

  bool get isConnected => _webSocketManager.isConnected;

  Future<void> connect(String userId) => _webSocketManager.connect(userId);

  void disconnect() => _webSocketManager.disconnect();

  void dispose() {
    _messageSubscription.cancel();
    _statusSubscription.cancel();
    _pairMessageController.close();
    _progressShareController.close();
    _gamificationController.close();
    _notificationController.close();
    _statusController.close();
  }

  void sendPairMessage({
    required String messageId,
    required String senderId,
    required String recipientId,
    required String text,
    String? imageUrl,
  }) {
    final message = RealtimeMessage.pairMessage(
      messageId: messageId,
      senderId: senderId,
      recipientId: recipientId,
      text: text,
      imageUrl: imageUrl,
    );

    _webSocketManager.sendMessage(message);
  }

  void sendProgressShare({
    required String senderId,
    required String recipientId,
    required String shareId,
    required String title,
    required String description,
    int? score,
    List<String>? tags,
  }) {
    final message = RealtimeMessage.progressShare(
      senderId: senderId,
      recipientId: recipientId,
      shareId: shareId,
      title: title,
      description: description,
      score: score,
      tags: tags,
    );

    _webSocketManager.sendMessage(message);
  }

  void sendEncouragement({
    required String senderId,
    required String recipientId,
    required String message,
    String? questId,
  }) {
    final encouragement = RealtimeMessage.encouragement(
      senderId: senderId,
      recipientId: recipientId,
      message: message,
      questId: questId,
    );

    _webSocketManager.sendMessage(encouragement);
  }

  void _handleRealtimeMessage(RealtimeMessage message) {
    _logger.d('Realtime message received: ${message.type}');

    switch (message.type) {
      case MessageType.pairMessage:
      case MessageType.pairEncouragement:
      case MessageType.pairInvitation:
      case MessageType.pairAccepted:
        _pairMessageController.add(message);
        _maybeNotify(
          id: message.payload['notificationId'] as int? ?? 1001,
          title: message.payload['title'] as String? ??
              'New pair update',
          body: message.payload['text'] as String? ?? '',
          payload: 'pair_message',
        );
        break;
      case MessageType.pairProgressShare:
        _progressShareController.add(message);
        break;
      case MessageType.xpGained:
      case MessageType.levelUp:
      case MessageType.rankingChange:
      case MessageType.leagueUpdate:
        _gamificationController.add(message);
        break;
      case MessageType.pushNotification:
      case MessageType.questReminder:
      case MessageType.streakAlert:
        _notificationController.add(message);
        _maybeNotify(
          id: message.payload['notificationId'] as int? ?? 2001,
          title: message.payload['title'] as String? ?? 'Notification',
          body: message.payload['body'] as String? ?? '',
          payload: 'system_notification',
        );
        break;
      case MessageType.challengeInvite:
      case MessageType.challengeUpdate:
      case MessageType.challengeCompleted:
      case MessageType.userOnline:
      case MessageType.userOffline:
        // Currently just broadcast the raw message.
        _notificationController.add(message);
        break;
      case MessageType.unknown:
        _logger.w('Unhandled realtime message: $message');
        break;
    }
  }

  Future<void> _maybeNotify({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final plugin = _notificationService;
    if (plugin == null) {
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'realtime_channel',
        'Realtime Updates',
        channelDescription: 'Notifications for realtime events',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    try {
      await plugin.show(id, title, body, notificationDetails, payload: payload);
    } catch (error, stackTrace) {
      _logger.w('Unable to show realtime notification', error, stackTrace);
    }
  }
}
