import 'dart:math';

class GeofenceRegion {
  GeofenceRegion({
    required this.identifier,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
    this.payload = const <String, Object?>{},
  });

  final String identifier;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final Map<String, Object?> payload;
}

class GeolocationSample {
  GeolocationSample({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime recordedAt;
}

class GeofenceTrigger {
  GeofenceTrigger({required this.region, required this.distance});

  final GeofenceRegion region;
  final double distance;
}

class GeofencedNotificationService {
  const GeofencedNotificationService();

  List<GeofenceTrigger> evaluate({
    required List<GeofenceRegion> regions,
    required GeolocationSample sample,
    double enterThreshold = 0.7,
  }) {
    if (regions.isEmpty) {
      return const [];
    }
    final triggers = <GeofenceTrigger>[];
    for (final region in regions) {
      final distance = _haversineDistance(
        sample.latitude,
        sample.longitude,
        region.latitude,
        region.longitude,
      );
      final ratio = distance / region.radiusMeters;
      if (ratio <= enterThreshold) {
        triggers.add(GeofenceTrigger(region: region, distance: distance));
      }
    }
    return triggers;
  }

  double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a =
        pow(sin(dLat / 2), 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * pow(sin(dLon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double value) => value * pi / 180;
}
