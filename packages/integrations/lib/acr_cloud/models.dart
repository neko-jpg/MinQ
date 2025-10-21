import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

@JsonSerializable()
class ACRCloudTrackMetadata {
  ACRCloudTrackMetadata({
    required this.title,
    required this.album,
    required this.artists,
    required this.genres,
    required this.playOffsetMs,
  });

  factory ACRCloudTrackMetadata.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudTrackMetadataFromJson(json);

  final String title;
  final String album;
  final List<String> artists;
  final List<String> genres;
  final int playOffsetMs;

  Map<String, dynamic> toJson() => _$ACRCloudTrackMetadataToJson(this);
}

@JsonSerializable()
class ACRCloudResult {
  ACRCloudResult({required this.metadata, required this.score});

  factory ACRCloudResult.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResultFromJson(json);

  final ACRCloudTrackMetadata metadata;
  final double score;

  Map<String, dynamic> toJson() => _$ACRCloudResultToJson(this);
}
