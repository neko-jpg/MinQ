import 'dart:io';

void main() async {
  // Fix common MinqTokens issues
  await fixMinqTokensIssues();
}

Future<void> fixMinqTokensIssues() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    print('lib directory not found');
    return;
  }

  await for (final file in libDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      await fixFileMinqTokens(file);
    }
  }
}

Future<void> fixFileMinqTokens(File file) async {
  try {
    String content = await file.readAsString();
    String originalContent = content;

    // Fix import statements
    content = content.replaceAll(
      "import 'package:minq/presentation/theme/minq_theme.dart';",
      "import 'package:minq/presentation/theme/minq_tokens.dart';",
    );

    // Fix withOpacity to withValues
    content = content.replaceAll(
      RegExp(r'\.withOpacity\(([^)]+)\)'),
      '.withValues(alpha: \$1)',
    );

    // Fix tokens.spacing usage
    content = content.replaceAll(
      RegExp(r'tokens\.spacing\('),
      'MinqTokens.spacing(',
    );

    // Fix tokens.cornerMedium usage
    content = content.replaceAll(
      RegExp(r'tokens\.cornerMedium\(\)'),
      'MinqTokens.cornerMedium()',
    );

    // Fix tokens.cornerSmall usage
    content = content.replaceAll(
      RegExp(r'tokens\.cornerSmall\(\)'),
      'MinqTokens.cornerSmall()',
    );

    // Fix tokens.cornerLarge usage
    content = content.replaceAll(
      RegExp(r'tokens\.cornerLarge\(\)'),
      'MinqTokens.cornerLarge()',
    );

    // Fix color tokens
    content = content.replaceAll(
      RegExp(r'tokens\.brandPrimary'),
      'MinqTokens.brandPrimary',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.brandSecondary'),
      'MinqTokens.brandSecondary',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.textPrimary'),
      'MinqTokens.textPrimary',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.textSecondary'),
      'MinqTokens.textSecondary',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.surface'),
      'MinqTokens.surface',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.background'),
      'MinqTokens.background',
    );

    // Fix typography tokens
    content = content.replaceAll(
      RegExp(r'tokens\.titleLarge'),
      'MinqTokens.titleLarge',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.titleMedium'),
      'MinqTokens.titleMedium',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.bodyLarge'),
      'MinqTokens.bodyLarge',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.bodyMedium'),
      'MinqTokens.bodyMedium',
    );

    content = content.replaceAll(
      RegExp(r'tokens\.bodySmall'),
      'MinqTokens.bodySmall',
    );

    // Remove unused tokens variables
    content = content.replaceAll(
      RegExp(r'final tokens = context\.tokens;\s*'),
      '',
    );

    // Fix method parameters that take MinqTokens
    content = content.replaceAll(
      RegExp(r'Widget _build\w+\(MinqTokens tokens,?\s*'),
      'Widget _build',
    );

    content = content.replaceAll(
      RegExp(r'Widget _build\w+\(\s*MinqTokens tokens\s*\)'),
      'Widget _build',
    );

    if (content != originalContent) {
      await file.writeAsString(content);
      print('Fixed MinqTokens issues in: ${file.path}');
    }
  } catch (e) {
    print('Error processing ${file.path}: $e');
  }
}