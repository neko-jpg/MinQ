import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:minq/domain/notification/notification_sound_profile.dart';
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
  static const String _reminderChannelId = 'minq_reminders_v1';
  static const String _pairChannelId = 'minq_pair_v1';
  static const String _systemChannelId = 'minq_system_v1';

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
  bool _channelsInitialised = false;

  bool get _supportsLocalNotifications => !kIsWeb;

  Stream<String> get notificationTapStream => _tapController.stream;

  Future<String?> takeInitialPayload() async {
    final payload = _initialPayload;
    _initialPayload = null;
    return payload;
  }

  Future<String?> getReminderSoundProfileId() async {
    await _loadState();
    return _state.reminderSoundProfileId;
  }

  Future<void> updateReminderSoundProfile(String profileId) async {
    await _loadState();
    _state = _state.copyWith(reminderSoundProfileId: profileId);
    await _persistState();
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
      await _ensureAndroidChannels();
      _initialized = true;
    }
    return hasPermission();
  }

  Future<bool> hasPermission() async {
    if (!_supportsLocalNotifications) return false;
    final androidImplementation =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    // Add iOS check if needed
    return true; // Default for other platforms
  }

  Future<bool> shouldRequestPermission() async {
    if (await hasPermission()) return false;
    await _loadState();
    final lastAskedTimestamp = _state.permissionLastAskedTimestamp;
    if (lastAskedTimestamp == null) {
      return true; // Never asked before
    }
    final sevenDaysAgo =
        DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    return lastAskedTimestamp <
        sevenDaysAgo; // Ask again if it's been more than 7 days
  }

  Future<void> recordPermissionRequestTimestamp() async {
    await _loadState();
    _state = _state.copyWith(
      permissionLastAskedTimestamp: DateTime.now().millisecondsSinceEpoch,
    );
    await _persistState();
  }

  Future<bool> requestPermission() async {
    if (!_supportsLocalNotifications) {
      return false;
    }
    // This now directly requests permission from the OS.
    // It should be called after the user agrees on a custom dialog.
    final granted =
        await _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission() ??
        false;
    if (!granted) {
      await cancelAll();
    } else {
      await _ensureAndroidChannels();
    }
    return granted;
  }

  Future<void> scheduleRecurringReminders(List<String> times) async {
    if (!_supportsLocalNotifications || times.isEmpty) {
      return;
    }

    await _ensureAndroidChannels();
    await _loadState();

    final normalized = _normalizeTimes(times);
    final previousCount = _state.recurringReminderTimes.length;

    await _cancelRecurringReminders(max(previousCount, normalized.length));

    final notificationDetails = NotificationDetails(
      android: _androidDetailsForChannel(_reminderChannelId),
    );

    for (var index = 0; index < normalized.length; index++) {
      final parsed = _parseTime(normalized[index]);
      if (parsed == null) {
        continue;
      }
      final scheduledDate = _nextInstance(parsed.$1, parsed.$2);
      await _plugin.zonedSchedule(
        _recurringNotificationBaseId + index,
        _titleForIndex(index),
        _bodyForIndex(index),
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

        payload: _recordRoutePayload,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    _state = _state.copyWith(
      timezoneName: tz.local.name,
      recurringReminderTimes: normalized,
      suspended: false,
    );
    await _persistState();
  }

  Future<void> scheduleAuxiliaryReminder(String time) async {
    if (!_supportsLocalNotifications) {
      return;
    }

    await _ensureAndroidChannels();
    await _loadState();

    final parsed = _parseTime(time);
    if (parsed == null) {
      return;
    }

    final scheduledDate = _nextInstance(parsed.$1, parsed.$2);
    final isTooClose = _state.recurringReminderTimes.any((recurring) {
      final recurringParsed = _parseTime(recurring);
      if (recurringParsed == null) {
        return false;
      }
      final recurringDate = _nextInstance(
        recurringParsed.$1,
        recurringParsed.$2,
      );
      return (scheduledDate.difference(recurringDate)).abs() < _minimumGap;
    });

    if (isTooClose) {
      return;
    }

    await _plugin.zonedSchedule(
      _auxiliaryNotificationId,
      'もう一歩で達成です',
      '今日のミニクエストを記録して連続日数を伸ばしましょう。',
      scheduledDate,
      NotificationDetails(
        android: _androidDetailsForChannel(_reminderChannelId),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: _recordRoutePayload,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    _state = _state.copyWith(
      auxiliaryReminderTime:
          _ReminderTime(totalMinutes: parsed.$1 * 60 + parsed.$2).formatted,
      suspended: false,
    );
    await _persistState();
  }

  Future<void> _handleSnooze(String actionId, String? payload) async {
    if (!_supportsLocalNotifications) {
      return;
    }

    Duration? duration;
    switch (actionId) {
      case snoozeActionId_10m:
        duration = const Duration(minutes: 10);
        break;
      case snoozeActionId_1h:
        duration = const Duration(hours: 1);
        break;
      case snoozeActionId_1d:
        duration = const Duration(days: 1);
        break;
    }

    if (duration == null) {
      return;
    }

    await _plugin.zonedSchedule(
      _snoozeNotificationId,
      '後で再開しますか？',
      'タイマーを延長しました。覚えているうちに記録しましょう。',
      tz.TZDateTime.now(tz.local).add(duration),
      NotificationDetails(
        android: _androidDetailsForChannel(_reminderChannelId),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload ?? _recordRoutePayload,
    );
  }

  Future<void> cancelAuxiliaryReminder() async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await _plugin.cancel(_auxiliaryNotificationId);
    await _loadState();
    if (_state.auxiliaryReminderTime != null) {
      _state = _state.copyWith(auxiliaryReminderTime: null);
      await _persistState();
    }
  }

  Future<void> cancelAll() async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await _plugin.cancelAll();
    await _loadState();
    _state = _state.copyWith(
      recurringReminderTimes: const <String>[],
      auxiliaryReminderTime: null,
    );
    await _persistState();
  }

  Future<void> suspendForTimeDrift() async {
    if (!_supportsLocalNotifications) {
      return;
    }
    await _loadState();
    if (_state.suspended) {
      return;
    }
    await _cancelRecurringReminders(_state.recurringReminderTimes.length);
    await _plugin.cancel(_snoozeNotificationId);
    await cancelAuxiliaryReminder();
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

    final recurring = List<String>.from(_state.recurringReminderTimes);
    final auxiliary = _state.auxiliaryReminderTime;
    _state = _state.copyWith(suspended: false);
    await _persistState();

    if (recurring.isNotEmpty) {
      await scheduleRecurringReminders(recurring);
    }
    if (auxiliary != null) {
      await scheduleAuxiliaryReminder(auxiliary);
    }
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

    if (storedTimezone != currentTimezone) {
      final recurring =
          _state.recurringReminderTimes.isNotEmpty
              ? _state.recurringReminderTimes
              : (fallbackRecurring ?? const <String>[]);
      final auxiliary = _state.auxiliaryReminderTime ?? fallbackAuxiliary;

      _state = _state.copyWith(timezoneName: currentTimezone);
      await _persistState();

      if (recurring.isNotEmpty) {
        await scheduleRecurringReminders(recurring);
      }
      if (auxiliary != null) {
        await scheduleAuxiliaryReminder(auxiliary);
      }
      return;
    }

    if (_state.recurringReminderTimes.isEmpty &&
        (fallbackRecurring?.isNotEmpty ?? false)) {
      await scheduleRecurringReminders(fallbackRecurring!);
    }
    if (_state.auxiliaryReminderTime == null && fallbackAuxiliary != null) {
      await scheduleAuxiliaryReminder(fallbackAuxiliary);
    }
  }

  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    if (!_supportsLocalNotifications) {
      return;
    }

    await _ensureAndroidChannels();

    final channelId = _resolveChannelId(data);
    final androidDetails = _androidDetailsForChannel(channelId);
    final details = NotificationDetails(android: androidDetails);
    final payload = data != null ? data['route'] ?? '' : '';

    final notificationId =
        DateTime.now().millisecondsSinceEpoch % 1000000 +
        _auxiliaryNotificationId;

    await _plugin.show(notificationId, title, body, details, payload: payload);
  }

  Future<void> _ensureAndroidChannels() async {
    if (_channelsInitialised || !_supportsLocalNotifications) {
      return;
    }
    if (!Platform.isAndroid) {
      _channelsInitialised = true;
      return;
    }
    final androidPlugin =
        _plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin == null) {
      return;
    }
    const channels = <AndroidNotificationChannel>[
      AndroidNotificationChannel(
        _reminderChannelId,
        '習慣リマインダー',
        description: '毎日のクエストと補助的な通知をお届けします',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _pairChannelId,
        'ペア通知',
        description: 'ペアからの応援やメッセージをお知らせします',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        _systemChannelId,
        'システム通知',
        description: 'MinQからのお知らせや重要な案内です',
        importance: Importance.defaultImportance,
      ),
    ];

    for (final channel in channels) {
      await androidPlugin.createNotificationChannel(channel);
    }
    _channelsInitialised = true;
  }

  String _resolveChannelId(Map<String, String>? data) {
    final type = data?['type'] ?? data?['category'] ?? '';
    if (type == 'pair_reminder' || type == 'pair') {
      return _pairChannelId;
    }
    if (type == 'system') {
      return _systemChannelId;
    }
    return _reminderChannelId;
  }

  AndroidNotificationDetails _androidDetailsForChannel(String channelId) {
    switch (channelId) {
      case _pairChannelId:
        return const AndroidNotificationDetails(
          _pairChannelId,
          'ペア通知',
          channelDescription: 'ペアからの応援やメッセージをお知らせします',
          importance: Importance.high,
          priority: Priority.high,
        );
      case _systemChannelId:
        return const AndroidNotificationDetails(
          _systemChannelId,
          'システム通知',
          channelDescription: 'MinQからのお知らせや重要な案内です',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        );
      case _reminderChannelId:
      default:
        final profile = NotificationSoundProfile.byId(
          _state.reminderSoundProfileId,
        );
        final vibrationPattern =
            profile.vibrationPattern != null
                ? Int64List.fromList(profile.vibrationPattern!)
                : null;
        return AndroidNotificationDetails(
          _reminderChannelId,
          '習慣リマインダー',
          channelDescription: '毎日のクエストと補助的な通知をお届けします',
          importance: Importance.high,
          priority: Priority.high,
          playSound: profile.playSound,
          enableVibration: profile.enableVibration,
          vibrationPattern: vibrationPattern,
        );
    }
  }

  Future<void> _cancelRecurringReminders(int count) async {
    if (!_supportsLocalNotifications || count <= 0) {
      return;
    }
    for (var index = 0; index < count; index++) {
      await _plugin.cancel(_recurringNotificationBaseId + index);
    }
  }

  List<String> _normalizeTimes(List<String> times) {
    final seen = <int>{};
    final result = <_ReminderTime>[];
    for (final time in times) {
      final parsed = _parseTime(time);
      if (parsed == null) {
        continue;
      }
      final minutes = parsed.$1 * 60 + parsed.$2;
      if (seen.add(minutes)) {
        result.add(_ReminderTime(totalMinutes: minutes));
      }
    }
    result.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
    return result.map((time) => time.formatted).toList(growable: false);
  }

  (int, int)? _parseTime(String time) {
    final parts = time.split(':');
    if (parts.length != 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }
    return (hour, minute);
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
        return '朝のスタートを整えましょう';
      case 1:
        return '夕方の振り返りタイム';
      default:
        return '今日のクエストを記録しませんか？';
    }
  }

  String _bodyForIndex(int index) {
    switch (index) {
      case 0:
        return '最初の一歩で連続日数を伸ばすチャンスです。記録画面を開きましょう。';
      case 1:
        return '一日の終わりに成果を記録して、次の挑戦への勢いをつくりましょう。';
      default:
        return '今日の目標を達成したか確認して、習慣化を続けましょう。';
    }
  }

  Future<void> _loadState() async {
    if (_stateLoaded || !_supportsLocalNotifications) {
      return;
    }
    try {
      final directory = await getApplicationSupportDirectory();
      final file = File(p.join(directory.path, _storageFileName));
      final contents = await file.readAsString();
      final jsonMap = jsonDecode(contents) as Map<String, dynamic>;
      _state = _NotificationState.fromJson(jsonMap);
    } on FileSystemException {
      // Don't log, this is an expected condition on first run.
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
    this.permissionLastAskedTimestamp,
    this.reminderSoundProfileId = 'default',
  });

  final String? timezoneName;
  final List<String> recurringReminderTimes;
  final String? auxiliaryReminderTime;
  final bool suspended;
  final int? permissionLastAskedTimestamp;
  final String? reminderSoundProfileId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'timezone': timezoneName,
    'recurring': recurringReminderTimes,
    'auxiliary': auxiliaryReminderTime,
    'suspended': suspended,
    'permissionLastAskedTimestamp': permissionLastAskedTimestamp,
    'reminderSoundProfileId': reminderSoundProfileId,
  };

  _NotificationState copyWith({
    String? timezoneName,
    List<String>? recurringReminderTimes,
    String? auxiliaryReminderTime,
    bool? suspended,
    int? permissionLastAskedTimestamp,
    String? reminderSoundProfileId,
  }) {
    return _NotificationState(
      timezoneName: timezoneName ?? this.timezoneName,
      recurringReminderTimes:
          recurringReminderTimes ?? this.recurringReminderTimes,
      auxiliaryReminderTime:
          auxiliaryReminderTime ?? this.auxiliaryReminderTime,
      suspended: suspended ?? this.suspended,
      permissionLastAskedTimestamp:
          permissionLastAskedTimestamp ?? this.permissionLastAskedTimestamp,
      reminderSoundProfileId:
          reminderSoundProfileId ?? this.reminderSoundProfileId,
    );
  }

  factory _NotificationState.fromJson(Map<String, dynamic> json) {
    return _NotificationState(
      timezoneName: json['timezone'] as String?,
      recurringReminderTimes:
          (json['recurring'] as List<dynamic>?)
              ?.map((dynamic value) => value as String)
              .toList(growable: false) ??
          const <String>[],
      auxiliaryReminderTime: json['auxiliary'] as String?,
      suspended: json['suspended'] as bool? ?? false,
      permissionLastAskedTimestamp:
          json['permissionLastAskedTimestamp'] as int?,
      reminderSoundProfileId:
          json['reminderSoundProfileId'] as String? ?? 'default',
    );
  }
}
