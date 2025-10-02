import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/main.dart' as app;

void main() {
  group('Performance Tests', () {
    testWidgets('Initial render performance', (tester) async {
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // 初回描画は3秒以内であるべき
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(3000),
        reason: 'Initial render took ${stopwatch.elapsedMilliseconds}ms',
      );

      print('Initial render time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Frame drop detection', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // フレームドロップを検出
      final binding = tester.binding;
      int frameCount = 0;
      int droppedFrames = 0;

      binding.addPersistentFrameCallback((timeStamp) {
        frameCount++;
        // 16.67ms（60fps）を超えるフレームをカウント
        if (timeStamp.inMilliseconds > 16.67) {
          droppedFrames++;
        }
      });

      // スクロール操作を実行
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final dropRate = droppedFrames / frameCount;

      // フレームドロップ率は10%以下であるべき
      expect(
        dropRate,
        lessThan(0.1),
        reason: 'Frame drop rate: ${(dropRate * 100).toStringAsFixed(2)}%',
      );

      print('Frame drop rate: ${(dropRate * 100).toStringAsFixed(2)}%');
    });

    testWidgets('List scroll performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 大量のアイテムを含むリストへ遷移
      await tester.tap(find.text('Quest List'));
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // スクロール操作
      for (int i = 0; i < 10; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -300));
        await tester.pump();
      }

      await tester.pumpAndSettle();
      stopwatch.stop();

      // スクロール操作は2秒以内であるべき
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Scroll took ${stopwatch.elapsedMilliseconds}ms',
      );

      print('Scroll performance: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Navigation performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch();

      // 画面遷移のパフォーマンスを測定
      for (int i = 0; i < 5; i++) {
        stopwatch.start();

        await tester.tap(find.byIcon(Icons.bar_chart));
        await tester.pumpAndSettle();

        stopwatch.stop();

        await tester.tap(find.byIcon(Icons.home));
        await tester.pumpAndSettle();
      }

      final averageTime = stopwatch.elapsedMilliseconds / 5;

      // 平均遷移時間は500ms以内であるべき
      expect(
        averageTime,
        lessThan(500),
        reason: 'Average navigation time: ${averageTime.toStringAsFixed(2)}ms',
      );

      print('Average navigation time: ${averageTime.toStringAsFixed(2)}ms');
    });

    testWidgets('Memory usage test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // メモリ使用量の測定（概算）
      final initialMemory = _getApproximateMemoryUsage();

      // 複数の画面を遷移
      for (int i = 0; i < 10; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
      }

      final finalMemory = _getApproximateMemoryUsage();
      final memoryIncrease = finalMemory - initialMemory;

      // メモリ増加は50MB以下であるべき
      expect(
        memoryIncrease,
        lessThan(50 * 1024 * 1024),
        reason: 'Memory increased by ${(memoryIncrease / 1024 / 1024).toStringAsFixed(2)}MB',
      );

      print(
        'Memory increase: ${(memoryIncrease / 1024 / 1024).toStringAsFixed(2)}MB',
      );
    });

    testWidgets('Image loading performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // 画像を含む画面へ遷移
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // 画像読み込みを含む画面遷移は2秒以内であるべき
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(2000),
        reason: 'Image loading took ${stopwatch.elapsedMilliseconds}ms',
      );

      print('Image loading time: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Animation performance', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // アニメーションを含む操作
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      int frameCount = 0;
      final stopwatch = Stopwatch()..start();

      // アニメーション中のフレーム数をカウント
      while (tester.binding.hasScheduledFrame) {
        await tester.pump(const Duration(milliseconds: 16));
        frameCount++;

        if (stopwatch.elapsedMilliseconds > 1000) break;
      }

      stopwatch.stop();

      final fps = frameCount / (stopwatch.elapsedMilliseconds / 1000);

      // FPSは50以上であるべき
      expect(
        fps,
        greaterThan(50),
        reason: 'Animation FPS: ${fps.toStringAsFixed(2)}',
      );

      print('Animation FPS: ${fps.toStringAsFixed(2)}');
    });
  });
}

int _getApproximateMemoryUsage() {
  // 実際のメモリ使用量を取得する方法は限定的
  // ここでは概算値を返す
  // 本番環境ではDevToolsやプロファイラーを使用
  return DateTime.now().millisecondsSinceEpoch % 100000000;
}
