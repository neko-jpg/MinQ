import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/services/time_consistency_service.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'time_consistency_service_test.mocks.dart';

@GenerateMocks([HttpClient, HttpClientRequest, HttpClientResponse, HttpHeaders])
void main() {
  test('reports consistent device time within tolerance', () async {
    final serverTime = DateTime.now().toUtc();
    final response = MockHttpClientResponse();
    final request = MockHttpClientRequest();
    final client = MockHttpClient();

    when(client.openUrl(any, any)).thenAnswer((_) async => request);
    when(request.close()).thenAnswer((_) async => response);
    when(response.headers).thenReturn(MockHttpHeaders());
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.headers.value(HttpHeaders.dateHeader)).thenReturn(HttpDate.format(serverTime));

    final service = TimeConsistencyService(
      httpClient: client,
      tolerance: const Duration(minutes: 3),
      probeUri: Uri.parse('https://example.com'),
    );

    expect(await service.isDeviceTimeConsistent(), isTrue);
    service.close();
  });

  test('detects drift beyond tolerance', () async {
    final serverTime = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
    final response = MockHttpClientResponse();
    final request = MockHttpClientRequest();
    final client = MockHttpClient();

    when(client.openUrl(any, any)).thenAnswer((_) async => request);
    when(request.close()).thenAnswer((_) async => response);
    when(response.headers).thenReturn(MockHttpHeaders());
    when(response.statusCode).thenReturn(HttpStatus.ok);
    when(response.headers.value(HttpHeaders.dateHeader)).thenReturn(HttpDate.format(serverTime));

    final service = TimeConsistencyService(
      httpClient: client,
      tolerance: const Duration(minutes: 3),
      probeUri: Uri.parse('https://example.com'),
    );

    expect(await service.isDeviceTimeConsistent(), isFalse);
    service.close();
  });
}