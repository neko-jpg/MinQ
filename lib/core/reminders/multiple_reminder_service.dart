import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// 複数リマインダーサービス
class MultipleReminderService {
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _notifications;

  static const AndroidNotificationChannel _reminderChannel =
      AndroidNotificationChannel(
        'minq_multi_reminder_v1',
        'Quest reminders',
        description: '習慣クエスト向けの個別リマインダー',
        importance: Importance.high,
      );

  static bool _timezoneInitialized = false;
  static bool _notificationsInitialized = false;

  MultipleReminderService({
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? notifications,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  CollectionReference<Map<String, dynamic>> _reminderCollection(
    String userId,
    String questId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quests')
        .doc(questId)
        .collection('reminders');
  }

  /// リマインダーを追加
  Future<void> addReminder({
    required String userId,
    required String questId,
    required TimeOfDay time,
  }) async {
    try {
      final reminderRef = _reminderCollection(userId, questId).doc();

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

      logger.info(
        'Reminder added',
      );
    } catch (e, stack) {
      logger.error('Failed to add reminder', e, stack);
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
      await _reminderCollection(userId, questId).doc(reminderId).delete();

      // 通知をキャンセル
      await _cancelNotification(reminderId);

      logger.info('Reminder removed');
    } catch (e, stack) {
      logger.error('Failed to remove reminder', e, stack);
      rethrow;
    }
  }

  /// リマインダーを取得
  Stream<List<Reminder>> getReminders(String userId, String questId) {
    return _reminderCollection(
      userId,
      questId,
    ).orderBy('hour').orderBy('minute').snapshots().map((snapshot) {
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
      await _reminderCollection(
        userId,
        questId,
      ).doc(reminderId).update({'enabled': enabled});

      if (enabled) {
        // 通知を再スケジュール
        final doc =
            await _reminderCollection(userId, questId).doc(reminderId).get();

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
      logger.error('Failed to toggle reminder', e, stack);
      rethrow;
    }
  }

  Future<void> saveReminders({
    required String userId,
    required String questId,
    required List<ReminderDraft> reminders,
  }) async {
    try {
      final collection = _reminderCollection(userId, questId);
      final snapshot = await collection.get();
      final existing = <String, Map<String, dynamic>>{
        for (final doc in snapshot.docs) doc.id: doc.data(),
      };

      final draftsById = {
        for (final draft in reminders)
          if (draft.id != null) draft.id!: draft,
      };

      for (final entry in existing.entries) {
        final id = entry.key;
        if (!draftsById.containsKey(id)) {
          await collection.doc(id).delete();
          await _cancelNotification(id);
        }
      }

      for (final draft in reminders) {
        if (draft.id == null) {
          final doc = collection.doc();
          await doc.set({
            'hour': draft.time.hour,
            'minute': draft.time.minute,
            'enabled': draft.enabled,
            'createdAt': FieldValue.serverTimestamp(),
          });
          if (draft.enabled) {
            await _scheduleNotification(
              reminderId: doc.id,
              questId: questId,
              time: draft.time,
            );
          } else {
            await _cancelNotification(doc.id);
          }
          continue;
        }

        final docRef = collection.doc(draft.id);
        final previous = existing[draft.id];

        if (previous == null) {
          await docRef.set({
            'hour': draft.time.hour,
            'minute': draft.time.minute,
            'enabled': draft.enabled,
            'createdAt': FieldValue.serverTimestamp(),
          });
          if (draft.enabled) {
            await _scheduleNotification(
              reminderId: draft.id!,
              questId: questId,
              time: draft.time,
            );
          } else {
            await _cancelNotification(draft.id!);
          }
          continue;
        }

        final prevHour = previous['hour'] as int? ?? 0;
        final prevMinute = previous['minute'] as int? ?? 0;
        final prevEnabled = previous['enabled'] as bool? ?? true;

        final shouldUpdateTime =
            prevHour != draft.time.hour || prevMinute != draft.time.minute;
        final shouldUpdateEnabled = prevEnabled != draft.enabled;

        if (shouldUpdateTime || shouldUpdateEnabled) {
          final updates = <String, dynamic>{};
          if (shouldUpdateTime) {
            updates['hour'] = draft.time.hour;
            updates['minute'] = draft.time.minute;
          }
          if (shouldUpdateEnabled) {
            updates['enabled'] = draft.enabled;
          }
          if (updates.isNotEmpty) {
            await docRef.update(updates);
          }

          await _cancelNotification(draft.id!);
          if (draft.enabled) {
            await _scheduleNotification(
              reminderId: draft.id!,
              questId: questId,
              time: draft.time,
            );
          }
        }
      }

      logger.info(
        'Reminders saved',
      );
    } catch (e, stack) {
      logger.error('Failed to save reminders', e, stack);
      rethrow;
    }
  }

  /// 通知をスケジュール
  Future<void> _scheduleNotification({
    required String reminderId,
    required String questId,
    required TimeOfDay time,
  }) async {
    try {
      await _ensureNotificationsInitialised();

      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      if (!scheduledDate.isAfter(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final notificationId = reminderId.hashCode;

      await _notifications.zonedSchedule(
        notificationId,
        'クエストを記録する時間です',
        '「$questId」のクエストを進めましょう。',
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _reminderChannel.id,
            _reminderChannel.name,
            channelDescription: _reminderChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: questId,
      );
    } catch (e, stack) {
      logger.warning(
        'Failed to schedule reminder notification',
        e,
        stack,
      );
    }
  }

  /// 通知をキャンセル
  Future<void> _cancelNotification(String reminderId) async {
    try {
      final notificationId = reminderId.hashCode;
      await _notifications.cancel(notificationId);
    } catch (e, stack) {
      logger.warning(
        'Failed to cancel reminder notification',
        e,
        stack,
      );
    }
  }

  Future<void> _ensureNotificationsInitialised() async {
    if (!_timezoneInitialized) {
      tz.initializeTimeZones();
      _timezoneInitialized = true;
    }

    if (_notificationsInitialized) {
      return;
    }

    try {
      const initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _notifications.initialize(initializationSettings);

      final android =
          _notifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await android?.createNotificationChannel(_reminderChannel);
    } catch (e, stack) {
      logger.warning(
        'Failed to initialise notifications for reminders',
        e,
        stack,
      );
    }

    _notificationsInitialized = true;
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

  ReminderDraft toDraft() =>
      ReminderDraft(id: id, time: time, enabled: enabled);
}

class ReminderDraft {
  const ReminderDraft({this.id, required this.time, required this.enabled});

  final String? id;
  final TimeOfDay time;
  final bool enabled;
}
