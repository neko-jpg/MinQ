import 'package:flutter/material.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

class DashboardHeader extends StatelessWidget {
  final CustomDashboardConfig dashboard;
  final bool isEditMode;
  final Function(DashboardLayout) onLayoutChanged;

  const DashboardHeader({
    super.key,
    required this.dashboard,
    required this.isEditMode,
    required this.onLayoutChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dashboard.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dashboard.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        dashboard.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isEditMode) _buildLayoutControls(context),
            ],
          ),
          if (isEditMode) ...[
            const SizedBox(height: 12),
            _buildEditModeInfo(context),
          ],
        ],
      ),
    );
  }

  Widget _buildLayoutControls(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.grid_view),
          onPressed: () => _showLayoutSettings(context),
          tooltip: 'レイアウト設定',
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _resetLayout(context),
          tooltip: 'レイアウトリセット',
        ),
      ],
    );
  }

  Widget _buildEditModeInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '編集モード: ウィジェットをドラッグして移動、設定アイコンで詳細設定',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLayoutSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'レイアウト設定',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const Text('カラム数'),
            Slider(
              value: dashboard.layout.columns.toDouble(),
              min: 2,
              max: 6,
              divisions: 4,
              label: '${dashboard.layout.columns}',
              onChanged: (value) {
                final newLayout = dashboard.layout.copyWith(
                  columns: value.toInt(),
                );
                onLayoutChanged(newLayout);
              },
            ),
            const SizedBox(height: 16),
            const Text('行の高さ'),
            Slider(
              value: dashboard.layout.rowHeight,
              min: 80,
              max: 200,
              divisions: 12,
              label: '${dashboard.layout.rowHeight.toInt()}px',
              onChanged: (value) {
                final newLayout = dashboard.layout.copyWith(
                  rowHeight: value,
                );
                onLayoutChanged(newLayout);
              },
            ),
            const SizedBox(height: 16),
            const Text('間隔'),
            Slider(
              value: dashboard.layout.spacing,
              min: 4,
              max: 24,
              divisions: 10,
              label: '${dashboard.layout.spacing.toInt()}px',
              onChanged: (value) {
                final newLayout = dashboard.layout.copyWith(
                  spacing: value,
                );
                onLayoutChanged(newLayout);
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('完了'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetLayout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レイアウトリセット'),
        content: const Text('レイアウト設定をデフォルトに戻しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              const defaultLayout = DashboardLayout(
                columns: 4,
                rowHeight: 120,
                spacing: 16,
              );
              onLayoutChanged(defaultLayout);
              Navigator.of(context).pop();
            },
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }
}