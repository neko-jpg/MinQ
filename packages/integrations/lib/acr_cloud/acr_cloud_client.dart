import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:meta/meta.dart';

import 'package:miinq_integrations/acr_cloud/acr_cloud_config.dart';
import 'package:miinq_integrations/acr_cloud/models.dart';

/// A minimal client for the ACR Cloud identify API.
class ACRCloudClient {
  /// Creates a new [ACRCloudClient].
  ACRCloudClient({
    required http.Client httpClient,
    required ACRCloudConfig config,
  }) : _httpClient = httpClient,
       _config = config;

  final http.Client _httpClient;
  final ACRCloudConfig _config;

  /// Builds the signature for the HTTP request.
  /// See the ACR Cloud documentation for more details.
  @visibleForTesting
  String buildSignature({
    required String httpMethod,
    required String uri,
    required String accessKey,
    required String dataType,
    required String signatureVersion,
    required int timestamp,
  }) {
    final toSign = [
      httpMethod,
      uri,
      accessKey,
      dataType,
      signatureVersion,
      '$timestamp',
    ].join('\n');

    final key = utf8.encode(_config.accessSecret);
    final bytes = utf8.encode(toSign);
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// Identifies a song from an audio sample.
  ///
  /// Returns the [ACRCloudResult] if a match is found, otherwise `null`.
  Future<ACRCloudResult?> identify({
    required Uint8List audio,
    Duration? sampleLength,
  }) async {
    if (audio.isEmpty) {
      throw ArgumentError.value(
        audio,
        'audio',
        'Audio sample must not be empty',
      );
    }

    const endpoint = '/v1/identify';
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    const dataType = 'audio';
    const signatureVersion = '1';

    final signature = buildSignature(
      httpMethod: 'POST',
      uri: endpoint,
      accessKey: _config.accessKey,
      dataType: dataType,
      signatureVersion: signatureVersion,
      timestamp: timestamp,
    );

    final request =
        http.MultipartRequest(
            'POST',
            Uri.parse('https://${_config.host}$endpoint'),
          )
          ..fields['access_key'] = _config.accessKey
          ..fields['data_type'] = dataType
          ..fields['signature_version'] = signatureVersion
          ..fields['signature'] = signature
          ..fields['sample_bytes'] = audio.length.toString()
          ..fields['timestamp'] = timestamp.toString();

    if (sampleLength != null) {
      request.fields['sample_length'] = sampleLength.inSeconds.toString();
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'sample',
        audio,
        filename: 'sample.pcm',
        contentType: MediaType('application', 'octet-stream'),
      ),
    );

    final response = await _httpClient.send(request);
    final payload = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw ACRCloudException(
        'Identification failed: ${response.statusCode} $payload',
      );
    }

    final json = jsonDecode(payload) as Map<String, dynamic>;
    final status = json['status'] as Map<String, dynamic>?;
    if ((status?['code'] as int?) != 0) {
      throw ACRCloudException('ACRCloud error: ${status?['msg']}');
    }

    final metadata = json['metadata'] as Map<String, dynamic>?;
    final musicMatches = metadata?['music'] as List<dynamic>?;
    if (musicMatches == null || musicMatches.isEmpty) {
      return null;
    }

    final track = musicMatches.first as Map<String, dynamic>;
    final title = track['title'] as String? ?? '';
    final album =
        (track['album'] as Map<String, dynamic>?)?['name'] as String? ?? '';
    final artists =
        (track['artists'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => (e as Map<String, dynamic>)['name'] as String)
            .toList();
    final genres =
        (track['genres'] as List<dynamic>? ?? <dynamic>[])
            .map((dynamic e) => (e as Map<String, dynamic>)['name'] as String)
            .toList();
    final score = (track['score'] as num?)?.toDouble() ?? 0;
    final playOffset = (track['play_offset_ms'] as num?)?.toInt() ?? 0;

    return ACRCloudResult(
      metadata: ACRCloudTrackMetadata(
        title: title,
        album: album,
        artists: artists,
        genres: genres,
        playOffsetMs: playOffset,
      ),
      score: score,
    );
  }
}

/// An exception thrown when the ACR Cloud API returns an error.
class ACRCloudException implements Exception {
  /// Creates a new [ACRCloudException].
  ACRCloudException(this.message);

  /// The error message.
  final String message;

  @override
  String toString() => 'ACRCloudException: $message';
}
