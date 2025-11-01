import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:minq/core/gamification/league_system.dart';
import 'package:minq/domain/gamification/league.dart';
import 'package:minq/presentation/theme/minq_theme_v2.dart';
import 'package:minq/presentation/widgets/league/league_ranking_widget.dart';
import 'package:minq/presentation/widgets/polished_ui_components.dart';

/// League screen showing rankings and league information
class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedLeague = 'bronze';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LeagueSystem.leagues.length,
      vsync: this,
    );
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      final leagues = LeagueSystem.leagues.keys.toList();
      setState(() {
        _selectedLeague = leagues[_tabController.index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final leagueStats = ref.watch(leagueStatisticsProvider);

    return Scaffold(
      backgroundColor: context.colorTokens.background,
      appBar: AppBar(
        title: Text(
          'リーグランキング',
          style: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.colorTokens.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLeagueInfo(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildLeagueTabs(context),
        ),
      ),
      body: Column(
        children: [
          // League statistics
          if (leagueStats.hasValue)
            _buildLeagueStatistics(context, leagueStats.value!),

          // Current user ranking card
          if (currentUser.hasValue)
            _buildCurrentUserRanking(context, currentUser.value!),

          // League rankings
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  LeagueSystem.leagues.keys.map((league) {
                    return LeagueRankingWidget(
                      league: league,
                      currentUserId: currentUser.value?.userId,
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildLeagueTabs(BuildContext context) {
    return Container(
      color: context.colorTokens.surface,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: context.colorTokens.primary,
        labelColor: context.colorTokens.primary,
        unselectedLabelColor: context.colorTokens.textSecondary,
        tabs:
            LeagueSystem.leagues.entries.map((entry) {
              final config = entry.value;
              return Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(config.icon, size: 20, color: config.color),
                    const SizedBox(width: 8),
                    Text(config.name),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildLeagueStatistics(BuildContext context, LeagueStatistics stats) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: context.colorTokens.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'リーグ統計',
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                '総参加者',
                '${stats.totalUsers}人',
                Icons.people,
              ),
              _buildStatItem(
                context,
                '最多リーグ',
                LeagueSystem.leagues[stats.mostPopulatedLeague]?.name ?? '-',
                Icons.trending_up,
              ),
              _buildStatItem(
                context,
                '最終更新',
                _formatLastUpdated(stats.lastUpdated),
                Icons.update,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserRanking(BuildContext context, LocalUser user) {
    final userRanking = ref.watch(userRankingProvider(user.userId));

    return userRanking.when(
      data: (ranking) {
        if (ranking == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colorTokens.primary.withOpacity(0.1),
                context.colorTokens.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colorTokens.primary),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: NetworkImage(ranking.avatarUrl),
                backgroundColor: context.colorTokens.surfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'あなたの順位',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorTokens.textSecondary,
                      ),
                    ),
                    Text(
                      '${ranking.rank}位 / ${ranking.league.toUpperCase()}',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorTokens.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ranking.weeklyXP} XP',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorTokens.primary,
                    ),
                  ),
                  Text(
                    '今週',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
        Icon(icon, color: context.colorTokens.textSecondary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorTokens.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showPromotionInfo(context),
      backgroundColor: context.colorTokens.primary,
      foregroundColor: context.colorTokens.onPrimary,
      icon: const Icon(Icons.trending_up),
      label: const Text('昇格条件'),
    );
  }

  void _showLeagueInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLeagueInfoSheet(context),
    );
  }

  void _showPromotionInfo(BuildContext context) {
    final currentLeague = LeagueSystem.leagues[_selectedLeague];
    if (currentLeague == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(currentLeague.icon, color: currentLeague.color),
                const SizedBox(width: 8),
                Text('${currentLeague.name} 昇格条件'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPromotionRequirement(
                  context,
                  '週間XP',
                  '${currentLeague.promotionThreshold} XP以上',
                  Icons.stars,
                ),
                const SizedBox(height: 12),
                _buildPromotionRequirement(
                  context,
                  '総XP',
                  '${currentLeague.maxXP} XP以上',
                  Icons.emoji_events,
                ),
                const SizedBox(height: 12),
                _buildPromotionRequirement(
                  context,
                  '継続性',
                  '週次目標達成',
                  Icons.trending_up,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('閉じる'),
              ),
            ],
          ),
    );
  }

  Widget _buildPromotionRequirement(
    BuildContext context,
    String title,
    String requirement,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: context.colorTokens.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                requirement,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeagueInfoSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: context.colorTokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: context.colorTokens.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: context.colorTokens.primary),
                const SizedBox(width: 8),
                Text(
                  'リーグシステムについて',
                  style: context.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // League info list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: LeagueSystem.leagues.length,
              itemBuilder: (context, index) {
                final entry = LeagueSystem.leagues.entries.elementAt(index);
                final config = entry.value;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: config.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(config.icon, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            config.name,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'XP範囲: ${config.minXP} - ${config.maxXP}',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '週間目標: ${config.weeklyXPRequirement} XP',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '最大参加者: ${config.maxParticipants}人',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}時間前';
    } else {
      return '${difference.inDays}日前';
    }
  }
}

// Provider for current user
final currentUserProvider = FutureProvider<LocalUser?>((ref) async {
  // This should be implemented to get the current user
  // For now, return null as placeholder
  return null;
});
