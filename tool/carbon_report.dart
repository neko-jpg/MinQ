import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';

const Map<String, double> _runnerEnergyPerMinute = <String, double>{
  'ubuntu-latest': 0.035, // kWh per minute
  'ubuntu-22.04': 0.033,
  'macos-latest': 0.045,
  'windows-latest': 0.055,
};

const double _co2PerKwh = 0.475; // kg CO2e per kWh (global average)

class CiRun {
  CiRun({
    required this.workflow,
    required this.minutes,
    required this.runnerType,
  });

  final String workflow;
  final double minutes;
  final String runnerType;
}

class GcpUsage {
  GcpUsage({
    required this.service,
    required this.energyKwh,
  });

  final String service;
  final double energyKwh;
}

Future<void> main(List<String> args) async {
  final Map<String, String> parsedArgs = _parseArgs(args);
  final String? ciPath = parsedArgs['--ci'];
  final String? gcpPath = parsedArgs['--gcp'];
  final String? outputPath = parsedArgs['--output'];

  if (ciPath == null || gcpPath == null) {
    stderr.writeln('Usage: dart run tool/carbon_report.dart --ci=ci_runs.csv --gcp=gcp_usage.csv');
    exitCode = 64;
    return;
  }

  final List<CiRun> ciRuns = await _loadCiRuns(ciPath);
  final List<GcpUsage> gcpUsage = await _loadGcpUsage(gcpPath);

  final double ciEnergyKwh = ciRuns.fold<double>(0, (double acc, CiRun run) {
    final double factor =
        _runnerEnergyPerMinute[run.runnerType] ?? _runnerEnergyPerMinute['ubuntu-latest']!;
    return acc + run.minutes * factor;
  });

  final double gcpEnergyKwh = gcpUsage.fold<double>(
    0,
    (double acc, GcpUsage usage) => acc + usage.energyKwh,
  );

  final double totalEnergy = ciEnergyKwh + gcpEnergyKwh;
  final double totalCo2 = totalEnergy * _co2PerKwh;

  final Map<String, dynamic> summary = <String, dynamic>{
    'ciEnergyKwh': ciEnergyKwh,
    'gcpEnergyKwh': gcpEnergyKwh,
    'totalEnergyKwh': totalEnergy,
    'totalCo2Kg': totalCo2,
  };

  final String summaryJson = const JsonEncoder.withIndent('  ').convert(summary);
  stdout.writeln(summaryJson);

  if (outputPath != null) {
    File(outputPath).writeAsStringSync(summaryJson);
  }

  await _maybeNotifySlack(ciEnergyKwh, gcpEnergyKwh, totalCo2);
}

Map<String, String> _parseArgs(List<String> args) {
  final Map<String, String> result = <String, String>{};
  for (final String arg in args) {
    if (arg.contains('=')) {
      final int index = arg.indexOf('=');
      result[arg.substring(0, index)] = arg.substring(index + 1);
    } else {
      result[arg] = 'true';
    }
  }
  return result;
}

Future<List<CiRun>> _loadCiRuns(String path) async {
  final File file = File(path);
  if (!await file.exists()) {
    throw FileSystemException('CI CSV not found', path);
  }
  final String csvContent = await file.readAsString();
  final List<List<dynamic>> rows = const CsvToListConverter()
      .convert(csvContent, eol: '\n');

  final int workflowIndex = rows.first.indexOf('workflow');
  final int minutesIndex = rows.first.indexOf('minutes');
  final int runnerIndex = rows.first.indexOf('runner');

  return rows.skip(1).map((List<dynamic> row) {
    return CiRun(
      workflow: row[workflowIndex].toString(),
      minutes: (row[minutesIndex] as num).toDouble(),
      runnerType: row[runnerIndex].toString(),
    );
  }).toList();
}

Future<List<GcpUsage>> _loadGcpUsage(String path) async {
  final File file = File(path);
  if (!await file.exists()) {
    throw FileSystemException('GCP CSV not found', path);
  }
  final String csvContent = await file.readAsString();
  final List<List<dynamic>> rows = const CsvToListConverter()
      .convert(csvContent, eol: '\n');

  final int serviceIndex = rows.first.indexOf('service');
  final int energyIndex = rows.first.indexOf('energy_kwh');

  return rows.skip(1).map((List<dynamic> row) {
    return GcpUsage(
      service: row[serviceIndex].toString(),
      energyKwh: (row[energyIndex] as num).toDouble(),
    );
  }).toList();
}

Future<void> _maybeNotifySlack(
  double ciEnergy,
  double gcpEnergy,
  double totalCo2,
) async {
  final String webhookUrl =
      Platform.environment['SLACK_CARBON_WEBHOOK_URL'] ?? '';
  if (webhookUrl.isEmpty) {
    return;
  }

  final String message = '*Monthly Carbon Report*\n'
      'CI energy: ${ciEnergy.toStringAsFixed(2)} kWh\n'
      'GCP energy: ${gcpEnergy.toStringAsFixed(2)} kWh\n'
      'Total CO2e: ${totalCo2.toStringAsFixed(2)} kg';

  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request =
        await client.postUrl(Uri.parse(webhookUrl));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'text': message}));
    await request.close();
  } finally {
    client.close();
  }
}
