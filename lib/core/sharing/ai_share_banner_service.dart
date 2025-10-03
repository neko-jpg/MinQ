import 'dart:typed_data';

// TODO: Fix integrations package
// import 'package:miinq_integrations/miinq_integrations.dart';

// Dummy type until integrations package is fixed
import 'dart:typed_data';

class AIBannerGenerator {
  const AIBannerGenerator();
  Future<Uint8List> generate({required String title, required String subtitle, int seed = 0}) async => Uint8List(0);
}

class AIShareBannerService {
  AIShareBannerService({required AIBannerGenerator generator})
      : _generator = generator;

  final AIBannerGenerator _generator;

  Future<Uint8List> buildBanner({
    required String title,
    required String subtitle,
    int seed = 0,
  }) {
    return _generator.generate(
      title: title,
      subtitle: subtitle,
      seed: seed,
    );
  }
}
