import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure_prediction.freezed.dart';
part 'failure_prediction.g.dart';

@freezed
class FailurePredictionModel with _$FailurePredictionModel {
  const factory FailurePredictionModel({
    required String id,
    required String userId,
    required String habitId,
    required double predictionScore, // 0.0 to 1.0
    required DateTime createdAt,
  }) = _FailurePredictionModel;

  factory FailurePredictionModel.fromJson(Map<String, dynamic> json) =>
      _$FailurePredictionModelFromJson(json);
}
