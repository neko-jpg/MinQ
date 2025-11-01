import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/core/gamification/services/league_system.dart';
import 'package:minq/domain/gamification/league.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

/// Animated celebration for league promotions.
class LeaguePromotionAnimation extends StatefulWidget {
  const LeaguePromotionAnimation({
    super.key,
    required this.promotion,
    this.onComplete,
  });

  final LeaguePromotion promotion;
  final VoidCallback? onComplete;

  @override
  State<LeaguePromotionAnimation> createState() =>
      _LeaguePromotionAnimationState();
}

class _LeaguePromotionAnimationState extends State<LeaguePromotionAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    );

    _scale = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 1.0, curve: Curves.elasticOut),
    );

    _controller.forward();
    HapticFeedback.heavyImpact();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromLeague = LeagueSystem.leagues[widget.promotion.fromLeague];
    final toLeague = LeagueSystem.leagues[widget.promotion.toLeague];
    final tokens = context.colorTokens;

    if (fromLeague == null || toLeague == null) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                tokens.primary,
                toLeague.color,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 72,
                    color: toLeague.color,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Promotion!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: tokens.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${fromLeague.nameEn} → ${toLeague.nameEn}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: tokens.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _RewardList(rewards: toLeague.rewards),
                  const SizedBox(height: 24),
                  Text(
                    'Weekly XP earned: ${widget.promotion.xpEarned}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: tokens.textPrimary,
                        ),
                  ),
                  Text(
                    'Total XP: ${widget.promotion.totalXP}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: tokens.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardList extends StatelessWidget {
  const _RewardList({required this.rewards});

  final LeagueRewards rewards;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    final items = <Widget>[
      _RewardRow(
        icon: Icons.local_fire_department,
        label: '${rewards.weeklyXP} bonus weekly XP',
      ),
    ];

    for (final badge in rewards.badges) {
      items.add(
        _RewardRow(
          icon: Icons.military_tech,
          label: 'New badge: $badge',
        ),
      );
    }

    for (final unlock in rewards.unlocks) {
      items.add(
        _RewardRow(
          icon: Icons.lock_open,
          label: 'Unlocked feature: ${_formatUnlock(unlock)}',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rewards unlocked',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  String _formatUnlock(String unlock) {
    return unlock
        .replaceAll('_', ' ')
        .split(' ')
        .map((part) => part.isEmpty
            ? part
            : part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: tokens.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: tokens.textPrimary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
