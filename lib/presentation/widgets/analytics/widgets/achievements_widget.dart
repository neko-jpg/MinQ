import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

class AchievementsWidget extends ConsumerWidget {
  final DashboardWidgetConfig config;

  const AchievementsWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 実際の実績データプロバイダーを実装
    final achievements = _getMockAchievements();

    return _buildAchievementsList(context, achievements);
  }

  Widget _buildAchievementsList(
    BuildContext context,
    List<Achievement> achievements,
  ) {
    if (achievements.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      itemCount: achievements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(context, achievement);
      },
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            achievement.isUnlocked
                ? _getRarityColor(achievement.rarity).withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color:
              achievement.isUnlocked
                  ? _getRarityColor(achievement.rarity).withOpacity(0.3)
                  : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  achievement.isUnlocked
                      ? _getRarityColor(achievement.rarity)
                      : Colors.grey,
              shape: BoxShape.circle,
            ),
            child: Icon(achievement.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: achievement.isUnlocked ? null : Colors.grey,
                        ),
                      ),
                    ),
                    if (achievement.isUnlocked)
                      _buildRarityBadge(context, achievement.rarity),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        achievement.isUnlocked
                            ? Theme.of(context).textTheme.bodySmall?.color
                            : Colors.grey,
                  ),
                ),
                if (!achievement.isUnlocked &&
                    achievement.progress != null) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(achievement.progress! * 100).toStringAsFixed(0)}% 完了',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityBadge(BuildContext context, AchievementRarity rarity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getRarityColor(rarity),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _getRarityText(rarity),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.emoji_events, size: 32, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            '実績なし',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          Text(
            'クエストを完了して\n実績を解除しましょう',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
    }
  }

  String _getRarityText(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 'コモン';
      case AchievementRarity.rare:
        return 'レア';
      case AchievementRarity.epic:
        return 'エピック';
      case AchievementRarity.legendary:
        return 'レジェンド';
    }
  }

  List<Achievement> _getMockAchievements() {
    // TODO: 実際のデータソースから取得
    return [
      Achievement(
        title: '初回完了',
        description: '最初のクエストを完了する',
        icon: Icons.star,
        rarity: AchievementRarity.common,
        isUnlocked: true,
      ),
      Achievement(
        title: '7日連続',
        description: '7日間連続でクエストを完了する',
        icon: Icons.local_fire_department,
        rarity: AchievementRarity.rare,
        isUnlocked: true,
      ),
      Achievement(
        title: '100回完了',
        description: 'クエストを100回完了する',
        icon: Icons.emoji_events,
        rarity: AchievementRarity.epic,
        isUnlocked: false,
        progress: 0.65,
      ),
      Achievement(
        title: 'パーフェクト月',
        description: '1ヶ月間毎日クエストを完了する',
        icon: Icons.calendar_month,
        rarity: AchievementRarity.legendary,
        isUnlocked: false,
        progress: 0.23,
      ),
    ];
  }
}

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final AchievementRarity rarity;
  final bool isUnlocked;
  final double? progress;

  Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.rarity,
    required this.isUnlocked,
    this.progress,
  });
}

enum AchievementRarity { common, rare, epic, legendary }
