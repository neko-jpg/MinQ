import 'package:freezed_annotation/freezed_annotation.dart';

part 'success_pattern.freezed.dart';
part 'success_pattern.g.dart';

@freezed
class SuccessPattern with _$SuccessPattern {
  const factory SuccessPattern({
    required String id,
    required String userId,
    required String
    description, // e.g., "Completing 'Morning Run' increases 'Healthy Breakfast' success by 40%"
    required List<String> relatedHabitIds,
  }) = _SuccessPattern;

  factory SuccessPattern.fromJson(Map<String, dynamic> json) =>
      _$SuccessPatternFromJson(json);
}
