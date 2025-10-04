import 'package:flutter/material.dart';

/// グリーンダークモーチE
/// OLED省E��力�E色
class GreenDarkTheme {
  const GreenDarkTheme._();

  /// OLED最適化ダークチE�EチE
  /// 純黒背景で消費電力を削渁E
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // 純黒背景�E�ELED省E��力！E
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF4CAF50), // グリーン
        secondary: Color(0xFF81C784),
        surface: Color(0xFF0A0A0A),
        error: Color(0xFFCF6679),
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Color(0xFFE0E0E0),
        onError: Colors.black,
      ),
      // カーチE
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
      // ボタン
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.black,
        ),
      ),
      // チE��スチE
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

  /// 省E��力設宁E
  static const powerSavingSettings = {
    'useBlackBackground': true,
    'reduceAnimations': true,
    'lowerBrightness': true,
    'disableHaptics': false,
  };

  /// 推定消費電力削減率�E�ELED画面の場合！E
  static const estimatedPowerSaving = 0.4; // 40%削渁E

  /// カラーパレチE��
  static const colors = GreenDarkColors();
}

/// グリーンダークモード�EカラーパレチE��
class GreenDarkColors {
  const GreenDarkColors();

  // 背景色
  final Color background = Colors.black;
  final Color surface = const Color(0xFF0A0A0A);
  final Color surfaceVariant = const Color(0xFF1A1A1A);

  // プライマリカラー
  final Color primary = const Color(0xFF4CAF50);
  final Color primaryLight = const Color(0xFF81C784);
  final Color primaryDark = const Color(0xFF388E3C);

  // チE��ストカラー
  final Color textPrimary = const Color(0xFFE0E0E0);
  final Color textSecondary = const Color(0xFFB0B0B0);
  final Color textTertiary = const Color(0xFF808080);

  // アクセントカラー
  final Color success = const Color(0xFF66BB6A);
  final Color warning = const Color(0xFFFFA726);
  final Color error = const Color(0xFFEF5350);
  final Color info = const Color(0xFF42A5F5);

  // ボ�Eダー
  final Color border = const Color(0xFF2A2A2A);
  final Color divider = const Color(0xFF1A1A1A);
}

/// 省E��力モード設宁E
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

  /// チE��ォルト設宁E
  static const defaultMode = PowerSavingMode();

  /// 最大省E��力モーチE
  static const maxPowerSaving = PowerSavingMode(
    enabled: true,
    useBlackBackground: true,
    reduceAnimations: true,
    lowerBrightness: true,
    disableHaptics: true,
  );

  /// アニメーション時間を調整
  Duration adjustDuration(Duration duration) {
    if (!enabled || !reduceAnimations) return duration;
    return duration * 0.5; // 50%短縮
  }

  /// 明るさを調整
  double adjustBrightness(double brightness) {
    if (!enabled || !lowerBrightness) return brightness;
    return (brightness * 0.7).clamp(0.0, 1.0); // 30%削渁E
  }
}
