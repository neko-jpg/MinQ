import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// カレンダーエクスポートサービス
class CalendarExportService {
  /// クエストをICSファイルとしてエクスポート
  Future<File> exportQuestToICS({
    required String questTitle,
    required DateTime scheduledTime,
    String? description,
    String? location,
    Duration? duration,
    bool isRecurring = false,
    RecurrenceRule? recurrenceRule,
  }) async {
    final icsContent = _generateICS(
      title: questTitle,
      startTime: scheduledTime,
      description: description,
      location: location,
      duration: duration ?? const Duration(hours: 1),
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
    );

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/quest_${DateTime.now().millisecondsSinceEpoch}.ics');
    await file.writeAsString(icsContent);

    return file;
  }

  /// 複数のクエストをICSファイルとしてエクスポート
  Future<File> exportQuestsToICS({
    required List<QuestSchedule> quests,
  }) async {
    final buffer = StringBuffer();

    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//MiniQuest//Quest Calendar//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');
    buffer.writeln('X-WR-CALNAME:MiniQuest');
    buffer.writeln('X-WR-TIMEZONE:Asia/Tokyo');

    for (final quest in quests) {
      buffer.write(_generateEvent(
        title: quest.title,
        startTime: quest.scheduledTime,
        description: quest.description,
        location: quest.location,
        duration: quest.duration,
        isRecurring: quest.isRecurring,
        recurrenceRule: quest.recurrenceRule,
      ));
    }

    buffer.writeln('END:VCALENDAR');

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/quests_${DateTime.now().millisecondsSinceEpoch}.ics');
    await file.writeAsString(buffer.toString());

    return file;
  }

  /// ICSコンテンツを生成
  String _generateICS({
    required String title,
    required DateTime startTime,
    String? description,
    String? location,
    required Duration duration,
    bool isRecurring = false,
    RecurrenceRule? recurrenceRule,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('BEGIN:VCALENDAR');
    buffer.writeln('VERSION:2.0');
    buffer.writeln('PRODID:-//MiniQuest//Quest Calendar//EN');
    buffer.writeln('CALSCALE:GREGORIAN');
    buffer.writeln('METHOD:PUBLISH');

    buffer.write(_generateEvent(
      title: title,
      startTime: startTime,
      description: description,
      location: location,
      duration: duration,
      isRecurring: isRecurring,
      recurrenceRule: recurrenceRule,
    ));

    buffer.writeln('END:VCALENDAR');

    return buffer.toString();
  }

  /// イベントを生成
  String _generateEvent({
    required String title,
    required DateTime startTime,
    String? description,
    String? location,
    required Duration duration,
    bool isRecurring = false,
    RecurrenceRule? recurrenceRule,
  }) {
    final buffer = StringBuffer();
    final endTime = startTime.add(duration);
    final uid = 'quest-${DateTime.now().millisecondsSinceEpoch}@miniquest.app';

    buffer.writeln('BEGIN:VEVENT');
    buffer.writeln('UID:$uid');
    buffer.writeln('DTSTAMP:${_formatDateTime(DateTime.now())}');
    buffer.writeln('DTSTART:${_formatDateTime(startTime)}');
    buffer.writeln('DTEND:${_formatDateTime(endTime)}');
    buffer.writeln('SUMMARY:$title');

    if (description != null && description.isNotEmpty) {
      buffer.writeln('DESCRIPTION:${_escapeText(description)}');
    }

    if (location != null && location.isNotEmpty) {
      buffer.writeln('LOCATION:${_escapeText(location)}');
    }

    if (isRecurring && recurrenceRule != null) {
      buffer.writeln('RRULE:${recurrenceRule.toICSFormat()}');
    }

    buffer.writeln('STATUS:CONFIRMED');
    buffer.writeln('SEQUENCE:0');
    buffer.writeln('BEGIN:VALARM');
    buffer.writeln('TRIGGER:-PT15M');
    buffer.writeln('ACTION:DISPLAY');
    buffer.writeln('DESCRIPTION:Reminder');
    buffer.writeln('END:VALARM');
    buffer.writeln('END:VEVENT');

    return buffer.toString();
  }

  /// 日時をICS形式にフォーマット
  String _formatDateTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return '${utc.year}${_pad(utc.month)}${_pad(utc.day)}T${_pad(utc.hour)}${_pad(utc.minute)}${_pad(utc.second)}Z';
  }

  /// 数値を2桁にパディング
  String _pad(int value) {
    return value.toString().padLeft(2, '0');
  }

  /// テキストをエスケープ
  String _escapeText(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll(',', '\\,')
        .replaceAll(';', '\\;')
        .replaceAll('\n', '\\n');
  }

  /// ICSファイルを共有
  Future<void> shareICS(File icsFile) async {
    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(icsFile.path)],
      subject: 'MiniQuest カレンダー',
    );
  }
}

/// クエストスケジュール
class QuestSchedule {
  final String title;
  final DateTime scheduledTime;
  final String? description;
  final String? location;
  final Duration duration;
  final bool isRecurring;
  final RecurrenceRule? recurrenceRule;

  const QuestSchedule({
    required this.title,
    required this.scheduledTime,
    this.description,
    this.location,
    this.duration = const Duration(hours: 1),
    this.isRecurring = false,
    this.recurrenceRule,
  });
}

/// 繰り返しルール
class RecurrenceRule {
  final RecurrenceFrequency frequency;
  final int interval;
  final int? count;
  final DateTime? until;
  final List<int>? byDay;
  final List<int>? byMonthDay;
  final List<int>? byMonth;

  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.count,
    this.until,
    this.byDay,
    this.byMonthDay,
    this.byMonth,
  });

  /// 毎日
  factory RecurrenceRule.daily({int interval = 1, int? count, DateTime? until}) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.daily,
      interval: interval,
      count: count,
      until: until,
    );
  }

  /// 毎週
  factory RecurrenceRule.weekly({
    int interval = 1,
    List<int>? byDay,
    int? count,
    DateTime? until,
  }) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.weekly,
      interval: interval,
      byDay: byDay,
      count: count,
      until: until,
    );
  }

  /// 毎月
  factory RecurrenceRule.monthly({
    int interval = 1,
    List<int>? byMonthDay,
    int? count,
    DateTime? until,
  }) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.monthly,
      interval: interval,
      byMonthDay: byMonthDay,
      count: count,
      until: until,
    );
  }

  /// 毎年
  factory RecurrenceRule.yearly({
    int interval = 1,
    List<int>? byMonth,
    int? count,
    DateTime? until,
  }) {
    return RecurrenceRule(
      frequency: RecurrenceFrequency.yearly,
      interval: interval,
      byMonth: byMonth,
      count: count,
      until: until,
    );
  }

  /// ICS形式に変換
  String toICSFormat() {
    final buffer = StringBuffer();

    buffer.write('FREQ=${frequency.name.toUpperCase()}');

    if (interval > 1) {
      buffer.write(';INTERVAL=$interval');
    }

    if (count != null) {
      buffer.write(';COUNT=$count');
    }

    if (until != null) {
      buffer.write(';UNTIL=${_formatDateTime(until!)}');
    }

    if (byDay != null && byDay!.isNotEmpty) {
      buffer.write(';BYDAY=${byDay!.map(_dayToString).join(",")}');
    }

    if (byMonthDay != null && byMonthDay!.isNotEmpty) {
      buffer.write(';BYMONTHDAY=${byMonthDay!.join(",")}');
    }

    if (byMonth != null && byMonth!.isNotEmpty) {
      buffer.write(';BYMONTH=${byMonth!.join(",")}');
    }

    return buffer.toString();
  }

  String _formatDateTime(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return '${utc.year}${_pad(utc.month)}${_pad(utc.day)}T${_pad(utc.hour)}${_pad(utc.minute)}${_pad(utc.second)}Z';
  }

  String _pad(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _dayToString(int day) {
    const days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    return days[day - 1];
  }
}

/// 繰り返し頻度
enum RecurrenceFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

/// カレンダー統合ヘルパー
class CalendarIntegrationHelper {
  /// デバイスのカレンダーアプリを開く
  static Future<void> openCalendarApp() async {
    // TODO: url_launcherを使用してカレンダーアプリを開く
    // await launchUrl(Uri.parse('content://com.android.calendar/time/'));
  }

  /// カレンダーに追加するためのインテントを作成
  static Future<void> addToCalendar({
    required String title,
    required DateTime startTime,
    String? description,
    String? location,
  }) async {
    // TODO: add_2_calendarパッケージを使用
  }
}

/// カレンダーエクスポート設定
class CalendarExportConfig {
  final bool includeReminders;
  final Duration reminderBefore;
  final bool includeDescription;
  final bool includeLocation;

  const CalendarExportConfig({
    this.includeReminders = true,
    this.reminderBefore = const Duration(minutes: 15),
    this.includeDescription = true,
    this.includeLocation = true,
  });

  /// デフォルト設定
  static const defaultConfig = CalendarExportConfig();

  /// 最小限の設定
  static const minimal = CalendarExportConfig(
    includeReminders: false,
    includeDescription: false,
    includeLocation: false,
  );
}

/// カレンダーエクスポート統計
class CalendarExportStats {
  int _exportCount = 0;
  final Map<String, int> _exportTypeCount = {};

  /// エクスポート回数
  int get exportCount => _exportCount;

  /// エクスポートを記録
  void recordExport(String type) {
    _exportCount++;
    _exportTypeCount[type] = (_exportTypeCount[type] ?? 0) + 1;
  }

  /// タイプ別のエクスポート回数
  int getExportCountByType(String type) {
    return _exportTypeCount[type] ?? 0;
  }

  /// 統計をリセット
  void reset() {
    _exportCount = 0;
    _exportTypeCount.clear();
  }

  /// 統計を取得
  Map<String, dynamic> getStats() {
    return {
      'totalExports': _exportCount,
      'exportsByType': Map.unmodifiable(_exportTypeCount),
    };
  }
}
