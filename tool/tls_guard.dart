import 'dart:io';

void main() {
  final root = Directory.current;
  final violations = <String>[];
  final forbiddenPatterns = <String>['http://', 'Uri.http'];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.dart') && !entity.path.endsWith('.yaml')) continue;
    if (entity.path.contains('${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}')) {
      continue;
    }

    final content = entity.readAsStringSync();
    for (final pattern in forbiddenPatterns) {
      if (content.contains(pattern)) {
        violations.add('${entity.path} contains insecure reference "$pattern"');
      }
    }
  }

  if (violations.isNotEmpty) {
    stderr.writeln('TLS guard failed:');
    for (final violation in violations) {
      stderr.writeln('  - $violation');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('TLS guard passed.');
}
