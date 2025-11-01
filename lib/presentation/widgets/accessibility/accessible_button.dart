import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:minq/core/accessibility/semantic_helpers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Accessible button widget that adapts to accessibility settings
class AccessibleButton extends ConsumerWidget {
  const AccessibleButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.semanticHint,
    this.style,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final ButtonStyle? style;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final accessibilitySettings = ref.watch(accessibilityServiceProvider);

    // Calculate effective button size based on accessibility settings
    const baseSize = 44.0; // Minimum touch target size
    final effectiveSize = baseSize * accessibilitySettings.buttonScale;

    // Get accessible colors
    final backgroundColor =
        enabled
            ? (accessibilitySettings.highContrast
                ? tokens.highContrastPrimary
                : tokens.brandPrimary)
            : tokens.textMuted;

    final foregroundColor =
        enabled
            ? (accessibilitySettings.highContrast
                ? tokens.highContrastText
                : tokens.primaryForeground)
            : tokens.textSecondary;

    // Create button style with accessibility considerations
    final effectiveStyle = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return tokens.textMuted;
        }
        if (states.contains(WidgetState.pressed)) {
          return backgroundColor.withValues(alpha: 0.8);
        }
        if (states.contains(WidgetState.hovered)) {
          return tokens.primaryHover;
        }
        return backgroundColor;
      }),
      foregroundColor: WidgetStateProperty.all(foregroundColor),
      minimumSize: WidgetStateProperty.all(Size(effectiveSize, effectiveSize)),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: tokens.spacing.md * accessibilitySettings.buttonScale,
          vertical: tokens.spacing.sm * accessibilitySettings.buttonScale,
        ),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: tokens.cornerMedium(),
          side:
              accessibilitySettings.highContrast
                  ? BorderSide(color: tokens.border, width: 2)
                  : BorderSide.none,
        ),
      ),
      elevation: WidgetStateProperty.resolveWith((states) {
        if (accessibilitySettings.highContrast) return 0;
        if (states.contains(WidgetState.pressed)) return 1;
        return 2;
      }),
      overlayColor: WidgetStateProperty.all(tokens.tapFeedback),
    ).merge(style);

    Widget button = ElevatedButton(
      onPressed:
          enabled
              ? () {
                // Provide haptic feedback if enabled
                ref
                    .read(accessibilityServiceProvider.notifier)
                    .provideHapticFeedback();
                onPressed?.call();
              }
              : null,
      style: effectiveStyle,
      focusNode: focusNode,
      autofocus: autofocus,
      child: DefaultTextStyle(
        style: TextStyle(
          fontSize: 16 * accessibilitySettings.textScale,
          fontWeight:
              accessibilitySettings.boldText
                  ? FontWeight.bold
                  : FontWeight.w600,
        ),
        child: child,
      ),
    );

    // Add focus indicator for keyboard navigation
    if (accessibilitySettings.focusIndicator) {
      button = Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration:
                  hasFocus
                      ? BoxDecoration(
                        borderRadius: tokens.cornerMedium(),
                        border: Border.all(
                          color: tokens.brandPrimary,
                          width: 3,
                        ),
                      )
                      : null,
              child: button,
            );
          },
        ),
      );
    }

    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    // Wrap with semantic helpers
    return SemanticHelpers.accessibleButton(
      child: button,
      onPressed: enabled ? onPressed : null,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      enabled: enabled,
      tooltip: tooltip,
    );
  }
}

/// Accessible icon button variant
class AccessibleIconButton extends ConsumerWidget {
  const AccessibleIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
    this.size,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final String semanticLabel;
  final String? semanticHint;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;
  final double? size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final accessibilitySettings = ref.watch(accessibilityServiceProvider);

    // Calculate effective size
    final baseSize = size ?? 48.0;
    final effectiveSize = baseSize * accessibilitySettings.buttonScale;

    Widget button = IconButton(
      onPressed:
          enabled
              ? () {
                ref
                    .read(accessibilityServiceProvider.notifier)
                    .provideHapticFeedback();
                onPressed?.call();
              }
              : null,
      icon: icon,
      iconSize: effectiveSize * 0.6, // Icon should be 60% of button size
      focusNode: focusNode,
      autofocus: autofocus,
      style: ButtonStyle(
        minimumSize: WidgetStateProperty.all(
          Size(effectiveSize, effectiveSize),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (!enabled) return Colors.transparent;
          if (accessibilitySettings.highContrast) {
            return states.contains(WidgetState.pressed)
                ? tokens.highContrastPrimary.withValues(alpha: 0.2)
                : Colors.transparent;
          }
          return states.contains(WidgetState.pressed)
              ? tokens.tapFeedback
              : Colors.transparent;
        }),
        foregroundColor: WidgetStateProperty.all(
          enabled
              ? (accessibilitySettings.highContrast
                  ? tokens.highContrastText
                  : tokens.textPrimary)
              : tokens.textMuted,
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: tokens.cornerMedium(),
            side:
                accessibilitySettings.highContrast && enabled
                    ? BorderSide(color: tokens.border, width: 1)
                    : BorderSide.none,
          ),
        ),
      ),
    );

    // Add focus indicator
    if (accessibilitySettings.focusIndicator) {
      button = Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration:
                  hasFocus
                      ? BoxDecoration(
                        borderRadius: tokens.cornerMedium(),
                        border: Border.all(
                          color: tokens.brandPrimary,
                          width: 2,
                        ),
                      )
                      : null,
              child: button,
            );
          },
        ),
      );
    }

    // Add tooltip
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return SemanticHelpers.accessibleButton(
      child: button,
      onPressed: enabled ? onPressed : null,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      enabled: enabled,
      tooltip: tooltip,
    );
  }
}

/// Accessible floating action button
class AccessibleFloatingActionButton extends ConsumerWidget {
  const AccessibleFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.semanticLabel,
    this.semanticHint,
    this.tooltip,
    this.focusNode,
    this.autofocus = false,
    this.mini = false,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final String semanticLabel;
  final String? semanticHint;
  final String? tooltip;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool mini;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final accessibilitySettings = ref.watch(accessibilityServiceProvider);

    // Calculate effective size
    final baseSize = mini ? 40.0 : 56.0;
    final effectiveSize = baseSize * accessibilitySettings.buttonScale;

    Widget fab = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: FloatingActionButton(
        onPressed: () {
          ref
              .read(accessibilityServiceProvider.notifier)
              .provideHapticFeedback();
          onPressed?.call();
        },
        focusNode: focusNode,
        autofocus: autofocus,
        backgroundColor:
            accessibilitySettings.highContrast
                ? tokens.highContrastPrimary
                : tokens.brandPrimary,
        foregroundColor:
            accessibilitySettings.highContrast
                ? tokens.highContrastText
                : tokens.primaryForeground,
        elevation: accessibilitySettings.highContrast ? 0 : 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(effectiveSize / 2),
          side:
              accessibilitySettings.highContrast
                  ? BorderSide(color: tokens.border, width: 2)
                  : BorderSide.none,
        ),
        child: child,
      ),
    );

    // Add focus indicator
    if (accessibilitySettings.focusIndicator) {
      fab = Focus(
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration:
                  hasFocus
                      ? BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: tokens.brandPrimary,
                          width: 3,
                        ),
                      )
                      : null,
              child: fab,
            );
          },
        ),
      );
    }

    // Add tooltip
    if (tooltip != null) {
      fab = Tooltip(message: tooltip!, child: fab);
    }

    return SemanticHelpers.accessibleButton(
      child: fab,
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      tooltip: tooltip,
    );
  }
}
