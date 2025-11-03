import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/color_tokens.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Extension to provide easy access to theme tokens from BuildContext
extension ThemeExtensions on BuildContext {
  /// Get color tokens (legacy support)
  ColorTokens get colorTokens {
    final theme = MinqTheme.of(this);
    return theme.brightness == Brightness.light 
        ? ColorTokens.light 
        : ColorTokens.dark;
  }
  
  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}