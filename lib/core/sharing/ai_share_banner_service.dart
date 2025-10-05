import 'dart:typed_data';

import 'package:miinq_integrations/miinq_integrations.dart';

class AIShareBannerService {
  AIShareBannerService({required AIBannerGenerator generator})
    : _generator = generator;

  final AIBannerGenerator _generator;

  Future<Uint8List> buildBanner({
    required String title,
    required String subtitle,
    int seed = 0,
  }) {
    return _generator.generate(title: title, subtitle: subtitle, seed: seed);
  }
}
