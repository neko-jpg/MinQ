import 'dart:math' as math;

import 'package:flutter/material.dart';

/// プレミアムローディングアニメーション集
class PremiumLoading {
  PremiumLoading._();

  /// 脈動ローディング
  static Widget pulse({
    Color? color,
    double size = 50.0,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return _PulseLoading(
      color: color,
      size: size,
      duration: duration,
    );
  }

  /// 波紋ローディング
  static Widget ripple({
    Color? color,
    double size = 50.0,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return _RippleLoading(
      color: color,
      size: size,
      duration: duration,
    );
  }

  /// スピンローディング
  static Widget spin({
    Color? color,
    double size = 50.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _SpinLoading(
      color: color,
      size: size,
      duration: duration,
    );
  }

  /// ドットローディング
  static Widget dots({
    Color? color,
    double size = 50.0,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return _DotsLoading(
      color: color,
      size: size,
      duration: duration,
    );
  }

  /// 波ローディング
  static Widget wave({
    Color? color,
    double size = 50.0,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _WaveLoading(
      color: color,
      size: size,
      duration: duration,
    );
  }
}

/// 脈動ローディング
class _PulseLoading extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const _PulseLoading({
    this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_PulseLoading> createState() => _PulseLoadingState();
}

class _PulseLoadingState extends State<_PulseLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(_opacityAnimation.value * 0.6),
                  ),
                ),
              ),
              Container(
                width: widget.size * 0.6,
                height: widget.size * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 波紋ローディング
class _RippleLoading extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const _RippleLoading({
    this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_RippleLoading> createState() => _RippleLoadingState();
}

class _RippleLoadingState extends State<_RippleLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RipplePainter(
              animation: _controller,
              color: color,
            ),
            size: Size(widget.size, widget.size),
          );
        },
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _RipplePainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    for (int i = 0; i < 3; i++) {
      final progress = (animation.value + i * 0.33) % 1.0;
      final radius = maxRadius * progress;
      final opacity = 1.0 - progress;

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// スピンローディング
class _SpinLoading extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const _SpinLoading({
    this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_SpinLoading> createState() => _SpinLoadingState();
}

class _SpinLoadingState extends State<_SpinLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              painter: _SpinPainter(color: color),
              size: Size(widget.size, widget.size),
            ),
          );
        },
      ),
    );
  }
}

class _SpinPainter extends CustomPainter {
  final Color color;

  _SpinPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    // グラデーション効果
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final opacity = (i + 1) / 8;
      
      paint.color = color.withOpacity(opacity);
      
      final startX = center.dx + math.cos(angle) * radius * 0.7;
      final startY = center.dy + math.sin(angle) * radius * 0.7;
      final endX = center.dx + math.cos(angle) * radius * 0.9;
      final endY = center.dy + math.sin(angle) * radius * 0.9;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ドットローディング
class _DotsLoading extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const _DotsLoading({
    this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_DotsLoading> createState() => _DotsLoadingState();
}

class _DotsLoadingState extends State<_DotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: widget.size,
      height: widget.size * 0.3,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final delay = index * 0.2;
              final progress = (_controller.value + delay) % 1.0;
              final scale = math.sin(progress * math.pi);
              
              return Transform.scale(
                scale: 0.5 + scale * 0.5,
                child: Container(
                  width: widget.size * 0.15,
                  height: widget.size * 0.15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.5 + scale * 0.5),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// 波ローディング
class _WaveLoading extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const _WaveLoading({
    this.color,
    required this.size,
    required this.duration,
  });

  @override
  State<_WaveLoading> createState() => _WaveLoadingState();
}

class _WaveLoadingState extends State<_WaveLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: widget.size,
      height: widget.size * 0.6,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavePainter(
              animation: _controller,
              color: color,
            ),
            size: Size(widget.size, widget.size * 0.6),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _WavePainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final waveHeight = size.height * 0.3;
    final waveLength = size.width;
    final phase = animation.value * 2 * math.pi;

    path.moveTo(0, size.height / 2);

    for (double x = 0; x <= waveLength; x += 1) {
      final y = size.height / 2 + 
          math.sin((x / waveLength * 2 * math.pi) + phase) * waveHeight;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// プレミアムローディングオーバーレイ
class PremiumLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
  final LoadingType type;

  const PremiumLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
    this.type = LoadingType.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLoadingWidget(type),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        message!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingWidget(LoadingType type) {
    switch (type) {
      case LoadingType.pulse:
        return PremiumLoading.pulse();
      case LoadingType.ripple:
        return PremiumLoading.ripple();
      case LoadingType.spin:
        return PremiumLoading.spin();
      case LoadingType.dots:
        return PremiumLoading.dots();
      case LoadingType.wave:
        return PremiumLoading.wave();
    }
  }
}

enum LoadingType {
  pulse,
  ripple,
  spin,
  dots,
  wave,
}