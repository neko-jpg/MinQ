import 'dart:io';

import 'package:path/path.dart' as p;

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('lib directory not found');
    exitCode = 1;
    return;
  }

  final violations = <String>[];

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }

    final relativePath = p.relative(entity.path, from: libDir.path);
    final layer = relativePath.split(p.separator).first;
    final content = entity.readAsStringSync();

    switch (layer) {
      case 'domain':
        _checkForbiddenImports(
          content,
          relativePath,
          <String>['package:minq/data/', '../data/', 'package:minq/presentation/', '../presentation/'],
          violations,
        );
        break;
      case 'data':
        _checkForbiddenImports(
          content,
          relativePath,
          <String>['package:minq/presentation/', '../presentation/'],
          violations,
        );
        break;
      default:
        break;
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('Dependency guard failed:');
    for (final violation in violations) {
      stderr.writeln('  - $violation');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Dependency guard passed.');
}

void _checkForbiddenImports(
  String content,
  String relativePath,
  List<String> forbidden,
  List<String> violations,
) {
  for (final pattern in forbidden) {
    if (content.contains("import '$pattern") || content.contains('import \"$pattern')) {
      violations.add('$relativePath imports $pattern');
    }
  }
}
