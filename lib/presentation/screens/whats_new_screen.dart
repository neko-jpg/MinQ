import 'package:flutter/material.dart';

/// What's New逕ｻ髱｢・医ヰ繝ｼ繧ｸ繝ｧ繝ｳ繧｢繝・・譎ゅ・螟画峩轤ｹ譯亥・・・
class WhatsNewScreen extends StatelessWidget {
  final String version;
  final List<WhatsNewItem> items;

  const WhatsNewScreen({
    super.key,
    required this.version,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('譁ｰ讖溯・縺ｮ縺皮ｴｹ莉・),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.celebration,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  '繝舌・繧ｸ繝ｧ繝ｳ $version',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildItem(context, items[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('蟋九ａ繧・),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, WhatsNewItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                item.icon,
                color: item.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// What's New繧｢繧､繝・Β
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
