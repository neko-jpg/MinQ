import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/services/time_consistency_service.dart';
import 'package:test/fake.dart';

class _FakeHttpClient extends Fake implements HttpClient {
  _FakeHttpClient(this._response);

  final _FakeHttpClientResponse _response;

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    return _FakeHttpClientRequest(_response);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  _FakeHttpClientRequest(this._response);

  final _FakeHttpClientResponse _response;
  final HttpHeaders _headers = HttpHeaders();
  bool _followRedirects = true;
  Encoding _encoding = utf8;

  @override
  Future<HttpClientResponse> close() async => _response;

  @override
  void abort([Object? exception, StackTrace? stackTrace]) {}

  @override
  void add(List<int> data) {}

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) async {}

  @override
  Encoding get encoding => _encoding;

  @override
  set encoding(Encoding value) => _encoding = value;

  @override
  bool get followRedirects => _followRedirects;

  @override
  set followRedirects(bool value) => _followRedirects = value;

  @override
  HttpHeaders get headers => _headers;

  @override
  void write(Object? obj) {}

  @override
  void writeAll(Iterable objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? obj = '']) {}
}

class _FakeHttpClientResponse extends Stream<List<int>>
    implements HttpClientResponse {
  _FakeHttpClientResponse(DateTime serverTime)
      : _headers = (HttpHeaders()
          ..set(HttpHeaders.dateHeader, HttpDate.format(serverTime)));

  final HttpHeaders _headers;
  final Stream<List<int>> _emptyStream = const Stream<List<int>>.empty();

  @override
  HttpHeaders get headers => _headers;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => 0;

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  bool get redirected => false;

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  CompressionState get compressionState => CompressionState.notCompressed;

  @override
  X509Certificate? get certificate => null;

  @override
  List<Cookie> get cookies => const [];

  @override
  String get reasonPhrase => 'OK';

  @override
  Future<Socket> detachSocket() =>
      Future<Socket>.error(UnsupportedError('Not supported in tests'));

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int>)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _emptyStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  test('reports consistent device time within tolerance', () async {
    final serverTime = DateTime.now().toUtc();
    final response = _FakeHttpClientResponse(serverTime);
    final service = TimeConsistencyService(
      httpClient: _FakeHttpClient(response),
      tolerance: const Duration(minutes: 3),
      probeUri: Uri.parse('https://example.com'),
    );

    expect(await service.isDeviceTimeConsistent(), isTrue);
    service.close();
  });

  test('detects drift beyond tolerance', () async {
    final serverTime = DateTime.now().toUtc().subtract(const Duration(minutes: 10));
    final response = _FakeHttpClientResponse(serverTime);
    final service = TimeConsistencyService(
      httpClient: _FakeHttpClient(response),
      tolerance: const Duration(minutes: 3),
      probeUri: Uri.parse('https://example.com'),
    );

    expect(await service.isDeviceTimeConsistent(), isFalse);
    service.close();
  });
}
