import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// サブスクリプション管理サービス
class SubscriptionManager {
  static const String premiumMonthlyId = 'premium_monthly';
  static const String premiumYearlyId = 'premium_yearly';
  static const String coachingBasicId = 'coaching_basic';
  static const String coachingProId = 'coaching_pro';

  /// 利用可能なサブスクリプションプラン
  static const List<SubscriptionPlan> availablePlans = [
    SubscriptionPlan(
      id: premiumMonthlyId,
      name: 'プレミアム（月額）',
      description: '全機能アンロック、広告なし、無制限ストリーク回復',
      price: 980,
      currency: 'JPY',
      duration: Duration(days: 30),
      features: [
        '全機能アンロック',
        '広告なし',
        '無制限ストリーク回復',
        'プレミアムテーマ',
        '詳細統計',
        'データエクスポート',
      ],
    ),
    SubscriptionPlan(
      id: premiumYearlyId,
      name: 'プレミアム（年額）',
      description: '月額プランより30%お得！',
      price: 8280, // 月額980円 × 12ヶ月 × 0.7
      currency: 'JPY',
      duration: Duration(days: 365),
      features: [
        '全機能アンロック',
        '広告なし',
        '無制限ストリーク回復',
        'プレミアムテーマ',
        '詳細統計',
        'データエクスポート',
        '30%割引',
      ],
    ),
    SubscriptionPlan(
      id: coachingBasicId,
      name: 'AIコーチング（ベーシック）',
      description: 'パーソナライズされたAIコーチング',
      price: 2980,
      currency: 'JPY',
      duration: Duration(days: 30),
      features: [
        'プレミアム機能すべて',
        'リアルタイムAIコーチング',
        '個別習慣分析',
        '失敗予測アラート',
        'パーソナライズ提案',
      ],
    ),
    SubscriptionPlan(
      id: coachingProId,
      name: 'AIコーチング（プロ）',
      description: '最高レベルのパーソナライズ体験',
      price: 9800,
      currency: 'JPY',
      duration: Duration(days: 30),
      features: [
        'ベーシック機能すべて',
        '24時間AIサポート',
        '週次1on1コーチング',
        'カスタム習慣プログラム',
        '優先サポート',
        '専用コミュニティ',
      ],
    ),
  ];

  /// 現在のサブスクリプション状態
  SubscriptionStatus _currentStatus = const SubscriptionStatus.free();

  /// サブスクリプション状態を取得
  SubscriptionStatus get currentStatus => _currentStatus;

  /// プレミアム機能が利用可能かチェック
  bool get isPremiumActive {
    return _currentStatus.when(
      free: () => false,
      premium: (plan, expiresAt) => expiresAt.isAfter(DateTime.now()),
      coaching: (plan, expiresAt) => expiresAt.isAfter(DateTime.now()),
    );
  }

  /// コーチング機能が利用可能かチェック
  bool get isCoachingActive {
    return _currentStatus.when(
      free: () => false,
      premium: (plan, expiresAt) => false,
      coaching: (plan, expiresAt) => expiresAt.isAfter(DateTime.now()),
    );
  }

  /// サブスクリプションを開始
  Future<bool> startSubscription(String planId) async {
    try {
      // In-App Purchase実装（将来）
      if (kDebugMode) {
        print('Starting subscription: $planId');
      }

      // 仮実装: デバッグモードでは即座に有効化
      if (kDebugMode) {
        final plan = availablePlans.firstWhere((p) => p.id == planId);
        final expiresAt = DateTime.now().add(plan.duration);

        if (planId.contains('coaching')) {
          _currentStatus = SubscriptionStatus.coaching(plan, expiresAt);
        } else {
          _currentStatus = SubscriptionStatus.premium(plan, expiresAt);
        }
        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Subscription error: $e');
      }
      return false;
    }
  }

  /// サブスクリプションをキャンセル
  Future<bool> cancelSubscription() async {
    try {
      // In-App Purchase実装（将来）
      if (kDebugMode) {
        print('Canceling subscription');
      }

      _currentStatus = const SubscriptionStatus.free();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Cancel subscription error: $e');
      }
      return false;
    }
  }

  /// サブスクリプション状態を復元
  Future<void> restoreSubscriptions() async {
    try {
      // In-App Purchase実装（将来）
      if (kDebugMode) {
        print('Restoring subscriptions');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Restore subscriptions error: $e');
      }
    }
  }

  /// 特定機能へのアクセス権をチェック
  bool hasFeatureAccess(PremiumFeature feature) {
    switch (feature) {
      case PremiumFeature.adFree:
      case PremiumFeature.unlimitedStreakRecovery:
      case PremiumFeature.premiumThemes:
      case PremiumFeature.detailedStats:
      case PremiumFeature.dataExport:
        return isPremiumActive;

      case PremiumFeature.aiCoaching:
      case PremiumFeature.failurePrediction:
      case PremiumFeature.personalizedSuggestions:
        return isCoachingActive;

      case PremiumFeature.prioritySupport:
      case PremiumFeature.customPrograms:
        return isCoachingActive &&
            _currentStatus.maybeWhen(
              coaching: (plan, _) => plan.id == coachingProId,
              orElse: () => false,
            );
    }
  }
}

/// サブスクリプションプラン
class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.duration,
    required this.features,
  });

  final String id;
  final String name;
  final String description;
  final int price; // 価格（セント単位）
  final String currency;
  final Duration duration;
  final List<String> features;

  /// 月額換算価格を取得
  double get monthlyPrice {
    final months = duration.inDays / 30.0;
    return price / months;
  }

  /// 年額プランの割引率を計算
  double? get discountRate {
    if (id == SubscriptionManager.premiumYearlyId) {
      const monthlyPrice = 980.0;
      final yearlyMonthlyPrice = price / 12.0;
      return (monthlyPrice - yearlyMonthlyPrice) / monthlyPrice;
    }
    return null;
  }
}

/// サブスクリプション状態
sealed class SubscriptionStatus {
  const SubscriptionStatus();

  const factory SubscriptionStatus.free() = _FreeStatus;
  const factory SubscriptionStatus.premium(
    SubscriptionPlan plan,
    DateTime expiresAt,
  ) = _PremiumStatus;
  const factory SubscriptionStatus.coaching(
    SubscriptionPlan plan,
    DateTime expiresAt,
  ) = _CoachingStatus;

  T when<T>({
    required T Function() free,
    required T Function(SubscriptionPlan plan, DateTime expiresAt) premium,
    required T Function(SubscriptionPlan plan, DateTime expiresAt) coaching,
  }) {
    return switch (this) {
      _FreeStatus() => free(),
      _PremiumStatus(:final plan, :final expiresAt) => premium(plan, expiresAt),
      _CoachingStatus(:final plan, :final expiresAt) => coaching(
        plan,
        expiresAt,
      ),
    };
  }

  T? maybeWhen<T>({
    T Function()? free,
    T Function(SubscriptionPlan plan, DateTime expiresAt)? premium,
    T Function(SubscriptionPlan plan, DateTime expiresAt)? coaching,
    required T Function() orElse,
  }) {
    return switch (this) {
      _FreeStatus() => free?.call() ?? orElse(),
      _PremiumStatus(:final plan, :final expiresAt) =>
        premium?.call(plan, expiresAt) ?? orElse(),
      _CoachingStatus(:final plan, :final expiresAt) =>
        coaching?.call(plan, expiresAt) ?? orElse(),
    };
  }
}

class _FreeStatus extends SubscriptionStatus {
  const _FreeStatus();
}

class _PremiumStatus extends SubscriptionStatus {
  const _PremiumStatus(this.plan, this.expiresAt);

  final SubscriptionPlan plan;
  final DateTime expiresAt;
}

class _CoachingStatus extends SubscriptionStatus {
  const _CoachingStatus(this.plan, this.expiresAt);

  final SubscriptionPlan plan;
  final DateTime expiresAt;
}

/// プレミアム機能一覧
enum PremiumFeature {
  adFree,
  unlimitedStreakRecovery,
  premiumThemes,
  detailedStats,
  dataExport,
  aiCoaching,
  failurePrediction,
  personalizedSuggestions,
  prioritySupport,
  customPrograms,
}

/// プロバイダー
final subscriptionManagerProvider = Provider<SubscriptionManager>((ref) {
  return SubscriptionManager();
});

final subscriptionStatusProvider = StateProvider<SubscriptionStatus>((ref) {
  return ref.watch(subscriptionManagerProvider).currentStatus;
});
