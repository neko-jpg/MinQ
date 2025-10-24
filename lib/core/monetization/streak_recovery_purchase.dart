import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/monetization/subscription_manager.dart';

/// ストリーク回復購入サービス
class StreakRecoveryPurchase {
  StreakRecoveryPurchase(this._subscriptionManager);

  final SubscriptionManager _subscriptionManager;

  /// ストリーク回復チケットの価格
  static const int ticketPrice = 120; // 120円

  /// 広告視聴によるストリーク回復
  Future<StreakRecoveryResult> recoverByAd(String questId) async {
    try {
      // 広告表示実装（将来）
      if (kDebugMode) {
        print('Showing ad for streak recovery: $questId');
      }

      // 仮実装: デバッグモードでは即座に成功
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 2)); // 広告視聴シミュレート
        return const StreakRecoveryResult.success(RecoveryMethod.ad);
      }

      return const StreakRecoveryResult.failed('広告の読み込みに失敗しました');
    } catch (e) {
      return StreakRecoveryResult.failed('エラーが発生しました: $e');
    }
  }

  /// 課金によるストリーク回復
  Future<StreakRecoveryResult> recoverByPurchase(String questId) async {
    try {
      // プレミアムユーザーは無制限
      if (_subscriptionManager.hasFeatureAccess(
        PremiumFeature.unlimitedStreakRecovery,
      )) {
        return const StreakRecoveryResult.success(RecoveryMethod.premium);
      }

      // In-App Purchase実装（将来）
      if (kDebugMode) {
        print('Processing streak recovery purchase: $questId');
      }

      // 仮実装: デバッグモードでは即座に成功
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 1)); // 購入処理シミュレート
        return const StreakRecoveryResult.success(RecoveryMethod.purchase);
      }

      return const StreakRecoveryResult.failed('購入処理に失敗しました');
    } catch (e) {
      return StreakRecoveryResult.failed('エラーが発生しました: $e');
    }
  }

  /// ストリーク保護チケットを購入
  Future<ProtectionPurchaseResult> buyProtectionTicket(
    String questId,
    ProtectionType type,
  ) async {
    try {
      // プレミアムユーザーは無制限
      if (_subscriptionManager.hasFeatureAccess(
        PremiumFeature.unlimitedStreakRecovery,
      )) {
        return const ProtectionPurchaseResult.success(RecoveryMethod.premium);
      }

      // 保護タイプ別の価格
      final price = _getProtectionPrice(type);

      // In-App Purchase実装（将来）
      if (kDebugMode) {
        print(
          'Purchasing protection ticket: $questId, type: $type, price: $price',
        );
      }

      // 仮実装: デバッグモードでは即座に成功
      if (kDebugMode) {
        await Future.delayed(const Duration(seconds: 1));
        return const ProtectionPurchaseResult.success(RecoveryMethod.purchase);
      }

      return const ProtectionPurchaseResult.failed('購入処理に失敗しました');
    } catch (e) {
      return ProtectionPurchaseResult.failed('エラーが発生しました: $e');
    }
  }

  /// 保護タイプ別の価格を取得
  int _getProtectionPrice(ProtectionType type) {
    switch (type) {
      case ProtectionType.freeze:
        return 100; // 凍結日: 100円
      case ProtectionType.pause:
        return 80; // 一時停止: 80円
      case ProtectionType.skip:
        return 60; // スキップ: 60円
    }
  }

  /// 利用可能な回復方法を取得
  List<RecoveryOption> getAvailableRecoveryOptions(String questId) {
    final options = <RecoveryOption>[];

    // プレミアムユーザーは無制限回復
    if (_subscriptionManager.hasFeatureAccess(
      PremiumFeature.unlimitedStreakRecovery,
    )) {
      options.add(
        const RecoveryOption(
          method: RecoveryMethod.premium,
          title: 'プレミアム回復',
          description: '無制限で回復できます',
          price: 0,
          isRecommended: true,
        ),
      );
      return options;
    }

    // 広告視聴による回復
    options.add(
      const RecoveryOption(
        method: RecoveryMethod.ad,
        title: '広告視聴で回復',
        description: '30秒の広告を見てストリークを回復',
        price: 0,
        isRecommended: true,
      ),
    );

    // 課金による回復
    options.add(
      const RecoveryOption(
        method: RecoveryMethod.purchase,
        title: 'チケットで回復',
        description: 'ストリーク回復チケットを使用',
        price: ticketPrice,
        isRecommended: false,
      ),
    );

    return options;
  }

  /// 利用可能な保護オプションを取得
  List<ProtectionOption> getAvailableProtectionOptions(String questId) {
    final options = <ProtectionOption>[];

    // プレミアムユーザーは無制限保護
    if (_subscriptionManager.hasFeatureAccess(
      PremiumFeature.unlimitedStreakRecovery,
    )) {
      for (final type in ProtectionType.values) {
        options.add(
          ProtectionOption(
            type: type,
            title: _getProtectionTitle(type),
            description: _getProtectionDescription(type),
            price: 0,
            isPremium: true,
          ),
        );
      }
      return options;
    }

    // 通常ユーザーの保護オプション
    for (final type in ProtectionType.values) {
      options.add(
        ProtectionOption(
          type: type,
          title: _getProtectionTitle(type),
          description: _getProtectionDescription(type),
          price: _getProtectionPrice(type),
          isPremium: false,
        ),
      );
    }

    return options;
  }

  String _getProtectionTitle(ProtectionType type) {
    switch (type) {
      case ProtectionType.freeze:
        return '凍結日';
      case ProtectionType.pause:
        return '一時停止';
      case ProtectionType.skip:
        return 'スキップ';
    }
  }

  String _getProtectionDescription(ProtectionType type) {
    switch (type) {
      case ProtectionType.freeze:
        return 'ストリークを1日凍結します（病気や緊急時用）';
      case ProtectionType.pause:
        return 'ストリークを一時停止します（旅行や忙しい時用）';
      case ProtectionType.skip:
        return '今日だけスキップします（軽い理由用）';
    }
  }
}

/// ストリーク回復結果
sealed class StreakRecoveryResult {
  const StreakRecoveryResult();

  const factory StreakRecoveryResult.success(RecoveryMethod method) =
      _SuccessResult;
  const factory StreakRecoveryResult.failed(String message) = _FailedResult;

  T when<T>({
    required T Function(RecoveryMethod method) success,
    required T Function(String message) failed,
  }) {
    return switch (this) {
      _SuccessResult(:final method) => success(method),
      _FailedResult(:final message) => failed(message),
    };
  }
}

class _SuccessResult extends StreakRecoveryResult {
  const _SuccessResult(this.method);
  final RecoveryMethod method;
}

class _FailedResult extends StreakRecoveryResult {
  const _FailedResult(this.message);
  final String message;
}

/// 保護購入結果
sealed class ProtectionPurchaseResult {
  const ProtectionPurchaseResult();

  const factory ProtectionPurchaseResult.success(RecoveryMethod method) =
      _ProtectionSuccessResult;
  const factory ProtectionPurchaseResult.failed(String message) =
      _ProtectionFailedResult;

  T when<T>({
    required T Function(RecoveryMethod method) success,
    required T Function(String message) failed,
  }) {
    return switch (this) {
      _ProtectionSuccessResult(:final method) => success(method),
      _ProtectionFailedResult(:final message) => failed(message),
    };
  }
}

class _ProtectionSuccessResult extends ProtectionPurchaseResult {
  const _ProtectionSuccessResult(this.method);
  final RecoveryMethod method;
}

class _ProtectionFailedResult extends ProtectionPurchaseResult {
  const _ProtectionFailedResult(this.message);
  final String message;
}

/// 回復方法
enum RecoveryMethod {
  ad, // 広告視聴
  purchase, // 課金
  premium, // プレミアム
}

/// 保護タイプ
enum ProtectionType {
  freeze, // 凍結日
  pause, // 一時停止
  skip, // スキップ
}

/// 回復オプション
class RecoveryOption {
  const RecoveryOption({
    required this.method,
    required this.title,
    required this.description,
    required this.price,
    required this.isRecommended,
  });

  final RecoveryMethod method;
  final String title;
  final String description;
  final int price;
  final bool isRecommended;
}

/// 保護オプション
class ProtectionOption {
  const ProtectionOption({
    required this.type,
    required this.title,
    required this.description,
    required this.price,
    required this.isPremium,
  });

  final ProtectionType type;
  final String title;
  final String description;
  final int price;
  final bool isPremium;
}

/// プロバイダー
final streakRecoveryPurchaseProvider = Provider<StreakRecoveryPurchase>((ref) {
  final subscriptionManager = ref.watch(subscriptionManagerProvider);
  return StreakRecoveryPurchase(subscriptionManager);
});
