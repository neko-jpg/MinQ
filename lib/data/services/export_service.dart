import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:minq/data/models/mini_quest.dart';
import 'package:minq/data/models/quest_log.dart';

/// データエクスポートサービス
/// CSV、JSON形式でのデータ出力
class ExportService {
  /// クエストログをCSVエクスポート
  Future<File> exportLogsToCSV({
    required List<QuestLog> logs,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final rows = <List<String>>[];

    // ヘッダー行
    rows.add([
      'Date',
      'Quest ID',
      'Quest Title',
      'Completed',
      'Completion Time',
      'Notes',
    ]);

    // データ行
    for (final log in logs) {
      final date = log.date;
      if (startDate != null && date.isBefore(startDate)) continue;
      if (endDate != null && date.isAfter(endDate)) continue;

      rows.add([
        _formatDate(log.date),
        log.questId,
        log.questTitle ?? '',
        log.completed ? 'Yes' : 'No',
        log.completedAt != null ? _formatDateTime(log.completedAt!) : '',
        log.notes ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    return _writeToFile(csv, 'quest_logs_${_getTimestamp()}.csv');
  }

  /// クエストをCSVエクスポート
  Future<File> exportQuestsToCSV(List<MiniQuest> quests) async {
    final rows = <List<String>>[];

    // ヘッダー行
    rows.add([
      'ID',
      'Title',
      'Description',
      'Reminder Time',
      'Active',
      'Created At',
      'Order',
    ]);

    // データ行
    for (final quest in quests) {
      rows.add([
        quest.id,
        quest.title,
        quest.description ?? '',
        quest.reminderTime ?? '',
        quest.isActive ? 'Yes' : 'No',
        _formatDateTime(quest.createdAt),
        quest.order.toString(),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    return _writeToFile(csv, 'quests_${_getTimestamp()}.csv');
  }

  /// 統計データをCSVエクスポート
  Future<File> exportStatsToCSV({
    required Map<DateTime, int> dailyCompletions,
    required int currentStreak,
    required int longestStreak,
    required double weeklyAchievementRate,
  }) async {
    final rows = <List<String>>[];

    // サマリーセクション
    rows.add(['Summary Statistics']);
    rows.add(['Current Streak', currentStreak.toString()]);
    rows.add(['Longest Streak', longestStreak.toString()]);
    rows.add([
      'Weekly Achievement Rate',
      '${(weeklyAchievementRate * 100).toStringAsFixed(1)}%',
    ]);
    rows.add([]); // 空行

    // 日次データ
    rows.add(['Daily Completions']);
    rows.add(['Date', 'Completed Count']);

    final sortedDates = dailyCompletions.keys.toList()..sort();
    for (final date in sortedDates) {
      rows.add([_formatDate(date), dailyCompletions[date].toString()]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    return _writeToFile(csv, 'stats_${_getTimestamp()}.csv');
  }

  /// データをJSONエクスポート
  Future<File> exportToJSON({
    required List<MiniQuest> quests,
    required List<QuestLog> logs,
    Map<String, dynamic>? metadata,
  }) async {
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': '1.0',
      'metadata': metadata ?? {},
      'quests': quests.map((q) => q.toJson()).toList(),
      'logs': logs.map((l) => l.toJson()).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    return _writeToFile(jsonString, 'minquest_backup_${_getTimestamp()}.json');
  }

  /// JSONからデータをインポート
  Future<ImportResult> importFromJSON(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      final quests =
          (data['quests'] as List?)
              ?.map((q) => MiniQuest.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [];

      final logs =
          (data['logs'] as List?)
              ?.map((l) => QuestLog.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [];

      return ImportResult(
        quests: quests,
        logs: logs,
        metadata: data['metadata'] as Map<String, dynamic>?,
        success: true,
      );
    } catch (e) {
      return ImportResult(
        quests: [],
        logs: [],
        success: false,
        error: e.toString(),
      );
    }
  }

  /// ファイルをシェア
  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)], subject: 'MiniQuest Export');
  }

  /// 期間比較レポートを生成
  Future<File> exportComparisonReport({
    required DateTime period1Start,
    required DateTime period1End,
    required DateTime period2Start,
    required DateTime period2End,
    required List<QuestLog> allLogs,
  }) async {
    final period1Logs =
        allLogs.where((log) {
          return log.date.isAfter(
                period1Start.subtract(const Duration(days: 1)),
              ) &&
              log.date.isBefore(period1End.add(const Duration(days: 1)));
        }).toList();

    final period2Logs =
        allLogs.where((log) {
          return log.date.isAfter(
                period2Start.subtract(const Duration(days: 1)),
              ) &&
              log.date.isBefore(period2End.add(const Duration(days: 1)));
        }).toList();

    final rows = <List<String>>[];

    // ヘッダー
    rows.add(['Period Comparison Report']);
    rows.add([]);
    rows.add([
      'Metric',
      'Period 1 (${_formatDate(period1Start)} - ${_formatDate(period1End)})',
      'Period 2 (${_formatDate(period2Start)} - ${_formatDate(period2End)})',
      'Change',
      'Change %',
    ]);

    // 総完了数
    final p1Completed = period1Logs.where((l) => l.completed).length;
    final p2Completed = period2Logs.where((l) => l.completed).length;
    final completedChange = p2Completed - p1Completed;
    final completedChangePercent =
        p1Completed > 0 ? (completedChange / p1Completed * 100) : 0.0;

    rows.add([
      'Total Completed',
      p1Completed.toString(),
      p2Completed.toString(),
      completedChange.toString(),
      '${completedChangePercent.toStringAsFixed(1)}%',
    ]);

    // 平均完了率
    final p1Rate =
        period1Logs.isEmpty
            ? 0.0
            : period1Logs.where((l) => l.completed).length / period1Logs.length;
    final p2Rate =
        period2Logs.isEmpty
            ? 0.0
            : period2Logs.where((l) => l.completed).length / period2Logs.length;
    final rateChange = (p2Rate - p1Rate) * 100;

    rows.add([
      'Completion Rate',
      '${(p1Rate * 100).toStringAsFixed(1)}%',
      '${(p2Rate * 100).toStringAsFixed(1)}%',
      '${rateChange.toStringAsFixed(1)}%',
      '',
    ]);

    // 日次平均
    final p1Days = period1End.difference(period1Start).inDays + 1;
    final p2Days = period2End.difference(period2Start).inDays + 1;
    final p1DailyAvg = p1Completed / p1Days;
    final p2DailyAvg = p2Completed / p2Days;
    final dailyAvgChange = p2DailyAvg - p1DailyAvg;

    rows.add([
      'Daily Average',
      p1DailyAvg.toStringAsFixed(1),
      p2DailyAvg.toStringAsFixed(1),
      dailyAvgChange.toStringAsFixed(1),
      p1DailyAvg > 0
          ? '${(dailyAvgChange / p1DailyAvg * 100).toStringAsFixed(1)}%'
          : '',
    ]);

    final csv = const ListToCsvConverter().convert(rows);
    return _writeToFile(csv, 'comparison_report_${_getTimestamp()}.csv');
  }

  // ヘルパーメソッド

  Future<File> _writeToFile(String content, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');
    return file.writeAsString(content);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
  }
}

/// インポート結果
class ImportResult {
  final List<MiniQuest> quests;
  final List<QuestLog> logs;
  final Map<String, dynamic>? metadata;
  final bool success;
  final String? error;

  ImportResult({
    required this.quests,
    required this.logs,
    this.metadata,
    required this.success,
    this.error,
  });
}
