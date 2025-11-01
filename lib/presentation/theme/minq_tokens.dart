import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// Legacy static tokens helper kept for backwards compatibility.
class MinqTokens {
  static MinqDesignTokens _tokens = MinqDesignTokens.light();

  /// Update backing tokens from the current [theme].
  static void updateFromTheme(ThemeData theme) {
    final extension = theme.extension<MinqDesignTokens>();
    if (extension != null) {
      _tokens = extension;
    }
  }

  static Color get primary => _tokens.colorScheme.primary;
  static Color get secondary => _tokens.colorScheme.secondary;
  static Color get success => _tokens.colorScheme.secondaryContainer;
  static Color get error => _tokens.colorScheme.error;
  static Color get warning => _tokens.colorScheme.tertiary;
  static Color get info => _tokens.colorScheme.primary;

  static Color get background => _tokens.colorScheme.background;
  static Color get surface => _tokens.colorScheme.surface;
  static Color get surfaceAlt => _tokens.colorScheme.surfaceVariant;

  static Color get textPrimary => _tokens.colorScheme.onSurface;
  static Color get textSecondary => _tokens.colorScheme.onSurfaceVariant;
  static Color get textMuted =>
      Color.lerp(textSecondary, background, 0.5) ?? textSecondary;

  static Color get border => _tokens.colorScheme.outline;
  static Color get divider => _tokens.colorScheme.outlineVariant;

  static double get spacingXs => _tokens.spacing.xs;
  static double get spacingSm => _tokens.spacing.sm;
  static double get spacingMd => _tokens.spacing.md;
  static double get spacingLg => _tokens.spacing.lg;
  static double get spacingXl => _tokens.spacing.xl;

  static double spacing(double multiplier) => spacingSm * multiplier;

  static double get radiusSm => _tokens.radius.sm;
  static double get radiusMd => _tokens.radius.md;
  static double get radiusLg => _tokens.radius.lg;
  static double get radiusXl => _tokens.radius.xl;

  static BorderRadius cornerSmall() =>
      BorderRadius.circular(_tokens.radius.sm);
  static BorderRadius cornerMedium() =>
      BorderRadius.circular(_tokens.radius.md);
  static BorderRadius cornerLarge() =>
      BorderRadius.circular(_tokens.radius.lg);

  static Color get brandPrimary => _tokens.colorScheme.primary;
  static Color get brandSecondary => _tokens.colorScheme.secondary;

  static TextStyle get h1 => _tokens.textTheme.displayLarge!;
  static TextStyle get h2 => _tokens.textTheme.displayMedium!;
  static TextStyle get h3 => _tokens.textTheme.displaySmall!;
  static TextStyle get h4 => _tokens.textTheme.headlineSmall!;
  static TextStyle get h5 => _tokens.textTheme.titleLarge!;
  static TextStyle get body => _tokens.textTheme.bodyMedium!;
  static TextStyle get bodyLarge => _tokens.textTheme.bodyLarge!;
  static TextStyle get bodyMedium => _tokens.textTheme.bodyMedium!;
  static TextStyle get bodySmall => _tokens.textTheme.bodySmall!;
  static TextStyle get button => _tokens.textTheme.labelLarge!;
  static TextStyle get caption => _tokens.textTheme.labelSmall!;

  static TextStyle get titleLarge => _tokens.textTheme.headlineMedium!;
  static TextStyle get titleMedium => _tokens.textTheme.titleMedium!;

  static Color get accentWarning => warning;
  static Color get primaryForeground => _tokens.colorScheme.onPrimary;
}
