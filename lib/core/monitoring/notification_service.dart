import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:minq/core/config/environment.dart';
import 'package:minq/core/logging/app_logger.dart';

/// 重大イベント通知サービス
///
/// Slack、メール、その他の通知チャネルに
/// 重大なイベントを通知する
class NotificationService {
  final http.Client _client;
  final Environment _env;

  NotificationService({http.Client? client, Environment? env})
    : _client = client ?? http.Client(),
      _env = env ?? Environment.current;

  /// Slackに通知を送信
  Future<void> sendSlackNotification({
    required String title,
    required String message,
    NotificationSeverity severity = NotificationSeverity.warning,
  }) async {
    final webhookUrl = _env.slackWebhookUrl;
    if (webhookUrl == null || webhookUrl.isEmpty) {
      logger.warning('Slack webhook URL not configured');
      return;
    }

    try {
      final color = _getSeverityColor(severity);
      final emoji = _getSeverityEmoji(severity);

      final payload = {
        'username': 'MiniQ Monitor',
        'icon_emoji': ':robot_face:',
        'attachments': [
          {
            'color': color,
            'title': '$emoji $title',
            'text': message,
            'fields': [
              {
                'title': 'Severity',
                'value': severity.name.toUpperCase(),
                'short': true,
              },
              {'title': 'Environment', 'value': _env.name, 'short': true},
              {
                'title': 'Timestamp',
                'value': DateTime.now().toIso8601String(),
                'short': false,
              },
            ],
            'footer': 'MiniQ Monitoring',
            'ts': DateTime.now().millisecondsSinceEpoch ~/ 1000,
          },
        ],
      };

      final response = await _client.post(
        Uri.parse(webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        logger.info('Slack notification sent successfully');
      } else {
        logger.error(
          'Failed to send Slack notification',
          data: {'status': response.statusCode, 'body': response.body},
        );
      }
    } catch (e, stack) {
      logger.error(
        'Error sending Slack notification',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// メール通知を送信
  Future<void> sendEmailNotification({
    required String title,
    required String message,
    required List<String> recipients,
    NotificationSeverity severity = NotificationSeverity.warning,
  }) async {
    // Cloud Functionsのメール送信エンドポイントを呼び出す
    final emailEndpoint = _env.emailNotificationEndpoint;
    if (emailEndpoint == null || emailEndpoint.isEmpty) {
      logger.warning('Email notification endpoint not configured');
      return;
    }

    try {
      final payload = {
        'to': recipients,
        'subject': '[$severity] $title',
        'body': _formatEmailBody(title, message, severity),
        'html': _formatEmailHtml(title, message, severity),
      };

      final response = await _client.post(
        Uri.parse(emailEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        logger.info('Email notification sent successfully');
      } else {
        logger.error(
          'Failed to send email notification',
          data: {'status': response.statusCode, 'body': response.body},
        );
      }
    } catch (e, stack) {
      logger.error(
        'Error sending email notification',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// PagerDutyにアラートを送信
  Future<void> sendPagerDutyAlert({
    required String title,
    required String message,
    NotificationSeverity severity = NotificationSeverity.critical,
  }) async {
    final integrationKey = _env.pagerDutyIntegrationKey;
    if (integrationKey == null || integrationKey.isEmpty) {
      logger.warning('PagerDuty integration key not configured');
      return;
    }

    try {
      final payload = {
        'routing_key': integrationKey,
        'event_action': 'trigger',
        'payload': {
          'summary': title,
          'severity': _mapSeverityToPagerDuty(severity),
          'source': 'MiniQ App',
          'custom_details': {
            'message': message,
            'environment': _env.name,
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
      };

      final response = await _client.post(
        Uri.parse('https://events.pagerduty.com/v2/enqueue'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );

      if (response.statusCode == 202) {
        logger.info('PagerDuty alert sent successfully');
      } else {
        logger.error(
          'Failed to send PagerDuty alert',
          data: {'status': response.statusCode, 'body': response.body},
        );
      }
    } catch (e, stack) {
      logger.error(
        'Error sending PagerDuty alert',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// 複数チャネルに通知
  Future<void> notifyAll({
    required String title,
    required String message,
    NotificationSeverity severity = NotificationSeverity.warning,
    List<String>? emailRecipients,
  }) async {
    final futures = <Future<void>>[];

    // Slack通知
    futures.add(
      sendSlackNotification(title: title, message: message, severity: severity),
    );

    // メール通知
    if (emailRecipients != null && emailRecipients.isNotEmpty) {
      futures.add(
        sendEmailNotification(
          title: title,
          message: message,
          recipients: emailRecipients,
          severity: severity,
        ),
      );
    }

    // クリティカルな場合はPagerDutyにも通知
    if (severity == NotificationSeverity.critical) {
      futures.add(
        sendPagerDutyAlert(title: title, message: message, severity: severity),
      );
    }

    await Future.wait(futures);
  }

  String _getSeverityColor(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.info:
        return '#36a64f'; // 緑
      case NotificationSeverity.warning:
        return '#ff9800'; // オレンジ
      case NotificationSeverity.error:
        return '#f44336'; // 赤
      case NotificationSeverity.critical:
        return '#9c27b0'; // 紫
    }
  }

  String _getSeverityEmoji(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.info:
        return 'ℹ️';
      case NotificationSeverity.warning:
        return '⚠️';
      case NotificationSeverity.error:
        return '❌';
      case NotificationSeverity.critical:
        return '🚨';
    }
  }

  String _mapSeverityToPagerDuty(NotificationSeverity severity) {
    switch (severity) {
      case NotificationSeverity.info:
        return 'info';
      case NotificationSeverity.warning:
        return 'warning';
      case NotificationSeverity.error:
        return 'error';
      case NotificationSeverity.critical:
        return 'critical';
    }
  }

  String _formatEmailBody(
    String title,
    String message,
    NotificationSeverity severity,
  ) {
    return '''
MiniQ Monitoring Alert

Severity: ${severity.name.toUpperCase()}
Title: $title
Message: $message

Environment: ${_env.name}
Timestamp: ${DateTime.now().toIso8601String()}

---
This is an automated message from MiniQ Monitoring System.
''';
  }

  String _formatEmailHtml(
    String title,
    String message,
    NotificationSeverity severity,
  ) {
    final color = _getSeverityColor(severity);
    return '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background-color: $color; color: white; padding: 20px; border-radius: 5px; }
    .content { padding: 20px; background-color: #f5f5f5; margin-top: 20px; border-radius: 5px; }
    .footer { margin-top: 20px; font-size: 12px; color: #666; }
    .badge { display: inline-block; padding: 5px 10px; background-color: $color; color: white; border-radius: 3px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>MiniQ Monitoring Alert</h1>
    </div>
    <div class="content">
      <p><span class="badge">${severity.name.toUpperCase()}</span></p>
      <h2>$title</h2>
      <p>$message</p>
      <hr>
      <p><strong>Environment:</strong> ${_env.name}</p>
      <p><strong>Timestamp:</strong> ${DateTime.now().toIso8601String()}</p>
    </div>
    <div class="footer">
      <p>This is an automated message from MiniQ Monitoring System.</p>
    </div>
  </div>
</body>
</html>
''';
  }
}

/// 通知の重要度
enum NotificationSeverity { info, warning, error, critical }

/// 通知サービスのProvider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
