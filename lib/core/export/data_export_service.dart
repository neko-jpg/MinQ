import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:minq/features/home/presentation/screens/home_screen_v2.dart'; // for _userId

final dataExportServiceProvider = Provider((ref) {
  return DataExportService(FirebaseFirestore.instance);
});

class DataExportService {
  final FirebaseFirestore _firestore;

  DataExportService(this._firestore);

  Future<void> exportQuestHistoryAsPdf() async {
    // 1. Fetch data
    final questLogsSnapshot = await _firestore
        .collection('users')
        .doc(_userId)
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
            pw.Header(level: 0, child: pw.Text("Quest Completion History", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
            pw.Table.fromTextArray(
              headers: ['Date', 'Quest Name'],
              data: questLogs.map((doc) {
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
    final file = File("${output.path}/quest_history.pdf");
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'Here is my quest history from MinQ!');
  }
}