import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// MinQ Theme Configuration
/// Provides Material 3 theme data with MinQ design tokens
class MinqThemeConfig {
  /// Light theme configuration
  static ThemeData light() {
    final minqTheme = MinqTheme.light();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: minqTheme.brandPrimary,
        secondary: minqTheme.accentSecondary,
        surface: minqTheme.surface,
        error: minqTheme.accentError,
        onPrimary: minqTheme.textPrimary,
        onSecondary: minqTheme.textSecondary,
        onSurface: minqTheme.textPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: minqTheme.typography.h1,
        displayMedium: minqTheme.typography.h2,
        displaySmall: minqTheme.typography.h3,
        headlineLarge: minqTheme.typography.h2,
        headlineMedium: minqTheme.typography.h3,
        headlineSmall: minqTheme.typography.h4,
        titleLarge: minqTheme.typography.h4,
        titleMedium: minqTheme.typography.h5,
        titleSmall: minqTheme.typography.h5,
        bodyLarge: minqTheme.typography.bodyLarge,
        bodyMedium: minqTheme.typography.body,
        bodySmall: minqTheme.typography.bodySmall,
        labelLarge: minqTheme.typography.button,
        labelMedium: minqTheme.typography.caption,
        labelSmall: minqTheme.typography.caption,
      ),
      extensions: [minqTheme],
    );
  }

  /// Dark theme configuration
  static ThemeData dark() {
    final minqTheme = MinqTheme.dark();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: minqTheme.brandPrimary,
        secondary: minqTheme.accentSecondary,
        surface: minqTheme.surface,
        error: minqTheme.accentError,
        onPrimary: minqTheme.textPrimary,
        onSecondary: minqTheme.textSecondary,
        onSurface: minqTheme.textPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: minqTheme.typography.h1,
        displayMedium: minqTheme.typography.h2,
        displaySmall: minqTheme.typography.h3,
        headlineLarge: minqTheme.typography.h2,
        headlineMedium: minqTheme.typography.h3,
        headlineSmall: minqTheme.typography.h4,
        titleLarge: minqTheme.typography.h4,
        titleMedium: minqTheme.typography.h5,
        titleSmall: minqTheme.typography.h5,
        bodyLarge: minqTheme.typography.bodyLarge,
        bodyMedium: minqTheme.typography.body,
        bodySmall: minqTheme.typography.bodySmall,
        labelLarge: minqTheme.typography.button,
        labelMedium: minqTheme.typography.caption,
        labelSmall: minqTheme.typography.caption,
      ),
      extensions: [minqTheme],
    );
  }
}
