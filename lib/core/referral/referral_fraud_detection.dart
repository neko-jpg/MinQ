import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/logging/app_logger.dart';

/// リファラル詐欺検出サービス
///
/// 不正な招待リンクの使用を検出し、防止する
class ReferralFraudDetection {
  final FirebaseFirestore _firestore;
  final AppLogger _logger = AppLogger();

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
        _logger.warning(
          'Self-referral detected',
          data: {'referrer_id': referrerId},
        );
        return ReferralValidationResult(
          isValid: false,
          reason: FraudReason.selfReferral,
          message: '自分自身を招待することはできません',
        );
      }

      // 2. リファラーのアカウント年齢チェック
      final referrerValid = await _checkReferrerAccountAge(referrerId);
      if (!referrerValid) {
        _logger.warning(
          'Referrer account too new',
          data: {'referrer_id': referrerId},
        );
        return ReferralValidationResult(
          isValid: false,
          reason: FraudReason.newAccount,
          message: 'アカウント作成から$_minAccountAge日経過していません',
        );
      }

      // 3. 1日あたりの招待数チェック
      final dailyCount = await _getDailyReferralCount(referrerId);
      if (dailyCount >= _maxReferralsPerDay) {
        _logger.warning(
          'Daily referral limit exceeded',
          data: {'referrer_id': referrerId, 'count': dailyCount},
        );
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
          _logger.warning(
            'IP referral limit exceeded',
            data: {'ip_address': ipAddress, 'count': ipCount},
          );
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
        _logger.warning(
          'Suspicious referral pattern detected',
          data: {'referrer_id': referrerId, 'count': recentCount},
        );
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
          _logger.warning(
            'Device already used for referral',
            data: {'device_id': deviceId},
          );
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
        _logger.warning(
          'Blacklisted user attempted referral',
          data: {'referrer_id': referrerId},
        );
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
      _logger.error('Referral validation failed', error: e, stackTrace: stack);
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

      _logger.info(
        'User added to blacklist',
        data: {'user_id': userId, 'reason': reason},
      );
    } catch (e, stack) {
      _logger.error(
        'Failed to add user to blacklist',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  /// ユーザーをブラックリストから削除
  Future<void> removeFromBlacklist(String userId) async {
    try {
      await _firestore.collection('blacklist').doc(userId).delete();

      _logger.info('User removed from blacklist', data: {'user_id': userId});
    } catch (e, stack) {
      _logger.error(
        'Failed to remove user from blacklist',
        error: e,
        stackTrace: stack,
      );
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

      _logger.warning(
        'Suspicious activity recorded',
        data: {'user_id': userId, 'reason': reason.name, ...?metadata},
      );
    } catch (e, stack) {
      _logger.error(
        'Failed to record suspicious activity',
        error: e,
        stackTrace: stack,
      );
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
      _logger.error('Failed to get fraud stats', error: e, stackTrace: stack);
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
