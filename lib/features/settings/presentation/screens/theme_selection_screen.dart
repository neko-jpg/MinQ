import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// TODO: This should be managed by a proper theme provider
final selectedColorProvider = StateProvider<Color>((ref) => Colors.blue);

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
    final selectedColor = ref.watch(selectedColorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("テーマカラーを選択"),
      ),
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
                ref.read(selectedColorProvider.notifier).state = color;
                // TODO: Persist the selected theme color.
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selectedColor == color
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