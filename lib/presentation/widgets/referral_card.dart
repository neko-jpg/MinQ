import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
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
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: tokens.spacing.xl,
            height: tokens.spacing.xl,
            decoration: BoxDecoration(
              color: tokens.textMuted.withAlpha((255 * 0.3).round()),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withAlpha((255 * 0.3).round()),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Container(
                  width: 150,
                  height: 15,
                  decoration: BoxDecoration(
                    color: tokens.textMuted.withAlpha((255 * 0.3).round()),
                    borderRadius: BorderRadius.circular(tokens.radius.sm),
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
        padding: EdgeInsets.all(tokens.spacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(tokens.radius.lg),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withAlpha((255 * 0.3).round()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: tokens.spacing.xl,
              height: tokens.spacing.xl,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255 * 0.2).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people,
                color: Colors.white,
                size: tokens.spacing.lg,
              ),
            ),
            SizedBox(width: tokens.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.friendInvitationTitle,
                    style: tokens.typography.h3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  if (stats.totalReferrals > 0)
                    Text(
                      AppLocalizations.of(context)!.invitedFriends
                        .replaceAll('{count}', stats.totalReferrals.toString())
                        .replaceAll('{rate}', (stats.conversionRate * 100).toStringAsFixed(0)),
                      style: tokens.typography.caption.copyWith(
                        color: Colors.white.withAlpha((255 * 0.9).round()),
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.inviteFriendsBonus,
                      style: tokens.typography.caption.copyWith(
                        color: Colors.white.withAlpha((255 * 0.9).round()),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha((255 * 0.8).round()),
              size: tokens.spacing.lg,
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
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.sm,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(tokens.radius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people, color: Colors.white, size: tokens.spacing.lg),
            SizedBox(width: tokens.spacing.sm),
            Text(
              AppLocalizations.of(context)!.friendInvitationTitle,
              style: tokens.typography.caption.copyWith(
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
      margin: EdgeInsets.all(tokens.spacing.lg),
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withAlpha((255 * 0.3).round()),
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
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                AppLocalizations.of(context)!.specialCampaignTitle,
                style: tokens.typography.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            AppLocalizations.of(context)!.inviteFriendsPoints,
            style: tokens.typography.body.copyWith(
              color: Colors.white.withAlpha((255 * 0.9).round()),
            ),
          ),
          SizedBox(height: tokens.spacing.md),
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
                  child: Text(AppLocalizations.of(context)!.inviteNow),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
