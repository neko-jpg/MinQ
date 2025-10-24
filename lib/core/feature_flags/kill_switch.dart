import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:minq/core/logging/app_logger.dart';

/// Feature Flag Kill Switch
/// Remote Configのみで機能を即時停止
import 'package:flutter/material.dart';

class KillSwitch {
  final FirebaseRemoteConfig _remoteConfig;
  final AppLogger _logger;

  KillSwitch(this._remoteConfig, this._logger);

  /// 機能が有効かチェック
  Future<bool> isFeatureEnabled(String featureKey) async {
    try {
      await _remoteConfig.fetchAndActivate();
      final enabled = _remoteConfig.getBool('feature_$featureKey');

      if (!enabled) {
        _logger.warning('Feature disabled by kill switch: $featureKey');
      }

      return enabled;
    } catch (e, stack) {
      _logger.error(
        'Kill switch check failed',
        error: e,
        stackTrace: stack,
      );
      // エラー時はデフォルトで有効
      return true;
    }
  }

  /// 複数の機能をチェック
  Future<Map<String, bool>> checkFeatures(List<String> featureKeys) async {
    final results = <String, bool>{};

    for (final key in featureKeys) {
      results[key] = await isFeatureEnabled(key);
    }

    return results;
  }

  /// 機能の設定値を取得
  Future<T> getFeatureConfig<T>(String featureKey, T defaultValue) async {
    try {
      await _remoteConfig.fetchAndActivate();

      if (T == String) {
        return _remoteConfig.getString('config_$featureKey') as T;
      } else if (T == int) {
        return _remoteConfig.getInt('config_$featureKey') as T;
      } else if (T == double) {
        return _remoteConfig.getDouble('config_$featureKey') as T;
      } else if (T == bool) {
        return _remoteConfig.getBool('config_$featureKey') as T;
      }

      return defaultValue;
    } catch (e, stack) {
      _logger.error(
        'Feature config fetch failed',
        error: e,
        stackTrace: stack,
      );
      return defaultValue;
    }
  }

  /// すべての機能フラグを取得
  Future<Map<String, bool>> getAllFeatureFlags() async {
    try {
      await _remoteConfig.fetchAndActivate();
      final all = _remoteConfig.getAll();
      final features = <String, bool>{};

      for (final entry in all.entries) {
        if (entry.key.startsWith('feature_')) {
          final featureName = entry.key.substring('feature_'.length);
          features[featureName] = entry.value.asBool();
        }
      }

      return features;
    } catch (e, stack) {
      _logger.error(
        'Failed to get all feature flags',
        error: e,
        stackTrace: stack,
      );
      return {};
    }
  }
}

/// 機能キー定義
class FeatureKeys {
  const FeatureKeys._();

  // コア機能
  static const questCreation = 'quest_creation';
  static const questCompletion = 'quest_completion';
  static const questDeletion = 'quest_deletion';

  // ソーシャル機能
  static const pairMatching = 'pair_matching';
  static const pairChat = 'pair_chat';
  static const sharing = 'sharing';

  // プレミアム機能
  static const premiumFeatures = 'premium_features';
  static const advancedStats = 'advanced_stats';
  static const dataExport = 'data_export';

  // 実験的機能
  static const aiRecommendations = 'ai_recommendations';
  static const voiceInput = 'voice_input';
  static const bgm = 'bgm';

  // イベント
  static const events = 'events';
  static const challenges = 'challenges';

  // 通知
  static const pushNotifications = 'push_notifications';
  static const emailNotifications = 'email_notifications';

  // 広告
  static const ads = 'ads';
  static const rewardedAds = 'rewarded_ads';
}


/// Remote Config デフォルト値
class RemoteConfigDefaults {
  const RemoteConfigDefaults._();

  static const Map<String, dynamic> defaults = {
    // 機能フラグ（すべてデフォルトで有効）
    'feature_quest_creation': true,
    'feature_quest_completion': true,
    'feature_quest_deletion': true,
    'feature_pair_matching': true,
    'feature_pair_chat': true,
    'feature_sharing': true,
    'feature_premium_features': false,
    'feature_advanced_stats': true,
    'feature_data_export': true,
    'feature_ai_recommendations': false,
    'feature_voice_input': false,
    'feature_bgm': false,
    'feature_events': true,
    'feature_challenges': true,
    'feature_push_notifications': true,
    'feature_email_notifications': false,
    'feature_ads': false,
    'feature_rewarded_ads': false,

    // 設定値
    'config_max_quests_per_user': 50,
    'config_max_pair_messages_per_day': 100,
    'config_quest_completion_cooldown_seconds': 5,
    'config_pair_matching_timeout_seconds': 30,
  };
}
