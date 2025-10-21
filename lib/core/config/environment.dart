/// アプリケーション環境設定
enum Environment {
  /// 開発環境
  development,

  /// ステージング環境
  staging,

  /// 本番環境
  production;

  /// 現在の環境を取得
  static Environment get current => EnvironmentConfig.current;

  /// 環境名を取得
  String get name {
    switch (this) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }

  /// Slack Webhook URL
  String? get slackWebhookUrl => EnvironmentConfig.slackWebhookUrl;

  /// メール通知エンドポイント
  String? get emailNotificationEndpoint =>
      EnvironmentConfig.emailNotificationEndpoint;

  /// PagerDuty Integration Key
  String? get pagerDutyIntegrationKey =>
      EnvironmentConfig.pagerDutyIntegrationKey;

  /// 通知受信者
  List<String> get notificationRecipients =>
      EnvironmentConfig.notificationRecipients;
}

/// 環境設定クラス
class EnvironmentConfig {
  /// 現在の環境
  static Environment get current {
    const env = String.fromEnvironment('ENV', defaultValue: 'development');
    switch (env) {
      case 'production':
      case 'prod':
        return Environment.production;
      case 'staging':
      case 'stg':
        return Environment.staging;
      case 'development':
      case 'dev':
      default:
        return Environment.development;
    }
  }

  /// 開発環境かどうか
  static bool get isDevelopment => current == Environment.development;

  /// ステージング環境かどうか
  static bool get isStaging => current == Environment.staging;

  /// 本番環境かどうか
  static bool get isProduction => current == Environment.production;

  /// デバッグモードかどうか
  static bool get isDebug {
    const debug = bool.fromEnvironment('DEBUG', defaultValue: false);
    return debug || isDevelopment;
  }

  /// API Base URL
  static String get apiBaseUrl {
    const url = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (url.isNotEmpty) return url;

    switch (current) {
      case Environment.production:
        return 'https://api.minq.app';
      case Environment.staging:
        return 'https://api-staging.minq.app';
      case Environment.development:
        return 'http://localhost:8080';
    }
  }

  /// Firebase Project ID
  static String get firebaseProjectId {
    const projectId = String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: '',
    );
    if (projectId.isNotEmpty) return projectId;

    switch (current) {
      case Environment.production:
        return 'minq-prod';
      case Environment.staging:
        return 'minq-staging';
      case Environment.development:
        return 'minq-dev';
    }
  }

  /// Sentry DSN
  static String get sentryDsn {
    const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
    return dsn;
  }

  /// Analytics有効化
  static bool get analyticsEnabled {
    const enabled = bool.fromEnvironment(
      'ANALYTICS_ENABLED',
      defaultValue: false,
    );
    return enabled || isProduction;
  }

  /// Crashlytics有効化
  static bool get crashlyticsEnabled {
    const enabled = bool.fromEnvironment(
      'CRASHLYTICS_ENABLED',
      defaultValue: false,
    );
    return enabled || isProduction;
  }

  /// ログレベル
  static String get logLevel {
    const level = String.fromEnvironment('LOG_LEVEL', defaultValue: '');
    if (level.isNotEmpty) return level;

    switch (current) {
      case Environment.production:
        return 'warning';
      case Environment.staging:
        return 'info';
      case Environment.development:
        return 'debug';
    }
  }

  /// Slack Webhook URL
  static String? get slackWebhookUrl {
    const url = String.fromEnvironment('SLACK_WEBHOOK_URL', defaultValue: '');
    return url.isEmpty ? null : url;
  }

  /// メール通知エンドポイント
  static String? get emailNotificationEndpoint {
    const endpoint = String.fromEnvironment(
      'EMAIL_NOTIFICATION_ENDPOINT',
      defaultValue: '',
    );
    return endpoint.isEmpty ? null : endpoint;
  }

  /// PagerDuty Integration Key
  static String? get pagerDutyIntegrationKey {
    const key = String.fromEnvironment(
      'PAGERDUTY_INTEGRATION_KEY',
      defaultValue: '',
    );
    return key.isEmpty ? null : key;
  }

  /// 通知受信者メールアドレス
  static List<String> get notificationRecipients {
    const recipients = String.fromEnvironment(
      'NOTIFICATION_RECIPIENTS',
      defaultValue: '',
    );
    if (recipients.isEmpty) return [];
    return recipients.split(',').map((e) => e.trim()).toList();
  }

  /// アプリ名（環境別）
  static String get appName {
    switch (current) {
      case Environment.production:
        return 'MiniQuest';
      case Environment.staging:
        return 'MiniQuest (Staging)';
      case Environment.development:
        return 'MiniQuest (Dev)';
    }
  }

  /// アプリID（環境別）
  static String get appId {
    switch (current) {
      case Environment.production:
        return 'com.minq.app';
      case Environment.staging:
        return 'com.minq.app.staging';
      case Environment.development:
        return 'com.minq.app.dev';
    }
  }

  /// 環境情報を文字列で取得
  static String get environmentInfo {
    return '''
Environment: ${current.name}
Debug: $isDebug
API Base URL: $apiBaseUrl
Firebase Project: $firebaseProjectId
Analytics: $analyticsEnabled
Crashlytics: $crashlyticsEnabled
Log Level: $logLevel
''';
  }

  /// 環境情報をMapで取得
  static Map<String, dynamic> get environmentMap {
    return {
      'environment': current.name,
      'debug': isDebug,
      'apiBaseUrl': apiBaseUrl,
      'firebaseProjectId': firebaseProjectId,
      'analyticsEnabled': analyticsEnabled,
      'crashlyticsEnabled': crashlyticsEnabled,
      'logLevel': logLevel,
      'appName': appName,
      'appId': appId,
    };
  }
}

/// ビルド設定
class BuildConfig {
  /// ビルド番号
  static const buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );

  /// バージョン名
  static const versionName = String.fromEnvironment(
    'VERSION_NAME',
    defaultValue: '1.0.0',
  );

  /// ビルド日時
  static const buildDate = String.fromEnvironment(
    'BUILD_DATE',
    defaultValue: '',
  );

  /// Git コミットハッシュ
  static const gitCommit = String.fromEnvironment(
    'GIT_COMMIT',
    defaultValue: '',
  );

  /// Git ブランチ
  static const gitBranch = String.fromEnvironment(
    'GIT_BRANCH',
    defaultValue: '',
  );

  /// ビルド情報を文字列で取得
  static String get buildInfo {
    return '''
Version: $versionName ($buildNumber)
Build Date: $buildDate
Git Commit: $gitCommit
Git Branch: $gitBranch
''';
  }

  /// ビルド情報をMapで取得
  static Map<String, dynamic> get buildMap {
    return {
      'buildNumber': buildNumber,
      'versionName': versionName,
      'buildDate': buildDate,
      'gitCommit': gitCommit,
      'gitBranch': gitBranch,
    };
  }
}

/// フィーチャーフラグ
class FeatureFlags {
  /// 新機能を有効化
  static const enableNewFeature = bool.fromEnvironment(
    'ENABLE_NEW_FEATURE',
    defaultValue: false,
  );

  /// ペア機能を有効化
  static const enablePairFeature = bool.fromEnvironment(
    'ENABLE_PAIR_FEATURE',
    defaultValue: true,
  );

  /// 広告を有効化
  static const enableAds = bool.fromEnvironment(
    'ENABLE_ADS',
    defaultValue: false,
  );

  /// サブスクリプションを有効化
  static const enableSubscription = bool.fromEnvironment(
    'ENABLE_SUBSCRIPTION',
    defaultValue: false,
  );

  /// デバッグメニューを表示
  static const showDebugMenu = bool.fromEnvironment(
    'SHOW_DEBUG_MENU',
    defaultValue: false,
  );

  /// パフォーマンスオーバーレイを表示
  static const showPerformanceOverlay = bool.fromEnvironment(
    'SHOW_PERFORMANCE_OVERLAY',
    defaultValue: false,
  );

  /// フィーチャーフラグをMapで取得
  static Map<String, bool> get flagsMap {
    return {
      'enableNewFeature': enableNewFeature,
      'enablePairFeature': enablePairFeature,
      'enableAds': enableAds,
      'enableSubscription': enableSubscription,
      'showDebugMenu': showDebugMenu,
      'showPerformanceOverlay': showPerformanceOverlay,
    };
  }
}
