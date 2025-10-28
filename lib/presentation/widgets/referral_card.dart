import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/referral_service.dart';
import 'package:minq/l10n/app_localizations.dart';

/// リファラルカード
/// ホーム画面に表示される友達招待促進カード
class ReferralCard extends ConsumerWidget {
  const ReferralCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<ReferralStats>(
      future: _loadReferralData(ref, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildSkeletonCard(context);
        }

        final stats = snapshot.data!;
        return _buildReferralCard(context, ref, stats);
      },
    );
  }

  Widget _buildSkeletonCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withAlpha((255 * 0.3).round()),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha((255 * 0.3).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 15,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha((255 * 0.3).round()),
                    borderRadius: BorderRadius.circular(8),
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
    WidgetRef ref,
    ReferralStats stats,
  ) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return GestureDetector(
      onTap: () {
        final navigation = ref.read(navigationUseCaseProvider);
        navigation.goToReferral();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
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
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((255 * 0.2).round()),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.friendInvitationTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (stats.totalReferrals > 0)
                    Text(
                      AppLocalizations.of(context)!.invitedFriends
                        .toString()
                        .replaceAll('{count}', stats.totalReferrals.toString())
                        .replaceAll('{rate}', (stats.conversionRate * 100).toStringAsFixed(0)),
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha((255 * 0.9).round()),
                      ),
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.inviteFriendsBonus,
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withAlpha((255 * 0.9).round()),
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withAlpha((255 * 0.8).round()),
              size: 16,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () {
        final navigation = ref.read(navigationUseCaseProvider);
        navigation.goToReferral();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.friendInvitationTitle,
              style: textTheme.bodySmall?.copyWith(
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade300, Colors.purple.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
              const Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.specialCampaignTitle,
                style: textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.inviteFriendsPoints,
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha((255 * 0.9).round()),
            ),
          ),
          const SizedBox(height: 12),
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
