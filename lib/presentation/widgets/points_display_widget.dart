import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/data/providers.dart' as providers;
import 'package:minq/presentation/theme/minq_theme.dart';

/// ポイント表示ウィジェット
/// ユーザーの現在のポイントとランクを表示
class PointsDisplayWidget extends ConsumerWidget {
  const PointsDisplayWidget({
    super.key,
    this.showRank = true,
    this.compact = false,
  });

  final bool showRank;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final uid = ref.watch(providers.uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final gamificationEngine = ref.watch(providers.gamificationEngineProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadPointsData(gamificationEngine, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildSkeleton(tokens, compact);
        }

        final data = snapshot.data!;
        final points = data['points'] as int;
        final rank = data['rank'] as String;
        final rankIcon = data['rankIcon'] as IconData;

        if (compact) {
          return _buildCompactView(tokens, points, rank, rankIcon);
        }

        return _buildFullView(tokens, points, rank, rankIcon);
      },
    );
  }

  Widget _buildSkeleton(MinqTheme tokens, bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(3),
        vertical: tokens.spacing(2),
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: tokens.cornerMedium(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: tokens.spacing(6),
            height: tokens.spacing(6),
            decoration: BoxDecoration(
              color: tokens.textMuted.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: tokens.spacing(2)),
          Container(
            width: compact ? tokens.spacing(12) : tokens.spacing(20),
            height: tokens.spacing(4),
            decoration: BoxDecoration(
              color: tokens.textMuted.withOpacity(0.3),
              borderRadius: tokens.cornerSmall(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactView(
    MinqTheme tokens,
    int points,
    String rank,
    IconData rankIcon,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing(3),
        vertical: tokens.spacing(2),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tokens.brandPrimary, tokens.brandPrimary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerMedium(),
        boxShadow: [
          BoxShadow(
            color: tokens.brandPrimary.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(rankIcon, color: Colors.white, size: tokens.spacing(5)),
          SizedBox(width: tokens.spacing(2)),
          Text(
            '$points',
            style: tokens.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullView(
    MinqTheme tokens,
    int points,
    String rank,
    IconData rankIcon,
  ) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing(3)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [tokens.brandPrimary, tokens.brandPrimary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: tokens.cornerLarge(),
        boxShadow: [
          BoxShadow(
            color: tokens.brandPrimary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: tokens.spacing(10),
            height: tokens.spacing(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(rankIcon, color: Colors.white, size: tokens.spacing(6)),
          ),
          SizedBox(width: tokens.spacing(3)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showRank) ...[
                Text(
                  rank,
                  style: tokens.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: tokens.spacing(0.5)),
              ],
              Text(
                '$points ポイント',
                style: tokens.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _loadPointsData(
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

    return {'points': points, 'rank': rank.name, 'rankIcon': rankIcon};
  }
}

/// アニメーション付きポイント表示ウィジェット
class AnimatedPointsWidget extends StatefulWidget {
  const AnimatedPointsWidget({
    super.key,
    required this.points,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
  });

  final int points;
  final Duration duration;
  final TextStyle? style;

  @override
  State<AnimatedPointsWidget> createState() => _AnimatedPointsWidgetState();
}

class _AnimatedPointsWidgetState extends State<AnimatedPointsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;
  int _previousPoints = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _updateAnimation();
  }

  @override
  void didUpdateWidget(AnimatedPointsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.points != widget.points) {
      _previousPoints = oldWidget.points;
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    _animation = IntTween(
      begin: _previousPoints,
      end: widget.points,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text('${_animation.value}', style: widget.style);
      },
    );
  }
}

/// ランクプログレスウィジェット
class RankProgressWidget extends ConsumerWidget {
  const RankProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = MinqTheme.of(context);
    final uid = ref.watch(providers.uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final gamificationEngine = ref.watch(providers.gamificationEngineProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _loadRankData(gamificationEngine, uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: tokens.spacing(20),
            decoration: BoxDecoration(
              color: tokens.surfaceVariant,
              borderRadius: tokens.cornerMedium(),
            ),
          );
        }

        final data = snapshot.data!;
        final currentRank = data['currentRank'] as String;
        final nextRank = data['nextRank'] as String?;
        final progress = data['progress'] as double;
        final pointsToNext = data['pointsToNext'] as int;

        return Container(
          padding: EdgeInsets.all(tokens.spacing(4)),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: tokens.cornerLarge(),
            border: Border.all(color: tokens.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '現在のランク',
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                  ),
                  Text(
                    currentRank,
                    style: tokens.titleMedium.copyWith(
                      color: tokens.brandPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (nextRank != null) ...[
                SizedBox(height: tokens.spacing(3)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '次のランクまで',
                      style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                    ),
                    Text(
                      '$pointsToNext ポイント',
                      style: tokens.bodySmall.copyWith(
                        color: tokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: tokens.spacing(2)),
                ClipRRect(
                  borderRadius: tokens.cornerSmall(),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: tokens.spacing(2),
                    backgroundColor: tokens.brandPrimary.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(tokens.brandPrimary),
                  ),
                ),
                SizedBox(height: tokens.spacing(1)),
                Text(
                  '次のランク: $nextRank',
                  style: tokens.bodySmall.copyWith(color: tokens.textMuted),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _loadRankData(
    GamificationEngine engine,
    String uid,
  ) async {
    final points = await engine.getUserPoints(uid);
    final currentRank = engine.getRankForPoints(points);

    // 次のランク情報を計算
    final allRanks = [
      {'name': 'ブロンズ', 'points': 0},
      {'name': 'シルバー', 'points': 1000},
      {'name': 'ゴールド', 'points': 5000},
      {'name': 'プラチナ', 'points': 15000},
      {'name': 'ダイヤモンド', 'points': 50000},
    ];

    String? nextRank;
    int nextRankPoints = 50000;
    int currentRankPoints = currentRank.minPoints;

    for (int i = 0; i < allRanks.length; i++) {
      final rankPoints = allRanks[i]['points'] as int;
      if (points >= rankPoints && i < allRanks.length - 1) {
        nextRank = allRanks[i + 1]['name'] as String;
        nextRankPoints = allRanks[i + 1]['points'] as int;
        break;
      }
    }

    final progress =
        nextRank != null
            ? (points - currentRankPoints) /
                (nextRankPoints - currentRankPoints)
            : 1.0;

    return {
      'currentRank': currentRank.name,
      'nextRank': nextRank,
      'progress': progress.clamp(0.0, 1.0),
      'pointsToNext': nextRank != null ? nextRankPoints - points : 0,
    };
  }
}
