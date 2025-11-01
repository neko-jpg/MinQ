import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// An animated checkbox that provides delightful micro-interactions
/// Features bounce animation, glow effects, and haptic feedback
class AnimatedCheckbox extends StatefulWidget {
  const AnimatedCheckbox({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.size = 24.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.showConfetti = false,
    this.enableHapticFeedback = true,
    this.enableSoundFeedback = true,
    this.checkColor,
    this.activeColor,
    this.inactiveColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius,
  });

  /// Whether the checkbox is currently checked
  final bool isChecked;

  /// Callback when the checkbox state changes
  final ValueChanged<bool> onChanged;

  /// Size of the checkbox
  final double size;

  /// Duration of the check/uncheck animation
  final Duration animationDuration;

  /// Whether to show confetti effect on check
  final bool showConfetti;

  /// Whether to provide haptic feedback
  final bool enableHapticFeedback;

  /// Whether to provide sound feedback
  final bool enableSoundFeedback;

  /// Color of the checkmark
  final Color? checkColor;

  /// Color when checkbox is active/checked
  final Color? activeColor;

  /// Color when checkbox is inactive/unchecked
  final Color? inactiveColor;

  /// Border color
  final Color? borderColor;

  /// Border width
  final double borderWidth;

  /// Border radius
  final BorderRadius? borderRadius;

  @override
  State<AnimatedCheckbox> createState() => _AnimatedCheckboxState();
}

class _AnimatedCheckboxState extends State<AnimatedCheckbox>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late AnimationController _glowController;
  late AnimationController _bounceController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Scale animation for press feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Check animation for the checkmark appearance
    _checkController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.elasticOut),
    );

    // Glow animation for success feedback
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Bounce animation for celebration
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    // Set initial state
    if (widget.isChecked) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isChecked != widget.isChecked) {
      _animateStateChange();
    }
  }

  void _animateStateChange() {
    if (widget.isChecked) {
      _checkController.forward();
      _glowController.forward().then((_) {
        _glowController.reverse();
      });
      if (widget.showConfetti) {
        _bounceController.forward().then((_) {
          _bounceController.reverse();
        });
      }
    } else {
      _checkController.reverse();
    }
  }

  void _handleTap() {
    // Scale animation for press feedback
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    // Provide feedback
    if (widget.enableHapticFeedback || widget.enableSoundFeedback) {
      if (widget.isChecked) {
        // Unchecking - simple feedback
        if (widget.enableHapticFeedback && widget.enableSoundFeedback) {
          FeedbackManager.toggled();
        } else if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      } else {
        // Checking - celebration feedback
        if (widget.enableHapticFeedback && widget.enableSoundFeedback) {
          FeedbackManager.questCompleted();
        } else if (widget.enableHapticFeedback) {
          HapticFeedback.lightImpact();
        }
      }
    }

    // Call the callback
    widget.onChanged(!widget.isChecked);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    _glowController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = MinqTheme.of(context);

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _checkAnimation,
          _glowAnimation,
          _bounceAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * _bounceAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color:
                    widget.isChecked
                        ? (widget.activeColor ?? theme.progressComplete)
                        : (widget.inactiveColor ?? theme.surface),
                borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
                border: Border.all(
                  color:
                      widget.isChecked
                          ? (widget.activeColor ?? theme.progressComplete)
                          : (widget.borderColor ?? theme.border),
                  width: widget.borderWidth,
                ),
                boxShadow:
                    _glowAnimation.value > 0
                        ? [
                          BoxShadow(
                            color: (widget.activeColor ??
                                    theme.progressComplete)
                                .withAlpha(
                                  (_glowAnimation.value * 102).round(),
                                ),
                            blurRadius: 8 * _glowAnimation.value,
                            spreadRadius: 2 * _glowAnimation.value,
                          ),
                        ]
                        : null,
              ),
              child:
                  widget.isChecked
                      ? Transform.scale(
                        scale: _checkAnimation.value,
                        child: Icon(
                          Icons.check,
                          size: widget.size * 0.7,
                          color: widget.checkColor ?? Colors.white,
                        ),
                      )
                      : null,
            ),
          );
        },
      ),
    );
  }
}
