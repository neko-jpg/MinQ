import 'package:flutter/material.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// A button that provides pulsing animation and tap feedback
/// Features scale animation, color transitions, and haptic feedback
class PulsingButton extends StatefulWidget {
  const PulsingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.isPulsing = false,
    this.pulseColor,
    this.pulseDuration = const Duration(milliseconds: 1000),
    this.tapFeedbackDuration = const Duration(milliseconds: 150),
    this.enableHapticFeedback = true,
    this.enableSoundFeedback = true,
    this.backgroundColor,
    this.pressedColor,
    this.borderRadius,
    this.padding,
    this.elevation = 0,
    this.pressedElevation = 2,
    this.minSize = const Size(44, 44),
    this.tapScale = 0.95,
  });

  /// The widget to display inside the button
  final Widget child;

  /// Callback when the button is pressed
  final VoidCallback? onPressed;

  /// Whether the button should pulse continuously
  final bool isPulsing;

  /// Color of the pulse effect
  final Color? pulseColor;

  /// Duration of one pulse cycle
  final Duration pulseDuration;

  /// Duration of the tap feedback animation
  final Duration tapFeedbackDuration;

  /// Whether to provide haptic feedback
  final bool enableHapticFeedback;

  /// Whether to provide sound feedback
  final bool enableSoundFeedback;

  /// Background color of the button
  final Color? backgroundColor;

  /// Color when button is pressed
  final Color? pressedColor;

  /// Border radius of the button
  final BorderRadius? borderRadius;

  /// Padding inside the button
  final EdgeInsetsGeometry? padding;

  /// Elevation of the button
  final double elevation;

  /// Elevation when button is pressed
  final double pressedElevation;

  /// Minimum size of the button (for accessibility)
  final Size minSize;

  /// Scale factor when button is pressed
  final double tapScale;

  @override
  State<PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<PulsingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late AnimationController _colorController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPulsingIfNeeded();
  }

  void _initializeAnimations() {
    // Pulse animation for continuous pulsing effect
    _pulseController = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Tap animation for press feedback
    _tapController = AnimationController(
      duration: widget.tapFeedbackDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.tapScale,
    ).animate(CurvedAnimation(
      parent: _tapController,
      curve: Curves.easeInOut,
    ));

    // Color animation for press feedback
    _colorController = AnimationController(
      duration: widget.tapFeedbackDuration,
      vsync: this,
    );
  }

  void _initializeColorAnimation(BuildContext context) {
    final theme = MinqTheme.of(context);
    _colorAnimation = ColorTween(
      begin: widget.backgroundColor ?? theme.brandPrimary,
      end: widget.pressedColor ?? theme.tapFeedback,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  void _startPulsingIfNeeded() {
    if (widget.isPulsing && widget.onPressed != null) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulsingButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.isPulsing != widget.isPulsing) {
      if (widget.isPulsing && widget.onPressed != null) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed == null) return;
    
    setState(() {
      _isPressed = true;
    });
    
    _tapController.forward();
    _colorController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapEnd();
  }

  void _handleTapCancel() {
    _handleTapEnd();
  }

  void _handleTapEnd() {
    if (!mounted) return;
    
    setState(() {
      _isPressed = false;
    });
    
    _tapController.reverse();
    _colorController.reverse();
  }

  void _handleTap() {
    if (widget.onPressed == null) return;

    // Provide feedback
    if (widget.enableHapticFeedback && widget.enableSoundFeedback) {
      FeedbackManager.buttonPressed();
    } else if (widget.enableHapticFeedback) {
      FeedbackManager.buttonPressed();
    }

    // Call the callback
    widget.onPressed!();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);
    _initializeColorAnimation(context);
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _scaleAnimation,
          _colorAnimation,
        ]),
        builder: (context, child) {
          double scale = _scaleAnimation.value;
          if (widget.isPulsing && widget.onPressed != null) {
            scale *= _pulseAnimation.value;
          }

          return Transform.scale(
            scale: scale,
            child: Container(
              constraints: BoxConstraints(
                minWidth: widget.minSize.width,
                minHeight: widget.minSize.height,
              ),
              decoration: BoxDecoration(
                color: _colorAnimation.value ?? 
                       (widget.backgroundColor ?? theme.brandPrimary),
                borderRadius: widget.borderRadius ?? 
                           BorderRadius.circular(theme.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: _isPressed ? widget.pressedElevation : widget.elevation,
                    offset: Offset(0, _isPressed ? widget.pressedElevation / 2 : widget.elevation / 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: widget.padding ?? EdgeInsets.all(theme.spaceMD),
                  child: Center(
                    child: widget.child,
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