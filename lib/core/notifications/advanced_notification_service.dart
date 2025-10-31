import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minq/core/notifications/behavior_learning_service.dart';
import 'package:minq/core/notifications/notification_analytics_service.dart';
import 'package:minq/domain/notification/notification_analytics.dart';
import 'package:minq/domain/notification/notification_settings.dart' as domain;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

/// 高度な通知サービス
class AdvancedNotificationService {
  static const String _settingsKey = 'notification_settings';
  static const String _deviceTokenKey = 'device_token';

  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseMessaging _firebaseMessaging;
  final SharedPreferences _prefs;
  final NotificationAnalyticsService _analyticsService;
  final BehaviorLearningService _behaviorService;

  domain.NotificationSettings? _currentSettings;
  StreamController<NotificationEvent>? _eventController;

  AdvancedNotificationService({
    required FlutterLocalNotificationsPlugin localNotifications,
    required FirebaseMessaging firebaseMessaging,
    required SharedPreferences prefs,
    required NotificationAnalyticsService analyticsService,
    required BehaviorLearningService behaviorService,
  })  : _localNotifications = localNotifications,
        _firebaseMessaging = firebaseMessaging,
        _prefs = prefs,
        _analyticsService = analyticsService,
        _behaviorService = behaviorService;

  /// 通知イベントストリーム
  Stream<NotificationEvent> get eventStream =>
      _eventController?.stream ?? const Stream.empty();

  /// 初期化
  Future<void> initialize() async {
    _eventController = StreamController<NotificationEvent>.broadcast();

    // ローカル通知の初期化
    await _initializeLocalNotifications();

    // Firebase Messaging の初期化
    await _initializeFirebaseMessaging();

    // 設定の読み込み
    await _loadSettings();

    // 分析サービスの初期化
    await _analyticsService.initialize();
    await _behaviorService.initialize();

    debugPrint('AdvancedNotificationService initialized');
  }

  /// ローカル通知の初期化
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
  }

  /// Firebase Messaging の初期化
  Future<void> _initializeFirebaseMessaging() async {
    // 権限リクエスト
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    }

    // デバイストークンの取得
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      await _prefs.setString(_deviceTokenKey, token);
      debugPrint('FCM Token: $token');
    }

    // フォアグラウンドメッセージの処理
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // バックグラウンドメッセージの処理
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
  }

  /// 設定の読み込み
  Future<void> _loadSettings() async {
    final settingsJson = _prefs.getString(_settingsKey);
    if (settingsJson != null) {
      try {
        final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
        _currentSettings = NotificationSettings.fromJson(settingsMap);
      } catch (e) {
        debugPrint('Failed to load notification settings: $e');
        _currentSettings = NotificationSettings.defaultSettings();
      }
    } else {
      _currentSettings = NotificationSettings.defaultSettings();
    }
  }

  /// 設定の保存
  Future<void> _saveSettings() async {
    if (_currentSettings != null) {
      final settingsJson = jsonEncode(_currentSettings!.toJson());
      await _prefs.setString(_settingsKey, settingsJson);
    }
  }

  /// 現在の設定を取得
  domain.NotificationSettings get currentSettings =>
      _currentSettings ?? domain.NotificationSettings.defaultSettings();

  /// 設定を更新
  Future<void> updateSettings(domain.NotificationSettings settings) async {
    _currentSettings = settings.copyWith(lastUpdated: DateTime.now());
    await _saveSettings();
    debugPrint('Notification settings updated');
  }

  /// カテゴリ別設定を更新
  Future<void> updateCategorySettings(
    domain.NotificationCategory category,
    domain.CategoryNotificationSettings settings,
  ) async {
    final currentSettings = this.currentSettings;
    final updatedCategorySettings = Map<domain.NotificationCategory, domain.CategoryNotificationSettings>.from(
      currentSettings.categorySettings,
    );
    updatedCategorySettings[category] = settings;

    await updateSettings(
      currentSettings.copyWith(categorySettings: updatedCategorySettings),
    );
  }

  /// 時間帯設定を更新
  Future<void> updateTimeSettings(domain.TimeBasedNotificationSettings settings) async {
    await updateSettings(currentSettings.copyWith(timeSettings: settings));
  }

  /// スマート通知設定を更新
  Future<void> updateSmartSettings(domain.SmartNotificationSettings settings) async {
    await updateSettings(currentSettings.copyWith(smartSettings: settings));
  }

  /// 通知をスケジュール
  Future<bool> scheduleNotification({
    required String id,
    required String title,
    required String body,
    required NotificationCategory category,
    required String userId,
    DateTime? scheduledTime,
    Map<String, dynamic>? payload,
    bool isUrgent = false,
    double priority = 1.0,
  }) async {
    final settings = currentSettings;

    // グローバル設定チェック
    if (!settings.globalEnabled) {
      debugPrint('Notifications globally disabled');
      return false;
    }

    // カテゴリ設定チェック
    final categorySettings = settings.categorySettings[category];
    if (categorySettings == null || !categorySettings.enabled) {
      debugPrint('Category $category notifications disabled');
      return false;
    }

    // 通知コンテキストを作成
    final context = NotificationContext(
      timestamp: DateTime.now(),
      category: category,
      userId: userId,
      metadata: payload,
      isUrgent: isUrgent,
      priority: priority,
    );

    // スマート通知が有効な場合、最適なタイミングを計算
    DateTime? optimalTime = scheduledTime;
    if (settings.smartSettings.enabled && scheduledTime == null) {
      optimalTime = await _calculateOptimalTiming(context);
    }

    // 時間帯制御チェック
    if (optimalTime != null && !await _isTimeAllowed(optimalTime, settings.timeSettings)) {
      // 次の許可された時間を計算
      optimalTime = await _getNextAllowedTime(optimalTime, settings.timeSettings);
    }

    // 通知をスケジュール
    final success = await _scheduleLocalNotification(
      id: id,
      title: title,
      body: body,
      scheduledTime: optimalTime,
      categorySettings: categorySettings,
      payload: payload,
    );

    if (success) {
      // 分析イベントを記録
      await _recordEvent(NotificationEvent(
        id: _generateEventId(),
        notificationId: id,
        userId: userId,
        eventType: NotificationEventType.sent,
        category: category,
        timestamp: DateTime.now(),
        metadata: payload,
      ));

      // 行動学習データを更新
      if (settings.smartSettings.behaviorLearning) {
        await _behaviorService.recordNotificationSent(context);
      }
    }

    return success;
  }

  /// 最適なタイミングを計算
  Future<DateTime?> _calculateOptimalTiming(NotificationContext context) async {
    final analysis = await _behaviorService.getOptimalTiming(
      context.userId,
      context.category,
    );

    if (analysis == null || analysis.confidence < currentSettings.smartSettings.confidenceThreshold) {
      return null; // 即座に送信
    }

    final now = DateTime.now();
    final currentHour = now.hour;

    // 最適な時間帯を見つける
    int? nextOptimalHour;
    for (final hour in analysis.optimalHours) {
      if (hour > currentHour) {
        nextOptimalHour = hour;
        break;
      }
    }

    // 今日の最適な時間がない場合、明日の最初の最適時間を使用
    if (nextOptimalHour == null && analysis.optimalHours.isNotEmpty) {
      nextOptimalHour = analysis.optimalHours.first;
      return DateTime(now.year, now.month, now.day + 1, nextOptimalHour);
    }

    if (nextOptimalHour != null) {
      return DateTime(now.year, now.month, now.day, nextOptimalHour);
    }

    return null; // 即座に送信
  }

  /// 指定時間が許可されているかチェック
  Future<bool> _isTimeAllowed(DateTime time, TimeBasedNotificationSettings settings) async {
    if (!settings.enabled) return true;

    final hour = time.hour;
    final minute = time.minute;
    final isWeekend = time.weekday == DateTime.saturday || time.weekday == DateTime.sunday;

    // 就寝時間チェック
    final sleepTime = isWeekend && settings.weekendSleepTime != null
        ? settings.weekendSleepTime!
        : settings.sleepTime;

    if (sleepTime != null) {
      if (_isTimeInRange(hour, minute, sleepTime)) {
        return false;
      }
    }

    // 勤務時間チェック（制限モード）
    final workTime = isWeekend && settings.weekendWorkTime != null
        ? settings.weekendWorkTime!
        : settings.workTime;

    if (workTime != null) {
      if (_isTimeInRange(hour, minute, workTime)) {
        // 勤務時間中は緊急通知のみ許可
        return false; // 簡略化：ここでは全て拒否
      }
    }

    // カスタム静音時間チェック
    for (final quietHour in settings.customQuietHours) {
      if (_isTimeInRange(hour, minute, quietHour)) {
        return false;
      }
    }

    return true;
  }

  /// 時間が範囲内かチェック
  bool _isTimeInRange(int hour, int minute, TimeSlot timeSlot) {
    final currentMinutes = hour * 60 + minute;
    final startMinutes = timeSlot.startHour * 60 + timeSlot.startMinute;
    final endMinutes = timeSlot.endHour * 60 + timeSlot.endMinute;

    if (startMinutes <= endMinutes) {
      // 同日内の範囲
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // 日をまたぐ範囲
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  /// 次の許可された時間を取得
  Future<DateTime> _getNextAllowedTime(DateTime from, TimeBasedNotificationSettings settings) async {
    var candidate = from.add(const Duration(minutes: 30)); // 30分後から開始

    for (var i = 0; i < 48; i++) { // 最大24時間先まで検索
      if (await _isTimeAllowed(candidate, settings)) {
        return candidate;
      }
      candidate = candidate.add(const Duration(minutes: 30));
    }

    return from.add(const Duration(hours: 24)); // 24時間後にフォールバック
  }

  /// ローカル通知をスケジュール
  Future<bool> _scheduleLocalNotification({
    required String id,
    required String title,
    required String body,
    DateTime? scheduledTime,
    required CategoryNotificationSettings categorySettings,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        categorySettings.category.id,
        categorySettings.category.displayName,
        channelDescription: '${categorySettings.category.displayName}の通知',
        importance: Importance.high,
        priority: Priority.high,
        playSound: categorySettings.sound,
        enableVibration: categorySettings.vibration,
        vibrationPattern: categorySettings.vibrationPattern != null
            ? Int64List.fromList(categorySettings.vibrationPattern!)
            : null,
        showBadge: categorySettings.badge,
        visibility: categorySettings.lockScreen
            ? NotificationVisibility.public
            : NotificationVisibility.private,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final payloadJson = payload != null ? jsonEncode(payload) : null;

      if (scheduledTime != null) {
        await _localNotifications.zonedSchedule(
          id.hashCode,
          title,
          body,
          tz.TZDateTime.from(scheduledTime, tz.local),
          details,
          payload: payloadJson,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } else {
        await _localNotifications.show(
          id.hashCode,
          title,
          body,
          details,
          payload: payloadJson,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Failed to schedule notification: $e');
      return false;
    }
  }

  /// 通知応答の処理
  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final payloadMap = jsonDecode(payload) as Map<String, dynamic>;
        _handleNotificationAction(payloadMap, response.actionId);
      } catch (e) {
        debugPrint('Failed to parse notification payload: $e');
      }
    }
  }

  /// フォアグラウンドメッセージの処理
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Received foreground message: ${message.messageId}');
    
    // 分析イベントを記録
    _recordEvent(NotificationEvent(
      id: _generateEventId(),
      notificationId: message.messageId ?? '',
      userId: '', // ユーザーIDを取得する必要がある
      eventType: NotificationEventType.delivered,
      category: _getCategoryFromMessage(message),
      timestamp: DateTime.now(),
      metadata: message.data,
    ));
  }

  /// バックグラウンドメッセージの処理
  void _handleBackgroundMessage(RemoteMessage message) {
    debugPrint('Received background message: ${message.messageId}');
    _handleNotificationAction(message.data, null);
  }

  /// 通知アクションの処理
  void _handleNotificationAction(Map<String, dynamic> data, String? actionId) {
    // 分析イベントを記録
    _recordEvent(NotificationEvent(
      id: _generateEventId(),
      notificationId: data['notification_id'] ?? '',
      userId: data['user_id'] ?? '',
      eventType: NotificationEventType.opened,
      category: _getCategoryFromData(data),
      timestamp: DateTime.now(),
      metadata: data,
      actionTaken: actionId,
    ));

    // 行動学習データを更新
    if (currentSettings.smartSettings.behaviorLearning) {
      _behaviorService.recordNotificationOpened(
        data['user_id'] ?? '',
        _getCategoryFromData(data),
        DateTime.now(),
      );
    }
  }

  /// メッセージからカテゴリを取得
  NotificationCategory _getCategoryFromMessage(RemoteMessage message) {
    final categoryId = message.data['category'] ?? 'system';
    return NotificationCategory.values.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => NotificationCategory.system,
    );
  }

  /// データからカテゴリを取得
  NotificationCategory _getCategoryFromData(Map<String, dynamic> data) {
    final categoryId = data['category'] ?? 'system';
    return NotificationCategory.values.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => NotificationCategory.system,
    );
  }

  /// イベントを記録
  Future<void> _recordEvent(NotificationEvent event) async {
    _eventController?.add(event);
    await _analyticsService.recordEvent(event);
  }

  /// イベントIDを生成
  String _generateEventId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  /// 通知をキャンセル
  Future<void> cancelNotification(String id) async {
    await _localNotifications.cancel(id.hashCode);
  }

  /// 全通知をキャンセル
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// 通知メトリクスを取得
  Future<NotificationMetrics> getMetrics({
    required String userId,
    required NotificationCategory category,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _analyticsService.getMetrics(
      userId: userId,
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// 最適タイミング分析を取得
  Future<OptimalTimingAnalysis?> getOptimalTimingAnalysis({
    required String userId,
    required NotificationCategory category,
  }) async {
    return await _behaviorService.getOptimalTiming(userId, category);
  }

  /// 行動パターン分析を取得
  Future<BehaviorPatternAnalysis?> getBehaviorPatternAnalysis({
    required String userId,
  }) async {
    return await _behaviorService.getBehaviorPattern(userId);
  }

  /// リソースを解放
  void dispose() {
    _eventController?.close();
  }
}