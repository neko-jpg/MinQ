import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:minq/core/logging/app_logger.dart';
import 'package:path_provider/path_provider.dart';

/// OGP画像生成サービス
/// クエスト達成バナーをSNSシェア用の画像として生成
class OgpImageGenerator {
  OgpImageGenerator();

  /// クエスト達成バナーを生成
  Future<File?> generateAchievementBanner({
    required String questTitle,
    required int currentStreak,
    required int totalCompleted,
  }) async {
    try {
      // ウィジェットをレンダリング
      final widget = _AchievementBannerWidget(
        questTitle: questTitle,
        currentStreak: currentStreak,
        totalCompleted: totalCompleted,
      );

      final image = await _widgetToImage(widget);
      if (image == null) return null;

      // 一時ファイルに保存
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/achievement_banner_${DateTime.now().millisecondsSinceEpoch}.png');
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      AppLogger.info('OGP image generated: ${file.path}');
      return file;
    } catch (e, stack) {
      AppLogger.error('Failed to generate OGP image', error: e, stackTrace: stack);
      return null;
    }
  }

  /// ウィジェットを画像に変換
  Future<ui.Image?> _widgetToImage(Widget widget) async {
    final repaintBoundary = RenderRepaintBoundary();
    
    final view = ui.PlatformDispatcher.instance.views.first;
    const logicalSize = Size(1200, 630); // OGP標準サイズ
    final devicePixelRatio = view.devicePixelRatio;

    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(logicalSize),
        devicePixelRatio: devicePixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: widget,
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final image = await repaintBoundary.toImage(pixelRatio: devicePixelRatio);
    return image;
  }
}

/// 達成バナーウィジェット（OGP画像用）
class _AchievementBannerWidget extends StatelessWidget {
  final String questTitle;
  final int currentStreak;
  final int totalCompleted;

  const _AchievementBannerWidget({
    required this.questTitle,
    required this.currentStreak,
    required this.totalCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1200,
      height: 630,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6366F1),
            Color(0xFF8B5CF6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 背景パターン
          Positioned.fill(
            child: CustomPaint(
              painter: _BackgroundPatternPainter(),
            ),
          ),
          // コンテンツ
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // アイコン
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // タイトル
                Text(
                  'クエスト達成！',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // クエスト名
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                    questTitle,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 2,
                          color: Colors.black.withOpacity(0.2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 40),
                // 統計情報
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StatBadge(
                      icon: Icons.local_fire_department,
                      label: '連続',
                      value: '$currentStreak日',
                    ),
                    const SizedBox(width: 40),
                    _StatBadge(
                      icon: Icons.emoji_events,
                      label: '達成',
                      value: '$totalCompleted回',
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                // アプリ名
                Text(
                  'MinQ - 3分で続く習慣化アプリ',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 統計バッジ
class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/// 背景パターンペインター
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const spacing = 60.0;
    
    // 縦線
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 横線
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
