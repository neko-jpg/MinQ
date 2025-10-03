import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:miinq_integrations/acr_cloud/acr_cloud_client.dart';
import 'package:miinq_integrations/acr_cloud/acr_cloud_config.dart';

class _FakeHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = await request.finalize().toBytes();
    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

void main() {
  group('ACRCloudClient', () {
    late ACRCloudClient client;

    setUp(() {
      client = ACRCloudClient(
        httpClient: _FakeHttpClient(),
        config: const ACRCloudConfig(
          host: 'identify-eu-west-1.acrcloud.com',
          accessKey: 'test_key',
          accessSecret: 'test_secret',
        ),
      );
    });

    test('generates expected signature for known inputs', () {
      const timestamp = 1700000000;
      final signature = client.buildSignature(
        httpMethod: 'POST',
        uri: '/v1/identify',
        accessKey: 'test_key',
        dataType: 'audio',
        signatureVersion: '1',
        timestamp: timestamp,
      );

      expect(signature, 'wNp6ZoIsfqg35w+9sai3KVDqTL8=');
    });

    test('throws when audio payload is empty', () async {
      await expectLater(
        () => client.identify(audio: Uint8List(0)),
        throwsArgumentError,
      );
    });
  });
}
