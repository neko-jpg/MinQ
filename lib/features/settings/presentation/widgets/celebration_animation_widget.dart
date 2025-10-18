import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'dart:math';

class CelebrationAnimationWidget extends StatefulWidget {
  final bool isVisible;
  const CelebrationAnimationWidget({super.key, required this.isVisible});

  @override
  State<CelebrationAnimationWidget> createState() => _CelebrationAnimationWidgetState();
}

class _CelebrationAnimationWidgetState extends State<CelebrationAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CelebrationAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isAnimating) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ConfettiPainter(_controller.value),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<Paint> _paints;
  final List<Offset> _particles;

  _ConfettiPainter(this.progress)
      : _paints = [
          Paint()..color = Colors.blue,
          Paint()..color = Colors.green,
          Paint()..color = Colors.pink,
          Paint()..color = Colors.orange,
        ],
        _particles = List.generate(100, (index) => Offset(
          Random().nextDouble(), // x position (0.0 to 1.0)
          Random().nextDouble() * -1.5, // initial y position (above screen)
        ));

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    for (int i = 0; i < _particles.length; i++) {
      final particle = _particles[i];
      final paint = _paints[i % _paints.length];
      final yPos = (particle.dy + progress * 2.5) % 1.5 - 0.5;
      canvas.drawCircle(
        Offset(particle.dx * size.width, yPos * size.height),
        random.nextDouble() * 4 + 2, // random size
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}