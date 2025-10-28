import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/design_tokens.dart';

/// MinQ Theme Configuration
///
/// This class creates complete Flutter ThemeData objects using MinQ design tokens.
/// It ensures consistency across the app and provides proper light/dark mode support
/// with WCAG AA compliant colors.
class MinqThemeConfig {
  const MinqThemeConfig._();

  /// Create light theme with MinQ design tokens
  static ThemeData light() {
    final tokens = MinqDesignTokens.light();
    final colorScheme = _createColorScheme(tokens.colors, Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      extensions: [tokens],

      // Typography
      textTheme: _createTextTheme(tokens.typography, tokens.colors.onSurface),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.colors.surface,
        foregroundColor: tokens.colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: tokens.typography.titleLarge.copyWith(
          color: tokens.colors.onSurface,
        ),
        iconTheme: IconThemeData(color: tokens.colors.onSurface),
      ),

      // Card
      cardTheme: CardTheme(
        color: tokens.colors.surface,
        shadowColor: tokens.colors.shadow,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.cardRadius,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.colors.primary,
          foregroundColor: tokens.colors.onPrimary,
          elevation: 2,
          shadowColor: tokens.colors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: tokens.radius.buttonRadius,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.md,
          ),
          minimumSize: const Size(
            MinqSpacingTokens.minTouchTarget,
            MinqSpacingTokens.minTouchTarget,
          ),
          textStyle: tokens.typography.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.colors.primary,
          side: BorderSide(color: tokens.colors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: tokens.radius.buttonRadius,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.md,
          ),
          minimumSize: const Size(
            MinqSpacingTokens.minTouchTarget,
            MinqSpacingTokens.minTouchTarget,
          ),
          textStyle: tokens.typography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: tokens.radius.buttonRadius,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.md,
          ),
          minimumSize: const Size(
            MinqSpacingTokens.minTouchTarget,
            MinqSpacingTokens.minTouchTarget,
          ),
          textStyle: tokens.typography.labelLarge,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.colors.primary,
        foregroundColor: tokens.colors.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.lgRadius,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
        labelStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurfaceVariant,
        ),
        hintStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurfaceVariant,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: tokens.colors.surfaceVariant,
        selectedColor: tokens.colors.primaryContainer,
        labelStyle: tokens.typography.labelMedium,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.fullRadius,
        ),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: tokens.colors.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.dialogRadius,
        ),
        titleTextStyle: tokens.typography.headlineSmall.copyWith(
          color: tokens.colors.onSurface,
        ),
        contentTextStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurface,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.colors.surface,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MinqRadiusTokens.lg),
          ),
        ),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.xs,
        ),
        minVerticalPadding: tokens.spacing.xs,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.smRadius,
        ),
        titleTextStyle: tokens.typography.bodyLarge.copyWith(
          color: tokens.colors.onSurface,
        ),
        subtitleTextStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurfaceVariant,
        ),
      ),

      // Icon
      iconTheme: IconThemeData(
        color: tokens.colors.onSurface,
        size: 24,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: tokens.colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.onPrimary;
          }
          return tokens.colors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.primary;
          }
          return tokens.colors.surfaceVariant;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(tokens.colors.onPrimary),
        side: BorderSide(color: tokens.colors.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.xsRadius,
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.primary;
          }
          return tokens.colors.outline;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: tokens.colors.primary,
        inactiveTrackColor: tokens.colors.surfaceVariant,
        thumbColor: tokens.colors.primary,
        overlayColor: tokens.colors.primary.withAlpha(32),
        valueIndicatorColor: tokens.colors.primary,
        valueIndicatorTextStyle: tokens.typography.labelMedium.copyWith(
          color: tokens.colors.onPrimary,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.colors.primary,
        linearTrackColor: tokens.colors.surfaceVariant,
        circularTrackColor: tokens.colors.surfaceVariant,
      ),

      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.colors.inverseSurface,
        contentTextStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onInverseSurface,
        ),
        actionTextColor: tokens.colors.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.smRadius,
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.colors.surface,
        indicatorColor: tokens.colors.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          tokens.typography.labelMedium.copyWith(
            color: tokens.colors.onSurface,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.colors.onSecondaryContainer);
          }
          return IconThemeData(color: tokens.colors.onSurfaceVariant);
        }),
      ),

      // Tab Bar
      tabBarTheme: TabBarTheme(
        labelColor: tokens.colors.primary,
        unselectedLabelColor: tokens.colors.onSurfaceVariant,
        labelStyle: tokens.typography.titleSmall,
        unselectedLabelStyle: tokens.typography.titleSmall,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: tokens.colors.primary, width: 2),
        ),
      ),
    );
  }

  /// Create dark theme with MinQ design tokens
  static ThemeData dark() {
    final tokens = MinqDesignTokens.dark();
    final colorScheme = _createColorScheme(tokens.colors, Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      extensions: [tokens],

      // Typography
      textTheme: _createTextTheme(tokens.typography, tokens.colors.onSurface),

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.colors.surface,
        foregroundColor: tokens.colors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: tokens.typography.titleLarge.copyWith(
          color: tokens.colors.onSurface,
        ),
        iconTheme: IconThemeData(color: tokens.colors.onSurface),
      ),

      // Card
      cardTheme: CardTheme(
        color: tokens.colors.surface,
        shadowColor: tokens.colors.shadow,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.cardRadius,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.colors.primary,
          foregroundColor: tokens.colors.onPrimary,
          elevation: 2,
          shadowColor: tokens.colors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: tokens.radius.buttonRadius,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.md,
          ),
          minimumSize: const Size(
            MinqSpacingTokens.minTouchTarget,
            MinqSpacingTokens.minTouchTarget,
          ),
          textStyle: tokens.typography.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.colors.primary,
          side: BorderSide(color: tokens.colors.outline),
          shape: RoundedRectangleBorder(
            borderRadius: tokens.radius.buttonRadius,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.md,
          ),
          minimumSize: const Size(
            MinqSpacingTokens.minTouchTarget,
            MinqSpacingTokens.minTouchTarget,
          ),
          textStyle: tokens.typography.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.colors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: tokens.radius.buttonRadius,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: tokens.spacing.lg,
            vertical: tokens.spacing.md,
          ),
          minimumSize: const Size(
            MinqSpacingTokens.minTouchTarget,
            MinqSpacingTokens.minTouchTarget,
          ),
          textStyle: tokens.typography.labelLarge,
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tokens.colors.primary,
        foregroundColor: tokens.colors.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.lgRadius,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: tokens.radius.smRadius,
          borderSide: BorderSide(color: tokens.colors.error, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.md,
        ),
        labelStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurfaceVariant,
        ),
        hintStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurfaceVariant,
        ),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: tokens.colors.surfaceVariant,
        selectedColor: tokens.colors.primaryContainer,
        labelStyle: tokens.typography.labelMedium,
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.md,
          vertical: tokens.spacing.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.fullRadius,
        ),
      ),

      // Dialog
      dialogTheme: DialogTheme(
        backgroundColor: tokens.colors.surface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.dialogRadius,
        ),
        titleTextStyle: tokens.typography.headlineSmall.copyWith(
          color: tokens.colors.onSurface,
        ),
        contentTextStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurface,
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.colors.surface,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(MinqRadiusTokens.lg),
          ),
        ),
      ),

      // List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.xs,
        ),
        minVerticalPadding: tokens.spacing.xs,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.smRadius,
        ),
        titleTextStyle: tokens.typography.bodyLarge.copyWith(
          color: tokens.colors.onSurface,
        ),
        subtitleTextStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onSurfaceVariant,
        ),
      ),

      // Icon
      iconTheme: IconThemeData(
        color: tokens.colors.onSurface,
        size: 24,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: tokens.colors.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Switch
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.onPrimary;
          }
          return tokens.colors.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.primary;
          }
          return tokens.colors.surfaceVariant;
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(tokens.colors.onPrimary),
        side: BorderSide(color: tokens.colors.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.xsRadius,
        ),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return tokens.colors.primary;
          }
          return tokens.colors.outline;
        }),
      ),

      // Slider
      sliderTheme: SliderThemeData(
        activeTrackColor: tokens.colors.primary,
        inactiveTrackColor: tokens.colors.surfaceVariant,
        thumbColor: tokens.colors.primary,
        overlayColor: tokens.colors.primary.withAlpha(32),
        valueIndicatorColor: tokens.colors.primary,
        valueIndicatorTextStyle: tokens.typography.labelMedium.copyWith(
          color: tokens.colors.onPrimary,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: tokens.colors.primary,
        linearTrackColor: tokens.colors.surfaceVariant,
        circularTrackColor: tokens.colors.surfaceVariant,
      ),

      // Snack Bar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.colors.inverseSurface,
        contentTextStyle: tokens.typography.bodyMedium.copyWith(
          color: tokens.colors.onInverseSurface,
        ),
        actionTextColor: tokens.colors.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: tokens.radius.smRadius,
        ),
      ),

      // Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.colors.surface,
        indicatorColor: tokens.colors.secondaryContainer,
        labelTextStyle: WidgetStateProperty.all(
          tokens.typography.labelMedium.copyWith(
            color: tokens.colors.onSurface,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.colors.onSecondaryContainer);
          }
          return IconThemeData(color: tokens.colors.onSurfaceVariant);
        }),
      ),

      // Tab Bar
      tabBarTheme: TabBarTheme(
        labelColor: tokens.colors.primary,
        unselectedLabelColor: tokens.colors.onSurfaceVariant,
        labelStyle: tokens.typography.titleSmall,
        unselectedLabelStyle: tokens.typography.titleSmall,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: tokens.colors.primary, width: 2),
        ),
      ),
    );
  }

  /// Create ColorScheme from MinQ color tokens
  static ColorScheme _createColorScheme(MinqColorTokens colors, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primaryContainer,
      onPrimaryContainer: colors.onPrimaryContainer,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      secondaryContainer: colors.secondaryContainer,
      onSecondaryContainer: colors.onSecondaryContainer,
      tertiary: colors.tertiary,
      onTertiary: colors.onTertiary,
      tertiaryContainer: colors.tertiaryContainer,
      onTertiaryContainer: colors.onTertiaryContainer,
      error: colors.error,
      onError: colors.onError,
      errorContainer: colors.errorContainer,
      onErrorContainer: colors.onErrorContainer,
      surface: colors.surface,
      onSurface: colors.onSurface,
      surfaceVariant: colors.surfaceVariant,
      onSurfaceVariant: colors.onSurfaceVariant,
      outline: colors.outline,
      outlineVariant: colors.outlineVariant,
      shadow: colors.shadow,
      scrim: colors.scrim,
      inverseSurface: colors.inverseSurface,
      onInverseSurface: colors.onInverseSurface,
      inversePrimary: colors.inversePrimary,
      surfaceTint: colors.primary,
    );
  }

  /// Create TextTheme from MinQ typography tokens
  static TextTheme _createTextTheme(MinqTypographyTokens typography, Color defaultColor) {
    return TextTheme(
      displayLarge: typography.displayLarge.copyWith(color: defaultColor),
      displayMedium: typography.displayMedium.copyWith(color: defaultColor),
      displaySmall: typography.displaySmall.copyWith(color: defaultColor),
      headlineLarge: typography.headlineLarge.copyWith(color: defaultColor),
      headlineMedium: typography.headlineMedium.copyWith(color: defaultColor),
      headlineSmall: typography.headlineSmall.copyWith(color: defaultColor),
      titleLarge: typography.titleLarge.copyWith(color: defaultColor),
      titleMedium: typography.titleMedium.copyWith(color: defaultColor),
      titleSmall: typography.titleSmall.copyWith(color: defaultColor),
      bodyLarge: typography.bodyLarge.copyWith(color: defaultColor),
      bodyMedium: typography.bodyMedium.copyWith(color: defaultColor),
      bodySmall: typography.bodySmall.copyWith(color: defaultColor),
      labelLarge: typography.labelLarge.copyWith(color: defaultColor),
      labelMedium: typography.labelMedium.copyWith(color: defaultColor),
      labelSmall: typography.labelSmall.copyWith(color: defaultColor),
    );
  }
}