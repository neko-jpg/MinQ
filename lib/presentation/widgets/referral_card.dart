import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/data/providers.dart';
import 'package:minq/data/services/referral_service.dart';
import 'package:minq/presentation/routing/app_router.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// リファラルカード
/// ホーム画面に表示される友達招待促進カード
class ReferralCard extends ConsumerWidget {
  const ReferralCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<ReferralStats>(
      future: _loadReferralData(ref, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildSkeletonCard(tokens);
        }

        final stats = snapshot.data!;
        return _buildReferralCard(context, tokens, ref, stats);
      },
    );
  }

  Widget _buildSkeletonCard(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerLarge(),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.spacing(12),
            height: tokens.spacing(12),
            decoration: BoxDecoration(
              color: tokens.textMuted.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacing(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: tokens.spacing(20),
                  height: tokens.spacing(4),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withValues(alpha: 0.3),
                    borderRadius: tokens.cornerSmall(),
                  ),
                ),
                SizedBox(height: tokens.spacing(2)),
                Container(
                  width: tokens.spacing(32),
                  height: tokens.spacing(3),
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withValues(alpha: 0.3),
                    borderRadius: tokens.cornerSmall(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(
    BuildContext context,
    MinqTheme tokens,
    WidgetRef ref,
    ReferralStats stats,
  ) {
    return GestureDetector(
      onTap: () {
        final navigation = ref.read(navigationUseCaseProvider);
        navigation.goToReferral();
      },
      child: Container(
        padding: EdgeInsets.all(tokens.spacing(4)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: tokens.cornerLarge(),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: tokens.spacing(12),
              height: tokens.spacing(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people,
                color: Colors.white,
                size: tokens.spacing(6),
              ),
            ),
            SizedBox(width: tokens.spacing(3)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '友達招待',
                    style: tokens.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing(1)),
                  if (stats.totalReferrals > 0)
                    Text(
                      '${stats.totalReferrals}人招待済み・成功率${(stats.conversionRate * 100).toStringAsFixed(0)}%',
                      style: tokens.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    )
                  else
                    Text(
                      '友達を招待してボーナスポイントをゲット！',
                      style: tokens.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.8),
              size: tokens.spacing(4),
            ),
          ],
        ),
      ),
    );
  }

  Future<ReferralStats> _loadReferralData(WidgetRef ref, String uid) async {
    try {
      final referralService = ref.read(referralServiceProvider);
      return await referralService.getReferralStats(uid);
    } catch (e) {
      // フォールバックデータ
      return ReferralStats(
        totalReferrals: 0,
        pendingReferrals: 0,
        completedReferrals: 0,
        rewardedReferrals: 0,
      );
    }
  }
}

/// コンパクトリファラルカード
class CompactReferralCard extends ConsumerWidget {
  const CompactReferralCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return GestureDetector(
      onTap: () {
        final navigation = ref.read(navigationUseCaseProvider);
        navigation.goToReferral();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing(3),
          vertical: tokens.spacing(2),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: tokens.cornerMedium(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, color: Colors.white, size: tokens.spacing(4)),
            SizedBox(width: tokens.spacing(2)),
            Text(
              '友達招待',
              style: tokens.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// リファラル促進バナー
class ReferralPromotionBanner extends ConsumerWidget {
  const ReferralPromotionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Container(
      margin: EdgeInsets.all(tokens.spacing(4)),
      padding: EdgeInsets.all(tokens.spacing(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: tokens.spacing(6),
              ),
              SizedBox(width: tokens.spacing(2)),
              Text(
                '特別キャンペーン',
                style: tokens.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing(2)),
          Text(
            '友達を招待すると、あなたも友達も\n最大3500ポイントがもらえます！',
            style: tokens.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: tokens.spacing(3)),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final navigation = ref.read(navigationUseCaseProvider);
                    navigation.goToReferral();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade600,
                  ),
                  child: const Text('今すぐ招待'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
