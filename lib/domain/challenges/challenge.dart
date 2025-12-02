import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
class Challenge with _$Challenge {
  const Challenge._();

  const factory Challenge({
    required String id,
    required String name,
    required String description,
    required String type, // e.g., 'daily', 'weekly', 'event'
    required int goal, // e.g., number of days for a streak
    required DateTime startDate,
    required DateTime endDate,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) =>
      _$ChallengeFromJson(json);

  // Aliases for compatibility
  String get title => name;
  int get targetValue => goal;
  int get rewardPoints => 100; // Default
  // currentProgress is not here, should be handled by UI or wrapper
}
