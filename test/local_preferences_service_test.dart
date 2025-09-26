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

  test('preferred locale is persisted and cleared correctly', () async {
    final service = LocalPreferencesService();
    expect(await service.getPreferredLocale(), isNull);
    await service.setPreferredLocale('en');
    expect(await service.getPreferredLocale(), 'en');
    await service.setPreferredLocale(null);
    expect(await service.getPreferredLocale(), isNull);
  });

  test('cloud backup toggle is stored', () async {
    final service = LocalPreferencesService();
    expect(await service.isCloudBackupEnabled(), isFalse);
    await service.setCloudBackupEnabled(true);
    expect(await service.isCloudBackupEnabled(), isTrue);
  });

  test('NPS responses persist score/comment and timestamp', () async {
    final now = DateTime.utc(2024, 3, 1, 9);
    final service = LocalPreferencesService(now: () => now);
    expect(await service.loadNpsResponse(), isNull);

    await service.saveNpsResponse(score: 9, comment: 'Great flow!');
    final response = await service.loadNpsResponse();
    expect(response, isNotNull);
    expect(response!.score, 9);
    expect(response.comment, 'Great flow!');
    expect(response.recordedAt, now);

    await service.saveNpsResponse(score: 4, comment: '');
    final updated = await service.loadNpsResponse();
    expect(updated!.score, 4);
    expect(updated.comment, isNull);
  });

  test('attribution snapshot is stored when UTM parameters exist', () async {
    final service = LocalPreferencesService();
    expect(await service.loadAttribution(), isNull);

    await service.saveAttribution(<String, String>{
      'source': 'newsletter',
      'medium': 'email',
      'campaign': 'launch',
      'content': 'cta',
      'term': 'habit',
      'captured_at_epoch':
          DateTime.utc(2024, 4, 2, 8).millisecondsSinceEpoch.toString(),
    });

    final snapshot = await service.loadAttribution();
    expect(snapshot, isNotNull);
    expect(snapshot!.source, 'newsletter');
    expect(snapshot.medium, 'email');
    expect(snapshot.campaign, 'launch');
    expect(snapshot.content, 'cta');
    expect(snapshot.term, 'habit');
    expect(snapshot.capturedAt, DateTime.utc(2024, 4, 2, 8));

    await service.saveAttribution(<String, String>{});
    expect(await service.loadAttribution(), isNull);
  });
}
