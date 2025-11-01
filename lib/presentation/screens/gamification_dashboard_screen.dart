import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart'
    hide gamificationEngineProvider;
import 'package:minq/data/providers.dart';
import 'package:minq/domain/gamification/badge.dart';
import 'package:minq/presentation/theme/haptics_system.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

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
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
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
    return Scaffold(
      backgroundColor: MinqTokens.background,
      appBar: AppBar(
        title: Text(
          'ゲーミフィケーション',
          style: MinqTokens.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: MinqTokens.textPrimary,
          ),
        ),
        backgroundColor: MinqTokens.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: MinqTokens.brandPrimary,
          unselectedLabelColor: MinqTokens.textSecondary,
          indicatorColor: MinqTokens.brandPrimary,
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
            _buildProgressTab(),
            _buildBadgesTab(),
            _buildRankingTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    final uid = ref.watch(uidProvider);
    if (uid == null) return const Center(child: Text('ログインが必要です'));

    final gamificationEngine = ref.watch(gamificationEngineProvider);

    return SingleChildScrollView(
      padding: EdgeInsets.all(MinqTokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Progress Placeholder
          Container(
            padding: EdgeInsets.all(MinqTokens.spacing(4)),
            decoration: BoxDecoration(
              color: MinqTokens.surface,
              borderRadius: MinqTokens.cornerLarge(),
            ),
            child: const Center(
              child: Text('Enhanced Level Progress Widget Placeholder'),
            ),
          ),

          SizedBox(height: MinqTokens.spacing(4)),

          // Points Summary Card
          FutureBuilder<int>(
            future: gamificationEngine?.getUserPoints(uid),
            builder: (context, snapshot) {
              final points = snapshot.data ?? 0;
              return _buildPointsSummaryCard(points);
            },
          ),

          SizedBox(height: MinqTokens.spacing(4)),

          // Recent Achievements
          Text(
            '最近の実績',
            style: MinqTokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: MinqTokens.textPrimary,
            ),
          ),

          SizedBox(height: MinqTokens.spacing(3)),

          FutureBuilder<List<Badge>>(
            future: _getRecentBadges(uid),
            builder: (context, snapshot) {
              final badges = snapshot.data ?? [];
              if (badges.isEmpty) {
                return _buildEmptyAchievements();
              }
              return _buildRecentAchievements(badges);
            },
          ),

          SizedBox(height: MinqTokens.spacing(4)),

          // Quick Actions
          _buildQuickActions(uid),
        ],
      ),
    );
  }

  Widget _buildBadgesTab() {
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
          padding: EdgeInsets.all(MinqTokens.spacing(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '獲得バッジ (${badges.length})',
                style: MinqTokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MinqTokens.textPrimary,
                ),
              ),

              SizedBox(height: MinqTokens.spacing(4)),

              if (badges.isEmpty)
                _buildEmptyBadges()
              else
                _buildBadgeGrid(badges),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MinqTokens.spacing(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ランキング',
            style: MinqTokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: MinqTokens.textPrimary,
            ),
          ),

          SizedBox(height: MinqTokens.spacing(4)),

          // Coming soon placeholder
          Container(
            padding: EdgeInsets.all(MinqTokens.spacing(6)),
            decoration: BoxDecoration(
              color: MinqTokens.background,
              borderRadius: MinqTokens.cornerLarge(),
              border: Border.all(color: Colors.transparent),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.leaderboard,
                  size: MinqTokens.spacing(12),
                  color: MinqTokens.textSecondary,
                ),
                SizedBox(height: MinqTokens.spacing(3)),
                Text(
                  'ランキング機能',
                  style: MinqTokens.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MinqTokens.textSecondary,
                  ),
                ),
                SizedBox(height: MinqTokens.spacing(1)),
                Text(
                  '他のユーザーとの競争機能を準備中です',
                  style: MinqTokens.bodyMedium.copyWith(
                    color: MinqTokens.textSecondary,
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

  Widget _buildPointsSummaryCard(int points) {
    final gamificationEngine = ref.watch(gamificationEngineProvider);
    if (gamificationEngine == null) {
      return const SizedBox.shrink();
    }
    final rank = gamificationEngine.getRankForPoints(points);

    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(4)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
            MinqTokens.brandSecondary.withAlpha((255 * 0.1).round()),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: MinqTokens.cornerLarge(),
        border: Border.all(
          color: MinqTokens.brandPrimary.withAlpha((255 * 0.3).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars,
                color: MinqTokens.brandPrimary,
                size: MinqTokens.spacing(4),
              ),
              SizedBox(width: MinqTokens.spacing(1)),
              Text(
                'ポイント概要',
                style: MinqTokens.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: MinqTokens.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: MinqTokens.spacing(4)),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  '総ポイント',
                  '$points',
                  Icons.monetization_on,
                  MinqTokens.brandPrimary,
                ),
              ),
              SizedBox(width: MinqTokens.spacing(3)),
              Expanded(
                child: _buildStatItem(
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
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(3)),
      decoration: BoxDecoration(
        color: MinqTokens.surface,
        borderRadius: MinqTokens.cornerMedium(),
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: MinqTokens.spacing(4)),
          SizedBox(height: MinqTokens.spacing(1)),
          Text(
            value,
            style: MinqTokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: MinqTokens.bodySmall.copyWith(
              color: MinqTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAchievements(List<Badge> badges) {
    return Column(
      children:
          badges.take(3).map((badge) {
            return Container(
              margin: EdgeInsets.only(bottom: MinqTokens.spacing(3)),
              padding: EdgeInsets.all(MinqTokens.spacing(3)),
              decoration: BoxDecoration(
                color: MinqTokens.surface,
                borderRadius: MinqTokens.cornerMedium(),
                border: Border.all(color: Colors.transparent),
              ),
              child: Row(
                children: [
                  Container(
                    width: MinqTokens.spacing(6),
                    height: MinqTokens.spacing(6),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          MinqTokens.brandPrimary,
                          MinqTokens.brandSecondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.military_tech, color: Colors.white),
                  ),
                  SizedBox(width: MinqTokens.spacing(3)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badge.name,
                          style: MinqTokens.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: MinqTokens.textPrimary,
                          ),
                        ),
                        Text(
                          badge.description,
                          style: MinqTokens.bodySmall.copyWith(
                            color: MinqTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatDate(badge.earnedAt),
                    style: MinqTokens.bodySmall.copyWith(
                      color: MinqTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildEmptyAchievements() {
    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(6)),
      decoration: BoxDecoration(
        color: MinqTokens.background,
        borderRadius: MinqTokens.cornerLarge(),
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        children: [
          Icon(
            Icons.military_tech,
            size: MinqTokens.spacing(12),
            color: MinqTokens.textSecondary,
          ),
          SizedBox(height: MinqTokens.spacing(3)),
          Text(
            'まだ実績がありません',
            style: MinqTokens.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: MinqTokens.textSecondary,
            ),
          ),
          SizedBox(height: MinqTokens.spacing(1)),
          Text(
            'クエストを完了して最初の実績を獲得しましょう！',
            style: MinqTokens.bodySmall.copyWith(
              color: MinqTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid(List<Badge> badges) {
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
            padding: EdgeInsets.all(MinqTokens.spacing(3)),
            decoration: BoxDecoration(
              color: MinqTokens.surface,
              borderRadius: MinqTokens.cornerLarge(),
              border: Border.all(color: Colors.transparent),
              boxShadow: [
                BoxShadow(
                  color: MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MinqTokens.spacing(12),
                  height: MinqTokens.spacing(12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        MinqTokens.brandPrimary,
                        MinqTokens.brandSecondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                SizedBox(height: MinqTokens.spacing(3)),
                Text(
                  badge.name,
                  style: MinqTokens.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: MinqTokens.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: MinqTokens.spacing(1)),
                Text(
                  _formatDate(badge.earnedAt),
                  style: MinqTokens.bodySmall.copyWith(
                    color: MinqTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyBadges() {
    return Container(
      padding: EdgeInsets.all(MinqTokens.spacing(6)),
      decoration: BoxDecoration(
        color: MinqTokens.background,
        borderRadius: MinqTokens.cornerLarge(),
        border: Border.all(color: Colors.transparent),
      ),
      child: Column(
        children: [
          Icon(
            Icons.military_tech,
            size: MinqTokens.spacing(14),
            color: MinqTokens.textSecondary,
          ),
          SizedBox(height: MinqTokens.spacing(4)),
          Text(
            'バッジコレクション',
            style: MinqTokens.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: MinqTokens.textSecondary,
            ),
          ),
          SizedBox(height: MinqTokens.spacing(1)),
          Text(
            'クエストを完了してバッジを集めましょう！\n継続することで特別なバッジも獲得できます。',
            style: MinqTokens.bodyMedium.copyWith(
              color: MinqTokens.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クイックアクション',
          style: MinqTokens.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: MinqTokens.textPrimary,
          ),
        ),

        SizedBox(height: MinqTokens.spacing(3)),

        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'テストポイント獲得',
                Icons.add_circle,
                () => _awardTestPoints(uid),
              ),
            ),
            SizedBox(width: MinqTokens.spacing(3)),
            Expanded(
              child: _buildActionButton(
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

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: () async {
        await HapticsSystem.buttonTap();
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(MinqTokens.spacing(3)),
        decoration: BoxDecoration(
          color: MinqTokens.brandPrimary.withAlpha((255 * 0.1).round()),
          borderRadius: MinqTokens.cornerMedium(),
          border: Border.all(
            color: MinqTokens.brandPrimary.withAlpha((255 * 0.3).round()),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: MinqTokens.brandPrimary,
              size: MinqTokens.spacing(4),
            ),
            SizedBox(height: MinqTokens.spacing(1)),
            Text(
              label,
              style: MinqTokens.bodySmall.copyWith(
                color: MinqTokens.brandPrimary,
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
      builder:
          (context) => AlertDialog(
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
    await gamificationEngine?.awardHabitPoints(
      userId: uid,
      action: HabitAction.questComplete,
      context: context,
    );
    setState(() {}); // Refresh the UI
  }

  Future<void> _checkBadges(String uid) async {
    final gamificationEngine = ref.read(gamificationEngineProvider);
    await gamificationEngine?.checkAndAwardBadges(uid, context: context);
    setState(() {}); // Refresh the UI
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
