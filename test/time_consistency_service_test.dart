import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/services/time_consistency_service.dart';

void main() {
  test('returns true when device time is within tolerance', () async {
    final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
    final service = TimeConsistencyService(
      tolerance: const Duration(minutes: 3),
      now: () => now,
      serverTimeProvider: () async => now.subtract(const Duration(minutes: 2)),
    );

    expect(await service.isDeviceTimeConsistent(), isTrue);
    service.close();
  });

  test('returns false when drift exceeds tolerance', () async {
    final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
    final service = TimeConsistencyService(
      tolerance: const Duration(minutes: 3),
      now: () => now,
      serverTimeProvider: () async => now.subtract(const Duration(minutes: 10)),
    );

    expect(await service.isDeviceTimeConsistent(), isFalse);
    service.close();
  });

  test('treats missing server time as consistent', () async {
    final now = DateTime.utc(2024, 1, 1, 12, 0, 0);
    final service = TimeConsistencyService(now: () => now, serverTimeProvider: () async => null);

    expect(await service.isDeviceTimeConsistent(), isTrue);
    service.close();
  });

  test('rethrows socket exceptions from the probe', () async {
    final service = TimeConsistencyService(
      serverTimeProvider: () async => throw const SocketException('no network'),
    );

    await expectLater(service.isDeviceTimeConsistent(), throwsA(isA<SocketException>()));
    service.close();
  });
}
