import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 驕疲・繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ繧ｦ繧｣繧ｸ繧ｧ繝・ヨ
class AchievementAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;

  const AchievementAnimation({
    super.key,
    required this.child,
    this.onComplete,
  });

  @override
  State<AchievementAnimation> createState() => _AchievementAnimationState();
}

class _AchievementAnimationState extends State<AchievementAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _scaleController.forward();
    await _confettiController.forward();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 邏吝聖髮ｪ
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                progress: _confettiController.value,
              ),
              child: Container(),
            );
          },
        ),
        // 繝｡繧､繝ｳ繧ｳ繝ｳ繝・Φ繝・
        Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}

/// 邏吝聖髮ｪ繝壹う繝ｳ繧ｿ繝ｼ
class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Confetti> confetti;

  ConfettiPainter({required this.progress})
      : confetti = List.generate(50, (index) => Confetti());

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in confetti) {
      piece.paint(canvas, size, progress);
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 邏吝聖髮ｪ縺ｮ1縺､
class Confetti {
  final double x;
  final double y;
  final double rotation;
  final Color color;
  final double size;

  Confetti()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble() * 0.3,
        rotation = math.Random().nextDouble() * math.pi * 2,
        color = _randomColor(),
        size = math.Random().nextDouble() * 8 + 4;

  static Color _randomColor() {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
    ];
    return colors[math.Random().nextInt(colors.length)];
  }

  void paint(Canvas canvas, Size size, double progress) {
    final paint = Paint()..color = color;

    final currentX = x * size.width;
    final currentY = y * size.height + (progress * size.height);
    final currentRotation = rotation + (progress * math.pi * 4);

    canvas.save();
    canvas.translate(currentX, currentY);
    canvas.rotate(currentRotation);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: this.size,
        height: this.size / 2,
      ),
      paint,
    );
    canvas.restore();
  }
}
