import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// A utility function to build a [ThemeData] from a [MinqTheme] instance.
///
/// This function encapsulates the logic of translating design tokens from [MinqTheme]
/// into a fully-fledged [ThemeData] object, ensuring consistency across the app.
ThemeData buildTheme(MinqTheme tokens) {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: tokens.brandPrimary,
    brightness: tokens.brightness,
  );

  final colorScheme = baseScheme.copyWith(
    primary: tokens.brandPrimary,
    onPrimary: tokens.textPrimary,
    secondary: tokens.accentSuccess,
    onSecondary: tokens.textPrimary,
    error: tokens.accentError,
    onError: tokens.textPrimary,
    surface: tokens.surface,
    onSurface: tokens.textPrimary,
  );

  final buttonShape = WidgetStatePropertyAll<OutlinedBorder>(
    RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
  );
  final buttonPadding = WidgetStatePropertyAll<EdgeInsetsGeometry>(
    EdgeInsets.symmetric(horizontal: tokens.spacing(4)),
  );
  const minButtonSize = WidgetStatePropertyAll<Size>(Size(80, 48));

  final typeScale = tokens.typeScale;
  final textTheme = TextTheme(
    displayMedium: typeScale.h1,
    displaySmall: typeScale.h2,
    headlineMedium: typeScale.h3,
    headlineSmall: typeScale.h4,
    titleLarge: typeScale.h3,
    titleMedium: typeScale.h4,
    titleSmall: typeScale.h5,
    bodyLarge: typeScale.bodyLarge,
    bodyMedium: typeScale.bodyMedium,
    bodySmall: typeScale.bodySmall,
    labelLarge: typeScale.button,
    labelSmall: typeScale.caption,
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
    cardTheme: CardThemeData(
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: tokens.cornerMedium(),
        side: BorderSide(color: tokens.border),
      ),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        minimumSize: minButtonSize,
        padding: buttonPadding,
        shape: buttonShape,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        minimumSize: minButtonSize,
        padding: buttonPadding,
        shape: buttonShape,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        minimumSize: minButtonSize,
        padding: buttonPadding,
        shape: buttonShape,
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    ),
    iconButtonTheme: const IconButtonThemeData(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.padded,
        minimumSize: WidgetStatePropertyAll<Size>(Size.square(48)),
      ),
    ),
    iconTheme: const IconThemeData(
      weight: 400, // Use "regular" weight, which is visually close to a 2dp stroke.
    ),
    listTileTheme: const ListTileThemeData(
      minVerticalPadding: 16, // Ensures a minimum height of ~48dp for a single-line tile
    ),
    extensions: <ThemeExtension<dynamic>>[tokens],
  );
}
