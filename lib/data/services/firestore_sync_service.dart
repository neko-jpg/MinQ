import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/repositories/quest_log_repository.dart';
import 'package:minq/domain/log/quest_log.dart';

class FirestoreSyncService {
  FirestoreSyncService(this._firestore, this._logRepository, this._isar);

  final FirebaseFirestore _firestore;
  final QuestLogRepository _logRepository;
  final Isar _isar;

  Future<void> syncQuestLogs(String uid) async {
    final unsyncedLogs =
        await _isar.questLogs
            .filter()
            .uidEqualTo(uid)
            .syncedEqualTo(false)
            .findAll();

    if (unsyncedLogs.isEmpty) {
      return;
    }

    final logIds = unsyncedLogs.map((log) => log.id).toList();
    final payloads = unsyncedLogs
        .map(
          (QuestLog log) => _PendingLog(
            docRef: _firestore
                .collection('users')
                .doc(uid)
                .collection('quest_logs')
                .doc(log.id.toString()),
            data: {
              'questId': log.questId,
              'ts': log.ts,
              'proofType': log.proofType.name,
              'proofValue': log.proofValue,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          ),
        )
        .toList();

    const maxAttempts = 5;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final batch = _firestore.batch();
      for (final payload in payloads) {
        batch.set(payload.docRef, payload.data, SetOptions(merge: true));
      }

      try {
        await batch.commit();
        await _logRepository.markLogsAsSynced(logIds);
        return;
      } on FirebaseException catch (error) {
        final retryable = _isRetryable(error.code);
        if (!retryable || attempt == maxAttempts - 1) {
          rethrow;
        }
      }

      await Future<void>.delayed(
        Duration(milliseconds: 200 * pow(2, attempt).toInt()),
      );
    }
  }

  bool _isRetryable(String code) {
    return <String>{'aborted', 'cancelled', 'unknown', 'deadline-exceeded'}
        .contains(code);
  }
}

class _PendingLog {
  _PendingLog({required this.docRef, required this.data});

  final DocumentReference<Map<String, dynamic>> docRef;
  final Map<String, dynamic> data;
}
