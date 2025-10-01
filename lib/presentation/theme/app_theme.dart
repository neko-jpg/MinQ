import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/build_theme.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// Centralized definition of the app's light and dark themes.
///
/// This file uses the `buildTheme` utility to construct `ThemeData` objects
/// from the `MinqTheme` design tokens. This ensures that our theme is consistent
/// and easy to manage.
final ThemeData lightTheme = buildTheme(MinqTheme.light());
final ThemeData darkTheme = buildTheme(MinqTheme.dark());
