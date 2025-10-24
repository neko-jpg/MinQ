import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_habit_correlation.freezed.dart';
part 'mood_habit_correlation.g.dart';

@freezed
class MoodHabitCorrelation with _$MoodHabitCorrelation {
  const factory MoodHabitCorrelation({
    required String id,
    required String userId,
    required String habitId,
    required String mood,
    required double correlationScore, // -1.0 to 1.0
  }) = _MoodHabitCorrelation;

  factory MoodHabitCorrelation.fromJson(Map<String, dynamic> json) => _$MoodHabitCorrelationFromJson(json);
}