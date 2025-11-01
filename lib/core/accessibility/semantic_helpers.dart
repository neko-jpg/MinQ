import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Helper class for creating accessible widgets with proper semantic labels
class SemanticHelpers {
  /// Create an accessible button with proper semantics
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String semanticLabel,
    String? semanticHint,
    bool enabled = true,
    String? tooltip,
    EdgeInsets? padding,
  }) {
    Widget button = child;

    if (tooltip != null) {
      button = Tooltip(message: tooltip, child: button);
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: true,
      enabled: enabled,
      onTap: enabled ? onPressed : null,
      child: button,
    );
  }

  /// Create an accessible text field with proper semantics
  static Widget accessibleTextField({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    String? semanticValue,
    bool obscureText = false,
    bool multiline = false,
    bool readOnly = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      value: semanticValue,
      textField: true,
      obscured: obscureText,
      multiline: multiline,
      readOnly: readOnly,
      child: child,
    );
  }

  /// Create an accessible switch with proper semantics
  static Widget accessibleSwitch({
    required Widget child,
    required String semanticLabel,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      toggled: value,
      onTap: onChanged != null ? () => onChanged(!value) : null,
      child: child,
    );
  }

  /// Create an accessible slider with proper semantics
  static Widget accessibleSlider({
    required Widget child,
    required String semanticLabel,
    required double value,
    required double min,
    required double max,
    String? semanticHint,
    String? valueLabel,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      value: valueLabel ?? value.toStringAsFixed(1),
      slider: true,
      child: child,
    );
  }

  /// Create an accessible image with proper semantics
  static Widget accessibleImage({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    bool isDecorative = false,
  }) {
    if (isDecorative) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      image: true,
      child: child,
    );
  }

  /// Create an accessible list item with proper semantics
  static Widget accessibleListItem({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
    bool selected = false,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }

  /// Create an accessible header with proper semantics
  static Widget accessibleHeader({
    required Widget child,
    required String semanticLabel,
    int level = 1,
  }) {
    return Semantics(label: semanticLabel, header: true, child: child);
  }

  /// Create an accessible progress indicator with proper semantics
  static Widget accessibleProgress({
    required Widget child,
    required String semanticLabel,
    double? value,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      value: value != null ? '${(value * 100).round()}%' : null,
      child: child,
    );
  }

  /// Create an accessible card with proper semantics
  static Widget accessibleCard({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      button: onTap != null,
      onTap: onTap,
      child: child,
    );
  }

  /// Create an accessible tab with proper semantics
  static Widget accessibleTab({
    required Widget child,
    required String semanticLabel,
    required bool selected,
    required VoidCallback onTap,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      selected: selected,
      onTap: onTap,
      child: child,
    );
  }

  /// Create an accessible dialog with proper semantics
  static Widget accessibleDialog({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    bool modal = true,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      scopesRoute: modal,
      namesRoute: modal,
      child: child,
    );
  }

  /// Create an accessible alert with proper semantics
  static Widget accessibleAlert({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
    bool liveRegion = true,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      liveRegion: liveRegion,
      child: child,
    );
  }

  /// Announce a message to screen readers
  static void announceToScreenReader(
    BuildContext context,
    String message, {
    Assertiveness assertiveness = Assertiveness.polite,
  }) {
    SemanticsService.announce(
      message,
      TextDirection.ltr,
      assertiveness: assertiveness,
    );
  }

  /// Create a focus trap for modal dialogs
  static Widget focusTrap({required Widget child, required bool active}) {
    if (!active) return child;

    return FocusScope(child: child);
  }

  /// Create an accessible loading indicator
  static Widget accessibleLoading({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      liveRegion: true,
      child: child,
    );
  }

  /// Create an accessible error message
  static Widget accessibleError({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      liveRegion: true,
      child: child,
    );
  }

  /// Create an accessible success message
  static Widget accessibleSuccess({
    required Widget child,
    required String semanticLabel,
    String? semanticHint,
  }) {
    return Semantics(
      label: semanticLabel,
      hint: semanticHint,
      liveRegion: true,
      child: child,
    );
  }
}

/// Extension to add accessibility helpers to any widget
extension AccessibilityExtension on Widget {
  /// Add semantic label to any widget
  Widget withSemantics({
    required String label,
    String? hint,
    String? value,
    bool button = false,
    bool header = false,
    bool selected = false,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button,
      header: header,
      selected: selected,
      enabled: enabled,
      onTap: onTap,
      child: this,
    );
  }

  /// Exclude widget from semantics tree (for decorative elements)
  Widget excludeFromSemantics() {
    return ExcludeSemantics(child: this);
  }

  /// Merge semantics with child widgets
  Widget mergeSemantics() {
    return MergeSemantics(child: this);
  }
}
