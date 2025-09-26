import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({String storageFileName = 'notification_state.json'})
      : _storageFileName = storageFileName;

  static const List<String> defaultReminderTimes = ['07:30', '18:30', '21:30'];
  static const int _recurringNotificationBaseId = 200;
  static const int _auxiliaryNotificationId = 300;
  static const int _snoozeNotificationId = 400;
  static const String _recordRoutePayload = '/record';
  static const Duration _minimumGap = Duration(minutes: 10);

  static const String snoozeActionId_10m = 'snooze_10m';
  static const String snoozeActionId_1h = 'snooze_1h';
  static const String snoozeActionId_1d = 'snooze_1d';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<String> _tapController =
      StreamController<String>.broadcast();
  final String _storageFileName;

  bool _initialized = false;
  String? _initialPayload;
  _NotificationState _state = const _NotificationState();
  bool _stateLoaded = false;

  bool get _supportsLocalNotifications => !kIsWeb;

  Stream<String> get notificationTapStream => _tapController.stream;

  Future<String?> takeInitialPayload() async {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  Future<bool> init() async {
    if (!_supportsLocalNotifications) {
      return false;
    }

    if (!_initialized) {
      tz.initializeTimeZones();
      await _loadState();
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      _initialPayload = launchDetails?.notificationResponse?.payload;

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initializationSettings = InitializationSettings(
        android: androidSettings,
      );
      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          if (details.actionId != null &&
              details.actionId!.startsWith('snooze')) {
            _handleSnooze(details.actionId!, details.payload);
          } else {
            final payload = details.payload;
            if (payload != null && payload.isNotEmpty) {
              _tapController.add(payload);
            }
          }
        },
      );
      _initialized = true;
    }
    final granted = await requestPermission();
    if (!granted) {
      await cancelAll();
    }
    return granted;
  }

  Future<bool> requestPermission() async {
    if (!_supportsLocalNotifications) {
      return false;
    }

    bool granted = true;

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidImplementation != null) {
      final enabled = await androidImplementation.areNotificationsEnabled();
      if (enabled != null) {
        granted = granted && enabled;
      }
    }

    final iosImplementation = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (iosImplementation != null) {
      final iosGranted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (iosGranted != null) {
        granted = granted && iosGranted;
      }
    }

    return granted;
  }

  Future<void> scheduleRecurringReminders(List<String> times) async {
    if (!_supportsLocalNotifications) {
      return;
    }

    await _loadState();
    final normalizedTimes = _normalizeTimes(times);

    await _cancelRecurringReminders();
    for (var index = 0; index < normalizedTimes.length; index++) {
      final parsed = _parseTime(normalizedTimes[index]);
      if (parsed == null) continue;

      await _plugin.zonedSchedule(
        _recurringNotificationBaseId + index,
        _titleForIndex(index),
        _bodyForIndex(index),
        _nextInstance(parsed.$1, parsed.$2),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'minq_daily_channel',
            'MinQ 毎日のリマインダー',
            channelDescription: '続けやすいタイミングでミニクエをお知らせします。',
            importance: Importance.high,
            priority: Priority.high,
            actions: [
              AndroidNotificationAction(snoozeActionId_10m, '+10分'),
              AndroidNotificationAction(snoozeActionId_1h, '+1時間'),
              AndroidNotificationAction(snoozeActionId_1d, '明日'),
            ],
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: _recordRoutePayload,
      );
    }

    _state = _state.copyWith(
      timezoneName: tz.local.name,
      recurringReminderTimes: normalizedTimes,
      suspended: false,
    );
    await _persistState();
  }

  Future<void> scheduleAuxiliaryReminder(String time) async {
    if (!_supportsLocalNotifications) {
      return;
    }

    final parsed = _parseTime(time);
    if (parsed == null) return;

    await _plugin.zonedSchedule(
      _auxiliaryNotificationId,
      'あと1つだけやってみよう',
      '今日のミニQuestがまだなら、今こそHigh-fiveをもらいにいこう。',
      _nextInstance(parsed.$1, parsed.$2),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'minq_aux_channel',
          'MinQ 追いリマインダー',
          channelDescription: '未完了のときだけ届く補助リマインダーです。',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: _recordRoutePayload,
    );

    await _loadState();
    _state = _state.copyWith(
      timezoneName: tz.local.name,
      auxiliaryReminderTime: time,
      suspended: false,
    );
    await _persistState();
  }

  Future<void> _handleSnooze(String actionId, String? payload) async {
    Duration snoozeDuration;
    switch (actionId) {
      case snoozeActionId_10m:
        snoozeDuration = const Duration(minutes: 10);
        break;
      case snoozeActionId_1h:
        snoozeDuration = const Duration(hours: 1);
        break;
      case snoozeActionId_1d:
        snoozeDuration = const Duration(days: 1);
        break;
      default:
        return;
    }

    final snoozedTime = tz.TZDateTime.now(tz.local).add(snoozeDuration);

    await _plugin.zonedSchedule(
      _snoozeNotificationId,
      'Snoozed: MinQからのお知らせ',
      '時間になりました。ミニQuestをRecordしましょう。',
      snoozedTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'minq_snooze_channel',
          'MinQ スヌーズしたリマインダー',
          channelDescription: 'スヌーズしたリマインダーです。',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancelAuxiliaryReminder() async {
    if (!_supportsLocalNotifications) {
      return;
    }

    await _plugin.cancel(_auxiliaryNotificationId);
    await _loadState();
    _state = _state.copyWith(auxiliaryReminderTime: null);
    await _persistState();
  }

  Future<void> cancelAll() async {
    if (!_supportsLocalNotifications) {
      return;
    }

    await _plugin.cancelAll();
  }

  Future<void> suspendForTimeDrift() async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await cancelAll();
    await _loadState();
    _state = _state.copyWith(suspended: true);
    await _persistState();
  }

  Future<void> resumeFromTimeDrift() async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await _loadState();
    if (!_state.suspended) {
      return;
    }

    final recurring = _state.recurringReminderTimes;
    if (recurring.isNotEmpty) {
      await scheduleRecurringReminders(recurring);
    }
    final auxiliary = _state.auxiliaryReminderTime;
    if (auxiliary != null && auxiliary.isNotEmpty) {
      await scheduleAuxiliaryReminder(auxiliary);
    }
    _state = _state.copyWith(suspended: false);
    await _persistState();
  }

  Future<void> ensureTimezoneConsistency({
    List<String>? fallbackRecurring,
    String? fallbackAuxiliary,
  }) async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await _loadState();
    final currentTimezone = tz.local.name;
    final storedTimezone = _state.timezoneName;
    if (storedTimezone == null) {
      _state = _state.copyWith(timezoneName: currentTimezone);
      await _persistState();
      return;
    }

    if (storedTimezone != currentTimezone) {
      final recurring = _state.recurringReminderTimes.isNotEmpty
          ? _state.recurringReminderTimes
          : (fallbackRecurring ?? const <String>[]);
      final auxiliary =
          _state.auxiliaryReminderTime ?? fallbackAuxiliary;

      if (recurring.isNotEmpty) {
        await scheduleRecurringReminders(recurring);
      }
      if (auxiliary != null && auxiliary.isNotEmpty) {
        await scheduleAuxiliaryReminder(auxiliary);
      }
    }
  }

  Future<void> _cancelRecurringReminders() async {
    if (!_supportsLocalNotifications) {
      return;
    }

    for (var index = 0; index < 3; index++) {
      await _plugin.cancel(_recurringNotificationBaseId + index);
    }
  }

  List<String> _normalizeTimes(List<String> times) {
    final sanitized = <_ReminderTime>[];
    for (final time in times) {
      final parsed = _parseTime(time);
      if (parsed == null) continue;
      final totalMinutes = parsed.$1 * 60 + parsed.$2;
      final hasConflict = sanitized.any((existing) =>
          (existing.totalMinutes - totalMinutes).abs() <=
          _minimumGap.inMinutes);
      if (hasConflict) {
        continue;
      }
      sanitized.add(_ReminderTime(totalMinutes: totalMinutes));
    }
    sanitized.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    return sanitized.map((entry) => entry.formatted).toList(growable: false);
  }

  (int, int)? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    final normalizedHour = hour.clamp(0, 23).toInt();
    final normalizedMinute = minute.clamp(0, 59).toInt();
    return (normalizedHour, normalizedMinute);
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return '朝一番のミニクエ時間';
      case 1:
        return '昼下がりのリセット';
      case 2:
        return 'おやすみ前の振り返り';
      default:
        return 'MinQからのお知らせ';
    }
  }

  String _bodyForIndex(int index) {
    switch (index) {
      case 0:
        return '最初のミニクエで勢いをつけましょう。まずは1分でOK！';
      case 1:
        return '小さなタスクで午後の集中力を取り戻しましょう。';
      case 2:
        return '今日のRecordをまとめて、ストリークを伸ばそう。';
      default:
        return 'ミニQuestを続けて、PairにHigh-fiveを送りましょう。';
    }
  }

  Future<void> _loadState() async {
    if (_stateLoaded || !_supportsLocalNotifications) {
      return;
    }
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, _storageFileName));
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonMap = jsonDecode(contents) as Map<String, dynamic>;
        _state = _NotificationState.fromJson(jsonMap);
      }
    } catch (error) {
      debugPrint('Failed to load notification state: $error');
    }
    _stateLoaded = true;
  }

  Future<void> _persistState() async {
    if (!_supportsLocalNotifications) {
      return;
    }
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, _storageFileName));
      await file.create(recursive: true);
      await file.writeAsString(jsonEncode(_state.toJson()));
    } catch (error) {
      debugPrint('Failed to persist notification state: $error');
    }
  }
}

class _ReminderTime {
  _ReminderTime({required this.totalMinutes});

  final int totalMinutes;

  String get formatted {
    final hour = totalMinutes ~/ 60;
    final minute = totalMinutes % 60;
    final hourString = hour.toString().padLeft(2, '0');
    final minuteString = minute.toString().padLeft(2, '0');
    return '$hourString:$minuteString';
  }
}

class _NotificationState {
  const _NotificationState({
    this.timezoneName,
    this.recurringReminderTimes = const <String>[],
    this.auxiliaryReminderTime,
    this.suspended = false,
  });

  final String? timezoneName;
  final List<String> recurringReminderTimes;
  final String? auxiliaryReminderTime;
  final bool suspended;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timezone': timezoneName,
        'recurring': recurringReminderTimes,
        'auxiliary': auxiliaryReminderTime,
        'suspended': suspended,
      };

  _NotificationState copyWith({
    String? timezoneName,
    List<String>? recurringReminderTimes,
    String? auxiliaryReminderTime,
    bool? suspended,
  }) {
    return _NotificationState(
      timezoneName: timezoneName ?? this.timezoneName,
      recurringReminderTimes:
          recurringReminderTimes ?? this.recurringReminderTimes,
      auxiliaryReminderTime: auxiliaryReminderTime ?? this.auxiliaryReminderTime,
      suspended: suspended ?? this.suspended,
    );
  }

  factory _NotificationState.fromJson(Map<String, dynamic> json) {
    return _NotificationState(
      timezoneName: json['timezone'] as String?,
      recurringReminderTimes: (json['recurring'] as List<dynamic>?)
              ?.map((dynamic value) => value as String)
              .toList(growable: false) ??
          const <String>[],
      auxiliaryReminderTime: json['auxiliary'] as String?,
      suspended: json['suspended'] as bool? ?? false,
    );
  }
}
