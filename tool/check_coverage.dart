import 'dart:io';

void main(List<String> args) {
  var minCoverage = 75.0;
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--min' && i + 1 < args.length) {
      minCoverage = double.tryParse(args[i + 1]) ?? minCoverage;
      i++;
    }
  }

  final coverageFile = File('coverage/lcov.info');
  if (!coverageFile.existsSync()) {
    stderr.writeln('Coverage report not found at coverage/lcov.info.');
    exitCode = 66;
    return;
  }

  final lines = coverageFile.readAsLinesSync();
  var totalLines = 0;
  var coveredLines = 0;

  for (final line in lines) {
    if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length == 2) {
        totalLines++;
        final hits = int.tryParse(parts[1]);
        if (hits != null && hits > 0) {
          coveredLines++;
        }
      }
    }
  }

  if (totalLines == 0) {
    stderr.writeln('No coverage data found in lcov report.');
    exitCode = 65;
    return;
  }

  final coverage = coveredLines / totalLines * 100;
  stdout.writeln('Line coverage: ${coverage.toStringAsFixed(2)}% (min ${minCoverage.toStringAsFixed(2)}%)');

  if (coverage + 1e-6 < minCoverage) {
    stderr.writeln('Coverage requirement not met.');
    exitCode = 1;
  }
}
