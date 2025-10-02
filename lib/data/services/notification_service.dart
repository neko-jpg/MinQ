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
    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
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
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7)).millisecondsSinceEpoch;
    return lastAskedTimestamp < sevenDaysAgo; // Ask again if it's been more than 7 days
  }

  Future<void> recordPermissionRequestTimestamp() async {
    await _loadState();
    _state = _state.copyWith(permissionLastAskedTimestamp: DateTime.now().millisecondsSinceEpoch);
    await _persistState();
  }

  Future<bool> requestPermission() async {
    if (!_supportsLocalNotifications) {
      return false;
    }
    // This now directly requests permission from the OS.
    // It should be called after the user agrees on a custom dialog.
    final granted = await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission() ?? false;
    if (!granted) {
      await cancelAll();
    } else {
      await _ensureAndroidChannels();
    }
    return granted;
  }

  Future<void> scheduleRecurringReminders(List<String> times) async {
    // ... (existing implementation)
  }

  Future<void> scheduleAuxiliaryReminder(String time) async {
    // ... (existing implementation)
  }

  Future<void> _handleSnooze(String actionId, String? payload) async {
    // ... (existing implementation)
  }

  Future<void> cancelAuxiliaryReminder() async {
    // ... (existing implementation)
  }

  Future<void> cancelAll() async {
    // ... (existing implementation)
  }

  Future<void> suspendForTimeDrift() async {
    // ... (existing implementation)
  }

  Future<void> resumeFromTimeDrift() async {
    // ... (existing implementation)
  }

  Future<void> ensureTimezoneConsistency({
    List<String>? fallbackRecurring,
    String? fallbackAuxiliary,
  }) async {
    // ... (existing implementation)
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
        DateTime.now().millisecondsSinceEpoch % 1000000 + _auxiliaryNotificationId;

    await _plugin.show(
      notificationId,
      title,
      body,
      details,
      payload: payload,
    );
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
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
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
        return const AndroidNotificationDetails(
          _reminderChannelId,
          '習慣リマインダー',
          channelDescription: '毎日のクエストと補助的な通知をお届けします',
          importance: Importance.high,
          priority: Priority.high,
        );
    }
  }

  Future<void> _cancelRecurringReminders() async {
    // ... (existing implementation)
  }

  List<String> _normalizeTimes(List<String> times) {
    // ... (existing implementation)
  }

  (int, int)? _parseTime(String time) {
    // ... (existing implementation)
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    // ... (existing implementation)
  }

  String _titleForIndex(int index) {
    // ... (existing implementation)
  }

  String _bodyForIndex(int index) {
    // ... (existing implementation)
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
    this.permissionLastAskedTimestamp,
  });

  final String? timezoneName;
  final List<String> recurringReminderTimes;
  final String? auxiliaryReminderTime;
  final bool suspended;
  final int? permissionLastAskedTimestamp;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'timezone': timezoneName,
        'recurring': recurringReminderTimes,
        'auxiliary': auxiliaryReminderTime,
        'suspended': suspended,
        'permissionLastAskedTimestamp': permissionLastAskedTimestamp,
      };

  _NotificationState copyWith({
    String? timezoneName,
    List<String>? recurringReminderTimes,
    String? auxiliaryReminderTime,
    bool? suspended,
    int? permissionLastAskedTimestamp,
  }) {
    return _NotificationState(
      timezoneName: timezoneName ?? this.timezoneName,
      recurringReminderTimes:
          recurringReminderTimes ?? this.recurringReminderTimes,
      auxiliaryReminderTime: auxiliaryReminderTime ?? this.auxiliaryReminderTime,
      suspended: suspended ?? this.suspended,
      permissionLastAskedTimestamp: permissionLastAskedTimestamp ?? this.permissionLastAskedTimestamp,
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
      permissionLastAskedTimestamp: json['permissionLastAskedTimestamp'] as int?,
    );
  }
}