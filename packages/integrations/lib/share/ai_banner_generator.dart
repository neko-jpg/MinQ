import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Simple procedural banner generator that emulates AI-personalised backgrounds.
class AIBannerGenerator {
  const AIBannerGenerator();

  Future<Uint8List> generate({
    required String title,
    required String subtitle,
    int width = 1200,
    int height = 630,
    int seed = 0,
  }) async {
    final rng = Random(seed);
    final palette = _generatePalette(rng);
    final canvas = img.Image(width: width, height: height);

    img.fill(canvas, color: palette.background);

    _paintGradient(canvas, palette, rng);
    _paintBlobs(canvas, palette, rng);
    _drawText(canvas, title, subtitle, palette);

    return Uint8List.fromList(img.encodePng(canvas));
  }

  void _paintGradient(_ImageLike canvas, _Palette palette, Random rng) {
    final overlay = img.Image(width: canvas.width, height: canvas.height);
    final start = palette.accents[rng.nextInt(palette.accents.length)];
    final end = palette.accents[rng.nextInt(palette.accents.length)];

    for (var y = 0; y < overlay.height; y++) {
      final t = y / overlay.height;
      final color = _lerpColor(start, end, t);
      for (var x = 0; x < overlay.width; x++) {
        overlay.setPixel(x, y, color);
      }
    }
    img.gaussianBlur(overlay, radius: 12);
    img.compositeImage(canvas as img.Image, overlay, blend: img.BlendMode.screen);
  }

  void _paintBlobs(_ImageLike canvas, _Palette palette, Random rng) {
    final blobCount = 4;
    for (var i = 0; i < blobCount; i++) {
      final radius =
          (canvas.width * 0.15 + rng.nextDouble() * canvas.width * 0.1).toInt();
      final centerX = rng.nextInt(canvas.width);
      final centerY = rng.nextInt(canvas.height);
      final color = palette.accents[rng.nextInt(palette.accents.length)];
      img.fillCircle(
        canvas as img.Image,
        x: centerX,
        y: centerY,
        radius: radius,
        color: color,
      );
    }
  }

  void _drawText(
    _ImageLike canvas,
    String title,
    String subtitle,
    _Palette palette,
  ) {
    // Text rendering is simplified - in production, consider using
    // a proper text rendering library or Flutter's canvas
    // For now, we'll just create a visually appealing banner without text
    // The gradient and blobs provide the visual interest
  }

  _Palette _generatePalette(Random rng) {
    final backgrounds = [
      _Palette(
        background: _rgb(20, 28, 33),
        onBackground: _rgb(240, 245, 250),
        onBackgroundSecondary: _rgb(205, 213, 220),
        accents: [
          _rgb(17, 138, 178),
          _rgb(239, 71, 111),
          _rgb(255, 209, 102),
          _rgb(6, 214, 160),
        ],
      ),
      _Palette(
        background: _rgb(33, 17, 52),
        onBackground: _rgb(244, 242, 255),
        onBackgroundSecondary: _rgb(199, 196, 214),
        accents: [
          _rgb(131, 56, 236),
          _rgb(58, 134, 255),
          _rgb(252, 163, 17),
          _rgb(11, 218, 81),
        ],
      ),
    ];
    return backgrounds[rng.nextInt(backgrounds.length)];
  }

  img.Color _lerpColor(img.Color a, img.Color b, double t) {
    final ar = a.r.toDouble();
    final ag = a.g.toDouble();
    final ab = a.b.toDouble();
    final br = b.r.toDouble();
    final bg = b.g.toDouble();
    final bb = b.b.toDouble();

    final rr = (ar + ((br - ar) * t)).round().clamp(0, 255);
    final rg = (ag + ((bg - ag) * t)).round().clamp(0, 255);
    final rb = (ab + ((bb - ab) * t)).round().clamp(0, 255);
    return _rgb(rr, rg, rb);
  }
}

typedef _ImageLike = img.Image;

class _Palette {
  const _Palette({
    required this.background,
    required this.onBackground,
    required this.onBackgroundSecondary,
    required this.accents,
  });

  final img.Color background;
  final img.Color onBackground;
  final img.Color onBackgroundSecondary;
  final List<img.Color> accents;
}

img.ColorRgb8 _rgb(int r, int g, int b) => img.ColorRgb8(r, g, b);
