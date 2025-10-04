import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minq/core/logging/app_logger.dart';

/// 複数リマインダーサービス
class MultipleReminderService {
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _notifications;

  MultipleReminderService({
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? notifications,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  /// リマインダーを追加
  Future<void> addReminder({
    required String userId,
    required String questId,
    required TimeOfDay time,
  }) async {
    try {
      final reminderRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .collection('reminders')
          .doc();

      await reminderRef.set({
        'hour': time.hour,
        'minute': time.minute,
        'enabled': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 通知をスケジュール
      await _scheduleNotification(
        reminderId: reminderRef.id,
        questId: questId,
        time: time,
      );

      AppLogger.info('Reminder added', data: {
        'questId': questId,
        'time': '${time.hour}:${time.minute}',
      },);
    } catch (e, stack) {
      AppLogger.error('Failed to add reminder', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// リマインダーを削除
  Future<void> removeReminder({
    required String userId,
    required String questId,
    required String reminderId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .collection('reminders')
          .doc(reminderId)
          .delete();

      // 通知をキャンセル
      await _cancelNotification(reminderId);

      AppLogger.info('Reminder removed', data: {'reminderId': reminderId});
    } catch (e, stack) {
      AppLogger.error('Failed to remove reminder', error: e, stackTrace: stack);
      rethrow;
    }
  }


  /// リマインダーを取得
  Stream<List<Reminder>> getReminders(String userId, String questId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quests')
        .doc(questId)
        .collection('reminders')
        .orderBy('hour')
        .orderBy('minute')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Reminder(
          id: doc.id,
          hour: data['hour'] as int,
          minute: data['minute'] as int,
          enabled: data['enabled'] as bool? ?? true,
        );
      }).toList();
    });
  }

  /// リマインダーの有効/無効を切り替え
  Future<void> toggleReminder({
    required String userId,
    required String questId,
    required String reminderId,
    required bool enabled,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('quests')
          .doc(questId)
          .collection('reminders')
          .doc(reminderId)
          .update({'enabled': enabled});

      if (enabled) {
        // 通知を再スケジュール
        final doc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('quests')
            .doc(questId)
            .collection('reminders')
            .doc(reminderId)
            .get();

        final data = doc.data()!;
        await _scheduleNotification(
          reminderId: reminderId,
          questId: questId,
          time: TimeOfDay(
            hour: data['hour'] as int,
            minute: data['minute'] as int,
          ),
        );
      } else {
        // 通知をキャンセル
        await _cancelNotification(reminderId);
      }
    } catch (e, stack) {
      AppLogger.error('Failed to toggle reminder', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// 通知をスケジュール
  Future<void> _scheduleNotification({
    required String reminderId,
    required String questId,
    required TimeOfDay time,
  }) async {
    // TODO: 実装
    // flutter_local_notificationsを使用して通知をスケジュール
  }

  /// 通知をキャンセル
  Future<void> _cancelNotification(String reminderId) async {
    final notificationId = reminderId.hashCode;
    await _notifications.cancel(notificationId);
  }
}

/// リマインダーモデル
class Reminder {
  final String id;
  final int hour;
  final int minute;
  final bool enabled;

  Reminder({
    required this.id,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  String get displayTime {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// TimeOfDay（簡易実装）
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}
