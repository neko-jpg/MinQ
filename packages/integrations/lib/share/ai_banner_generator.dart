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

    img.fill(canvas, palette.background);

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
    img.gaussianBlur(overlay, 12);
    img.drawImage(canvas, overlay, dstBlend: img.BlendMode.plus);
  }

  void _paintBlobs(_ImageLike canvas, _Palette palette, Random rng) {
    const blobCount = 4;
    for (var i = 0; i < blobCount; i++) {
      final radius = (canvas.width * 0.15 + rng.nextDouble() * canvas.width * 0.1).toInt();
      final centerX = rng.nextInt(canvas.width);
      final centerY = rng.nextInt(canvas.height);
      final color = palette.accents[rng.nextInt(palette.accents.length)];
      img.drawCircle(canvas, centerX, centerY, radius, color,
          thickness: -1, blend: img.BlendMode.overlay,);
    }
  }

  void _drawText(_ImageLike canvas, String title, String subtitle, _Palette palette) {
    final boldFont = img.arial_48;
    final regularFont = img.arial_24;

    final titleLines = img.wrapText(boldFont, title, canvas.width - 160);
    var offsetY = 160;
    for (final line in titleLines) {
      img.drawString(canvas, line, font: boldFont, x: 80, y: offsetY, color: palette.onBackground);
      offsetY += boldFont.height + 12;
    }

    final subtitleLines = img.wrapText(regularFont, subtitle, canvas.width - 160);
    offsetY += 24;
    for (final line in subtitleLines) {
      img.drawString(canvas, line, font: regularFont, x: 80, y: offsetY, color: palette.onBackgroundSecondary);
      offsetY += regularFont.height + 8;
    }
  }

  _Palette _generatePalette(Random rng) {
    final backgrounds = [
      _Palette(
        background: img.getColor(20, 28, 33),
        onBackground: img.getColor(240, 245, 250),
        onBackgroundSecondary: img.getColor(205, 213, 220),
        accents: [
          img.getColor(17, 138, 178),
          img.getColor(239, 71, 111),
          img.getColor(255, 209, 102),
          img.getColor(6, 214, 160),
        ],
      ),
      _Palette(
        background: img.getColor(33, 17, 52),
        onBackground: img.getColor(244, 242, 255),
        onBackgroundSecondary: img.getColor(199, 196, 214),
        accents: [
          img.getColor(131, 56, 236),
          img.getColor(58, 134, 255),
          img.getColor(252, 163, 17),
          img.getColor(11, 218, 81),
        ],
      ),
    ];
    return backgrounds[rng.nextInt(backgrounds.length)];
  }

  int _lerpColor(int a, int b, double t) {
    final ar = img.getRed(a);
    final ag = img.getGreen(a);
    final ab = img.getBlue(a);
    final br = img.getRed(b);
    final bg = img.getGreen(b);
    final bb = img.getBlue(b);

    final rr = (ar + ((br - ar) * t)).round();
    final rg = (ag + ((bg - ag) * t)).round();
    final rb = (ab + ((bb - ab) * t)).round();
    return img.getColor(rr, rg, rb);
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

  final int background;
  final int onBackground;
  final int onBackgroundSecondary;
  final List<int> accents;
}
