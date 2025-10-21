import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_state.freezed.dart';
part 'mood_state.g.dart';

@freezed
class MoodState with _$MoodState {
  const factory MoodState({
    required String id,
    required String userId,
    required String mood, // e.g., 'happy', 'sad', 'neutral'
    required int rating, // 1-5
    required DateTime createdAt,
  }) = _MoodState;

  factory MoodState.fromJson(Map<String, dynamic> json) =>
      _$MoodStateFromJson(json);
}
