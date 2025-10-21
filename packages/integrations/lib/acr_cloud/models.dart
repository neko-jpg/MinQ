import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// Deserialized track metadata from the ACR Cloud identify API.
@JsonSerializable()
class ACRCloudTrackMetadata {
  /// Creates a new [ACRCloudTrackMetadata].
  ACRCloudTrackMetadata({
    required this.title,
    required this.album,
    required this.artists,
    required this.genres,
    required this.playOffsetMs,
  });

  /// Creates a new [ACRCloudTrackMetadata] from a JSON map.
  factory ACRCloudTrackMetadata.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudTrackMetadataFromJson(json);

  /// The title of the track.
  final String title;

  /// The album of the track.
  final String album;

  /// The artists of the track.
  final List<String> artists;

  /// The genres of the track.
  final List<String> genres;

  /// The play offset in milliseconds.
  final int playOffsetMs;

  /// Converts the [ACRCloudTrackMetadata] to a JSON map.
  Map<String, dynamic> toJson() => _$ACRCloudTrackMetadataToJson(this);
}

@JsonSerializable()
class ACRCloudResult {
  /// Creates a new [ACRCloudResult].
  ACRCloudResult({required this.metadata, required this.score});

  /// Creates a new [ACRCloudResult] from a JSON map.
  factory ACRCloudResult.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResultFromJson(json);

  /// The metadata for the track.
  final ACRCloudTrackMetadata metadata;

  /// The confidence score for the match.
  final double score;

  /// Converts the [ACRCloudResult] to a JSON map.
  Map<String, dynamic> toJson() => _$ACRCloudResultToJson(this);
}
