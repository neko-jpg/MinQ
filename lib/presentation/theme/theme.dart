import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme_v2.dart';
import 'package:minq/presentation/theme/minq_tokens.dart';

ThemeData buildLightTheme() {
  final theme = MinqThemeV2.light();
  MinqTokens.updateFromTheme(theme);
  return theme;
}

ThemeData buildDarkTheme() {
  final theme = MinqThemeV2.dark();
  return theme;
}
