import 'package:freezed_annotation/freezed_annotation.dart';

part 'badge.freezed.dart';
part 'badge.g.dart';

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String name,
    required String description,
    required String imageUrl,
    required DateTime earnedAt,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}
