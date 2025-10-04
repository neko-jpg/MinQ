import 'package:minq/data/services/local_preferences_service.dart';
import 'package:minq/data/services/usage_limit_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockLocalPreferencesService extends Mock
    implements LocalPreferencesService {}

void main() {
  setUpAll(() {
    registerFallbackValue(DateTime(2000));
  });

  group('UsageLimitService', () {
    late MockLocalPreferencesService preferences;
    late UsageLimitService service;
    late DateTime now;

    setUp(() {
      preferences = MockLocalPreferencesService();
      now = DateTime(2024, 1, 2, 9);
      service = UsageLimitService(
        preferences,
        now: () => now,
      );
    });

    test('resets counters when a new day starts', () async {
      when(() => preferences.getUsageLastReset()).thenAnswer(
        (_) async => DateTime(2024, 1, 1, 8),
      );
      when(() => preferences.getUsageLimitMinutes()).thenAnswer(
        (_) async => 120,
      );
      when(() => preferences.getUsageUsedSeconds()).thenAnswer(
        (_) async => 600,
      );
      when(() => preferences.setUsageLastReset(any())).thenAnswer(
        (_) async => true,
      );
      when(() => preferences.setUsageUsedSeconds(any())).thenAnswer(
        (_) async => true,
      );

      final snapshot = await service.loadSnapshot();

      expect(snapshot.dailyLimit, equals(const Duration(minutes: 120)));
      expect(snapshot.usedToday, equals(Duration.zero));
      verify(() => preferences.setUsageLastReset(DateTime(2024, 1, 2))).called(1);
      verify(() => preferences.setUsageUsedSeconds(0)).called(1);
    });

    test('records additional usage without resetting when same day', () async {
      now = DateTime(2024, 1, 2, 9, 30);
      when(() => preferences.getUsageLastReset()).thenAnswer(
        (_) async => DateTime(2024, 1, 2),
      );
      when(() => preferences.getUsageLimitMinutes()).thenAnswer(
        (_) async => 30,
      );
      when(() => preferences.getUsageUsedSeconds()).thenAnswer(
        (_) async => 900,
      );
      when(() => preferences.setUsageUsedSeconds(any())).thenAnswer(
        (_) async => true,
      );

      final snapshot = await service.recordUsage(const Duration(minutes: 10));

      expect(snapshot.usedToday, equals(const Duration(minutes: 25)));
      verifyNever(() => preferences.setUsageLastReset(any()));
      verify(() => preferences.setUsageUsedSeconds(1500)).called(1);
    });

    test('ignores negative usage inputs', () async {
      when(() => preferences.getUsageLastReset()).thenAnswer(
        (_) async => DateTime(2024, 1, 2),
      );
      when(() => preferences.getUsageLimitMinutes()).thenAnswer(
        (_) async => null,
      );
      when(() => preferences.getUsageUsedSeconds()).thenAnswer(
        (_) async => 0,
      );

      final snapshot = await service.recordUsage(const Duration(minutes: -5));

      expect(snapshot.usedToday, equals(Duration.zero));
      verifyNever(() => preferences.setUsageUsedSeconds(any()));
    });

    test('clears usage when disabling limit', () async {
      when(() => preferences.getUsageLastReset()).thenAnswer(
        (_) async => DateTime(2024, 1, 2),
      );
      when(() => preferences.getUsageLimitMinutes()).thenAnswer(
        (_) async => 45,
      );
      when(() => preferences.getUsageUsedSeconds()).thenAnswer(
        (_) async => 1200,
      );
      when(() => preferences.setUsageLimitMinutes(any())).thenAnswer(
        (_) async => true,
      );
      when(() => preferences.setUsageUsedSeconds(any())).thenAnswer(
        (_) async => true,
      );

      final snapshot = await service.setDailyLimit(null);

      expect(snapshot.dailyLimit, isNull);
      verify(() => preferences.setUsageLimitMinutes(null)).called(1);
      verify(() => preferences.setUsageUsedSeconds(0)).called(1);
    });
  });

  group('UsageLimitSnapshot', () {
    test('reports remaining time correctly', () {
      const snapshot = UsageLimitSnapshot(
        dailyLimit: Duration(minutes: 60),
        usedToday: Duration(minutes: 15),
        lastReset: DateTime(2024, 1, 1),
      );

      expect(snapshot.remaining, equals(const Duration(minutes: 45)));
      expect(snapshot.isBlocked, isFalse);
    });

    test('caps remaining at zero when limit exceeded', () {
      const snapshot = UsageLimitSnapshot(
        dailyLimit: Duration(minutes: 30),
        usedToday: Duration(minutes: 45),
        lastReset: DateTime(2024, 1, 1),
      );

      expect(snapshot.remaining, equals(Duration.zero));
      expect(snapshot.isBlocked, isTrue);
    });
  });
}
