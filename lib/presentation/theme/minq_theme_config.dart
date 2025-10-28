import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

/// MinQ Theme Configuration
///
/// This class creates complete Flutter ThemeData objects using the static MinQ design tokens.
class MinqThemeConfig {
  const MinqThemeConfig._();

  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: MinqTokens.brandPrimary,
    onPrimary: Colors.white,
    secondary: MinqTokens.brandSecondary,
    onSecondary: const Color(0xFF0F172A),
    error: const Color(0xFFEF4444),
    onError: Colors.white,
    surface: MinqTokens.surface,
    onSurface: MinqTokens.textPrimary,
    // Sensible defaults for other colors
    primaryContainer: const Color(0xFFE6E7FF),
    onPrimaryContainer: const Color(0xFF312E81),
    secondaryContainer: const Color(0xFFD1FAE5),
    onSecondaryContainer: const Color(0xFF065F46),
    surfaceContainerHighest: const Color(0xFFE7ECFB),
    onSurfaceVariant: MinqTokens.textSecondary,
    outline: const Color(0xFFD0D7E5),
  );

  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: const Color(0xFFA5B4FC),
    onPrimary: Colors.white,
    secondary: const Color(0xFF2DD4BF),
    onSecondary: Colors.white,
    error: const Color(0xFFF87171),
    onError: const Color(0xFF0B1120),
    surface: const Color(0xFF111827),
    onSurface: const Color(0xFFE2E8F0),
    // Sensible defaults for other colors
    primaryContainer: const Color(0xFF312E81),
    onPrimaryContainer: const Color(0xFFE0E7FF),
    secondaryContainer: const Color(0xFF0F766E),
    onSecondaryContainer: const Color(0xFFD1FAE5),
    surfaceContainerHighest: const Color(0xFF1F2937),
    onSurfaceVariant: const Color(0xFF94A3B8),
    outline: const Color(0xFF334155),
  );

  static final TextTheme _textTheme = TextTheme(
    displayLarge: MinqTokens.titleLarge.copyWith(fontSize: 57),
    displayMedium: MinqTokens.titleLarge.copyWith(fontSize: 45),
    displaySmall: MinqTokens.titleLarge.copyWith(fontSize: 36),
    headlineLarge: MinqTokens.titleLarge.copyWith(fontSize: 32),
    headlineMedium: MinqTokens.titleLarge.copyWith(fontSize: 28),
    headlineSmall: MinqTokens.titleLarge.copyWith(fontSize: 24),
    titleLarge: MinqTokens.titleLarge,
    titleMedium: MinqTokens.titleMedium,
    titleSmall: MinqTokens.titleMedium.copyWith(fontSize: 14),
    bodyLarge: MinqTokens.bodyLarge,
    bodyMedium: MinqTokens.bodyMedium,
    bodySmall: MinqTokens.bodySmall,
    labelLarge: MinqTokens.bodyMedium.copyWith(fontWeight: FontWeight.w600),
    labelMedium: MinqTokens.bodySmall.copyWith(fontWeight: FontWeight.w600),
    labelSmall: MinqTokens.bodySmall.copyWith(fontSize: 11),
  ).apply(
    bodyColor: MinqTokens.textPrimary,
    displayColor: MinqTokens.textPrimary,
  );

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleTextStyle: _textTheme.titleLarge,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: MinqTokens.cornerMedium()),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: MinqTokens.cornerMedium(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MinqTokens.spacing(4),
            vertical: MinqTokens.spacing(3),
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: MinqTokens.cornerMedium(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MinqTokens.spacing(4),
            vertical: MinqTokens.spacing(3),
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: MinqTokens.cornerMedium(),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: MinqTokens.spacing(4),
            vertical: MinqTokens.spacing(3),
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: MinqTokens.cornerSmall(),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: MinqTokens.cornerSmall(),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: MinqTokens.cornerSmall(),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        labelStyle: _textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        hintStyle: _textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: MinqTokens.cornerLarge()),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: colorScheme.primaryContainer,
        labelStyle: _textTheme.labelMedium,
        padding: EdgeInsets.symmetric(horizontal: MinqTokens.spacing(3)),
        shape: RoundedRectangleBorder(borderRadius: MinqTokens.cornerMedium()),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: MinqTokens.cornerLarge()),
        titleTextStyle: _textTheme.headlineSmall,
        contentTextStyle: _textTheme.bodyMedium,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: _textTheme.titleSmall,
        unselectedLabelStyle: _textTheme.titleSmall,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  /// Create light theme with MinQ design tokens
  static ThemeData light() {
    return _buildTheme(_lightColorScheme);
  }

  /// Create dark theme with MinQ design tokens
  static ThemeData dark() {
    return _buildTheme(_darkColorScheme);
  }
}
