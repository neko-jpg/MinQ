import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// エクスポート形式
enum ExportFormat {
  /// JSON形式
  json,

  /// CSV形式
  csv,

  /// テキスト形式
  text,
}

/// データエクスポートサービス
class DataExportService {
  /// クエストデータをエクスポート
  Future<File> exportQuests({
    required List<Map<String, dynamic>> quests,
    required ExportFormat format,
    String? filename,
  }) async {
    final name = filename ?? 'quests_${DateTime.now().millisecondsSinceEpoch}';

    switch (format) {
      case ExportFormat.json:
        return await _exportAsJson(quests, '$name.json');
      case ExportFormat.csv:
        return await _exportQuestsAsCsv(quests, '$name.csv');
      case ExportFormat.text:
        return await _exportAsText(quests, '$name.txt');
    }
  }

  /// ログデータをエクスポート
  Future<File> exportLogs({
    required List<Map<String, dynamic>> logs,
    required ExportFormat format,
    String? filename,
  }) async {
    final name = filename ?? 'logs_${DateTime.now().millisecondsSinceEpoch}';

    switch (format) {
      case ExportFormat.json:
        return await _exportAsJson(logs, '$name.json');
      case ExportFormat.csv:
        return await _exportLogsAsCsv(logs, '$name.csv');
      case ExportFormat.text:
        return await _exportAsText(logs, '$name.txt');
    }
  }

  /// 統計データをエクスポート
  Future<File> exportStats({
    required Map<String, dynamic> stats,
    required ExportFormat format,
    String? filename,
  }) async {
    final name = filename ?? 'stats_${DateTime.now().millisecondsSinceEpoch}';

    switch (format) {
      case ExportFormat.json:
        return await _exportAsJson(stats, '$name.json');
      case ExportFormat.csv:
        return await _exportStatsAsCsv(stats, '$name.csv');
      case ExportFormat.text:
        return await _exportAsText(stats, '$name.txt');
    }
  }

  /// 全データをエクスポート
  Future<File> exportAllData({
    required Map<String, dynamic> allData,
    String? filename,
  }) async {
    final name = filename ?? 'minq_backup_${DateTime.now().millisecondsSinceEpoch}';
    return await _exportAsJson(allData, '$name.json');
  }

  /// JSON形式でエクスポート
  Future<File> _exportAsJson(dynamic data, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    await file.writeAsString(jsonString);

    return file;
  }

  /// クエストをCSV形式でエクスポート
  Future<File> _exportQuestsAsCsv(
    List<Map<String, dynamic>> quests,
    String filename,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');

    final rows = <List<dynamic>>[
      ['ID', 'タイトル', 'カテゴリー', '作成日', '完了回数', 'アクティブ'],
    ];

    for (final quest in quests) {
      rows.add([
        quest['id'],
        quest['title'],
        quest['category'] ?? '',
        quest['createdAt'],
        quest['completionCount'] ?? 0,
        quest['isActive'] ?? true,
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);

    return file;
  }

  /// ログをCSV形式でエクスポート
  Future<File> _exportLogsAsCsv(
    List<Map<String, dynamic>> logs,
    String filename,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');

    final rows = <List<dynamic>>[
      ['ID', 'クエストID', '完了日時', 'メモ'],
    ];

    for (final log in logs) {
      rows.add([
        log['id'],
        log['questId'],
        log['completedAt'],
        log['note'] ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);

    return file;
  }

  /// 統計をCSV形式でエクスポート
  Future<File> _exportStatsAsCsv(
    Map<String, dynamic> stats,
    String filename,
  ) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');

    final rows = <List<dynamic>>[
      ['指標', '値'],
    ];

    stats.forEach((key, value) {
      rows.add([key, value]);
    });

    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);

    return file;
  }

  /// テキスト形式でエクスポート
  Future<File> _exportAsText(dynamic data, String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$filename');

    final buffer = StringBuffer();

    if (data is List) {
      for (final item in data) {
        buffer.writeln(_formatItem(item));
        buffer.writeln('---');
      }
    } else if (data is Map) {
      data.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    } else {
      buffer.writeln(data.toString());
    }

    await file.writeAsString(buffer.toString());

    return file;
  }

  /// アイテムをフォーマット
  String _formatItem(Map<String, dynamic> item) {
    final buffer = StringBuffer();
    item.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }

  /// ファイルを共有
  Future<void> shareFile(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'MiniQuest データエクスポート',
    );
  }
}

/// データインポートサービス
class DataImportService {
  /// JSONファイルからインポート
  Future<Map<String, dynamic>> importFromJson(File file) async {
    try {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      throw ImportException('JSONファイルの読み込みに失敗しました: $e');
    }
  }

  /// CSVファイルからクエストをインポート
  Future<List<Map<String, dynamic>>> importQuestsFromCsv(File file) async {
    try {
      final content = await file.readAsString();
      final rows = const CsvToListConverter().convert(content);

      if (rows.isEmpty || rows.length < 2) {
        throw ImportException('CSVファイルが空です');
      }

      final headers = rows[0].map((e) => e.toString()).toList();
      final quests = <Map<String, dynamic>>[];

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        final quest = <String, dynamic>{};

        for (int j = 0; j < headers.length && j < row.length; j++) {
          quest[headers[j]] = row[j];
        }

        quests.add(quest);
      }

      return quests;
    } catch (e) {
      throw ImportException('CSVファイルの読み込みに失敗しました: $e');
    }
  }

  /// データを検証
  bool validateImportData(Map<String, dynamic> data) {
    // 必須フィールドのチェック
    if (!data.containsKey('version')) {
      return false;
    }

    // バージョンチェック
    final version = data['version'] as int?;
    if (version == null || version > 3) {
      return false;
    }

    return true;
  }

  /// データをマージ
  Map<String, dynamic> mergeData(
    Map<String, dynamic> existing,
    Map<String, dynamic> imported,
  ) {
    final merged = Map<String, dynamic>.from(existing);

    imported.forEach((key, value) {
      if (value is List && merged[key] is List) {
        // リストの場合はマージ
        final existingList = merged[key] as List;
        final importedList = value;
        merged[key] = [...existingList, ...importedList];
      } else if (value is Map && merged[key] is Map) {
        // Mapの場合は再帰的にマージ
        merged[key] = mergeData(
          merged[key] as Map<String, dynamic>,
          value as Map<String, dynamic>,
        );
      } else {
        // その他の場合は上書き
        merged[key] = value;
      }
    });

    return merged;
  }
}

/// インポート例外
class ImportException implements Exception {
  final String message;

  ImportException(this.message);

  @override
  String toString() => 'ImportException: $message';
}

/// エクスポート設定
class ExportConfig {
  final bool includeQuests;
  final bool includeLogs;
  final bool includeStats;
  final bool includeSettings;
  final bool includePairData;
  final ExportFormat format;

  const ExportConfig({
    this.includeQuests = true,
    this.includeLogs = true,
    this.includeStats = true,
    this.includeSettings = true,
    this.includePairData = false,
    this.format = ExportFormat.json,
  });

  /// 全て含む
  static const all = ExportConfig(
    includeQuests: true,
    includeLogs: true,
    includeStats: true,
    includeSettings: true,
    includePairData: true,
  );

  /// 最小限
  static const minimal = ExportConfig(
    includeQuests: true,
    includeLogs: false,
    includeStats: false,
    includeSettings: false,
    includePairData: false,
  );
}

/// エクスポート進捗
class ExportProgress {
  final int totalSteps;
  final int currentStep;
  final String currentTask;

  const ExportProgress({
    required this.totalSteps,
    required this.currentStep,
    required this.currentTask,
  });

  /// 進捗率（0.0〜1.0）
  double get progress => currentStep / totalSteps;

  /// 完了したかどうか
  bool get isComplete => currentStep >= totalSteps;
}

/// エクスポート結果
class ExportResult {
  final File file;
  final int itemCount;
  final int fileSize;
  final Duration duration;

  const ExportResult({
    required this.file,
    required this.itemCount,
    required this.fileSize,
    required this.duration,
  });

  /// ファイルサイズ（MB）
  double get fileSizeMB => fileSize / (1024 * 1024);

  /// 成功メッセージ
  String get successMessage {
    return '$itemCount件のデータを${fileSizeMB.toStringAsFixed(2)}MBでエクスポートしました';
  }
}

/// バックアップマネージャー
class BackupManager {
  final DataExportService _exportService;
  final DataImportService _importService;

  BackupManager({
    required DataExportService exportService,
    required DataImportService importService,
  })  : _exportService = exportService,
        _importService = importService;

  /// バックアップを作成
  Future<File> createBackup(Map<String, dynamic> data) async {
    final backupData = {
      'version': 3,
      'createdAt': DateTime.now().toIso8601String(),
      'data': data,
    };

    return await _exportService.exportAllData(allData: backupData);
  }

  /// バックアップから復元
  Future<Map<String, dynamic>> restoreBackup(File file) async {
    final backupData = await _importService.importFromJson(file);

    if (!_importService.validateImportData(backupData)) {
      throw ImportException('無効なバックアップファイルです');
    }

    return backupData['data'] as Map<String, dynamic>;
  }

  /// 自動バックアップ
  Future<void> autoBackup(Map<String, dynamic> data) async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${directory.path}/backups');

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    // 古いバックアップを削除（7日以上前）
    await _cleanOldBackups(backupDir);

    // 新しいバックアップを作成
    await createBackup(data);
  }

  /// 古いバックアップを削除
  Future<void> _cleanOldBackups(Directory backupDir) async {
    final files = await backupDir.list().toList();
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    for (final file in files) {
      if (file is File) {
        final stat = await file.stat();
        if (stat.modified.isBefore(sevenDaysAgo)) {
          await file.delete();
        }
      }
    }
  }
}
