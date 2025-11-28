import 'package:freezed_annotation/freezed_annotation.dart';

part 'intervention_strategy.freezed.dart';
part 'intervention_strategy.g.dart';

@freezed
class InterventionStrategy with _$InterventionStrategy {
  const factory InterventionStrategy({
    required String id,
    required String name,
    required String description,
    required String type, // e.g., 'encouragement', 'goal_adjustment'
  }) = _InterventionStrategy;

  factory InterventionStrategy.fromJson(Map<String, dynamic> json) =>
      _$InterventionStrategyFromJson(json);
}
