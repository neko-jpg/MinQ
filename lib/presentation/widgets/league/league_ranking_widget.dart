import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/gamification/league.dart';
import 'package:minq/presentation/providers/league_providers.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

/// Displays the ranking table for a specific league tier.
class LeagueRankingWidget extends ConsumerWidget {
  const LeagueRankingWidget({
    super.key,
    required this.league,
    this.currentUserId,
  });

  final String league;
  final String? currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankings = ref.watch(leagueRankingsProvider(league));

    return rankings.when(
      data: (data) {
        if (data.isEmpty) {
          return _EmptyState(
            message: 'No players have joined this league yet.',
          );
        }
        return _RankingList(
          rankings: data,
          currentUserId: currentUserId,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _EmptyState(
        message: 'Failed to load rankings: $error',
        isError: true,
      ),
    );
  }
}

class _RankingList extends StatelessWidget {
  const _RankingList({
    required this.rankings,
    required this.currentUserId,
  });

  final List<LeagueRanking> rankings;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: rankings.length,
      padding: const EdgeInsets.only(bottom: 24),
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final ranking = rankings[index];
        final isCurrent = ranking.userId == currentUserId;
        return _RankingTile(ranking: ranking, isCurrentUser: isCurrent);
      },
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({
    required this.ranking,
    required this.isCurrentUser,
  });

  final LeagueRanking ranking;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    final titleStyle = Theme.of(context).textTheme.titleSmall;
    final bodyStyle = Theme.of(context).textTheme.bodySmall;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isCurrentUser ? tokens.primary.withAlpha((255 * 0.12).round()) : tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser ? tokens.primary : tokens.border,
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.textPrimary.withAlpha((255 * 0.04).round()),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _RankBadge(ranking: ranking, isCurrentUser: isCurrentUser),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(ranking.avatarUrl),
            backgroundColor: tokens.surfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.displayName,
                  style: titleStyle?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCurrentUser
                        ? tokens.primary
                        : tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Streak ${ranking.streakDays} day(s) • '
                  'Last active ${_formatRelative(ranking.lastActive)}',
                  style: bodyStyle?.copyWith(color: tokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ranking.weeklyXP} XP',
                style: titleStyle?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
              Text(
                '${ranking.totalXP} total',
                style: bodyStyle?.copyWith(color: tokens.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatRelative(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.ranking,
    required this.isCurrentUser,
  });

  final LeagueRanking ranking;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    final background = isCurrentUser
        ? tokens.primary
        : ranking.rankColor.withAlpha((255 * 0.18).round());
    final foreground = isCurrentUser ? Colors.white : ranking.rankColor;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ranking.rank.toString(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: foreground,
                  ),
            ),
            Text(
              ranking.rankSuffix,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: foreground,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    this.isError = false,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.hourglass_empty,
              size: 48,
              color: isError ? tokens.error : tokens.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color:
                        isError ? tokens.error : tokens.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
