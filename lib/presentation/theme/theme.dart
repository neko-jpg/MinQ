import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/minq_theme_config.dart';

/// Build light theme using MinQ design tokens
/// 
/// This creates a complete Material 3 theme with WCAG AA compliant colors,
/// consistent spacing, typography, and component styling.
ThemeData buildLightTheme() {
  // Use new design token system
  final themeData = MinqThemeConfig.light();
  
  // Also include legacy MinqTheme for backward compatibility
  final minqTheme = MinqTheme.light();
  
  return themeData.copyWith(extensions: _mergeExtensions(themeData, minqTheme));
}

/// Build dark theme using MinQ design tokens
/// 
/// This creates a complete Material 3 dark theme with WCAG AA compliant colors,
/// consistent spacing, typography, and component styling.
ThemeData buildDarkTheme() {
  // Use new design token system
  final themeData = MinqThemeConfig.dark();
  
  // Also include legacy MinqTheme for backward compatibility
  final minqTheme = MinqTheme.dark();
  
  return themeData.copyWith(extensions: _mergeExtensions(themeData, minqTheme));
}

List<ThemeExtension<dynamic>> _mergeExtensions(
  ThemeData themeData,
  MinqTheme minqTheme,
) {
  final List<ThemeExtension<dynamic>> extensions = <ThemeExtension<dynamic>>[];

  for (final ThemeExtension<dynamic> extension
      in themeData.extensions.values) {
    // Remove any existing MinqTheme to avoid duplicates.
    if (extension is MinqTheme) {
      continue;
    }
    extensions.add(extension);
  }

  extensions.add(minqTheme);
  return extensions;
}
