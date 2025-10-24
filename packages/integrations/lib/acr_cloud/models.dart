import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// Metadata for a track identified by ACR Cloud.
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

  /// Creates a new [ACRCloudTrackMetadata] from a JSON object.
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

  /// The offset in milliseconds from the beginning of the audio sample.
  final int playOffsetMs;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() => _$ACRCloudTrackMetadataToJson(this);
}

/// A successful result from the ACR Cloud identify API.
@JsonSerializable()
class ACRCloudResult {
  /// Creates a new [ACRCloudResult].
  ACRCloudResult({required this.metadata, required this.score});

  /// Creates a new [ACRCloudResult] from a JSON object.
  factory ACRCloudResult.fromJson(Map<String, dynamic> json) =>
      _$ACRCloudResultFromJson(json);

  /// The metadata of the identified track.
  final ACRCloudTrackMetadata metadata;

  /// The confidence score of the identification (0-100).
  final double score;

  /// Converts this object to a JSON map.
  Map<String, dynamic> toJson() => _$ACRCloudResultToJson(this);
}
