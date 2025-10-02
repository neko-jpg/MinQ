import 'package:shared_preferences/shared_preferences.dart';

/// Do Not Disturbサービス
class DNDService {
  static const String _keyDNDEnabled = 'dnd_enabled';
  static const String _keyDNDStartTime = 'dnd_start_time';
  static const String _keyDNDEndTime = 'dnd_end_time';
  static const String _keyDNDDays = 'dnd_days';

  /// DNDが有効かどうか
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDNDEnabled) ?? false;
  }

  /// DNDを有効化
  Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDNDEnabled, true);
  }

  /// DNDを無効化
  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDNDEnabled, false);
  }

  /// DND時間帯を設定
  Future<void> setTimeRange({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDNDStartTime, _timeToString(startTime));
    await prefs.setString(_keyDNDEndTime, _timeToString(endTime));
  }

  /// DND時間帯を取得
  Future<DNDTimeRange?> getTimeRange() async {
    final prefs = await SharedPreferences.getInstance();
    final startStr = prefs.getString(_keyDNDStartTime);
    final endStr = prefs.getString(_keyDNDEndTime);

    if (startStr == null || endStr == null) return null;

    return DNDTimeRange(
      start: _stringToTime(startStr),
      end: _stringToTime(endStr),
    );
  }

  /// DND曜日を設定
  Future<void> setDays(List<int> days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyDNDDays, days.map((d) => d.toString()).toList());
  }

  /// DND曜日を取得
  Future<List<int>> getDays() async {
    final prefs = await SharedPreferences.getInstance();
    final daysStr = prefs.getStringList(_keyDNDDays);
    if (daysStr == null) return [];
    return daysStr.map((d) => int.parse(d)).toList();
  }

  /// 現在DNDモードかチェック
  Future<bool> isInDNDMode() async {
    if (!await isEnabled()) return false;

    final timeRange = await getTimeRange();
    if (timeRange == null) return false;

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    // 曜日チェック
    final days = await getDays();
    if (days.isNotEmpty && !days.contains(now.weekday)) {
      return false;
    }

    // 時間帯チェック
    return _isTimeInRange(currentTime, timeRange.start, timeRange.end);
  }

  /// 時刻を文字列に変換
  String _timeToString(TimeOfDay time) {
    return '${time.hour}:${time.minute}';
  }

  /// 文字列を時刻に変換
  TimeOfDay _stringToTime(String str) {
    final parts = str.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// 時刻が範囲内かチェック
  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    if (startMinutes <= endMinutes) {
      // 通常の範囲（例: 22:00 - 07:00）
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // 日をまたぐ範囲（例: 22:00 - 07:00）
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }
}

/// DND時間帯
class DNDTimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const DNDTimeRange({
    required this.start,
    required this.end,
  });

  @override
  String toString() {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

/// スヌーズサービス
class SnoozeService {
  static const String _keyPrefix = 'snooze_';

  /// 通知をスヌーズ
  Future<void> snooze({
    required String notificationId,
    required Duration duration,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntil = DateTime.now().add(duration);
    await prefs.setString(
      '$_keyPrefix$notificationId',
      snoozeUntil.toIso8601String(),
    );
  }

  /// スヌーズ中かチェック
  Future<bool> isSnoozed(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntilStr = prefs.getString('$_keyPrefix$notificationId');

    if (snoozeUntilStr == null) return false;

    final snoozeUntil = DateTime.parse(snoozeUntilStr);
    if (DateTime.now().isAfter(snoozeUntil)) {
      // スヌーズ期限切れ
      await prefs.remove('$_keyPrefix$notificationId');
      return false;
    }

    return true;
  }

  /// スヌーズをキャンセル
  Future<void> cancelSnooze(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$notificationId');
  }

  /// スヌーズ終了時刻を取得
  Future<DateTime?> getSnoozeUntil(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final snoozeUntilStr = prefs.getString('$_keyPrefix$notificationId');

    if (snoozeUntilStr == null) return null;

    return DateTime.parse(snoozeUntilStr);
  }

  /// 全てのスヌーズをクリア
  Future<void> clearAllSnoozes() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}

/// スヌーズ期間
enum SnoozeDuration {
  fiveMinutes,
  tenMinutes,
  fifteenMinutes,
  thirtyMinutes,
  oneHour,
  twoHours,
  fourHours,
  tomorrow,
}

extension SnoozeDurationExtension on SnoozeDuration {
  Duration get duration {
    switch (this) {
      case SnoozeDuration.fiveMinutes:
        return const Duration(minutes: 5);
      case SnoozeDuration.tenMinutes:
        return const Duration(minutes: 10);
      case SnoozeDuration.fifteenMinutes:
        return const Duration(minutes: 15);
      case SnoozeDuration.thirtyMinutes:
        return const Duration(minutes: 30);
      case SnoozeDuration.oneHour:
        return const Duration(hours: 1);
      case SnoozeDuration.twoHours:
        return const Duration(hours: 2);
      case SnoozeDuration.fourHours:
        return const Duration(hours: 4);
      case SnoozeDuration.tomorrow:
        // 翌日の同じ時刻まで
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1, now.hour, now.minute);
        return tomorrow.difference(now);
    }
  }

  String get displayName {
    switch (this) {
      case SnoozeDuration.fiveMinutes:
        return '5分後';
      case SnoozeDuration.tenMinutes:
        return '10分後';
      case SnoozeDuration.fifteenMinutes:
        return '15分後';
      case SnoozeDuration.thirtyMinutes:
        return '30分後';
      case SnoozeDuration.oneHour:
        return '1時間後';
      case SnoozeDuration.twoHours:
        return '2時間後';
      case SnoozeDuration.fourHours:
        return '4時間後';
      case SnoozeDuration.tomorrow:
        return '明日';
    }
  }
}

/// 通知スケジューラー（DND対応）
class DNDAwareNotificationScheduler {
  final DNDService _dndService;
  final SnoozeService _snoozeService;
  static const String _keyDeferredNotifications = 'deferred_notifications';

  DNDAwareNotificationScheduler({
    required DNDService dndService,
    required SnoozeService snoozeService,
  })  : _dndService = dndService,
        _snoozeService = snoozeService;

  /// 通知を送信すべきかチェック
  Future<bool> shouldSendNotification(String notificationId) async {
    // スヌーズ中かチェック
    if (await _snoozeService.isSnoozed(notificationId)) {
      return false;
    }

    // DNDモードかチェック
    if (await _dndService.isInDNDMode()) {
      return false;
    }

    return true;
  }

  /// 次の通知可能時刻を取得
  Future<DateTime> getNextAvailableTime() async {
    final now = DateTime.now();

    // DNDモードでない場合は即座に
    if (!await _dndService.isInDNDMode()) {
      return now;
    }

    // DND終了時刻を取得
    final timeRange = await _dndService.getTimeRange();
    if (timeRange == null) return now;

    final endTime = timeRange.end;
    final nextAvailable = DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    // 既に過ぎている場合は翌日
    if (nextAvailable.isBefore(now)) {
      return nextAvailable.add(const Duration(days: 1));
    }

    return nextAvailable;
  }

  /// DND中の通知を延期
  Future<void> deferNotification({
    required String notificationId,
    required Map<String, dynamic> notificationData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final deferredList = prefs.getStringList(_keyDeferredNotifications) ?? [];
    
    final deferredItem = {
      'id': notificationId,
      'data': notificationData,
      'deferredAt': DateTime.now().toIso8601String(),
    };
    
    deferredList.add(_encodeMap(deferredItem));
    await prefs.setStringList(_keyDeferredNotifications, deferredList);
  }

  /// 延期された通知を取得
  Future<List<Map<String, dynamic>>> getDeferredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final deferredList = prefs.getStringList(_keyDeferredNotifications) ?? [];
    
    return deferredList.map((item) => _decodeMap(item)).toList();
  }

  /// 延期された通知をクリア
  Future<void> clearDeferredNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeferredNotifications);
  }

  /// DND終了後に延期された通知を送信
  Future<void> sendDeferredNotifications() async {
    if (await _dndService.isInDNDMode()) {
      return; // まだDND中
    }

    final deferred = await getDeferredNotifications();
    if (deferred.isEmpty) return;

    // 延期された通知を処理（実際の通知送信は呼び出し側で実装）
    await clearDeferredNotifications();
  }

  /// 通知を延期すべきかチェックして処理
  Future<NotificationAction> processNotification({
    required String notificationId,
    required Map<String, dynamic> notificationData,
  }) async {
    // スヌーズ中
    if (await _snoozeService.isSnoozed(notificationId)) {
      return NotificationAction.skip;
    }

    // DNDモード中
    if (await _dndService.isInDNDMode()) {
      await deferNotification(
        notificationId: notificationId,
        notificationData: notificationData,
      );
      return NotificationAction.defer;
    }

    return NotificationAction.send;
  }

  String _encodeMap(Map<String, dynamic> map) {
    return map.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, dynamic> _decodeMap(String encoded) {
    final map = <String, dynamic>{};
    for (final pair in encoded.split('&')) {
      final parts = pair.split('=');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}

/// 通知アクション
enum NotificationAction {
  send,   // 送信
  skip,   // スキップ（スヌーズ中）
  defer,  // 延期（DND中）
}

/// DND設定プリセット
class DNDPresets {
  const DNDPresets._();

  /// 夜間（22:00 - 07:00）
  static const night = DNDTimeRange(
    start: TimeOfDay(hour: 22, minute: 0),
    end: TimeOfDay(hour: 7, minute: 0),
  );

  /// 就寝時間（23:00 - 08:00）
  static const sleep = DNDTimeRange(
    start: TimeOfDay(hour: 23, minute: 0),
    end: TimeOfDay(hour: 8, minute: 0),
  );

  /// 勤務時間（09:00 - 18:00）
  static const work = DNDTimeRange(
    start: TimeOfDay(hour: 9, minute: 0),
    end: TimeOfDay(hour: 18, minute: 0),
  );

  /// 昼休み（12:00 - 13:00）
  static const lunch = DNDTimeRange(
    start: TimeOfDay(hour: 12, minute: 0),
    end: TimeOfDay(hour: 13, minute: 0),
  );
}

/// DND統計
class DNDStats {
  int _blockedNotifications = 0;
  int _snoozedNotifications = 0;
  final Map<int, int> _blockedByHour = {};

  /// ブロックされた通知数
  int get blockedNotifications => _blockedNotifications;

  /// スヌーズされた通知数
  int get snoozedNotifications => _snoozedNotifications;

  /// 通知ブロックを記録
  void recordBlocked({int? hour}) {
    _blockedNotifications++;
    if (hour != null) {
      _blockedByHour[hour] = (_blockedByHour[hour] ?? 0) + 1;
    }
  }

  /// スヌーズを記録
  void recordSnoozed() {
    _snoozedNotifications++;
  }

  /// 時間帯別のブロック数
  int getBlockedByHour(int hour) {
    return _blockedByHour[hour] ?? 0;
  }

  /// 統計をリセット
  void reset() {
    _blockedNotifications = 0;
    _snoozedNotifications = 0;
    _blockedByHour.clear();
  }

  /// 統計を取得
  Map<String, dynamic> getStats() {
    return {
      'blockedNotifications': _blockedNotifications,
      'snoozedNotifications': _snoozedNotifications,
      'blockedByHour': Map.unmodifiable(_blockedByHour),
    };
  }
}

/// TimeOfDay拡張
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({
    required this.hour,
    required this.minute,
  });

  @override
  String toString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}
