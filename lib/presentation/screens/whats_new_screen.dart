import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// What's New画面（バージョンアップ時の変更点案内）
class WhatsNewScreen extends StatelessWidget {
  final String version;
  final List<WhatsNewItem> items;

  const WhatsNewScreen({super.key, required this.version, required this.items});

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<MinqTheme>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('新機能のご紹介')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.spacing.xl),
            child: Column(
              children: [
                Icon(Icons.celebration, size: 64, color: tokens.brandPrimary),
                SizedBox(height: tokens.spacing.md),
                Text('バージョン $version', style: tokens.typography.h2),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(tokens.spacing.md),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItem(context, items[index]);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(tokens.spacing.md),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('始める'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, WhatsNewItem item) {
    final tokens = Theme.of(context).extension<MinqTheme>()!;
    return Card(
      margin: EdgeInsets.only(bottom: tokens.spacing.md),
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withAlpha(26),
                borderRadius: BorderRadius.circular(tokens.radius.sm),
              ),
              child: Icon(item.icon, color: item.color),
            ),
            SizedBox(width: tokens.spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: tokens.typography.h3),
                  SizedBox(height: tokens.spacing.xs),
                  Text(item.description, style: tokens.typography.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What's Newアイテム
class WhatsNewItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  WhatsNewItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
