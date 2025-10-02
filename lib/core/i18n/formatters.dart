import 'package:intl/intl.dart';

/// 多言語フォーマッター
class LocalizedFormatters {
  final String locale;

  LocalizedFormatters(this.locale);

  /// 日時をフォーマット
  String formatDateTime(DateTime dateTime, {DateTimeFormat format = DateTimeFormat.medium}) {
    switch (format) {
      case DateTimeFormat.short:
        return DateFormat.yMd(locale).format(dateTime);
      case DateTimeFormat.medium:
        return DateFormat.yMMMd(locale).format(dateTime);
      case DateTimeFormat.long:
        return DateFormat.yMMMMd(locale).format(dateTime);
      case DateTimeFormat.full:
        return DateFormat.yMMMMEEEEd(locale).format(dateTime);
    }
  }

  /// 時刻をフォーマット
  String formatTime(DateTime dateTime) {
    return DateFormat.Hm(locale).format(dateTime);
  }

  /// 数値をフォーマット
  String formatNumber(num number, {int? decimalDigits}) {
    final formatter = NumberFormat.decimalPattern(locale);
    if (decimalDigits != null) {
      formatter.minimumFractionDigits = decimalDigits;
      formatter.maximumFractionDigits = decimalDigits;
    }
    return formatter.format(number);
  }

  /// パーセンテージをフォーマット
  String formatPercentage(double value, {int decimalDigits = 1}) {
    final formatter = NumberFormat.percentPattern(locale);
    formatter.minimumFractionDigits = decimalDigits;
    formatter.maximumFractionDigits = decimalDigits;
    return formatter.format(value);
  }

  /// 通貨をフォーマット
  String formatCurrency(num amount, {String? currencySymbol}) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: currencySymbol ?? _getCurrencySymbol(),
    );
    return formatter.format(amount);
  }

  /// 相対時間をフォーマット
  String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return _localize('just_now');
    } else if (difference.inMinutes < 60) {
      return _localize('minutes_ago', {'count': difference.inMinutes});
    } else if (difference.inHours < 24) {
      return _localize('hours_ago', {'count': difference.inHours});
    } else if (difference.inDays < 7) {
      return _localize('days_ago', {'count': difference.inDays});
    } else if (difference.inDays < 30) {
      return _localize('weeks_ago', {'count': (difference.inDays / 7).floor()});
    } else if (difference.inDays < 365) {
      return _localize('months_ago', {'count': (difference.inDays / 30).floor()});
    } else {
      return _localize('years_ago', {'count': (difference.inDays / 365).floor()});
    }
  }

  /// 期間をフォーマット
  String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return _localize('days', {'count': duration.inDays});
    } else if (duration.inHours > 0) {
      return _localize('hours', {'count': duration.inHours});
    } else if (duration.inMinutes > 0) {
      return _localize('minutes', {'count': duration.inMinutes});
    } else {
      return _localize('seconds', {'count': duration.inSeconds});
    }
  }

  /// 通貨シンボルを取得
  String _getCurrencySymbol() {
    if (locale.startsWith('ja')) return '¥';
    if (locale.startsWith('en_US')) return '\$';
    if (locale.startsWith('en_GB')) return '£';
    if (locale.startsWith('eu')) return '€';
    return '\$';
  }

  /// ローカライズ
  String _localize(String key, [Map<String, dynamic>? params]) {
    // TODO: 実際のローカライゼーションロジックを実装
    return key;
  }
}

/// 日時フォーマット
enum DateTimeFormat {
  short,
  medium,
  long,
  full,
}

/// 日本語固有の整形
class JapaneseFormatters {
  /// 全角/半角変換
  static String toFullWidth(String text) {
    return text.replaceAllMapped(
      RegExp(r'[A-Za-z0-9]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) + 0xFEE0),
    );
  }

  static String toHalfWidth(String text) {
    return text.replaceAllMapped(
      RegExp(r'[Ａ-Ｚａ-ｚ０-９]'),
      (match) => String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0xFEE0),
    );
  }

  /// 長音記号の正規化
  static String normalizeLongVowel(String text) {
    return text
        .replaceAll('ー', 'ー')
        .replaceAll('～', '〜');
  }

  /// 曜日を日本語で取得
  static String getWeekdayJa(int weekday) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return weekdays[weekday - 1];
  }

  /// 和暦変換
  static String toJapaneseEra(DateTime date) {
    if (date.year >= 2019) {
      return '令和${date.year - 2018}年';
    } else if (date.year >= 1989) {
      return '平成${date.year - 1988}年';
    } else if (date.year >= 1926) {
      return '昭和${date.year - 1925}年';
    }
    return '${date.year}年';
  }
}

/// 単位フォーマッター
class UnitFormatters {
  final String locale;

  UnitFormatters(this.locale);

  /// 距離をフォーマット
  String formatDistance(double meters) {
    if (locale.startsWith('en_US')) {
      // マイル
      final miles = meters / 1609.34;
      return '${miles.toStringAsFixed(2)} mi';
    } else {
      // キロメートル
      if (meters >= 1000) {
        return '${(meters / 1000).toStringAsFixed(2)} km';
      } else {
        return '${meters.toStringAsFixed(0)} m';
      }
    }
  }

  /// 重量をフォーマット
  String formatWeight(double grams) {
    if (locale.startsWith('en_US')) {
      // ポンド
      final pounds = grams / 453.592;
      return '${pounds.toStringAsFixed(2)} lb';
    } else {
      // キログラム
      if (grams >= 1000) {
        return '${(grams / 1000).toStringAsFixed(2)} kg';
      } else {
        return '${grams.toStringAsFixed(0)} g';
      }
    }
  }

  /// 温度をフォーマット
  String formatTemperature(double celsius) {
    if (locale.startsWith('en_US')) {
      // 華氏
      final fahrenheit = celsius * 9 / 5 + 32;
      return '${fahrenheit.toStringAsFixed(1)}°F';
    } else {
      // 摂氏
      return '${celsius.toStringAsFixed(1)}°C';
    }
  }
}
