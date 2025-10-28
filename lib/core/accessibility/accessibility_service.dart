import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/accessibility/screen_reader_helper.dart';

/// Comprehensive accessibility service for WCAG AA compliance
class AccessibilityService {
  static AccessibilityService? _instance;
  static AccessibilityService get instance => _instance ??= AccessibilityService._();
  
  AccessibilityService._();

  AccessibilitySettings? _currentSettings;
  
  /// Get current accessibility settings
  AccessibilitySettings getCurrentSettings(BuildContext context) {
    return _currentSettings ??= AccessibilitySettings.fromMediaQuery(context);
  }

  /// Update accessibility settings
  void updateSettings(BuildContext context) {
    _currentSettings = AccessibilitySettings.fromMediaQuery(context);
  }

  /// Check if device has screen reader enabled
  bool isScreenReaderEnabled(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.accessibleNavigation;
  }

  /// Announce message to screen reader
  void announce(String message, {bool assertive = false}) {
    SemanticsService.announce(
      message,
      // TODO(you): This should be derived from the context's Directionality.
      // For now, hardcoding LTR as it's the dominant direction for the app.
      TextDirection.ltr,
      assertiveness: assertive ? Assertiveness.assertive : Assertiveness.polite,
    );
  }

  /// Provide haptic feedback for accessibility
  void provideHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Get accessible animation duration
  Duration getAccessibleDuration(BuildContext context, Duration baseDuration) {
    final settings = getCurrentSettings(context);
    return settings.adjustDuration(baseDuration);
  }

  /// Get accessible text style
  TextStyle getAccessibleTextStyle(BuildContext context, TextStyle baseStyle) {
    final settings = getCurrentSettings(context);
    return settings.adjustTextStyle(baseStyle);
  }

  /// Validate color contrast for accessibility
  bool validateContrast(Color foreground, Color background) {
    return ContrastValidator.meetsWCAGAA(foreground, background);
  }

  /// Get accessible color combination
  Color getAccessibleColor(Color original, Color background) {
    if (ContrastValidator.meetsWCAGAA(original, background)) {
      return original;
    }
    return ContrastValidator.adjustColorForContrast(original, background);
  }

  /// Create accessible button with proper touch targets
  Widget createAccessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    String? semanticLabel,
    String? tooltip,
    bool enabled = true,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return AccessibleButton(
      onPressed: onPressed,
      semanticLabel: semanticLabel,
      tooltip: tooltip,
      enabled: enabled,
      padding: padding,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      child: child,
    );
  }

  /// Wrap widget with proper semantics
  Widget wrapWithSemantics({
    required Widget child,
    String? label,
    String? hint,
    String? value,
    bool? button,
    bool? header,
    bool? image,
    bool? textField,
    bool? focusable,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      value: value,
      button: button ?? false,
      header: header ?? false,
      image: image ?? false,
      textField: textField ?? false,
      focusable: focusable ?? true,
      onTap: onTap,
      child: child,
    );
  }

  /// Create accessible form field
  Widget createAccessibleFormField({
    required Widget child,
    required String label,
    String? hint,
    String? errorText,
    bool required = false,
  }) {
    final semanticLabel = required ? '$label (必須)' : label;
    final semanticHint = [hint, errorText].where((s) => s != null).join(', ');

    return Semantics(
      textField: true,
      label: semanticLabel,
      hint: semanticHint.isNotEmpty ? semanticHint : null,
      child: child,
    );
  }

  /// Create accessible navigation item
  Widget createAccessibleNavItem({
    required Widget child,
    required String label,
    required bool selected,
    required int index,
    required int total,
    VoidCallback? onTap,
  }) {
    return ScreenReaderHelper.tab(
      child: child,
      label: label,
      selected: selected,
      index: index,
      total: total,
      onTap: onTap,
    );
  }

  /// Create accessible progress indicator
  Widget createAccessibleProgress({
    required Widget child,
    required double value,
    String? label,
  }) {
    return ScreenReaderHelper.progress(
      child: child,
      value: value,
      label: label,
    );
  }

  /// Create accessible image with description
  Widget createAccessibleImage({
    required Widget child,
    required String description,
  }) {
    return ScreenReaderHelper.image(
      child: child,
      description: description,
    );
  }

  /// Create accessible header
  Widget createAccessibleHeader({
    required Widget child,
    required String text,
    int level = 1,
  }) {
    return ScreenReaderHelper.header(
      child: child,
      text: text,
      level: level,
    );
  }

  /// Create accessible list item
  Widget createAccessibleListItem({
    required Widget child,
    required String label,
    required int index,
    required int total,
    String? hint,
    VoidCallback? onTap,
  }) {
    return ScreenReaderHelper.listItem(
      child: child,
      label: label,
      index: index,
      total: total,
      hint: hint,
      onTap: onTap,
    );
  }

  /// Create accessible dialog
  Widget createAccessibleDialog({
    required Widget child,
    required String title,
  }) {
    return ScreenReaderHelper.dialog(
      child: child,
      title: title,
    );
  }

  /// Create accessible alert
  Widget createAccessibleAlert({
    required Widget child,
    required String message,
    bool isError = false,
  }) {
    return ScreenReaderHelper.alert(
      child: child,
      message: message,
      isError: isError,
    );
  }

  /// Create accessible loading indicator
  Widget createAccessibleLoading({
    required Widget child,
    String? message,
  }) {
    return ScreenReaderHelper.loading(
      child: child,
      message: message,
    );
  }
}

/// Provider for accessibility service
final accessibilityServiceProvider = Provider<AccessibilityService>((ref) {
  return AccessibilityService.instance;
});

/// Provider for current accessibility settings
final accessibilitySettingsProvider = Provider.family<AccessibilitySettings, BuildContext>((ref, context) {
  return AccessibilitySettings.fromMediaQuery(context);
});

/// Extension to easily access accessibility service from context
extension AccessibilityExtension on BuildContext {
  AccessibilityService get accessibility => AccessibilityService.instance;
  AccessibilitySettings get accessibilitySettings => AccessibilitySettings.fromMediaQuery(this);
}