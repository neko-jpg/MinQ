import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:minq/config/stripe_config.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:minq/data/services/stripe_billing_service.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements http.Client {}

class MockLogger extends Mock implements AppLogger {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com/portal'));
  });

  group('StripeBillingService', () {
    late MockClient client;
    late MockLogger logger;
    late StripeBillingService service;

    setUp(() {
      client = MockClient();
      logger = MockLogger();
      service = StripeBillingService(
        client: client,
        config: StripeConfig(portalEndpoint: Uri.parse('https://example.com/portal')),
        logger: logger,
      );
    });

    test('returns portal url on success', () async {
      when(() => client.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer(
        (_) async => http.Response('{"url":"https://billing.example.com"}', 200),
      );
      when(() => logger.logApiRequest(any(), any(), body: any(named: 'body')))
          .thenReturn(null);
      when(() => logger.logApiResponse(any(), any(), any(), body: any(named: 'body')))
          .thenReturn(null);

      final portalUrl = await service.createBillingPortalSession(
        customerId: 'cus_123',
        returnUrl: Uri.parse('https://app.example.com/settings'),
      );

      expect(portalUrl.toString(), equals('https://billing.example.com'));
    });

    test('throws exception when response is not successful', () async {
      when(() => client.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),).thenAnswer(
        (_) async => http.Response('error', 500),
      );
      when(() => logger.logApiRequest(any(), any(), body: any(named: 'body')))
          .thenReturn(null);
      when(() => logger.logApiResponse(any(), any(), any(), body: any(named: 'body')))
          .thenReturn(null);

      expect(
        () => service.createBillingPortalSession(
          customerId: 'cus_123',
          returnUrl: Uri.parse('https://app.example.com/settings'),
        ),
        throwsA(isA<StripeBillingException>()),
      );
    });
  });
}
