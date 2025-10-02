import 'package:firebase_remote_config/firebase_remote_config.dart';

/// 機能フラグサービス
/// Remote Configを使用した機能の有効/無効切り替え
class FeatureFlagService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// 初期化
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 1),
      ),
    );

    // デフォルト値を設定
    await _remoteConfig.setDefaults({
      // 機能フラグ
      'feature_pair_enabled': true,
      'feature_chat_enabled': true,
      'feature_achievements_enabled': true,
      'feature_export_enabled': true,
      'feature_share_enabled': true,
      'feature_calendar_enabled': true,
      'feature_templates_enabled': true,
      'feature_smart_suggestions_enabled': true,

      // キルスイッチ
      'kill_switch_app': false,
      'kill_switch_auth': false,
      'kill_switch_sync': false,
      'kill_switch_notifications': false,

      // 実験フラグ
      'experiment_new_ui': false,
      'experiment_gamification': false,

      // 設定値
      'max_quests_free': 10,
      'max_quests_premium': 100,
      'sync_interval_minutes': 15,
    });

    await fetchAndActivate();
  }

  /// 設定を取得して有効化
  Future<bool> fetchAndActivate() async {
    try {
      final activated = await _remoteConfig.fetchAndActivate();
      print('✅ Remote Config ${activated ? 'activated' : 'not changed'}');
      return activated;
    } catch (e) {
      print('❌ Failed to fetch remote config: $e');
      return false;
    }
  }

  /// 機能が有効かチェック
  bool isFeatureEnabled(String featureName) {
    return _remoteConfig.getBool('feature_${featureName}_enabled');
  }

  /// キルスイッチがアクティブかチェック
  bool isKillSwitchActive(String switchName) {
    return _remoteConfig.getBool('kill_switch_$switchName');
  }

  /// 実験が有効かチェック
  bool isExperimentEnabled(String experimentName) {
    return _remoteConfig.getBool('experiment_$experimentName');
  }

  /// 設定値を取得
  int getConfigInt(String key) {
    return _remoteConfig.getInt(key);
  }

  String getConfigString(String key) {
    return _remoteConfig.getString(key);
  }

  double getConfigDouble(String key) {
    return _remoteConfig.getDouble(key);
  }

  /// アプリ全体のキルスイッチ
  bool get isAppKilled => isKillSwitchActive('app');

  /// 認証のキルスイッチ
  bool get isAuthKilled => isKillSwitchActive('auth');

  /// 同期のキルスイッチ
  bool get isSyncKilled => isKillSwitchActive('sync');

  /// 通知のキルスイッチ
  bool get isNotificationsKilled => isKillSwitchActive('notifications');

  /// ペア機能が有効か
  bool get isPairFeatureEnabled => isFeatureEnabled('pair');

  /// チャット機能が有効か
  bool get isChatFeatureEnabled => isFeatureEnabled('chat');

  /// アチーブメント機能が有効か
  bool get isAchievementsFeatureEnabled => isFeatureEnabled('achievements');

  /// エクスポート機能が有効か
  bool get isExportFeatureEnabled => isFeatureEnabled('export');

  /// 共有機能が有効か
  bool get isShareFeatureEnabled => isFeatureEnabled('share');

  /// カレンダー機能が有効か
  bool get isCalendarFeatureEnabled => isFeatureEnabled('calendar');

  /// テンプレート機能が有効か
  bool get isTemplatesFeatureEnabled => isFeatureEnabled('templates');

  /// スマート提案機能が有効か
  bool get isSmartSuggestionsFeatureEnabled =>
      isFeatureEnabled('smart_suggestions');

  /// 無料ユーザーの最大クエスト数
  int get maxQuestsFree => getConfigInt('max_quests_free');

  /// プレミアムユーザーの最大クエスト数
  int get maxQuestsPremium => getConfigInt('max_quests_premium');

  /// 同期間隔（分）
  int get syncIntervalMinutes => getConfigInt('sync_interval_minutes');

  /// メンテナンスモードかチェック
  bool get isMaintenanceMode {
    return _remoteConfig.getBool('maintenance_mode');
  }

  /// メンテナンスメッセージを取得
  String get maintenanceMessage {
    return _remoteConfig.getString('maintenance_message');
  }

  /// 最小サポートバージョンを取得
  String get minSupportedVersion {
    return _remoteConfig.getString('min_supported_version');
  }

  /// 強制アップデートが必要かチェック
  bool isForceUpdateRequired(String currentVersion) {
    final minVersion = minSupportedVersion;
    return _compareVersions(currentVersion, minVersion) < 0;
  }

  /// バージョン比較
  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < v1Parts.length && i < v2Parts.length; i++) {
      if (v1Parts[i] < v2Parts[i]) return -1;
      if (v1Parts[i] > v2Parts[i]) return 1;
    }

    return 0;
  }

  /// A/Bテストのバリアント取得
  String getExperimentVariant(String experimentName) {
    return _remoteConfig.getString('experiment_${experimentName}_variant');
  }

  /// 機能のロールアウト率を取得（0-100）
  int getFeatureRolloutPercentage(String featureName) {
    return _remoteConfig.getInt('feature_${featureName}_rollout');
  }

  /// ユーザーが機能のロールアウト対象かチェック
  bool isUserInRollout(String featureName, String userId) {
    final rolloutPercentage = getFeatureRolloutPercentage(featureName);
    if (rolloutPercentage >= 100) return true;
    if (rolloutPercentage <= 0) return false;

    // ユーザーIDのハッシュ値を使って決定的に判定
    final hash = userId.hashCode.abs() % 100;
    return hash < rolloutPercentage;
  }

  /// デバッグ情報を取得
  Map<String, dynamic> getDebugInfo() {
    return {
      'lastFetchTime': _remoteConfig.lastFetchTime,
      'lastFetchStatus': _remoteConfig.lastFetchStatus.toString(),
      'settings': {
        'fetchTimeout': _remoteConfig.settings.fetchTimeout.inSeconds,
        'minimumFetchInterval':
            _remoteConfig.settings.minimumFetchInterval.inMinutes,
      },
    };
  }
}
