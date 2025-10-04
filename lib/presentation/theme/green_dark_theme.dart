import 'package:flutter/material.dart';

/// 繧ｰ繝ｪ繝ｼ繝ｳ繝繝ｼ繧ｯ繝｢繝ｼ繝・
/// OLED逵・崕蜉幃・濶ｲ
class GreenDarkTheme {
  const GreenDarkTheme._();

  /// OLED譛驕ｩ蛹悶ム繝ｼ繧ｯ繝・・繝・
  /// 邏秘ｻ定レ譎ｯ縺ｧ豸郁ｲｻ髮ｻ蜉帙ｒ蜑頑ｸ・
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // 邏秘ｻ定レ譎ｯ・・LED逵・崕蜉幢ｼ・
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50), // 繧ｰ繝ｪ繝ｼ繝ｳ
        secondary: Color(0xFF81C784),
        surface: Color(0xFF0A0A0A),
        error: Color(0xFFCF6679),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Color(0xFFE0E0E0),
        onError: Colors.black,
      ),
      // 繧ｫ繝ｼ繝・
      cardTheme: const CardTheme(
        color: Color(0xFF0A0A0A),
        elevation: 0,
      ),
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Color(0xFFE0E0E0),
        elevation: 0,
      ),
      // 繝懊ち繝ｳ
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.black,
        ),
      ),
      // 繝・く繧ｹ繝・
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFFE0E0E0)),
        displayMedium: TextStyle(color: Color(0xFFE0E0E0)),
        displaySmall: TextStyle(color: Color(0xFFE0E0E0)),
        headlineLarge: TextStyle(color: Color(0xFFE0E0E0)),
        headlineMedium: TextStyle(color: Color(0xFFE0E0E0)),
        headlineSmall: TextStyle(color: Color(0xFFE0E0E0)),
        titleLarge: TextStyle(color: Color(0xFFE0E0E0)),
        titleMedium: TextStyle(color: Color(0xFFE0E0E0)),
        titleSmall: TextStyle(color: Color(0xFFE0E0E0)),
        bodyLarge: TextStyle(color: Color(0xFFE0E0E0)),
        bodyMedium: TextStyle(color: Color(0xFFE0E0E0)),
        bodySmall: TextStyle(color: Color(0xFFB0B0B0)),
        labelLarge: TextStyle(color: Color(0xFFE0E0E0)),
        labelMedium: TextStyle(color: Color(0xFFE0E0E0)),
        labelSmall: TextStyle(color: Color(0xFFB0B0B0)),
      ),
    );
  }

  /// 逵・崕蜉幄ｨｭ螳・
  static const powerSavingSettings = {
    'useBlackBackground': true,
    'reduceAnimations': true,
    'lowerBrightness': true,
    'disableHaptics': false,
  };

  /// 謗ｨ螳壽ｶ郁ｲｻ髮ｻ蜉帛炎貂帷紫・・LED逕ｻ髱｢縺ｮ蝣ｴ蜷茨ｼ・
  static const estimatedPowerSaving = 0.4; // 40%蜑頑ｸ・

  /// 繧ｫ繝ｩ繝ｼ繝代Ξ繝・ヨ
  static const colors = GreenDarkColors();
}

/// 繧ｰ繝ｪ繝ｼ繝ｳ繝繝ｼ繧ｯ繝｢繝ｼ繝峨・繧ｫ繝ｩ繝ｼ繝代Ξ繝・ヨ
class GreenDarkColors {
  const GreenDarkColors();

  // 閭梧勹濶ｲ
  final Color background = Colors.black;
  final Color surface = const Color(0xFF0A0A0A);
  final Color surfaceVariant = const Color(0xFF1A1A1A);

  // 繝励Λ繧､繝槭Μ繧ｫ繝ｩ繝ｼ
  final Color primary = const Color(0xFF4CAF50);
  final Color primaryLight = const Color(0xFF81C784);
  final Color primaryDark = const Color(0xFF388E3C);

  // 繝・く繧ｹ繝医き繝ｩ繝ｼ
  final Color textPrimary = const Color(0xFFE0E0E0);
  final Color textSecondary = const Color(0xFFB0B0B0);
  final Color textTertiary = const Color(0xFF808080);

  // 繧｢繧ｯ繧ｻ繝ｳ繝医き繝ｩ繝ｼ
  final Color success = const Color(0xFF66BB6A);
  final Color warning = const Color(0xFFFFA726);
  final Color error = const Color(0xFFEF5350);
  final Color info = const Color(0xFF42A5F5);

  // 繝懊・繝繝ｼ
  final Color border = const Color(0xFF2A2A2A);
  final Color divider = const Color(0xFF1A1A1A);
}

/// 逵・崕蜉帙Δ繝ｼ繝芽ｨｭ螳・
class PowerSavingMode {
  final bool enabled;
  final bool useBlackBackground;
  final bool reduceAnimations;
  final bool lowerBrightness;
  final bool disableHaptics;

  const PowerSavingMode({
    this.enabled = false,
    this.useBlackBackground = true,
    this.reduceAnimations = true,
    this.lowerBrightness = false,
    this.disableHaptics = false,
  });

  /// 繝・ヵ繧ｩ繝ｫ繝郁ｨｭ螳・
  static const defaultMode = PowerSavingMode();

  /// 譛螟ｧ逵・崕蜉帙Δ繝ｼ繝・
  static const maxPowerSaving = PowerSavingMode(
    enabled: true,
    useBlackBackground: true,
    reduceAnimations: true,
    lowerBrightness: true,
    disableHaptics: true,
  );

  /// 繧｢繝九Γ繝ｼ繧ｷ繝ｧ繝ｳ譎る俣繧定ｪｿ謨ｴ
  Duration adjustDuration(Duration duration) {
    if (!enabled || !reduceAnimations) return duration;
    return duration * 0.5; // 50%遏ｭ邵ｮ
  }

  /// 譏弱ｋ縺輔ｒ隱ｿ謨ｴ
  double adjustBrightness(double brightness) {
    if (!enabled || !lowerBrightness) return brightness;
    return (brightness * 0.7).clamp(0.0, 1.0); // 30%蜑頑ｸ・
  }
}
