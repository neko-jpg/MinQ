import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// A circular progress ring with smooth animations and completion effects
/// Features progress animation, sparkles, and celebration feedback
class ProgressRing extends StatefulWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120.0,
    this.strokeWidth = 8.0,
    this.animationDuration = const Duration(milliseconds: 800),
    this.showSparkles = true,
    this.enableCompletionFeedback = true,
    this.backgroundColor,
    this.progressColor,
    this.completedColor,
    this.sparkleColor,
    this.onComplete,
    this.child,
    this.startAngle = -math.pi / 2, // Start from top
  });

  /// Progress value from 0.0 to 1.0
  final double progress;

  /// Size of the progress ring
  final double size;

  /// Width of the progress stroke
  final double strokeWidth;

  /// Duration of the progress animation
  final Duration animationDuration;

  /// Whether to show sparkle effects
  final bool showSparkles;

  /// Whether to provide feedback on completion
  final bool enableCompletionFeedback;

  /// Background color of the ring
  final Color? backgroundColor;

  /// Color of the progress arc
  final Color? progressColor;

  /// Color when progress is completed
  final Color? completedColor;

  /// Color of the sparkle effects
  final Color? sparkleColor;

  /// Callback when progress reaches 1.0
  final VoidCallback? onComplete;

  /// Widget to display in the center of the ring
  final Widget? child;

  /// Starting angle of the progress arc
  final double startAngle;

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with TickerProviderStateMixin {
  bool get _reduceMotion =>
      WidgetsBinding.instance.platformDispatcher.accessibilityFeatures
          .disableAnimations;

  bool get _shouldShowSparkles => widget.showSparkles && !_reduceMotion;

  bool get _shouldProvideCompletionFeedback =>
      widget.enableCompletionFeedback && !_reduceMotion;

  late AnimationController _progressController;
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;

  late Animation<double> _progressAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  double _previousProgress = 0.0;
  bool _hasCompleted = false;
  Timer? _sparkleTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _animateToProgress();
  }

  void _initializeAnimations() {
    final Duration progressDuration =
        _reduceMotion ? Duration.zero : widget.animationDuration;
    final Duration sparkleDuration =
        _reduceMotion ? Duration.zero : const Duration(milliseconds: 1200);
    final Duration pulseDuration =
        _reduceMotion ? Duration.zero : const Duration(milliseconds: 600);
    final Duration rotationDuration =
        _reduceMotion ? Duration.zero : const Duration(milliseconds: 2000);

    // Progress animation
    _progressController = AnimationController(
      duration: progressDuration,
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    // Sparkle animation for completion effect
    _sparkleController = AnimationController(
      duration: sparkleDuration,
      vsync: this,
    );
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for completion celebration
    _pulseController = AnimationController(
      duration: pulseDuration,
      vsync: this,
    );
    final double pulseEnd = _reduceMotion ? 1.0 : 1.1;
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: pulseEnd,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    // Rotation animation for sparkles
    _rotationController = AnimationController(
      duration: rotationDuration,
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _previousProgress = widget.progress;
  }

  void _animateToProgress() {
    _progressAnimation = Tween<double>(
      begin: _previousProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    ));

    _progressController.reset();
    _progressController.forward();

    // Check for completion
    if (widget.progress >= 1.0 && _previousProgress < 1.0) {
      _handleCompletion();
    }

    _previousProgress = widget.progress;
  }

  void _handleCompletion() {
    if (_hasCompleted) return;
    _hasCompleted = true;

    if (_shouldShowSparkles && _sparkleController.duration != Duration.zero) {
      _sparkleController
        ..reset()
        ..forward();
      if (_rotationController.duration != Duration.zero) {
        _rotationController
          ..reset()
          ..repeat();
      }

      _sparkleTimer?.cancel();
      _sparkleTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _sparkleController.reverse();
          _rotationController.stop();
        }
      });
    }

    if (_shouldProvideCompletionFeedback) {
      FeedbackManager.questCompleted();
      if (_pulseController.duration != Duration.zero) {
        _pulseController
          ..reset()
          ..forward().then((_) {
            if (_pulseController.duration != Duration.zero) {
              _pulseController.reverse();
            }
          });
      }
    }

    widget.onComplete?.call();
  }

  @override
  void didUpdateWidget(ProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.progress != widget.progress) {
      if (widget.progress < _previousProgress) {
        // Progress decreased, reset completion state
        _hasCompleted = false;
        _sparkleTimer?.cancel();
        if (_sparkleController.duration != Duration.zero) {
          _sparkleController.reset();
        }
        if (_rotationController.duration != Duration.zero) {
          _rotationController.reset();
        }
      }
      _animateToProgress();
    }
  }

  @override
  void dispose() {
    _sparkleTimer?.cancel();
    _progressController.dispose();
    _sparkleController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressAnimation,
        _sparkleAnimation,
        _pulseAnimation,
        _rotationAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ProgressRingPainter(
                    progress: 1.0,
                    strokeWidth: widget.strokeWidth,
                    color: widget.backgroundColor ?? theme.progressPending,
                    startAngle: widget.startAngle,
                  ),
                ),
                
                // Progress ring
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ProgressRingPainter(
                    progress: _progressAnimation.value,
                    strokeWidth: widget.strokeWidth,
                    color: _progressAnimation.value >= 1.0
                        ? (widget.completedColor ?? theme.progressComplete)
                        : (widget.progressColor ?? theme.progressActive),
                    startAngle: widget.startAngle,
                  ),
                ),
                
                // Sparkles
                if (_shouldShowSparkles && _sparkleAnimation.value > 0)
                  Transform.rotate(
                    angle: _rotationAnimation.value,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _SparklesPainter(
                        animation: _sparkleAnimation.value,
                        color: widget.sparkleColor ?? theme.joyAccent,
                        ringSize: widget.size,
                      ),
                    ),
                  ),
                
                // Center content
                if (widget.child != null)
                  widget.child!,
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double startAngle;

  _ProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.startAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.startAngle != startAngle;
  }
}

class _SparklesPainter extends CustomPainter {
  final double animation;
  final Color color;
  final double ringSize;

  _SparklesPainter({
    required this.animation,
    required this.color,
    required this.ringSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = ringSize / 2;
    
    final paint = Paint()
      ..color = color.withOpacity(animation)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw sparkles around the ring
    const sparkleCount = 8;
    for (int i = 0; i < sparkleCount; i++) {
      final angle = (2 * math.pi * i) / sparkleCount;
      final sparkleRadius = radius + 10;
      final sparkleCenter = Offset(
        center.dx + sparkleRadius * math.cos(angle),
        center.dy + sparkleRadius * math.sin(angle),
      );
      
      final sparkleSize = 4.0 * animation;
      
      // Draw sparkle as a small cross
      canvas.drawLine(
        Offset(sparkleCenter.dx - sparkleSize, sparkleCenter.dy),
        Offset(sparkleCenter.dx + sparkleSize, sparkleCenter.dy),
        paint,
      );
      canvas.drawLine(
        Offset(sparkleCenter.dx, sparkleCenter.dy - sparkleSize),
        Offset(sparkleCenter.dx, sparkleCenter.dy + sparkleSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklesPainter oldDelegate) {
    return oldDelegate.animation != animation ||
           oldDelegate.color != color ||
           oldDelegate.ringSize != ringSize;
  }
}