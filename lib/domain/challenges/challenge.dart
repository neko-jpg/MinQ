import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'challenge.freezed.dart';
part 'challenge.g.dart';

@freezed
class Challenge with _$Challenge {
  const factory Challenge({
    required String id,
    required String name,
    required String description,
    required String type, // e.g., 'daily', 'weekly', 'event'
    required int goal, // e.g., number of days for a streak
    required DateTime startDate,
    required DateTime endDate,
  }) = _Challenge;

  factory Challenge.fromJson(Map<String, dynamic> json) => _$ChallengeFromJson(json);
}