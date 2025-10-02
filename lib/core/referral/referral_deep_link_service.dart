import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Referral Code Deep Link サービス
/// 友達招待→報酬システム
class ReferralDeepLinkService {
  /// リファラルコードを生成
  String generateReferralCode(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$userId:$timestamp';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    
    // 最初の8文字を使用（短くて覚えやすい）
    return hash.toString().substring(0, 8).toUpperCase();
  }

  /// リファラルリンクを生成
  String generateReferralLink(String referralCode) {
    return 'https://minq.app/invite/$referralCode';
  }

  /// ディープリンクURLを生成
  Uri generateDeepLink(String referralCode) {
    return Uri(
      scheme: 'minq',
      host: 'invite',
      path: '/$referralCode',
    );
  }

  /// リファラルコードを検証
  bool validateReferralCode(String code) {
    // 8文字の英数字
    final regex = RegExp(r'^[A-Z0-9]{8}$');
    return regex.hasMatch(code);
  }

  /// リファラルを記録
  Future<ReferralResult> recordReferral({
    required String referralCode,
    required String newUserId,
  }) async {
    // TODO: Firestoreに記録
    return ReferralResult(
      success: true,
      referrerId: 'referrer_user_id',
      reward: ReferralReward.standard,
    );
  }
}

/// リファラル結果
class ReferralResult {
  final bool success;
  final String? referrerId;
  final ReferralReward? reward;
  final String? errorMessage;

  const ReferralResult({
    required this.success,
    this.referrerId,
    this.reward,
    this.errorMessage,
  });
}

/// リファラル報酬
class ReferralReward {
  final String id;
  final String title;
  final String description;
  final RewardType type;
  final int value;

  const ReferralReward({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
  });

  static const standard = ReferralReward(
    id: 'standard_referral',
    title: '友達招待ボーナス',
    description: '友達を招待してくれてありがとう！',
    type: RewardType.badge,
    value: 1,
  );
}

enum RewardType {
  badge,
  premium,
  points,
}
