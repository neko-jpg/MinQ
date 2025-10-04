import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/core/achievements/achievement_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// アチ�Eブメント一覧画面
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final achievementSystem = AchievementSystem();
    final allAchievements = achievementSystem.getAllAchievements();
    final unlockedAchievements = achievementSystem.getUnlockedAchievements();

    return Scaffold(
      backgroundColor: tokens.background,
      appBar: AppBar(
        title: Text(
          'アチ�EブメンチE,
          style: tokens.typography.h3.copyWith(
            color: tokens.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        backgroundColor: tokens.background.withValues(alpha: 0.9),
        elevation: 0,
      ),
      body: Column(
        children: [
          // 統計サマリー
          _buildSummary(tokens, unlockedAchievements.length, allAchievements.length),
          // アチ�EブメントリスチE
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(tokens.spacing.md),
              itemCount: allAchievements.length,
              itemBuilder: (context, index) {
                final achievement = allAchievements[index];
                final isUnlocked = unlockedAchievements.contains(achievement);
                return _AchievementCard(
                  achievement: achievement,
                  isUnlocked: isUnlocked,
                  tokens: tokens,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary(MinqTheme tokens, int unlocked, int total) {
    final percentage = total > 0 ? (unlocked / total * 100).toInt() : 0;

    return Container(
      margin: EdgeInsets.all(tokens.spacing.md),
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tokens.primary,
            tokens.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
      child: Column(
        children: [
          const Text(
            '🏆',
            style: TextStyle(fontSize: 48),
          ),
          SizedBox(height: tokens.spacing.sm),
          Text(
            '$unlocked / $total',
            style: tokens.typography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'アチ�Eブメント達戁E,
            style: tokens.typography.body.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: tokens.spacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radius.full),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: tokens.spacing.xs),
          Text(
            '$percentage% 完亁E,
            style: tokens.typography.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// アチ�EブメントカーチE
class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;
  final MinqTheme tokens;

  const _AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    required this.tokens,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      elevation: 0,
      color: tokens.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radius.lg),
        side: BorderSide(
          color: isUnlocked ? tokens.primary : tokens.border,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Row(
          children: [
            // アイコン
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? tokens.primary.withValues(alpha: 0.2)
                    : tokens.background,
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 32,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(width: tokens.spacing.md),
            // チE��スチE
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: tokens.typography.body.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isUnlocked
                                ? tokens.textPrimary
                                : tokens.textSecondary,
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spacing.sm,
                            vertical: tokens.spacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.primary,
                            borderRadius: BorderRadius.circular(tokens.radius.full),
                          ),
                          child: Text(
                            '達�E',
                            style: tokens.typography.caption.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  Text(
                    achievement.description,
                    style: tokens.typography.caption.copyWith(
                      color: tokens.textSecondary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.sm),
                  // 進捗バー�E�未達�Eの場合！E
                  if (!isUnlocked) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radius.full),
                      child: LinearProgressIndicator(
                        value: 0.5, // TODO: 実際の進捗を表示
                        minHeight: 4,
                        backgroundColor: tokens.background,
                        valueColor: AlwaysStoppedAnimation<Color>(tokens.primary),
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '5 / ${achievement.requirement}', // TODO: 実際の進捗を表示
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// バッジウィジェチE���E��Eロフィールなどで使用�E�E
class BadgeWidget extends StatelessWidget {
  final Achievement achievement;
  final double size;

  const BadgeWidget({
    super.key,
    required this.achievement,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tokens.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: tokens.primary,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          achievement.icon,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}

/// バッジ一覧ウィジェチE���E��Eロフィールで使用�E�E
class BadgeListWidget extends StatelessWidget {
  final List<Achievement> achievements;
  final int maxDisplay;

  const BadgeListWidget({
    super.key,
    required this.achievements,
    this.maxDisplay = 5,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final displayAchievements = achievements.take(maxDisplay).toList();
    final remaining = achievements.length - displayAchievements.length;

    return Row(
      children: [
        ...displayAchievements.map((achievement) {
          return Padding(
            padding: EdgeInsets.only(right: tokens.spacing.xs),
            child: BadgeWidget(achievement: achievement, size: 40),
          );
        }),
        if (remaining > 0)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tokens.surface,
              shape: BoxShape.circle,
              border: Border.all(color: tokens.border),
            ),
            child: Center(
              child: Text(
                '+$remaining',
                style: tokens.typography.caption.copyWith(
                  color: tokens.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
