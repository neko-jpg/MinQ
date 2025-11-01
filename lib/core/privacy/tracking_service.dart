import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:minq/data/logging/minq_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// トラッキングサービス
/// ユーザーのプライバシー設定を管理
class TrackingService {
  static const String _keyTrackingEnabled = 'tracking_enabled';
  static const String _keyCrashlyticsEnabled = 'crashlytics_enabled';
  static const String _keyPersonalizedAdsEnabled = 'personalized_ads_enabled';

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// トラッキングを有効化/無効化
  Future<void> setTrackingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTrackingEnabled, enabled);

    // Firebase Analyticsの設定
    await _analytics.setAnalyticsCollectionEnabled(enabled);

    MinqLogger.info('Tracking ${enabled ? 'enabled' : 'disabled'}');
  }

  /// トラッキングが有効かチェック
  Future<bool> isTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTrackingEnabled) ?? true; // デフォルトは有効
  }

  /// Crashlyticsを有効化/無効化
  Future<void> setCrashlyticsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCrashlyticsEnabled, enabled);

    // Firebase Crashlyticsの設定
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);

    MinqLogger.info('Crashlytics ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Crashlyticsが有効かチェック
  Future<bool> isCrashlyticsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyCrashlyticsEnabled) ?? true;
  }

  /// パーソナライズド広告を有効化/無効化
  Future<void> setPersonalizedAdsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPersonalizedAdsEnabled, enabled);

    // TODO: AdMobの設定を更新
    // if (enabled) {
    //   await MobileAds.instance.updateRequestConfiguration(
    //     RequestConfiguration(testDeviceIds: []),
    //   );
    // } else {
    //   await MobileAds.instance.updateRequestConfiguration(
    //     RequestConfiguration(
    //       testDeviceIds: [],
    //       tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
    //     ),
    //   );
    // }

    MinqLogger.info('Personalized ads ${enabled ? 'enabled' : 'disabled'}');
  }

  /// パーソナライズド広告が有効かチェック
  Future<bool> isPersonalizedAdsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPersonalizedAdsEnabled) ?? true;
  }

  /// すべてのトラッキングを無効化（Do Not Track）
  Future<void> enableDoNotTrack() async {
    await setTrackingEnabled(false);
    await setCrashlyticsEnabled(false);
    await setPersonalizedAdsEnabled(false);

    MinqLogger.info('Do Not Track enabled');
  }

  /// すべてのトラッキングを有効化
  Future<void> disableDoNotTrack() async {
    await setTrackingEnabled(true);
    await setCrashlyticsEnabled(true);
    await setPersonalizedAdsEnabled(true);

    MinqLogger.info('Do Not Track disabled');
  }

  /// プライバシー設定を取得
  Future<PrivacySettings> getPrivacySettings() async {
    return PrivacySettings(
      trackingEnabled: await isTrackingEnabled(),
      crashlyticsEnabled: await isCrashlyticsEnabled(),
      personalizedAdsEnabled: await isPersonalizedAdsEnabled(),
    );
  }

  /// プライバシー設定を一括更新
  Future<void> updatePrivacySettings(PrivacySettings settings) async {
    await setTrackingEnabled(settings.trackingEnabled);
    await setCrashlyticsEnabled(settings.crashlyticsEnabled);
    await setPersonalizedAdsEnabled(settings.personalizedAdsEnabled);

    MinqLogger.info('Privacy settings updated');
  }

  /// ユーザーIDの匿名化
  Future<void> anonymizeUserId() async {
    await _analytics.setUserId(id: null);
    MinqLogger.info('User ID anonymized');
  }

  /// ユーザープロパティをクリア
  Future<void> clearUserProperties() async {
    // Firebase Analyticsのユーザープロパティをクリア
    await _analytics.setUserProperty(name: 'user_type', value: null);
    await _analytics.setUserProperty(name: 'subscription_status', value: null);

    MinqLogger.info('User properties cleared');
  }

  /// データ収集の同意を記録
  Future<void> recordConsent({
    required bool analyticsConsent,
    required bool crashlyticsConsent,
    required bool adsConsent,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('consent_analytics', analyticsConsent);
    await prefs.setBool('consent_crashlytics', crashlyticsConsent);
    await prefs.setBool('consent_ads', adsConsent);
    await prefs.setString(
      'consent_timestamp',
      DateTime.now().toIso8601String(),
    );

    // 同意に基づいて設定を更新
    await setTrackingEnabled(analyticsConsent);
    await setCrashlyticsEnabled(crashlyticsConsent);
    await setPersonalizedAdsEnabled(adsConsent);

    MinqLogger.info('Consent recorded');
  }

  /// 同意が記録されているかチェック
  Future<bool> hasConsentRecorded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('consent_timestamp');
  }

  /// GDPR準拠: データ処理の同意を取得
  Future<ConsentStatus> getConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('consent_timestamp')) {
      return ConsentStatus.notAsked;
    }

    final analyticsConsent = prefs.getBool('consent_analytics') ?? false;
    final crashlyticsConsent = prefs.getBool('consent_crashlytics') ?? false;
    final adsConsent = prefs.getBool('consent_ads') ?? false;

    if (analyticsConsent && crashlyticsConsent && adsConsent) {
      return ConsentStatus.fullConsent;
    } else if (!analyticsConsent && !crashlyticsConsent && !adsConsent) {
      return ConsentStatus.noConsent;
    } else {
      return ConsentStatus.partialConsent;
    }
  }

  /// 同意を撤回
  Future<void> revokeConsent() async {
    await enableDoNotTrack();
    await anonymizeUserId();
    await clearUserProperties();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('consent_timestamp');
    await prefs.remove('consent_analytics');
    await prefs.remove('consent_crashlytics');
    await prefs.remove('consent_ads');

    MinqLogger.info('Consent revoked');
  }
}

/// プライバシー設定
class PrivacySettings {
  final bool trackingEnabled;
  final bool crashlyticsEnabled;
  final bool personalizedAdsEnabled;

  const PrivacySettings({
    required this.trackingEnabled,
    required this.crashlyticsEnabled,
    required this.personalizedAdsEnabled,
  });

  bool get doNotTrack =>
      !trackingEnabled && !crashlyticsEnabled && !personalizedAdsEnabled;
}

/// 同意ステータス
enum ConsentStatus {
  /// 未確認
  notAsked,

  /// 完全同意
  fullConsent,

  /// 部分同意
  partialConsent,

  /// 同意なし
  noConsent,
}
