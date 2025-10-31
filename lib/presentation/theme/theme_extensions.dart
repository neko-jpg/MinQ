import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Extension to provide convenient access to theme properties
extension BuildContextThemeExtensions on BuildContext {
  /// Get the MinqTheme extension
  MinqTheme get minqTheme => Theme.of(this).extension<MinqTheme>() ?? MinqTheme.light();
  
  /// Get the text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get color tokens with semantic names
  MinqColorTokens get colorTokens => minqTheme.tokens;
}

/// Extension to provide semantic color access on MinqTheme
extension MinqThemeSemanticColors on MinqTheme {
  /// Primary color
  Color get primary => brandPrimary;
  
  /// Success color
  Color get success => accentSuccess;
  
  /// Error color  
  Color get error => accentError;
  
  /// Warning color
  Color get warning => accentWarning;
  
  /// Info color (using secondary)
  Color get info => accentSecondary;
}

/// Extension to provide radius access
extension MinqRadiusExtensions on MinqRadius {
  /// Extra small radius
  double get xs => sm / 2;
}