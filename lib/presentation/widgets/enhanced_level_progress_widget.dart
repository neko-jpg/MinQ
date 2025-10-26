import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/gamification/gamification_engine.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/haptics_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Enhanced level progress widget with smooth animations and micro-interactions
class EnhancedLevelProgressWidget extends ConsumerStatefulWidget {
  final bool isCompact;
  final VoidCallback? onTap;
  final bool showAnimations;

  const EnhancedLevelProgressWidget({
    super.key,
    this.isCompact = false,
    this.onTap,
    this.showAnimations = true,
  });

  @override
  ConsumerState<EnhancedLevelProgressWidget> createState() =>
      _EnhancedLevelProgressWidgetState();
}

class _EnhancedLevelProgressWidgetState
    extends ConsumerState<EnhancedLevelProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.linear),
    );

    if (widget.showAnimations) {
      _progressController.forward();
      _pulseController.repeat(reverse: true);
      _sparkleController.repeat();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final uid = ref.watch(uidProvider);

    if (uid == null) {
      return const SizedBox.shrink();
    }

    final gamificationEngine = ref.watch(gamificationEngineProvider);

    return FutureBuilder<LevelInfo>(
      future: gamificationEngine.getUserLevelInfo(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _buildLoadingWidget(tokens);
        }

        final levelInfo = snapshot.data!;
        
        if (widget.isCompact) {
          return _buildCompactWidget(context, tokens, levelInfo);
        }

        return _buildFullWidget(context, tokens, levelInfo);
      },
    );
  }

  Widget _buildCompactWidget(
    BuildContext context,
    MinqTheme tokens,
    LevelInfo levelInfo,
  ) {
    return GestureDetector(
      onTap: () async {
        await HapticsSystem.lightImpact();
        widget.onTap?.call();
      },
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.md),
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
          boxShadow: [
            BoxShadow(
              color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Animated level icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: tokens.spacing.xl * 1.5,
                    height: tokens.spacing.xl * 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          tokens.brandPrimary,
                          tokens.brandSecondary,
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: tokens.brandPrimary.withAlpha((255 * 0.4).round()),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            '${levelInfo.currentLevel}',
                            style: tokens.typography.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Sparkle effect
                        if (widget.showAnimations)
                          AnimatedBuilder(
                            animation: _sparkleAnimation,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(tokens.spacing.xl * 1.5, tokens.spacing.xl * 1.5),
                                painter: SparklePainter(
                                  animation: _sparkleAnimation.value,
                                  color: Colors.white.withAlpha(128),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

            SizedBox(width: tokens.spacing.md),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    levelInfo.currentLevelName,
                    style: tokens.typography.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: tokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.xs),
                  
                  if (!levelInfo.isMaxLevel) ...[
                    // Animated progress bar
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: tokens.border,
                            borderRadius: BorderRadius.circular(tokens.radius.sm),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: levelInfo.progress * _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tokens.brandPrimary,
                                    tokens.brandSecondary,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(tokens.radius.sm),
                                boxShadow: [
                                  BoxShadow(
                                    color: tokens.brandPrimary.withAlpha((255 * 0.3).round()),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '次のレベルまで ${levelInfo.pointsToNextLevel} ポイント',
                      style: tokens.typography.caption.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ] else
                    Text(
                      '最高レベル達成！',
                      style: tokens.typography.caption.copyWith(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
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
      ),
    );
  }

  Widget _buildFullWidget(
    BuildContext context,
    MinqTheme tokens,
    LevelInfo levelInfo,
  ) {
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
        boxShadow: [
          BoxShadow(
            color: tokens.brandPrimary.withAlpha((255 * 0.1).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: tokens.brandPrimary,
                size: tokens.spacing.lg,
              ),
              SizedBox(width: tokens.spacing.sm),
              Text(
                'レベル進捗',
                style: tokens.typography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tokens.textPrimary,
                ),
              ),
              const Spacer(),
              if (widget.onTap != null)
                GestureDetector(
                  onTap: widget.onTap,
                  child: Icon(
                    Icons.info_outline,
                    size: tokens.spacing.lg,
                    color: tokens.textMuted,
                  ),
                ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          // Level display
          Row(
            children: [
              // Animated level circle
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: tokens.spacing.xl * 3,
                      height: tokens.spacing.xl * 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tokens.brandPrimary,
                            tokens.brandSecondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: tokens.brandPrimary.withAlpha((255 * 0.4).round()),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              '${levelInfo.currentLevel}',
                              style: tokens.typography.h1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Sparkle effect
                          if (widget.showAnimations)
                            AnimatedBuilder(
                              animation: _sparkleAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(tokens.spacing.xl * 3, tokens.spacing.xl * 3),
                                  painter: SparklePainter(
                                    animation: _sparkleAnimation.value,
                                    color: Colors.white.withAlpha(128),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              SizedBox(width: tokens.spacing.lg),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      levelInfo.currentLevelName,
                      style: tokens.typography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: tokens.textPrimary,
                      ),
                    ),
                    SizedBox(height: tokens.spacing.xs),
                    Text(
                      '${levelInfo.currentPoints} ポイント',
                      style: tokens.typography.body.copyWith(
                        color: tokens.brandPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: tokens.spacing.lg),

          if (!levelInfo.isMaxLevel) ...[
            // Progress section
            _buildProgressSection(tokens, levelInfo),
          ] else ...[
            // Max level section
            _buildMaxLevelSection(tokens),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection(MinqTheme tokens, LevelInfo levelInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '次のレベルまで',
              style: tokens.typography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            Text(
              '${levelInfo.pointsToNextLevel} ポイント',
              style: tokens.typography.body.copyWith(
                color: tokens.brandPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: tokens.spacing.md),

        // Animated progress bar with glow effect
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Container(
              height: 12,
              decoration: BoxDecoration(
                color: tokens.border,
                borderRadius: BorderRadius.circular(tokens.radius.md),
              ),
              child: Stack(
                children: [
                  // Background glow
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(tokens.radius.md),
                      boxShadow: [
                        BoxShadow(
                          color: tokens.brandPrimary.withAlpha((255 * 0.2).round()),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Progress fill
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: levelInfo.progress * _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            tokens.brandPrimary,
                            tokens.brandSecondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(tokens.radius.md),
                        boxShadow: [
                          BoxShadow(
                            color: tokens.brandPrimary.withAlpha((255 * 0.4).round()),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        SizedBox(height: tokens.spacing.sm),

        // Progress percentage
        Text(
          '${(levelInfo.progress * 100).toInt()}% 完了',
          style: tokens.typography.caption.copyWith(
            color: tokens.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildMaxLevelSection(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withAlpha((255 * 0.2).round()),
            Colors.orange.withAlpha((255 * 0.2).round()),
          ],
        ),
        borderRadius: BorderRadius.circular(tokens.radius.md),
        border: Border.all(
          color: Colors.amber.withAlpha((255 * 0.4).round()),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: tokens.spacing.xl,
          ),
          SizedBox(width: tokens.spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最高レベル達成！',
                  style: tokens.typography.h3.copyWith(
                    color: Colors.amber.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: tokens.spacing.xs),
                Text(
                  '習慣形成の達人になりました！',
                  style: tokens.typography.body.copyWith(
                    color: Colors.amber.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(MinqTheme tokens) {
    return Container(
      padding: EdgeInsets.all(tokens.spacing.lg),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radius.lg),
      ),
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
            'レベル情報を読み込み中...',
            style: tokens.typography.body.copyWith(color: tokens.textMuted),
          ),
        ],
      ),
    );
  }
}

/// Sparkle effect painter for level icon
class SparklePainter extends CustomPainter {
  final double animation;
  final Color color;

  SparklePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withAlpha((255 * (0.5 + 0.5 * math.sin(animation * math.pi * 2))).round())
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw sparkles at different positions
    final sparklePositions = [
      Offset(center.dx + radius * 0.6 * math.cos(animation * math.pi * 2),
             center.dy + radius * 0.6 * math.sin(animation * math.pi * 2)),
      Offset(center.dx + radius * 0.4 * math.cos(animation * math.pi * 2 + math.pi),
             center.dy + radius * 0.4 * math.sin(animation * math.pi * 2 + math.pi)),
      Offset(center.dx + radius * 0.7 * math.cos(animation * math.pi * 2 + math.pi / 2),
             center.dy + radius * 0.7 * math.sin(animation * math.pi * 2 + math.pi / 2)),
    ];

    for (final pos in sparklePositions) {
      _drawSparkle(canvas, pos, 3, paint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    
    // Draw a 4-pointed star
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      final radius = (i % 2 == 0) ? size : size * 0.4;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}