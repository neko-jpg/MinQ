import 'package:flutter/material.dart';
import 'package:minq/core/accessibility/accessibility_service.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// WCAG AA compliant button with minimum 44pt touch target
class AccessibleElevatedButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonStyle? style;
  final bool autofocus;
  final Clip clipBehavior;
  final FocusNode? focusNode;

  const AccessibleElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final accessibilityService = AccessibilityService.instance;

    Widget button = ElevatedButton(
      onPressed: onPressed,
      style: _getAccessibleStyle(context, tokens),
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      child: child,
    );

    // Add tooltip if provided
    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    // Wrap with proper semantics
    return accessibilityService.wrapWithSemantics(
      child: button,
      label: semanticLabel,
      button: true,
      focusable: true,
      onTap: onPressed,
    );
  }

  ButtonStyle _getAccessibleStyle(BuildContext context, MinqTheme tokens) {
    final baseStyle = style ?? ElevatedButton.styleFrom();

    return baseStyle.copyWith(
      // Ensure minimum touch target size
      minimumSize: WidgetStateProperty.all(const Size(44.0, 44.0)),
      // Ensure adequate padding
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
      ),
      // Ensure accessible colors
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        final originalColor =
            baseStyle.backgroundColor?.resolve(states) ?? tokens.brandPrimary;
        return tokens.ensureAccessibleOnBackground(
          originalColor,
          tokens.background,
        );
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        final backgroundColor =
            baseStyle.backgroundColor?.resolve(states) ?? tokens.brandPrimary;
        return tokens.ensureAccessibleOnBackground(
          tokens.primaryForeground,
          backgroundColor,
        );
      }),
    );
  }
}

/// WCAG AA compliant text button with minimum 44pt touch target
class AccessibleTextButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final ButtonStyle? style;
  final bool autofocus;
  final Clip clipBehavior;
  final FocusNode? focusNode;

  const AccessibleTextButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.style,
    this.autofocus = false,
    this.clipBehavior = Clip.none,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final accessibilityService = AccessibilityService.instance;

    Widget button = TextButton(
      onPressed: onPressed,
      style: _getAccessibleStyle(context, tokens),
      autofocus: autofocus,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      child: child,
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return accessibilityService.wrapWithSemantics(
      child: button,
      label: semanticLabel,
      button: true,
      focusable: true,
      onTap: onPressed,
    );
  }

  ButtonStyle _getAccessibleStyle(BuildContext context, MinqTheme tokens) {
    final baseStyle = style ?? TextButton.styleFrom();

    return baseStyle.copyWith(
      minimumSize: WidgetStateProperty.all(const Size(44.0, 44.0)),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
      ),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        final originalColor =
            baseStyle.foregroundColor?.resolve(states) ?? tokens.brandPrimary;
        return tokens.ensureAccessibleOnBackground(
          originalColor,
          tokens.background,
        );
      }),
    );
  }
}

/// WCAG AA compliant icon button with minimum 44pt touch target
class AccessibleIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final double? iconSize;
  final Color? color;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.iconSize,
    this.color,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final accessibilityService = AccessibilityService.instance;

    // Ensure accessible color
    final accessibleColor =
        color != null
            ? tokens.ensureAccessibleOnBackground(color!, tokens.background)
            : tokens.textPrimary;

    Widget button = IconButton(
      onPressed: onPressed,
      icon: icon,
      iconSize: iconSize,
      color: accessibleColor,
      autofocus: autofocus,
      focusNode: focusNode,
      constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
      padding: EdgeInsets.all(tokens.spacing.sm),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return accessibilityService.wrapWithSemantics(
      child: button,
      label: semanticLabel ?? tooltip,
      button: true,
      focusable: true,
      onTap: onPressed,
    );
  }
}

/// Accessible floating action button with proper semantics
class AccessibleFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? semanticLabel;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool mini;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleFloatingActionButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.semanticLabel,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.mini = false,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final accessibilityService = AccessibilityService.instance;

    // Ensure accessible colors
    final accessibleBgColor =
        backgroundColor != null
            ? tokens.ensureAccessibleOnBackground(
              backgroundColor!,
              tokens.background,
            )
            : tokens.brandPrimary;

    final accessibleFgColor =
        foregroundColor != null
            ? tokens.ensureAccessibleOnBackground(
              foregroundColor!,
              accessibleBgColor,
            )
            : tokens.primaryForeground;

    Widget button = FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: accessibleBgColor,
      foregroundColor: accessibleFgColor,
      mini: mini,
      autofocus: autofocus,
      focusNode: focusNode,
      tooltip: tooltip,
      child: child,
    );

    return accessibilityService.wrapWithSemantics(
      child: button,
      label: semanticLabel ?? tooltip,
      button: true,
      focusable: true,
      onTap: onPressed,
    );
  }
}

/// Accessible switch with proper semantics and touch targets
class AccessibleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.activeColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final accessibilityService = AccessibilityService.instance;

    Widget switchWidget = Switch(
      value: value,
      onChanged: onChanged,
      activeThumbColor: activeColor ?? tokens.brandPrimary,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      autofocus: autofocus,
      focusNode: focusNode,
    );

    // Ensure minimum touch target
    switchWidget = Container(
      constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
      alignment: Alignment.center,
      child: switchWidget,
    );

    final statusText = value ? '有効' : '無効';
    final fullLabel =
        semanticLabel != null
            ? '$semanticLabel、スイッチ、$statusText'
            : 'スイッチ、$statusText';

    return accessibilityService.wrapWithSemantics(
      child: switchWidget,
      label: fullLabel,
      focusable: true,
      onTap: onChanged != null ? () => onChanged!(!value) : null,
    );
  }
}

/// Accessible checkbox with proper semantics and touch targets
class AccessibleCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? semanticLabel;
  final Color? activeColor;
  final Color? checkColor;
  final bool tristate;
  final bool autofocus;
  final FocusNode? focusNode;

  const AccessibleCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
    this.activeColor,
    this.checkColor,
    this.tristate = false,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final accessibilityService = AccessibilityService.instance;

    Widget checkbox = Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: activeColor ?? tokens.brandPrimary,
      checkColor: checkColor,
      tristate: tristate,
      autofocus: autofocus,
      focusNode: focusNode,
    );

    // Ensure minimum touch target
    checkbox = Container(
      constraints: const BoxConstraints(minWidth: 44.0, minHeight: 44.0),
      alignment: Alignment.center,
      child: checkbox,
    );

    String statusText;
    if (tristate && value == null) {
      statusText = '部分選択';
    } else if (value == true) {
      statusText = '選択済み';
    } else {
      statusText = '未選択';
    }

    final fullLabel =
        semanticLabel != null
            ? '$semanticLabel、チェックボックス、$statusText'
            : 'チェックボックス、$statusText';

    return accessibilityService.wrapWithSemantics(
      child: checkbox,
      label: fullLabel,
      focusable: true,
      onTap: onChanged != null ? () => onChanged!(!value!) : null,
    );
  }
}
