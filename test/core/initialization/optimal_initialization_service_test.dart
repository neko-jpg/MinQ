import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/initialization/optimal_initialization_service.dart';
import 'package:minq/data/providers.dart';

void main() {
  group('OptimalInitializationService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // 必要なプロバイダーをモック
          firebaseAvailabilityProvider.overrideWithValue(false),
          dummyDataModeProvider.overrideWith((ref) => false),
          notificationPermissionProvider.overrideWith((ref) => true),
          timeDriftDetectedProvider.overrideWith((ref) => false),
          initializationErrorProvider.overrideWith((ref) => null),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('completes initialization within target time', () async {
      final stopwatch = Stopwatch()..start();
      
      try {
        await OptimalInitializationService.initializeApp(container);
      } catch (e) {
        // エラーが発生してもテストを続行
      }
      
      stopwatch.stop();
      
      // 1.5秒以上2.5秒以内で完了することを確認
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1500));
      expect(stopwatch.elapsedMilliseconds, lessThan(2500));
    });

    test('handles initialization errors gracefully', () async {
      // エラーを発生させるプロバイダーをオーバーライド
      final errorContainer = ProviderContainer(
        overrides: [
          firebaseAvailabilityProvider.overrideWithValue(false),
          localPreferencesServiceProvider.overrideWith((ref) {
            throw Exception('Test error');
          }),
        ],
      );

      expect(
        () => OptimalInitializationService.initializeApp(errorContainer),
        throwsException,
      );

      errorContainer.dispose();
    });

    test('optimized startup provider works correctly', () async {
      final result = container.read(optimizedAppStartupProvider);
      
      expect(result, isA<AsyncValue<void>>());
      
      // 初期状態はローディング
      expect(result.isLoading, isTrue);
    });

    test('deferred initialization does not block startup', () async {
      final stopwatch = Stopwatch()..start();
      
      // 重要な初期化のみをテスト
      await OptimalInitializationService.initializeApp(container);
      
      stopwatch.stop();
      
      // 遅延初期化により、メイン初期化は高速に完了
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });
}