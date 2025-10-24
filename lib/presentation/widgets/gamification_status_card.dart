import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart'
    show GamificationEngine;
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// ゲーミフィケーションステータスカード
/// ホーム画面に表示されるポイント、ランク、バッジ情報
class GamificationStatusCard extends ConsumerWidget {
  const GamificationStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final gamificationEngine = ref.watch(gamificationEngineProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadGamificationData(gamificationEngine, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            elevation: 0,
            color: tokens.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radius.lg),
              side: BorderSide(color: tokens.border),
            ),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing.lg),
              child: Row(
                children: [
                  SizedBox(
                    width: tokens.spacing.lg,
                    height: tokens.spacing.lg,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
                    ),
                  ),
                  SizedBox(width: tokens.spacing.md),
                  Text(
                    '読み込み中...',
                    style:
                        tokens.typography.body.copyWith(color: tokens.textMuted),
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
          color: tokens.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.lg),
            side: BorderSide(color: tokens.border),
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: tokens.spacing.xl,
                      height: tokens.spacing.xl,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tokens.brandPrimary,
                            tokens.brandPrimary.withAlpha((255 * 0.6).round()),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(tokens.radius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.brandPrimary
                                .withAlpha((255 * 0.3).round()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        rankIcon,
                        color: Colors.white,
                        size: tokens.spacing.lg,
                      ),
                    ),
                    SizedBox(width: tokens.spacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rank,
                            style: tokens.typography.h3.copyWith(
                              color: tokens.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: tokens.spacing.xs),
                          Text(
                            '$points ポイント',
                            style: tokens.typography.body.copyWith(
                              color: tokens.brandPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: tokens.spacing.lg,
                      color: tokens.textMuted,
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '次のランクまで',
                          style: tokens.typography.caption.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                        Text(
                          '${nextRankPoints - points} ポイント',
                          style: tokens.typography.caption.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.spacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(tokens.radius.sm),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: tokens.spacing.sm,
                        backgroundColor:
                            tokens.brandPrimary.withAlpha((255 * 0.1).round()),
                        valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
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
