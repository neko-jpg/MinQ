import 'package:flutter/foundation.dart';

/// ダッシュボードウィジェットの種類
enum DashboardWidgetType {
  streakCounter,
  completionRate,
  timePattern,
  categoryBreakdown,
  goalProgress,
  weeklyTrend,
  monthlyHeatmap,
  insights,
  predictions,
  achievements,
  comparisons,
  customChart,
}

/// ダッシュボードウィジェット設定
@immutable
class DashboardWidgetConfig {
  const DashboardWidgetConfig({
    required this.id,
    required this.type,
    required this.title,
    required this.position,
    required this.size,
    required this.isVisible,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DashboardWidgetType type;
  final String title;
  final WidgetPosition position;
  final WidgetSize size;
  final bool isVisible;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  DashboardWidgetConfig copyWith({
    String? id,
    DashboardWidgetType? type,
    String? title,
    WidgetPosition? position,
    WidgetSize? size,
    bool? isVisible,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DashboardWidgetConfig(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      position: position ?? this.position,
      size: size ?? this.size,
      isVisible: isVisible ?? this.isVisible,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardWidgetConfig &&
        other.id == id &&
        other.type == type &&
        other.title == title &&
        other.position == position &&
        other.size == size &&
        other.isVisible == isVisible &&
        mapEquals(other.settings, settings) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    title,
    position,
    size,
    isVisible,
    Object.hashAllUnordered(settings.entries),
    createdAt,
    updatedAt,
  );
}

/// ウィジェットの位置
@immutable
class WidgetPosition {
  const WidgetPosition({required this.row, required this.column});

  final int row;
  final int column;

  WidgetPosition copyWith({int? row, int? column}) {
    return WidgetPosition(row: row ?? this.row, column: column ?? this.column);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WidgetPosition &&
        other.row == row &&
        other.column == column;
  }

  @override
  int get hashCode => Object.hash(row, column);
}

/// ウィジェットのサイズ
@immutable
class WidgetSize {
  const WidgetSize({required this.width, required this.height});

  final int width; // Grid units
  final int height; // Grid units

  WidgetSize copyWith({int? width, int? height}) {
    return WidgetSize(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WidgetSize &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}

/// カスタムダッシュボード設定
@immutable
class CustomDashboardConfig {
  const CustomDashboardConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.widgets,
    required this.layout,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final List<DashboardWidgetConfig> widgets;
  final DashboardLayout layout;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomDashboardConfig copyWith({
    String? id,
    String? name,
    String? description,
    List<DashboardWidgetConfig>? widgets,
    DashboardLayout? layout,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomDashboardConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      widgets: widgets ?? this.widgets,
      layout: layout ?? this.layout,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomDashboardConfig &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        listEquals(other.widgets, widgets) &&
        other.layout == layout &&
        other.isDefault == isDefault &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    Object.hashAllUnordered(widgets),
    layout,
    isDefault,
    createdAt,
    updatedAt,
  );
}

/// ダッシュボードレイアウト
@immutable
class DashboardLayout {
  const DashboardLayout({
    required this.columns,
    required this.rowHeight,
    required this.spacing,
  });

  final int columns;
  final double rowHeight;
  final double spacing;

  DashboardLayout copyWith({int? columns, double? rowHeight, double? spacing}) {
    return DashboardLayout(
      columns: columns ?? this.columns,
      rowHeight: rowHeight ?? this.rowHeight,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DashboardLayout &&
        other.columns == columns &&
        other.rowHeight == rowHeight &&
        other.spacing == spacing;
  }

  @override
  int get hashCode => Object.hash(columns, rowHeight, spacing);
}

/// デフォルトダッシュボード設定
class DefaultDashboardConfigs {
  static final overview = CustomDashboardConfig(
    id: 'overview',
    name: '概要',
    description: '全体的な進捗と主要な指標を表示',
    widgets: [
      DashboardWidgetConfig(
        id: 'streak',
        type: DashboardWidgetType.streakCounter,
        title: 'ストリーク',
        position: WidgetPosition(row: 0, column: 0),
        size: WidgetSize(width: 2, height: 1),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      DashboardWidgetConfig(
        id: 'completion_rate',
        type: DashboardWidgetType.completionRate,
        title: '完了率',
        position: WidgetPosition(row: 0, column: 2),
        size: WidgetSize(width: 2, height: 1),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      DashboardWidgetConfig(
        id: 'weekly_trend',
        type: DashboardWidgetType.weeklyTrend,
        title: '週間トレンド',
        position: WidgetPosition(row: 1, column: 0),
        size: WidgetSize(width: 4, height: 2),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      DashboardWidgetConfig(
        id: 'insights',
        type: DashboardWidgetType.insights,
        title: 'インサイト',
        position: WidgetPosition(row: 3, column: 0),
        size: WidgetSize(width: 4, height: 2),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
    ],
    layout: DashboardLayout(columns: 4, rowHeight: 120, spacing: 16),
    isDefault: true,
    createdAt: _defaultDate,
    updatedAt: _defaultDate,
  );

  static final detailed = CustomDashboardConfig(
    id: 'detailed',
    name: '詳細分析',
    description: '詳細な分析とパターンを表示',
    widgets: [
      DashboardWidgetConfig(
        id: 'time_pattern',
        type: DashboardWidgetType.timePattern,
        title: '時間帯パターン',
        position: WidgetPosition(row: 0, column: 0),
        size: WidgetSize(width: 2, height: 2),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      DashboardWidgetConfig(
        id: 'category_breakdown',
        type: DashboardWidgetType.categoryBreakdown,
        title: 'カテゴリ別分析',
        position: WidgetPosition(row: 0, column: 2),
        size: WidgetSize(width: 2, height: 2),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      DashboardWidgetConfig(
        id: 'monthly_heatmap',
        type: DashboardWidgetType.monthlyHeatmap,
        title: '月間ヒートマップ',
        position: WidgetPosition(row: 2, column: 0),
        size: WidgetSize(width: 4, height: 2),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
      DashboardWidgetConfig(
        id: 'predictions',
        type: DashboardWidgetType.predictions,
        title: '予測・警告',
        position: WidgetPosition(row: 4, column: 0),
        size: WidgetSize(width: 4, height: 2),
        isVisible: true,
        settings: {},
        createdAt: _defaultDate,
        updatedAt: _defaultDate,
      ),
    ],
    layout: DashboardLayout(columns: 4, rowHeight: 120, spacing: 16),
    isDefault: false,
    createdAt: _defaultDate,
    updatedAt: _defaultDate,
  );

  static final DateTime _defaultDate = DateTime.utc(2024, 1, 1);
}
