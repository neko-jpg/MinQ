import 'package:flutter/material.dart';

class StickerPickerWidget extends StatelessWidget {
  const StickerPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Fetch sticker packs from a service.
    final stickers = [
      'assets/images/stickers/sticker_1.png',
      'assets/images/stickers/sticker_2.png',
      'assets/images/stickers/sticker_3.png',
      'assets/images/stickers/sticker_4.png',
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: stickers.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // TODO: Implement sending the selected sticker.
              print("Selected sticker: ${stickers[index]}");
            },
            // Using a placeholder icon since the actual assets don't exist yet.
            child: const Center(child: Icon(Icons.emoji_emotions, size: 48)),
          );
        },
      ),
    );
  }
}