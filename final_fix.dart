import 'dart:io';

void main() async {
  await finalFix();
}

Future<void> finalFix() async {
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

    // Fix broken import paths
    content = content.replaceAll(
      "import 'package:minq/presentation/theme/minq_MinqTokens.dart';",
      "import 'package:minq/presentation/theme/minq_tokens.dart';",
    );

    if (content != originalContent) {
      await file.writeAsString(content);
      // ignore: avoid_print
      print('Applied final fixes to: ${file.path}');
    }
  } catch (e) {
    // ignore: avoid_print
    print('Error processing ${file.path}: $e');
  }
}