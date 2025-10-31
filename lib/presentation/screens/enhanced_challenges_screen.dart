import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/challenges/offline_challenge_service.dart';
import 'package:minq/data/local/models/local_quest.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/common/layout/responsive_layout.dart';
import 'package:minq/presentation/common/layout/safe_scaffold.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';
import 'package:minq/presentation/widgets/challenges/enhanced_challenge_card.dart';
import 'package:minq/presentation/widgets/common/offline_indicator.dart';
import 'package:minq/presentation/widgets/common/shimmer_loading.dart';

/// Enhanced challenges screen with offline-first capabilities and modern UI
class EnhancedChallengesScreen extends ConsumerStatefulWidget {
  const EnhancedChallengesScreen({super.key});

  @override
  ConsumerState<EnhancedChallengesScreen> createState() => _EnhancedChallengesScreenState();
}

class _EnhancedChallengesScreenState extends ConsumerState<EnhancedChallengesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(uidProvider);
    final networkStatus = ref.watch(networkStatusProvider);
    final isOffline = networkStatus == NetworkStatus.offline;

    if (userId == null) {
      return const SafeScaffold(
        body: Center(
          child: Text('ユーザーが見つかりません'),
        ),
      );
    }

    return SafeScaffold(
      enableResponsiveLayout: false,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('チャレンジ'),
            if (isOffline) ...[
              SizedBox(width: MinqTokens.spacing(2)),
              const OfflineIndicator(size: 16),
            ],
          ],
        ),
        backgroundColor: MinqTokens.surface,
        elevation: 0,
        actions: [
          // Filter button
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('すべて'),
              ),
              const PopupMenuItem(
                value: 'expiring',
                child: Text('期限間近'),
              ),
              const PopupMenuItem(
                value: 'high_reward',
                child: Text('高報酬'),
              ),
            ],
          ),
          
          // Sync button (only show when offline)
          if (isOffline)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () => _triggerSync(userId),
              tooltip: '同期',
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: MinqTokens.textPrimary,
          unselectedLabelColor: MinqTokens.textSecondary,
          indicatorColor: MinqTokens.brandPrimary,
          tabs: const [
            Tab(text: 'アクティブ'),
            Tab(text: '完了済み'),
            Tab(text: '統計'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Offline banner
          if (isOffline)
            OfflineBanner(
              onSyncPressed: () => _triggerSync(userId),
            ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ActiveChallengesTab(
                  userId: userId,
                  filter: _selectedFilter,
                ),
                _CompletedChallengesTab(userId: userId),
                _ChallengeStatsTab(userId: userId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateChallengeDialog(context, userId),
        icon: const Icon(Icons.add),
        label: const Text('チャレンジ作成'),
        backgroundColor: MinqTokens.brandPrimary,
        foregroundColor: MinqTokens.primaryForeground,
      ),
    );
  }

  void _triggerSync(String userId) {
    final service = ref.read(offlineChallengeServiceProvider(userId));
    service?.syncChallenges();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('同期を開始しました'),
        backgroundColor: MinqTokens.brandPrimary,
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateChallengeSheet(userId: userId),
    );
  }
}

/// Active challenges tab with filtering
class _ActiveChallengesTab extends ConsumerWidget {
  const _ActiveChallengesTab({
    required this.userId,
    required this.filter,
  });

  final String userId;
  final String filter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(activeChallengesStreamProvider(userId));

    return challengesAsync.when(
      data: (challenges) {
        final filteredChallenges = _applyFilter(challenges, filter);
        
        if (filteredChallenges.isEmpty) {
          return _EmptyStateWidget(
            icon: Icons.emoji_events,
            title: filter == 'all' 
                ? 'アクティブなチャレンジはありません'
                : 'フィルター条件に一致するチャレンジがありません',
            message: '新しいチャレンジに参加して、特別な報酬を獲得しましょう！',
            actionLabel: 'チャレンジを作成',
            onActionPressed: () => _showCreateChallengeDialog(context, userId),
          );
        }

        return ResponsiveLayout.constrainedContainer(
          child: RefreshIndicator(
            onRefresh: () => _refreshChallenges(ref, userId),
            child: ListView.builder(
              padding: EdgeInsets.all(MinqTokens.spacing(2)),
              itemCount: filteredChallenges.length,
              itemBuilder: (context, index) {
                final challenge = filteredChallenges[index];
                return EnhancedChallengeCard(
                  challenge: challenge,
                  onTap: () => _showChallengeDetails(context, challenge, userId),
                  onProgressUpdate: () => _updateProgress(context, challenge, userId),
                );
              },
            ),
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _ErrorWidget(
        message: 'チャレンジの読み込みに失敗しました',
        onRetry: () => ref.refresh(activeChallengesStreamProvider(userId)),
      ),
    );
  }

  List<LocalChallenge> _applyFilter(List<LocalChallenge> challenges, String filter) {
    switch (filter) {
      case 'expiring':
        final now = DateTime.now();
        return challenges.where((c) {
          final timeLeft = c.endDate.difference(now);
          return timeLeft.inHours < 24 && timeLeft.isPositive;
        }).toList();
      
      case 'high_reward':
        return challenges.where((c) => c.xpReward >= 100).toList();
      
      default:
        return challenges;
    }
  }

  Future<void> _refreshChallenges(WidgetRef ref, String userId) async {
    final service = ref.read(offlineChallengeServiceProvider(userId));
    await service?.syncChallenges();
  }

  void _showChallengeDetails(BuildContext context, LocalChallenge challenge, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChallengeDetailsSheet(
        challenge: challenge,
        userId: userId,
      ),
    );
  }

  void _updateProgress(BuildContext context, LocalChallenge challenge, String userId) {
    showDialog(
      context: context,
      builder: (context) => _ProgressUpdateDialog(
        challenge: challenge,
        userId: userId,
      ),
    );
  }

  void _showCreateChallengeDialog(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CreateChallengeSheet(userId: userId),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(MinqTokens.spacing(2)),
      itemCount: 3,
      itemBuilder: (context, index) => ShimmerLoading(
        child: Container(
          height: 200,
          margin: EdgeInsets.only(bottom: MinqTokens.spacing(3)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: MinqTokens.cornerLarge(),
          ),
        ),
      ),
    );
  }
}

/// Completed challenges tab
class _CompletedChallengesTab extends ConsumerWidget {
  const _CompletedChallengesTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(completedChallengesStreamProvider(userId));

    return challengesAsync.when(
      data: (challenges) {
        if (challenges.isEmpty) {
          return const _EmptyStateWidget(
            icon: Icons.check_circle_outline,
            title: '完了したチャレンジはありません',
            message: 'チャレンジに参加して、達成の喜びを味わいましょう！',
          );
        }

        return ResponsiveLayout.constrainedContainer(
          child: ListView.builder(
            padding: EdgeInsets.all(MinqTokens.spacing(2)),
            itemCount: challenges.length,
            itemBuilder: (context, index) {
              final challenge = challenges[index];
              return EnhancedChallengeCard(
                challenge: challenge,
                onTap: () => _showCompletedChallengeDetails(context, challenge),
              );
            },
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _ErrorWidget(
        message: '完了済みチャレンジの読み込みに失敗しました',
        onRetry: () => ref.refresh(completedChallengesStreamProvider(userId)),
      ),
    );
  }

  void _showCompletedChallengeDetails(BuildContext context, LocalChallenge challenge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CompletedChallengeDetailsSheet(challenge: challenge),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.all(MinqTokens.spacing(2)),
      itemCount: 3,
      itemBuilder: (context, index) => ShimmerLoading(
        child: Container(
          height: 200,
          margin: EdgeInsets.only(bottom: MinqTokens.spacing(3)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: MinqTokens.cornerLarge(),
          ),
        ),
      ),
    );
  }
}

/// Challenge statistics tab
class _ChallengeStatsTab extends ConsumerWidget {
  const _ChallengeStatsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(offlineChallengeServiceProvider(userId));
    
    if (service == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<ChallengeStats>(
      future: service.getUserChallengeStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return _ErrorWidget(
            message: '統計の読み込みに失敗しました',
            onRetry: () => setState(() {}),
          );
        }
        
        final stats = snapshot.data!;
        
        return ResponsiveLayout.constrainedContainer(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(MinqTokens.spacing(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'チャレンジ統計',
                  style: MinqTokens.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: MinqTokens.spacing(4)),
                
                // Stats cards
                _buildStatsGrid(stats),
                
                SizedBox(height: MinqTokens.spacing(4)),
                
                // Achievement rate chart
                _buildAchievementChart(stats),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(ChallengeStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: MinqTokens.spacing(3),
      crossAxisSpacing: MinqTokens.spacing(3),
      children: [
        _StatCard(
          title: '総チャレンジ数',
          value: stats.totalChallenges.toString(),
          icon: Icons.emoji_events,
          color: MinqTokens.brandPrimary,
        ),
        _StatCard(
          title: '完了数',
          value: stats.completedChallenges.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _StatCard(
          title: 'アクティブ',
          value: stats.activeChallenges.toString(),
          icon: Icons.play_circle,
          color: Colors.blue,
        ),
        _StatCard(
          title: '獲得XP',
          value: stats.totalXPEarned.toString(),
          icon: Icons.stars,
          color: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildAchievementChart(ChallengeStats stats) {
    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(4)),
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: MinqTokens.cornerLarge(),
        border: Border.all(color: MinqTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '達成率',
            style: MinqTokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: MinqTokens.spacing(3)),
          
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: stats.completionRate,
                  minHeight: 8,
                  backgroundColor: MinqTokens.border,
                  valueColor: const AlwaysStoppedAnimation(Colors.green),
                ),
              ),
              SizedBox(width: MinqTokens.spacing(2)),
              Text(
                '${(stats.completionRate * 100).toInt()}%',
                style: MinqTokens.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(3)),
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: MinqTokens.cornerLarge(),
        border: Border.all(color: MinqTokens.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          SizedBox(height: MinqTokens.spacing(2)),
          Text(
            value,
            style: MinqTokens.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: MinqTokens.spacing(1)),
          Text(
            title,
            style: MinqTokens.bodySmall.copyWith(
              color: MinqTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Placeholder widgets - these would need full implementation
class _CreateChallengeSheet extends StatelessWidget {
  const _CreateChallengeSheet({required this.userId});
  final String userId;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('チャレンジ作成フォーム（実装予定）'),
      ),
    );
  }
}

class _ChallengeDetailsSheet extends StatelessWidget {
  const _ChallengeDetailsSheet({required this.challenge, required this.userId});
  final LocalChallenge challenge;
  final String userId;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('チャレンジ詳細（実装予定）'),
      ),
    );
  }
}

class _CompletedChallengeDetailsSheet extends StatelessWidget {
  const _CompletedChallengeDetailsSheet({required this.challenge});
  final LocalChallenge challenge;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Center(
        child: Text('完了チャレンジ詳細（実装予定）'),
      ),
    );
  }
}

class _ProgressUpdateDialog extends StatelessWidget {
  const _ProgressUpdateDialog({required this.challenge, required this.userId});
  final LocalChallenge challenge;
  final String userId;
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('進捗更新'),
      content: const Text('進捗更新ダイアログ（実装予定）'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
      ],
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  const _EmptyStateWidget({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: MinqTokens.textSecondary),
            SizedBox(height: MinqTokens.spacing(4)),
            Text(
              title,
              style: MinqTokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MinqTokens.spacing(1)),
            Text(
              message,
              style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: MinqTokens.spacing(4)),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(MinqTokens.spacing(6)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: MinqTokens.textSecondary,
            ),
            SizedBox(height: MinqTokens.spacing(4)),
            Text(
              message,
              style: MinqTokens.bodyMedium.copyWith(color: MinqTokens.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MinqTokens.spacing(4)),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder providers - these would need to be implemented based on your existing architecture
final networkStatusProvider = Provider<NetworkStatus>((ref) => NetworkStatus.online);

enum NetworkStatus { online, offline }