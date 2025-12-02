import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minq/core/logging/app_logger.dart';

/// ペアリマインド通知サービス
class PairReminderService {
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _notifications;

  PairReminderService({
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? notifications,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  /// ペアの未達成状況をチェックして通知
  Future<void> checkAndNotifyPairProgress({
    required String userId,
    required String pairId,
  }) async {
    try {
      final pairDoc = await _firestore.collection('pairs').doc(pairId).get();

      if (!pairDoc.exists) return;

      final pairData = pairDoc.data()!;
      final user1Id = pairData['user1Id'] as String;
      final user2Id = pairData['user2Id'] as String;

      // 相手のIDを取得
      final partnerId = userId == user1Id ? user2Id : user1Id;

      // 相手の今日の進捗を確認
      final partnerProgress = await _getTodayProgress(partnerId);

      if (partnerProgress < 100) {
        // 相手が未達成の場合、通知を送信
        await _sendPairReminderNotification(
          userId: userId,
          partnerProgress: partnerProgress,
        );
      }
    } catch (e, stack) {
      AppLogger().error(
        'Failed to check pair progress',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// 今日の進捗率を取得
  Future<int> _getTodayProgress(String userId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('quest_logs')
            .where('completedAt', isGreaterThanOrEqualTo: startOfDay)
            .get();

    // 簡易的な進捗計算
    final completedCount = snapshot.docs.length;
    const totalQuests = 10; // TODO: 実際のクエスト数を取得

    return ((completedCount / totalQuests) * 100).toInt();
  }

  /// ペアリマインド通知を送信
  Future<void> _sendPairReminderNotification({
    required String userId,
    required int partnerProgress,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pair_reminder',
      'ペアリマインド',
      channelDescription: 'ペアの進捗リマインド通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      userId.hashCode,
      'ペアからの応援',
      'ペアの進捗は$partnerProgress%です。一緒に頑張りましょう！',
      details,
    );

    AppLogger().info(
      'Pair reminder sent',
      data: {'userId': userId, 'partnerProgress': partnerProgress},
    );
  }
}
