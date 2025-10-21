import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:minq/data/repositories/pair_repository.dart';
import 'package:minq/data/repositories/user_repository.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/domain/pair/pair_reminder.dart';

/// ペア間の相互リマインド機能を提供するサービス
class PairReminderService {
  final PairRepository _pairRepository;
  final UserRepository _userRepository;
  final NotificationService _notificationService;
  final FirebaseFirestore _firestore;

  PairReminderService({
    required PairRepository pairRepository,
    required UserRepository userRepository,
    required NotificationService notificationService,
    FirebaseFirestore? firestore,
  }) : _pairRepository = pairRepository,
       _userRepository = userRepository,
       _notificationService = notificationService,
       _firestore = firestore ?? FirebaseFirestore.instance;

  /// ペアにリマインダーを送信
  Future<bool> sendReminderToPair({
    required String pairId,
    required String senderId,
    required ReminderType type,
    String? customMessage,
  }) async {
    try {
      final pair = await _pairRepository.getPairById(pairId);
      if (pair == null) return false;

      final receiverId = pair.user1Id == senderId ? pair.user2Id : pair.user1Id;
      if (receiverId == null) return false;

      final sender = await _userRepository.getUserById(senderId);
      final receiver = await _userRepository.getUserById(receiverId);

      if (sender == null || receiver == null) return false;

      final reminder = PairReminder(
        id: '',
        pairId: pairId,
        senderId: senderId,
        receiverId: receiverId,
        type: type,
        message: customMessage ?? _getDefaultMessage(type),
        sentAt: DateTime.now(),
        isRead: false,
      );

      // Firestoreにリマインダーを保存
      final docRef = await _firestore
          .collection('pair_reminders')
          .add(reminder.toJson());

      // プッシュ通知を送信
      await _sendReminderNotification(reminder.copyWith(id: docRef.id));

      return true;
    } catch (e) {
      debugPrint('Failed to send reminder to pair: $e');
      return false;
    }
  }

  /// 自動リマインダーをチェックして送信
  Future<void> checkAndSendAutoReminders() async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser?.pairId == null) return;

      final pair = await _pairRepository.getPairById(currentUser!.pairId!);
      if (pair == null) return;

      final partnerId =
          pair.user1Id == currentUser.uid ? pair.user2Id : pair.user1Id;
      if (partnerId == null) return;

      // パートナーの今日の進捗をチェック
      final partnerProgress = await _checkPartnerProgress(partnerId);

      // 条件に応じて自動リマインダーを送信
      if (_shouldSendAutoReminder(partnerProgress)) {
        await sendReminderToPair(
          pairId: currentUser.pairId!,
          senderId: currentUser.uid,
          type: ReminderType.encouragement,
        );
      }
    } catch (e) {
      debugPrint('Failed to check and send auto reminders: $e');
    }
  }

  /// ペアからのリマインダーを取得
  Future<List<PairReminder>> getRemindersForUser(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('pair_reminders')
              .where('receiverId', isEqualTo: userId)
              .where('isRead', isEqualTo: false)
              .orderBy('sentAt', descending: true)
              .limit(10)
              .get();

      return querySnapshot.docs
          .map((doc) => PairReminder.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      debugPrint('Failed to get reminders for user: $e');
      return [];
    }
  }

  /// リマインダーを既読にする
  Future<bool> markReminderAsRead(String reminderId) async {
    try {
      await _firestore.collection('pair_reminders').doc(reminderId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Failed to mark reminder as read: $e');
      return false;
    }
  }

  /// リマインダーの統計を取得
  Future<ReminderStats> getReminderStats(String userId) async {
    try {
      final sentQuery =
          await _firestore
              .collection('pair_reminders')
              .where('senderId', isEqualTo: userId)
              .get();

      final receivedQuery =
          await _firestore
              .collection('pair_reminders')
              .where('receiverId', isEqualTo: userId)
              .get();

      return ReminderStats(
        sentCount: sentQuery.docs.length,
        receivedCount: receivedQuery.docs.length,
        lastSentAt: _getLastReminderDate(sentQuery.docs, 'sentAt'),
        lastReceivedAt: _getLastReminderDate(receivedQuery.docs, 'sentAt'),
      );
    } catch (e) {
      debugPrint('Failed to get reminder stats: $e');
      return const ReminderStats(sentCount: 0, receivedCount: 0);
    }
  }

  /// パートナーの進捗をチェック
  Future<PartnerProgress> _checkPartnerProgress(String partnerId) async {
    // TODO: 実際の進捗データを取得する実装
    // 現在は仮のデータを返す
    return const PartnerProgress(
      completedToday: 0,
      totalQuests: 3,
      lastActiveAt: null,
    );
  }

  /// 自動リマインダーを送信すべきかチェック
  bool _shouldSendAutoReminder(PartnerProgress progress) {
    final now = DateTime.now();
    final cutoffTime = DateTime(now.year, now.month, now.day, 20, 0); // 20:00

    // 20時以降で、パートナーが今日まだクエストを完了していない場合
    if (now.isAfter(cutoffTime) && progress.completedToday == 0) {
      return true;
    }

    // パートナーが2日以上アクティブでない場合
    if (progress.lastActiveAt != null) {
      final daysSinceActive = now.difference(progress.lastActiveAt!).inDays;
      if (daysSinceActive >= 2) {
        return true;
      }
    }

    return false;
  }

  /// リマインダー通知を送信
  Future<void> _sendReminderNotification(PairReminder reminder) async {
    final title = _getReminderNotificationTitle(reminder.type);
    final body = reminder.message;

    await _notificationService.sendNotificationToUser(
      userId: reminder.receiverId,
      title: title,
      body: body,
      data: {
        'type': 'pair_reminder',
        'reminderId': reminder.id,
        'pairId': reminder.pairId,
      },
    );
  }

  /// デフォルトメッセージを取得
  String _getDefaultMessage(ReminderType type) {
    switch (type) {
      case ReminderType.encouragement:
        return '今日のクエスト、一緒に頑張りましょう！💪';
      case ReminderType.celebration:
        return 'お疲れさまでした！今日もよく頑張りましたね🎉';
      case ReminderType.checkIn:
        return '調子はどうですか？一緒に継続していきましょう😊';
      case ReminderType.motivation:
        return 'あなたならできます！応援しています🌟';
    }
  }

  /// リマインダー通知のタイトルを取得
  String _getReminderNotificationTitle(ReminderType type) {
    switch (type) {
      case ReminderType.encouragement:
        return 'ペアからの応援メッセージ';
      case ReminderType.celebration:
        return 'ペアからのお祝いメッセージ';
      case ReminderType.checkIn:
        return 'ペアからのチェックイン';
      case ReminderType.motivation:
        return 'ペアからの励ましメッセージ';
    }
  }

  /// 最後のリマインダー日時を取得
  DateTime? _getLastReminderDate(
    List<QueryDocumentSnapshot> docs,
    String field,
  ) {
    if (docs.isEmpty) return null;

    final lastDoc = docs.first;
    final timestamp = lastDoc.data() as Map<String, dynamic>;
    final fieldValue = timestamp[field];

    if (fieldValue is Timestamp) {
      return fieldValue.toDate();
    }

    return null;
  }
}

/// パートナーの進捗情報
class PartnerProgress {
  final int completedToday;
  final int totalQuests;
  final DateTime? lastActiveAt;

  const PartnerProgress({
    required this.completedToday,
    required this.totalQuests,
    this.lastActiveAt,
  });
}

/// リマインダー統計
class ReminderStats {
  final int sentCount;
  final int receivedCount;
  final DateTime? lastSentAt;
  final DateTime? lastReceivedAt;

  const ReminderStats({
    required this.sentCount,
    required this.receivedCount,
    this.lastSentAt,
    this.lastReceivedAt,
  });
}
