import 'package:freezed_annotation/freezed_annotation.dart';

part 'points.freezed.dart';
part 'points.g.dart';

@freezed
class Points with _$Points {
  const factory Points({
    required String id,
    required String userId,
    required int value,
    required String reason,
    required DateTime createdAt,
  }) = _Points;

  factory Points.fromJson(Map<String, dynamic> json) => _$PointsFromJson(json);
}
