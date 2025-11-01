import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:minq/core/notifications/advanced_notification_service.dart';
import 'package:minq/core/notifications/behavior_learning_service.dart';
import 'package:minq/core/notifications/notification_analytics_service.dart';
import 'package:minq/domain/notification/notification_settings.dart';

/// スマート通知スケジューラー
class SmartNotificationScheduler {
  final AdvancedNotificationService _notificationService;
  final BehaviorLearningService _behaviorService;
  final NotificationAnalyticsService _analyticsService;

  final Map<String, Timer> _scheduledNotifications = {};
  final Map<String, NotificationContext> _pendingNotifications = {};

  SmartNotificationScheduler({
    required AdvancedNotificationService notificationService,
    required BehaviorLearningService behaviorService,
    required NotificationAnalyticsService analyticsService,
  }) : _notificationService = notificationService,
       _behaviorService = behaviorService,
       _analyticsService = analyticsService;

  /// スマート通知をスケジュール
  Future<bool> scheduleSmartNotification({
    required String id,
    required String title,
    required String body,
    required NotificationCategory category,
    required String userId,
    Map<String, dynamic>? payload,
    bool isUrgent = false,
    double priority = 1.0,
    Duration? maxDelay,
  }) async {
    final context = NotificationContext(
      timestamp: DateTime.now(),
      category: category,
      userId: userId,
      metadata: payload,
      isUrgent: isUrgent,
      priority: priority,
    );

    // 緊急通知は即座に送信
    if (isUrgent) {
      return await _notificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        category: category,
        userId: userId,
        payload: payload,
        isUrgent: isUrgent,
        priority: priority,
      );
    }

    // スマート通知設定を確認
    final settings = _notificationService.currentSettings;
    if (!settings.smartSettings.enabled) {
      return await _notificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        category: category,
        userId: userId,
        payload: payload,
        priority: priority,
      );
    }

    // 最適タイミングを計算
    final optimalTime = await _calculateOptimalTiming(context, maxDelay);

    if (optimalTime == null ||
        optimalTime.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
      // 即座に送信
      return await _notificationService.scheduleNotification(
        id: id,
        title: title,
        body: body,
        category: category,
        userId: userId,
        payload: payload,
        priority: priority,
      );
    }

    // 遅延送信をスケジュール
    _scheduleDelayedNotification(
      id: id,
      title: title,
      body: body,
      context: context,
      scheduledTime: optimalTime,
    );

    return true;
  }

  /// 最適タイミングを計算
  Future<DateTime?> _calculateOptimalTiming(
    NotificationContext context,
    Duration? maxDelay,
  ) async {
    final settings = _notificationService.currentSettings.smartSettings;

    // 行動パターン分析を取得
    final analysis = await _behaviorService.getOptimalTiming(
      context.userId,
      context.category,
    );

    if (analysis == null ||
        analysis.confidence < settings.confidenceThreshold) {
      return null; // 学習データが不十分
    }

    final now = DateTime.now();
    final maxDelayTime =
        maxDelay != null
            ? now.add(maxDelay)
            : now.add(const Duration(hours: 24));

    // 最適な時間帯を検索
    DateTime? bestTime;
    double bestScore = 0.0;

    for (final hour in analysis.optimalHours) {
      // 今日の該当時間
      var candidateTime = DateTime(now.year, now.month, now.day, hour);

      // 過去の時間の場合は明日にする
      if (candidateTime.isBefore(now)) {
        candidateTime = candidateTime.add(const Duration(days: 1));
      }

      // 最大遅延時間を超える場合はスキップ
      if (candidateTime.isAfter(maxDelayTime)) {
        continue;
      }

      // 時間帯制御をチェック
      if (!await _isTimeAllowed(candidateTime)) {
        continue;
      }

      // スコアを計算（エンゲージメント率 × 優先度調整）
      final engagementRate =
          analysis.hourlyEngagementRates?[hour.toString()] ?? 0.0;
      final timeDistance = candidateTime.difference(now).inHours.abs();
      final distancePenalty = math.exp(-timeDistance / 12.0); // 12時間で半減

      final score = engagementRate * distancePenalty * context.priority;

      if (score > bestScore) {
        bestScore = score;
        bestTime = candidateTime;
      }
    }

    return bestTime;
  }

  /// 時間帯制御をチェック
  Future<bool> _isTimeAllowed(DateTime time) async {
    final settings = _notificationService.currentSettings.timeSettings;

    if (!settings.enabled) return true;

    final hour = time.hour;
    final minute = time.minute;
    final isWeekend =
        time.weekday == DateTime.saturday || time.weekday == DateTime.sunday;

    // 就寝時間チェック
    final sleepTime =
        isWeekend && settings.weekendSleepTime != null
            ? settings.weekendSleepTime!
            : settings.sleepTime;

    if (sleepTime != null) {
      if (_isTimeInRange(hour, minute, sleepTime)) {
        return false;
      }
    }

    // 勤務時間チェック
    final workTime =
        isWeekend && settings.weekendWorkTime != null
            ? settings.weekendWorkTime!
            : settings.workTime;

    if (workTime != null) {
      if (_isTimeInRange(hour, minute, workTime)) {
        return false; // 勤務時間中は制限
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
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  /// 遅延通知をスケジュール
  void _scheduleDelayedNotification({
    required String id,
    required String title,
    required String body,
    required NotificationContext context,
    required DateTime scheduledTime,
  }) {
    // 既存のタイマーをキャンセル
    _scheduledNotifications[id]?.cancel();

    final delay = scheduledTime.difference(DateTime.now());

    _pendingNotifications[id] = context;

    _scheduledNotifications[id] = Timer(delay, () async {
      try {
        await _notificationService.scheduleNotification(
          id: id,
          title: title,
          body: body,
          category: context.category,
          userId: context.userId,
          payload: context.metadata,
          priority: context.priority,
        );

        debugPrint('Smart notification sent: $id at ${DateTime.now()}');
      } catch (e) {
        debugPrint('Failed to send smart notification $id: $e');
      } finally {
        _scheduledNotifications.remove(id);
        _pendingNotifications.remove(id);
      }
    });

    debugPrint('Smart notification scheduled: $id for $scheduledTime');
  }

  /// 通知をキャンセル
  void cancelNotification(String id) {
    _scheduledNotifications[id]?.cancel();
    _scheduledNotifications.remove(id);
    _pendingNotifications.remove(id);
  }

  /// 全通知をキャンセル
  void cancelAllNotifications() {
    for (final timer in _scheduledNotifications.values) {
      timer.cancel();
    }
    _scheduledNotifications.clear();
    _pendingNotifications.clear();
  }

  /// 保留中の通知一覧を取得
  Map<String, NotificationContext> get pendingNotifications =>
      Map.unmodifiable(_pendingNotifications);

  /// リソースを解放
  void dispose() {
    cancelAllNotifications();
  }
}
