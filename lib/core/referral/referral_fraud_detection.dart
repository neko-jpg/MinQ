import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/logging/app_logger.dart';

/// リファラル詐欺検出サービス
///
/// 不正な招待リンクの使用を検出し、防止する
class ReferralFraudDetection {
  final FirebaseFirestore _firestore;

  ReferralFraudDetection({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 詐欺の閾値設定
  static const int _maxReferralsPerDay = 10; // 1日あたりの最大招待数
  static const int _maxReferralsPerIP = 5; // 同一IPからの最大招待数
  static const int _minAccountAge = 7; // 招待可能な最小アカウント日数
  static const Duration _suspiciousTimeWindow = Duration(minutes: 5); // 疑わしい時間枠

  /// リファラルが有効かチェック
  Future<ReferralValidationResult> validateReferral({
    required String referrerId,
    required String newUserId,
    String? ipAddress,
    String? deviceId,
  }) async {
    try {
      // 1. 自己招待チェック
      if (referrerId == newUserId) {
        AppLogger.warning('Self-referral detected', {
          'referrer_id': referrerId,
        });
        return ReferralValidationResult(
          isValid: false,
          reason: FraudReason.selfReferral,
          message: '自分自身を招待することはできません',
        );
      }

      // 2. リファラーのアカウント年齢チェック
      final referrerValid = await _checkReferrerAccountAge(referrerId);
      if (!referrerValid) {
        AppLogger.warning('Referrer account too new', {
          'referrer_id': referrerId,
        });
        return ReferralValidationResult(
          isValid: false,
          reason: FraudReason.newAccount,
          message: 'アカウント作成から$_minAccountAge日経過していません',
        );
      }

      // 3. 1日あたりの招待数チェック
      final dailyCount = await _getDailyReferralCount(referrerId);
      if (dailyCount >= _maxReferralsPerDay) {
        AppLogger.warning('Daily referral limit exceeded', {
          'referrer_id': referrerId,
          'count': dailyCount,
        });
        return ReferralValidationResult(
          isValid: false,
          reason: FraudReason.tooManyReferrals,
          message: '1日の招待上限に達しました',
        );
      }

      // 4. 同一IPからの招待数チェック
      if (ipAddress != null) {
        final ipCount = await _getIPReferralCount(ipAddress);
        if (ipCount >= _maxReferralsPerIP) {
          AppLogger.warning('IP referral limit exceeded', {
            'ip_address': ipAddress,
            'count': ipCount,
          });
          return ReferralValidationResult(
            isValid: false,
            reason: FraudReason.sameIP,
            message: '同一IPからの招待が多すぎます',
          );
        }
      }

      // 5. 短時間での複数招待チェック
      final recentCount = await _getRecentReferralCount(
        referrerId,
        _suspiciousTimeWindow,
      );
      if (recentCount >= 3) {
        AppLogger.warning('Suspicious referral pattern detected', {
          'referrer_id': referrerId,
          'count': recentCount,
        });
        return ReferralValidationResult(
          isValid: false,
          reason: FraudReason.suspiciousPattern,
          message: '短時間での招待が多すぎます',
        );
      }

      // 6. デバイスIDの重複チェック
      if (deviceId != null) {
        final deviceUsed = await _isDeviceAlreadyUsed(deviceId);
        if (deviceUsed) {
          AppLogger.warning('Device already used for referral', {
            'device_id': deviceId,
          });
          return ReferralValidationResult(
            isValid: false,
            reason: FraudReason.duplicateDevice,
            message: 'このデバイスは既に使用されています',
          );
        }
      }

      // 7. ブラックリストチェック
      final isBlacklisted = await _isBlacklisted(referrerId);
      if (isBlacklisted) {
        AppLogger.warning('Blacklisted user attempted referral', {
          'referrer_id': referrerId,
        });
        return ReferralValidationResult(
          isValid: false,
          reason: FraudReason.blacklisted,
          message: 'このアカウントは招待機能を利用できません',
        );
      }

      // すべてのチェックをパス
      return ReferralValidationResult(
        isValid: true,
        reason: null,
        message: null,
      );
    } catch (e, stack) {
      AppLogger.error('Referral validation failed', e, stack);
      return ReferralValidationResult(
        isValid: false,
        reason: FraudReason.error,
        message: 'エラーが発生しました',
      );
    }
  }

  /// リファラーのアカウント年齢をチェック
  Future<bool> _checkReferrerAccountAge(String referrerId) async {
    final userDoc = await _firestore.collection('users').doc(referrerId).get();
    if (!userDoc.exists) return false;

    final createdAt = userDoc.data()?['createdAt'] as Timestamp?;
    if (createdAt == null) return false;

    final accountAge = DateTime.now().difference(createdAt.toDate());
    return accountAge.inDays >= _minAccountAge;
  }

  /// 1日あたりの招待数を取得
  Future<int> _getDailyReferralCount(String referrerId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot =
        await _firestore
            .collection('referrals')
            .where('referrerId', isEqualTo: referrerId)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .get();

    return snapshot.docs.length;
  }

  /// 同一IPからの招待数を取得
  Future<int> _getIPReferralCount(String ipAddress) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final snapshot =
        await _firestore
            .collection('referrals')
            .where('ipAddress', isEqualTo: ipAddress)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
            )
            .get();

    return snapshot.docs.length;
  }

  /// 最近の招待数を取得
  Future<int> _getRecentReferralCount(
    String referrerId,
    Duration timeWindow,
  ) async {
    final cutoff = DateTime.now().subtract(timeWindow);

    final snapshot =
        await _firestore
            .collection('referrals')
            .where('referrerId', isEqualTo: referrerId)
            .where(
              'createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff),
            )
            .get();

    return snapshot.docs.length;
  }

  /// デバイスが既に使用されているかチェック
  Future<bool> _isDeviceAlreadyUsed(String deviceId) async {
    final snapshot =
        await _firestore
            .collection('referrals')
            .where('deviceId', isEqualTo: deviceId)
            .limit(1)
            .get();

    return snapshot.docs.isNotEmpty;
  }

  /// ブラックリストに登録されているかチェック
  Future<bool> _isBlacklisted(String userId) async {
    final doc = await _firestore.collection('blacklist').doc(userId).get();

    return doc.exists;
  }

  /// ユーザーをブラックリストに追加
  Future<void> addToBlacklist({
    required String userId,
    required String reason,
  }) async {
    try {
      await _firestore.collection('blacklist').doc(userId).set({
        'userId': userId,
        'reason': reason,
        'addedAt': FieldValue.serverTimestamp(),
      });

      AppLogger.info('User added to blacklist', {
        'user_id': userId,
        'reason': reason,
      });
    } catch (e, stack) {
      AppLogger.error('Failed to add user to blacklist', e, stack);
      rethrow;
    }
  }

  /// ユーザーをブラックリストから削除
  Future<void> removeFromBlacklist(String userId) async {
    try {
      await _firestore.collection('blacklist').doc(userId).delete();

      AppLogger.info('User removed from blacklist', {'user_id': userId});
    } catch (e, stack) {
      AppLogger.error('Failed to remove user from blacklist', e, stack);
      rethrow;
    }
  }

  /// 疑わしいアクティビティを記録
  Future<void> recordSuspiciousActivity({
    required String userId,
    required FraudReason reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      await _firestore.collection('suspicious_activities').add({
        'userId': userId,
        'reason': reason.name,
        'metadata': metadata ?? {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      AppLogger.warning('Suspicious activity recorded', {
        'user_id': userId,
        'reason': reason.name,
        ...?metadata,
      });
    } catch (e, stack) {
      AppLogger.error('Failed to record suspicious activity', e, stack);
    }
  }

  /// 詐欺統計を取得
  Future<FraudStats> getFraudStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now();

      final suspiciousSnapshot =
          await _firestore
              .collection('suspicious_activities')
              .where(
                'createdAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(start),
              )
              .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(end))
              .get();

      final blacklistSnapshot = await _firestore.collection('blacklist').get();

      final reasonCounts = <FraudReason, int>{};
      for (final doc in suspiciousSnapshot.docs) {
        final reasonStr = doc.data()['reason'] as String?;
        if (reasonStr != null) {
          final reason = FraudReason.values.firstWhere(
            (r) => r.name == reasonStr,
            orElse: () => FraudReason.other,
          );
          reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
        }
      }

      return FraudStats(
        totalSuspiciousActivities: suspiciousSnapshot.docs.length,
        blacklistedUsers: blacklistSnapshot.docs.length,
        reasonCounts: reasonCounts,
      );
    } catch (e, stack) {
      AppLogger.error('Failed to get fraud stats', e, stack);
      return FraudStats(
        totalSuspiciousActivities: 0,
        blacklistedUsers: 0,
        reasonCounts: {},
      );
    }
  }
}

/// リファラル検証結果
class ReferralValidationResult {
  final bool isValid;
  final FraudReason? reason;
  final String? message;

  ReferralValidationResult({required this.isValid, this.reason, this.message});
}

/// 詐欺の理由
enum FraudReason {
  selfReferral, // 自己招待
  newAccount, // 新規アカウント
  tooManyReferrals, // 招待数が多すぎる
  sameIP, // 同一IP
  suspiciousPattern, // 疑わしいパターン
  duplicateDevice, // 重複デバイス
  blacklisted, // ブラックリスト
  error, // エラー
  other, // その他
}

/// 詐欺統計
class FraudStats {
  final int totalSuspiciousActivities;
  final int blacklistedUsers;
  final Map<FraudReason, int> reasonCounts;

  FraudStats({
    required this.totalSuspiciousActivities,
    required this.blacklistedUsers,
    required this.reasonCounts,
  });
}

/// 詐欺検出サービスのProvider
final referralFraudDetectionProvider = Provider<ReferralFraudDetection>((ref) {
  return ReferralFraudDetection();
});
