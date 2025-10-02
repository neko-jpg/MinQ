import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class StatsViewData {
  const StatsViewData({
    required this.streak,
    required this.heatmap,
    required this.updatedAt,
  });

  factory StatsViewData.empty() {
    return StatsViewData(
      streak: 0,
      heatmap: const <DateTime, int>{},
      updatedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
    );
  }

  factory StatsViewData.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString) as Map<String, dynamic>;
    final Map<String, dynamic> heatmapJson = json['heatmap'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    final Map<DateTime, int> decodedHeatmap = <DateTime, int>{};
    for (final MapEntry<String, dynamic> entry in heatmapJson.entries) {
      final DateTime? day = DateTime.tryParse(entry.key);
      if (day == null) continue;
      decodedHeatmap[day.toLocal()] = (entry.value as num).toInt();
    }
    return StatsViewData(
      streak: json['streak'] as int? ?? 0,
      heatmap: decodedHeatmap,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal(),
    );
  }

  final int streak;
  final Map<DateTime, int> heatmap;
  final DateTime updatedAt;

  bool get hasCachedContent => streak > 0 || heatmap.isNotEmpty;

  String toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'streak': streak,
      'heatmap': <String, int>{
        for (final MapEntry<DateTime, int> entry in heatmap.entries)
          entry.key.toUtc().toIso8601String(): entry.value,
      },
      'updatedAt': updatedAt.toUtc().toIso8601String(),
    };
    return jsonEncode(json);
  }

  StatsViewData copyWith({
    int? streak,
    Map<DateTime, int>? heatmap,
    DateTime? updatedAt,
  }) {
    return StatsViewData(
      streak: streak ?? this.streak,
      heatmap: heatmap ?? this.heatmap,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StatsViewData &&
        other.streak == streak &&
        mapEquals(other.heatmap, heatmap) &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode => Object.hash(streak, Object.hashAllUnordered(heatmap.entries), updatedAt);
}
