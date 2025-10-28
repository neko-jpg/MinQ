import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart'
    show GamificationEngine;
import 'package:minq/data/providers.dart';

/// ゲーミフィケーションステータスカード
/// ホーム画面に表示されるポイント、ランク、バッジ情報
class GamificationStatusCard extends ConsumerWidget {
  const GamificationStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final gamificationEngine = ref.watch(gamificationEngineProvider);

    // Firestoreが利用できない場合は空のウィジェットを返す
    if (gamificationEngine == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadGamificationData(gamificationEngine, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            elevation: 0,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '読み込み中...',
                    style:
                        textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data!;
        final points = data['points'] as int;
        final rank = data['rank'] as String;
        final rankIcon = data['rankIcon'] as IconData;
        final nextRankPoints = data['nextRankPoints'] as int;
        final progress = data['progress'] as double;

        return Card(
          elevation: 0,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.outline),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withAlpha((255 * 0.6).round()),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary
                                .withAlpha((255 * 0.3).round()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        rankIcon,
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
                            rank,
                            style: textTheme.headlineSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$points ポイント',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '次のランクまで',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${nextRankPoints - points} ポイント',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor:
                            colorScheme.primary.withAlpha((255 * 0.1).round()),
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadGamificationData(
    GamificationEngine engine,
    String uid,
  ) async {
    final points = await engine.getUserPoints(uid);
    final rank = engine.getRankForPoints(points);

    // ランクアイコンを決定
    IconData rankIcon;
    switch (rank.name) {
      case 'ブロンズ':
        rankIcon = Icons.workspace_premium;
        break;
      case 'シルバー':
        rankIcon = Icons.military_tech;
        break;
      case 'ゴールド':
        rankIcon = Icons.emoji_events;
        break;
      case 'プラチナ':
        rankIcon = Icons.diamond;
        break;
      case 'ダイヤモンド':
        rankIcon = Icons.auto_awesome;
        break;
      default:
        rankIcon = Icons.star;
    }

    // 次のランクまでの進捗を計算
    final allRanks = [
      {'name': 'ブロンズ', 'points': 0},
      {'name': 'シルバー', 'points': 1000},
      {'name': 'ゴールド', 'points': 5000},
      {'name': 'プラチナ', 'points': 15000},
      {'name': 'ダイヤモンド', 'points': 50000},
    ];

    int nextRankPoints = 50000;
    int currentRankPoints = 0;

    for (int i = 0; i < allRanks.length; i++) {
      final rankPoints = allRanks[i]['points'] as int;
      if (points >= rankPoints) {
        currentRankPoints = rankPoints;
        if (i < allRanks.length - 1) {
          nextRankPoints = allRanks[i + 1]['points'] as int;
        }
      }
    }

    final progress =
        (points - currentRankPoints) / (nextRankPoints - currentRankPoints);

    return {
      'points': points,
      'rank': rank.name,
      'rankIcon': rankIcon,
      'nextRankPoints': nextRankPoints,
      'progress': progress.clamp(0.0, 1.0),
    };
  }
}
