import 'package:mocktail/mocktail.dart';
import 'package:minq/data/services/usage_limit_service.dart';
import 'package:minq/presentation/controllers/usage_limit_controller.dart';
import 'package:test/test.dart';

class MockUsageLimitService extends Mock implements UsageLimitService {}

void main() {
  setUpAll(() {
    registerFallbackValue(const UsageLimitSnapshot(
      dailyLimit: Duration(minutes: 10),
      usedToday: Duration.zero,
      lastReset: DateTime(2024, 1, 1),
    ));
  });

  group('UsageLimitController', () {
    late MockUsageLimitService service;
    late UsageLimitSnapshot snapshot;

    setUp(() {
      service = MockUsageLimitService();
      snapshot = const UsageLimitSnapshot(
        dailyLimit: Duration(minutes: 50),
        usedToday: Duration(minutes: 15),
        lastReset: DateTime(2024, 1, 1),
      );
    });

    test('loads snapshot on initialization', () async {
      when(() => service.loadSnapshot()).thenAnswer((_) async => snapshot);

      final controller = UsageLimitController(service);
      await Future<void>.delayed(Duration.zero);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.snapshot, equals(snapshot));
      verify(() => service.loadSnapshot()).called(1);
    });

    test('setDailyLimit transitions through loading state', () async {
      when(() => service.loadSnapshot()).thenAnswer((_) async => snapshot);
      final controller = UsageLimitController(service);
      await Future<void>.delayed(Duration.zero);

      final updatedSnapshot = snapshot.copyWith(usedToday: const Duration(minutes: 20));
      when(() => service.setDailyLimit(const Duration(minutes: 45)))
          .thenAnswer((_) async => updatedSnapshot);

      final future = controller.setDailyLimit(const Duration(minutes: 45));
      expect(controller.state.isLoading, isTrue);

      await future;
      expect(controller.state.snapshot, equals(updatedSnapshot));
      expect(controller.state.isLoading, isFalse);
    });

    test('recordUsage replaces state with updated snapshot', () async {
      when(() => service.loadSnapshot()).thenAnswer((_) async => snapshot);
      final controller = UsageLimitController(service);
      await Future<void>.delayed(Duration.zero);

      final updatedSnapshot = snapshot.copyWith(usedToday: const Duration(minutes: 40));
      when(() => service.recordUsage(const Duration(minutes: 25)))
          .thenAnswer((_) async => updatedSnapshot);

      await controller.recordUsage(const Duration(minutes: 25));

      expect(controller.state.snapshot, equals(updatedSnapshot));
    });
  });
}
