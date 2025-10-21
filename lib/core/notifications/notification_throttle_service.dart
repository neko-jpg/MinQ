import 'dart:async';

import 'package:minq/core/logging/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知スロットリングサービス - 連続通知を抑制
class NotificationThrottleService {
  static const String _keyLastNotificationTime = 'last_notification_time_';
  static const String _keyNotificationCount = 'notification_count_';
  static const String _keyBatchedNotifications = 'batched_notifications';

  // デバウンス設定: 同じ種類の通知は最低この間隔を空ける
  static const Duration _debounceInterval = Duration(seconds: 30);
  
  // バッチ設定: この時間内の通知をまとめる
  static const Duration _batchWindow = Duration(minutes: 5);
  
  // レート制限: この時間内に送信できる最大通知数
  static const Duration _rateLimitWindow = Duration(minutes: 10);
  static const int _maxNotificationsPerWindow = 5;

  final Map<String, Timer> _debounceTimers = {};
  final Map<String, List<Map<String, dynamic>>> _batchedNotifications = {};

  /// デバウンス: 連続した同じ通知を抑制
  Future<bool> shouldDebounce(String notificationType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyLastNotificationTime$notificationType';
    final lastTimeStr = prefs.getString(key);

    if (lastTimeStr == null) {
      await _recordNotificationTime(notificationType);
      return false;
    }

    final lastTime = DateTime.parse(lastTimeStr);
    final now = DateTime.now();
    final elapsed = now.difference(lastTime);

    if (elapsed < _debounceInterval) {
      AppLogger.info('Notification debounced', data: {
        'type': notificationType,
        'elapsed': elapsed.inSeconds,
      });
      return true; // デバウンス中
    }

    await _recordNotificationTime(notificationType);
    return false;
  }

  /// レート制限: 一定時間内の通知数を制限
  Future<bool> isRateLimited(String notificationType) async {
    final prefs = await SharedPreferences.getInstance();
    final countKey = '$_keyNotificationCount$notificationType';
    final timeKey = '$_keyLastNotificationTime$notificationType';

    final count = prefs.getInt(countKey) ?? 0;
    final lastTimeStr = prefs.getString(timeKey);

    if (lastTimeStr == null) {
      await _recordNotification(notificationType);
      return false;
    }

    final lastTime = DateTime.parse(lastTimeStr);
    final now = DateTime.now();
    final elapsed = now.difference(lastTime);

    // ウィンドウをリセット
    if (elapsed > _rateLimitWindow) {
      await _resetNotificationCount(notificationType);
      await _recordNotification(notificationType);
      return false;
    }

    // レート制限チェック
    if (count >= _maxNotificationsPerWindow) {
      AppLogger.warning('Notification rate limited', data: {
        'type': notificationType,
        'count': count,
        'window': _rateLimitWindow.inMinutes,
      });
      return true;
    }

    await _recordNotification(notificationType);
    return false;
  }

  /// バッチ処理: 複数の通知をまとめて送信
  Future<void> addToBatch({
    required String batchKey,
    required Map<String, dynamic> notificationData,
  }) async {
    if (!_batchedNotifications.containsKey(batchKey)) {
      _batchedNotifications[batchKey] = [];
      
      // バッチウィンドウ後に送信
      Timer(_batchWindow, () async {
        await _sendBatchedNotifications(batchKey);
      });
    }

    _batchedNotifications[batchKey]!.add(notificationData);
    
    AppLogger.info('Notification added to batch', data: {
      'batchKey': batchKey,
      'count': _batchedNotifications[batchKey]!.length,
    });
  }

  /// バッチ通知を取得
  List<Map<String, dynamic>>? getBatchedNotifications(String batchKey) {
    return _batchedNotifications[batchKey];
  }

  /// バッチ通知を送信
  Future<void> _sendBatchedNotifications(String batchKey) async {
    final notifications = _batchedNotifications[batchKey];
    if (notifications == null || notifications.isEmpty) return;

    AppLogger.info('Sending batched notifications', data: {
      'batchKey': batchKey,
      'count': notifications.length,
    });

    // バッチをクリア
    _batchedNotifications.remove(batchKey);
    
    // 実際の通知送信は呼び出し側で実装
    // ここでは通知データを返すだけ
  }

  /// デバウンスタイマーをキャンセル
  void cancelDebounce(String notificationType) {
    _debounceTimers[notificationType]?.cancel();
    _debounceTimers.remove(notificationType);
  }

  /// 全てのデバウンスタイマーをキャンセル
  void cancelAllDebounces() {
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();
  }

  /// 通知時刻を記録
  Future<void> _recordNotificationTime(String notificationType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyLastNotificationTime$notificationType';
    await prefs.setString(key, DateTime.now().toIso8601String());
  }

  /// 通知を記録
  Future<void> _recordNotification(String notificationType) async {
    final prefs = await SharedPreferences.getInstance();
    final countKey = '$_keyNotificationCount$notificationType';
    final timeKey = '$_keyLastNotificationTime$notificationType';
    
    final count = prefs.getInt(countKey) ?? 0;
    await prefs.setInt(countKey, count + 1);
    await prefs.setString(timeKey, DateTime.now().toIso8601String());
  }

  /// 通知カウントをリセット
  Future<void> _resetNotificationCount(String notificationType) async {
    final prefs = await SharedPreferences.getInstance();
    final countKey = '$_keyNotificationCount$notificationType';
    await prefs.setInt(countKey, 0);
  }

  /// 統計をクリア
  Future<void> clearStats() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(_keyLastNotificationTime) ||
          key.startsWith(_keyNotificationCount)) {
        await prefs.remove(key);
      }
    }
  }

  /// 通知を送信すべきかチェック（デバウンス + レート制限）
  Future<NotificationThrottleResult> shouldSendNotification({
    required String notificationType,
    bool enableDebounce = true,
    bool enableRateLimit = true,
  }) async {
    // デバウンスチェック
    if (enableDebounce && await shouldDebounce(notificationType)) {
      return NotificationThrottleResult.debounced;
    }

    // レート制限チェック
    if (enableRateLimit && await isRateLimited(notificationType)) {
      return NotificationThrottleResult.rateLimited;
    }

    return NotificationThrottleResult.allowed;
  }

  /// クリーンアップ
  void dispose() {
    cancelAllDebounces();
    _batchedNotifications.clear();
  }
}

/// 通知スロットリング結果
enum NotificationThrottleResult {
  allowed,      // 送信可能
  debounced,    // デバウンスにより抑制
  rateLimited,  // レート制限により抑制
}

/// 通知バッチャー - 複数の通知をまとめて表示
class NotificationBatcher {
  final NotificationThrottleService _throttleService;
  
  NotificationBatcher(this._throttleService);

  /// クエスト完了通知をバッチ処理
  Future<void> batchQuestCompletion({
    required String questId,
    required String questTitle,
  }) async {
    await _throttleService.addToBatch(
      batchKey: 'quest_completions',
      notificationData: {
        'questId': questId,
        'questTitle': questTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// ペア通知をバッチ処理
  Future<void> batchPairActivity({
    required String pairId,
    required String activityType,
    required String message,
  }) async {
    await _throttleService.addToBatch(
      batchKey: 'pair_activities',
      notificationData: {
        'pairId': pairId,
        'activityType': activityType,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// リマインダーをバッチ処理
  Future<void> batchReminder({
    required String questId,
    required String questTitle,
  }) async {
    await _throttleService.addToBatch(
      batchKey: 'reminders',
      notificationData: {
        'questId': questId,
        'questTitle': questTitle,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// バッチ通知のサマリーを生成
  String generateBatchSummary(String batchKey) {
    final notifications = _throttleService.getBatchedNotifications(batchKey);
    if (notifications == null || notifications.isEmpty) {
      return '';
    }

    final count = notifications.length;
    
    switch (batchKey) {
      case 'quest_completions':
        return '$count個のクエストが完了しました';
      case 'pair_activities':
        return 'ペアから$count件の通知があります';
      case 'reminders':
        return '$count件のリマインダーがあります';
      default:
        return '$count件の通知があります';
    }
  }
}

/// 通知優先度管理
class NotificationPriorityManager {
  /// 通知の優先度を判定
  NotificationPriority getPriority(String notificationType) {
    switch (notificationType) {
      case 'quest_deadline':
      case 'streak_break_warning':
        return NotificationPriority.high;
      
      case 'quest_reminder':
      case 'pair_message':
        return NotificationPriority.medium;
      
      case 'achievement_unlocked':
      case 'weekly_summary':
        return NotificationPriority.low;
      
      default:
        return NotificationPriority.medium;
    }
  }

  /// 優先度に基づいてスロットリング設定を調整
  bool shouldApplyThrottle(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return false; // 高優先度はスロットリングしない
      case NotificationPriority.medium:
      case NotificationPriority.low:
        return true;
    }
  }
}

/// 通知優先度
enum NotificationPriority {
  high,
  medium,
  low,
}
