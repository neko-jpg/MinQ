import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/premium/premium_service.dart';
import 'package:minq/core/storage/local_storage_service.dart';
import 'package:minq/domain/premium/premium_plan.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class DataExportService {
  final PremiumService _premiumService;
  final LocalStorageService _localStorage;

  DataExportService(this._premiumService, this._localStorage);

  Future<bool> canExportData() async {
    return await _premiumService.hasFeature(FeatureType.export);
  }

  Future<ExportResult> exportToCSV({
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize = false,
  }) async {
    if (!await canExportData()) {
      return ExportResult.failure(
        'Premium subscription required for data export',
      );
    }

    try {
      final data = await _getExportData(type, startDate, endDate, anonymize);
      final csvData = _convertToCSV(data, type);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${type.name}_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(csvData);

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        format: ExportFormat.csv,
        recordCount: data.length,
      );
    } catch (e) {
      return ExportResult.failure('Failed to export CSV: $e');
    }
  }

  Future<ExportResult> exportToPDF({
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize = false,
  }) async {
    if (!await canExportData()) {
      return ExportResult.failure(
        'Premium subscription required for data export',
      );
    }

    try {
      final data = await _getExportData(type, startDate, endDate, anonymize);
      final pdfBytes = await _generatePDF(data, type);

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${type.name}_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(pdfBytes);

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        format: ExportFormat.pdf,
        recordCount: data.length,
      );
    } catch (e) {
      return ExportResult.failure('Failed to export PDF: $e');
    }
  }

  Future<ExportResult> exportToJSON({
    required ExportType type,
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize = false,
  }) async {
    if (!await canExportData()) {
      return ExportResult.failure(
        'Premium subscription required for data export',
      );
    }

    try {
      final data = await _getExportData(type, startDate, endDate, anonymize);
      final jsonData = jsonEncode({
        'exportType': type.name,
        'exportDate': DateTime.now().toIso8601String(),
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'anonymized': anonymize,
        'recordCount': data.length,
        'data': data,
      });

      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          '${type.name}_export_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonData);

      return ExportResult.success(
        filePath: file.path,
        fileName: fileName,
        format: ExportFormat.json,
        recordCount: data.length,
      );
    } catch (e) {
      return ExportResult.failure('Failed to export JSON: $e');
    }
  }

  Future<void> shareExport(ExportResult result) async {
    if (result.isSuccess && result.filePath != null) {
      await Share.shareXFiles([
        XFile(result.filePath!),
      ], text: 'MinQ Data Export - ${result.fileName}');
    }
  }

  Future<List<Map<String, dynamic>>> _getExportData(
    ExportType type,
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize,
  ) async {
    switch (type) {
      case ExportType.quests:
        return await _getQuestData(startDate, endDate, anonymize);
      case ExportType.progress:
        return await _getProgressData(startDate, endDate, anonymize);
      case ExportType.analytics:
        return await _getAnalyticsData(startDate, endDate, anonymize);
      case ExportType.achievements:
        return await _getAchievementData(startDate, endDate, anonymize);
      case ExportType.all:
        final allData = <Map<String, dynamic>>[];
        allData.addAll(await _getQuestData(startDate, endDate, anonymize));
        allData.addAll(await _getProgressData(startDate, endDate, anonymize));
        allData.addAll(await _getAnalyticsData(startDate, endDate, anonymize));
        allData.addAll(
          await _getAchievementData(startDate, endDate, anonymize),
        );
        return allData;
    }
  }

  Future<List<Map<String, dynamic>>> _getQuestData(
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize,
  ) async {
    // Mock data - in real implementation, this would fetch from database
    return [
      {
        'id': anonymize ? 'quest_1' : 'real_quest_id_1',
        'title': 'Morning Exercise',
        'description': 'Do 30 minutes of exercise',
        'category': 'Health',
        'status': 'completed',
        'createdAt': '2024-01-01T08:00:00Z',
        'completedAt': '2024-01-01T08:30:00Z',
        'streak': 5,
        'xpEarned': 25,
      },
      {
        'id': anonymize ? 'quest_2' : 'real_quest_id_2',
        'title': 'Read for 20 minutes',
        'description': 'Read a book or article',
        'category': 'Learning',
        'status': 'active',
        'createdAt': '2024-01-01T19:00:00Z',
        'completedAt': null,
        'streak': 0,
        'xpEarned': 0,
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _getProgressData(
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize,
  ) async {
    // Mock data
    return [
      {
        'date': '2024-01-01',
        'questsCompleted': 3,
        'totalQuests': 5,
        'completionRate': 0.6,
        'xpEarned': 75,
        'streakDays': 5,
        'categories': ['Health', 'Learning', 'Productivity'],
      },
      {
        'date': '2024-01-02',
        'questsCompleted': 4,
        'totalQuests': 5,
        'completionRate': 0.8,
        'xpEarned': 100,
        'streakDays': 6,
        'categories': ['Health', 'Learning', 'Productivity', 'Social'],
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _getAnalyticsData(
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize,
  ) async {
    // Mock data
    return [
      {
        'metric': 'weekly_completion_rate',
        'value': 0.75,
        'period': '2024-W01',
        'category': 'overall',
      },
      {
        'metric': 'average_streak_length',
        'value': 8.5,
        'period': '2024-01',
        'category': 'streaks',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _getAchievementData(
    DateTime? startDate,
    DateTime? endDate,
    bool anonymize,
  ) async {
    // Mock data
    return [
      {
        'id': anonymize ? 'achievement_1' : 'real_achievement_id_1',
        'name': 'First Steps',
        'description': 'Complete your first quest',
        'category': 'Beginner',
        'unlockedAt': '2024-01-01T08:30:00Z',
        'xpReward': 50,
        'rarity': 'common',
      },
      {
        'id': anonymize ? 'achievement_2' : 'real_achievement_id_2',
        'name': 'Streak Master',
        'description': 'Maintain a 7-day streak',
        'category': 'Consistency',
        'unlockedAt': '2024-01-07T20:00:00Z',
        'xpReward': 200,
        'rarity': 'rare',
      },
    ];
  }

  String _convertToCSV(List<Map<String, dynamic>> data, ExportType type) {
    if (data.isEmpty) return '';

    final headers = data.first.keys.toList();
    final rows =
        data
            .map(
              (item) =>
                  headers
                      .map((header) => item[header]?.toString() ?? '')
                      .toList(),
            )
            .toList();

    return const ListToCsvConverter().convert([headers, ...rows]);
  }

  Future<Uint8List> _generatePDF(
    List<Map<String, dynamic>> data,
    ExportType type,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('MinQ Data Export - ${type.displayName}'),
            ),
            pw.Paragraph(
              text: 'Export generated on ${DateTime.now().toString()}',
            ),
            pw.SizedBox(height: 20),
            if (data.isNotEmpty) ...[
              pw.Table.fromTextArray(
                context: context,
                data: [
                  data.first.keys.toList(),
                  ...data.map(
                    (item) =>
                        item.values.map((v) => v?.toString() ?? '').toList(),
                  ),
                ],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ] else ...[
              pw.Text('No data available for the selected criteria.'),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }
}

class ExportResult {
  final bool isSuccess;
  final String? filePath;
  final String? fileName;
  final ExportFormat? format;
  final int? recordCount;
  final String? errorMessage;

  const ExportResult._({
    required this.isSuccess,
    this.filePath,
    this.fileName,
    this.format,
    this.recordCount,
    this.errorMessage,
  });

  factory ExportResult.success({
    required String filePath,
    required String fileName,
    required ExportFormat format,
    required int recordCount,
  }) {
    return ExportResult._(
      isSuccess: true,
      filePath: filePath,
      fileName: fileName,
      format: format,
      recordCount: recordCount,
    );
  }

  factory ExportResult.failure(String errorMessage) {
    return ExportResult._(isSuccess: false, errorMessage: errorMessage);
  }
}

enum ExportType { quests, progress, analytics, achievements, all }

enum ExportFormat { csv, pdf, json }

extension ExportTypeExtension on ExportType {
  String get displayName {
    switch (this) {
      case ExportType.quests:
        return 'Quests';
      case ExportType.progress:
        return 'Progress';
      case ExportType.analytics:
        return 'Analytics';
      case ExportType.achievements:
        return 'Achievements';
      case ExportType.all:
        return 'All Data';
    }
  }
}

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  final premiumService = ref.watch(premiumServiceProvider);
  final localStorage = ref.watch(localStorageServiceProvider);
  return DataExportService(premiumService, localStorage);
});
