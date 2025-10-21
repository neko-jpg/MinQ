import 'package:flutter/material.dart';

/// Elevationシステム - 影と深度の定義
/// Material Design 3に準拠した影のレベル
class ElevationSystem {
  const ElevationSystem._();

  // ========================================
  // Elevation レベル
  // ========================================

  /// Level 0 - 影なし（フラット）
  static const double level0 = 0.0;

  /// Level 1 - 最小の影（カード、チップ）
  static const double level1 = 1.0;

  /// Level 2 - 小さな影（ボタン、FAB）
  static const double level2 = 2.0;

  /// Level 3 - 中程度の影（ダイアログ、メニュー）
  static const double level3 = 3.0;

  /// Level 4 - 大きな影（ナビゲーションドロワー）
  static const double level4 = 4.0;

  /// Level 5 - 最大の影（モーダル、ボトムシート）
  static const double level5 = 5.0;

  // ========================================
  // BoxShadow 定義
  // ========================================

  /// 影なし
  static const List<BoxShadow> none = [];

  /// 極小の影 - ホバー状態
  static const List<BoxShadow> minimal = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// 小さな影 - カード、チップ
  static const List<BoxShadow> small = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  /// 中程度の影 - ボタン、FAB
  static const List<BoxShadow> medium = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  /// 大きな影 - ダイアログ、メニュー
  static const List<BoxShadow> large = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 18, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  /// 特大の影 - ナビゲーションドロワー
  static const List<BoxShadow> extraLarge = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  /// 最大の影 - モーダル、ボトムシート
  static const List<BoxShadow> maximum = [
    BoxShadow(color: Color(0x24000000), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  // ========================================
  // ダークモード用の影
  // ========================================

  /// ダークモード - 小さな影
  static const List<BoxShadow> darkSmall = [
    BoxShadow(color: Color(0x33000000), blurRadius: 10, offset: Offset(0, 3)),
  ];

  /// ダークモード - 中程度の影
  static const List<BoxShadow> darkMedium = [
    BoxShadow(color: Color(0x3D000000), blurRadius: 16, offset: Offset(0, 6)),
  ];

  /// ダークモード - 大きな影
  static const List<BoxShadow> darkLarge = [
    BoxShadow(color: Color(0x47000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  // ========================================
  // セマンティックな影
  // ========================================

  /// カード用の影
  static const List<BoxShadow> card = small;

  /// ボタン用の影
  static const List<BoxShadow> button = medium;

  /// ダイアログ用の影
  static const List<BoxShadow> dialog = large;

  /// メニュー用の影
  static const List<BoxShadow> menu = large;

  /// ボトムシート用の影
  static const List<BoxShadow> bottomSheet = maximum;

  /// FAB用の影
  static const List<BoxShadow> fab = medium;

  /// AppBar用の影
  static const List<BoxShadow> appBar = minimal;

  // ========================================
  // カラー付き影（アクセント）
  // ========================================

  /// プライマリカラーの影
  static List<BoxShadow> primaryGlow(Color primaryColor) => [
    BoxShadow(
      color: primaryColor.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// 成功カラーの影
  static List<BoxShadow> successGlow(Color successColor) => [
    BoxShadow(
      color: successColor.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// エラーカラーの影
  static List<BoxShadow> errorGlow(Color errorColor) => [
    BoxShadow(
      color: errorColor.withOpacity(0.3),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ========================================
  // インナーシャドウ（疑似）
  // ========================================

  /// インナーシャドウ効果（Containerの内側に配置）
  static BoxDecoration innerShadow({
    Color color = const Color(0x1A000000),
    double blurRadius = 8,
    Offset offset = const Offset(0, 2),
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.1), Colors.transparent],
        stops: const [0.0, 0.3],
      ),
    );
  }

  // ========================================
  // ヘルパーメソッド
  // ========================================

  /// Brightnessに応じた影を取得
  static List<BoxShadow> getShadow(
    Brightness brightness,
    List<BoxShadow> lightShadow,
    List<BoxShadow> darkShadow,
  ) {
    return brightness == Brightness.light ? lightShadow : darkShadow;
  }

  /// レベルから影を取得
  static List<BoxShadow> fromLevel(int level) {
    switch (level) {
      case 0:
        return none;
      case 1:
        return minimal;
      case 2:
        return small;
      case 3:
        return medium;
      case 4:
        return large;
      case 5:
        return maximum;
      default:
        return medium;
    }
  }
}

/// Borderシステム - 枠線の定義
class BorderSystem {
  const BorderSystem._();

  // ========================================
  // Border Width
  // ========================================

  /// 枠線なし
  static const double none = 0.0;

  /// 極細枠線
  static const double thin = 1.0;

  /// 標準枠線
  static const double regular = 1.5;

  /// 太い枠線
  static const double thick = 2.0;

  /// 特太枠線
  static const double extraThick = 3.0;

  // ========================================
  // Border Radius
  // ========================================

  /// 角丸なし
  static const double radiusNone = 0.0;

  /// 極小角丸
  static const double radiusXS = 4.0;

  /// 小角丸
  static const double radiusSM = 8.0;

  /// 中角丸
  static const double radiusMD = 12.0;

  /// 大角丸
  static const double radiusLG = 16.0;

  /// 特大角丸
  static const double radiusXL = 20.0;

  /// 超特大角丸
  static const double radiusXXL = 28.0;

  /// 完全な円形
  static const double radiusFull = 999.0;

  // ========================================
  // BorderRadius オブジェクト
  // ========================================

  /// 角丸なし
  static const BorderRadius noRadius = BorderRadius.zero;

  /// 極小角丸
  static const BorderRadius roundedXS = BorderRadius.all(
    Radius.circular(radiusXS),
  );

  /// 小角丸
  static const BorderRadius roundedSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );

  /// 中角丸
  static const BorderRadius roundedMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );

  /// 大角丸
  static const BorderRadius roundedLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );

  /// 特大角丸
  static const BorderRadius roundedXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );

  /// 超特大角丸
  static const BorderRadius roundedXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );

  /// 完全な円形
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // ========================================
  // Border オブジェクト
  // ========================================

  /// 標準枠線
  static Border standard(Color color) =>
      Border.all(color: color, width: regular);

  /// 細い枠線
  static Border thinBorder(Color color) =>
      Border.all(color: color, width: thin);

  /// 太い枠線
  static Border thickBorder(Color color) =>
      Border.all(color: color, width: thick);

  /// 下部のみの枠線
  static Border bottomOnly(Color color, {double width = regular}) =>
      Border(bottom: BorderSide(color: color, width: width));

  /// 上部のみの枠線
  static Border topOnly(Color color, {double width = regular}) =>
      Border(top: BorderSide(color: color, width: width));

  /// 左側のみの枠線
  static Border leftOnly(Color color, {double width = regular}) =>
      Border(left: BorderSide(color: color, width: width));

  /// 右側のみの枠線
  static Border rightOnly(Color color, {double width = regular}) =>
      Border(right: BorderSide(color: color, width: width));

  // ========================================
  // セマンティックな枠線
  // ========================================

  /// カード用の枠線
  static Border card(Color color) => thinBorder(color);

  /// ボタン用の枠線
  static Border button(Color color) => standard(color);

  /// 入力フィールド用の枠線
  static Border input(Color color) => standard(color);

  /// フォーカス時の枠線
  static Border focused(Color color) => thickBorder(color);

  /// エラー時の枠線
  static Border error(Color errorColor) => thickBorder(errorColor);

  // ========================================
  // セマンティックな角丸
  // ========================================

  /// カード用の角丸
  static const BorderRadius cardRadius = roundedMD;

  /// ボタン用の角丸
  static const BorderRadius buttonRadius = roundedSM;

  /// 入力フィールド用の角丸
  static const BorderRadius inputRadius = roundedSM;

  /// ダイアログ用の角丸
  static const BorderRadius dialogRadius = roundedLG;

  /// ボトムシート用の角丸（上部のみ）
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(radiusLG),
    topRight: Radius.circular(radiusLG),
  );

  /// チップ用の角丸
  static const BorderRadius chipRadius = roundedFull;

  /// アバター用の角丸
  static const BorderRadius avatarRadius = roundedFull;
}

/// Elevation拡張
extension ElevationExtension on Widget {
  /// 影を追加
  Widget withElevation(
    List<BoxShadow> shadows, {
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: shadows,
      ),
      child: this,
    );
  }

  /// カードの影を追加
  Widget withCardElevation({
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return withElevation(
      ElevationSystem.card,
      borderRadius: borderRadius ?? BorderSystem.cardRadius,
      backgroundColor: backgroundColor,
    );
  }
}

/// Border拡張
extension BorderExtension on Widget {
  /// 枠線を追加
  Widget withBorder(
    Border border, {
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: border,
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }

  /// 角丸を追加
  Widget withRadius(BorderRadius radius, {Color? backgroundColor}) {
    return Container(
      decoration: BoxDecoration(color: backgroundColor, borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: this,
    );
  }
}
