import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:minq/presentation/routing/navigation_extensions.dart';

class _RecordingNavigatorObserver extends NavigatorObserver {
  bool didPopCalled = false;
  bool didPushCalled = false;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    didPopCalled = true;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    didPushCalled = true;
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({required this.onNavigate, super.key});

  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: onNavigate,
          child: const Text('Go to detail'),
        ),
      ),
    );
  }
}

class _DetailPage extends StatelessWidget {
  const _DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.safePop(),
          child: const Text('Back'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('safePop pops when there is a back stack', (tester) async {
    final observer = _RecordingNavigatorObserver();
    late final GoRouter router;
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) =>
                  _HomePage(onNavigate: () => context.push('/detail')),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) => const _DetailPage(),
        ),
      ],
      observers: [observer],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Go to detail'));
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Go to detail'), findsOneWidget);
    expect(observer.didPopCalled, isTrue);
  });

  testWidgets('safePop falls back to go when nothing can be popped', (
    tester,
  ) async {
    final observer = _RecordingNavigatorObserver();
    final router = GoRouter(
      initialLocation: '/detail',
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) =>
                  _HomePage(onNavigate: () => context.push('/detail')),
        ),
        GoRoute(
          path: '/detail',
          builder: (context, state) => const _DetailPage(),
        ),
      ],
      observers: [observer],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Back'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(find.text('Go to detail'), findsOneWidget);
    expect(observer.didPopCalled, isFalse);
    expect(observer.didPushCalled, isTrue);
  });
}
