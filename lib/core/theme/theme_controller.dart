import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// テーマモード
enum AppThemeMode { light, dark, system }

/// テーマコントローラー
class ThemeController extends StateNotifier<AppThemeMode> {
  static const String _keyThemeMode = 'theme_mode';

  ThemeController() : super(AppThemeMode.system) {
    _loadThemeMode();
  }

  /// テーマモードを読み込み
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyThemeMode);

    if (modeStr != null) {
      state = AppThemeMode.values.firstWhere(
        (mode) => mode.name == modeStr,
        orElse: () => AppThemeMode.system,
      );
    }
  }

  /// テーマモードを設定（即時反映）
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
  }

  /// ライトモードに切替
  Future<void> setLight() => setThemeMode(AppThemeMode.light);

  /// ダークモードに切替
  Future<void> setDark() => setThemeMode(AppThemeMode.dark);

  /// システム設定に従う
  Future<void> setSystem() => setThemeMode(AppThemeMode.system);

  /// トグル（ライト⇔ダーク）
  Future<void> toggle() async {
    if (state == AppThemeMode.light) {
      await setDark();
    } else {
      await setLight();
    }
  }

  /// 現在のテーマモードを取得
  ThemeMode get themeMode {
    switch (state) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// テーマコントローラープロバイダー
final themeControllerProvider =
    StateNotifierProvider<ThemeController, AppThemeMode>((ref) {
      return ThemeController();
    });

/// テーマモードプロバイダー（MaterialAppで使用）
final themeModeProvider = Provider<ThemeMode>((ref) {
  final controller = ref.watch(themeControllerProvider.notifier);
  return controller.themeMode;
});

/// ダークモード判定プロバイダー
final isDarkModeProvider = Provider<bool>((ref) {
  final mode = ref.watch(themeControllerProvider);

  if (mode == AppThemeMode.dark) {
    return true;
  } else if (mode == AppThemeMode.light) {
    return false;
  }

  // システム設定を確認
  return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;
});
