import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeColorKey = 'theme_color';

class ThemeNotifier extends StateNotifier<Color> {
  ThemeNotifier() : super(Colors.blue) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final colorValue = prefs.getInt(_themeColorKey);
    if (colorValue != null) {
      state = Color(colorValue);
    }
  }

  Future<void> setTheme(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    // ignore: deprecated_member_use
    await prefs.setInt(_themeColorKey, color.value);
    state = color;
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, Color>((ref) {
  return ThemeNotifier();
});

class ThemeSelectionScreen extends ConsumerWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableColors = [
      Colors.blue,
      Colors.green,
      Colors.pink,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    final selectedColor = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('テーマカラーを選択')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: availableColors.length,
          itemBuilder: (context, index) {
            final color = availableColors[index];
            return GestureDetector(
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(color);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        selectedColor == color
                            ? Theme.of(context).colorScheme.onSurface
                            : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
