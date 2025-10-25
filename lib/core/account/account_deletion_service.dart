import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:minq/core/logging/app_logger.dart';

/// アカウント削除サービス
/// GDPR/個人情報保護法に準拠したデータ削除機能
class AccountDeletionService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// アカウントを完全に削除
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.uid;

    try {
      // 1. Firestoreのデータを削除
      await _deleteFirestoreData(userId);

      // 2. Storageのデータを削除
      await _deleteStorageData(userId);

      // 3. Authenticationを削除
      await user.delete();

      logger.info('✅ Account deleted successfully');
    } catch (e, s) {
      logger.error('Failed to delete account', error: e, stackTrace: s);
      rethrow;
    }
  }

  /// Firestoreのユーザーデータを削除
  Future<void> _deleteFirestoreData(String userId) async {
    final batch = _firestore.batch();

    // ユーザー情報を削除
    batch.delete(_firestore.collection('users').doc(userId));

    // クエストを削除
    final questsSnapshot =
        await _firestore
            .collection('quests')
            .where('userId', isEqualTo: userId)
            .get();

    for (final doc in questsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // クエストログを削除
    final logsSnapshot =
        await _firestore
            .collection('questLogs')
            .where('userId', isEqualTo: userId)
            .get();

    for (final doc in logsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // ペアリクエストを削除
    final pairRequestsSnapshot =
        await _firestore
            .collection('pairRequests')
            .where('fromUserId', isEqualTo: userId)
            .get();

    for (final doc in pairRequestsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    final pairRequestsSnapshot2 =
        await _firestore
            .collection('pairRequests')
            .where('toUserId', isEqualTo: userId)
            .get();

    for (final doc in pairRequestsSnapshot2.docs) {
      batch.delete(doc.reference);
    }

    // アチーブメントを削除
    final achievementsSnapshot =
        await _firestore
            .collection('achievements')
            .where('userId', isEqualTo: userId)
            .get();

    for (final doc in achievementsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // 通知設定を削除
    final notificationSettingsSnapshot =
        await _firestore
            .collection('notificationSettings')
            .where('userId', isEqualTo: userId)
            .get();

    for (final doc in notificationSettingsSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    logger.info('✅ Firestore data deleted');
  }

  /// Storageのユーザーデータを削除
  Future<void> _deleteStorageData(String userId) async {
    try {
      final ref = _storage.ref().child('users/$userId');
      final listResult = await ref.listAll();

      // すべてのファイルを削除
      for (final item in listResult.items) {
        await item.delete();
      }

      // すべてのサブフォルダを削除
      for (final prefix in listResult.prefixes) {
        await _deleteStorageFolder(prefix);
      }

      logger.info('✅ Storage data deleted');
    } catch (e, s) {
      logger.warning('Failed to delete storage data', error: e, stackTrace: s);
      // Storageの削除に失敗してもアカウント削除は続行
    }
  }

  /// Storageのフォルダを再帰的に削除
  Future<void> _deleteStorageFolder(Reference folderRef) async {
    final listResult = await folderRef.listAll();

    for (final item in listResult.items) {
      await item.delete();
    }

    for (final prefix in listResult.prefixes) {
      await _deleteStorageFolder(prefix);
    }
  }

  /// データエクスポート（削除前にダウンロード可能）
  Future<Map<String, dynamic>> exportUserData() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final userId = user.uid;

    // ユーザー情報
    final userDoc = await _firestore.collection('users').doc(userId).get();
    final userData = userDoc.data();

    // クエスト情報
    final questsSnapshot = await _firestore
        .collection('quests')
        .where('userId', isEqualTo: userId)
        .get();
    final quests = questsSnapshot.docs.map((doc) => doc.data()).toList();

    // クエストログ
    final logsSnapshot = await _firestore
        .collection('questLogs')
        .where('userId', isEqualTo: userId)
        .get();
    final logs = logsSnapshot.docs.map((doc) => doc.data()).toList();

    // アチーブメント
    final achievementsSnapshot = await _firestore
        .collection('achievements')
        .where('userId', isEqualTo: userId)
        .get();
    final achievements =
        achievementsSnapshot.docs.map((doc) => doc.data()).toList();

    return {
      'user': userData,
      'quests': quests,
      'logs': logs,
      'achievements': achievements,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// アカウント削除の確認
  Future<bool> confirmDeletion() async {
    // UIで二重確認を実装
    // 例: "DELETE"という文字列を入力させる
    return true;
  }

  /// 削除予約（30日後に削除）
  Future<void> scheduleDeletion() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'deletionScheduledAt': FieldValue.serverTimestamp(),
      'deletionDate': DateTime.now().add(const Duration(days: 30)),
    });

    logger.info('✅ Account deletion scheduled for 30 days from now');
  }

  /// 削除予約をキャンセル
  Future<void> cancelDeletion() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('users').doc(user.uid).update({
      'deletionScheduledAt': FieldValue.delete(),
      'deletionDate': FieldValue.delete(),
    });

    logger.info('✅ Account deletion cancelled');
  }
}
