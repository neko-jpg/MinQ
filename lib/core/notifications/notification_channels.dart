import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 通知チャンネルID
class NotificationChannelId {
  const NotificationChannelId._();

  /// 重要な通知（クエスト完了リマインダー）
  static const String important = 'important_notifications';

  /// 通常の通知（一般的なリマインダー）
  static const String normal = 'normal_notifications';

  /// 低優先度の通知（統計レポート）
  static const String low = 'low_notifications';

  /// ペア関連の通知
  static const String pair = 'pair_notifications';

  /// システム通知
  static const String system = 'system_notifications';
}

/// 通知チャンネル設定
class NotificationChannels {
  const NotificationChannels._();

  /// 重要な通知チャンネル
  static const AndroidNotificationChannel important = AndroidNotificationChannel(
    NotificationChannelId.important,
    '重要な通知',
    description: 'クエスト完了のリマインダーなど、重要な通知を受け取ります',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    showBadge: true,
  );

  /// 通常の通知チャンネル
  static const AndroidNotificationChannel normal = AndroidNotificationChannel(
    NotificationChannelId.normal,
    '通常の通知',
    description: '一般的なリマインダーや更新情報を受け取ります',
    importance: Importance.defaultImportance,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// 低優先度の通知チャンネル
  static const AndroidNotificationChannel low = AndroidNotificationChannel(
    NotificationChannelId.low,
    '低優先度の通知',
    description: '統計レポートやヒントなど、緊急性の低い通知を受け取ります',
    importance: Importance.low,
    playSound: false,
    enableVibration: false,
    showBadge: false,
  );

  /// ペア関連の通知チャンネル
  static const AndroidNotificationChannel pair = AndroidNotificationChannel(
    NotificationChannelId.pair,
    'ペア通知',
    description: 'ペアからのメッセージや進捗更新を受け取ります',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    enableLights: true,
    showBadge: true,
  );

  /// システム通知チャンネル
  static const AndroidNotificationChannel system = AndroidNotificationChannel(
    NotificationChannelId.system,
    'システム通知',
    description: 'アプリの更新やメンテナンス情報を受け取ります',
    importance: Importance.defaultImportance,
    playSound: false,
    enableVibration: false,
    showBadge: false,
  );

  /// 全チャンネルのリスト
  static const List<AndroidNotificationChannel> all = [
    important,
    normal,
    low,
    pair,
    system,
  ];
}

/// iOS通知カテゴリー
class IOSNotificationCategory {
  const IOSNotificationCategory._();

  /// クエスト完了アクション付き
  static const String questCompletion = 'QUEST_COMPLETION';

  /// ペアメッセージアクション付き
  static const String pairMessage = 'PAIR_MESSAGE';

  /// スヌーズアクション付き
  static const String snooze = 'SNOOZE';
}

/// 通知アクション
class NotificationAction {
  final String id;
  final String title;
  final bool requiresAuthentication;
  final bool destructive;

  const NotificationAction({
    required this.id,
    required this.title,
    this.requiresAuthentication = false,
    this.destructive = false,
  });

  /// 完了アクション
  static const complete = NotificationAction(
    id: 'complete',
    title: '完了',
  );

  /// スヌーズアクション
  static const snooze = NotificationAction(
    id: 'snooze',
    title: 'スヌーズ',
  );

  /// 表示アクション
  static const view = NotificationAction(
    id: 'view',
    title: '表示',
  );

  /// 返信アクション
  static const reply = NotificationAction(
    id: 'reply',
    title: '返信',
  );

  /// 削除アクション
  static const dismiss = NotificationAction(
    id: 'dismiss',
    title: '削除',
    destructive: true,
  );
}

/// 通知カテゴリー設定
class NotificationCategoryConfig {
  final String identifier;
  final List<NotificationAction> actions;
  final String? hiddenPreviewsBodyPlaceholder;

  const NotificationCategoryConfig({
    required this.identifier,
    required this.actions,
    this.hiddenPreviewsBodyPlaceholder,
  });

  /// クエスト完了カテゴリー
  static const questCompletion = NotificationCategoryConfig(
    identifier: IOSNotificationCategory.questCompletion,
    actions: [
      NotificationAction.complete,
      NotificationAction.snooze,
    ],
    hiddenPreviewsBodyPlaceholder: 'クエストのリマインダー',
  );

  /// ペアメッセージカテゴリー
  static const pairMessage = NotificationCategoryConfig(
    identifier: IOSNotificationCategory.pairMessage,
    actions: [
      NotificationAction.reply,
      NotificationAction.view,
    ],
    hiddenPreviewsBodyPlaceholder: 'ペアからのメッセージ',
  );

  /// スヌーズカテゴリー
  static const snooze = NotificationCategoryConfig(
    identifier: IOSNotificationCategory.snooze,
    actions: [
      NotificationAction.snooze,
      NotificationAction.dismiss,
    ],
  );

  /// 全カテゴリーのリスト
  static const List<NotificationCategoryConfig> all = [
    questCompletion,
    pairMessage,
    snooze,
  ];
}

/// 通知優先度
enum NotificationPriority {
  /// 最高優先度
  max,

  /// 高優先度
  high,

  /// 通常
  normal,

  /// 低優先度
  low,

  /// 最低優先度
  min,
}

/// 通知設定ヘルパー
class NotificationSettingsHelper {
  const NotificationSettingsHelper._();

  /// Android通知の詳細設定を取得
  static AndroidNotificationDetails getAndroidDetails({
    required String channelId,
    String? channelName,
    String? channelDescription,
    NotificationPriority priority = NotificationPriority.normal,
    bool playSound = true,
    bool enableVibration = true,
    bool enableLights = true,
    String? sound,
    List<int>? vibrationPattern,
    String? largeIcon,
    String? styleInformation,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName ?? channelId,
      channelDescription: channelDescription,
      importance: _getImportance(priority),
      priority: _getPriority(priority),
      playSound: playSound,
      enableVibration: enableVibration,
      enableLights: enableLights,
      sound: sound != null ? RawResourceAndroidNotificationSound(sound) : null,
      vibrationPattern: vibrationPattern,
      largeIcon: largeIcon != null ? DrawableResourceAndroidBitmap(largeIcon) : null,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// iOS通知の詳細設定を取得
  static DarwinNotificationDetails getIOSDetails({
    String? sound,
    bool presentAlert = true,
    bool presentBadge = true,
    bool presentSound = true,
    String? categoryIdentifier,
    String? threadIdentifier,
    List<DarwinNotificationAttachment>? attachments,
  }) {
    return DarwinNotificationDetails(
      sound: sound,
      presentAlert: presentAlert,
      presentBadge: presentBadge,
      presentSound: presentSound,
      categoryIdentifier: categoryIdentifier,
      threadIdentifier: threadIdentifier,
      attachments: attachments,
    );
  }

  /// 優先度からImportanceに変換
  static Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.max:
        return Importance.max;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.min:
        return Importance.min;
    }
  }

  /// 優先度からPriorityに変換
  static Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.max:
        return Priority.max;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.min:
        return Priority.min;
    }
  }
}

/// 通知スタイル
enum NotificationStyle {
  /// デフォルト
  defaultStyle,

  /// 大きいテキスト
  bigText,

  /// 大きい画像
  bigPicture,

  /// インボックス（複数行）
  inbox,

  /// メッセージング
  messaging,

  /// 進捗バー
  progress,
}

/// 通知グループ
class NotificationGroup {
  const NotificationGroup._();

  /// クエスト関連
  static const String quests = 'quests';

  /// ペア関連
  static const String pairs = 'pairs';

  /// 統計関連
  static const String stats = 'stats';

  /// システム関連
  static const String system = 'system';
}

/// まとめ通知の設定
class SummaryNotificationConfig {
  final String groupKey;
  final String summaryTitle;
  final String summaryBody;
  final int notificationCount;

  const SummaryNotificationConfig({
    required this.groupKey,
    required this.summaryTitle,
    required this.summaryBody,
    required this.notificationCount,
  });

  /// クエストのまとめ通知
  static SummaryNotificationConfig quests(int count) {
    return SummaryNotificationConfig(
      groupKey: NotificationGroup.quests,
      summaryTitle: 'クエストリマインダー',
      summaryBody: '$count件の未完了クエストがあります',
      notificationCount: count,
    );
  }

  /// ペアのまとめ通知
  static SummaryNotificationConfig pairs(int count) {
    return SummaryNotificationConfig(
      groupKey: NotificationGroup.pairs,
      summaryTitle: 'ペアからのメッセージ',
      summaryBody: '$count件の新しいメッセージがあります',
      notificationCount: count,
    );
  }
}

/// 通知スケジュール
class NotificationSchedule {
  final DateTime scheduledTime;
  final Duration? repeatInterval;
  final bool exactTiming;

  const NotificationSchedule({
    required this.scheduledTime,
    this.repeatInterval,
    this.exactTiming = false,
  });

  /// 毎日の通知
  static NotificationSchedule daily(DateTime time) {
    return NotificationSchedule(
      scheduledTime: time,
      repeatInterval: const Duration(days: 1),
    );
  }

  /// 毎週の通知
  static NotificationSchedule weekly(DateTime time) {
    return NotificationSchedule(
      scheduledTime: time,
      repeatInterval: const Duration(days: 7),
    );
  }

  /// 1回限りの通知
  static NotificationSchedule once(DateTime time) {
    return NotificationSchedule(
      scheduledTime: time,
    );
  }

  /// カスタム間隔の通知
  static NotificationSchedule custom({
    required DateTime time,
    required Duration interval,
  }) {
    return NotificationSchedule(
      scheduledTime: time,
      repeatInterval: interval,
    );
  }
}
