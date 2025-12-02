import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minq/core/deeplink/deeplink_handler.dart';
import 'package:minq/core/notifications/notification_channels.dart';

/// プッシュ通知ハンドラー
class PushNotificationHandler {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final DeepLinkHandler _deepLinkHandler;

  final StreamController<RemoteMessage> _messageController =
      StreamController<RemoteMessage>.broadcast();

  PushNotificationHandler({
    required FirebaseMessaging messaging,
    required FlutterLocalNotificationsPlugin localNotifications,
    required DeepLinkHandler deepLinkHandler,
  }) : _messaging = messaging,
       _localNotifications = localNotifications,
       _deepLinkHandler = deepLinkHandler;

  /// メッセージストリーム
  Stream<RemoteMessage> get messageStream => _messageController.stream;

  /// 初期化
  Future<void> initialize() async {
    // 通知権限をリクエスト
    await _requestPermission();

    // FCMトークンを取得
    final token = await _messaging.getToken();
    print('📱 FCM Token: $token');

    // トークン更新を監視
    _messaging.onTokenRefresh.listen((token) {
      print('🔄 FCM Token refreshed: $token');
      // サーバーに新しいトークンを送信
      _sendTokenToServer(token);
    });

    // フォアグラウンドメッセージを処理
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // バックグラウンドメッセージを処理
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // アプリ起動時のメッセージを処理
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    // ローカル通知のタップを処理
    _setupLocalNotificationTapHandler();
  }

  /// 通知権限をリクエスト
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('⚠️ Notification permission granted provisionally');
    } else {
      print('❌ Notification permission denied');
    }
  }

  /// フォアグラウンドメッセージを処理
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📬 Foreground message received: ${message.messageId}');

    _messageController.add(message);

    // ローカル通知として表示
    await _showLocalNotification(message);
  }

  /// バックグラウンドメッセージを処理
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📬 Background message opened: ${message.messageId}');

    _messageController.add(message);

    // ディープリンクを処理
    final deepLink = message.data['deepLink'] as String?;
    if (deepLink != null) {
      await _deepLinkHandler.handleUrl(deepLink);
    }
  }

  /// ローカル通知として表示
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final channelId = _getChannelId(message);
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: _getIOSCategory(message),
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['deepLink'] as String?,
    );
  }

  /// チャンネルIDを取得
  String _getChannelId(RemoteMessage message) {
    final type = message.data['type'] as String?;

    switch (type) {
      case 'quest_reminder':
        return NotificationChannelId.important;
      case 'pair_message':
        return NotificationChannelId.pair;
      case 'system':
        return NotificationChannelId.system;
      default:
        return NotificationChannelId.normal;
    }
  }

  /// チャンネル名を取得
  String _getChannelName(String channelId) {
    switch (channelId) {
      case NotificationChannelId.important:
        return '重要な通知';
      case NotificationChannelId.pair:
        return 'ペア通知';
      case NotificationChannelId.system:
        return 'システム通知';
      default:
        return '通常の通知';
    }
  }

  /// iOSカテゴリーを取得
  String? _getIOSCategory(RemoteMessage message) {
    final type = message.data['type'] as String?;

    switch (type) {
      case 'quest_reminder':
        return IOSNotificationCategory.questCompletion;
      case 'pair_message':
        return IOSNotificationCategory.pairMessage;
      default:
        return null;
    }
  }

  /// ローカル通知のタップハンドラーを設定
  void _setupLocalNotificationTapHandler() {
    _localNotifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          _deepLinkHandler.handleUrl(payload);
        }
      },
    );
  }

  /// トークンをサーバーに送信
  Future<void> _sendTokenToServer(String token) async {
    // TODO: サーバーにトークンを送信
    print('📤 Sending token to server: $token');
  }

  /// トピックを購読
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    print('✅ Subscribed to topic: $topic');
  }

  /// トピックの購読を解除
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    print('✅ Unsubscribed from topic: $topic');
  }

  /// クリーンアップ
  void dispose() {
    _messageController.close();
  }
}

/// バックグラウンドメッセージハンドラー（トップレベル関数）
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📬 Background message received: ${message.messageId}');
  // バックグラウンドでの処理（データ同期など）
}

/// プッシュ通知トピック
class PushNotificationTopics {
  const PushNotificationTopics._();

  /// 全ユーザー向け
  static const String all = 'all_users';

  /// 新機能のお知らせ
  static const String newFeatures = 'new_features';

  /// メンテナンス情報
  static const String maintenance = 'maintenance';

  /// 週次レポート
  static const String weeklyReport = 'weekly_report';

  /// ペア機能のお知らせ
  static const String pairUpdates = 'pair_updates';
}

/// プッシュ通知ペイロード
class PushNotificationPayload {
  final String type;
  final String? title;
  final String? body;
  final Map<String, dynamic> data;
  final String? deepLink;
  final String? imageUrl;

  const PushNotificationPayload({
    required this.type,
    this.title,
    this.body,
    this.data = const {},
    this.deepLink,
    this.imageUrl,
  });

  /// クエストリマインダー
  factory PushNotificationPayload.questReminder({
    required String questId,
    required String questTitle,
  }) {
    return PushNotificationPayload(
      type: 'quest_reminder',
      title: 'クエストのリマインダー',
      body: '$questTitleの時間です！',
      data: {'questId': questId},
      deepLink: DeepLinkHandler.generateUrl(
        type: DeepLinkType.questRecord,
        parameters: {'questId': questId},
      ),
    );
  }

  /// ペアメッセージ
  factory PushNotificationPayload.pairMessage({
    required String pairId,
    required String senderName,
    required String message,
  }) {
    return PushNotificationPayload(
      type: 'pair_message',
      title: '$senderNameからのメッセージ',
      body: message,
      data: {'pairId': pairId},
      deepLink: DeepLinkHandler.generateUrl(
        type: DeepLinkType.pairChat,
        parameters: {'pairId': pairId},
      ),
    );
  }

  /// デイリーサマリー
  factory PushNotificationPayload.dailySummary({
    required int completedQuests,
    required int totalQuests,
  }) {
    return PushNotificationPayload(
      type: 'daily_summary',
      title: '今日の振り返り',
      body: '$completedQuests/$totalQuests クエストを完了しました！',
      deepLink: DeepLinkHandler.generateUrl(type: DeepLinkType.stats),
    );
  }

  /// システム通知
  factory PushNotificationPayload.system({
    required String title,
    required String body,
  }) {
    return PushNotificationPayload(type: 'system', title: title, body: body);
  }

  /// JSONに変換
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      'data': data,
      if (deepLink != null) 'deepLink': deepLink,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  /// JSONから生成
  factory PushNotificationPayload.fromJson(Map<String, dynamic> json) {
    return PushNotificationPayload(
      type: json['type'] as String,
      title: json['title'] as String?,
      body: json['body'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? {},
      deepLink: json['deepLink'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// プッシュ通知統計
class PushNotificationStats {
  int _receivedCount = 0;
  int _openedCount = 0;
  final Map<String, int> _typeCount = {};

  /// 受信数
  int get receivedCount => _receivedCount;

  /// 開封数
  int get openedCount => _openedCount;

  /// 開封率
  double get openRate =>
      _receivedCount > 0 ? _openedCount / _receivedCount : 0.0;

  /// 受信を記録
  void recordReceived(String type) {
    _receivedCount++;
    _typeCount[type] = (_typeCount[type] ?? 0) + 1;
  }

  /// 開封を記録
  void recordOpened() {
    _openedCount++;
  }

  /// タイプ別の受信数を取得
  int getTypeCount(String type) {
    return _typeCount[type] ?? 0;
  }

  /// 統計をリセット
  void reset() {
    _receivedCount = 0;
    _openedCount = 0;
    _typeCount.clear();
  }

  /// 統計を取得
  Map<String, dynamic> getStats() {
    return {
      'receivedCount': _receivedCount,
      'openedCount': _openedCount,
      'openRate': openRate,
      'typeCount': Map.unmodifiable(_typeCount),
    };
  }
}
