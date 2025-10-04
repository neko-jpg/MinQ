import 'package:flutter/material.dart';

/// Elevation繧ｷ繧ｹ繝・Β - 蠖ｱ縺ｨ豺ｱ蠎ｦ縺ｮ螳夂ｾｩ
/// Material Design 3縺ｫ貅匁侠縺励◆蠖ｱ縺ｮ繝ｬ繝吶Ν
class ElevationSystem {
  const ElevationSystem._();

  // ========================================
  // Elevation 繝ｬ繝吶Ν
  // ========================================

  /// Level 0 - 蠖ｱ縺ｪ縺暦ｼ医ヵ繝ｩ繝・ヨ・・
  static const double level0 = 0.0;

  /// Level 1 - 譛蟆上・蠖ｱ・医き繝ｼ繝峨√メ繝・・・・
  static const double level1 = 1.0;

  /// Level 2 - 蟆上＆縺ｪ蠖ｱ・医・繧ｿ繝ｳ縲：AB・・
  static const double level2 = 2.0;

  /// Level 3 - 荳ｭ遞句ｺｦ縺ｮ蠖ｱ・医ム繧､繧｢繝ｭ繧ｰ縲√Γ繝九Η繝ｼ・・
  static const double level3 = 3.0;

  /// Level 4 - 螟ｧ縺阪↑蠖ｱ・医リ繝薙ご繝ｼ繧ｷ繝ｧ繝ｳ繝峨Ο繝ｯ繝ｼ・・
  static const double level4 = 4.0;

  /// Level 5 - 譛螟ｧ縺ｮ蠖ｱ・医Δ繝ｼ繝繝ｫ縲√・繝医Β繧ｷ繝ｼ繝茨ｼ・
  static const double level5 = 5.0;

  // ========================================
  // BoxShadow 螳夂ｾｩ
  // ========================================

  /// 蠖ｱ縺ｪ縺・
  static const List<BoxShadow> none = [];

  /// 讌ｵ蟆上・蠖ｱ - 繝帙ヰ繝ｼ迥ｶ諷・
  static const List<BoxShadow> minimal = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// 蟆上＆縺ｪ蠖ｱ - 繧ｫ繝ｼ繝峨√メ繝・・
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

  /// 荳ｭ遞句ｺｦ縺ｮ蠖ｱ - 繝懊ち繝ｳ縲：AB
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

  /// 螟ｧ縺阪↑蠖ｱ - 繝繧､繧｢繝ｭ繧ｰ縲√Γ繝九Η繝ｼ
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

  /// 迚ｹ螟ｧ縺ｮ蠖ｱ - 繝翫ン繧ｲ繝ｼ繧ｷ繝ｧ繝ｳ繝峨Ο繝ｯ繝ｼ
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

  /// 譛螟ｧ縺ｮ蠖ｱ - 繝｢繝ｼ繝繝ｫ縲√・繝医Β繧ｷ繝ｼ繝・
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
  // 繝繝ｼ繧ｯ繝｢繝ｼ繝臥畑縺ｮ蠖ｱ
  // ========================================

  /// 繝繝ｼ繧ｯ繝｢繝ｼ繝・- 蟆上＆縺ｪ蠖ｱ
  static const List<BoxShadow> darkSmall = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
  ];

  /// 繝繝ｼ繧ｯ繝｢繝ｼ繝・- 荳ｭ遞句ｺｦ縺ｮ蠖ｱ
  static const List<BoxShadow> darkMedium = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// 繝繝ｼ繧ｯ繝｢繝ｼ繝・- 螟ｧ縺阪↑蠖ｱ
  static const List<BoxShadow> darkLarge = [
    BoxShadow(
      color: Color(0x47000000),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  // ========================================
  // 繧ｻ繝槭Φ繝・ぅ繝・け縺ｪ蠖ｱ
  // ========================================

  /// 繧ｫ繝ｼ繝臥畑縺ｮ蠖ｱ
  static const List<BoxShadow> card = small;

  /// 繝懊ち繝ｳ逕ｨ縺ｮ蠖ｱ
  static const List<BoxShadow> button = medium;

  /// 繝繧､繧｢繝ｭ繧ｰ逕ｨ縺ｮ蠖ｱ
  static const List<BoxShadow> dialog = large;

  /// 繝｡繝九Η繝ｼ逕ｨ縺ｮ蠖ｱ
  static const List<BoxShadow> menu = large;

  /// 繝懊ヨ繝繧ｷ繝ｼ繝育畑縺ｮ蠖ｱ
  static const List<BoxShadow> bottomSheet = maximum;

  /// FAB逕ｨ縺ｮ蠖ｱ
  static const List<BoxShadow> fab = medium;

  /// AppBar逕ｨ縺ｮ蠖ｱ
  static const List<BoxShadow> appBar = minimal;

  // ========================================
  // 繧ｫ繝ｩ繝ｼ莉倥″蠖ｱ・医い繧ｯ繧ｻ繝ｳ繝茨ｼ・
  // ========================================

  /// 繝励Λ繧､繝槭Μ繧ｫ繝ｩ繝ｼ縺ｮ蠖ｱ
  static List<BoxShadow> primaryGlow(Color primaryColor) => [
        BoxShadow(
          color: primaryColor.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// 謌仙粥繧ｫ繝ｩ繝ｼ縺ｮ蠖ｱ
  static List<BoxShadow> successGlow(Color successColor) => [
        BoxShadow(
          color: successColor.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// 繧ｨ繝ｩ繝ｼ繧ｫ繝ｩ繝ｼ縺ｮ蠖ｱ
  static List<BoxShadow> errorGlow(Color errorColor) => [
        BoxShadow(
          color: errorColor.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  // ========================================
  // 繧､繝ｳ繝翫・繧ｷ繝｣繝峨え・育桝莨ｼ・・
  // ========================================

  /// 繧､繝ｳ繝翫・繧ｷ繝｣繝峨え蜉ｹ譫懶ｼ・ontainer縺ｮ蜀・・縺ｫ驟咲ｽｮ・・
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
  // 繝倥Ν繝代・繝｡繧ｽ繝・ラ
  // ========================================

  /// Brightness縺ｫ蠢懊§縺溷ｽｱ繧貞叙蠕・
  static List<BoxShadow> getShadow(
    Brightness brightness,
    List<BoxShadow> lightShadow,
    List<BoxShadow> darkShadow,
  ) {
    return brightness == Brightness.light ? lightShadow : darkShadow;
  }

  /// 繝ｬ繝吶Ν縺九ｉ蠖ｱ繧貞叙蠕・
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

/// Border繧ｷ繧ｹ繝・Β - 譫邱壹・螳夂ｾｩ
class BorderSystem {
  const BorderSystem._();

  // ========================================
  // Border Width
  // ========================================

  /// 譫邱壹↑縺・
  static const double none = 0.0;

  /// 讌ｵ邏ｰ譫邱・
  static const double thin = 1.0;

  /// 讓呎ｺ匁棧邱・
  static const double regular = 1.5;

  /// 螟ｪ縺・棧邱・
  static const double thick = 2.0;

  /// 迚ｹ螟ｪ譫邱・
  static const double extraThick = 3.0;

  // ========================================
  // Border Radius
  // ========================================

  /// 隗剃ｸｸ縺ｪ縺・
  static const double radiusNone = 0.0;

  /// 讌ｵ蟆剰ｧ剃ｸｸ
  static const double radiusXS = 4.0;

  /// 蟆剰ｧ剃ｸｸ
  static const double radiusSM = 8.0;

  /// 荳ｭ隗剃ｸｸ
  static const double radiusMD = 12.0;

  /// 螟ｧ隗剃ｸｸ
  static const double radiusLG = 16.0;

  /// 迚ｹ螟ｧ隗剃ｸｸ
  static const double radiusXL = 20.0;

  /// 雜・音螟ｧ隗剃ｸｸ
  static const double radiusXXL = 28.0;

  /// 螳悟・縺ｪ蜀・ｽ｢
  static const double radiusFull = 999.0;

  // ========================================
  // BorderRadius 繧ｪ繝悶ず繧ｧ繧ｯ繝・
  // ========================================

  /// 隗剃ｸｸ縺ｪ縺・
  static const BorderRadius noRadius = BorderRadius.zero;

  /// 讌ｵ蟆剰ｧ剃ｸｸ
  static const BorderRadius roundedXS = BorderRadius.all(
    Radius.circular(radiusXS),
  );

  /// 蟆剰ｧ剃ｸｸ
  static const BorderRadius roundedSM = BorderRadius.all(
    Radius.circular(radiusSM),
  );

  /// 荳ｭ隗剃ｸｸ
  static const BorderRadius roundedMD = BorderRadius.all(
    Radius.circular(radiusMD),
  );

  /// 螟ｧ隗剃ｸｸ
  static const BorderRadius roundedLG = BorderRadius.all(
    Radius.circular(radiusLG),
  );

  /// 迚ｹ螟ｧ隗剃ｸｸ
  static const BorderRadius roundedXL = BorderRadius.all(
    Radius.circular(radiusXL),
  );

  /// 雜・音螟ｧ隗剃ｸｸ
  static const BorderRadius roundedXXL = BorderRadius.all(
    Radius.circular(radiusXXL),
  );

  /// 螳悟・縺ｪ蜀・ｽ｢
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // ========================================
  // Border 繧ｪ繝悶ず繧ｧ繧ｯ繝・
  // ========================================

  /// 讓呎ｺ匁棧邱・
  static Border standard(Color color) => Border.all(
        color: color,
        width: regular,
      );

  /// 邏ｰ縺・棧邱・
  static Border thinBorder(Color color) => Border.all(
        color: color,
        width: thin,
      );

  /// 螟ｪ縺・棧邱・
  static Border thickBorder(Color color) => Border.all(
        color: color,
        width: thick,
      );

  /// 荳矩Κ縺ｮ縺ｿ縺ｮ譫邱・
  static Border bottomOnly(Color color, {double width = regular}) => Border(
        bottom: BorderSide(color: color, width: width),
      );

  /// 荳企Κ縺ｮ縺ｿ縺ｮ譫邱・
  static Border topOnly(Color color, {double width = regular}) => Border(
        top: BorderSide(color: color, width: width),
      );

  /// 蟾ｦ蛛ｴ縺ｮ縺ｿ縺ｮ譫邱・
  static Border leftOnly(Color color, {double width = regular}) => Border(
        left: BorderSide(color: color, width: width),
      );

  /// 蜿ｳ蛛ｴ縺ｮ縺ｿ縺ｮ譫邱・
  static Border rightOnly(Color color, {double width = regular}) => Border(
        right: BorderSide(color: color, width: width),
      );

  // ========================================
  // 繧ｻ繝槭Φ繝・ぅ繝・け縺ｪ譫邱・
  // ========================================

  /// 繧ｫ繝ｼ繝臥畑縺ｮ譫邱・
  static Border card(Color color) => thinBorder(color);

  /// 繝懊ち繝ｳ逕ｨ縺ｮ譫邱・
  static Border button(Color color) => standard(color);

  /// 蜈･蜉帙ヵ繧｣繝ｼ繝ｫ繝臥畑縺ｮ譫邱・
  static Border input(Color color) => standard(color);

  /// 繝輔か繝ｼ繧ｫ繧ｹ譎ゅ・譫邱・
  static Border focused(Color color) => thickBorder(color);

  /// 繧ｨ繝ｩ繝ｼ譎ゅ・譫邱・
  static Border error(Color errorColor) => thickBorder(errorColor);

  // ========================================
  // 繧ｻ繝槭Φ繝・ぅ繝・け縺ｪ隗剃ｸｸ
  // ========================================

  /// 繧ｫ繝ｼ繝臥畑縺ｮ隗剃ｸｸ
  static const BorderRadius cardRadius = roundedMD;

  /// 繝懊ち繝ｳ逕ｨ縺ｮ隗剃ｸｸ
  static const BorderRadius buttonRadius = roundedSM;

  /// 蜈･蜉帙ヵ繧｣繝ｼ繝ｫ繝臥畑縺ｮ隗剃ｸｸ
  static const BorderRadius inputRadius = roundedSM;

  /// 繝繧､繧｢繝ｭ繧ｰ逕ｨ縺ｮ隗剃ｸｸ
  static const BorderRadius dialogRadius = roundedLG;

  /// 繝懊ヨ繝繧ｷ繝ｼ繝育畑縺ｮ隗剃ｸｸ・井ｸ企Κ縺ｮ縺ｿ・・
  static const BorderRadius bottomSheetRadius = BorderRadius.only(
    topLeft: Radius.circular(radiusLG),
    topRight: Radius.circular(radiusLG),
  );

  /// 繝√ャ繝礼畑縺ｮ隗剃ｸｸ
  static const BorderRadius chipRadius = roundedFull;

  /// 繧｢繝舌ち繝ｼ逕ｨ縺ｮ隗剃ｸｸ
  static const BorderRadius avatarRadius = roundedFull;
}

/// Elevation諡｡蠑ｵ
extension ElevationExtension on Widget {
  /// 蠖ｱ繧定ｿｽ蜉
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

  /// 繧ｫ繝ｼ繝峨・蠖ｱ繧定ｿｽ蜉
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

/// Border諡｡蠑ｵ
extension BorderExtension on Widget {
  /// 譫邱壹ｒ霑ｽ蜉
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

  /// 隗剃ｸｸ繧定ｿｽ蜉
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
