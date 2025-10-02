import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  RemoteConfigService(this._remoteConfig);

  final FirebaseRemoteConfig? _remoteConfig;

  static const Duration _fetchTimeout = Duration(seconds: 10);
  static const Duration _minimumFetchInterval = Duration(hours: 1);

  Future<void> initialize() async {
    if (_remoteConfig == null) return;

    try {
      await _remoteConfig!.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: _fetchTimeout,
          minimumFetchInterval: _minimumFetchInterval,
        ),
      );

      await _remoteConfig!.setDefaults(_defaultValues);
      await _remoteConfig!.fetchAndActivate();
      
      debugPrint('Remote Config initialized');
    } catch (e) {
      debugPrint('Remote Config initialization failed: $e');
    }
  }

  // Default values
  static const Map<String, dynamic> _defaultValues = {
    // Version compatibility
    'min_supported_version': '0.9.0',
    'recommended_version': '0.9.0',
    'force_update_enabled': false,
    
    // Feature flags
    'feature_pair_enabled': true,
    'feature_photo_proof_enabled': true,
    'feature_share_enabled': true,
    'feature_premium_enabled': false,
    
    // UI/UX configs
    'onboarding_max_steps': 3,
    'daily_goal_default': 3,
    'max_quests_per_user': 20,
    
    // Copy variations for A/B testing
    'cta_create_quest': 'クエストを作成する',
    'cta_start_now': '今すぐ始める',
    'cta_record_progress': '記録する',
    
    // Notification configs
    'notification_default_times': '07:30,18:30,21:30',
    'notification_snooze_minutes': '10,60,1440',
    
    // Pair matching configs
    'pair_matching_timeout_seconds': 30,
    'pair_rematch_cooldown_hours': 24,
    
    // Moderation configs
    'content_moderation_enabled': true,
    'max_message_length': 500,
    'max_username_length': 20,
    
    // Monetization
    'show_ads': false,
    'ad_frequency_minutes': 30,
    'premium_price_monthly': 500,
  };

  // Feature flags
  bool get isPairEnabled => _getBool('feature_pair_enabled');
  bool get isPhotoProofEnabled => _getBool('feature_photo_proof_enabled');
  bool get isShareEnabled => _getBool('feature_share_enabled');
  bool get isPremiumEnabled => _getBool('feature_premium_enabled');

  // UI/UX configs
  int get onboardingMaxSteps => _getInt('onboarding_max_steps');
  int get dailyGoalDefault => _getInt('daily_goal_default');
  int get maxQuestsPerUser => _getInt('max_quests_per_user');

  // Copy variations
  String get ctaCreateQuest => _getString('cta_create_quest');
  String get ctaStartNow => _getString('cta_start_now');
  String get ctaRecordProgress => _getString('cta_record_progress');

  // Notification configs
  List<String> get notificationDefaultTimes => 
      _getString('notification_default_times').split(',');
  List<int> get notificationSnoozeMinutes => 
      _getString('notification_snooze_minutes').split(',').map(int.parse).toList();

  // Pair matching configs
  int get pairMatchingTimeoutSeconds => _getInt('pair_matching_timeout_seconds');
  int get pairRematchCooldownHours => _getInt('pair_rematch_cooldown_hours');

  // Moderation configs
  bool get isContentModerationEnabled => _getBool('content_moderation_enabled');
  int get maxMessageLength => _getInt('max_message_length');
  int get maxUsernameLength => _getInt('max_username_length');

  // Monetization
  bool get showAds => _getBool('show_ads');
  int get adFrequencyMinutes => _getInt('ad_frequency_minutes');
  int get premiumPriceMonthly => _getInt('premium_price_monthly');

  // Helper methods
  bool _getBool(String key) {
    return _remoteConfig?.getBool(key) ?? _defaultValues[key] as bool;
  }

  int _getInt(String key) {
    return _remoteConfig?.getInt(key) ?? _defaultValues[key] as int;
  }

  String _getString(String key) {
    return _remoteConfig?.getString(key) ?? _defaultValues[key] as String;
  }

  double _getDouble(String key) {
    return _remoteConfig?.getDouble(key) ?? _defaultValues[key] as double;
  }

  // A/B Testing helper
  String getVariant(String experimentKey, List<String> variants) {
    final variantIndex = _getInt('${experimentKey}_variant');
    if (variantIndex >= 0 && variantIndex < variants.length) {
      return variants[variantIndex];
    }
    return variants.first;
  }
}
