import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/core/logging/app_logger.dart';

/// ペア解消サービス
class PairDissolutionService {
  final FirebaseFirestore _firestore;

  PairDissolutionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ペアを解消
  Future<bool> dissolvePair({
    required String userId,
    required String pairId,
    String? reason,
  }) async {
    try {
      final pairRef = _firestore.collection('pairs').doc(pairId);
      final pairDoc = await pairRef.get();

      if (!pairDoc.exists) {
        return false;
      }

      final pairData = pairDoc.data()!;
      final user1Id = pairData['user1Id'] as String;
      final user2Id = pairData['user2Id'] as String;

      // ペアを解消
      await pairRef.update({
        'status': 'dissolved',
        'dissolvedBy': userId,
        'dissolvedAt': FieldValue.serverTimestamp(),
        'dissolveReason': reason,
      });

      // 両ユーザーのペア情報を更新
      await _updateUserPairStatus(user1Id, pairId, dissolved: true);
      await _updateUserPairStatus(user2Id, pairId, dissolved: true);

      logger.logJson('Pair dissolved', {
        'pairId': pairId,
        'dissolvedBy': userId,
        'reason': reason,
      });

      return true;
    } catch (e, stack) {
      logger.error('Failed to dissolve pair', error: e, stackTrace: stack);
      return false;
    }
  }

  /// ユーザーのペア状態を更新
  Future<void> _updateUserPairStatus(
    String userId,
    String pairId, {
    required bool dissolved,
  }) async {
    await _firestore.collection('users').doc(userId).update({
      'currentPairId': dissolved ? null : pairId,
      'hasPair': !dissolved,
    });
  }

  /// ペア解消の確認ダイアログ用データ
  Map<String, dynamic> getDissolutionConfirmationData() {
    return {
      'title': 'ペアを解消しますか？',
      'message': 'ペアを解消すると、相手との進捗共有が停止されます。この操作は取り消せません。',
      'reasons': ['目標が達成できた', '相性が合わなかった', '一時的に休止したい', 'その他'],
    };
  }
}
