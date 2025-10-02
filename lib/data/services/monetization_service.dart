import 'package:flutter/foundation.dart';

enum SubscriptionTier { free, premium }

class MonetizationService {
  MonetizationService();

  SubscriptionTier _currentTier = SubscriptionTier.free;

  SubscriptionTier get currentTier => _currentTier;
  bool get isPremium => _currentTier == SubscriptionTier.premium;

  // AdMob配置ポリシー
  bool shouldShowAd(AdPlacement placement) {
    if (isPremium) return false;

    switch (placement) {
      case AdPlacement.questList:
        return true;
      case AdPlacement.statsScreen:
        return true;
      case AdPlacement.recordFlow:
        return false; // 実行導線では非表示
      case AdPlacement.celebration:
        return false; // 達成時は非表示
      case AdPlacement.onboarding:
        return false;
    }
  }

  // サブスク権限チェック
  bool hasFeatureAccess(PremiumFeature feature) {
    if (isPremium) return true;

    switch (feature) {
      case PremiumFeature.unlimitedQuests:
        return false;
      case PremiumFeature.advancedStats:
        return false;
      case PremiumFeature.customThemes:
        return false;
      case PremiumFeature.prioritySupport:
        return false;
      case PremiumFeature.adFree:
        return false;
      case PremiumFeature.cloudBackup:
        return false;
      case PremiumFeature.exportData:
        return false;
    }
  }

  Future<bool> purchaseSubscription(SubscriptionTier tier) async {
    // TODO: Implement actual purchase flow
    debugPrint('Purchase subscription: $tier');
    _currentTier = tier;
    return true;
  }

  Future<void> restorePurchases() async {
    // TODO: Implement restore purchases
    debugPrint('Restore purchases');
  }

  Future<void> cancelSubscription() async {
    // TODO: Implement cancellation
    debugPrint('Cancel subscription');
    _currentTier = SubscriptionTier.free;
  }
}

enum AdPlacement {
  questList,
  statsScreen,
  recordFlow,
  celebration,
  onboarding,
}

enum PremiumFeature {
  unlimitedQuests,
  advancedStats,
  customThemes,
  prioritySupport,
  adFree,
  cloudBackup,
  exportData,
}
