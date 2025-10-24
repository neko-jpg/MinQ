import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minq/core/notifications/notification_channels.dart';

/// まとめ通知サービス
class SummaryNotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  final Map<String, List<PendingNotification>> _pendingNotifications = {};

  SummaryNotificationService(this._notifications);

  /// 通知を追加（まとめ通知用）
  Future<void> addNotification({
    required String groupKey,
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final notification = PendingNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
    );

    _pendingNotifications.putIfAbsent(groupKey, () => []);
    _pendingNotifications[groupKey]!.add(notification);

    // 個別通知を表示
    await _showIndividualNotification(
      groupKey: groupKey,
      notification: notification,
    );

    // まとめ通知を更新
    await _updateSummaryNotification(groupKey);
  }

  /// 個別通知を表示
  Future<void> _showIndividualNotification({
    required String groupKey,
    required PendingNotification notification,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      NotificationChannelId.normal,
      '通常の通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      groupKey: groupKey,
      setAsGroupSummary: false,
    );

    final iosDetails = DarwinNotificationDetails(threadIdentifier: groupKey);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      notification.id,
      notification.title,
      notification.body,
      details,
      payload: notification.payload,
    );
  }

  /// まとめ通知を更新
  Future<void> _updateSummaryNotification(String groupKey) async {
    final notifications = _pendingNotifications[groupKey] ?? [];

    if (notifications.isEmpty) {
      return;
    }

    final count = notifications.length;
    final config = _getSummaryConfig(groupKey, count);

    // Android用のまとめ通知
    final androidDetails = AndroidNotificationDetails(
      NotificationChannelId.normal,
      '通常の通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      groupKey: groupKey,
      setAsGroupSummary: true,
      styleInformation: InboxStyleInformation(
        notifications.map((n) => n.body).toList(),
        contentTitle: config.summaryTitle,
        summaryText: config.summaryBody,
      ),
    );

    // iOS用のまとめ通知
    final iosDetails = DarwinNotificationDetails(threadIdentifier: groupKey);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // まとめ通知のIDはグループキーのハッシュ値を使用
    final summaryId = groupKey.hashCode;

    await _notifications.show(
      summaryId,
      config.summaryTitle,
      config.summaryBody,
      details,
    );
  }

  /// グループキーに応じたまとめ通知設定を取得
  SummaryNotificationConfig _getSummaryConfig(String groupKey, int count) {
    switch (groupKey) {
      case NotificationGroup.quests:
        return SummaryNotificationConfig.quests(count);
      case NotificationGroup.pairs:
        return SummaryNotificationConfig.pairs(count);
      default:
        return SummaryNotificationConfig(
          groupKey: groupKey,
          summaryTitle: '通知',
          summaryBody: '$count件の通知があります',
          notificationCount: count,
        );
    }
  }

  /// グループの通知をクリア
  Future<void> clearGroup(String groupKey) async {
    final notifications = _pendingNotifications[groupKey] ?? [];

    for (final notification in notifications) {
      await _notifications.cancel(notification.id);
    }

    // まとめ通知もキャンセル
    final summaryId = groupKey.hashCode;
    await _notifications.cancel(summaryId);

    _pendingNotifications.remove(groupKey);
  }

  /// 全ての通知をクリア
  Future<void> clearAll() async {
    await _notifications.cancelAll();
    _pendingNotifications.clear();
  }

  /// グループ内の通知数を取得
  int getNotificationCount(String groupKey) {
    return _pendingNotifications[groupKey]?.length ?? 0;
  }

  /// 全グループの通知数を取得
  int getTotalNotificationCount() {
    return _pendingNotifications.values.fold(
      0,
      (sum, list) => sum + list.length,
    );
  }
}

/// 保留中の通知
class PendingNotification {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final DateTime createdAt;

  PendingNotification({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
  }) : createdAt = DateTime.now();
}

/// デイリーサマリー通知サービス
class DailySummaryNotificationService {
  final FlutterLocalNotificationsPlugin _notifications;

  DailySummaryNotificationService(this._notifications);

  /// デイリーサマリーを送信
  Future<void> sendDailySummary({
    required int completedQuests,
    required int totalQuests,
    required int currentStreak,
    required double achievementRate,
  }) async {
    const title = '今日の振り返り';
    final body = _buildSummaryBody(
      completedQuests: completedQuests,
      totalQuests: totalQuests,
      currentStreak: currentStreak,
      achievementRate: achievementRate,
    );

    final androidDetails = AndroidNotificationDetails(
      NotificationChannelId.low,
      '低優先度の通知',
      importance: Importance.low,
      priority: Priority.low,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      999, // デイリーサマリー用の固定ID
      title,
      body,
      details,
    );
  }

  /// サマリー本文を構築
  String _buildSummaryBody({
    required int completedQuests,
    required int totalQuests,
    required int currentStreak,
    required double achievementRate,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('📊 今日の成果');
    buffer.writeln('');
    buffer.writeln('✅ 完了: $completedQuests/$totalQuests クエスト');
    buffer.writeln('🔥 連続: $currentStreak日');
    buffer.writeln('📈 達成率: ${achievementRate.toStringAsFixed(1)}%');

    if (achievementRate >= 80) {
      buffer.writeln('');
      buffer.writeln('🎉 素晴らしい！今日も頑張りました！');
    } else if (achievementRate >= 50) {
      buffer.writeln('');
      buffer.writeln('👍 良いペースです！');
    } else if (completedQuests > 0) {
      buffer.writeln('');
      buffer.writeln('💪 明日も頑張りましょう！');
    }

    return buffer.toString();
  }

  /// ウィークリーサマリーを送信
  Future<void> sendWeeklySummary({
    required int totalCompletedQuests,
    required int totalQuests,
    required int activeDays,
    required double weeklyAchievementRate,
    required List<String> topQuests,
  }) async {
    const title = '今週の振り返り';
    final body = _buildWeeklySummaryBody(
      totalCompletedQuests: totalCompletedQuests,
      totalQuests: totalQuests,
      activeDays: activeDays,
      weeklyAchievementRate: weeklyAchievementRate,
      topQuests: topQuests,
    );

    final androidDetails = AndroidNotificationDetails(
      NotificationChannelId.low,
      '低優先度の通知',
      importance: Importance.low,
      priority: Priority.low,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      998, // ウィークリーサマリー用の固定ID
      title,
      body,
      details,
    );
  }

  /// ウィークリーサマリー本文を構築
  String _buildWeeklySummaryBody({
    required int totalCompletedQuests,
    required int totalQuests,
    required int activeDays,
    required double weeklyAchievementRate,
    required List<String> topQuests,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('📊 今週の成果');
    buffer.writeln('');
    buffer.writeln('✅ 完了: $totalCompletedQuests/$totalQuests クエスト');
    buffer.writeln('📅 アクティブ: $activeDays/7 日');
    buffer.writeln('📈 達成率: ${weeklyAchievementRate.toStringAsFixed(1)}%');

    if (topQuests.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('🏆 よく達成したクエスト:');
      for (final quest in topQuests.take(3)) {
        buffer.writeln('  • $quest');
      }
    }

    if (weeklyAchievementRate >= 80) {
      buffer.writeln('');
      buffer.writeln('🎉 素晴らしい1週間でした！');
    } else if (weeklyAchievementRate >= 50) {
      buffer.writeln('');
      buffer.writeln('👍 良いペースです！来週も頑張りましょう！');
    }

    return buffer.toString();
  }
}

/// 通知バッジ管理サービス
class NotificationBadgeService {
  final FlutterLocalNotificationsPlugin _notifications;
  int _badgeCount = 0;

  NotificationBadgeService(this._notifications);

  /// バッジ数を取得
  int get badgeCount => _badgeCount;

  /// バッジ数を設定
  Future<void> setBadgeCount(int count) async {
    _badgeCount = count;
    // iOS用のバッジ更新
    // Android用のバッジはチャンネル設定で自動管理
  }

  /// バッジ数を増やす
  Future<void> incrementBadge() async {
    await setBadgeCount(_badgeCount + 1);
  }

  /// バッジ数を減らす
  Future<void> decrementBadge() async {
    if (_badgeCount > 0) {
      await setBadgeCount(_badgeCount - 1);
    }
  }

  /// バッジをクリア
  Future<void> clearBadge() async {
    await setBadgeCount(0);
  }
}

/// 通知スケジューラー
class NotificationScheduler {
  final FlutterLocalNotificationsPlugin _notifications;

  NotificationScheduler(this._notifications);

  /// スケジュール通知を設定
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required NotificationSchedule schedule,
    String? channelId,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId ?? NotificationChannelId.normal,
      '通常の通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    if (schedule.repeatInterval != null) {
      // 繰り返し通知
      await _notifications.periodicallyShow(
        id,
        title,
        body,
        _convertToRepeatInterval(schedule.repeatInterval!),
        details,
        payload: payload,
        androidScheduleMode:
            schedule.exactTiming
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      // 1回限りの通知
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        _convertToTZDateTime(schedule.scheduledTime),
        details,
        payload: payload,
        androidScheduleMode: schedule.exactTiming
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// RepeatIntervalに変換
  RepeatInterval _convertToRepeatInterval(Duration duration) {
    if (duration.inDays >= 7) {
      return RepeatInterval.weekly;
    } else if (duration.inDays >= 1) {
      return RepeatInterval.daily;
    } else if (duration.inHours >= 1) {
      return RepeatInterval.hourly;
    } else {
      return RepeatInterval.everyMinute;
    }
  }

  /// TZDateTimeに変換（timezone パッケージが必要）
  dynamic _convertToTZDateTime(DateTime dateTime) {
    // timezone パッケージを使用してTZDateTimeに変換
    // ここでは簡略化のためdynamicを返す
    return dateTime;
  }

  /// スケジュール通知をキャンセル
  Future<void> cancelScheduledNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// 全てのスケジュール通知をキャンセル
  Future<void> cancelAllScheduledNotifications() async {
    await _notifications.cancelAll();
  }

  /// 保留中の通知を取得
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
