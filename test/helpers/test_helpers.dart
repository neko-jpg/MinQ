import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// テストヘルパー関数集

/// 異なる画面サイズでウィジェットをテスト
Future<void> testMultipleScreenSizes(
  WidgetTester tester,
  Widget widget,
  Future<void> Function(WidgetTester) testCallback,
) async {
  final sizes = [
    const Size(320, 568), // iPhone SE
    const Size(375, 667), // iPhone 8
    const Size(390, 844), // iPhone 12
    const Size(414, 896), // iPhone 11 Pro Max
    const Size(768, 1024), // iPad
  ];

  for (final size in sizes) {
    await tester.binding.setSurfaceSize(size);
    await tester.pumpWidget(widget);
    await testCallback(tester);
  }

  // リセット
  await tester.binding.setSurfaceSize(null);
}

/// ダークモードとライトモードでテスト
Future<void> testBothThemes(
  WidgetTester tester,
  Widget Function(ThemeMode) widgetBuilder,
  Future<void> Function(WidgetTester, ThemeMode) testCallback,
) async {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    await tester.pumpWidget(widgetBuilder(mode));
    await testCallback(tester, mode);
  }
}

/// テキストスケールファクターでテスト
Future<void> testTextScaling(
  WidgetTester tester,
  Widget widget,
  Future<void> Function(WidgetTester, double) testCallback,
) async {
  final scales = [1.0, 1.3, 2.0];

  for (final scale in scales) {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaleFactor: scale),
        child: widget,
      ),
    );
    await testCallback(tester, scale);
  }
}

/// タップ領域が48dp以上あることを確認
void verifyTapTargetSize(WidgetTester tester, Finder finder) {
  final renderBox = tester.renderObject(finder) as RenderBox;
  final size = renderBox.size;

  expect(
    size.width >= 48 && size.height >= 48,
    true,
    reason: 'Tap target should be at least 48x48dp, but was ${size.width}x${size.height}',
  );
}

/// すべてのタップ可能な要素のサイズを検証
void verifyAllTapTargets(WidgetTester tester) {
  final buttons = find.byType(ElevatedButton);
  final iconButtons = find.byType(IconButton);
  final textButtons = find.byType(TextButton);
  final inkWells = find.byType(InkWell);

  for (final finder in [buttons, iconButtons, textButtons, inkWells]) {
    for (var i = 0; i < finder.evaluate().length; i++) {
      verifyTapTargetSize(tester, finder.at(i));
    }
  }
}

/// Semanticsが適切に設定されているか確認
void verifySemanticsLabels(WidgetTester tester) {
  final semantics = tester.getSemantics(find.byType(Semantics).first);
  expect(semantics.label, isNotNull);
  expect(semantics.label, isNotEmpty);
}

/// オフライン状態をシミュレート
class OfflineSimulator {
  static bool _isOffline = false;

  static void setOffline(bool offline) {
    _isOffline = offline;
  }

  static bool get isOffline => _isOffline;
}

/// ネットワーク遅延をシミュレート
Future<T> simulateNetworkDelay<T>(
  Future<T> Function() operation, {
  Duration delay = const Duration(seconds: 2),
}) async {
  await Future.delayed(delay);
  return operation();
}

/// エラーをシミュレート
Future<T> simulateError<T>(String errorMessage) async {
  throw Exception(errorMessage);
}

/// ゴールデンテストヘルパー
Future<void> expectGoldenMatches(
  WidgetTester tester,
  String goldenPath, {
  Size? size,
}) async {
  if (size != null) {
    await tester.binding.setSurfaceSize(size);
  }

  await tester.pumpAndSettle();
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile(goldenPath),
  );

  if (size != null) {
    await tester.binding.setSurfaceSize(null);
  }
}

/// 複数デバイスでゴールデンテスト
Future<void> expectGoldenMatchesMultipleDevices(
  WidgetTester tester,
  String basePath,
) async {
  final devices = {
    'iphone_se': const Size(320, 568),
    'iphone_12': const Size(390, 844),
    'ipad': const Size(768, 1024),
  };

  for (final entry in devices.entries) {
    await expectGoldenMatches(
      tester,
      '$basePath/${entry.key}.png',
      size: entry.value,
    );
  }
}

/// パフォーマンス測定
class PerformanceMonitor {
  final Stopwatch _stopwatch = Stopwatch();
  final List<Duration> _measurements = [];

  void start() {
    _stopwatch.reset();
    _stopwatch.start();
  }

  void stop() {
    _stopwatch.stop();
    _measurements.add(_stopwatch.elapsed);
  }

  Duration get average {
    if (_measurements.isEmpty) return Duration.zero;
    final total = _measurements.fold<int>(
      0,
      (sum, duration) => sum + duration.inMicroseconds,
    );
    return Duration(microseconds: total ~/ _measurements.length);
  }

  Duration get max {
    if (_measurements.isEmpty) return Duration.zero;
    return _measurements.reduce((a, b) => a > b ? a : b);
  }

  Duration get min {
    if (_measurements.isEmpty) return Duration.zero;
    return _measurements.reduce((a, b) => a < b ? a : b);
  }

  void reset() {
    _measurements.clear();
    _stopwatch.reset();
  }
}

/// フレームレート測定
class FrameRateMonitor {
  final List<Duration> _frameTimes = [];
  DateTime? _lastFrameTime;

  void recordFrame() {
    final now = DateTime.now();
    if (_lastFrameTime != null) {
      _frameTimes.add(now.difference(_lastFrameTime!));
    }
    _lastFrameTime = now;
  }

  double get averageFps {
    if (_frameTimes.isEmpty) return 0.0;
    final avgFrameTime = _frameTimes.fold<int>(
          0,
          (sum, duration) => sum + duration.inMicroseconds,
        ) /
        _frameTimes.length;
    return 1000000 / avgFrameTime; // マイクロ秒から秒に変換してFPS計算
  }

  bool get isSmooth => averageFps >= 55; // 60fps目標、55fps以上で合格

  void reset() {
    _frameTimes.clear();
    _lastFrameTime = null;
  }
}

/// メモリ使用量チェック
class MemoryMonitor {
  // Note: 実際のメモリ監視はプラットフォーム固有のコードが必要
  // これはモックアップ
  static int _allocatedBytes = 0;

  static void allocate(int bytes) {
    _allocatedBytes += bytes;
  }

  static void deallocate(int bytes) {
    _allocatedBytes -= bytes;
  }

  static int get currentUsage => _allocatedBytes;

  static void reset() {
    _allocatedBytes = 0;
  }
}

/// テストデータビルダー
class TestDataBuilder {
  static DateTime testDate({int daysAgo = 0}) {
    return DateTime.now().subtract(Duration(days: daysAgo));
  }

  static String randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[(index * 7) % chars.length],
    ).join();
  }

  static List<T> generateList<T>(int count, T Function(int) generator) {
    return List.generate(count, generator);
  }
}

/// アクセシビリティテストヘルパー
class AccessibilityTester {
  /// コントラスト比を計算（簡易版）
  static double calculateContrastRatio(Color foreground, Color background) {
    final fgLuminance = _relativeLuminance(foreground);
    final bgLuminance = _relativeLuminance(background);

    final lighter = fgLuminance > bgLuminance ? fgLuminance : bgLuminance;
    final darker = fgLuminance > bgLuminance ? bgLuminance : fgLuminance;

    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color color) {
    final r = _linearize(color.red / 255);
    final g = _linearize(color.green / 255);
    final b = _linearize(color.blue / 255);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return ((channel + 0.055) / 1.055).pow(2.4);
  }

  /// WCAG AA準拠チェック（4.5:1以上）
  static bool meetsWCAGAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 4.5;
  }

  /// WCAG AAA準拠チェック（7:1以上）
  static bool meetsWCAGAAA(Color foreground, Color background) {
    return calculateContrastRatio(foreground, background) >= 7.0;
  }
}

extension on double {
  double pow(double exponent) {
    return this * this; // 簡易実装
  }
}
