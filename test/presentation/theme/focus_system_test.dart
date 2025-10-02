import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/app_theme.dart';
import 'package:minq/presentation/theme/focus_system.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

void main() {
  testWidgets('resolveFocusColor defaults to brand primary', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: Builder(
          builder: (context) {
            final color = FocusSystem.resolveFocusColor(context);
            expect(color, MinqTheme.of(context).brandPrimary);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  });

  testWidgets('resolveFocusColor returns accessible color in high contrast', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(highContrast: true),
          child: Builder(
            builder: (context) {
              final color = FocusSystem.resolveFocusColor(context);
              final tokens = MinqTheme.of(context);
              expect(color, tokens.getAccessibleTextColor(context));
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });
}
