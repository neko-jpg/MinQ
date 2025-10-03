import 'package:flutter_test/flutter_test.dart';

import 'package:minq/domain/notification/geofenced_notification_service.dart';

void main() {
  group('GeofencedNotificationService', () {
    const service = GeofencedNotificationService();

    test('triggers when within radius', () {
      final regions = [
        GeofenceRegion(
          identifier: 'gym',
          latitude: 35.681236,
          longitude: 139.767125,
          radiusMeters: 150,
        ),
      ];
      final sample = GeolocationSample(
        latitude: 35.6815,
        longitude: 139.7669,
        recordedAt: DateTime.utc(2024, 1, 1, 9),
      );

      final triggers = service.evaluate(regions: regions, sample: sample);
      expect(triggers, isNotEmpty);
      expect(triggers.first.region.identifier, 'gym');
    });

    test('does not trigger when outside radius', () {
      final regions = [
        GeofenceRegion(
          identifier: 'gym',
          latitude: 35.681236,
          longitude: 139.767125,
          radiusMeters: 50,
        ),
      ];
      final sample = GeolocationSample(
        latitude: 35.6895,
        longitude: 139.6917,
        recordedAt: DateTime.utc(2024, 1, 1, 9),
      );

      final triggers = service.evaluate(regions: regions, sample: sample);
      expect(triggers, isEmpty);
    });
  });
}
