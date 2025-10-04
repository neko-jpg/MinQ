import 'package:flutter/material.dart';

/// スペ�EシングシスチE�� - 4/8pxベ�EスライングリチE��
/// すべての余白とサイズはこ�EシスチE��に従う
class SpacingSystem {
  const SpacingSystem._();

  // ========================================
  // ベ�EスユニッチE
  // ========================================

  /// 基本単佁E 4px
  static const double baseUnit = 4.0;

  /// 8pxグリチE��単佁E
  static const double gridUnit = 8.0;

  // ========================================
  // スペ�Eシングスケール (4pxベ�Eス)
  // ========================================

  /// 0px - なぁE
  static const double none = 0.0;

  /// 2px - 極封E
  static const double xxxs = baseUnit * 0.5;

  /// 4px - 最封E
  static const double xxs = baseUnit * 1;

  /// 6px - 親寁E��間隔
  static const double xs = baseUnit * 1.5;

  /// 8px - 封E
  static const double sm = baseUnit * 2;

  /// 12px - 中封E
  static const double md = baseUnit * 3;

  /// 16px - 中�E�呼吸できる間隔�E�E
  static const double lg = baseUnit * 4;

  /// 20px - 中大
  static const double xl = baseUnit * 5;

  /// 24px - 大
  static const double xxl = baseUnit * 6;

  /// 32px - 敬意ある間隁E
  static const double xxxl = baseUnit * 8;

  /// 40px - 特大
  static const double xxxxl = baseUnit * 10;

  /// 48px - 劁E��な間隔
  static const double xxxxxl = baseUnit * 12;

  /// 64px - 趁E��大
  static const double xxxxxxl = baseUnit * 16;

  // ========================================
  // セマンチE��チE��スペ�Eシング
  // ========================================

  /// 親寁E��間隔 - 関連性の高い要素閁E
  static const double intimate = xs; // 6px

  /// 呼吸できる間隔 - 通常の要素閁E
  static const double breathing = lg; // 16px

  /// 敬意ある間隁E- セクション閁E
  static const double respectful = xxxl; // 32px

  /// 劁E��な間隔 - 大きなセクション閁E
  static const double dramatic = xxxxxl; // 48px

  // ========================================
  // コンポ�Eネント固有�Eスペ�Eシング
  // ========================================

  /// カード�E部のパディング
  static const double cardPadding = lg; // 16px

  /// カード間のマ�Eジン
  static const double cardMargin = md; // 12px

  /// リストアイチE��間�Eスペ�Eス
  static const double listItemSpacing = sm; // 8px

  /// ボタン冁E��のパディング�E�水平�E�E
  static const double buttonPaddingH = xl; // 20px

  /// ボタン冁E��のパディング�E�垂直�E�E
  static const double buttonPaddingV = md; // 12px

  /// アイコンとチE��スト�E間隔
  static const double iconTextGap = sm; // 8px

  /// フォーム要素間�E間隔
  static const double formFieldSpacing = lg; // 16px

  /// セクション間�E間隔
  static const double sectionSpacing = xxxl; // 32px

  /// 画面端のパディング
  static const double screenPadding = lg; // 16px

  /// ダイアログのパディング
  static const double dialogPadding = xxl; // 24px

  /// ボトムシート�Eパディング
  static const double bottomSheetPadding = xxl; // 24px

  // ========================================
  // EdgeInsets ヘルパ�E
  // ========================================

  /// すべての辺に同じスペ�Eス
  static EdgeInsets all(double value) => EdgeInsets.all(value);

  /// 水平方向�Eスペ�Eス
  static EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);

  /// 垂直方向�Eスペ�Eス
  static EdgeInsets vertical(double value) =>
      EdgeInsets.symmetric(vertical: value);

  /// 対称皁E��スペ�Eス
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);

  /// 個別持E��E
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      EdgeInsets.only(left: left, top: top, right: right, bottom: bottom);

  // ========================================
  // 定義済みパディング
  // ========================================

  /// 極小パチE��ング
  static const EdgeInsets paddingXXS = EdgeInsets.all(xxs);

  /// 最小パチE��ング
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);

  /// 小パチE��ング
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);

  /// 中パディング
  static const EdgeInsets paddingMD = EdgeInsets.all(md);

  /// 大パディング
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);

  /// 特大パディング
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  /// 趁E��大パディング
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  /// 画面パディング
  static const EdgeInsets screenPaddingAll = EdgeInsets.all(screenPadding);

  /// カードパチE��ング
  static const EdgeInsets cardPaddingAll = EdgeInsets.all(cardPadding);

  /// ダイアログパディング
  static const EdgeInsets dialogPaddingAll = EdgeInsets.all(dialogPadding);

  // ========================================
  // SizedBox ヘルパ�E
  // ========================================

  /// 水平スペ�Eサー
  static Widget horizontalSpace(double width) => SizedBox(width: width);

  /// 垂直スペ�Eサー
  static Widget verticalSpace(double height) => SizedBox(height: height);

  /// 極小垂直スペ�Eス
  static Widget get vSpaceXXS => verticalSpace(xxs);

  /// 最小垂直スペ�Eス
  static Widget get vSpaceXS => verticalSpace(xs);

  /// 小垂直スペ�Eス
  static Widget get vSpaceSM => verticalSpace(sm);

  /// 中垂直スペ�Eス
  static Widget get vSpaceMD => verticalSpace(md);

  /// 大垂直スペ�Eス
  static Widget get vSpaceLG => verticalSpace(lg);

  /// 特大垂直スペ�Eス
  static Widget get vSpaceXL => verticalSpace(xl);

  /// 趁E��大垂直スペ�Eス
  static Widget get vSpaceXXL => verticalSpace(xxl);

  /// 極小水平スペ�Eス
  static Widget get hSpaceXXS => horizontalSpace(xxs);

  /// 最小水平スペ�Eス
  static Widget get hSpaceXS => horizontalSpace(xs);

  /// 小水平スペ�Eス
  static Widget get hSpaceSM => horizontalSpace(sm);

  /// 中水平スペ�Eス
  static Widget get hSpaceMD => horizontalSpace(md);

  /// 大水平スペ�Eス
  static Widget get hSpaceLG => horizontalSpace(lg);

  /// 特大水平スペ�Eス
  static Widget get hSpaceXL => horizontalSpace(xl);

  /// 趁E��大水平スペ�Eス
  static Widget get hSpaceXXL => horizontalSpace(xxl);

  // ========================================
  // グリチE��アライメント�Eルパ�E
  // ========================================

  /// 値めEpxグリチE��にスナッチE
  static double snapToGrid(double value) {
    return (value / gridUnit).round() * gridUnit;
  }

  /// 値めEpxベ�EスにスナッチE
  static double snapToBase(double value) {
    return (value / baseUnit).round() * baseUnit;
  }

  /// グリチE��単位から実際の値に変換
  static double fromGridUnits(int units) {
    return gridUnit * units;
  }

  /// ベ�Eス単位から実際の値に変換
  static double fromBaseUnits(int units) {
    return baseUnit * units;
  }
}

/// ベ�EスライングリチE��ウィジェチE���E�デバッグ用�E�E
class BaselineGridOverlay extends StatelessWidget {
  final Widget child;
  final bool showGrid;
  final Color gridColor;
  final double gridSize;

  const BaselineGridOverlay({
    super.key,
    required this.child,
    this.showGrid = false,
    this.gridColor = const Color(0x20FF0000),
    this.gridSize = SpacingSystem.gridUnit,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGrid) return child;

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: GridPainter(
                gridColor: gridColor,
                gridSize: gridSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// グリチE��描画
class GridPainter extends CustomPainter {
  final Color gridColor;
  final double gridSize;

  GridPainter({
    required this.gridColor,
    required this.gridSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    // 水平緁E
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // 垂直緁E
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.gridColor != gridColor ||
        oldDelegate.gridSize != gridSize;
  }
}

/// スペ�Eシング拡張
extension SpacingExtension on num {
  /// こ�E数値をスペ�Eシング単位として使用
  double get space => SpacingSystem.baseUnit * this;

  /// こ�E数値をグリチE��単位として使用
  double get grid => SpacingSystem.gridUnit * this;

  /// 垂直スペ�Eス
  Widget get vSpace => SizedBox(height: toDouble());

  /// 水平スペ�Eス
  Widget get hSpace => SizedBox(width: toDouble());
}

/// EdgeInsets拡張
extension EdgeInsetsSpacing on EdgeInsets {
  /// すべての辺をグリチE��にスナッチE
  EdgeInsets snapToGrid() {
    return EdgeInsets.only(
      left: SpacingSystem.snapToGrid(left),
      top: SpacingSystem.snapToGrid(top),
      right: SpacingSystem.snapToGrid(right),
      bottom: SpacingSystem.snapToGrid(bottom),
    );
  }

  /// すべての辺を�EースにスナッチE
  EdgeInsets snapToBase() {
    return EdgeInsets.only(
      left: SpacingSystem.snapToBase(left),
      top: SpacingSystem.snapToBase(top),
      right: SpacingSystem.snapToBase(right),
      bottom: SpacingSystem.snapToBase(bottom),
    );
  }
}

/// レスポンシブスペ�Eシング
class ResponsiveSpacing {
  const ResponsiveSpacing._();

  /// 画面サイズに応じたスペ�Eシングを取征E
  static double getResponsiveSpacing(
    BuildContext context,
    double baseSpacing,
  ) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      // 小型端末 - スペ�Eスを削渁E
      return baseSpacing * 0.75;
    } else if (width > 600) {
      // タブレチE�� - スペ�Eスを増加
      return baseSpacing * 1.25;
    }

    return baseSpacing;
  }

  /// レスポンシブ画面パディング
  static EdgeInsets screenPadding(BuildContext context) {
    final spacing = getResponsiveSpacing(
      context,
      SpacingSystem.screenPadding,
    );
    return EdgeInsets.all(spacing);
  }

  /// レスポンシブカードパチE��ング
  static EdgeInsets cardPadding(BuildContext context) {
    final spacing = getResponsiveSpacing(
      context,
      SpacingSystem.cardPadding,
    );
    return EdgeInsets.all(spacing);
  }

  /// レスポンシブセクションスペ�Eシング
  static double sectionSpacing(BuildContext context) {
    return getResponsiveSpacing(
      context,
      SpacingSystem.sectionSpacing,
    );
  }
}

/// Legacy spacing shim to keep backward compatibility with older layout code.
class AppSpacing {
  const AppSpacing._();

  static const double none = SpacingSystem.none;
  static const double xxxs = SpacingSystem.xxxs;
  static const double xxs = SpacingSystem.xxs;
  static const double xs = SpacingSystem.xs;
  static const double sm = SpacingSystem.sm;
  static const double md = SpacingSystem.md;
  static const double lg = SpacingSystem.lg;
  static const double xl = SpacingSystem.xl;
  static const double xxl = SpacingSystem.xxl;
  static const double xxxl = SpacingSystem.xxxl;
  static const double xxxxl = SpacingSystem.xxxxl;
  static const double xxxxxl = SpacingSystem.xxxxxl;
  static const double xxxxxxl = SpacingSystem.xxxxxxl;

  static const double intimate = SpacingSystem.intimate;
  static const double breathing = SpacingSystem.breathing;
  static const double respectful = SpacingSystem.respectful;
  static const double dramatic = SpacingSystem.dramatic;

  static const double cardPadding = SpacingSystem.cardPadding;
  static const double cardMargin = SpacingSystem.cardMargin;
  static const double listItemSpacing = SpacingSystem.listItemSpacing;
  static const double buttonPaddingH = SpacingSystem.buttonPaddingH;
  static const double buttonPaddingV = SpacingSystem.buttonPaddingV;
  static const double iconTextGap = SpacingSystem.iconTextGap;
  static const double formFieldSpacing = SpacingSystem.formFieldSpacing;
  static const double sectionSpacing = SpacingSystem.sectionSpacing;
  static const double screenPadding = SpacingSystem.screenPadding;
  static const double dialogPadding = SpacingSystem.dialogPadding;
  static const double bottomSheetPadding = SpacingSystem.bottomSheetPadding;

  static EdgeInsets all(double value) => SpacingSystem.all(value);
  static EdgeInsets horizontal(double value) =>
      SpacingSystem.horizontal(value);
  static EdgeInsets vertical(double value) => SpacingSystem.vertical(value);
  static EdgeInsets symmetric({double horizontal = 0, double vertical = 0}) =>
      SpacingSystem.symmetric(horizontal: horizontal, vertical: vertical);
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      SpacingSystem.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      );
}

/// Simple Spacing alias for backward compatibility
class Spacing {
  const Spacing._();

  static const double none = SpacingSystem.none;
  static const double xxxs = SpacingSystem.xxxs;
  static const double xxs = SpacingSystem.xxs;
  static const double xs = SpacingSystem.xs;
  static const double sm = SpacingSystem.sm;
  static const double md = SpacingSystem.md;
  static const double lg = SpacingSystem.lg;
  static const double xl = SpacingSystem.xl;
  static const double xxl = SpacingSystem.xxl;
  static const double xxxl = SpacingSystem.xxxl;
}
