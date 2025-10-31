import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/league_system.dart';
import 'package:minq/data/local/models/local_user.dart';
import 'package:minq/domain/gamification/league.dart';

/// League ranking widget with podium and list display
class LeagueRankingWidget extends ConsumerWidget {
  final String league;
  final String? currentUserId;

  const LeagueRankingWidget({
    super.key,
    required this.league,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankings = ref.watch(leagueRankingsProvider(league));
    final leagueConfig = LeagueSystem.leagues[league];

    return rankings.when(
      data: (data) => _buildRankingContent(context, data, leagueConfig),
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context, error),
    );
  }

  Widget _buildRankingContent(
    BuildContext context,
    List<LeagueRanking> rankings,
    LeagueConfig? leagueConfig,
  ) {
    if (leagueConfig == null) {
      return _buildErrorState(context, 'League not found');
    }

    return CustomScrollView(
      slivers: [
        // League Header
        SliverToBoxAdapter(
          child: LeagueHeaderCard(config: leagueConfig),
        ),

        // Top 3 Podium (if we have at least 1 user)
        if (rankings.isNotEmpty)
          SliverToBoxAdapter(
            child: PodiumWidget(
              topThree: rankings.take(3).toList(),
              currentUserId: currentUserId,
            ),
          ),

        // Ranking List (4th place and below)
        if (rankings.length > 3)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final ranking = rankings[index + 3]; // Skip top 3
                  final isCurrentUser = ranking.userId == currentUserId;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: RankingListTile(
                      ranking: ranking,
                      isCurrentUser: isCurrentUser,
                    ),
                  );
                },
                childCount: math.max(0, rankings.length - 3),
              ),
            ),
          ),

        // Empty state if no rankings
        if (rankings.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(context),
          ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: context.colorTokens.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'ランキングを読み込み中...',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colorTokens.error,
          ),
          const SizedBox(height: 16),
          Text(
            'ランキングの読み込みに失敗しました',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorTokens.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: context.colorTokens.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'まだランキングがありません',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorTokens.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'クエストを完了してXPを獲得しましょう！',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorTokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// League header card showing league info
class LeagueHeaderCard extends StatelessWidget {
  final LeagueConfig config;

  const LeagueHeaderCard({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: config.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  config.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.name,
                      style: context.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '週間XP目標: ${config.weeklyXPRequirement}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '昇格ライン',
                '${config.promotionThreshold} XP',
                Icons.trending_up,
              ),
              _buildStatItem(
                context,
                '降格ライン',
                '${config.relegationThreshold} XP',
                Icons.trending_down,
              ),
              _buildStatItem(
                context,
                '最大参加者',
                '${config.maxParticipants}人',
                Icons.people,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

/// Podium widget for top 3 rankings
class PodiumWidget extends StatelessWidget {
  final List<LeagueRanking> topThree;
  final String? currentUserId;

  const PodiumWidget({
    super.key,
    required this.topThree,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (topThree.length > 1)
            _buildPodiumPlace(context, topThree[1], 2),
          
          // 1st place
          if (topThree.isNotEmpty)
            _buildPodiumPlace(context, topThree[0], 1),
          
          // 3rd place
          if (topThree.length > 2)
            _buildPodiumPlace(context, topThree[2], 3),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    BuildContext context,
    LeagueRanking ranking,
    int place,
  ) {
    final height = place == 1 ? 120.0 : place == 2 ? 100.0 : 80.0;
    final isCurrentUser = ranking.userId == currentUserId;
    
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Crown for 1st place
          if (place == 1)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Icon(
                Icons.emoji_events,
                color: ranking.rankColor,
                size: 32,
              ),
            ),

          // Avatar with glow effect for current user
          Container(
            decoration: isCurrentUser
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.colorTokens.primary.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: CircleAvatar(
              radius: place == 1 ? 28 : 24,
              backgroundImage: NetworkImage(ranking.avatarUrl),
              backgroundColor: context.colorTokens.surfaceVariant,
            ),
          ),

          const SizedBox(height: 8),

          // Name
          SizedBox(
            width: 80,
            child: Text(
              ranking.displayName,
              style: context.textTheme.bodySmall?.copyWith(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                color: isCurrentUser 
                    ? context.colorTokens.primary 
                    : context.colorTokens.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          // XP
          Text(
            '${ranking.weeklyXP} XP',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorTokens.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Podium
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            width: 60,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ranking.rankColor,
                  ranking.rankColor.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              border: isCurrentUser
                  ? Border.all(
                      color: context.colorTokens.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                '$place',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: place == 1 ? 28 : 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ranking list tile for 4th place and below
class RankingListTile extends StatelessWidget {
  final LeagueRanking ranking;
  final bool isCurrentUser;

  const RankingListTile({
    super.key,
    required this.ranking,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? context.colorTokens.primary.withOpacity(0.1)
            : context.colorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: context.colorTokens.primary, width: 2)
            : Border.all(color: context.colorTokens.border),
        boxShadow: [
          BoxShadow(
            color: context.colorTokens.textPrimary.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? context.colorTokens.primary
                  : context.colorTokens.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${ranking.rank}',
                style: context.textTheme.titleSmall?.copyWith(
                  color: isCurrentUser
                      ? Colors.white
                      : context.colorTokens.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(ranking.avatarUrl),
            backgroundColor: context.colorTokens.surfaceVariant,
          ),

          const SizedBox(width: 12),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.displayName,
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                    color: isCurrentUser
                        ? context.colorTokens.primary
                        : context.colorTokens.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: context.colorTokens.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ranking.streakDays}日',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // XP
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ranking.weeklyXP}',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser
                      ? context.colorTokens.primary
                      : context.colorTokens.textPrimary,
                ),
              ),
              Text(
                'XP',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}