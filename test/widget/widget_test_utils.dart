import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// ウィジェットテストユーティリティ
class WidgetTestUtils {
  /// テスト用のアプリをビルド
  static Widget buildTestApp(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  /// テスト用のアプリ（ルーティング付き）
  static Widget buildTestAppWithRouting({
    required Widget home,
    Map<String, WidgetBuilder>? routes,
  }) {
    return MaterialApp(
      home: home,
      routes: routes ?? {},
    );
  }

  /// ウィジェットを見つける
  static Finder findByText(String text) {
    return find.text(text);
  }

  static Finder findByKey(Key key) {
    return find.byKey(key);
  }

  static Finder findByType<T>() {
    return find.byType(T);
  }

  /// タップする
  static Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// テキストを入力
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// スクロール
  static Future<void> scroll(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pumpAndSettle();
  }

  /// ウィジェットが表示されているかチェック
  static void expectVisible(Finder finder) {
    expect(finder, findsOneWidget);
  }

  /// ウィジェットが表示されていないかチェック
  static void expectNotVisible(Finder finder) {
    expect(finder, findsNothing);
  }

  /// スナップショットテスト
  static Future<void> expectMatchesGolden(
    WidgetTester tester,
    String goldenFile,
  ) async {
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(goldenFile),
    );
  }
}

/// テスト用のモックウィジェット
class MockWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const MockWidget({
    super.key,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text),
    );
  }
}

/// テスト用のモックナビゲーター
class MockNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
  }
}
