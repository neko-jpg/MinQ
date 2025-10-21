import 'package:flutter/foundation.dart';

/// 通知スケジュールカスタマイザー
/// 曜日や祝日に基づいて通知をカスタマイズ
class NotificationScheduleCustomizer {
  /// 通知を送信すべき曜日（0=日曜, 6=土曜）
  final Set<int> enabledWeekdays;

  /// 祝日に通知を送信するか
  final bool notifyOnHolidays;

  /// 休日に通知を送信するか（土日）
  final bool notifyOnWeekends;

  const NotificationScheduleCustomizer({
    this.enabledWeekdays = const {1, 2, 3, 4, 5}, // 平日デフォルト
    this.notifyOnHolidays = false,
    this.notifyOnWeekends = false,
  });

  /// デフォルト設定（平日のみ）
  static const defaultSettings = NotificationScheduleCustomizer();

  /// 毎日通知
  static const everyday = NotificationScheduleCustomizer(
    enabledWeekdays: {0, 1, 2, 3, 4, 5, 6},
    notifyOnHolidays: true,
    notifyOnWeekends: true,
  );

  /// 平日のみ
  static const weekdaysOnly = NotificationScheduleCustomizer(
    enabledWeekdays: {1, 2, 3, 4, 5},
    notifyOnHolidays: false,
    notifyOnWeekends: false,
  );

  /// 週末のみ
  static const weekendsOnly = NotificationScheduleCustomizer(
    enabledWeekdays: {0, 6},
    notifyOnHolidays: false,
    notifyOnWeekends: true,
  );

  /// 指定された日時に通知を送信すべきか判定
  bool shouldNotify(DateTime dateTime, {bool isHoliday = false}) {
    // 祝日チェック
    if (isHoliday && !notifyOnHolidays) {
      return false;
    }

    // 週末チェック
    final isWeekend =
        dateTime.weekday == DateTime.saturday ||
        dateTime.weekday == DateTime.sunday;
    if (isWeekend && !notifyOnWeekends) {
      return false;
    }

    // 曜日チェック
    return enabledWeekdays.contains(dateTime.weekday % 7);
  }

  /// 次の通知可能な日時を取得
  DateTime? getNextNotificationTime(
    DateTime from,
    List<String> notificationTimes, {
    required bool Function(DateTime) isHoliday,
  }) {
    var candidate = from;

    // 最大30日先まで検索
    for (var i = 0; i < 30; i++) {
      for (final timeStr in notificationTimes) {
        final parts = timeStr.split(':');
        if (parts.length != 2) continue;

        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour == null || minute == null) continue;

        final notificationTime = DateTime(
          candidate.year,
          candidate.month,
          candidate.day,
          hour,
          minute,
        );

        if (notificationTime.isAfter(from) &&
            shouldNotify(
              notificationTime,
              isHoliday: isHoliday(notificationTime),
            )) {
          return notificationTime;
        }
      }

      candidate = candidate.add(const Duration(days: 1));
    }

    return null;
  }

  /// JSON形式に変換
  Map<String, dynamic> toJson() {
    return {
      'enabledWeekdays': enabledWeekdays.toList(),
      'notifyOnHolidays': notifyOnHolidays,
      'notifyOnWeekends': notifyOnWeekends,
    };
  }

  /// JSON形式から復元
  factory NotificationScheduleCustomizer.fromJson(Map<String, dynamic> json) {
    return NotificationScheduleCustomizer(
      enabledWeekdays:
          (json['enabledWeekdays'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          const {1, 2, 3, 4, 5},
      notifyOnHolidays: json['notifyOnHolidays'] as bool? ?? false,
      notifyOnWeekends: json['notifyOnWeekends'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationScheduleCustomizer &&
        setEquals(other.enabledWeekdays, enabledWeekdays) &&
        other.notifyOnHolidays == notifyOnHolidays &&
        other.notifyOnWeekends == notifyOnWeekends;
  }

  @override
  int get hashCode =>
      Object.hash(enabledWeekdays, notifyOnHolidays, notifyOnWeekends);

  NotificationScheduleCustomizer copyWith({
    Set<int>? enabledWeekdays,
    bool? notifyOnHolidays,
    bool? notifyOnWeekends,
  }) {
    return NotificationScheduleCustomizer(
      enabledWeekdays: enabledWeekdays ?? this.enabledWeekdays,
      notifyOnHolidays: notifyOnHolidays ?? this.notifyOnHolidays,
      notifyOnWeekends: notifyOnWeekends ?? this.notifyOnWeekends,
    );
  }
}

/// 日本の祝日判定サービス（簡易版）
class JapaneseHolidayService {
  /// 2025年の祝日リスト（例）
  static final Map<DateTime, String> _holidays2025 = {
    DateTime(2025, 1, 1): '元日',
    DateTime(2025, 1, 13): '成人の日',
    DateTime(2025, 2, 11): '建国記念の日',
    DateTime(2025, 2, 23): '天皇誕生日',
    DateTime(2025, 3, 20): '春分の日',
    DateTime(2025, 4, 29): '昭和の日',
    DateTime(2025, 5, 3): '憲法記念日',
    DateTime(2025, 5, 4): 'みどりの日',
    DateTime(2025, 5, 5): 'こどもの日',
    DateTime(2025, 7, 21): '海の日',
    DateTime(2025, 8, 11): '山の日',
    DateTime(2025, 9, 15): '敬老の日',
    DateTime(2025, 9, 23): '秋分の日',
    DateTime(2025, 10, 13): 'スポーツの日',
    DateTime(2025, 11, 3): '文化の日',
    DateTime(2025, 11, 23): '勤労感謝の日',
  };

  /// 指定された日付が祝日かどうか判定
  static bool isHoliday(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _holidays2025.containsKey(normalized);
  }

  /// 祝日名を取得
  static String? getHolidayName(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _holidays2025[normalized];
  }

  /// 指定された期間の祝日リストを取得
  static List<DateTime> getHolidaysInRange(DateTime start, DateTime end) {
    return _holidays2025.keys
        .where((date) => date.isAfter(start) && date.isBefore(end))
        .toList()
      ..sort();
  }
}
