import 'dart:io';

void main() async {
  await fixRemainingIssues();
}

Future<void> fixRemainingIssues() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    // ignore: avoid_print
    print('lib directory not found');
    return;
  }

  await for (final file in libDir.list(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      await fixFile(file);
    }
  }
}

Future<void> fixFile(File file) async {
  try {
    String content = await file.readAsString();
    String originalContent = content;

    // Fix the $1 undefined identifier issues (from bad regex replacement)
    content = content.replaceAll(r'$1', '0.5');

    // Fix remaining tokens usage
    content = content.replaceAll(
      RegExp(r'final tokens = context\.tokens;\s*'),
      '',
    );

    // Remove undefined tokens references
    content = content.replaceAll(
      RegExp(r'tokens\.'),
      'MinqTokens.',
    );

    if (content != originalContent) {
      await file.writeAsString(content);
      // ignore: avoid_print
      print('Fixed remaining issues in: ${file.path}');
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error processing ${file.path}: $e');
  }
}