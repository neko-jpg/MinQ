import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';
import 'package:minq/data/services/analytics_service.dart';

/// 招待/リファラルサービス
/// 招待リンク生成、トラッキング、報酬管理
class ReferralService {
  final FirebaseFirestore _firestore;
  final FirebaseDynamicLinks _dynamicLinks;
  final AnalyticsService _analytics;

  ReferralService({
    FirebaseFirestore? firestore,
    FirebaseDynamicLinks? dynamicLinks,
    required AnalyticsService analytics,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance,
       _analytics = analytics;

  /// 招待リンク生成
  Future<String> generateInviteLink({
    required String userId,
    String? campaignName,
  }) async {
    try {
      final parameters = DynamicLinkParameters(
        uriPrefix: 'https://minquest.page.link',
        link: Uri.parse('https://minquest.app/invite?referrer=$userId'),
        androidParameters: const AndroidParameters(
          packageName: 'com.minquest.app',
          minimumVersion: 1,
        ),
        iosParameters: const IOSParameters(
          bundleId: 'com.minquest.app',
          minimumVersion: '1.0.0',
          appStoreId: '123456789',
        ),
        socialMetaTagParameters: SocialMetaTagParameters(
          title: 'MiniQuestに参加しよう！',
          description: '一緒に習慣を作って、目標を達成しましょう',
          imageUrl: Uri.parse('https://minquest.app/assets/invite-banner.png'),
        ),
      );

      final shortLink = await _dynamicLinks.buildShortLink(parameters);

      // リンク生成をトラッキング
      await _analytics.logEvent(
        'referral_link_generated',
        parameters: {
          'user_id': userId,
          'campaign': campaignName ?? 'default',
          'link': shortLink.shortUrl.toString(),
        },
      );

      return shortLink.shortUrl.toString();
    } catch (e) {
      await _analytics.logError(
        'referral_link_generation_failed',
        e.toString(),
      );
      rethrow;
    }
  }

  /// 招待リンクをシェア
  Future<void> shareInviteLink({
    required String userId,
    String? customMessage,
  }) async {
    try {
      final link = await generateInviteLink(userId: userId);
      final message = customMessage ?? 'MiniQuestで一緒に習慣を作りませんか？\n$link';

      await Share.share(message, subject: 'MiniQuestへの招待');

      await _analytics.logEvent(
        'referral_link_shared',
        parameters: {'user_id': userId},
      );
    } catch (e) {
      await _analytics.logError('referral_share_failed', e.toString());
      rethrow;
    }
  }

  /// Dynamic Linkを処理
  Future<String?> handleDynamicLink(PendingDynamicLinkData? linkData) async {
    if (linkData == null) return null;

    try {
      final deepLink = linkData.link;
      final referrerId = deepLink.queryParameters['referrer'];

      if (referrerId != null) {
        await _analytics.logEvent(
          'referral_link_opened',
          parameters: {'referrer_id': referrerId},
        );
      }

      return referrerId;
    } catch (e) {
      await _analytics.logError('dynamic_link_handling_failed', e.toString());
      return null;
    }
  }

  /// リファラル関係を記録
  Future<void> recordReferral({
    required String newUserId,
    required String referrerId,
  }) async {
    try {
      final batch = _firestore.batch();

      // 新規ユーザーのリファラル情報を保存
      final userRef = _firestore.collection('users').doc(newUserId);
      batch.set(userRef, {
        'referredBy': referrerId,
        'referredAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // リファラーの招待カウントを増加
      final referrerRef = _firestore.collection('users').doc(referrerId);
      batch.update(referrerRef, {'referralCount': FieldValue.increment(1)});

      // リファラル履歴を記録
      final referralRef = _firestore.collection('referrals').doc();
      batch.set(referralRef, {
        'referrerId': referrerId,
        'newUserId': newUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, completed, rewarded
      });

      await batch.commit();

      await _analytics.logEvent(
        'referral_recorded',
        parameters: {'referrer_id': referrerId, 'new_user_id': newUserId},
      );
    } catch (e) {
      await _analytics.logError('referral_recording_failed', e.toString());
      rethrow;
    }
  }

  /// リファラル報酬を付与
  Future<void> grantReferralReward({
    required String referrerId,
    required String newUserId,
    String rewardType = 'premium_trial',
  }) async {
    try {
      final batch = _firestore.batch();

      // リファラーに報酬を付与
      final referrerRef = _firestore.collection('users').doc(referrerId);
      batch.update(referrerRef, {
        'rewards.$rewardType': FieldValue.increment(1),
        'lastRewardAt': FieldValue.serverTimestamp(),
      });

      // リファラル履歴を更新
      final referralQuery =
          await _firestore
              .collection('referrals')
              .where('referrerId', isEqualTo: referrerId)
              .where('newUserId', isEqualTo: newUserId)
              .where('status', isEqualTo: 'pending')
              .limit(1)
              .get();

      if (referralQuery.docs.isNotEmpty) {
        final referralRef = referralQuery.docs.first.reference;
        batch.update(referralRef, {
          'status': 'rewarded',
          'rewardedAt': FieldValue.serverTimestamp(),
          'rewardType': rewardType,
        });
      }

      await batch.commit();

      await _analytics.logEvent(
        'referral_reward_granted',
        parameters: {
          'referrer_id': referrerId,
          'new_user_id': newUserId,
          'reward_type': rewardType,
        },
      );
    } catch (e) {
      await _analytics.logError('referral_reward_failed', e.toString());
      rethrow;
    }
  }

  /// ユーザーのリファラル統計を取得
  Future<ReferralStats> getReferralStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final referralCount = userDoc.data()?['referralCount'] ?? 0;

      final referralsQuery =
          await _firestore
              .collection('referrals')
              .where('referrerId', isEqualTo: userId)
              .get();

      final pending =
          referralsQuery.docs
              .where((doc) => doc.data()['status'] == 'pending')
              .length;
      final completed =
          referralsQuery.docs
              .where((doc) => doc.data()['status'] == 'completed')
              .length;
      final rewarded =
          referralsQuery.docs
              .where((doc) => doc.data()['status'] == 'rewarded')
              .length;

      return ReferralStats(
        totalReferrals: referralCount,
        pendingReferrals: pending,
        completedReferrals: completed,
        rewardedReferrals: rewarded,
      );
    } catch (e) {
      await _analytics.logError('referral_stats_fetch_failed', e.toString());
      rethrow;
    }
  }

  /// リファラルキャンペーンを作成
  Future<void> createCampaign({
    required String campaignId,
    required String name,
    required DateTime startDate,
    required DateTime endDate,
    Map<String, dynamic>? rewards,
  }) async {
    try {
      await _firestore.collection('referral_campaigns').doc(campaignId).set({
        'name': name,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'rewards': rewards ?? {},
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _analytics.logEvent(
        'referral_campaign_created',
        parameters: {'campaign_id': campaignId, 'campaign_name': name},
      );
    } catch (e) {
      await _analytics.logError('campaign_creation_failed', e.toString());
      rethrow;
    }
  }

  /// アクティブなキャンペーンを取得
  Future<List<Map<String, dynamic>>> getActiveCampaigns() async {
    try {
      final now = Timestamp.now();
      final snapshot =
          await _firestore
              .collection('referral_campaigns')
              .where('active', isEqualTo: true)
              .where('startDate', isLessThanOrEqualTo: now)
              .where('endDate', isGreaterThanOrEqualTo: now)
              .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      await _analytics.logError('active_campaigns_fetch_failed', e.toString());
      return [];
    }
  }
}

/// リファラル統計データ
class ReferralStats {
  final int totalReferrals;
  final int pendingReferrals;
  final int completedReferrals;
  final int rewardedReferrals;

  ReferralStats({
    required this.totalReferrals,
    required this.pendingReferrals,
    required this.completedReferrals,
    required this.rewardedReferrals,
  });

  double get conversionRate {
    if (totalReferrals == 0) return 0.0;
    return (completedReferrals + rewardedReferrals) / totalReferrals;
  }
}
