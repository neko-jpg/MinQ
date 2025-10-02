import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:minq/presentation/theme/minq_theme.dart';

class ContrastRequirement {
  const ContrastRequirement({
    required this.description,
    required this.foreground,
    required this.background,
    this.minimumRatio = 4.5,
  });

  final String description;
  final Color Function(MinqTheme theme) foreground;
  final Color Function(MinqTheme theme) background;
  final double minimumRatio;
}

double _contrastRatio(Color a, Color b) {
  final double luminanceA = a.computeLuminance();
  final double luminanceB = b.computeLuminance();
  final double brightest = max(luminanceA, luminanceB);
  final double darkest = min(luminanceA, luminanceB);
  return (brightest + 0.05) / (darkest + 0.05);
}

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();

  final Map<String, MinqTheme> themes = {
    'light': MinqTheme.light(),
    'dark': MinqTheme.dark(),
  };

  final List<ContrastRequirement> requirements = [
    ContrastRequirement(
      description: 'body text on background',
      foreground: (theme) => theme.textPrimary,
      background: (theme) => theme.background,
    ),
    ContrastRequirement(
      description: 'secondary text on surface',
      foreground: (theme) => theme.textSecondary,
      background: (theme) => theme.surface,
    ),
    ContrastRequirement(
      description: 'muted text on surface (minimum 3.0)',
      foreground: (theme) => theme.textMuted,
      background: (theme) => theme.surface,
      minimumRatio: 3.0,
    ),
    ContrastRequirement(
      description: 'success accent on surface',
      foreground: (theme) => theme.accentSuccess,
      background: (theme) => theme.surface,
    ),
    ContrastRequirement(
      description: 'error accent on background',
      foreground: (theme) => theme.accentError,
      background: (theme) => theme.background,
    ),
    ContrastRequirement(
      description: 'high contrast text on high contrast background',
      foreground: (theme) => theme.highContrastText,
      background: (theme) => theme.highContrastBackground,
      minimumRatio: 7.0,
    ),
  ];

  final StringBuffer report = StringBuffer();
  bool hasFailure = false;

  for (final entry in themes.entries) {
    final themeName = entry.key;
    final theme = entry.value;
    report.writeln('Theme: $themeName');

    for (final requirement in requirements) {
      final double ratio = _contrastRatio(
        requirement.foreground(theme),
        requirement.background(theme),
      );
      final bool passes = ratio >= requirement.minimumRatio;
      final status = passes ? 'PASS' : 'FAIL';
      report.writeln(
        '  [$status] ${requirement.description} -> ${ratio.toStringAsFixed(2)} '
        '(>= ${requirement.minimumRatio})',
      );
      if (!passes) {
        hasFailure = true;
      }
    }

    report.writeln();
  }

  stdout.write(report.toString());

  if (hasFailure) {
    stderr.writeln('Contrast validation failed.');
    exitCode = 1;
  }
}
