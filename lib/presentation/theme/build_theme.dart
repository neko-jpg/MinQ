import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// A utility function to build a [ThemeData] from a [MinqTheme] instance.
///
/// This function encapsulates the logic of translating design tokens from [MinqTheme]
/// into a fully-fledged [ThemeData] object, ensuring consistency across the app.
ThemeData buildTheme(MinqTheme tokens) {
  final colorScheme = ColorScheme(
    brightness: tokens.brightness,
    primary: tokens.brandPrimary,
    onPrimary: tokens.textPrimary,
    secondary: tokens.accentSuccess,
    onSecondary: tokens.textPrimary,
    error: tokens.accentError,
    onError: tokens.textPrimary,
    background: tokens.background,
    onBackground: tokens.textPrimary,
    surface: tokens.surface,
    onSurface: tokens.textPrimary,
  );

  final textTheme = TextTheme(
    displayMedium: tokens.displayMedium,
    displaySmall: tokens.displaySmall,
    titleLarge: tokens.titleLarge,
    titleMedium: tokens.titleMedium,
    titleSmall: tokens.titleSmall,
    bodyLarge: tokens.bodyLarge,
    bodyMedium: tokens.bodyMedium,
    bodySmall: tokens.bodySmall,
    labelSmall: tokens.labelSmall,
  ).apply(bodyColor: tokens.textPrimary, displayColor: tokens.textPrimary);

  return ThemeData(
    useMaterial3: true,
    brightness: tokens.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: tokens.background,
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerMedium(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.padded,
        minimumSize: WidgetStatePropertyAll<Size>(Size.square(48)),
      ),
    ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
