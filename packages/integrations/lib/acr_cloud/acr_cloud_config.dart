import 'dart:convert';

import 'package:meta/meta.dart';

/// Configuration required for invoking the ACR Cloud identify API.
@immutable
class ACRCloudConfig {
  /// Creates a new [ACRCloudConfig].
  const ACRCloudConfig({
    required this.host,
    required this.accessKey,
    required this.accessSecret,
  });

  /// Creates a new [ACRCloudConfig] from a JSON map.
  factory ACRCloudConfig.fromJson(Map<String, dynamic> json) {
    return ACRCloudConfig(
      host: json['host'] as String,
      accessKey: json['accessKey'] as String,
      accessSecret: json['accessSecret'] as String,
    );
  }

  /// Creates a new [ACRCloudConfig] from a base64-encoded JSON string.
  factory ACRCloudConfig.fromBase64(String encoded) {
    return ACRCloudConfig.fromJson(
      jsonDecode(utf8.decode(base64Decode(encoded))) as Map<String, dynamic>,
    );
  }

  /// The ACR Cloud API host.
  final String host;

  /// The ACR Cloud API access key.
  final String accessKey;

  /// The ACR Cloud API access secret.
  final String accessSecret;

  /// Converts the [ACRCloudConfig] to a JSON map.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'host': host,
        'accessKey': accessKey,
        'accessSecret': accessSecret,
      };
}
