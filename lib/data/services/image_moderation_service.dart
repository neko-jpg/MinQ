import 'dart:math';

import 'package:image/image.dart' as img;

enum PhotoModerationVerdict { ok, tooDark, tooBright, lowVariance }

class ImageModerationService {
  const ImageModerationService({
    this.sampleStride = 8,
    this.brightThreshold = 0.82,
    this.darkThreshold = 0.18,
    this.lowVarianceThreshold = 0.004,
  });

  final int sampleStride;
  final double brightThreshold;
  final double darkThreshold;
  final double lowVarianceThreshold;

  PhotoModerationVerdict evaluate(img.Image image) {
    if (image.width == 0 || image.height == 0) {
      return PhotoModerationVerdict.ok;
    }

    var bright = 0;
    var dark = 0;
    var samples = 0;

    var mean = 0.0;
    var m2 = 0.0;

    for (var y = 0; y < image.height; y += max(1, sampleStride)) {
      for (var x = 0; x < image.width; x += max(1, sampleStride)) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel) / 255.0;
        samples += 1;
        if (luminance >= brightThreshold) {
          bright += 1;
        }
        if (luminance <= darkThreshold) {
          dark += 1;
        }
        final delta = luminance - mean;
        mean += delta / samples;
        final delta2 = luminance - mean;
        m2 += delta * delta2;
      }
    }

    final ratioBright = bright / samples;
    final ratioDark = dark / samples;
    final variance = samples > 1 ? m2 / (samples - 1) : 0.0;

    if (ratioBright > 0.65) {
      return PhotoModerationVerdict.tooBright;
    }
    if (ratioDark > 0.65) {
      return PhotoModerationVerdict.tooDark;
    }
    if (variance < lowVarianceThreshold) {
      return PhotoModerationVerdict.lowVariance;
    }
    return PhotoModerationVerdict.ok;
  }
}
