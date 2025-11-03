import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/services/league_system.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/domain/gamification/league.dart';
import 'package:minq/presentation/providers/league_providers.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';
import 'package:minq/presentation/widgets/league/league_ranking_widget.dart';

/// Displays the league overview, statistics, and rankings.
class LeagueScreen extends ConsumerStatefulWidget {
  const LeagueScreen({super.key});

  @override
  ConsumerState<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends ConsumerState<LeagueScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final List<MapEntry<String, LeagueConfig>> _leagues;

  @override
  void initState() {
    super.initState();
    _leagues = LeagueSystem.leagues.entries.toList(growable: false);
    _tabController = TabController(length: _leagues.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(leagueStatisticsProvider);
    final currentUser = ref.watch(currentLeagueUserProvider);
    final currentUserValue = currentUser.asData?.value;

    return Scaffold(
      backgroundColor: context.colorTokens.background,
      appBar: AppBar(
        title: Text(
          'League Overview',
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
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: context.colorTokens.surface,
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: context.colorTokens.primary,
              labelColor: context.colorTokens.primary,
              unselectedLabelColor: context.colorTokens.textSecondary,
              tabs: _leagues
                  .map(
                    (entry) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            entry.value.icon,
                            size: 18,
                            color: entry.value.color,
                          ),
                          const SizedBox(width: 8),
                          Text(entry.value.name),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          stats.when(
            data: (value) => _LeagueStatisticsCard(
              statistics: value,
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load league statistics: $error',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorTokens.error,
                ),
              ),
            ),
          ),
          if (currentUserValue != null) ...[
            const SizedBox(height: 16),
            _CurrentUserCard(user: currentUserValue),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _leagues
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: LeagueRankingWidget(
                        league: entry.key,
                        currentUserId: currentUserValue?.uid,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.insights),
        label: const Text('Requirements'),
        onPressed: () => _showPromotionInfo(context),
      ),
    );
  }

  void _showLeagueInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return _LeagueInfoSheet(leagues: _leagues);
      },
    );
  }

  void _showPromotionInfo(BuildContext context) {
    final selectedLeague = _leagues[_tabController.index].value;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(selectedLeague.icon, color: selectedLeague.color),
              const SizedBox(width: 8),
              Text(selectedLeague.name),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RequirementRow(
                icon: Icons.stars,
                title: 'Promotion threshold',
                value: '${selectedLeague.promotionThreshold} XP this week',
              ),
              const SizedBox(height: 12),
              _RequirementRow(
                icon: Icons.emoji_events,
                title: 'Season XP cap',
                value: '${selectedLeague.maxXP} lifetime XP',
              ),
              const SizedBox(height: 12),
              _RequirementRow(
                icon: Icons.people_alt,
                title: 'Max participants',
                value: '${selectedLeague.maxParticipants} players',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class _LeagueStatisticsCard extends StatelessWidget {
  const _LeagueStatisticsCard({required this.statistics});

  final LeagueStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    final distribution = statistics.percentageDistribution;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
        boxShadow: [
          BoxShadow(
            color: tokens.textPrimary.withAlpha((255 * 0.05).round()),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'League statistics',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Updated ${_formatRelativeTime(statistics.lastUpdated)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.textSecondary,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: LeagueSystem.leagues.entries.map((entry) {
              final percentage = distribution[entry.key] ?? 0;
              return _DistributionChip(
                label: entry.value.nameEn,
                value: '${percentage.toStringAsFixed(1)}%',
                color: entry.value.color,
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute(s) ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} hour(s) ago';
    }
    return '${difference.inDays} day(s) ago';
  }
}

class _DistributionChip extends StatelessWidget {
  const _DistributionChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tokens.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _CurrentUserCard extends ConsumerWidget {
  const _CurrentUserCard({required this.user});

  final LocalUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.colorTokens;
    final league = LeagueSystem.leagues[user.currentLeague];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tokens.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: league?.color ?? tokens.primary,
            child: Icon(
              league?.icon ?? Icons.workspace_premium,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Weekly XP: ${user.weeklyXP}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Total XP: ${user.totalXP}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tokens.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _LeagueInfoSheet extends StatelessWidget {
  const _LeagueInfoSheet({required this.leagues});

  final List<MapEntry<String, LeagueConfig>> leagues;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorTokens.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'League tiers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: leagues.length,
                itemBuilder: (context, index) {
                  final entry = leagues[index];
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(config.icon, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              config.nameEn,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'XP range: ${config.minXP} - ${config.maxXP}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          'Weekly requirement: ${config.weeklyXPRequirement} XP',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          'Capacity: ${config.maxParticipants} players',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: tokens.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: tokens.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
