import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/presentation/theme/contrast_validator.dart';

void main() {
  group('ContrastValidator', () {
    test('meetsWCAGAA detects accessible color pairs', () {
      const foreground = Colors.black;
      const background = Colors.white;

      expect(ContrastValidator.meetsWCAGAA(foreground, background), isTrue);
      expect(ContrastValidator.meetsWCAGAAA(foreground, background), isTrue);
    });

    test('ensureContrast lightens color on dark background', () {
      const background = Colors.black;
      const lowContrast = Color(0xFF111111);

      final adjusted = ContrastValidator.ensureContrast(
        lowContrast,
        background,
        minContrast: ContrastValidator.wcagAA,
      );

      expect(
        ContrastValidator.meetsWCAGAA(adjusted, background),
        isTrue,
      );
    });

    test('ensureContrast darkens color on light background', () {
      const background = Colors.white;
      const lowContrast = Color(0xFFF2F2F2);

      final adjusted = ContrastValidator.ensureContrast(
        lowContrast,
        background,
        minContrast: ContrastValidator.wcagAA,
      );

      expect(
        ContrastValidator.meetsWCAGAA(adjusted, background),
        isTrue,
      );
    });
  });
}
