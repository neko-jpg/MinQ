import 'dart:convert';

import 'package:meta/meta.dart';

/// Configuration required for invoking the ACR Cloud identify API.
@immutable
class ACRCloudConfig {
  const ACRCloudConfig({
    required this.host,
    required this.accessKey,
    required this.accessSecret,
  });

  factory ACRCloudConfig.fromJson(Map<String, dynamic> json) {
    return ACRCloudConfig(
      host: json['host'] as String,
      accessKey: json['accessKey'] as String,
      accessSecret: json['accessSecret'] as String,
    );
  }

  factory ACRCloudConfig.fromBase64(String encoded) {
    return ACRCloudConfig.fromJson(
      jsonDecode(utf8.decode(base64Decode(encoded))) as Map<String, dynamic>,
    );
  }

  final String host;
  final String accessKey;
  final String accessSecret;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'host': host,
        'accessKey': accessKey,
        'accessSecret': accessSecret,
      };
}
