import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_analysis.freezed.dart';
part 'habit_analysis.g.dart';

@freezed
class HabitAnalysis with _$HabitAnalysis {
  const factory HabitAnalysis({
    required String id,
    required String userId,
    required String habitId,
    required double successRate,
    required Map<String, double> successByDay, // e.g., {'Monday': 0.8, ...}
    required Map<String, double> successByTime, // e.g., {'Morning': 0.9, ...}
    required DateTime lastUpdated,
  }) = _HabitAnalysis;

  factory HabitAnalysis.fromJson(Map<String, dynamic> json) =>
      _$HabitAnalysisFromJson(json);
}
