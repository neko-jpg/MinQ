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
  
  return themeData.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ...themeData.extensions.values,
      minqTheme,
    ],
  );
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
  
  return themeData.copyWith(
    extensions: <ThemeExtension<dynamic>>[
      ...themeData.extensions.values,
      minqTheme,
    ],
  );
}
