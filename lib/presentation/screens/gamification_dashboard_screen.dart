import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/badge.dart';
import 'package:minq/presentation/theme/haptics_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/widgets/badge_notification_widget.dart';
import 'package:minq/presentation/widgets/enhanced_level_progress_widget.dart';

/// Comprehensive gamification dashboard showing all gamification features
class GamificationDashboardScreen extends ConsumerStatefulWidget {
  const GamificationDashboardScreen({super.key});

  @override
  ConsumerState<GamificationDashboardScreen> createState() =>
      _GamificationDashboardScreenState();
}

class _GamificationDashboardScreenState
    extends ConsumerState<GamificationDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'ゲーミフィケーション',
          style: tokens.typography.h2.copyWith(
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
          ),
        ),
        backgroundColor: tokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: tokens.brandPrimary,
          unselectedLabelColor: tokens.textMuted,
          indicatorColor: tokens.brandPrimary,
          tabs: const [
            Tab(text: '進捗', icon: Icon(Icons.trending_up)),
            Tab(text: 'バッジ', icon: Icon(Icons.military_tech)),
            Tab(text: 'ランキング', icon: Icon(Icons.leaderboard)),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProgressTab(tokens),
            _buildBadgesTab(tokens),
            _buildRankingTab(tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab(MinqTheme tokens) {
    final uid = ref.watch(uidProvider);
    if (uid == null) return const Center(child: Text('ログインが必要です'));

    final gamificationEngine = ref.watch(gamificationEngineProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Progress
          const EnhancedLevelProgressWidget(showAnimations: true),

          SizedBox(height: tokens.spacing.lg),

          // Points Summary Card
          FutureBuilder<int>(
            future: gamificationEngine.getUserPoints(uid),
            builder: (context, snapshot) {
              final points = snapshot.data ?? 0;
              return _buildPointsSummaryCard(tokens, points);
            },
          ),

          SizedBox(height: tokens.spacing.lg),

          // Recent Achievements
          Text(
            '最近の実績',
            style: tokens.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),

          SizedBox(height: tokens.spacing.md),

          FutureBuilder<List<Badge>>(
            future: _getRecentBadges(uid),
            builder: (context, snapshot) {
              final badges = snapshot.data ?? [];
              if (badges.isEmpty) {
                return _buildEmptyAchievements(tokens);
              }
              return _buildRecentAchievements(tokens, badges);
            },
          ),

          SizedBox(height: tokens.spacing.lg),

          // Quick Actions
          _buildQuickActions(tokens, uid),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(MinqTheme tokens) {
    final uid = ref.watch(uidProvider);
    if (uid == null) return const Center(child: Text('ログインが必要です'));

    return FutureBuilder<List<Badge>>(
      future: _getAllUserBadges(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final badges = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: EdgeInsets.all(tokens.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '獲得バッジ (${badges.length})',
                style: tokens.typography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),

              SizedBox(height: tokens.spacing.lg),

              if (badges.isEmpty)
                _buildEmptyBadges(tokens)
              else
                _buildBadgeGrid(tokens, badges),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingTab(MinqTheme tokens) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ランキング',
            style: tokens.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),

          SizedBox(height: tokens.spacing.lg),

          // Coming soon placeholder
          Container(
            padding: EdgeInsets.all(tokens.spacing.xl),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.leaderboard,
                  size: tokens.spacing.xl * 2,
                  color: tokens.textMuted,
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  'ランキング機能',
                  style: tokens.typography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.textMuted,
                  ),
                ),
                SizedBox(height: tokens.spacing.sm),
                Text(
                  '他のユーザーとの競争機能を準備中です',
                  style: tokens.typography.body.copyWith(
                    color: tokens.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSummaryCard(MinqTheme tokens, int points) {
    final gamificationEngine = ref.watch(gamificationEngineProvider);
    final rank = gamificationEngine.getRankForPoints(points);

    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            tokens.brandSecondary.withAlpha((255 * 0.1).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(
          color: tokens.brandPrimary.withAlpha((255 * 0.3).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: tokens.brandPrimary,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                'ポイント概要',
                style: tokens.typography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  tokens,
                  '総ポイント',
                  '$points',
                  Icons.monetization_on,
                  tokens.brandPrimary,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: _buildStatItem(
                  tokens,
                  'ランク',
                  rank.name,
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    MinqTheme tokens,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: tokens.spacing.lg),
          SizedBox(height: tokens.spacing.sm),
          Text(
            value,
            style: tokens.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(MinqTheme tokens, List<Badge> badges) {
    return Column(
      children: badges.take(3).map((badge) {
        return Container(
          margin: EdgeInsets.only(bottom: tokens.spacing.md),
          padding: EdgeInsets.all(tokens.spacing.md),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(tokens.radius.md),
            border: Border.all(color: tokens.border),
          ),
          child: Row(
            children: [
              Container(
                width: tokens.spacing.xl,
                height: tokens.spacing.xl,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [tokens.brandPrimary, tokens.brandSecondary],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.military_tech,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: tokens.spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      badge.name,
                      style: tokens.typography.body.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    Text(
                      badge.description,
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(badge.earnedAt),
                style: tokens.typography.caption.copyWith(
                  color: tokens.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyAchievements(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.xl),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.military_tech,
            size: tokens.spacing.xl * 2,
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing.md),
          Text(
            'まだ実績がありません',
            style: tokens.typography.body.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            'クエストを完了して最初の実績を獲得しましょう！',
            style: tokens.typography.caption.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(MinqTheme tokens, List<Badge> badges) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return GestureDetector(
          onTap: () async {
            await HapticsSystem.lightImpact();
            _showBadgeDetails(badge);
          },
          child: Container(
            padding: EdgeInsets.all(tokens.spacing.md),
            decoration: BoxDecoration(
              color: tokens.surface,
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              border: Border.all(color: tokens.border),
              boxShadow: [
                BoxShadow(
                  color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: tokens.spacing.xl * 2,
                  height: tokens.spacing.xl * 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tokens.brandPrimary, tokens.brandSecondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: tokens.spacing.md),
                Text(
                  badge.name,
                  style: tokens.typography.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tokens.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  _formatDate(badge.earnedAt),
                  style: tokens.typography.caption.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyBadges(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.xl),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        border: Border.all(color: tokens.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.military_tech,
            size: tokens.spacing.xl * 3,
            color: tokens.textMuted,
          ),
          SizedBox(height: tokens.spacing.lg),
          Text(
            'バッジコレクション',
            style: tokens.typography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textMuted,
            ),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            'クエストを完了してバッジを集めましょう！\n継続することで特別なバッジも獲得できます。',
            style: tokens.typography.body.copyWith(
              color: tokens.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(MinqTheme tokens, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クイックアクション',
          style: tokens.typography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: tokens.textPrimary,
          ),
        ),

        SizedBox(height: tokens.spacing.md),

        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                tokens,
                'テストポイント獲得',
                Icons.add_circle,
                () => _awardTestPoints(uid),
              ),
            ),
            SizedBox(width: tokens.spacing.md),
            Expanded(
              child: _buildActionButton(
                tokens,
                'バッジチェック',
                Icons.military_tech,
                () => _checkBadges(uid),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    MinqTheme tokens,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () async {
        await HapticsSystem.buttonTap();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.md),
        decoration: BoxDecoration(
          color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
          borderRadius: BorderRadius.circular(tokens.radius.md),
          border: Border.all(
            color: tokens.brandPrimary.withAlpha((255 * 0.3).round()),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: tokens.brandPrimary,
              size: tokens.spacing.lg,
            ),
            SizedBox(height: tokens.spacing.sm),
            Text(
              label,
              style: tokens.typography.caption.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Badge>> _getRecentBadges(String uid) async {
    // This would fetch recent badges from the gamification engine
    // For now, return empty list
    return [];
  }

  Future<List<Badge>> _getAllUserBadges(String uid) async {
    // This would fetch all user badges from the gamification engine
    // For now, return empty list
    return [];
  }

  void _showBadgeDetails(Badge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(badge.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description),
            const SizedBox(height: 16),
            Text(
              '獲得日: ${_formatDate(badge.earnedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
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

  Future<void> _awardTestPoints(String uid) async {
    final gamificationEngine = ref.read(gamificationEngineProvider);
    await gamificationEngine.awardHabitPoints(
      userId: uid,
      action: HabitAction.questComplete,
      context: context,
    );
    setState(() {}); // Refresh the UI
  }

  Future<void> _checkBadges(String uid) async {
    final gamificationEngine = ref.read(gamificationEngineProvider);
    await gamificationEngine.checkAndAwardBadges(uid, context: context);
    setState(() {}); // Refresh the UI
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}