import 'package:flutter/material.dart';

class MinqTheme {
  static TextStyle of(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
  }

  static ColorScheme colorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  static ThemeData theme(BuildContext context) {
    return Theme.of(context);
  }
}