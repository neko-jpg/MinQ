import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

ThemeData buildTheme(MinqTheme tokens) {
  return ThemeData(
    brightness: tokens.brightness,
    primaryColor: tokens.brandPrimary,
    scaffoldBackgroundColor: tokens.background,
    extensions: [tokens],
  );
}
