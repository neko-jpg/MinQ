import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

typedef AsyncCallback = Future<void> Function();

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

Color _lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

mixin AsyncActionState<T extends StatefulWidget> on State<T> {
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  @protected
  Future<void> runGuarded(AsyncCallback action) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await action();
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}

class MinqPrimaryButton extends StatefulWidget {
  const MinqPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final AsyncCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  State<MinqPrimaryButton> createState() => _MinqPrimaryButtonState();
}

class _MinqPrimaryButtonState extends State<MinqPrimaryButton>
    with AsyncActionState<MinqPrimaryButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool disabled = widget.onPressed == null || isProcessing;

    Widget buildContent() {
      if (isProcessing) {
        return SizedBox(
          key: const ValueKey<String>('progress'),
          height: tokens.spacing.lg,
          width: tokens.spacing.lg,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.surface),
          ),
        );
      }

      final bool hasIcon = widget.icon != null;
      return Row(
        key: const ValueKey<String>('label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (hasIcon) ...<Widget>[
            Icon(widget.icon, size: tokens.spacing.lg),
            SizedBox(width: tokens.spacing.xs),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: tokens.typography.button.copyWith(color: tokens.surface),
            ),
          ),
        ],
      );
    }

    final baseColor = tokens.brandPrimary;
    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return baseColor.withAlpha(102);
        }
        if (states.contains(WidgetState.pressed)) {
          return _darken(baseColor, 0.15);
        }
        if (states.contains(WidgetState.hovered)) {
          return _darken(baseColor, 0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return _darken(baseColor, 0.05);
        }
        return baseColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return tokens.surface.withAlpha(179);
        }
        return tokens.surface;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return Colors.white.withAlpha(31);
        }
        if (states.contains(WidgetState.hovered)) {
          return Colors.white.withAlpha(20);
        }
        return null;
      }),
      minimumSize: WidgetStatePropertyAll<Size>(
        Size.fromHeight(tokens.spacing.xl),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.xl)),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(tokens.typography.button),
      animationDuration: const Duration(milliseconds: 150),
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    final button = FilledButton(
      style: buttonStyle,
      onPressed:
          disabled
              ? null
              : () => runGuarded(() async {
                await widget.onPressed!();
              }),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: buildContent(),
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class MinqSecondaryButton extends StatefulWidget {
  const MinqSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final AsyncCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  State<MinqSecondaryButton> createState() => _MinqSecondaryButtonState();
}

class _MinqSecondaryButtonState extends State<MinqSecondaryButton>
    with AsyncActionState<MinqSecondaryButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bool disabled = widget.onPressed == null || isProcessing;

    Widget buildContent() {
      if (isProcessing) {
        return SizedBox(
          key: const ValueKey<String>('progress'),
          height: tokens.spacing.lg,
          width: tokens.spacing.lg,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(tokens.textPrimary),
          ),
        );
      }

      final bool hasIcon = widget.icon != null;
      return Row(
        key: const ValueKey<String>('label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (hasIcon) ...<Widget>[
            Icon(widget.icon, size: tokens.spacing.lg),
            SizedBox(width: tokens.spacing.xs),
          ],
          Flexible(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: tokens.typography.button.copyWith(
                color: tokens.textPrimary,
              ),
            ),
          ),
        ],
      );
    }

    final surfaceColor = tokens.surface;
    final baseBorder = tokens.border;
    final buttonStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return surfaceColor;
        }
        if (states.contains(WidgetState.pressed)) {
          return _darken(surfaceColor, 0.06);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return _lighten(surfaceColor, 0.04);
        }
        return surfaceColor;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return tokens.textMuted;
        }
        return tokens.textPrimary;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered)) {
          return tokens.brandPrimary.withAlpha(20);
        }
        if (states.contains(WidgetState.focused)) {
          return tokens.brandPrimary.withAlpha(31);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return BorderSide(color: tokens.brandPrimary, width: 2);
        }
        return BorderSide(color: baseBorder);
      }),
      minimumSize: WidgetStatePropertyAll<Size>(
        Size.fromHeight(tokens.spacing.xl),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.xl)),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle>(tokens.typography.button),
      animationDuration: const Duration(milliseconds: 150),
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    final button = OutlinedButton(
      style: buttonStyle,
      onPressed:
          disabled
              ? null
              : () => runGuarded(() async {
                await widget.onPressed!();
              }),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: buildContent(),
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class MinqTextButton extends StatefulWidget {
  const MinqTextButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.expand = false,
    this.color,
  });

  final String label;
  final AsyncCallback? onTap;
  final IconData? icon;
  final bool expand;
  final Color? color;

  @override
  State<MinqTextButton> createState() => _MinqTextButtonState();
}

class _MinqTextButtonState extends State<MinqTextButton>
    with AsyncActionState<MinqTextButton> {
  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final Color baseColor = widget.color ?? tokens.brandPrimary;
    final bool disabled = widget.onTap == null || isProcessing;

    Widget buildContent() {
      if (isProcessing) {
        return SizedBox(
          key: const ValueKey<String>('progress'),
          height: tokens.spacing.lg,
          width: tokens.spacing.lg,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(baseColor),
          ),
        );
      }

      final children = <Widget>[];
      if (widget.icon != null) {
        children
          ..add(Icon(widget.icon, size: tokens.spacing.md))
          ..add(SizedBox(width: tokens.spacing.xs));
      }
      children.add(
        Flexible(
          child: Text(
            widget.label,
            style: tokens.typography.button.copyWith(color: baseColor),
          ),
        ),
      );

      return Row(
        key: const ValueKey<String>('label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    final buttonStyle = ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return baseColor.withAlpha(128);
        }
        return baseColor;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return baseColor.withAlpha(36);
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return baseColor.withAlpha(20);
        }
        return null;
      }),
      textStyle: WidgetStatePropertyAll<TextStyle>(tokens.typography.button),
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(widget.expand ? double.infinity : 0, tokens.spacing.xl),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(
          horizontal: tokens.spacing.sm,
          vertical: tokens.spacing.sm,
        ),
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radius.lg)),
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
      animationDuration: const Duration(milliseconds: 150),
    );

    final button = TextButton(
      onPressed:
          disabled
              ? null
              : () => runGuarded(() async {
                await widget.onTap!();
              }),
      style: buttonStyle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: buildContent(),
      ),
    );

    if (widget.expand) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class MinqIconButton extends StatelessWidget {
  const MinqIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 24.0,
    this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return IconButton(
      icon: Icon(icon, size: size, color: color ?? tokens.textPrimary),
      onPressed: onTap,
      splashRadius: size * 0.8,
      padding: const EdgeInsets.all(12.0),
    );
  }
}
