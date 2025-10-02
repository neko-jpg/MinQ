import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/text_overflow_policy.dart';

void main() {
  group('TextOverflowPolicy', () {
    test('title policy enforces single line ellipsis', () {
      expect(TextOverflowPolicy.titleMaxLines, 1);
      expect(TextOverflowPolicy.title, TextOverflow.ellipsis);
      expect(TextOverflowPolicy.titleSoftWrap, isFalse);
    });

    test('body policy allows wrapping', () {
      expect(TextOverflowPolicy.bodySoftWrap, isTrue);
      expect(TextOverflowPolicy.body, TextOverflow.clip);
      expect(TextOverflowPolicy.bodyMaxLines, isNull);
    });
  });

  testWidgets('StandardText.title applies overflow configuration', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StandardText.title('Hello World'),
        ),
      ),
    );

    final textWidget = tester.widget<Text>(find.text('Hello World'));
    expect(textWidget.maxLines, TextOverflowPolicy.titleMaxLines);
    expect(textWidget.overflow, TextOverflowPolicy.title);
    expect(textWidget.softWrap, TextOverflowPolicy.titleSoftWrap);
  });
}
