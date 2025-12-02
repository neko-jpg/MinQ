import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:minq/core/logging/app_logger.dart';

/// アーカイブサービス
class ArchiveService {
  final FirebaseFirestore _firestore;

  ArchiveService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// クエストをアーカイブ
  Future<void> archiveQuest(String userId, String questId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .update({
            'isArchived': true,
            'archivedAt': FieldValue.serverTimestamp(),
          });

      AppLogger().logJson('Quest archived', {'questId': questId}, level: Level.info);
    } catch (e, stack) {
      AppLogger().error('Failed to archive quest', e, stack);
      rethrow;
    }
  }

  /// クエストをアーカイブ解除
  Future<void> unarchiveQuest(String userId, String questId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .update({'isArchived': false, 'archivedAt': null});

      AppLogger().logJson('Quest unarchived', {'questId': questId}, level: Level.info);
    } catch (e, stack) {
      AppLogger().error('Failed to unarchive quest', e, stack);
      rethrow;
    }
  }

  /// アーカイブされたクエストを取得
  Stream<List<Map<String, dynamic>>> getArchivedQuests(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quests')
        .where('isArchived', isEqualTo: true)
        .orderBy('archivedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  /// アーカイブされたクエストを完全削除
  Future<void> deleteArchivedQuest(String userId, String questId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .delete();

      AppLogger().logJson('Archived quest deleted', {'questId': questId}, level: Level.info);
    } catch (e, stack) {
      AppLogger().error(
        'Failed to delete archived quest',
        e,
        stack,
      );
      rethrow;
    }
  }

  /// 古いアーカイブを自動削除（90日以上前）
  Future<void> cleanOldArchives(String userId) async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 90));

      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('quests')
              .where('isArchived', isEqualTo: true)
              .where('archivedAt', isLessThan: Timestamp.fromDate(cutoffDate))
              .get();

      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }

      AppLogger().logJson(
        'Old archives cleaned',
        {'count': snapshot.docs.length},
        level: Level.info,
      );
    } catch (e, stack) {
      AppLogger().error(
        'Failed to clean old archives',
        e,
        stack,
      );
    }
  }
}
