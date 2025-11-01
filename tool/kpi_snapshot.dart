import 'dart:convert';
import 'dart:io';

class KpiMetric {
  KpiMetric({
    required this.key,
    required this.label,
    required this.value,
    required this.target,
  });

  final String key;
  final String label;
  final double value;
  final double target;

  bool get isOnTrack => value >= target;
}

Future<void> main(List<String> args) async {
  final Map<String, String> parsedArgs = _parseArgs(args);
  final String? inputPath = parsedArgs['--input'];
  final bool dryRun = parsedArgs.containsKey('--dry-run');

  final Map<String, dynamic> payload = await _readPayload(inputPath);
  final DateTime generatedAt = DateTime.parse(payload['generatedAt'] as String);
  final List<dynamic> metricsRaw = payload['metrics'] as List<dynamic>;

  final List<KpiMetric> metrics =
      metricsRaw
          .map((dynamic item) => item as Map<String, dynamic>)
          .map(
            (Map<String, dynamic> item) => KpiMetric(
              key: item['key'] as String,
              label: item['label'] as String,
              value: (item['value'] as num).toDouble(),
              target: (item['target'] as num).toDouble(),
            ),
          )
          .toList();

  final String message = _buildSlackMessage(generatedAt, metrics);
  final String webhookUrl = Platform.environment['SLACK_KPI_WEBHOOK_URL'] ?? '';

  if (dryRun || webhookUrl.isEmpty) {
    stdout.writeln('Dry run or webhook missing. Message preview:\n$message');
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
    final String responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      stderr.writeln(
        'Slack notification failed: ${response.statusCode} $responseBody',
      );
      exitCode = 1;
    }
  } finally {
    client.close();
  }
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

Future<Map<String, dynamic>> _readPayload(String? inputPath) async {
  final String jsonString;
  if (inputPath == null || inputPath == '-') {
    jsonString = await stdin.transform(utf8.decoder).join();
  } else {
    jsonString = await File(inputPath).readAsString();
  }
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

String _buildSlackMessage(DateTime generatedAt, List<KpiMetric> metrics) {
  final StringBuffer buffer =
      StringBuffer()..writeln('*MinQ KPI Snapshot - ${generatedAt.toLocal()}*');
  for (final KpiMetric metric in metrics) {
    final String emoji = metric.isOnTrack ? ':white_check_mark:' : ':warning:';
    final String valuePercent = (metric.value * 100).toStringAsFixed(1);
    final String targetPercent = (metric.target * 100).toStringAsFixed(1);
    buffer.writeln(
      '$emoji ${metric.label}: $valuePercent% (target $targetPercent%)',
    );
  }
  return buffer.toString();
}
