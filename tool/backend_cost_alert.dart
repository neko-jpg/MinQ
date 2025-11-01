import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class ServiceThreshold {
  ServiceThreshold({
    required this.monthlyBudget,
    required this.dailyGrowthWarningRatio,
    this.maxDailyInvocations,
    this.cpuSecondsHourlyThreshold,
  });

  final double monthlyBudget;
  final double dailyGrowthWarningRatio;
  final double? maxDailyInvocations;
  final double? cpuSecondsHourlyThreshold;
}

class CostRecord {
  CostRecord({
    required this.service,
    required this.monthlyCost,
    required this.dailyCost,
    required this.dailyAverageLastWeek,
    required this.monthlyForecast,
    this.dailyInvocations,
    this.cpuSecondsHourly,
  });

  final String service;
  final double monthlyCost;
  final double dailyCost;
  final double dailyAverageLastWeek;
  final double monthlyForecast;
  final double? dailyInvocations;
  final double? cpuSecondsHourly;
}

class AlertFinding {
  AlertFinding({
    required this.service,
    required this.reason,
    required this.record,
  });

  final String service;
  final String reason;
  final CostRecord record;
}

Future<void> main(List<String> args) async {
  final Map<String, String> parsedArgs = _parseArgs(args);
  final String? inputPath = parsedArgs['--input'];
  final bool dryRun = parsedArgs.containsKey('--dry-run');

  final Map<String, dynamic> payload = await _readJsonPayload(inputPath);
  final DateTime generatedAt = DateTime.parse(payload['generatedAt'] as String);
  final List<dynamic> recordsRaw = payload['records'] as List<dynamic>;
  final Map<String, ServiceThreshold> thresholds = _loadThresholds();

  final List<CostRecord> records =
      recordsRaw
          .map((dynamic item) => item as Map<String, dynamic>)
          .map(
            (Map<String, dynamic> item) => CostRecord(
              service: item['service'] as String,
              monthlyCost: (item['monthlyCost'] as num).toDouble(),
              dailyCost: (item['dailyCost'] as num).toDouble(),
              dailyAverageLastWeek:
                  (item['dailyAverageLastWeek'] as num).toDouble(),
              monthlyForecast: (item['monthlyForecast'] as num).toDouble(),
              dailyInvocations:
                  item['dailyInvocations'] == null
                      ? null
                      : (item['dailyInvocations'] as num).toDouble(),
              cpuSecondsHourly:
                  item['cpuSecondsHourly'] == null
                      ? null
                      : (item['cpuSecondsHourly'] as num).toDouble(),
            ),
          )
          .toList();

  final List<AlertFinding> findings = <AlertFinding>[];

  for (final CostRecord record in records) {
    final ServiceThreshold? threshold = thresholds[record.service];
    if (threshold == null) {
      continue;
    }

    final double warningBudget = threshold.monthlyBudget * 0.8;
    final bool exceedsBudgetWarning = record.monthlyCost >= warningBudget;
    final bool spikesVsBaseline =
        record.dailyAverageLastWeek > 0 &&
        record.dailyCost / record.dailyAverageLastWeek >=
            threshold.dailyGrowthWarningRatio;

    if (exceedsBudgetWarning && spikesVsBaseline) {
      final String reason =
          'コスト高騰: 月次 '
          '${record.monthlyCost.toStringAsFixed(0)} USD '
          '(予算 ${threshold.monthlyBudget.toStringAsFixed(0)} USD, '
          '予測 ${record.monthlyForecast.toStringAsFixed(0)} USD)';
      findings.add(
        AlertFinding(service: record.service, reason: reason, record: record),
      );
    }

    if (threshold.maxDailyInvocations != null &&
        (record.dailyInvocations ?? 0) > threshold.maxDailyInvocations!) {
      findings.add(
        AlertFinding(
          service: record.service,
          reason:
              '実行回数が閾値超過: '
              '${record.dailyInvocations?.toStringAsFixed(0)} > '
              '${threshold.maxDailyInvocations!.toStringAsFixed(0)}',
          record: record,
        ),
      );
    }

    if (threshold.cpuSecondsHourlyThreshold != null &&
        (record.cpuSecondsHourly ?? 0) > threshold.cpuSecondsHourlyThreshold!) {
      findings.add(
        AlertFinding(
          service: record.service,
          reason:
              'CPU秒が閾値超過: '
              '${record.cpuSecondsHourly?.toStringAsFixed(0)} > '
              '${threshold.cpuSecondsHourlyThreshold!.toStringAsFixed(0)}',
          record: record,
        ),
      );
    }
  }

  if (findings.isEmpty) {
    stdout.writeln('No anomalies detected.');
    return;
  }

  final String slackMessage = _buildSlackMessage(generatedAt, findings);

  if (dryRun) {
    stdout.writeln('Dry run mode. Message preview:\n$slackMessage');
    return;
  }

  await Future.wait(<Future<void>>[
    _sendSlack(slackMessage),
    _sendOpsgenie(findings, generatedAt),
  ]);
}

Future<Map<String, dynamic>> _readJsonPayload(String? inputPath) async {
  final String jsonString;
  if (inputPath == null || inputPath == '-') {
    jsonString = await stdin.transform(utf8.decoder).join();
  } else {
    jsonString = await File(inputPath).readAsString();
  }
  return jsonDecode(jsonString) as Map<String, dynamic>;
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

Map<String, ServiceThreshold> _loadThresholds() {
  final File file = File('config/backend_cost_thresholds.yaml');
  final String yamlContent = file.readAsStringSync();
  final YamlMap yaml = loadYaml(yamlContent) as YamlMap;
  final Map<String, ServiceThreshold> thresholds = <String, ServiceThreshold>{};
  for (final MapEntry<dynamic, dynamic> entry in yaml.entries) {
    final String key = entry.key.toString();
    final YamlMap value = entry.value as YamlMap;
    thresholds[key] = ServiceThreshold(
      monthlyBudget: (value['monthly_budget_usd'] as num).toDouble(),
      dailyGrowthWarningRatio:
          (value['daily_growth_warning_ratio'] as num).toDouble(),
      maxDailyInvocations:
          value.containsKey('max_daily_invocations')
              ? (value['max_daily_invocations'] as num).toDouble()
              : null,
      cpuSecondsHourlyThreshold:
          value.containsKey('cpu_seconds_hourly_threshold')
              ? (value['cpu_seconds_hourly_threshold'] as num).toDouble()
              : null,
    );
  }
  return thresholds;
}

String _buildSlackMessage(DateTime generatedAt, List<AlertFinding> findings) {
  final StringBuffer buffer =
      StringBuffer()
        ..writeln('*MinQ Backend Cost Alert - ${generatedAt.toLocal()}*');
  for (final AlertFinding finding in findings) {
    buffer.writeln('- `${finding.service}`: ${finding.reason}');
  }
  return buffer.toString();
}

Future<void> _sendSlack(String message) async {
  final String webhookUrl =
      Platform.environment['SLACK_COST_ALERT_WEBHOOK_URL'] ?? '';
  if (webhookUrl.isEmpty) {
    stdout.writeln('SLACK_COST_ALERT_WEBHOOK_URL not set. Skipping Slack.');
    return;
  }

  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request = await client.postUrl(
      Uri.parse(webhookUrl),
    );
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode({'text': message}));
    final HttpClientResponse response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String body = await response.transform(utf8.decoder).join();
      stderr.writeln('Slack notification failed: ${response.statusCode} $body');
      exitCode = 1;
    }
  } finally {
    client.close();
  }
}

Future<void> _sendOpsgenie(
  List<AlertFinding> findings,
  DateTime generatedAt,
) async {
  final String apiKey = Platform.environment['OPSGENIE_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    stdout.writeln('OPSGENIE_API_KEY not set. Skipping Opsgenie.');
    return;
  }

  final HttpClient client = HttpClient();
  try {
    final HttpClientRequest request = await client.postUrl(
      Uri.parse('https://api.opsgenie.com/v2/alerts'),
    );
    request.headers
      ..contentType = ContentType.json
      ..set('Authorization', 'GenieKey $apiKey');

    final Map<String, dynamic> payload = <String, dynamic>{
      'message': 'MinQ backend cost alert',
      'alias': 'minq-backend-cost-${generatedAt.toIso8601String()}',
      'description': findings
          .map(
            (AlertFinding finding) => '${finding.service}: ${finding.reason}',
          )
          .join('\n'),
      'priority': 'P2',
      'source': 'github-actions',
    };

    request.write(jsonEncode(payload));

    final HttpClientResponse response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final String body = await response.transform(utf8.decoder).join();
      stderr.writeln(
        'Opsgenie notification failed: ${response.statusCode} $body',
      );
      exitCode = 1;
    }
  } finally {
    client.close();
  }
}
