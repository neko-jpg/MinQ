import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/widgets/analytics/dashboard_widget.dart';

class DashboardGrid extends StatefulWidget {
  final CustomDashboardConfig dashboard;
  final bool isEditMode;
  final Function(List<DashboardWidgetConfig>) onWidgetMoved;
  final Function(String) onWidgetRemoved;
  final Function(DashboardWidgetConfig) onWidgetConfigChanged;

  const DashboardGrid({
    super.key,
    required this.dashboard,
    required this.isEditMode,
    required this.onWidgetMoved,
    required this.onWidgetRemoved,
    required this.onWidgetConfigChanged,
  });

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  List<DashboardWidgetConfig> _widgets = [];

  @override
  void initState() {
    super.initState();
    _widgets = List.from(widget.dashboard.widgets);
  }

  @override
  void didUpdateWidget(DashboardGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dashboard != widget.dashboard) {
      _widgets = List.from(widget.dashboard.widgets);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleWidgets = _widgets.where((w) => w.isVisible).toList();
    
    if (visibleWidgets.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: EdgeInsets.all(widget.dashboard.layout.spacing),
      child: MasonryGridView.count(
        crossAxisCount: widget.dashboard.layout.columns,
        mainAxisSpacing: widget.dashboard.layout.spacing,
        crossAxisSpacing: widget.dashboard.layout.spacing,
        itemCount: visibleWidgets.length,
        itemBuilder: (context, index) {
          final widgetConfig = visibleWidgets[index];
          return _buildDashboardWidget(widgetConfig);
        },
      ),
    );
  }

  Widget _buildDashboardWidget(DashboardWidgetConfig widgetConfig) {
    return SizedBox(
      height: widget.dashboard.layout.rowHeight * widgetConfig.size.height,
      child: Stack(
        children: [
          DashboardWidget(
            config: widgetConfig,
            onConfigChanged: widget.onWidgetConfigChanged,
          ),
          if (widget.isEditMode) _buildEditOverlay(widgetConfig),
        ],
      ),
    );
  }

  Widget _buildEditOverlay(DashboardWidgetConfig widgetConfig) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // ドラッグハンドル
            Positioned(
              top: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.drag_handle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            // 削除ボタン
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showDeleteConfirmation(widgetConfig),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            // 設定ボタン
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _showWidgetSettings(widgetConfig),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.dashboard,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'ウィジェットがありません',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'メニューからウィジェットを追加してください',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(DashboardWidgetConfig widgetConfig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ウィジェットを削除'),
        content: Text('「${widgetConfig.title}」を削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              widget.onWidgetRemoved(widgetConfig.id);
              Navigator.of(context).pop();
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showWidgetSettings(DashboardWidgetConfig widgetConfig) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ウィジェット設定',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'タイトル',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: widgetConfig.title),
              onChanged: (value) {
                final updatedConfig = widgetConfig.copyWith(title: value);
                widget.onWidgetConfigChanged(updatedConfig);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('表示'),
                Switch(
                  value: widgetConfig.isVisible,
                  onChanged: (value) {
                    final updatedConfig = widgetConfig.copyWith(isVisible: value);
                    widget.onWidgetConfigChanged(updatedConfig);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'サイズ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('幅: '),
                DropdownButton<int>(
                  value: widgetConfig.size.width,
                  items: [1, 2, 3, 4].map((width) => DropdownMenuItem(
                    value: width,
                    child: Text('$width'),
                  )).toList(),
                  onChanged: (width) {
                    if (width != null) {
                      final updatedSize = widgetConfig.size.copyWith(width: width);
                      final updatedConfig = widgetConfig.copyWith(size: updatedSize);
                      widget.onWidgetConfigChanged(updatedConfig);
                    }
                  },
                ),
                const SizedBox(width: 16),
                const Text('高さ: '),
                DropdownButton<int>(
                  value: widgetConfig.size.height,
                  items: [1, 2, 3, 4].map((height) => DropdownMenuItem(
                    value: height,
                    child: Text('$height'),
                  )).toList(),
                  onChanged: (height) {
                    if (height != null) {
                      final updatedSize = widgetConfig.size.copyWith(height: height);
                      final updatedConfig = widgetConfig.copyWith(size: updatedSize);
                      widget.onWidgetConfigChanged(updatedConfig);
                    }
                  },
                ),
              ],
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
}