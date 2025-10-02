import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// フォントサイズ設定
enum FontSizeScale {
  small,
  medium,
  large,
  extraLarge,
}

extension FontSizeScaleExtension on FontSizeScale {
  /// スケール値
  double get scale {
    switch (this) {
      case FontSizeScale.small:
        return 0.85;
      case FontSizeScale.medium:
        return 1.0;
      case FontSizeScale.large:
        return 1.15;
      case FontSizeScale.extraLarge:
        return 1.3;
    }
  }

  /// 表示名
  String get displayName {
    switch (this) {
      case FontSizeScale.small:
        return '小';
      case FontSizeScale.medium:
        return '標準';
      case FontSizeScale.large:
        return '大';
      case FontSizeScale.extraLarge:
        return '特大';
    }
  }
}

/// フォントサイズコントローラー
class FontSizeController extends StateNotifier<FontSizeScale> {
  static const String _keyFontSize = 'font_size_scale';

  FontSizeController() : super(FontSizeScale.medium) {
    _loadFontSize();
  }

  /// フォントサイズを読み込み
  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final sizeStr = prefs.getString(_keyFontSize);

    if (sizeStr != null) {
      state = FontSizeScale.values.firstWhere(
        (size) => size.name == sizeStr,
        orElse: () => FontSizeScale.medium,
      );
    }
  }

  /// フォントサイズを設定（即時反映）
  Future<void> setFontSize(FontSizeScale size) async {
    state = size;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFontSize, size.name);
  }

  /// 拡大
  Future<void> increase() async {
    final currentIndex = FontSizeScale.values.indexOf(state);
    if (currentIndex < FontSizeScale.values.length - 1) {
      await setFontSize(FontSizeScale.values[currentIndex + 1]);
    }
  }

  /// 縮小
  Future<void> decrease() async {
    final currentIndex = FontSizeScale.values.indexOf(state);
    if (currentIndex > 0) {
      await setFontSize(FontSizeScale.values[currentIndex - 1]);
    }
  }
}

/// フォントサイズコントローラープロバイダー
final fontSizeControllerProvider =
    StateNotifierProvider<FontSizeController, FontSizeScale>((ref) {
  return FontSizeController();
});

/// フォントサイズスケールプロバイダー
final fontSizeScaleProvider = Provider<double>((ref) {
  final fontSize = ref.watch(fontSizeControllerProvider);
  return fontSize.scale;
});

/// フォントサイズ選択ウィジェット
class FontSizePicker extends ConsumerWidget {
  const FontSizePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSize = ref.watch(fontSizeControllerProvider);
    final controller = ref.read(fontSizeControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'フォントサイズ',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () => controller.decrease(),
            ),
            Expanded(
              child: Slider(
                value: FontSizeScale.values.indexOf(currentSize).toDouble(),
                min: 0,
                max: (FontSizeScale.values.length - 1).toDouble(),
                divisions: FontSizeScale.values.length - 1,
                label: currentSize.displayName,
                onChanged: (value) {
                  controller.setFontSize(FontSizeScale.values[value.toInt()]);
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => controller.increase(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'プレビュー: ${currentSize.displayName}',
            style: TextStyle(
              fontSize: 16 * currentSize.scale,
            ),
          ),
        ),
      ],
    );
  }
}

/// テキストスケールラッパー
class TextScaleWrapper extends ConsumerWidget {
  final Widget child;

  const TextScaleWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scale = ref.watch(fontSizeScaleProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: scale,
      ),
      child: child,
    );
  }
}
