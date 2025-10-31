import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';
import 'package:minq/presentation/providers/analytics_providers.dart';
import 'package:minq/presentation/widgets/analytics/dashboard_grid.dart';
import 'package:minq/presentation/widgets/analytics/dashboard_header.dart';
import 'package:minq/presentation/widgets/analytics/widget_selector_sheet.dart';

class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  String _selectedDashboardId = 'overview';
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    final dashboards = ref.watch(userDashboardsProvider);
    final selectedDashboard = ref.watch(selectedDashboardProvider(_selectedDashboardId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('データ分析'),
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'add_widget',
                child: ListTile(
                  leading: Icon(Icons.add_box),
                  title: Text('ウィジェットを追加'),
                ),
              ),
              const PopupMenuItem(
                value: 'duplicate_dashboard',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('ダッシュボードを複製'),
                ),
              ),
              const PopupMenuItem(
                value: 'reset_layout',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('レイアウトをリセット'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: dashboards.when(
        data: (dashboardList) => selectedDashboard.when(
          data: (dashboard) => _buildDashboard(dashboard),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(error),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
      bottomNavigationBar: dashboards.when(
        data: (dashboardList) => _buildDashboardSelector(dashboardList),
        loading: () => null,
        error: (error, stack) => null,
      ),
    );
  }

  Widget _buildDashboard(CustomDashboardConfig dashboard) {
    return Column(
      children: [
        DashboardHeader(
          dashboard: dashboard,
          isEditMode: _isEditMode,
          onLayoutChanged: (layout) {
            ref.read(dashboardServiceProvider).updateDashboardLayout(
              'current_user', // TODO: 実際のユーザーIDを使用
              dashboard.id,
              layout,
            );
          },
        ),
        Expanded(
          child: DashboardGrid(
            dashboard: dashboard,
            isEditMode: _isEditMode,
            onWidgetMoved: (widgets) {
              ref.read(dashboardServiceProvider).updateWidgetPositions(
                'current_user', // TODO: 実際のユーザーIDを使用
                dashboard.id,
                widgets,
              );
            },
            onWidgetRemoved: (widgetId) {
              ref.read(dashboardServiceProvider).removeWidget(
                'current_user', // TODO: 実際のユーザーIDを使用
                dashboard.id,
                widgetId,
              );
            },
            onWidgetConfigChanged: (widgetConfig) {
              ref.read(dashboardServiceProvider).updateWidgetConfig(
                'current_user', // TODO: 実際のユーザーIDを使用
                dashboard.id,
                widgetConfig,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardSelector(List<CustomDashboardConfig> dashboards) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dashboards.length,
        itemBuilder: (context, index) {
          final dashboard = dashboards[index];
          final isSelected = dashboard.id == _selectedDashboardId;
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDashboardId = dashboard.id;
                });
              },
              child: Container(
                width: 120,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getDashboardIcon(dashboard.id),
                      color: isSelected 
                          ? Colors.white
                          : Theme.of(context).iconTheme.color,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dashboard.name,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'データの読み込みに失敗しました',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(userDashboardsProvider);
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'add_widget':
        _showWidgetSelector();
        break;
      case 'duplicate_dashboard':
        _duplicateDashboard();
        break;
      case 'reset_layout':
        _resetLayout();
        break;
    }
  }

  void _showWidgetSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => WidgetSelectorSheet(
        dashboardId: _selectedDashboardId,
        onWidgetSelected: (widgetType) {
          final widgetConfig = DashboardWidgetConfig(
            id: 'widget_${DateTime.now().millisecondsSinceEpoch}',
            type: widgetType,
            title: ref.read(dashboardServiceProvider).getWidgetTypeDescription(widgetType),
            position: const WidgetPosition(row: 0, column: 0),
            size: _getDefaultWidgetSize(widgetType),
            isVisible: true,
            settings: const {},
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          ref.read(dashboardServiceProvider).addWidget(
            'current_user', // TODO: 実際のユーザーIDを使用
            _selectedDashboardId,
            widgetConfig,
          );
        },
      ),
    );
  }

  void _duplicateDashboard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ダッシュボードを複製'),
        content: TextField(
          decoration: const InputDecoration(
            labelText: '新しいダッシュボード名',
            hintText: '例: カスタムダッシュボード',
          ),
          onSubmitted: (name) {
            if (name.isNotEmpty) {
              ref.read(dashboardServiceProvider).duplicateDashboard(
                'current_user', // TODO: 実際のユーザーIDを使用
                _selectedDashboardId,
                name,
              );
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
        ],
      ),
    );
  }

  void _resetLayout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('レイアウトをリセット'),
        content: const Text('ダッシュボードのレイアウトをデフォルトに戻しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              // TODO: レイアウトリセット機能を実装
              Navigator.of(context).pop();
            },
            child: const Text('リセット'),
          ),
        ],
      ),
    );
  }

  IconData _getDashboardIcon(String dashboardId) {
    switch (dashboardId) {
      case 'overview':
        return Icons.dashboard;
      case 'detailed':
        return Icons.analytics;
      default:
        return Icons.view_module;
    }
  }

  WidgetSize _getDefaultWidgetSize(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.streakCounter:
      case DashboardWidgetType.completionRate:
        return const WidgetSize(width: 2, height: 1);
      case DashboardWidgetType.timePattern:
      case DashboardWidgetType.categoryBreakdown:
        return const WidgetSize(width: 2, height: 2);
      case DashboardWidgetType.weeklyTrend:
      case DashboardWidgetType.monthlyHeatmap:
      case DashboardWidgetType.insights:
      case DashboardWidgetType.predictions:
        return const WidgetSize(width: 4, height: 2);
      default:
        return const WidgetSize(width: 2, height: 2);
    }
  }
}