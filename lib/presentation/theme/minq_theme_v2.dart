import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:minq/presentation/theme/color_tokens.dart';
import 'package:minq/presentation/theme/component_themes.dart';

/// MinQ Theme System v2.0
///
/// Complete theme implementation with new brand colors:
/// - Midnight Indigo (#4F46E5) as primary
/// - Aurora Violet (#8B5CF6) as secondary
/// - Horizon Teal (#14B8A6) as tertiary
///
/// Features:
/// - WCAG AA compliant colors
/// - Comprehensive component theming
/// - Light and dark mode support
/// - Accessibility optimizations
class MinqThemeV2 {
  const MinqThemeV2._();

  /// Light theme with new brand colors
  static ThemeData light() {
    const colors = ColorTokens.light;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primary.withOpacity(0.12),
        onPrimaryContainer: colors.primary,

        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        secondaryContainer: colors.secondary.withOpacity(0.12),
        onSecondaryContainer: colors.secondary,

        tertiary: colors.tertiary,
        onTertiary: colors.onTertiary,
        tertiaryContainer: colors.tertiary.withOpacity(0.12),
        onTertiaryContainer: colors.tertiary,

        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.error.withOpacity(0.12),
        onErrorContainer: colors.error,

        surface: colors.surface,
        onSurface: colors.onSurface,
        surfaceContainerHighest: colors.surfaceVariant,
        onSurfaceVariant: colors.textSecondary,

        outline: colors.border,
        outlineVariant: colors.divider,

        shadow: Colors.black,
        scrim: Colors.black,

        inverseSurface: colors.textPrimary,
        onInverseSurface: colors.surface,
        inversePrimary: colors.primary.withOpacity(0.8),
      ),

      // Typography
      textTheme: _buildTextTheme(colors),

      // Component Themes
      appBarTheme: MinqComponentThemes.appBarTheme(colors),
      bottomNavigationBarTheme: MinqComponentThemes.bottomNavTheme(colors),
      elevatedButtonTheme: MinqComponentThemes.elevatedButtonTheme(colors),
      outlinedButtonTheme: MinqComponentThemes.outlinedButtonTheme(colors),
      textButtonTheme: MinqComponentThemes.textButtonTheme(colors),
      inputDecorationTheme: MinqComponentThemes.inputDecorationTheme(colors),
      cardTheme: MinqComponentThemes.cardTheme(colors),
      floatingActionButtonTheme: MinqComponentThemes.fabTheme(colors),
      switchTheme: MinqComponentThemes.switchTheme(colors),
      checkboxTheme: MinqComponentThemes.checkboxTheme(colors),
      radioTheme: MinqComponentThemes.radioTheme(colors),
      sliderTheme: MinqComponentThemes.sliderTheme(colors),
      progressIndicatorTheme: MinqComponentThemes.progressIndicatorTheme(
        colors,
      ),
      snackBarTheme: MinqComponentThemes.snackBarTheme(colors),
      dialogTheme: MinqComponentThemes.dialogTheme(colors),
      bottomSheetTheme: MinqComponentThemes.bottomSheetTheme(colors),
      tabBarTheme: MinqComponentThemes.tabBarTheme(colors),
      listTileTheme: MinqComponentThemes.listTileTheme(colors),
      chipTheme: MinqComponentThemes.chipTheme(colors),
      dividerTheme: MinqComponentThemes.dividerTheme(colors),
      iconTheme: MinqComponentThemes.iconTheme(colors),
      primaryIconTheme: MinqComponentThemes.primaryIconTheme(colors),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Material Tap Target Size
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash Factory
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Dark theme with adjusted brand colors
  static ThemeData dark() {
    const colors = ColorTokens.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: ColorScheme.dark(
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        primaryContainer: colors.primary.withOpacity(0.12),
        onPrimaryContainer: colors.primary,

        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        secondaryContainer: colors.secondary.withOpacity(0.12),
        onSecondaryContainer: colors.secondary,

        tertiary: colors.tertiary,
        onTertiary: colors.onTertiary,
        tertiaryContainer: colors.tertiary.withOpacity(0.12),
        onTertiaryContainer: colors.tertiary,

        error: colors.error,
        onError: colors.onError,
        errorContainer: colors.error.withOpacity(0.12),
        onErrorContainer: colors.error,

        surface: colors.surface,
        onSurface: colors.onSurface,
        surfaceContainerHighest: colors.surfaceVariant,
        onSurfaceVariant: colors.textSecondary,

        outline: colors.border,
        outlineVariant: colors.divider,

        shadow: Colors.black,
        scrim: Colors.black,

        inverseSurface: colors.textPrimary,
        onInverseSurface: colors.surface,
        inversePrimary: colors.primary.withOpacity(0.8),
      ),

      // Typography
      textTheme: _buildTextTheme(colors),

      // Component Themes
      appBarTheme: MinqComponentThemes.appBarTheme(colors),
      bottomNavigationBarTheme: MinqComponentThemes.bottomNavTheme(colors),
      elevatedButtonTheme: MinqComponentThemes.elevatedButtonTheme(colors),
      outlinedButtonTheme: MinqComponentThemes.outlinedButtonTheme(colors),
      textButtonTheme: MinqComponentThemes.textButtonTheme(colors),
      inputDecorationTheme: MinqComponentThemes.inputDecorationTheme(colors),
      cardTheme: MinqComponentThemes.cardTheme(colors),
      floatingActionButtonTheme: MinqComponentThemes.fabTheme(colors),
      switchTheme: MinqComponentThemes.switchTheme(colors),
      checkboxTheme: MinqComponentThemes.checkboxTheme(colors),
      radioTheme: MinqComponentThemes.radioTheme(colors),
      sliderTheme: MinqComponentThemes.sliderTheme(colors),
      progressIndicatorTheme: MinqComponentThemes.progressIndicatorTheme(
        colors,
      ),
      snackBarTheme: MinqComponentThemes.snackBarTheme(colors),
      dialogTheme: MinqComponentThemes.dialogTheme(colors),
      bottomSheetTheme: MinqComponentThemes.bottomSheetTheme(colors),
      tabBarTheme: MinqComponentThemes.tabBarTheme(colors),
      listTileTheme: MinqComponentThemes.listTileTheme(colors),
      chipTheme: MinqComponentThemes.chipTheme(colors),
      dividerTheme: MinqComponentThemes.dividerTheme(colors),
      iconTheme: MinqComponentThemes.iconTheme(colors),
      primaryIconTheme: MinqComponentThemes.primaryIconTheme(colors),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Material Tap Target Size
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash Factory
      splashFactory: InkRipple.splashFactory,
    );
  }

  /// Build text theme with Plus Jakarta Sans font
  static TextTheme _buildTextTheme(ColorTokens colors) {
    return TextTheme(
      // Display styles
      displayLarge: GoogleFonts.plusJakartaSans(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: colors.textPrimary,
      ),
      displayMedium: GoogleFonts.plusJakartaSans(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.16,
        color: colors.textPrimary,
      ),
      displaySmall: GoogleFonts.plusJakartaSans(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.22,
        color: colors.textPrimary,
      ),

      // Headline styles
      headlineLarge: GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.25,
        color: colors.textPrimary,
      ),
      headlineMedium: GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.29,
        color: colors.textPrimary,
      ),
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.33,
        color: colors.textPrimary,
      ),

      // Title styles
      titleLarge: GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.27,
        color: colors.textPrimary,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.50,
        color: colors.textPrimary,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: colors.textPrimary,
      ),

      // Body styles
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: colors.textPrimary,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: colors.textPrimary,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: colors.textSecondary,
      ),

      // Label styles
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
        color: colors.textPrimary,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.33,
        color: colors.textSecondary,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.45,
        color: colors.textSecondary,
      ),
    );
  }
}

/// Extension to access screen-specific color mappings
extension MinqThemeV2Extensions on ThemeData {
  /// Get quest screen colors
  Map<String, Color> get questColors {
    final colors =
        brightness == Brightness.light ? ColorTokens.light : ColorTokens.dark;
    return MinqScreenThemes.questColors(colors);
  }

  /// Get statistics screen colors
  Map<String, Color> get statsColors {
    final colors =
        brightness == Brightness.light ? ColorTokens.light : ColorTokens.dark;
    return MinqScreenThemes.statsColors(colors);
  }

  /// Get achievement screen colors
  Map<String, Color> get achievementColors {
    final colors =
        brightness == Brightness.light ? ColorTokens.light : ColorTokens.dark;
    return MinqScreenThemes.achievementColors(colors);
  }

  /// Get AI chat screen colors
  Map<String, Color> get aiChatColors {
    final colors =
        brightness == Brightness.light ? ColorTokens.light : ColorTokens.dark;
    return MinqScreenThemes.aiChatColors(colors);
  }

  /// Get settings screen colors
  Map<String, Color> get settingsColors {
    final colors =
        brightness == Brightness.light ? ColorTokens.light : ColorTokens.dark;
    return MinqScreenThemes.settingsColors(colors);
  }

  /// Get premium screen colors
  Map<String, Color> get premiumColors {
    final colors =
        brightness == Brightness.light ? ColorTokens.light : ColorTokens.dark;
    return MinqScreenThemes.premiumColors(colors);
  }

  /// Get offline mode colors
  Map<String, Color> get offlineColors {
    final colors =
        brightness == Brightness.light ? ColorTokens.light : ColorTokens.dark;
    return MinqScreenThemes.offlineColors(colors);
  }
}
