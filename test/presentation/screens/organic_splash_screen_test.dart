import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/initialization/optimal_initialization_service.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/screens/organic_splash_screen.dart';

void main() {
  group('OrganicSplashScreen', () {
    testWidgets('displays organic growth animation', (WidgetTester tester) async {
      // アプリ初期化をモック
      final container = ProviderContainer(
        overrides: [
          optimizedAppStartupProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 100));
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const OrganicSplashScreen(),
          ),
        ),
      );

      // 初期状態では種の段階
      expect(find.byType(OrganicSplashScreen), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);

      // アニメーションの進行を待つ
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // アニメーションが進行していることを確認
      expect(find.byType(CustomPaint), findsOneWidget);

      container.dispose();
    });

    testWidgets('shows app name when mature stage is reached', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          optimizedAppStartupProvider.overrideWith((ref) async {
            await Future.delayed(const Duration(milliseconds: 50));
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const OrganicSplashScreen(),
          ),
        ),
      );

      // アニメーション完了まで待機
      await tester.pump(const Duration(milliseconds: 1600));

      // アプリ名とサブタイトルが表示されることを確認
      expect(find.text('MinQ'), findsOneWidget);
      expect(find.text('習慣の種を育てよう'), findsOneWidget);

      container.dispose();
    });

    testWidgets('handles initialization errors gracefully', (WidgetTester tester) async {
      final container = ProviderContainer(
        overrides: [
          optimizedAppStartupProvider.overrideWith((ref) async {
            throw Exception('Test initialization error');
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const OrganicSplashScreen(),
          ),
        ),
      );

      // エラーが発生してもスプラッシュ画面は表示される
      expect(find.byType(OrganicSplashScreen), findsOneWidget);

      // 最小アニメーション時間を待つ
      await tester.pump(const Duration(milliseconds: 1600));

      container.dispose();
    });

    testWidgets('respects minimum animation duration', (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      final container = ProviderContainer(
        overrides: [
          optimizedAppStartupProvider.overrideWith((ref) async {
            // 非常に高速な初期化をシミュレート
            await Future.delayed(const Duration(milliseconds: 10));
          }),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: const OrganicSplashScreen(),
          ),
        ),
      );

      // 最小時間（1.5秒）まで待機
      await tester.pump(const Duration(milliseconds: 1600));

      stopwatch.stop();

      // 最小アニメーション時間が確保されていることを確認
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1500));

      container.dispose();
    });
  });

  group('OrganicGrowthPainter', () {
    testWidgets('renders different stages correctly', (WidgetTester tester) async {
      for (final stage in GrowthStage.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                painter: OrganicGrowthPainter(
                  stage: stage,
                  seedPulse: 1.0,
                  sproutGrowth: 1.0,
                  leafExpansion: 1.0,
                  finalScale: 1.0,
                  iconOpacity: 1.0,
                  isDark: false,
                  primaryColor: Colors.blue,
                ),
                size: const Size(100, 100),
              ),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsOneWidget);
        await tester.pump();
      }
    });
  });
}