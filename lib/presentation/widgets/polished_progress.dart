import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// Polished progress indicators with enhanced visuals and animations
/// Provides professional-looking progress feedback components

/// Circular progress indicator with gradient and enhanced visuals
class PolishedCircularProgress extends StatefulWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? valueColor;
  final Duration animationDuration;
  final Widget? child;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const PolishedCircularProgress({
    super.key,
    required this.value,
    this.size = 80.0,
    this.strokeWidth = 8.0,
    this.backgroundColor,
    this.gradient,
    this.valueColor,
    this.animationDuration = const Duration(milliseconds: 800),
    this.child,
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  State<PolishedCircularProgress> createState() =>
      _PolishedCircularProgressState();
}

class _PolishedCircularProgressState extends State<PolishedCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void didUpdateWidget(PolishedCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              backgroundColor:
                  widget.backgroundColor ?? tokens.colors.outline.withAlpha(51),
              gradient: widget.gradient,
              valueColor: widget.valueColor ?? tokens.colors.primary,
            ),
            child: Center(
              child:
                  widget.child ??
                  (widget.showPercentage
                      ? Text(
                        '${(_animation.value * 100).round()}%',
                        style:
                            widget.percentageStyle ??
                            tokens.typography.labelMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: tokens.colors.onSurface,
                            ),
                      )
                      : null),
            ),
          );
        },
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color valueColor;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    this.gradient,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint =
        Paint()
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    if (gradient != null) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      progressPaint.shader = gradient!.createShader(rect);
    } else {
      progressPaint.color = valueColor;
    }

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Linear progress indicator with gradient and enhanced visuals
class PolishedLinearProgress extends StatefulWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Color? valueColor;
  final BorderRadius? borderRadius;
  final Duration animationDuration;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const PolishedLinearProgress({
    super.key,
    required this.value,
    this.height = 8.0,
    this.backgroundColor,
    this.gradient,
    this.valueColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 800),
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  State<PolishedLinearProgress> createState() => _PolishedLinearProgressState();
}

class _PolishedLinearProgressState extends State<PolishedLinearProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void didUpdateWidget(PolishedLinearProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final borderRadius =
        widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: widget.height,
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    tokens.colors.outline.withAlpha(51),
                borderRadius: borderRadius,
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: LinearProgressIndicator(
                  value: _animation.value,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      widget.gradient != null
                          ? null
                          : AlwaysStoppedAnimation(
                            widget.valueColor ?? tokens.colors.primary,
                          ),
                  minHeight: widget.height,
                ),
              ),
            );
          },
        ),
        if (widget.showPercentage) ...[
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Text(
                '${(_animation.value * 100).round()}%',
                style:
                    widget.percentageStyle ??
                    tokens.typography.bodySmall.copyWith(
                      color: tokens.colors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              );
            },
          ),
        ],
      ],
    );
  }
}

/// Step progress indicator with enhanced visuals
class PolishedStepProgress extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final double stepSize;
  final double lineWidth;
  final Duration animationDuration;

  const PolishedStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.stepSize = 32.0,
    this.lineWidth = 2.0,
    this.animationDuration = const Duration(milliseconds: 400),
  });

  @override
  State<PolishedStepProgress> createState() => _PolishedStepProgressState();
}

class _PolishedStepProgressState extends State<PolishedStepProgress>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.totalSteps,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    _scaleAnimations =
        _controllers.map((controller) {
          return Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: controller, curve: Curves.elasticOut),
          );
        }).toList();
  }

  void _startAnimations() {
    for (int i = 0; i <= widget.currentStep && i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(PolishedStepProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final activeColor = widget.activeColor ?? tokens.colors.primary;
    final inactiveColor = widget.inactiveColor ?? tokens.colors.outline;
    final completedColor = widget.completedColor ?? tokens.colors.success;

    return Column(
      children: [
        Row(
          children: List.generate(widget.totalSteps, (index) {
            final isCompleted = index < widget.currentStep;
            final isActive = index == widget.currentStep;
            final isInactive = index > widget.currentStep;

            Color stepColor;
            if (isCompleted) {
              stepColor = completedColor;
            } else if (isActive) {
              stepColor = activeColor;
            } else {
              stepColor = inactiveColor;
            }

            return Expanded(
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _controllers[index],
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimations[index].value,
                        child: Container(
                          width: widget.stepSize,
                          height: widget.stepSize,
                          decoration: BoxDecoration(
                            color: stepColor,
                            shape: BoxShape.circle,
                            boxShadow:
                                isActive || isCompleted
                                    ? [
                                      BoxShadow(
                                        color: stepColor.withAlpha(76),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                    : null,
                          ),
                          child: Center(
                            child:
                                isCompleted
                                    ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: widget.stepSize * 0.5,
                                    )
                                    : Text(
                                      '${index + 1}',
                                      style: tokens.typography.labelMedium
                                          .copyWith(
                                            color:
                                                isInactive
                                                    ? tokens
                                                        .colors
                                                        .onSurfaceVariant
                                                    : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (index < widget.totalSteps - 1)
                    Expanded(
                      child: Container(
                        height: widget.lineWidth,
                        color:
                            index < widget.currentStep
                                ? completedColor
                                : inactiveColor,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        if (widget.stepLabels != null) ...[
          const SizedBox(height: 8),
          Row(
            children: List.generate(widget.totalSteps, (index) {
              final isCompleted = index < widget.currentStep;
              final isActive = index == widget.currentStep;

              return Expanded(
                child: Text(
                  widget.stepLabels![index],
                  textAlign: TextAlign.center,
                  style: tokens.typography.bodySmall.copyWith(
                    color:
                        isCompleted || isActive
                            ? tokens.colors.onSurface
                            : tokens.colors.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

/// Radial progress indicator with multiple segments
class PolishedRadialProgress extends StatefulWidget {
  final List<double> values;
  final List<Color> colors;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Duration animationDuration;
  final Widget? child;

  const PolishedRadialProgress({
    super.key,
    required this.values,
    required this.colors,
    this.size = 120.0,
    this.strokeWidth = 12.0,
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 1000),
    this.child,
  });

  @override
  State<PolishedRadialProgress> createState() => _PolishedRadialProgressState();
}

class _PolishedRadialProgressState extends State<PolishedRadialProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animations =
        widget.values.map((value) {
          return Tween<double>(begin: 0.0, end: value).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          );
        }).toList();

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadialProgressPainter(
              values: _animations.map((a) => a.value).toList(),
              colors: widget.colors,
              strokeWidth: widget.strokeWidth,
              backgroundColor:
                  widget.backgroundColor ?? tokens.colors.outline.withAlpha(51),
            ),
            child: Center(child: widget.child),
          );
        },
      ),
    );
  }
}

class _RadialProgressPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;
  final double strokeWidth;
  final Color backgroundColor;

  _RadialProgressPainter({
    required this.values,
    required this.colors,
    required this.strokeWidth,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint =
        Paint()
          ..color = backgroundColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arcs
    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final progressPaint =
          Paint()
            ..color = colors[i % colors.length]
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * values[i];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
