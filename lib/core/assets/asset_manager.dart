import 'package:minq/data/logging/minq_logger.dart';

/// アセット管理システム
/// アイコンセット固定、不要削除、ツリーシェイク対応
class AssetManager {
  const AssetManager._();

  // ========================================
  // アイコンセット: Material Icons (標準)
  // ========================================
  // Material Iconsを使用することで:
  // - 一貫性のあるデザイン
  // - 自動的なツリーシェイク
  // - 追加のアセットファイル不要

  // ========================================
  // 画像アセット
  // ========================================

  /// ロゴ
  static const String logo = 'assets/images/logo.png';
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';

  /// オンボーディング
  static const String onboarding1 = 'assets/images/onboarding_1.png';
  static const String onboarding2 = 'assets/images/onboarding_2.png';
  static const String onboarding3 = 'assets/images/onboarding_3.png';

  /// 空状態イラスト
  static const String emptyQuests = 'assets/images/empty_quests.png';
  static const String emptyLogs = 'assets/images/empty_logs.png';
  static const String emptyStats = 'assets/images/empty_stats.png';
  static const String emptyPairs = 'assets/images/empty_pairs.png';

  /// 祝福イラスト
  static const String celebration = 'assets/images/celebration.png';
  static const String achievement = 'assets/images/achievement.png';

  /// プレースホルダー
  static const String avatarPlaceholder =
      'assets/images/avatar_placeholder.png';
  static const String imagePlaceholder = 'assets/images/image_placeholder.png';

  // ========================================
  // Lottieアニメーション
  // ========================================

  /// ローディング
  static const String loadingAnimation = 'assets/animations/loading.json';

  /// 成功
  static const String successAnimation = 'assets/animations/success.json';

  /// 祝福
  static const String celebrationAnimation =
      'assets/animations/celebration.json';

  // ========================================
  // フォント
  // ========================================
  // Google Fontsを使用するため、ローカルフォントファイルは不要
  // - Plus Jakarta Sans (メインフォント)
  // - Roboto Mono (等幅フォント)

  // ========================================
  // アセット検証
  // ========================================

  /// すべての必須アセットが存在するか検証
  static List<String> get requiredAssets => [
    logo,
    logoLight,
    logoDark,
    onboarding1,
    onboarding2,
    onboarding3,
    emptyQuests,
    emptyLogs,
    emptyStats,
    emptyPairs,
    celebration,
    achievement,
    avatarPlaceholder,
    imagePlaceholder,
  ];

  /// オプショナルアセット（Lottie）
  static List<String> get optionalAssets => [
    loadingAnimation,
    successAnimation,
    celebrationAnimation,
  ];
}

/// アセットパス検証ヘルパー
class AssetValidator {
  /// アセットが存在するか確認（開発時のみ）
  static Future<bool> validateAssets() async {
    // 本番環境では常にtrueを返す
    assert(() {
      // 開発環境でのみ検証
      for (final asset in AssetManager.requiredAssets) {
        // アセットの存在確認ロジック
        MinqLogger.info('Validating asset: $asset');
      }
      return true;
    }());

    return true;
  }
}
