import 'dart:math' as math;

import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:minq/domain/gamification/badge.dart' as gamification;

/// バッジ獲得通知ウィジェット
/// 新しいバッジを獲得した時に表示されるアニメーション付き通知
class BadgeNotificationWidget extends StatefulWidget {
  const BadgeNotificationWidget({
    super.key,
    required this.badge,
    required this.onDismiss,
    this.duration = const Duration(seconds: 4),
  });

  final gamification.Badge badge;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<BadgeNotificationWidget> createState() =>
      _BadgeNotificationWidgetState();
}

class _BadgeNotificationWidgetState extends State<BadgeNotificationWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _sparkleController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    // 触覚フィードバック
    HapticFeedback.mediumImpact();

    // アニメーション開始
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    _sparkleController.repeat(reverse: true);

    // 自動消去タイマー
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    _sparkleController.stop();
    await _slideController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // スパークルエフェクト
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _sparkleAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: SparklePainter(
                          animation: _sparkleAnimation.value,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      );
                    },
                  ),
                ),

                // メインコンテンツ
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // バッジアイコン
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(child: _getBadgeIcon(widget.badge.id)),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // テキスト情報
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🎉 バッジ獲得！',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.badge.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.badge.description,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // 閉じるボタン
                      IconButton(
                        onPressed: _dismiss,
                        icon: Icon(
                          Icons.close,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBadgeIcon(String badgeId) {
    IconData iconData;
    Color iconColor = Colors.white;

    switch (badgeId) {
      case 'quest_master_1':
        iconData = Icons.star;
        break;
      case 'quest_master_10':
        iconData = Icons.military_tech;
        break;
      case 'quest_master_50':
        iconData = Icons.emoji_events;
        break;
      case 'quest_master_100':
        iconData = Icons.diamond;
        break;
      case 'streak_master_7':
        iconData = Icons.local_fire_department;
        break;
      case 'streak_master_30':
        iconData = Icons.whatshot;
        break;
      case 'early_bird':
        iconData = Icons.wb_sunny;
        break;
      case 'night_owl':
        iconData = Icons.nightlight;
        break;
      case 'consistency_king':
        iconData = Icons.trending_up;
        break;
      case 'category_master':
        iconData = Icons.auto_awesome;
        break;
      default:
        iconData = Icons.workspace_premium;
    }

    return Icon(iconData, color: iconColor, size: 32);
  }
}

/// スパークルエフェクトペインター
class SparklePainter extends CustomPainter {
  final double animation;
  final Color color;

  SparklePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: animation * 0.8)
          ..style = PaintingStyle.fill;

    // スパークルの位置を計算
    final sparkles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.9, size.height * 0.7),
      Offset(size.width * 0.1, size.height * 0.8),
      Offset(size.width * 0.6, size.height * 0.1),
      Offset(size.width * 0.3, size.height * 0.9),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final sparkle = sparkles[i];
      final phase = (animation + i * 0.2) % 1.0;
      final sparkleSize = 4 * phase * (1 - phase) * 4; // 0から4の間で変化

      if (sparkleSize > 0.5) {
        _drawSparkle(canvas, sparkle, sparkleSize, paint);
      }
    }
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // 4つの尖った星形を描画
    final points = <Offset>[];
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final radius = (i % 2 == 0) ? size : size * 0.4;
      points.add(
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
    }

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklePainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// バッジ通知オーバーレイ
class BadgeNotificationOverlay {
  static OverlayEntry? _currentEntry;

  /// バッジ通知を表示
  static void show(BuildContext context, gamification.Badge badge) {
    // 既存の通知があれば削除
    hide();

    _currentEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 0,
            right: 0,
            child: BadgeNotificationWidget(badge: badge, onDismiss: hide),
          ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  /// バッジ通知を非表示
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

/// ポイント獲得通知ウィジェット
class PointsNotificationWidget extends StatefulWidget {
  const PointsNotificationWidget({
    super.key,
    required this.points,
    required this.reason,
    required this.onDismiss,
    this.duration = const Duration(seconds: 2),
  });

  final int points;
  final String reason;
  final VoidCallback onDismiss;
  final Duration duration;

  @override
  State<PointsNotificationWidget> createState() =>
      _PointsNotificationWidgetState();
}

class _PointsNotificationWidgetState extends State<PointsNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    HapticFeedback.lightImpact();
    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
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
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '+${widget.points} ポイント',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.reason.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(${widget.reason})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ポイント通知オーバーレイ
class PointsNotificationOverlay {
  static OverlayEntry? _currentEntry;

  /// ポイント通知を表示
  static void show(BuildContext context, int points, String reason) {
    // 既存の通知があれば削除
    hide();

    _currentEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 0,
            right: 0,
            child: Center(
              child: PointsNotificationWidget(
                points: points,
                reason: reason,
                onDismiss: hide,
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  /// ポイント通知を非表示
  static void hide() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
