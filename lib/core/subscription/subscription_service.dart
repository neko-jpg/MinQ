import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/logging/app_logger.dart';

/// サブスクリプション管理サービス
/// 
/// ユーザーの課金状態を管理し、機能へのアクセス権限を制御する
class SubscriptionService {
  /// 現在のサブスクリプションプラン
  SubscriptionPlan _currentPlan = SubscriptionPlan.free;

  /// サブスクリプションプランを取得
  SubscriptionPlan get currentPlan => _currentPlan;

  /// プレミアムユーザーかどうか
  bool get isPremium => _currentPlan != SubscriptionPlan.free;

  /// 初期化
  Future<void> initialize() async {
    try {
      // TODO: 実際の課金プラットフォーム（RevenueCat, Purchases等）から状態を取得
      await _loadSubscriptionStatus();
      AppLogger.info('Subscription service initialized: plan=${_currentPlan.name}');
    } catch (e, stack) {
      AppLogger.error('Failed to initialize subscription service', error: e, stackTrace: stack);
    }
  }

  /// サブスクリプション状態を読み込み
  Future<void> _loadSubscriptionStatus() async {
    // TODO: 実装
    // 例: RevenueCat から購入情報を取得
    // final purchaserInfo = await Purchases.getPurchaserInfo();
    // if (purchaserInfo.entitlements.active.containsKey('premium')) {
    //   _currentPlan = SubscriptionPlan.premium;
    // }
  }

  /// サブスクリプションを購入
  Future<bool> purchase(SubscriptionPlan plan) async {
    try {
      AppLogger.info('Attempting to purchase subscription: plan=${plan.name}');

      // TODO: 実際の購入処理
      // 例: RevenueCat で購入
      // final purchaserInfo = await Purchases.purchasePackage(package);
      // if (purchaserInfo.entitlements.active.containsKey('premium')) {
      //   _currentPlan = plan;
      //   return true;
      // }

      // デモ用: 常に成功
      _currentPlan = plan;
      AppLogger.info('Subscription purchased successfully: plan=${plan.name}');
      return true;
    } catch (e, stack) {
      AppLogger.error('Failed to purchase subscription', error: e, stackTrace: stack);
      return false;
    }
  }

  /// サブスクリプションを復元
  Future<bool> restore() async {
    try {
      AppLogger.info('Attempting to restore subscription');

      // TODO: 実際の復元処理
      // 例: RevenueCat で復元
      // final purchaserInfo = await Purchases.restoreTransactions();
      // if (purchaserInfo.entitlements.active.containsKey('premium')) {
      //   _currentPlan = SubscriptionPlan.premium;
      //   return true;
      // }

      AppLogger.info('Subscription restored successfully');
      return true;
    } catch (e, stack) {
      AppLogger.error('Failed to restore subscription', error: e, stackTrace: stack);
      return false;
    }
  }

  /// サブスクリプションをキャンセル
  Future<bool> cancel() async {
    try {
      AppLogger.info('Attempting to cancel subscription');

      // TODO: 実際のキャンセル処理
      // 注: iOS/Androidではアプリ内でキャンセルできないため、
      // ストアの設定画面に誘導する

      AppLogger.info('Subscription cancellation initiated');
      return true;
    } catch (e, stack) {
      AppLogger.error('Failed to cancel subscription', error: e, stackTrace: stack);
      return false;
    }
  }

  /// 機能へのアクセス権限をチェック
  bool hasAccess(Feature feature) {
    return feature.isAvailableFor(_currentPlan);
  }

  /// 機能の使用制限をチェック
  FeatureLimit getLimit(Feature feature) {
    return feature.getLimitFor(_currentPlan);
  }
}

/// サブスクリプションプラン
enum SubscriptionPlan {
  /// 無料プラン
  free,

  /// プレミアムプラン（月額）
  premiumMonthly,

  /// プレミアムプラン（年額）
  premiumYearly,
}

/// 機能
enum Feature {
  /// クエスト作成
  createQuest,

  /// ペア機能
  pairFeature,

  /// データエクスポート
  dataExport,

  /// 広告非表示
  adFree,

  /// カスタムテーマ
  customTheme,

  /// 高度な統計
  advancedStats,

  /// 無制限のクエスト
  unlimitedQuests,

  /// 優先サポート
  prioritySupport,
}

extension FeatureExtension on Feature {
  /// プランで利用可能かチェック
  bool isAvailableFor(SubscriptionPlan plan) {
    switch (this) {
      case Feature.createQuest:
      case Feature.pairFeature:
      case Feature.dataExport:
        // 基本機能は全プランで利用可能
        return true;

      case Feature.adFree:
      case Feature.customTheme:
      case Feature.advancedStats:
      case Feature.unlimitedQuests:
      case Feature.prioritySupport:
        // プレミアム機能
        return plan != SubscriptionPlan.free;
    }
  }

  /// プランごとの制限を取得
  FeatureLimit getLimitFor(SubscriptionPlan plan) {
    switch (this) {
      case Feature.createQuest:
        return plan == SubscriptionPlan.free
            ? FeatureLimit(maxCount: 10, unlimited: false)
            : FeatureLimit(unlimited: true);

      case Feature.unlimitedQuests:
        return plan == SubscriptionPlan.free
            ? FeatureLimit(maxCount: 10, unlimited: false)
            : FeatureLimit(unlimited: true);

      default:
        return FeatureLimit(unlimited: true);
    }
  }

  /// 機能名を取得
  String get displayName {
    switch (this) {
      case Feature.createQuest:
        return 'クエスト作成';
      case Feature.pairFeature:
        return 'ペア機能';
      case Feature.dataExport:
        return 'データエクスポート';
      case Feature.adFree:
        return '広告非表示';
      case Feature.customTheme:
        return 'カスタムテーマ';
      case Feature.advancedStats:
        return '高度な統計';
      case Feature.unlimitedQuests:
        return '無制限のクエスト';
      case Feature.prioritySupport:
        return '優先サポート';
    }
  }

  /// 機能の説明を取得
  String get description {
    switch (this) {
      case Feature.createQuest:
        return '習慣を作成して管理できます';
      case Feature.pairFeature:
        return '友達とペアを組んで励まし合えます';
      case Feature.dataExport:
        return 'データをCSV/JSON形式でエクスポートできます';
      case Feature.adFree:
        return '広告なしで快適に利用できます';
      case Feature.customTheme:
        return 'お好みのテーマカラーを選択できます';
      case Feature.advancedStats:
        return '詳細な統計とグラフを表示できます';
      case Feature.unlimitedQuests:
        return 'クエストを無制限に作成できます';
      case Feature.prioritySupport:
        return '優先的にサポートを受けられます';
    }
  }
}

/// 機能の使用制限
class FeatureLimit {
  /// 最大使用回数（nullの場合は無制限）
  final int? maxCount;

  /// 無制限かどうか
  final bool unlimited;

  FeatureLimit({
    this.maxCount,
    this.unlimited = false,
  });

  /// 制限に達しているかチェック
  bool isLimitReached(int currentCount) {
    if (unlimited) return false;
    if (maxCount == null) return false;
    return currentCount >= maxCount!;
  }

  /// 残り使用可能回数
  int? remainingCount(int currentCount) {
    if (unlimited) return null;
    if (maxCount == null) return null;
    return maxCount! - currentCount;
  }
}

/// サブスクリプションサービスのProvider
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final service = SubscriptionService();
  service.initialize();
  return service;
});

/// 現在のプランのProvider
final currentPlanProvider = Provider<SubscriptionPlan>((ref) {
  return ref.watch(subscriptionServiceProvider).currentPlan;
});

/// プレミアムユーザーかどうかのProvider
final isPremiumProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionServiceProvider).isPremium;
});

/// 機能へのアクセス権限をチェックするProvider
final featureAccessProvider = Provider.family<bool, Feature>((ref, feature) {
  return ref.watch(subscriptionServiceProvider).hasAccess(feature);
});
