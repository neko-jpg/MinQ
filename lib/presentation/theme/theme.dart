import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

ThemeData buildLightTheme() {
  final minqTheme = MinqTheme.light();
  return ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: minqTheme.brandPrimary,
      brightness: Brightness.light,
    ),
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      minqTheme,
    ],
  );
}

ThemeData buildDarkTheme() {
  final minqTheme = MinqTheme.dark();
  return ThemeData.from(
    colorScheme: ColorScheme.fromSeed(
      seedColor: minqTheme.brandPrimary,
      brightness: Brightness.dark,
    ),
  ).copyWith(
    extensions: <ThemeExtension<dynamic>>[
      minqTheme,
    ],
  );
}
