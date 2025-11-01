import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/color_tokens.dart';

/// Component theme mappings for MinQ Design System v2.0
///
/// Provides consistent theming for all Flutter components using the new
/// Midnight Indigo, Aurora Violet, and Horizon Teal color palette.
/// All themes ensure WCAG AA compliance and proper light/dark mode support.
class MinqComponentThemes {
  const MinqComponentThemes._();

  /// AppBar theme with surface background and proper contrast
  static AppBarTheme appBarTheme(ColorTokens colors) => AppBarTheme(
    backgroundColor: colors.surface,
    foregroundColor: colors.textPrimary,
    elevation: 1,
    shadowColor: colors.border,
    scrolledUnderElevation: 2,
    surfaceTintColor: colors.surface,
    titleTextStyle: TextStyle(
      color: colors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    iconTheme: IconThemeData(color: colors.textPrimary, size: 24),
    actionsIconTheme: IconThemeData(color: colors.textPrimary, size: 24),
  );

  /// Bottom Navigation Bar theme with proper active/inactive states
  static BottomNavigationBarThemeData bottomNavTheme(ColorTokens colors) =>
      BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );

  /// Elevated Button theme with primary brand colors
  static ElevatedButtonThemeData elevatedButtonTheme(ColorTokens colors) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          elevation: 2,
          shadowColor: colors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(88, 44), // Accessibility minimum
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

  /// Outlined Button theme with border and hover states
  static OutlinedButtonThemeData outlinedButtonTheme(ColorTokens colors) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.border, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size(88, 44), // Accessibility minimum
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

  /// Text Button theme for secondary actions
  static TextButtonThemeData textButtonTheme(ColorTokens colors) =>
      TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          minimumSize: const Size(64, 44), // Accessibility minimum
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

  /// Input Decoration theme for text fields
  static InputDecorationTheme inputDecorationTheme(ColorTokens colors) =>
      InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceAlt,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: colors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.focusRing, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.error, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyle(color: colors.textMuted, fontSize: 14),
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
        errorStyle: TextStyle(color: colors.error, fontSize: 12),
      );

  /// Card theme with proper elevation and colors
  static CardThemeData cardTheme(ColorTokens colors) => CardThemeData(
    color: colors.surface,
    shadowColor: colors.textPrimary.withOpacity(0.1),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    margin: const EdgeInsets.all(8),
  );

  /// Floating Action Button theme
  static FloatingActionButtonThemeData fabTheme(ColorTokens colors) =>
      FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      );

  /// Switch theme with brand colors
  static SwitchThemeData switchTheme(ColorTokens colors) => SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colors.onPrimary;
      }
      return colors.textMuted;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colors.primary;
      }
      return colors.surfaceVariant;
    }),
  );

  /// Checkbox theme with brand colors
  static CheckboxThemeData checkboxTheme(ColorTokens colors) =>
      CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.onPrimary),
        side: BorderSide(color: colors.border, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      );

  /// Radio theme with brand colors
  static RadioThemeData radioTheme(ColorTokens colors) => RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return colors.primary;
      }
      return colors.textMuted;
    }),
  );

  /// Slider theme with brand colors
  static SliderThemeData sliderTheme(ColorTokens colors) => SliderThemeData(
    activeTrackColor: colors.primary,
    inactiveTrackColor: colors.surfaceVariant,
    thumbColor: colors.primary,
    overlayColor: colors.primary.withOpacity(0.12),
    valueIndicatorColor: colors.primary,
    valueIndicatorTextStyle: TextStyle(
      color: colors.onPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Progress Indicator theme
  static ProgressIndicatorThemeData progressIndicatorTheme(
    ColorTokens colors,
  ) => ProgressIndicatorThemeData(
    color: colors.primary,
    linearTrackColor: colors.surfaceVariant,
    circularTrackColor: colors.surfaceVariant,
  );

  /// Snackbar theme with semantic colors
  static SnackBarThemeData snackBarTheme(ColorTokens colors) =>
      SnackBarThemeData(
        backgroundColor: colors.surface,
        contentTextStyle: TextStyle(color: colors.textPrimary, fontSize: 14),
        actionTextColor: colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        elevation: 6,
      );

  /// Dialog theme
  static DialogThemeData dialogTheme(ColorTokens colors) => DialogThemeData(
    backgroundColor: colors.surface,
    surfaceTintColor: colors.surface,
    elevation: 24,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    titleTextStyle: TextStyle(
      color: colors.textPrimary,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: TextStyle(
      color: colors.textSecondary,
      fontSize: 14,
      height: 1.5,
    ),
  );

  /// Bottom Sheet theme
  static BottomSheetThemeData bottomSheetTheme(ColorTokens colors) =>
      BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        clipBehavior: Clip.antiAlias,
      );

  /// Tab Bar theme
  static TabBarThemeData tabBarTheme(ColorTokens colors) => TabBarThemeData(
    labelColor: colors.primary,
    unselectedLabelColor: colors.textSecondary,
    indicator: UnderlineTabIndicator(
      borderSide: BorderSide(color: colors.primary, width: 2),
    ),
    labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    unselectedLabelStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  );

  /// List Tile theme
  static ListTileThemeData listTileTheme(ColorTokens colors) =>
      ListTileThemeData(
        tileColor: colors.surface,
        selectedTileColor: colors.primary.withOpacity(0.08),
        iconColor: colors.textSecondary,
        selectedColor: colors.primary,
        textColor: colors.textPrimary,
        titleTextStyle: TextStyle(
          color: colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: TextStyle(color: colors.textSecondary, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      );

  /// Chip theme
  static ChipThemeData chipTheme(ColorTokens colors) => ChipThemeData(
    backgroundColor: colors.surfaceAlt,
    selectedColor: colors.primary.withOpacity(0.12),
    disabledColor: colors.surfaceVariant,
    labelStyle: TextStyle(
      color: colors.textPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    secondaryLabelStyle: TextStyle(color: colors.textSecondary, fontSize: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  /// Divider theme
  static DividerThemeData dividerTheme(ColorTokens colors) =>
      DividerThemeData(color: colors.divider, thickness: 1, space: 1);

  /// Icon theme
  static IconThemeData iconTheme(ColorTokens colors) =>
      IconThemeData(color: colors.textSecondary, size: 24);

  /// Primary Icon theme
  static IconThemeData primaryIconTheme(ColorTokens colors) =>
      IconThemeData(color: colors.onPrimary, size: 24);
}

/// Screen-specific color mappings for consistent UI patterns
class MinqScreenThemes {
  const MinqScreenThemes._();

  /// Quest screen color mapping
  static Map<String, Color> questColors(ColorTokens colors) => {
    'active': colors.primary,
    'completed': colors.success,
    'paused': colors.textMuted,
    'overdue': colors.error,
    'background': colors.surface,
    'border': colors.border,
  };

  /// Statistics screen color mapping
  static Map<String, Color> statsColors(ColorTokens colors) => {
    'primary_series': colors.primary,
    'secondary_series': colors.secondary,
    'tertiary_series': colors.tertiary,
    'background': colors.surface,
    'grid_lines': colors.divider,
  };

  /// Achievement screen color mapping
  static Map<String, Color> achievementColors(ColorTokens colors) => {
    'gold': const Color(0xFFF59E0B),
    'silver': const Color(0xFF9CA3AF),
    'bronze': const Color(0xFFB45309),
    'locked': colors.textMuted,
    'background': colors.surface,
  };

  /// AI Chat screen color mapping
  static Map<String, Color> aiChatColors(ColorTokens colors) => {
    'bot_bubble': colors.info,
    'user_bubble': colors.primary,
    'bot_text': colors.onInfo,
    'user_text': colors.onPrimary,
    'background': colors.background,
  };

  /// Settings screen color mapping
  static Map<String, Color> settingsColors(ColorTokens colors) => {
    'danger_action': colors.error,
    'warning_action': colors.warning,
    'success_action': colors.success,
    'section_header': colors.textSecondary,
    'background': colors.background,
  };

  /// Premium/Subscription screen color mapping
  static Map<String, Color> premiumColors(ColorTokens colors) => {
    'hero_gradient_start': colors.primary,
    'hero_gradient_end': colors.secondary,
    'feature_highlight': colors.tertiary,
    'price_text': colors.textPrimary,
    'background': colors.background,
  };

  /// Offline mode color mapping
  static Map<String, Color> offlineColors(ColorTokens colors) => {
    'banner_background': colors.warning,
    'banner_text': colors.onWarning,
    'indicator_border': colors.warning,
    'readonly_overlay': colors.overlay,
    'sync_progress': colors.info,
  };
}
