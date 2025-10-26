import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// Enhanced micro-interactions for polished UI components
/// Provides delightful feedback and smooth animations throughout the app

/// Enhanced button press animation with multiple effects
class EnhancedPressAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleDown;
  final bool enableHaptics;
  final bool enableRipple;
  final Color? rippleColor;
  final bool enableShadow;

  const EnhancedPressAnimation({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 150),
    this.scaleDown = 0.95,
    this.enableHaptics = true,
    this.enableRipple = false,
    this.rippleColor,
    this.enableShadow = false,
  });

  @override
  State<EnhancedPressAnimation> createState() => _EnhancedPressAnimationState();
}

class _EnhancedPressAnimationState extends State<EnhancedPressAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _shadowAnimation;

  Offset? _tapPosition;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _shadowAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = true;
        _tapPosition = details.localPosition;
      });
      
      _scaleController.forward();
      
      if (widget.enableRipple) {
        _rippleController.forward(from: 0.0);
      }
      
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
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
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleController, _rippleController]),
        builder: (context, child) {
          Widget result = Transform.scale(
            scale: _scaleAnimation.value,
            child: widget.child,
          );

          if (widget.enableShadow) {
            result = Container(
              decoration: BoxDecoration(
                boxShadow: tokens.elevation.md.map((shadow) {
                  return BoxShadow(
                    color: shadow.color.withAlpha(
                      (shadow.color.alpha * _shadowAnimation.value).round(),
                    ),
                    blurRadius: shadow.blurRadius,
                    offset: shadow.offset,
                  );
                }).toList(),
              ),
              child: result,
            );
          }

          if (widget.enableRipple && _tapPosition != null) {
            result = CustomPaint(
              painter: _RipplePainter(
                animation: _rippleAnimation,
                tapPosition: _tapPosition!,
                color: widget.rippleColor ?? tokens.colors.primary.withAlpha(51),
              ),
              child: result,
            );
          }

          return result;
        },
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  final Offset tapPosition;
  final Color color;

  _RipplePainter({
    required this.animation,
    required this.tapPosition,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value == 0.0) return;

    final paint = Paint()
      ..color = color.withAlpha((255 * (1.0 - animation.value)).round())
      ..style = PaintingStyle.fill;

    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final radius = maxRadius * animation.value;

    canvas.drawCircle(tapPosition, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Floating animation for elements that should feel weightless
class FloatingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double amplitude;
  final bool autoStart;

  const FloatingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 3000),
    this.amplitude = 8.0,
    this.autoStart = true,
  });

  @override
  State<FloatingAnimation> createState() => _FloatingAnimationState();
}

class _FloatingAnimationState extends State<FloatingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -widget.amplitude,
      end: widget.amplitude,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
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
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: widget.child,
        );
      },
    );
  }
}

/// Breathing animation for attention-grabbing elements
class BreathingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool autoStart;

  const BreathingAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.minScale = 0.98,
    this.maxScale = 1.02,
    this.autoStart = true,
  });

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// Shimmer loading animation
class ShimmerAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;
  final bool enabled;

  const ShimmerAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
    this.enabled = true,
  });

  @override
  State<ShimmerAnimation> createState() => _ShimmerAnimationState();
}

class _ShimmerAnimationState extends State<ShimmerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
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
    final baseColor = widget.baseColor ?? tokens.colors.surfaceVariant;
    final highlightColor = widget.highlightColor ?? tokens.colors.surface;

    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                math.max(0.0, _animation.value - 0.3),
                _animation.value,
                math.min(1.0, _animation.value + 0.3),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Typewriter animation for text
class TypewriterAnimation extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;
  final bool autoStart;
  final VoidCallback? onComplete;

  const TypewriterAnimation({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 50),
    this.delay = Duration.zero,
    this.autoStart = true,
    this.onComplete,
  });

  @override
  State<TypewriterAnimation> createState() => _TypewriterAnimationState();
}

class _TypewriterAnimationState extends State<TypewriterAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _characterCount;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration * widget.text.length,
      vsync: this,
    );

    _characterCount = IntTween(
      begin: 0,
      end: widget.text.length,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoStart) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void start() {
    _controller.forward();
  }

  void reset() {
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _characterCount,
      builder: (context, child) {
        final displayText = widget.text.substring(0, _characterCount.value);
        return Text(
          displayText,
          style: widget.style,
        );
      },
    );
  }
}

/// Particle explosion animation
class ParticleExplosion extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final int particleCount;
  final List<Color>? colors;

  const ParticleExplosion({
    super.key,
    required this.child,
    required this.isActive,
    this.duration = const Duration(milliseconds: 2000),
    this.particleCount = 20,
    this.colors,
  });

  @override
  State<ParticleExplosion> createState() => _ParticleExplosionState();
}

class _ParticleExplosionState extends State<ParticleExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _generateParticles();
  }

  @override
  void didUpdateWidget(ParticleExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _generateParticles();
      _controller.forward(from: 0.0);
      HapticFeedback.mediumImpact();
    }
  }

  void _generateParticles() {
    final random = math.Random();
    final colors = widget.colors ?? [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    _particles = List.generate(widget.particleCount, (index) {
      final angle = (index / widget.particleCount) * 2 * math.pi;
      final velocity = 2.0 + random.nextDouble() * 3.0;
      
      return Particle(
        x: 0.5,
        y: 0.5,
        velocityX: math.cos(angle) * velocity,
        velocityY: math.sin(angle) * velocity,
        color: colors[random.nextInt(colors.length)],
        size: 4.0 + random.nextDouble() * 6.0,
        life: 0.8 + random.nextDouble() * 0.4,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ParticlePainter(
                      animation: _controller,
                      particles: _particles,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class Particle {
  final double x;
  final double y;
  final double velocityX;
  final double velocityY;
  final Color color;
  final double size;
  final double life;

  Particle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.color,
    required this.size,
    required this.life,
  });
}

class ParticlePainter extends CustomPainter {
  final Animation<double> animation;
  final List<Particle> particles;

  ParticlePainter({
    required this.animation,
    required this.particles,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final particle in particles) {
      final progress = animation.value;
      final life = (progress / particle.life).clamp(0.0, 1.0);
      
      if (life >= 1.0) continue;

      final gravity = 0.5 * progress * progress;
      final x = size.width * (particle.x + particle.velocityX * progress * 0.1);
      final y = size.height * (particle.y + particle.velocityY * progress * 0.1 + gravity * 0.1);

      final opacity = (1.0 - life);
      paint.color = particle.color.withAlpha((255 * opacity).round());

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1.0 - life * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Morphing icon animation
class MorphingIcon extends StatefulWidget {
  final IconData startIcon;
  final IconData endIcon;
  final bool isToggled;
  final Duration duration;
  final Color? color;
  final double? size;
  final VoidCallback? onTap;

  const MorphingIcon({
    super.key,
    required this.startIcon,
    required this.endIcon,
    required this.isToggled,
    this.duration = const Duration(milliseconds: 300),
    this.color,
    this.size,
    this.onTap,
  });

  @override
  State<MorphingIcon> createState() => _MorphingIconState();
}

class _MorphingIconState extends State<MorphingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    if (widget.isToggled) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MorphingIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isToggled != oldWidget.isToggled) {
      if (widget.isToggled) {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Start icon
                Transform.scale(
                  scale: 1.0 - _scaleAnimation.value,
                  child: Opacity(
                    opacity: 1.0 - _controller.value,
                    child: Icon(
                      widget.startIcon,
                      color: widget.color,
                      size: widget.size,
                    ),
                  ),
                ),
                // End icon
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _controller.value,
                    child: Icon(
                      widget.endIcon,
                      color: widget.color,
                      size: widget.size,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Enhanced button with multiple interaction states
class InteractiveButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final InteractiveButtonStyle style;
  final bool enableHaptics;
  final bool enableRipple;
  final bool enableScale;
  final bool enableGlow;

  const InteractiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.style = InteractiveButtonStyle.primary,
    this.enableHaptics = true,
    this.enableRipple = true,
    this.enableScale = true,
    this.enableGlow = false,
  });

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rippleController;
  late AnimationController _glowController;
  
  late Animation<double> _scaleAnimation;
  late Animation<double> _rippleAnimation;
  late Animation<double> _glowAnimation;
  
  Offset? _tapPosition;
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOut,
    ));

    _rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    if (widget.enableGlow) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rippleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() {
        _isPressed = true;
        _tapPosition = details.localPosition;
      });
      
      if (widget.enableScale) {
        _scaleController.forward();
      }
      
      if (widget.enableRipple) {
        _rippleController.forward(from: 0.0);
      }
      
      if (widget.enableHaptics) {
        HapticFeedback.lightImpact();
      }
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
      if (widget.enableScale && !_isHovered) {
        _scaleController.reverse();
      }
    }
  }

  void _onHover(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (widget.enableScale) {
      if (isHovered && !_isPressed) {
        _scaleController.forward();
      } else if (!isHovered && !_isPressed) {
        _scaleController.reverse();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqDesignTokens.of(context);
    
    Color backgroundColor;
    Color foregroundColor;
    List<BoxShadow>? boxShadow;
    
    switch (widget.style) {
      case InteractiveButtonStyle.primary:
        backgroundColor = tokens.colors.primary;
        foregroundColor = tokens.colors.onPrimary;
        boxShadow = tokens.elevation.md;
        break;
      case InteractiveButtonStyle.secondary:
        backgroundColor = tokens.colors.surface;
        foregroundColor = tokens.colors.primary;
        boxShadow = tokens.elevation.sm;
        break;
      case InteractiveButtonStyle.ghost:
        backgroundColor = Colors.transparent;
        foregroundColor = tokens.colors.primary;
        boxShadow = null;
        break;
    }

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.onPressed != null,
      child: MouseRegion(
        onEnter: (_) => _onHover(true),
        onExit: (_) => _onHover(false),
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _scaleController,
              _rippleController,
              _glowController,
            ]),
            builder: (context, child) {
              Widget result = Container(
                constraints: const BoxConstraints(
                  minWidth: MinqSpacingTokens.minTouchTarget,
                  minHeight: MinqSpacingTokens.minTouchTarget,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: MinqSpacingTokens.lg,
                  vertical: MinqSpacingTokens.md,
                ),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: tokens.radius.mdRadius,
                  boxShadow: boxShadow,
                ),
                child: Center(
                  child: DefaultTextStyle(
                    style: tokens.typography.labelLarge.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                    child: IconTheme(
                      data: IconThemeData(
                        color: foregroundColor,
                        size: 18,
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
              );

              if (widget.enableScale) {
                result = Transform.scale(
                  scale: _scaleAnimation.value,
                  child: result,
                );
              }

              if (widget.enableRipple && _tapPosition != null) {
                result = CustomPaint(
                  painter: _RipplePainter(
                    animation: _rippleAnimation,
                    tapPosition: _tapPosition!,
                    color: foregroundColor.withAlpha(51),
                  ),
                  child: result,
                );
              }

              if (widget.enableGlow) {
                result = Container(
                  decoration: BoxDecoration(
                    borderRadius: tokens.radius.mdRadius,
                    boxShadow: [
                      BoxShadow(
                        color: backgroundColor.withAlpha(
                          (100 * _glowAnimation.value).round(),
                        ),
                        blurRadius: 20 * _glowAnimation.value,
                        spreadRadius: 2 * _glowAnimation.value,
                      ),
                    ],
                  ),
                  child: result,
                );
              }

              return result;
            },
          ),
        ),
      ),
    );
  }
}

/// Enhanced loading animation with multiple styles
class LoadingAnimation extends StatefulWidget {
  final LoadingStyle style;
  final Color? color;
  final double size;
  final Duration duration;

  const LoadingAnimation({
    super.key,
    this.style = LoadingStyle.dots,
    this.color,
    this.size = 40.0,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
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
    final tokens = MinqDesignTokens.of(context);
    final color = widget.color ?? tokens.colors.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          switch (widget.style) {
            case LoadingStyle.dots:
              return _DotsLoader(
                animation: _controller,
                color: color,
                size: widget.size,
              );
            case LoadingStyle.pulse:
              return _PulseLoader(
                animation: _controller,
                color: color,
                size: widget.size,
              );
            case LoadingStyle.wave:
              return _WaveLoader(
                animation: _controller,
                color: color,
                size: widget.size,
              );
            case LoadingStyle.spinner:
              return _SpinnerLoader(
                animation: _controller,
                color: color,
                size: widget.size,
              );
          }
        },
      ),
    );
  }
}

class _DotsLoader extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _DotsLoader({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        final delay = index * 0.2;
        final progress = (animation.value + delay) % 1.0;
        final scale = math.sin(progress * math.pi);
        
        return Transform.scale(
          scale: 0.5 + (scale * 0.5),
          child: Container(
            width: size * 0.2,
            height: size * 0.2,
            decoration: BoxDecoration(
              color: color.withAlpha((255 * (0.3 + scale * 0.7)).round()),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

class _PulseLoader extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _PulseLoader({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 0.5 + (math.sin(animation.value * 2 * math.pi) * 0.5);
    
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color.withAlpha((255 * scale).round()),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _WaveLoader extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _WaveLoader({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(5, (index) {
        final delay = index * 0.1;
        final progress = (animation.value + delay) % 1.0;
        final height = math.sin(progress * math.pi);
        
        return Container(
          width: size * 0.1,
          height: size * (0.2 + height * 0.8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(size * 0.05),
          ),
        );
      }),
    );
  }
}

class _SpinnerLoader extends StatelessWidget {
  final Animation<double> animation;
  final Color color;
  final double size;

  const _SpinnerLoader({
    required this.animation,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: animation.value * 2 * math.pi,
      child: CustomPaint(
        size: Size(size, size),
        painter: _SpinnerPainter(color: color),
      ),
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;

  _SpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // Draw gradient arc
    const sweepAngle = math.pi * 1.5;
    for (int i = 0; i < 8; i++) {
      final startAngle = (i / 8) * 2 * math.pi;
      final opacity = (i + 1) / 8;
      paint.color = color.withAlpha((255 * opacity).round());
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle / 8,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Enums for component variants
enum InteractiveButtonStyle {
  primary,
  secondary,
  ghost,
}

enum LoadingStyle {
  dots,
  pulse,
  wave,
  spinner,
}