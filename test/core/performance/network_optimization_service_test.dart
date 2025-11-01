import 'package:flutter_test/flutter_test.dart';
import 'package:minq/core/performance/network_optimization_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkOptimizationService', () {
    late NetworkOptimizationService service;

    setUp(() {
      service = NetworkOptimizationService();
    });

    test('should initialize successfully', () async {
      await expectLater(service.initialize(), completes);
    });

    test('should make network request', () async {
      const request = NetworkRequest(
        url: 'https://api.example.com/data',
        method: 'GET',
      );

      final response = await service.makeRequest(request);

      expect(response.statusCode, equals(200));
      expect(response.body, isNotEmpty);
      expect(response.isSuccess, isTrue);
    });

    test('should cache successful responses', () async {
      const request = NetworkRequest(
        url: 'https://api.example.com/cached',
        cacheable: true,
      );

      // First request
      final response1 = await service.makeRequest(request);
      expect(response1.isFromCache, isFalse);

      // Second request should be from cache
      final response2 = await service.makeRequest(request);
      expect(response2.isFromCache, isTrue);
      expect(response2.body, equals(response1.body));
    });

    test('should handle offline mode', () async {
      const request = NetworkRequest(url: 'https://api.example.com/offline');

      // Make initial request to cache it
      await service.makeRequest(request);

      // Set offline mode
      service.setOfflineMode(true);

      // Request should return cached data
      final response = await service.makeRequest(request);
      expect(response.isFromCache, isTrue);
      expect(response.isStale, isTrue);
    });

    test('should throw exception in offline mode without cache', () async {
      const request = NetworkRequest(url: 'https://api.example.com/nocache');

      service.setOfflineMode(true);

      await expectLater(
        service.makeRequest(request),
        throwsA(isA<NetworkException>()),
      );
    });

    test('should prefetch data', () async {
      final requests = [
        NetworkRequest(url: 'https://api.example.com/prefetch1'),
        NetworkRequest(url: 'https://api.example.com/prefetch2'),
      ];

      await expectLater(service.prefetchData(requests), completes);
    });

    test('should clear cache', () async {
      const request = NetworkRequest(url: 'https://api.example.com/clear');

      // Make request to cache it
      await service.makeRequest(request);

      // Clear cache
      await service.clearCache();

      // Get cache stats
      final stats = service.getCacheStats();
      expect(stats.cacheSize, equals(0));
      expect(stats.cacheCount, equals(0));
    });

    test('should get cache statistics', () {
      final stats = service.getCacheStats();

      expect(stats.cacheSize, greaterThanOrEqualTo(0));
      expect(stats.cacheCount, greaterThanOrEqualTo(0));
      expect(stats.maxCacheSize, greaterThan(0));
      expect(stats.hitRate, greaterThanOrEqualTo(0));
      expect(stats.utilizationRate, greaterThanOrEqualTo(0));
    });

    test('should get usage statistics', () {
      final stats = service.getUsageStats();

      expect(stats.totalRequests, greaterThanOrEqualTo(0));
      expect(stats.cachedRequests, greaterThanOrEqualTo(0));
      expect(stats.failedRequests, greaterThanOrEqualTo(0));
      expect(stats.averageResponseTime, greaterThanOrEqualTo(0));
      expect(stats.dataSaved, greaterThanOrEqualTo(0));
    });

    test('should get and update settings', () async {
      final initialSettings = await service.getSettings();
      expect(initialSettings.cacheEnabled, isTrue);

      final newSettings = NetworkOptimizationSettings(
        cacheEnabled: false,
        compressionEnabled: false,
        prefetchEnabled: true,
      );

      await service.updateSettings(newSettings);

      final updatedSettings = await service.getSettings();
      expect(updatedSettings.cacheEnabled, isFalse);
      expect(updatedSettings.compressionEnabled, isFalse);
      expect(updatedSettings.prefetchEnabled, isTrue);
    });

    test('should optimize network usage', () async {
      await expectLater(service.optimizeNetworkUsage(), completes);
    });
  });

  group('NetworkRequest', () {
    test('should create request with default values', () {
      const request = NetworkRequest(url: 'https://example.com');

      expect(request.url, equals('https://example.com'));
      expect(request.method, equals('GET'));
      expect(request.headers, isEmpty);
      expect(request.body, isNull);
      expect(request.cacheable, isTrue);
      expect(request.priority, equals(RequestPriority.normal));
    });

    test('should copy request with new values', () {
      const original = NetworkRequest(
        url: 'https://example.com',
        method: 'GET',
      );

      final copied = original.copyWith(method: 'POST', body: 'test body');

      expect(copied.url, equals(original.url));
      expect(copied.method, equals('POST'));
      expect(copied.body, equals('test body'));
    });
  });

  group('NetworkResponse', () {
    test('should create response with all fields', () {
      final now = DateTime.now();
      const response = NetworkResponse(
        statusCode: 200,
        body: 'response body',
        headers: {'content-type': 'application/json'},
        isCompressed: true,
        requestTime: now,
        responseTime: now,
        isFromCache: false,
        isStale: false,
      );

      expect(response.statusCode, equals(200));
      expect(response.body, equals('response body'));
      expect(response.headers['content-type'], equals('application/json'));
      expect(response.isCompressed, isTrue);
      expect(response.isFromCache, isFalse);
      expect(response.isStale, isFalse);
      expect(response.isSuccess, isTrue);
    });

    test('should create response from cached', () {
      final now = DateTime.now();
      final originalResponse = NetworkResponse(
        statusCode: 200,
        body: 'cached body',
        headers: {'content-type': 'application/json'},
        requestTime: now,
        responseTime: now,
      );

      final cachedResponse = CachedResponse(
        response: originalResponse,
        cachedAt: now,
        expiresAt: now.add(Duration(hours: 1)),
        size: 100,
      );

      final response = NetworkResponse.fromCached(cachedResponse);

      expect(response.body, equals('cached body'));
      expect(response.isFromCache, isTrue);
      expect(response.isStale, isFalse);
    });

    test('should identify successful responses', () {
      const successResponse = NetworkResponse(
        statusCode: 200,
        body: 'success',
        headers: {},
        requestTime: DateTime.now(),
        responseTime: DateTime.now(),
      );

      const errorResponse = NetworkResponse(
        statusCode: 404,
        body: 'not found',
        headers: {},
        requestTime: DateTime.now(),
        responseTime: DateTime.now(),
      );

      expect(successResponse.isSuccess, isTrue);
      expect(errorResponse.isSuccess, isFalse);
    });
  });

  group('CachedResponse', () {
    test('should create cached response', () {
      final now = DateTime.now();
      final response = NetworkResponse(
        statusCode: 200,
        body: 'test',
        headers: {},
        requestTime: now,
        responseTime: now,
      );

      final cached = CachedResponse(
        response: response,
        cachedAt: now,
        expiresAt: now.add(Duration(hours: 1)),
        size: 100,
      );

      expect(cached.response, equals(response));
      expect(cached.cachedAt, equals(now));
      expect(cached.size, equals(100));
      expect(cached.isExpired, isFalse);
    });

    test('should detect expired cache', () {
      final past = DateTime.now().subtract(Duration(hours: 2));
      final response = NetworkResponse(
        statusCode: 200,
        body: 'test',
        headers: {},
        requestTime: past,
        responseTime: past,
      );

      final cached = CachedResponse(
        response: response,
        cachedAt: past,
        expiresAt: past.add(Duration(hours: 1)),
        size: 100,
      );

      expect(cached.isExpired, isTrue);
    });
  });
}
