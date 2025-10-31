import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Legacy MinqTokens class for backward compatibility
/// This provides access to theme tokens in the old format
class MinqTokens {
  static MinqTheme _theme = MinqTheme.light();
  
  /// Update the current theme
  static void updateTheme(MinqTheme theme) {
    _theme = theme;
  }
  
  /// Colors
  static Color get primary => _theme.brandPrimary;
  static Color get secondary => _theme.accentSecondary;
  static Color get success => _theme.accentSuccess;
  static Color get error => _theme.accentError;
  static Color get warning => _theme.accentWarning;
  static Color get info => _theme.accentSecondary;
  
  static Color get background => _theme.background;
  static Color get surface => _theme.surface;
  static Color get surfaceAlt => _theme.surfaceAlt;
  
  static Color get textPrimary => _theme.textPrimary;
  static Color get textSecondary => _theme.textSecondary;
  static Color get textMuted => _theme.textMuted;
  
  static Color get border => _theme.border;
  static Color get divider => _theme.divider;
  
  /// Spacing
  static double get spacingXs => _theme.spacing.xs;
  static double get spacingSm => _theme.spacing.sm;
  static double get spacingMd => _theme.spacing.md;
  static double get spacingLg => _theme.spacing.lg;
  static double get spacingXl => _theme.spacing.xl;
  
  /// Spacing methods
  static double spacing(double multiplier) => _theme.spacing.sm * multiplier;
  
  /// Radius
  static double get radiusSm => _theme.radius.sm;
  static double get radiusMd => _theme.radius.md;
  static double get radiusLg => _theme.radius.lg;
  static double get radiusXl => _theme.radius.xl;
  
  /// Corner methods
  static BorderRadius cornerSmall() => _theme.cornerSmall();
  static BorderRadius cornerMedium() => _theme.cornerMedium();
  static BorderRadius cornerLarge() => _theme.cornerLarge();
  
  /// Brand colors
  static Color get brandPrimary => _theme.brandPrimary;
  static Color get brandSecondary => _theme.accentSecondary;
  
  /// Typography
  static TextStyle get h1 => _theme.typography.h1;
  static TextStyle get h2 => _theme.typography.h2;
  static TextStyle get h3 => _theme.typography.h3;
  static TextStyle get h4 => _theme.typography.h4;
  static TextStyle get h5 => _theme.typography.h5;
  static TextStyle get body => _theme.typography.body;
  static TextStyle get bodyLarge => _theme.typography.bodyLarge;
  static TextStyle get bodyMedium => _theme.typography.bodyMedium;
  static TextStyle get bodySmall => _theme.typography.bodySmall;
  static TextStyle get button => _theme.typography.button;
  static TextStyle get caption => _theme.typography.caption;
  
  /// Additional typography styles
  static TextStyle get titleLarge => _theme.typography.h2;
  static TextStyle get titleMedium => _theme.typography.h4;
  
  /// Additional color properties for backward compatibility
  static Color get accentWarning => _theme.accentWarning;
  static Color get primaryForeground => _theme.textPrimary;
}