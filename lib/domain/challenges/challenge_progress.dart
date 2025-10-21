import 'package:freezed_annotation/freezed_annotation.dart';

part 'challenge_progress.freezed.dart';
part 'challenge_progress.g.dart';

@freezed
class ChallengeProgress with _$ChallengeProgress {
  const factory ChallengeProgress({
    required String id,
    required String userId,
    required String challengeId,
    required int progress,
    required bool completed,
  }) = _ChallengeProgress;

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) =>
      _$ChallengeProgressFromJson(json);
}
