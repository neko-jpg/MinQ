import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/features/pair/presentation/widgets/conversation_starter_widget.dart'; // Re-using the chat service provider

// In a real app, this would be part of a service that fetches sticker packs.
final stickerPacksProvider = Provider<List<String>>((ref) {
  // These paths are placeholders.
  return List.generate(12, (i) => 'assets/images/stickers/sticker_${i + 1}.png');
});


class StickerPickerWidget extends ConsumerWidget {
  const StickerPickerWidget({super.key, required this.pairId});

  final String pairId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stickers = ref.watch(stickerPacksProvider);

    return Container(
      height: 250,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: stickers.length,
        itemBuilder: (context, index) {
          final stickerId = stickers[index];
          return GestureDetector(
            onTap: () {
              // Re-use the dummy chat service to "send" the sticker.
              ref.read(chatServiceProvider).sendMessage(
                    pairId: pairId,
                    text: "[sticker:$stickerId]", // Send a special format for stickers
                  );
              // Close the picker after selection
              Navigator.of(context).pop();
            },
            // Using a placeholder icon since the actual assets don't exist yet.
            child: Card(
              elevation: 1,
              child: Center(child: Icon(Icons.emoji_emotions_outlined, size: 40, color: Theme.of(context).colorScheme.primary)),
            ),
          );
        },
      ),
    );
  }
}