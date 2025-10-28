import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

final dataExportServiceProvider = Provider((ref) {
  return DataExportService(FirebaseFirestore.instance);
});

class DataExportService {
  final FirebaseFirestore _firestore;

  DataExportService(this._firestore);

  Future<File> exportDataZip({
    required List<Map<String, dynamic>> quests,
    required List<Map<String, dynamic>> logs,
    required Map<String, dynamic> stats,
    required Map<String, dynamic> metadata,
  }) async {
    const encoder = JsonEncoder.withIndent('  ');
    final archive = Archive();

    final questsData = utf8.encode(encoder.convert(quests));
    archive.addFile(ArchiveFile('quests.json', questsData.length, questsData));

    final logsData = utf8.encode(encoder.convert(logs));
    archive.addFile(ArchiveFile('logs.json', logsData.length, logsData));

    final statsData = utf8.encode(encoder.convert(stats));
    archive.addFile(ArchiveFile('stats.json', statsData.length, statsData));

    final metadataData = utf8.encode(encoder.convert(metadata));
    archive.addFile(
      ArchiveFile('metadata.json', metadataData.length, metadataData),
    );

    final outputDir = await getTemporaryDirectory();
    final outputFile = File('${outputDir.path}/minq_export.zip');

    final zipEncoder = ZipEncoder();
    final outputStream = OutputFileStream(outputFile.path);
    zipEncoder.encode(archive, output: outputStream);

    return outputFile;
  }

  Future<void> shareFile(File file) async {
    final params = ShareParams(
      text: 'My MinQ Data Export',
      files: [XFile(file.path)],
    );
    await SharePlus.instance.share(params);
  }

  Future<void> exportQuestHistoryAsPdf(String userId) async {
    // 1. Fetch data
    final questLogsSnapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('quest_logs')
            .orderBy('completedAt', descending: true)
            .get();

    final questLogs = questLogsSnapshot.docs;

    // 2. Generate PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Quest Completion History',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.TableHelper.fromTextArray(
              headers: ['Date', 'Quest Name'],
              data:
                  questLogs.map((doc) {
                    final data = doc.data();
                    final date = (data['completedAt'] as Timestamp).toDate();
                    final name = data['name'] as String;
                    return [date.toLocal().toString().split(' ')[0], name];
                  }).toList(),
            ),
          ];
        },
      ),
    );

    // 3. Save and share
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/quest_history.pdf');
    await file.writeAsBytes(await pdf.save());

    final params = ShareParams(
      text: 'Here is my quest history from MinQ!',
      files: [XFile(file.path)],
    );
    await SharePlus.instance.share(params);
  }
}
