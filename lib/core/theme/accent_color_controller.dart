import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// アクセントカラー
enum AccentColor {
  blue,
  green,
  purple,
  orange,
  pink,
  teal,
}

extension AccentColorExtension on AccentColor {
  /// カラー値を取得
  Color get color {
    switch (this) {
      case AccentColor.blue:
        return const Color(0xFF2196F3);
      case AccentColor.green:
        return const Color(0xFF4CAF50);
      case AccentColor.purple:
        return const Color(0xFF9C27B0);
      case AccentColor.orange:
        return const Color(0xFFFF9800);
      case AccentColor.pink:
        return const Color(0xFFE91E63);
      case AccentColor.teal:
        return const Color(0xFF009688);
    }
  }

  /// 表示名
  String get displayName {
    switch (this) {
      case AccentColor.blue:
        return '青';
      case AccentColor.green:
        return '緑';
      case AccentColor.purple:
        return '紫';
      case AccentColor.orange:
        return 'オレンジ';
      case AccentColor.pink:
        return 'ピンク';
      case AccentColor.teal:
        return 'ティール';
    }
  }

  /// MaterialColorを生成
  MaterialColor get materialColor {
    return MaterialColor(
      color.value,
      <int, Color>{
        50: color.withOpacity(0.1),
        100: color.withOpacity(0.2),
        200: color.withOpacity(0.3),
        300: color.withOpacity(0.4),
        400: color.withOpacity(0.6),
        500: color,
        600: color.withOpacity(0.8),
        700: color.withOpacity(0.9),
        800: color.withOpacity(0.95),
        900: color,
      },
    );
  }
}

/// アクセントカラーコントローラー
class AccentColorController extends StateNotifier<AccentColor> {
  static const String _keyAccentColor = 'accent_color';

  AccentColorController() : super(AccentColor.blue) {
    _loadAccentColor();
  }

  /// アクセントカラーを読み込み
  Future<void> _loadAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final colorStr = prefs.getString(_keyAccentColor);

    if (colorStr != null) {
      state = AccentColor.values.firstWhere(
        (color) => color.name == colorStr,
        orElse: () => AccentColor.blue,
      );
    }
  }

  /// アクセントカラーを設定（即時反映）
  Future<void> setAccentColor(AccentColor color) async {
    state = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccentColor, color.name);
  }
}

/// アクセントカラーコントローラープロバイダー
final accentColorControllerProvider =
    StateNotifierProvider<AccentColorController, AccentColor>((ref) {
  return AccentColorController();
});

/// アクセントカラープロバイダー
final accentColorProvider = Provider<Color>((ref) {
  final accentColor = ref.watch(accentColorControllerProvider);
  return accentColor.color;
});

/// アクセントカラー選択ウィジェット
class AccentColorPicker extends ConsumerWidget {
  const AccentColorPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(accentColorControllerProvider);
    final controller = ref.read(accentColorControllerProvider.notifier);

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: AccentColor.values.map((color) {
        final isSelected = color == currentColor;

        return GestureDetector(
          onTap: () => controller.setAccentColor(color),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.color,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: Colors.white,
                      width: 3,
                    )
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 32,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}
