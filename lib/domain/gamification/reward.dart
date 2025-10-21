import 'package:freezed_annotation/freezed_annotation.dart';

part 'reward.freezed.dart';
part 'reward.g.dart';

@freezed
class Reward with _$Reward {
  const factory Reward({
    required String id,
    required String name,
    required String description,
    required int cost,
    required String type, // e.g., 'icon', 'theme', 'content'
  }) = _Reward;

  factory Reward.fromJson(Map<String, dynamic> json) => _$RewardFromJson(json);
}
