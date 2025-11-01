import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/database/database_service.dart';
import 'package:minq/domain/analytics/dashboard_config.dart';

/// カスタムダッシュボードサービス
class DashboardService {
  final DatabaseService _databaseService;

  DashboardService(this._databaseService);

  /// ユーザーのダッシュボード設定を取得
  Future<List<CustomDashboardConfig>> getUserDashboards(String userId) async {
    try {
      final dashboards = await _databaseService.getUserDashboards(userId);
      if (dashboards.isEmpty) {
        // デフォルトダッシュボードを作成
        return await _createDefaultDashboards(userId);
      }
      return dashboards;
    } catch (e) {
      // エラー時はデフォルトダッシュボードを返す
      return [DefaultDashboardConfigs.overview];
    }
  }

  /// デフォルトダッシュボードを取得
  Future<CustomDashboardConfig> getDefaultDashboard() async {
    return DefaultDashboardConfigs.overview;
  }

  /// ダッシュボード設定を保存
  Future<void> saveDashboardConfig(
    String userId,
    CustomDashboardConfig config,
  ) async {
    await _databaseService.saveDashboardConfig(userId, config);
  }

  /// ウィジェット設定を更新
  Future<void> updateWidgetConfig(
    String userId,
    String dashboardId,
    DashboardWidgetConfig widgetConfig,
  ) async {
    final dashboards = await getUserDashboards(userId);
    final dashboardIndex = dashboards.indexWhere((d) => d.id == dashboardId);

    if (dashboardIndex == -1) return;

    final dashboard = dashboards[dashboardIndex];
    final widgets = List<DashboardWidgetConfig>.from(dashboard.widgets);
    final widgetIndex = widgets.indexWhere((w) => w.id == widgetConfig.id);

    if (widgetIndex != -1) {
      widgets[widgetIndex] = widgetConfig.copyWith(updatedAt: DateTime.now());
    } else {
      widgets.add(widgetConfig);
    }

    final updatedDashboard = dashboard.copyWith(
      widgets: widgets,
      updatedAt: DateTime.now(),
    );

    await saveDashboardConfig(userId, updatedDashboard);
  }

  /// ウィジェットを削除
  Future<void> removeWidget(
    String userId,
    String dashboardId,
    String widgetId,
  ) async {
    final dashboards = await getUserDashboards(userId);
    final dashboardIndex = dashboards.indexWhere((d) => d.id == dashboardId);

    if (dashboardIndex == -1) return;

    final dashboard = dashboards[dashboardIndex];
    final widgets = dashboard.widgets.where((w) => w.id != widgetId).toList();

    final updatedDashboard = dashboard.copyWith(
      widgets: widgets,
      updatedAt: DateTime.now(),
    );

    await saveDashboardConfig(userId, updatedDashboard);
  }

  /// ウィジェットを追加
  Future<void> addWidget(
    String userId,
    String dashboardId,
    DashboardWidgetConfig widgetConfig,
  ) async {
    final dashboards = await getUserDashboards(userId);
    final dashboardIndex = dashboards.indexWhere((d) => d.id == dashboardId);

    if (dashboardIndex == -1) return;

    final dashboard = dashboards[dashboardIndex];
    final widgets = List<DashboardWidgetConfig>.from(dashboard.widgets);

    // 適切な位置を計算
    final position = _calculateOptimalPosition(widgets, dashboard.layout);
    final newWidget = widgetConfig.copyWith(
      position: position,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widgets.add(newWidget);

    final updatedDashboard = dashboard.copyWith(
      widgets: widgets,
      updatedAt: DateTime.now(),
    );

    await saveDashboardConfig(userId, updatedDashboard);
  }

  /// ダッシュボードを複製
  Future<CustomDashboardConfig> duplicateDashboard(
    String userId,
    String dashboardId,
    String newName,
  ) async {
    final dashboards = await getUserDashboards(userId);
    final originalDashboard = dashboards.firstWhere((d) => d.id == dashboardId);

    final duplicatedDashboard = originalDashboard.copyWith(
      id: 'dashboard_${DateTime.now().millisecondsSinceEpoch}',
      name: newName,
      isDefault: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await saveDashboardConfig(userId, duplicatedDashboard);
    return duplicatedDashboard;
  }

  /// ダッシュボードを削除
  Future<void> deleteDashboard(String userId, String dashboardId) async {
    await _databaseService.deleteDashboard(userId, dashboardId);
  }

  /// ダッシュボードレイアウトを更新
  Future<void> updateDashboardLayout(
    String userId,
    String dashboardId,
    DashboardLayout layout,
  ) async {
    final dashboards = await getUserDashboards(userId);
    final dashboardIndex = dashboards.indexWhere((d) => d.id == dashboardId);

    if (dashboardIndex == -1) return;

    final dashboard = dashboards[dashboardIndex];
    final updatedDashboard = dashboard.copyWith(
      layout: layout,
      updatedAt: DateTime.now(),
    );

    await saveDashboardConfig(userId, updatedDashboard);
  }

  /// ウィジェットの位置を更新
  Future<void> updateWidgetPositions(
    String userId,
    String dashboardId,
    List<DashboardWidgetConfig> widgets,
  ) async {
    final dashboards = await getUserDashboards(userId);
    final dashboardIndex = dashboards.indexWhere((d) => d.id == dashboardId);

    if (dashboardIndex == -1) return;

    final dashboard = dashboards[dashboardIndex];
    final updatedDashboard = dashboard.copyWith(
      widgets:
          widgets.map((w) => w.copyWith(updatedAt: DateTime.now())).toList(),
      updatedAt: DateTime.now(),
    );

    await saveDashboardConfig(userId, updatedDashboard);
  }

  /// 利用可能なウィジェットタイプを取得
  List<DashboardWidgetType> getAvailableWidgetTypes() {
    return DashboardWidgetType.values;
  }

  /// ウィジェットタイプの説明を取得
  String getWidgetTypeDescription(DashboardWidgetType type) {
    switch (type) {
      case DashboardWidgetType.streakCounter:
        return 'ストリーク数を表示';
      case DashboardWidgetType.completionRate:
        return '完了率を表示';
      case DashboardWidgetType.timePattern:
        return '時間帯別のパフォーマンス';
      case DashboardWidgetType.categoryBreakdown:
        return 'カテゴリ別の分析';
      case DashboardWidgetType.goalProgress:
        return '目標の進捗状況';
      case DashboardWidgetType.weeklyTrend:
        return '週間のトレンド';
      case DashboardWidgetType.monthlyHeatmap:
        return '月間のヒートマップ';
      case DashboardWidgetType.insights:
        return 'AIインサイト';
      case DashboardWidgetType.predictions:
        return '予測と警告';
      case DashboardWidgetType.achievements:
        return '実績と達成';
      case DashboardWidgetType.comparisons:
        return '他ユーザーとの比較';
      case DashboardWidgetType.customChart:
        return 'カスタムチャート';
    }
  }

  // プライベートメソッド

  Future<List<CustomDashboardConfig>> _createDefaultDashboards(
    String userId,
  ) async {
    final defaultDashboards = [
      DefaultDashboardConfigs.overview,
      DefaultDashboardConfigs.detailed,
    ];

    for (final dashboard in defaultDashboards) {
      await saveDashboardConfig(userId, dashboard);
    }

    return defaultDashboards;
  }

  WidgetPosition _calculateOptimalPosition(
    List<DashboardWidgetConfig> existingWidgets,
    DashboardLayout layout,
  ) {
    // 既存のウィジェットの位置を確認して、空いている位置を見つける
    final occupiedPositions = existingWidgets.map((w) => w.position).toSet();

    for (int row = 0; row < 10; row++) {
      for (int col = 0; col < layout.columns; col++) {
        final position = WidgetPosition(row: row, column: col);
        if (!occupiedPositions.contains(position)) {
          return position;
        }
      }
    }

    // 空いている位置がない場合は最下部に配置
    final maxRow = existingWidgets.fold<int>(
      0,
      (max, w) => w.position.row > max ? w.position.row : max,
    );
    return WidgetPosition(row: maxRow + 1, column: 0);
  }
}

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return DashboardService(databaseService);
});
