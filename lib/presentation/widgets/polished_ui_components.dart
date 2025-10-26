import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// Comprehensive polished UI components to replace basic Flutter widgets
/// with refined designs, shadows, gradients, and micro-interactions

/// Enhanced progress indicator with smooth animations and custom styling
class PolishedProgressIndicator extends StatefulWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double strokeWidth;
  final double size;
  final bool showPercentage;
  final TextStyle? percentageStyle;

  const PolishedProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.strokeWidth = 4.0,
    this.size = 40.0,
    this.showPercentage = false,
    this.percentageStyle,
  });

  @override
  State<PolishedProgressIndicator> createState() => _PolishedProgressIndicatorState();
}

class _PolishedProgressIndicatorState extends State<PolishedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.medium,
      vsync: this,
    );

    if (widget.value == null) {
      _controller.repeat();
    } else {
      _animation = Tween<double>(
        begin: 0.0,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: MinqAnimationTokens.easeOut,
      ));
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PolishedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != null) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: MinqAnimationTokens.easeOut,
      ));
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
    final backgroundColor = widget.backgroundColor ?? tokens.colors.surfaceVariant;
    final valueColor = widget.valueColor ?? tokens.colors.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _ProgressPainter(
              animation: widget.value == null ? _controller : _animation,
              backgroundColor: backgroundColor,
              valueColor: valueColor,
              strokeWidth: widget.strokeWidth,
              isIndeterminate: widget.value == null,
            ),
          ),
          if (widget.showPercentage && widget.value != null)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final percentage = (_animation.value * 100).round();
                return Text(
                  '$percentage%',
                  style: widget.percentageStyle ?? 
                      tokens.typography.bodySmall.copyWith(
                        color: tokens.colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final Animation<double> animation;
  final Color backgroundColor;
  final Color valueColor;
  final double strokeWidth;
  final bool isIndeterminate;

  _ProgressPainter({
    required this.animation,
    required this.backgroundColor,
    required this.valueColor,
    required this.strokeWidth,
    required this.isIndeterminate,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isIndeterminate) {
      // Spinning animation for indeterminate progress
      final sweepAngle = 1.5;
      final startAngle = animation.value * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    } else {
      // Determinate progress
      final sweepAngle = animation.value * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Enhanced linear progress indicator with gradient and animation
class PolishedLinearProgressIndicator extends StatefulWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final Gradient? gradient;
  final double height;
  final BorderRadius? borderRadius;
  final bool showLabel;
  final String? label;

  const PolishedLinearProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.gradient,
    this.height = 8.0,
    this.borderRadius,
    this.showLabel = false,
    this.label,
  });

  @override
  State<PolishedLinearProgressIndicator> createState() => _PolishedLinearProgressIndicatorState();
}

class _PolishedLinearProgressIndicatorState extends State<PolishedLinearProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.medium,
      vsync: this,
    );

    if (widget.value == null) {
      _controller.repeat();
    } else {
      _animation = Tween<double>(
        begin: 0.0,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: MinqAnimationTokens.easeOut,
      ));
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(PolishedLinearProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && widget.value != null) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.value!,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: MinqAnimationTokens.easeOut,
      ));
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
    final backgroundColor = widget.backgroundColor ?? tokens.colors.surfaceVariant;
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(widget.height / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel && widget.label != null) ...[
          Text(
            widget.label!,
            style: tokens.typography.bodySmall.copyWith(
              color: tokens.colors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: MinqSpacingTokens.xs),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: AnimatedBuilder(
              animation: widget.value == null ? _controller : _animation,
              builder: (context, child) {
                return LinearProgressIndicator(
                  value: widget.value == null ? null : _animation.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(
                    widget.valueColor ?? tokens.colors.primary,
                  ),
                  minHeight: widget.height,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Enhanced floating action button with gradient and shadow
class PolishedFloatingActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final bool mini;
  final double? elevation;
  final ShapeBorder? shape;

  const PolishedFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.mini = false,
    this.elevation,
    this.shape,
  });

  @override
  State<PolishedFloatingActionButton> createState() => _PolishedFloatingActionButtonState();
}

class _PolishedFloatingActionButtonState extends State<PolishedFloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.mediumImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final size = widget.mini ? 40.0 : 56.0;
    final backgroundColor = widget.backgroundColor ?? tokens.colors.primary;
    final foregroundColor = widget.foregroundColor ?? tokens.colors.onPrimary;

    return Tooltip(
      message: widget.tooltip ?? '',
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  gradient: widget.gradient ?? LinearGradient(
                    colors: [
                      backgroundColor,
                      Color.lerp(backgroundColor, Colors.black, 0.1)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: tokens.elevation.lg.map((shadow) {
                    return BoxShadow(
                      color: shadow.color.withAlpha(
                        (shadow.color.alpha * _shadowAnimation.value).round(),
                      ),
                      blurRadius: shadow.blurRadius * 1.5,
                      offset: shadow.offset,
                    );
                  }).toList(),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Center(
                    child: DefaultTextStyle(
                      style: TextStyle(color: foregroundColor),
                      child: IconTheme(
                        data: IconThemeData(
                          color: foregroundColor,
                          size: widget.mini ? 18 : 24,
                        ),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Enhanced elevated button with gradient and micro-interactions
class PolishedElevatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final IconData? icon;

  const PolishedElevatedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PolishedElevatedButton> createState() => _PolishedElevatedButtonState();
}

class _PolishedElevatedButtonState extends State<PolishedElevatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final backgroundColor = widget.backgroundColor ?? tokens.colors.primary;
    final foregroundColor = widget.foregroundColor ?? tokens.colors.onPrimary;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? MinqSpacingTokens.minTouchTarget,
              constraints: const BoxConstraints(
                minWidth: MinqSpacingTokens.minTouchTarget,
                minHeight: MinqSpacingTokens.minTouchTarget,
              ),
              decoration: BoxDecoration(
                gradient: widget.gradient ?? (isEnabled
                    ? LinearGradient(
                        colors: [
                          backgroundColor,
                          Color.lerp(backgroundColor, Colors.black, 0.1)!,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null),
                color: widget.gradient == null && !isEnabled
                    ? tokens.colors.outline
                    : (widget.gradient == null ? backgroundColor : null),
                borderRadius: widget.borderRadius ?? tokens.radius.mdRadius,
                boxShadow: isEnabled
                    ? tokens.elevation.md.map((shadow) {
                        return BoxShadow(
                          color: shadow.color.withAlpha(
                            (shadow.color.alpha * _shadowAnimation.value).round(),
                          ),
                          blurRadius: shadow.blurRadius,
                          offset: shadow.offset,
                        );
                      }).toList()
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: widget.padding ?? 
                      EdgeInsets.symmetric(
                        horizontal: MinqSpacingTokens.lg,
                        vertical: MinqSpacingTokens.md,
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(foregroundColor),
                          ),
                        )
                      else if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: foregroundColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (!widget.isLoading)
                        DefaultTextStyle(
                          style: tokens.typography.labelLarge.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w600,
                          ),
                          child: widget.child,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced outlined button with hover effects
class PolishedOutlinedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final IconData? icon;

  const PolishedOutlinedButton({
    super.key,
    required this.child,
    this.onPressed,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PolishedOutlinedButton> createState() => _PolishedOutlinedButtonState();
}

class _PolishedOutlinedButtonState extends State<PolishedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final borderColor = widget.borderColor ?? tokens.colors.outline;
    final foregroundColor = widget.foregroundColor ?? tokens.colors.primary;

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: foregroundColor.withAlpha(15),
    ).animate(_controller);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height ?? MinqSpacingTokens.minTouchTarget,
              constraints: const BoxConstraints(
                minWidth: MinqSpacingTokens.minTouchTarget,
                minHeight: MinqSpacingTokens.minTouchTarget,
              ),
              decoration: BoxDecoration(
                color: _backgroundAnimation.value,
                borderRadius: widget.borderRadius ?? tokens.radius.mdRadius,
                border: Border.all(
                  color: isEnabled ? borderColor : tokens.colors.outlineVariant,
                  width: 1.5,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: widget.padding ?? 
                      EdgeInsets.symmetric(
                        horizontal: MinqSpacingTokens.lg,
                        vertical: MinqSpacingTokens.md,
                      ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(foregroundColor),
                          ),
                        )
                      else if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: foregroundColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (!widget.isLoading)
                        DefaultTextStyle(
                          style: tokens.typography.labelLarge.copyWith(
                            color: foregroundColor,
                            fontWeight: FontWeight.w600,
                          ),
                          child: widget.child,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced text button with subtle hover effects
class PolishedTextButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final EdgeInsets? padding;
  final bool isLoading;
  final IconData? icon;

  const PolishedTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.foregroundColor,
    this.padding,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PolishedTextButton> createState() => _PolishedTextButtonState();
}

class _PolishedTextButtonState extends State<PolishedTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _backgroundAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final foregroundColor = widget.foregroundColor ?? tokens.colors.primary;

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: foregroundColor.withAlpha(15),
    ).animate(_controller);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: MinqSpacingTokens.minTouchTarget,
                minHeight: MinqSpacingTokens.minTouchTarget,
              ),
              decoration: BoxDecoration(
                color: _backgroundAnimation.value,
                borderRadius: tokens.radius.smRadius,
              ),
              padding: widget.padding ?? 
                  EdgeInsets.symmetric(
                    horizontal: MinqSpacingTokens.md,
                    vertical: MinqSpacingTokens.sm,
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(foregroundColor),
                      ),
                    )
                  else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: foregroundColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (!widget.isLoading)
                    DefaultTextStyle(
                      style: tokens.typography.labelLarge.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.child,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Loading overlay for dialogs and screens
class PolishedLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final Color? backgroundColor;

  const PolishedLoadingOverlay({
    super.key,
    this.message,
    this.isVisible = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);

    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: backgroundColor ?? Colors.black.withAlpha(128),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(MinqSpacingTokens.xl),
          decoration: BoxDecoration(
            color: tokens.colors.surface,
            borderRadius: tokens.radius.lgRadius,
            boxShadow: tokens.elevation.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PolishedProgressIndicator(),
              if (message != null) ...[
                SizedBox(height: MinqSpacingTokens.lg),
                Text(
                  message!,
                  style: tokens.typography.bodyMedium.copyWith(
                    color: tokens.colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced card component with refined design and micro-interactions
class PolishedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool enableHoverEffect;
  final bool enablePressEffect;

  const PolishedCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
    this.enableHoverEffect = true,
    this.enablePressEffect = true,
  });

  @override
  State<PolishedCard> createState() => _PolishedCardState();
}

class _PolishedCardState extends State<PolishedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null && widget.enablePressEffect) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      if (!_isHovered) {
        _controller.reverse();
      }
    }
  }

  void _onHover(bool isHovered) {
    if (widget.enableHoverEffect) {
      setState(() => _isHovered = isHovered);
      if (isHovered && !_isPressed) {
        _controller.forward();
      } else if (!isHovered && !_isPressed) {
        _controller.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final backgroundColor = widget.backgroundColor ?? tokens.colors.surface;
    final borderRadius = widget.borderRadius ?? tokens.radius.lgRadius;

    return Container(
      margin: widget.margin,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final currentElevation = (widget.elevation ?? 2.0) * _elevationAnimation.value;
              
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: widget.padding ?? EdgeInsets.all(MinqSpacingTokens.lg),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: borderRadius,
                    border: widget.border,
                    boxShadow: currentElevation > 0
                        ? [
                            BoxShadow(
                              color: tokens.colors.shadow.withAlpha(
                                (25 * currentElevation).round().clamp(0, 255),
                              ),
                              blurRadius: currentElevation * 4,
                              offset: Offset(0, currentElevation * 2),
                            ),
                          ]
                        : null,
                  ),
                  child: widget.child,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Enhanced chip component with refined design
class PolishedChip extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isSelected;
  final EdgeInsets? padding;

  const PolishedChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.backgroundColor,
    this.foregroundColor,
    this.isSelected = false,
    this.padding,
  });

  @override
  State<PolishedChip> createState() => _PolishedChipState();
}

class _PolishedChipState extends State<PolishedChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _onTapEnd();
  }

  void _onTapCancel() {
    _onTapEnd();
  }

  void _onTapEnd() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final backgroundColor = widget.isSelected
        ? (widget.backgroundColor ?? tokens.colors.primary)
        : (widget.backgroundColor ?? tokens.colors.surfaceContainer);
    final foregroundColor = widget.isSelected
        ? (widget.foregroundColor ?? tokens.colors.onPrimary)
        : (widget.foregroundColor ?? tokens.colors.onSurface);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: widget.padding ?? EdgeInsets.symmetric(
                horizontal: MinqSpacingTokens.md,
                vertical: MinqSpacingTokens.sm,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: tokens.radius.fullRadius,
                border: widget.isSelected
                    ? null
                    : Border.all(
                        color: tokens.colors.outline,
                        width: 1,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: foregroundColor,
                      size: 16,
                    ),
                    SizedBox(width: MinqSpacingTokens.xs),
                  ],
                  Text(
                    widget.label,
                    style: tokens.typography.labelMedium.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.onDelete != null) ...[
                    SizedBox(width: MinqSpacingTokens.xs),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Icon(
                        Icons.close,
                        color: foregroundColor,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced switch component with smooth animations
class PolishedSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const PolishedSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  State<PolishedSwitch> createState() => _PolishedSwitchState();
}

class _PolishedSwitchState extends State<PolishedSwitch>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _thumbAnimation;
  late Animation<Color?> _trackAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: MinqAnimationTokens.medium,
      vsync: this,
    );

    _thumbAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: MinqAnimationTokens.easeOut,
    ));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PolishedSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.onChanged != null) {
      widget.onChanged!(!widget.value);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final activeColor = widget.activeColor ?? tokens.colors.primary;
    final inactiveColor = widget.inactiveColor ?? tokens.colors.outline;
    final thumbColor = widget.thumbColor ?? tokens.colors.surface;

    _trackAnimation = ColorTween(
      begin: inactiveColor,
      end: activeColor,
    ).animate(_controller);

    return GestureDetector(
      onTap: _onTap,
      child: Container(
        width: 52,
        height: 32,
        constraints: const BoxConstraints(
          minWidth: MinqSpacingTokens.minTouchTarget,
          minHeight: MinqSpacingTokens.minTouchTarget,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 52,
              height: 32,
              decoration: BoxDecoration(
                color: _trackAnimation.value,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: MinqAnimationTokens.medium,
                    curve: MinqAnimationTokens.easeOut,
                    left: _thumbAnimation.value * 20 + 2,
                    top: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: thumbColor,
                        shape: BoxShape.circle,
                        boxShadow: tokens.elevation.sm,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Enhanced slider component with refined design
class PolishedSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;

  const PolishedSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
  });

  @override
  State<PolishedSlider> createState() => _PolishedSliderState();
}

class _PolishedSliderState extends State<PolishedSlider> {
  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    final activeColor = widget.activeColor ?? tokens.colors.primary;
    final inactiveColor = widget.inactiveColor ?? tokens.colors.outline;
    final thumbColor = widget.thumbColor ?? tokens.colors.primary;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeColor,
        inactiveTrackColor: inactiveColor,
        thumbColor: thumbColor,
        overlayColor: activeColor.withAlpha(51),
        trackHeight: 6.0,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 12.0,
          pressedElevation: 8.0,
        ),
        overlayShape: const RoundSliderOverlayShape(
          overlayRadius: 24.0,
        ),
        trackShape: const RoundedRectSliderTrackShape(),
        valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: activeColor,
        valueIndicatorTextStyle: tokens.typography.bodySmall.copyWith(
          color: tokens.colors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Slider(
        value: widget.value,
        onChanged: widget.onChanged,
        min: widget.min,
        max: widget.max,
        divisions: widget.divisions,
        label: widget.label,
      ),
    );
  }
}