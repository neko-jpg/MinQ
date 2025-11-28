import 'package:intl/intl.dart';
import 'package:minq/core/providers/clock_provider.dart';

/// 時刻表現の一貫性を保つフォーマッター
class TimeFormatter {
  final Clock clock;

  TimeFormatter({Clock? clock}) : clock = clock ?? Clock();

  /// 相対時刻表現（例: 3分前、2時間前）
  String relative(DateTime dateTime, {String? locale}) {
    final now = clock.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return _formatFuture(difference.abs(), locale: locale);
    }

    return _formatPast(difference, locale: locale);
  }

  /// 過去の相対時刻
  String _formatPast(Duration difference, {String? locale}) {
    if (difference.inSeconds < 60) {
      return 'たった今';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日前';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks週間前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$monthsヶ月前';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years年前';
    }
  }

  /// 未来の相対時刻
  String _formatFuture(Duration difference, {String? locale}) {
    if (difference.inSeconds < 60) {
      return 'まもなく';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分後';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間後';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}日後';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks週間後';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$monthsヶ月後';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years年後';
    }
  }

  /// 絶対時刻表現（例: 2024年1月1日 12:00）
  String absolute(DateTime dateTime, {TimeFormat format = TimeFormat.full}) {
    switch (format) {
      case TimeFormat.full:
        return DateFormat('yyyy年M月d日 HH:mm').format(dateTime);
      case TimeFormat.date:
        return DateFormat('yyyy年M月d日').format(dateTime);
      case TimeFormat.time:
        return DateFormat('HH:mm').format(dateTime);
      case TimeFormat.dateTime:
        return DateFormat('M月d日 HH:mm').format(dateTime);
      case TimeFormat.short:
        return DateFormat('M/d HH:mm').format(dateTime);
    }
  }

  /// スマート表現（今日なら時刻、昨日なら「昨日」、それ以前なら日付）
  String smart(DateTime dateTime) {
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) {
      // 今日
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference == 1) {
      // 昨日
      return '昨日 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference == -1) {
      // 明日
      return '明日 ${DateFormat('HH:mm').format(dateTime)}';
    } else if (difference < 7 && difference > 0) {
      // 1週間以内
      return '$difference日前';
    } else if (difference > -7 && difference < 0) {
      // 1週間以内（未来）
      return '${difference.abs()}日後';
    } else if (dateTime.year == now.year) {
      // 今年
      return DateFormat('M月d日').format(dateTime);
    } else {
      // それ以前
      return DateFormat('yyyy年M月d日').format(dateTime);
    }
  }

  /// 期間表現（例: 3日間、2時間30分）
  String duration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}日間';
    } else if (duration.inHours > 0) {
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '${duration.inHours}時間$minutes分';
      }
      return '${duration.inHours}時間';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}分';
    } else {
      return '${duration.inSeconds}秒';
    }
  }

  /// タイムスタンプ（Unix時間）
  int timestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// タイムスタンプから日時へ
  DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }
}

/// 時刻フォーマット
enum TimeFormat {
  full, // 2024年1月1日 12:00
  date, // 2024年1月1日
  time, // 12:00
  dateTime, // 1月1日 12:00
  short, // 1/1 12:00
}

/// 時刻表現ポリシー
class TimeDisplayPolicy {
  /// 通知での時刻表現
  static String forNotification(DateTime dateTime, Clock clock) {
    final formatter = TimeFormatter(clock: clock);
    return formatter.smart(dateTime);
  }

  /// リストでの時刻表現
  static String forList(DateTime dateTime, Clock clock) {
    final formatter = TimeFormatter(clock: clock);
    return formatter.smart(dateTime);
  }

  /// 詳細画面での時刻表現
  static String forDetail(DateTime dateTime, Clock clock) {
    final formatter = TimeFormatter(clock: clock);
    return formatter.absolute(dateTime, format: TimeFormat.full);
  }

  /// チャットでの時刻表現
  static String forChat(DateTime dateTime, Clock clock) {
    final formatter = TimeFormatter(clock: clock);
    final now = clock.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'たった今';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分前';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(dateTime);
    } else {
      return formatter.smart(dateTime);
    }
  }

  /// 統計での時刻表現
  static String forStats(DateTime dateTime, Clock clock) {
    final formatter = TimeFormatter(clock: clock);
    return formatter.absolute(dateTime, format: TimeFormat.date);
  }
}
