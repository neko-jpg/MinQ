import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:minq/data/providers.dart';
import 'package:minq/domain/music/music_tag_result.dart';
// TODO: Fix integrations package
// import 'package:miinq_integrations/miinq_integrations.dart';
import 'package:riverpod/riverpod.dart';

// Dummy types until integrations package is fixed
class ACRCloudClient {
  const ACRCloudClient({required dynamic httpClient, required dynamic config});
  Future<dynamic> identify({required dynamic audio}) async => null;
}
class ACRCloudConfig {
  static ACRCloudConfig? fromBase64(String encoded) => null;
}

class ACRMuiscTaggingService {
  ACRMuiscTaggingService({
    required ACRCloudClient client,
    required http.Client httpClient,
  })  : _client = client,
        _httpClient = httpClient;

  final ACRCloudClient _client;
  final http.Client _httpClient;

  Future<MusicTagResult?> identifyTrack(Uint8List audio) async {
    final result = await _client.identify(audio: audio);
    if (result == null) {
      return null;
    }
    return MusicTagResult(
      title: result.metadata.title,
      album: result.metadata.album,
      artists: result.metadata.artists,
      score: result.score,
      genres: result.metadata.genres,
    );
  }

  Future<MusicTagResult?> identifyFromUrl(Uri audioUrl) async {
    final response = await _httpClient.get(audioUrl);
    if (response.statusCode >= 400) {
      throw Exception('音源の取得に失敗しました (${response.statusCode})');
    }
    return identifyTrack(Uint8List.fromList(response.bodyBytes));
  }
}

final acrCloudConfigProvider = Provider<ACRCloudConfig?>((ref) {
  final remoteConfig = ref.watch(remoteConfigServiceProvider);
  final encoded = remoteConfig.tryGetString('acr_cloud_credentials');
  if (encoded == null || encoded.isEmpty) {
    return null;
  }
  try {
    return ACRCloudConfig.fromBase64(encoded);
  } catch (_) {
    return null;
  }
});

final acrMusicTaggingServiceProvider = Provider<ACRMuiscTaggingService?>((ref) {
  final config = ref.watch(acrCloudConfigProvider);
  if (config == null) {
    return null;
  }
  final client = ACRCloudClient(
    httpClient: ref.watch(httpClientProvider),
    config: config,
  );
  return ACRMuiscTaggingService(
    client: client,
    httpClient: ref.watch(httpClientProvider),
  );
});
