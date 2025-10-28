import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minq/data/logging/minq_logger.dart';

/// 年齢確認サービス
/// COPPA（児童オンラインプライバシー保護法）準拠
class AgeVerificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 年齢を確認（13歳以上かチェック）
  bool verifyAge(DateTime birthDate) {
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return age >= 13;
  }

  /// 年齢区分を取得
  AgeCategory getAgeCategory(DateTime birthDate) {
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;

    if (age < 13) {
      return AgeCategory.child; // 13歳未満
    } else if (age < 18) {
      return AgeCategory.teen; // 13-17歳
    } else {
      return AgeCategory.adult; // 18歳以上
    }
  }

  /// ペアレンタルコントロールを有効化
  Future<void> enableParentalControl(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'parentalControlEnabled': true,
      'pairFeatureDisabled': true,
      'chatFeatureDisabled': true,
      'publicProfileDisabled': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    MinqLogger.info('Parental control enabled for user: $userId');
  }

  /// ペアレンタルコントロールを無効化
  Future<void> disableParentalControl(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'parentalControlEnabled': false,
      'pairFeatureDisabled': false,
      'chatFeatureDisabled': false,
      'publicProfileDisabled': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    MinqLogger.info('Parental control disabled for user: $userId');
  }

  /// 年少者向けの機能制限を適用
  Future<void> applyMinorRestrictions(String userId, DateTime birthDate) async {
    final ageCategory = getAgeCategory(birthDate);

    final restrictions = <String, dynamic>{
      'ageCategory': ageCategory.name,
      'birthDate': Timestamp.fromDate(birthDate),
    };

    // 13歳未満の場合
    if (ageCategory == AgeCategory.child) {
      restrictions.addAll({
        'pairFeatureDisabled': true,
        'chatFeatureDisabled': true,
        'publicProfileDisabled': true,
        'dataCollectionMinimized': true,
      });
    }
    // 13-17歳の場合
    else if (ageCategory == AgeCategory.teen) {
      restrictions.addAll({
        'pairFeatureRestricted': true, // 同年代のみマッチング
        'chatModerated': true, // チャット内容をモデレート
        'publicProfileLimited': true, // プロフィール公開範囲を制限
      });
    }

    await _firestore.collection('users').doc(userId).update(restrictions);

    MinqLogger.info('Minor restrictions applied for user: $userId');
  }

  /// 保護者の同意を記録
  Future<void> recordParentalConsent({
    required String userId,
    required String parentEmail,
    required String parentName,
  }) async {
    await _firestore.collection('parentalConsents').add({
      'userId': userId,
      'parentEmail': parentEmail,
      'parentName': parentName,
      'consentedAt': FieldValue.serverTimestamp(),
      'ipAddress': '', // TODO: IPアドレスを取得
    });

    await _firestore.collection('users').doc(userId).update({
      'parentalConsentGiven': true,
      'parentEmail': parentEmail,
    });

    MinqLogger.info('Parental consent recorded for user: $userId');
  }

  /// 保護者への通知を送信
  Future<void> notifyParent({
    required String userId,
    required String parentEmail,
    required String subject,
    required String body,
  }) async {
    // This queues up an email to be sent by a backend service (e.g., Firebase Functions with SendGrid)
    try {
      await _firestore.collection('mail_to_send').add({
        'to': parentEmail,
        'message': {
          'subject': subject,
          'html': body, // Using html for richer formatting
        },
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      MinqLogger.info('Queued parental consent email to: $parentEmail');
    } catch (e) {
      MinqLogger.error('Error queuing email', exception: e);
    }
  }

  /// 年齢確認が必要かチェック
  Future<bool> needsAgeVerification(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return true;

    // 生年月日が登録されていない場合
    if (!data.containsKey('birthDate')) return true;

    // 年齢確認済みフラグがない場合
    if (!data.containsKey('ageVerified') || data['ageVerified'] != true) {
      return true;
    }

    return false;
  }

  /// 年齢確認を完了
  Future<void> completeAgeVerification(
    String userId,
    DateTime birthDate,
  ) async {
    final ageCategory = getAgeCategory(birthDate);

    await _firestore.collection('users').doc(userId).update({
      'birthDate': Timestamp.fromDate(birthDate),
      'ageCategory': ageCategory.name,
      'ageVerified': true,
      'ageVerifiedAt': FieldValue.serverTimestamp(),
    });

    // 年少者の場合は制限を適用
    if (ageCategory != AgeCategory.adult) {
      await applyMinorRestrictions(userId, birthDate);
    }

    MinqLogger.info('Age verification completed for user: $userId');
  }

  /// ペア機能の利用可否をチェック
  Future<bool> canUsePairFeature(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return false;

    // ペアレンタルコントロールが有効な場合
    if (data['parentalControlEnabled'] == true) return false;

    // ペア機能が無効化されている場合
    if (data['pairFeatureDisabled'] == true) return false;

    // 年齢確認が完了していない場合
    if (data['ageVerified'] != true) return false;

    return true;
  }

  /// 年齢に応じたコンテンツフィルタリング
  Future<bool> isContentAppropriate({
    required String userId,
    required String contentType,
  }) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return false;

    final ageCategory = AgeCategory.values.firstWhere(
      (e) => e.name == data['ageCategory'],
      orElse: () => AgeCategory.adult,
    );

    // 年齢に応じたコンテンツ制限
    switch (ageCategory) {
      case AgeCategory.child:
        // 13歳未満は厳しく制限
        return contentType == 'educational' || contentType == 'safe';
      case AgeCategory.teen:
        // 13-17歳は一部制限
        return contentType != 'adult' && contentType != 'sensitive';
      case AgeCategory.adult:
        // 18歳以上は制限なし
        return true;
    }
  }
}

/// 年齢区分
enum AgeCategory {
  /// 13歳未満
  child,

  /// 13-17歳
  teen,

  /// 18歳以上
  adult,
}