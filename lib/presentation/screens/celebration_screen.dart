import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:minq/presentation/common/minq_buttons.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CelebrationScreen extends StatefulWidget {
  const CelebrationScreen({super.key});

  @override
  State<CelebrationScreen> createState() => _CelebrationScreenState();
}

class _CelebrationScreenState extends State<CelebrationScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _confettiDuration = Duration(milliseconds: 900);

  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _sparkleAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.1, 0.8, curve: Curves.easeOutBack),
    );

    Future<void>.delayed(_confettiDuration, () {
      if (!mounted) return;
      _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close, color: tokens.textPrimary),
                onPressed: () => context.go('/'),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _CelebrationBurst(
                      pulse: _pulseAnimation,
                      sparkles: _sparkleAnimation,
                    ),
                    SizedBox(height: tokens.spacing(6)),
                    Text(
                      'Streak +1',
                      style: tokens.titleLarge.copyWith(
                        color: tokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    Text(
                      'Great job logging today! Keep going.',
                      style: tokens.bodyMedium.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                    SizedBox(height: tokens.spacing(8)),
                    _buildRewardCard(tokens),
                  ],
                ),
              ),
            ),
            _buildNextAction(tokens, context),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardCard(MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.spacing(6)),
      child: Card(
        elevation: 0,
        color: tokens.brandPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
        child: ListTile(
          leading: Container(
            padding: EdgeInsets.all(tokens.spacing(3)),
            decoration: BoxDecoration(
              color: tokens.brandPrimary.withValues(alpha: 0.18),
              borderRadius: tokens.cornerMedium(),
            ),
            child: Icon(
              Icons.self_improvement,
              color: tokens.brandPrimary,
              size: tokens.spacing(7),
            ),
          ),
          title: Text(
            '1-min Breathing Exercise',
            style: tokens.titleSmall.copyWith(color: tokens.textPrimary),
          ),
          subtitle: Text(
            'Relax and recenter',
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: tokens.spacing(4),
            color: tokens.textMuted,
          ),
          onTap: () {},
        ),
      ),
    );
  }

  Widget _buildNextAction(MinqTheme tokens, BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing(6),
        tokens.spacing(4),
        tokens.spacing(6),
        tokens.spacing(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          MinqPrimaryButton(
            label: '次のQuestへ',
            onPressed: () async => context.go('/'),
          ),
          SizedBox(height: tokens.spacing(3)),
          TextButton(
            onPressed: () => context.go('/home'),
            child: const Text('ホームに戻る'),
          ),
        ],
      ),
    );
  }
}

class _CelebrationBurst extends StatelessWidget {
  const _CelebrationBurst({required this.pulse, required this.sparkles});

  final Animation<double> pulse;
  final Animation<double> sparkles;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = tokens.brandPrimary;

    return AnimatedBuilder(
      animation: pulse,
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          width: tokens.spacing(48),
          height: tokens.spacing(48),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: tokens.spacing(28) * pulse.value,
                height: tokens.spacing(28) * pulse.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12 * pulse.value),
                ),
              ),
              ScaleTransition(
                scale: pulse,
                child: Container(
                  width: tokens.spacing(16),
                  height: tokens.spacing(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[color, color.withValues(alpha: 0.6)],
                    ),
                  ),
                  child: Icon(
                    Icons.celebration,
                    color: tokens.surface,
                    size: tokens.spacing(10),
                  ),
                ),
              ),
              ...List<Widget>.generate(8, (int index) {
                final angle = (math.pi / 4) * index;
                return _ConfettiSparkle(
                  angle: angle,
                  progress: sparkles.value,
                  color: color,
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiSparkle extends StatelessWidget {
  const _ConfettiSparkle({
    required this.angle,
    required this.progress,
    required this.color,
  });

  final double angle;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) {
      return const SizedBox.shrink();
    }
    final radius = progress * 60;
    final dx = math.cos(angle) * radius;
    final dy = math.sin(angle) * radius;

    return Positioned(
      left: 80 + dx,
      top: 80 + dy,
      child: Opacity(
        opacity: 1 - progress,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            width: 8,
            height: 12,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
