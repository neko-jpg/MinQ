import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/services/local_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object?>{});
  });

  test('pair guidelines flag defaults to false and can be updated', () async {
    final service = LocalPreferencesService();

    expect(await service.hasSeenPairGuidelines(), isFalse);
    await service.markPairGuidelinesSeen();
    expect(await service.hasSeenPairGuidelines(), isTrue);
  });

  test('report attempts are limited within the configured window', () async {
    final service = LocalPreferencesService();
    final baseTime = DateTime.utc(2024, 1, 1, 12, 0, 0);

    expect(
      await service.registerReportAttempt(now: baseTime),
      isNull,
    );
    expect(
      await service.registerReportAttempt(now: baseTime.add(const Duration(minutes: 2))),
      isNull,
    );
    expect(
      await service.registerReportAttempt(now: baseTime.add(const Duration(minutes: 4))),
      isNull,
    );

    final retryAfter = await service.registerReportAttempt(
      now: baseTime.add(const Duration(minutes: 5)),
    );
    expect(retryAfter, isNotNull);
    expect(retryAfter!.inMinutes, greaterThan(0));

    // After the window passes, reports are allowed again.
    final allowedAgain = await service.registerReportAttempt(
      now: baseTime.add(const Duration(minutes: 15)),
    );
    expect(allowedAgain, isNull);
  });
}
