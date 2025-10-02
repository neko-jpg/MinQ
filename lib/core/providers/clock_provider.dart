import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 時刻プロバイダー - テスト容易化のための抽象化
abstract class Clock {
  DateTime now();
  DateTime today();
}

/// 実際の時刻を返すClock実装
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

/// テスト用の固定時刻Clock実装
class FixedClock implements Clock {
  final DateTime fixedTime;

  const FixedClock(this.fixedTime);

  @override
  DateTime now() => fixedTime;

  @override
  DateTime today() {
    return DateTime(fixedTime.year, fixedTime.month, fixedTime.day);
  }
}

/// Clockプロバイダー
final clockProvider = Provider<Clock>((ref) {
  return const SystemClock();
});

/// 現在時刻を取得するプロバイダー
final nowProvider = Provider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return clock.now();
});

/// 今日の日付（時刻なし）を取得するプロバイダー
final todayProvider = Provider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  return clock.today();
});

/// 時刻ユーティリティ拡張
extension DateTimeExtension on DateTime {
  /// 日付のみを取得（時刻を00:00:00にリセット）
  DateTime get dateOnly {
    return DateTime(year, month, day);
  }

  /// 時刻のみを取得（日付を1970-01-01にリセット）
  DateTime get timeOnly {
    return DateTime(1970, 1, 1, hour, minute, second, millisecond, microsecond);
  }

  /// 同じ日かどうかを判定
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// 今日かどうかを判定
  bool isToday(Clock clock) {
    final now = clock.now();
    return isSameDay(now);
  }

  /// 昨日かどうかを判定
  bool isYesterday(Clock clock) {
    final now = clock.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return isSameDay(yesterday);
  }

  /// 明日かどうかを判定
  bool isTomorrow(Clock clock) {
    final now = clock.now();
    final tomorrow = now.add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }

  /// 過去かどうかを判定
  bool isPast(Clock clock) {
    return isBefore(clock.now());
  }

  /// 未来かどうかを判定
  bool isFuture(Clock clock) {
    return isAfter(clock.now());
  }

  /// 週の開始日（月曜日）を取得
  DateTime get startOfWeek {
    final weekday = this.weekday;
    return subtract(Duration(days: weekday - 1)).dateOnly;
  }

  /// 週の終了日（日曜日）を取得
  DateTime get endOfWeek {
    final weekday = this.weekday;
    return add(Duration(days: 7 - weekday)).dateOnly;
  }

  /// 月の開始日を取得
  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  /// 月の終了日を取得
  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0);
  }

  /// 年の開始日を取得
  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  /// 年の終了日を取得
  DateTime get endOfYear {
    return DateTime(year, 12, 31);
  }

  /// 日数の差を計算
  int daysDifference(DateTime other) {
    final a = dateOnly;
    final b = other.dateOnly;
    return a.difference(b).inDays;
  }

  /// 週数の差を計算
  int weeksDifference(DateTime other) {
    return (daysDifference(other) / 7).floor();
  }

  /// 月数の差を計算
  int monthsDifference(DateTime other) {
    return (year - other.year) * 12 + (month - other.month);
  }

  /// 年数の差を計算
  int yearsDifference(DateTime other) {
    return year - other.year;
  }

  /// 相対的な日付表現を取得
  String toRelativeString(Clock clock) {
    if (isToday(clock)) {
      return '今日';
    } else if (isYesterday(clock)) {
      return '昨日';
    } else if (isTomorrow(clock)) {
      return '明日';
    }

    final days = daysDifference(clock.now());
    if (days.abs() < 7) {
      return days > 0 ? '$days日後' : '${days.abs()}日前';
    }

    final weeks = weeksDifference(clock.now());
    if (weeks.abs() < 4) {
      return weeks > 0 ? '$weeks週間後' : '${weeks.abs()}週間前';
    }

    final months = monthsDifference(clock.now());
    if (months.abs() < 12) {
      return months > 0 ? '$monthsヶ月後' : '${months.abs()}ヶ月前';
    }

    final years = yearsDifference(clock.now());
    return years > 0 ? '$years年後' : '${years.abs()}年前';
  }

  /// 日本語の曜日を取得
  String get weekdayJa {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }

  /// 日本語の日付フォーマット
  String toJaFormat() {
    return '$year年$month月$day日';
  }

  /// 日本語の日時フォーマット
  String toJaDateTimeFormat() {
    return '$year年$month月$day日 $hour:${minute.toString().padLeft(2, '0')}';
  }
}

/// タイムゾーンユーティリティ
class TimeZoneUtils {
  const TimeZoneUtils._();

  /// UTCからローカル時刻に変換
  static DateTime toLocal(DateTime utc) {
    return utc.toLocal();
  }

  /// ローカル時刻からUTCに変換
  static DateTime toUtc(DateTime local) {
    return local.toUtc();
  }

  /// タイムゾーンオフセットを取得
  static Duration getOffset() {
    final now = DateTime.now();
    return now.timeZoneOffset;
  }

  /// タイムゾーン名を取得
  static String getTimeZoneName() {
    final now = DateTime.now();
    return now.timeZoneName;
  }
}

/// 日付範囲
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });

  /// 今日
  factory DateRange.today(Clock clock) {
    final today = clock.today();
    return DateRange(start: today, end: today);
  }

  /// 昨日
  factory DateRange.yesterday(Clock clock) {
    final yesterday = clock.today().subtract(const Duration(days: 1));
    return DateRange(start: yesterday, end: yesterday);
  }

  /// 今週
  factory DateRange.thisWeek(Clock clock) {
    final today = clock.today();
    return DateRange(
      start: today.startOfWeek,
      end: today.endOfWeek,
    );
  }

  /// 先週
  factory DateRange.lastWeek(Clock clock) {
    final today = clock.today();
    final lastWeek = today.subtract(const Duration(days: 7));
    return DateRange(
      start: lastWeek.startOfWeek,
      end: lastWeek.endOfWeek,
    );
  }

  /// 今月
  factory DateRange.thisMonth(Clock clock) {
    final today = clock.today();
    return DateRange(
      start: today.startOfMonth,
      end: today.endOfMonth,
    );
  }

  /// 先月
  factory DateRange.lastMonth(Clock clock) {
    final today = clock.today();
    final lastMonth = DateTime(today.year, today.month - 1, today.day);
    return DateRange(
      start: lastMonth.startOfMonth,
      end: lastMonth.endOfMonth,
    );
  }

  /// 今年
  factory DateRange.thisYear(Clock clock) {
    final today = clock.today();
    return DateRange(
      start: today.startOfYear,
      end: today.endOfYear,
    );
  }

  /// 過去N日間
  factory DateRange.lastNDays(Clock clock, int days) {
    final today = clock.today();
    return DateRange(
      start: today.subtract(Duration(days: days - 1)),
      end: today,
    );
  }

  /// 日数を取得
  int get days {
    return end.difference(start).inDays + 1;
  }

  /// 指定日が範囲内かどうかを判定
  bool contains(DateTime date) {
    final dateOnly = date.dateOnly;
    return (dateOnly.isAtSameMomentAs(start) || dateOnly.isAfter(start)) &&
        (dateOnly.isAtSameMomentAs(end) || dateOnly.isBefore(end));
  }

  /// 範囲内の全日付を取得
  List<DateTime> get allDates {
    final dates = <DateTime>[];
    var current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }
}
