import 'dart:io';

void main() async {
  await finalFix();
}

Future<void> finalFix() async {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
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
      print('Applied final fixes to: ${file.path}');
    }
  } catch (e) {
    print('Error processing ${file.path}: $e');
  }
}