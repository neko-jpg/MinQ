import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:minq/config/stripe_config.dart';
import 'package:minq/core/logging/app_logger.dart';

class StripeBillingException implements Exception {
  StripeBillingException(this.message);
  final String message;

  @override
  String toString() => 'StripeBillingException: $message';
}

class StripeBillingService {
  StripeBillingService({
    required this.client,
    required this.config,
    required this.logger,
  });

  final http.Client client;
  final StripeConfig config;
  final AppLogger logger;

  Future<Uri> createBillingPortalSession({
    required String customerId,
    required Uri returnUrl,
  }) async {
    final payload = <String, dynamic>{
      'customerId': customerId,
      'returnUrl': returnUrl.toString(),
    };

    AppLogger.logApiRequest('POST', config.portalEndpoint.toString(), body: {
      'customerId': customerId,
      'returnUrl': returnUrl.toString(),
    },);

    final response = await client.post(
      config.portalEndpoint,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    AppLogger.logApiResponse(
      'POST',
      config.portalEndpoint.toString(),
      response.statusCode,
      body: response.body,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final url = decoded['url'] as String?;
      if (url == null || url.isEmpty) {
        throw StripeBillingException('Billing portal URL was not returned.');
      }
      return Uri.parse(url);
    }

    throw StripeBillingException(
      'Failed to create billing portal session (status ${response.statusCode}).',
    );
  }
}
