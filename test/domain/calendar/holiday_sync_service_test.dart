import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:minq/domain/calendar/holiday_sync_service.dart';

void main() {
  group('HolidaySyncService', () {
    test('fetches and caches holidays', () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        return http.Response('[{"date":"2024-01-01","localName":"New Year","countryCode":"JP"}]', 200);
      });

      final service = HolidaySyncService(client: client);
      final result = await service.fetch(year: 2024, countryCode: 'JP');
      expect(result.holidays, hasLength(1));

      final cached = await service.fetch(year: 2024, countryCode: 'JP');
      expect(cached.holidays, hasLength(1));
      expect(requestCount, 1);
    });

    test('throws on non-success status code', () async {
      final client = MockClient((request) async => http.Response('error', 500));
      final service = HolidaySyncService(client: client);

      expect(
        () => service.fetch(year: 2024, countryCode: 'JP'),
        throwsA(isA<HolidaySyncException>()),
      );
    });
  });
}
