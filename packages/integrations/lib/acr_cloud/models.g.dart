// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

ACRCloudTrackMetadata _$ACRCloudTrackMetadataFromJson(
        Map<String, dynamic> json) =>
    ACRCloudTrackMetadata(
      title: json['title'] as String,
      album: json['album'] as String? ?? '',
      artists: (json['artists'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(),
      genres: (json['genres'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic e) => e.toString())
          .toList(),
      playOffsetMs: json['playOffsetMs'] as int? ?? 0,
    );

Map<String, dynamic> _$ACRCloudTrackMetadataToJson(
        ACRCloudTrackMetadata instance) =>
    <String, dynamic>{
      'title': instance.title,
      'album': instance.album,
      'artists': instance.artists,
      'genres': instance.genres,
      'playOffsetMs': instance.playOffsetMs,
    };

ACRCloudResult _$ACRCloudResultFromJson(Map<String, dynamic> json) =>
    ACRCloudResult(
      metadata: ACRCloudTrackMetadata.fromJson(
          json['metadata'] as Map<String, dynamic>),
      score: (json['score'] as num).toDouble(),
    );

Map<String, dynamic> _$ACRCloudResultToJson(ACRCloudResult instance) =>
    <String, dynamic>{
      'metadata': instance.metadata,
      'score': instance.score,
    };
