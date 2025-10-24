import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:minq/core/logging/app_logger.dart';

/// FCMトピックサービス
/// プッシュ通知のトピック管理
class TopicService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// すべてのユーザー向けトピック
  static const String topicAllUsers = 'all_users';

  /// ニュース・お知らせトピック
  static const String topicNews = 'news';

  /// 週次まとめトピック
  static const String topicWeeklySummary = 'weekly_summary';

  /// デイリーリマインダートピック
  static const String topicDailyReminder = 'daily_reminder';

  /// アップデート情報トピック
  static const String topicUpdates = 'updates';

  /// イベント情報トピック
  static const String topicEvents = 'events';

  /// プレミアムユーザー向けトピック
  static const String topicPremium = 'premium_users';

  /// 初期トピックに登録
  Future<void> subscribeToDefaultTopics() async {
    await subscribeToTopic(topicAllUsers);
    await subscribeToTopic(topicNews);
    logger.info('✅ Subscribed to default topics');
  }

  /// トピックに登録
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      logger.info('✅ Subscribed to topic: $topic');
    } catch (e) {
      logger.error('❌ Failed to subscribe to topic $topic: $e');
    }
  }

  /// トピックから登録解除
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      logger.info('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      logger.error('❌ Failed to unsubscribe from topic $topic: $e');
    }
  }

  /// 週次まとめ通知を有効化
  Future<void> enableWeeklySummary() async {
    await subscribeToTopic(topicWeeklySummary);
  }

  /// 週次まとめ通知を無効化
  Future<void> disableWeeklySummary() async {
    await unsubscribeFromTopic(topicWeeklySummary);
  }

  /// デイリーリマインダーを有効化
  Future<void> enableDailyReminder() async {
    await subscribeToTopic(topicDailyReminder);
  }

  /// デイリーリマインダーを無効化
  Future<void> disableDailyReminder() async {
    await unsubscribeFromTopic(topicDailyReminder);
  }

  /// ニュース通知を有効化
  Future<void> enableNews() async {
    await subscribeToTopic(topicNews);
  }

  /// ニュース通知を無効化
  Future<void> disableNews() async {
    await unsubscribeFromTopic(topicNews);
  }

  /// アップデート通知を有効化
  Future<void> enableUpdates() async {
    await subscribeToTopic(topicUpdates);
  }

  /// アップデート通知を無効化
  Future<void> disableUpdates() async {
    await unsubscribeFromTopic(topicUpdates);
  }

  /// イベント通知を有効化
  Future<void> enableEvents() async {
    await subscribeToTopic(topicEvents);
  }

  /// イベント通知を無効化
  Future<void> disableEvents() async {
    await unsubscribeFromTopic(topicEvents);
  }

  /// プレミアムユーザートピックに登録
  Future<void> subscribeToPremium() async {
    await subscribeToTopic(topicPremium);
  }

  /// プレミアムユーザートピックから登録解除
  Future<void> unsubscribeFromPremium() async {
    await unsubscribeFromTopic(topicPremium);
  }

  /// 言語別トピックに登録
  Future<void> subscribeToLanguageTopic(String languageCode) async {
    await subscribeToTopic('lang_$languageCode');
  }

  /// 言語別トピックから登録解除
  Future<void> unsubscribeFromLanguageTopic(String languageCode) async {
    await unsubscribeFromTopic('lang_$languageCode');
  }

  /// 地域別トピックに登録
  Future<void> subscribeToRegionTopic(String regionCode) async {
    await subscribeToTopic('region_$regionCode');
  }

  /// 地域別トピックから登録解除
  Future<void> unsubscribeFromRegionTopic(String regionCode) async {
    await unsubscribeFromTopic('region_$regionCode');
  }

  /// ユーザー設定に基づいてトピックを更新
  Future<void> updateTopicSubscriptions({
    required bool weeklySummary,
    required bool dailyReminder,
    required bool news,
    required bool updates,
    required bool events,
  }) async {
    if (weeklySummary) {
      await enableWeeklySummary();
    } else {
      await disableWeeklySummary();
    }

    if (dailyReminder) {
      await enableDailyReminder();
    } else {
      await disableDailyReminder();
    }

    if (news) {
      await enableNews();
    } else {
      await disableNews();
    }

    if (updates) {
      await enableUpdates();
    } else {
      await disableUpdates();
    }

    if (events) {
      await enableEvents();
    } else {
      await disableEvents();
    }

    logger.info('✅ Topic subscriptions updated');
  }

  /// すべてのトピックから登録解除
  Future<void> unsubscribeFromAllTopics() async {
    await unsubscribeFromTopic(topicAllUsers);
    await unsubscribeFromTopic(topicNews);
    await unsubscribeFromTopic(topicWeeklySummary);
    await unsubscribeFromTopic(topicDailyReminder);
    await unsubscribeFromTopic(topicUpdates);
    await unsubscribeFromTopic(topicEvents);
    await unsubscribeFromTopic(topicPremium);

    logger.info('✅ Unsubscribed from all topics');
  }

  /// カスタムトピックに登録（管理者用）
  Future<void> subscribeToCustomTopic(String topic) async {
    await subscribeToTopic(topic);
  }

  /// カスタムトピックから登録解除（管理者用）
  Future<void> unsubscribeFromCustomTopic(String topic) async {
    await unsubscribeFromTopic(topic);
  }
}

/// トピック設定
class TopicSettings {
  final bool weeklySummary;
  final bool dailyReminder;
  final bool news;
  final bool updates;
  final bool events;

  const TopicSettings({
    this.weeklySummary = true,
    this.dailyReminder = true,
    this.news = true,
    this.updates = true,
    this.events = false,
  });

  TopicSettings copyWith({
    bool? weeklySummary,
    bool? dailyReminder,
    bool? news,
    bool? updates,
    bool? events,
  }) {
    return TopicSettings(
      weeklySummary: weeklySummary ?? this.weeklySummary,
      dailyReminder: dailyReminder ?? this.dailyReminder,
      news: news ?? this.news,
      updates: updates ?? this.updates,
      events: events ?? this.events,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklySummary': weeklySummary,
      'dailyReminder': dailyReminder,
      'news': news,
      'updates': updates,
      'events': events,
    };
  }

  factory TopicSettings.fromJson(Map<String, dynamic> json) {
    return TopicSettings(
      weeklySummary: json['weeklySummary'] ?? true,
      dailyReminder: json['dailyReminder'] ?? true,
      news: json['news'] ?? true,
      updates: json['updates'] ?? true,
      events: json['events'] ?? false,
    );
  }
}
