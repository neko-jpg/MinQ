import 'package:flutter/material.dart';

/// ElevationシスチE�� - 影と深度の定義
/// Material Design 3に準拠した影のレベル
class ElevationSystem {
  const ElevationSystem._();

  // ========================================
  // Elevation レベル
  // ========================================

  /// Level 0 - 影なし（フラチE���E�E
  static const double level0 = 0.0;

  /// Level 1 - 最小�E影�E�カード、チチE�E�E�E
  static const double level1 = 1.0;

  /// Level 2 - 小さな影�E��Eタン、FAB�E�E
  static const double level2 = 2.0;

  /// Level 3 - 中程度の影�E�ダイアログ、メニュー�E�E
  static const double level3 = 3.0;

  /// Level 4 - 大きな影�E�ナビゲーションドロワー�E�E
  static const double level4 = 4.0;

  /// Level 5 - 最大の影�E�モーダル、�Eトムシート！E
  static const double level5 = 5.0;

  // ========================================
  // BoxShadow 定義
  // ========================================

  /// 影なぁE
  static const List<BoxShadow> none = [];

  /// 極小�E影 - ホバー状慁E
  static const List<BoxShadow> minimal = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// 小さな影 - カード、チチE�E
  static const List<BoxShadow> small = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// 中程度の影 - ボタン、FAB
  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ];

  /// 大きな影 - ダイアログ、メニュー
  static const List<BoxShadow> large = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// 特大の影 - ナビゲーションドロワー
  static const List<BoxShadow> extraLarge = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  /// 最大の影 - モーダル、�EトムシーチE
  static const List<BoxShadow> maximum = [
    BoxShadow(
      color: Color(0x24000000),
      blurRadius: 32,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // ========================================
  // ダークモード用の影
  // ========================================

  /// ダークモーチE- 小さな影
  static const List<BoxShadow> darkSmall = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  /// ダークモーチE- 中程度の影
  static const List<BoxShadow> darkMedium = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// ダークモーチE- 大きな影
  static const List<BoxShadow> darkLarge = [
    BoxShadow(
      color: Color(0x47000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  // ========================================
  // セマンチE��チE��な影
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
  // カラー付き影�E�アクセント！E
  // ========================================

  /// プライマリカラーの影
  static List<BoxShadow> primaryGlow(Color primaryColor) => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// 成功カラーの影
  static List<BoxShadow> successGlow(Color successColor) => [
        BoxShadow(
          color: successColor.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// エラーカラーの影
  static List<BoxShadow> errorGlow(Color errorColor) => [
        BoxShadow(
          color: errorColor.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // ========================================
  // インナ�Eシャドウ�E�疑似�E�E
  // ========================================

  /// インナ�Eシャドウ効果！Eontainerの冁E�Eに配置�E�E
  static BoxDecoration innerShadow({
    Color color = const Color(0x1A000000),
    double blurRadius = 8,
    Offset offset = const Offset(0, 2),
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3],
      ),
    );
  }

  // ========================================
  // ヘルパ�EメソチE��
  // ========================================

  /// Brightnessに応じた影を取征E
  static List<BoxShadow> getShadow(
    Brightness brightness,
    List<BoxShadow> lightShadow,
    List<BoxShadow> darkShadow,
  ) {
    return brightness == Brightness.light ? lightShadow : darkShadow;
  }

  /// レベルから影を取征E
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

/// BorderシスチE�� - 枠線�E定義
class BorderSystem {
  const BorderSystem._();

  // ========================================
  // Border Width
  // ========================================

  /// 枠線なぁE
  static const double none = 0.0;

  /// 極細枠緁E
  static const double thin = 1.0;

  /// 標準枠緁E
  static const double regular = 1.5;

  /// 太ぁE��緁E
  static const double thick = 2.0;

  /// 特太枠緁E
  static const double extraThick = 3.0;

  // ========================================
  // Border Radius
  // ========================================

  /// 角丸なぁE
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

  /// 趁E��大角丸
  static const double radiusXXL = 28.0;

  /// 完�Eな冁E��
  static const double radiusFull = 999.0;

  // ========================================
  // BorderRadius オブジェクチE
  // ========================================

  /// 角丸なぁE
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

  /// 趁E��大角丸
  static const BorderRadius roundedXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );

  /// 完�Eな冁E��
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // ========================================
  // Border オブジェクチE
  // ========================================

  /// 標準枠緁E
  static Border standard(Color color) => Border.all(
        color: color,
        width: regular,
      );

  /// 細ぁE��緁E
  static Border thinBorder(Color color) => Border.all(
        color: color,
        width: thin,
      );

  /// 太ぁE��緁E
  static Border thickBorder(Color color) => Border.all(
        color: color,
        width: thick,
      );

  /// 下部のみの枠緁E
  static Border bottomOnly(Color color, {double width = regular}) => Border(
        bottom: BorderSide(color: color, width: width),
      );

  /// 上部のみの枠緁E
  static Border topOnly(Color color, {double width = regular}) => Border(
        top: BorderSide(color: color, width: width),
      );

  /// 左側のみの枠緁E
  static Border leftOnly(Color color, {double width = regular}) => Border(
        left: BorderSide(color: color, width: width),
      );

  /// 右側のみの枠緁E
  static Border rightOnly(Color color, {double width = regular}) => Border(
        right: BorderSide(color: color, width: width),
      );

  // ========================================
  // セマンチE��チE��な枠緁E
  // ========================================

  /// カード用の枠緁E
  static Border card(Color color) => thinBorder(color);

  /// ボタン用の枠緁E
  static Border button(Color color) => standard(color);

  /// 入力フィールド用の枠緁E
  static Border input(Color color) => standard(color);

  /// フォーカス時�E枠緁E
  static Border focused(Color color) => thickBorder(color);

  /// エラー時�E枠緁E
  static Border error(Color errorColor) => thickBorder(errorColor);

  // ========================================
  // セマンチE��チE��な角丸
  // ========================================

  /// カード用の角丸
  static const BorderRadius cardRadius = roundedMD;

  /// ボタン用の角丸
  static const BorderRadius buttonRadius = roundedSM;

  /// 入力フィールド用の角丸
  static const BorderRadius inputRadius = roundedSM;

  /// ダイアログ用の角丸
  static const BorderRadius dialogRadius = roundedLG;

  /// ボトムシート用の角丸�E�上部のみ�E�E
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

  /// カード�E影を追加
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
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
      ),
      clipBehavior: Clip.antiAlias,
      child: this,
    );
  }
}
