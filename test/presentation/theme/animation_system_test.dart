import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/animation_system.dart';

void main() {
  testWidgets('getDuration respects reduce motion accessibility setting', (tester) async {
    late Duration duration;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              duration = AnimationSystem.getDuration(
                context,
                const Duration(milliseconds: 200),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(duration, Duration.zero);
  });

  testWidgets('syncControllerWithAccessibility stops animation when reduce motion enabled', (tester) async {
    late AnimationController controller;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              controller = AnimationController(
                vsync: tester,
                duration: AnimationSystem.normal,
              )..repeat();

              AnimationSystem.syncControllerWithAccessibility(
                controller,
                context,
                repeat: true,
                repeatDuration: AnimationSystem.normal,
              );

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(controller.isAnimating, isFalse);
    expect(controller.value, 1.0);
    controller.dispose();
  });
}
