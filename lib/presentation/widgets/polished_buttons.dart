import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:minq/presentation/theme/design_tokens.dart';
import 'package:minq/presentation/widgets/micro_interactions.dart';

/// Polished button components with refined designs, shadows, and gradients
/// Replaces basic circular button shapes with professional UI components

/// Primary action button with gradient background and shadow
class PolishedPrimaryButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool isLoading;
  final IconData? icon;

  const PolishedPrimaryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.padding,
    this.width,
    this.height,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PolishedPrimaryButton> createState() => _PolishedPrimaryButtonState();
}

class _PolishedPrimaryButtonState extends State<PolishedPrimaryButton>
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

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: isEnabled,
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
                width: widget.width,
                height: widget.height ?? MinqSpacingTokens.minTouchTarget,
                constraints: const BoxConstraints(
                  minWidth: MinqSpacingTokens.minTouchTarget,
                  minHeight: MinqSpacingTokens.minTouchTarget,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isEnabled
                        ? [
                            tokens.colors.primary,
                            tokens.colors.primaryHover,
                          ]
                        : [
                            tokens.colors.outline,
                            tokens.colors.outlineVariant,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: tokens.radius.mdRadius,
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
                          horizontal: tokens.spacing.lg,
                          vertical: tokens.spacing.md,
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
                              valueColor: AlwaysStoppedAnimation(
                                tokens.colors.onPrimary,
                              ),
                            ),
                          )
                        else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: tokens.colors.onPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (!widget.isLoading)
                          DefaultTextStyle(
                            style: tokens.typography.labelLarge.copyWith(
                              color: tokens.colors.onPrimary,
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
      ),
    );
  }
}

/// Secondary button with subtle background and border
class PolishedSecondaryButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool isLoading;
  final IconData? icon;

  const PolishedSecondaryButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.padding,
    this.width,
    this.height,
    this.isLoading = false,
    this.icon,
  });

  @override
  State<PolishedSecondaryButton> createState() => _PolishedSecondaryButtonState();
}

class _PolishedSecondaryButtonState extends State<PolishedSecondaryButton>
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

    _backgroundAnimation = ColorTween(
      begin: tokens.colors.surface,
      end: tokens.colors.surfaceContainer,
    ).animate(_controller);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: isEnabled,
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
                width: widget.width,
                height: widget.height ?? MinqSpacingTokens.minTouchTarget,
                constraints: const BoxConstraints(
                  minWidth: MinqSpacingTokens.minTouchTarget,
                  minHeight: MinqSpacingTokens.minTouchTarget,
                ),
                decoration: BoxDecoration(
                  color: _backgroundAnimation.value,
                  borderRadius: tokens.radius.mdRadius,
                  border: Border.all(
                    color: isEnabled
                        ? tokens.colors.outline
                        : tokens.colors.outlineVariant,
                    width: 1.5,
                  ),
                  boxShadow: isEnabled ? tokens.elevation.sm : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: widget.padding ??
                        EdgeInsets.symmetric(
                          horizontal: tokens.spacing.lg,
                          vertical: tokens.spacing.md,
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
                              valueColor: AlwaysStoppedAnimation(
                                tokens.colors.primary,
                              ),
                            ),
                          )
                        else if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: tokens.colors.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (!widget.isLoading)
                          DefaultTextStyle(
                            style: tokens.typography.labelLarge.copyWith(
                              color: tokens.colors.primary,
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
      ),
    );
  }
}

/// Floating action button with enhanced shadow and micro-interactions
class PolishedFloatingActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;

  const PolishedFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
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

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.onPressed != null,
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
                  gradient: LinearGradient(
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

/// Icon button with subtle hover effects and proper touch targets
class PolishedIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final Color? color;
  final double? size;
  final EdgeInsets? padding;

  const PolishedIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.semanticLabel,
    this.color,
    this.size,
    this.padding,
  });

  @override
  State<PolishedIconButton> createState() => _PolishedIconButtonState();
}

class _PolishedIconButtonState extends State<PolishedIconButton>
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
    if (widget.onPressed != null) {
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
    final iconColor = widget.color ?? tokens.colors.onSurface;

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: iconColor.withAlpha(20),
    ).animate(_controller);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.onPressed != null,
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
                constraints: const BoxConstraints(
                  minWidth: MinqSpacingTokens.minTouchTarget,
                  minHeight: MinqSpacingTokens.minTouchTarget,
                ),
                decoration: BoxDecoration(
                  color: _backgroundAnimation.value,
                  borderRadius: tokens.radius.smRadius,
                ),
                padding: widget.padding ?? EdgeInsets.all(tokens.spacing.sm),
                child: Icon(
                  widget.icon,
                  color: iconColor,
                  size: widget.size ?? 24,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Text button with subtle hover effects
class PolishedTextButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final EdgeInsets? padding;

  const PolishedTextButton({
    super.key,
    required this.child,
    this.onPressed,
    this.semanticLabel,
    this.padding,
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
    if (widget.onPressed != null) {
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

    _backgroundAnimation = ColorTween(
      begin: Colors.transparent,
      end: tokens.colors.primary.withAlpha(15),
    ).animate(_controller);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: widget.onPressed != null,
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
                      horizontal: tokens.spacing.md,
                      vertical: tokens.spacing.sm,
                    ),
                child: Center(
                  child: DefaultTextStyle(
                    style: tokens.typography.labelLarge.copyWith(
                      color: tokens.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    child: widget.child,
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