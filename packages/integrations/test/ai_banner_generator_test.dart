import 'package:flutter_test/flutter_test.dart';
import 'package:miinq_integrations/share/ai_banner_generator.dart';

void main() {
  test('generates deterministic output for same seed', () async {
    const generator = AIBannerGenerator();
    final first = await generator.generate(
      title: 'Focus Streak',
      subtitle: '7日連続で集中タイムを達成しました',
      seed: 42,
    );
    final second = await generator.generate(
      title: 'Focus Streak',
      subtitle: '7日連続で集中タイムを達成しました',
      seed: 42,
    );

    expect(first, equals(second));
    expect(first, isNotEmpty);
  });
}
