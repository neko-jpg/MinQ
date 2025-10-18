import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_ecosystem.freezed.dart';
part 'habit_ecosystem.g.dart';

@freezed
class HabitEcosystem with _$HabitEcosystem {
  const factory HabitEcosystem({
    required String id,
    required String userId,
    required Map<String, List<String>> connections, // habitId -> list of connected habitIds
    required DateTime lastUpdated,
  }) = _HabitEcosystem;

  factory HabitEcosystem.fromJson(Map<String, dynamic> json) => _$HabitEcosystemFromJson(json);
}