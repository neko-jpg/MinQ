import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/data/logging/minq_logger.dart';

/// ストリークリカバリーサービス
class StreakRecoveryService {
  final FirebaseFirestore _firestore;

  StreakRecoveryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// リカバリーチケットを使用してストリークを復元
  Future<bool> recoverStreak({
    required String userId,
    required String questId,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final questRef = userRef.collection('quests').doc(questId);

      // トランザクションで実行
      return await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(userRef);
        final questDoc = await transaction.get(questRef);

        if (!userDoc.exists || !questDoc.exists) {
          return false;
        }

        final userData = userDoc.data()!;
        final questData = questDoc.data()!;

        // リカバリーチケット数を確認
        final recoveryTickets = userData['recoveryTickets'] as int? ?? 0;
        if (recoveryTickets <= 0) {
          MinqLogger.instance.warn('No recovery tickets available');
          return false;
        }

        // ストリークを復元
        final currentStreak = questData['currentStreak'] as int? ?? 0;
        transaction.update(questRef, {
          'currentStreak': currentStreak + 1,
          'lastRecoveryAt': FieldValue.serverTimestamp(),
        });

        // チケットを消費
        transaction.update(userRef, {
          'recoveryTickets': recoveryTickets - 1,
        });

        MinqLogger.instance.info('Streak recovered', metadata: {
          'userId': userId,
          'questId': questId,
          'remainingTickets': recoveryTickets - 1,
        });

        return true;
      });
    } catch (e, stack) {
      MinqLogger.instance.error('Failed to recover streak', exception: e, stackTrace: stack);
      return false;
    }
  }

  /// リカバリーチケットを購入（課金）
  Future<bool> purchaseRecoveryTicket({
    required String userId,
    required int count,
  }) async {
    try {
      // TODO: 課金処理を実装
      // 1. アプリ内課金を実行
      // 2. 成功したらチケットを付与

      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'recoveryTickets': FieldValue.increment(count),
      });

      MinqLogger.instance.info('Recovery tickets purchased', metadata: {
        'userId': userId,
        'count': count,
      });

      return true;
    } catch (e, stack) {
      MinqLogger.instance.error('Failed to purchase recovery ticket',
          exception: e, stackTrace: stack);
      return false;
    }
  }

  /// 広告視聴でリカバリーチケットを獲得
  Future<bool> earnTicketByWatchingAd({
    required String userId,
  }) async {
    try {
      // TODO: 広告視聴処理を実装
      // 1. リワード広告を表示
      // 2. 視聴完了したらチケットを付与

      final userRef = _firestore.collection('users').doc(userId);

      await userRef.update({
        'recoveryTickets': FieldValue.increment(1),
        'lastAdWatchedAt': FieldValue.serverTimestamp(),
      });

      MinqLogger.instance.info('Recovery ticket earned by ad', metadata: {
        'userId': userId,
      });

      return true;
    } catch (e, stack) {
      MinqLogger.instance.error('Failed to earn ticket by ad',
          exception: e, stackTrace: stack);
      return false;
    }
  }

  /// リカバリーチケット数を取得
  Future<int> getRecoveryTicketCount(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return 0;
      }

      return userDoc.data()?['recoveryTickets'] as int? ?? 0;
    } catch (e, stack) {
      MinqLogger.instance.error('Failed to get recovery ticket count',
          exception: e, stackTrace: stack);
      return 0;
    }
  }

  /// リカバリー可能かチェック
  Future<bool> canRecover({
    required String userId,
    required String questId,
  }) async {
    try {
      final ticketCount = await getRecoveryTicketCount(userId);
      if (ticketCount <= 0) {
        return false;
      }

      // 最後のリカバリーから24時間以上経過しているか確認
      final questDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .get();

      if (!questDoc.exists) {
        return false;
      }

      final lastRecoveryAt = questDoc.data()?['lastRecoveryAt'] as Timestamp?;
      if (lastRecoveryAt != null) {
        final lastRecovery = lastRecoveryAt.toDate();
        final now = DateTime.now();
        final hoursSinceLastRecovery = now.difference(lastRecovery).inHours;

        if (hoursSinceLastRecovery < 24) {
          return false; // 24時間以内は再リカバリー不可
        }
      }

      return true;
    } catch (e, stack) {
      MinqLogger.instance.error('Failed to check recovery availability',
          exception: e, stackTrace: stack);
      return false;
    }
  }
}
