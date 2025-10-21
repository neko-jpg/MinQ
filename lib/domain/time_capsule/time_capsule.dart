import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_capsule.freezed.dart';
part 'time_capsule.g.dart';

@freezed
class TimeCapsule with _$TimeCapsule {
  const factory TimeCapsule({
    required String id,
    required String userId,
    required String message,
    required String prediction,
    required DateTime createdAt,
    required DateTime deliveryDate,
  }) = _TimeCapsule;

  factory TimeCapsule.fromJson(Map<String, dynamic> json) =>
      _$TimeCapsuleFromJson(json);
}
