import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_archetype.freezed.dart';
part 'habit_archetype.g.dart';

@freezed
class HabitArchetype with _$HabitArchetype {
  const factory HabitArchetype({
    required String id,
    required String name,
    required String description,
    required List<String> strengths,
    required List<String> challenges,
  }) = _HabitArchetype;

  factory HabitArchetype.fromJson(Map<String, dynamic> json) =>
      _$HabitArchetypeFromJson(json);
}
