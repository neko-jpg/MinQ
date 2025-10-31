import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for optimizing network usage and implementing offline-first caching
class NetworkOptimizationService {
  static const String _cacheEnabledKey = 'network_cache_enabled';
  static const String _compressionEnabledKey = 'network_compression_enabled';
  static const String _prefetchEnabledKey = 'network_prefetch_enabled';
  static const Duration _defaultCacheExpiry = Duration(hours: 24);
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  
  final Map<String, CachedResponse> _responseCache = {};
  final Map<String, DateTime> _cacheAccessTimes = {};
  final Set<String> _pendingRequests = {};
  final List<NetworkRequest> _requestQueue = [];
  
  int _currentCacheSize = 0;
  bool _isOfflineMode = false;
  Timer? _cacheCleanupTimer;
  
  static final NetworkOptimizationService _instance = NetworkOptimizationService._internal();
  factory NetworkOptimizationService() => _instance;
  NetworkOptimizationService._internal() {
    _startCacheCleanup();
  }
  
  /// Initialize network optimization
  Future<void> initialize() async {
    try {
      await _loadCacheFromDisk();
      debugPrint('Network optimization initialized');
    } catch (e) {
      debugPrint('Error initializing network optimization: $e');
    }
  }
  
  /// Make optimized HTTP request with caching and compression
  Future<NetworkResponse> makeRequest(NetworkRequest request) async {
    try {
      final cacheKey = _generateCacheKey(request);
      
      // Check cache first (offline-first approach)
      final cachedResponse = await _getCachedResponse(cacheKey);
      if (cachedResponse != null && !cachedResponse.isExpired) {
        _updateCacheAccess(cacheKey);
        return NetworkResponse.fromCached(cachedResponse);
      }
      
      // Check if request is already pending (deduplication)
      if (_pendingRequests.contains(cacheKey)) {
        return await _waitForPendingRequest(cacheKey);
      }
      
      // Check if offline mode
      if (_isOfflineMode) {
        if (cachedResponse != null) {
          // Return stale cache if available
          return NetworkResponse.fromCached(cachedResponse, isStale: true);
        } else {
          throw const NetworkException('No cached data available in offline mode');
        }
      }
      
      // Make network request
      _pendingRequests.add(cacheKey);
      
      try {
        final response = await _executeNetworkRequest(request);
        
        // Cache successful responses
        if (response.isSuccess && request.cacheable) {
          await _cacheResponse(cacheKey, response);
        }
        
        return response;
      } finally {
        _pendingRequests.remove(cacheKey);
      }
    } catch (e) {
      debugPrint('Network request failed: ${request.url} - $e');
      
      // Try to return cached response as fallback
      final cacheKey = _generateCacheKey(request);
      final cachedResponse = await _getCachedResponse(cacheKey);
      if (cachedResponse != null) {
        return NetworkResponse.fromCached(cachedResponse, isStale: true);
      }
      
      rethrow;
    }
  }
  
  /// Prefetch data for improved performance
  Future<void> prefetchData(List<NetworkRequest> requests) async {
    final settings = await getSettings();
    if (!settings.prefetchEnabled) return;
    
    for (final request in requests) {
      try {
        await makeRequest(request.copyWith(priority: RequestPriority.low));
      } catch (e) {
        debugPrint('Prefetch failed for ${request.url}: $e');
      }
    }
  }
  
  /// Set offline mode
  void setOfflineMode(bool offline) {
    _isOfflineMode = offline;
    debugPrint('Network offline mode: $offline');
  }
  
  /// Clear network cache
  Future<void> clearCache() async {
    _responseCache.clear();
    _cacheAccessTimes.clear();
    _currentCacheSize = 0;
    
    await _clearDiskCache();
    debugPrint('Network cache cleared');
  }
  
  /// Get cache statistics
  NetworkCacheStats getCacheStats() {
    final hitRate = _calculateCacheHitRate();
    
    return NetworkCacheStats(
      cacheSize: _currentCacheSize,
      cacheCount: _responseCache.length,
      maxCacheSize: _maxCacheSize,
      hitRate: hitRate,
      utilizationRate: _currentCacheSize / _maxCacheSize,
    );
  }
  
  /// Get network optimization settings
  Future<NetworkOptimizationSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    return NetworkOptimizationSettings(
      cacheEnabled: prefs.getBool(_cacheEnabledKey) ?? true,
      compressionEnabled: prefs.getBool(_compressionEnabledKey) ?? true,
      prefetchEnabled: prefs.getBool(_prefetchEnabledKey) ?? false,
    );
  }
  
  /// Update network optimization settings
  Future<void> updateSettings(NetworkOptimizationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_cacheEnabledKey, settings.cacheEnabled);
    await prefs.setBool(_compressionEnabledKey, settings.compressionEnabled);
    await prefs.setBool(_prefetchEnabledKey, settings.prefetchEnabled);
  }
  
  /// Get network usage statistics
  NetworkUsageStats getUsageStats() {
    return NetworkUsageStats(
      totalRequests: _getTotalRequests(),
      cachedRequests: _getCachedRequests(),
      failedRequests: _getFailedRequests(),
      averageResponseTime: _getAverageResponseTime(),
      dataSaved: _getDataSaved(),
    );
  }
  
  /// Optimize network usage based on current conditions
  Future<void> optimizeNetworkUsage() async {
    try {
      // Clean up expired cache
      await _cleanupExpiredCache();
      
      // Compress large cached responses
      await _compressLargeCachedResponses();
      
      // Prioritize pending requests
      _prioritizePendingRequests();
      
      debugPrint('Network usage optimized');
    } catch (e) {
      debugPrint('Error optimizing network usage: $e');
    }
  }
  
  // Private methods
  
  String _generateCacheKey(NetworkRequest request) {
    final keyData = {
      'url': request.url,
      'method': request.method,
      'headers': request.headers,
      'body': request.body,
    };
    
    return base64Encode(utf8.encode(jsonEncode(keyData)));
  }
  
  Future<CachedResponse?> _getCachedResponse(String cacheKey) async {
    final settings = await getSettings();
    if (!settings.cacheEnabled) return null;
    
    return _responseCache[cacheKey];
  }
  
  void _updateCacheAccess(String cacheKey) {
    _cacheAccessTimes[cacheKey] = DateTime.now();
  }
  
  Future<NetworkResponse> _waitForPendingRequest(String cacheKey) async {
    // Wait for pending request to complete
    while (_pendingRequests.contains(cacheKey)) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    // Return cached response
    final cachedResponse = await _getCachedResponse(cacheKey);
    if (cachedResponse != null) {
      return NetworkResponse.fromCached(cachedResponse);
    }
    
    throw const NetworkException('Pending request failed');
  }
  
  Future<NetworkResponse> _executeNetworkRequest(NetworkRequest request) async {
    final settings = await getSettings();
    
    // Simulate network request (in real implementation, use http package)
    await Future.delayed(Duration(milliseconds: 100 + (request.priority.index * 50)));
    
    // Simulate response
    final responseData = {
      'status': 'success',
      'data': 'Mock response data for ${request.url}',
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    final responseBody = jsonEncode(responseData);
    final compressedBody = settings.compressionEnabled 
        ? _compressData(responseBody)
        : responseBody;
    
    return NetworkResponse(
      statusCode: 200,
      body: compressedBody,
      headers: {'content-type': 'application/json'},
      isCompressed: settings.compressionEnabled,
      requestTime: DateTime.now(),
      responseTime: DateTime.now(),
    );
  }
  
  Future<void> _cacheResponse(String cacheKey, NetworkResponse response) async {
    final settings = await getSettings();
    if (!settings.cacheEnabled) return;
    
    final cachedResponse = CachedResponse(
      response: response,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(_defaultCacheExpiry),
      size: response.body.length,
    );
    
    // Check cache size limit
    while (_currentCacheSize + cachedResponse.size > _maxCacheSize && _responseCache.isNotEmpty) {
      _evictLeastRecentlyUsed();
    }
    
    _responseCache[cacheKey] = cachedResponse;
    _cacheAccessTimes[cacheKey] = DateTime.now();
    _currentCacheSize += cachedResponse.size;
    
    // Persist to disk
    await _saveCacheToDisk(cacheKey, cachedResponse);
  }
  
  void _evictLeastRecentlyUsed() {
    if (_cacheAccessTimes.isEmpty) return;
    
    String oldestKey = _cacheAccessTimes.keys.first;
    DateTime oldestTime = _cacheAccessTimes[oldestKey]!;
    
    for (final entry in _cacheAccessTimes.entries) {
      if (entry.value.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value;
      }
    }
    
    final cachedResponse = _responseCache.remove(oldestKey);
    _cacheAccessTimes.remove(oldestKey);
    
    if (cachedResponse != null) {
      _currentCacheSize -= cachedResponse.size;
    }
  }
  
  String _compressData(String data) {
    // Simple compression simulation (in real implementation, use gzip)
    return data.length > 1000 ? '${data.substring(0, data.length ~/ 2)}...[compressed]' : data;
  }
  
  void _startCacheCleanup() {
    _cacheCleanupTimer = Timer.periodic(const Duration(hours: 1), (_) {
      _cleanupExpiredCache();
    });
  }
  
  Future<void> _cleanupExpiredCache() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];
    
    for (final entry in _responseCache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      final cachedResponse = _responseCache.remove(key);
      _cacheAccessTimes.remove(key);
      
      if (cachedResponse != null) {
        _currentCacheSize -= cachedResponse.size;
      }
    }
    
    if (expiredKeys.isNotEmpty) {
      debugPrint('Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }
  
  Future<void> _compressLargeCachedResponses() async {
    // Compress responses larger than 10KB
    const sizeThreshold = 10 * 1024;
    
    for (final entry in _responseCache.entries) {
      if (entry.value.size > sizeThreshold && !entry.value.response.isCompressed) {
        final compressedBody = _compressData(entry.value.response.body);
        final compressedResponse = entry.value.response.copyWith(
          body: compressedBody,
          isCompressed: true,
        );
        
        final newCachedResponse = entry.value.copyWith(
          response: compressedResponse,
          size: compressedBody.length,
        );
        
        _currentCacheSize -= entry.value.size;
        _currentCacheSize += newCachedResponse.size;
        _responseCache[entry.key] = newCachedResponse;
      }
    }
  }
  
  void _prioritizePendingRequests() {
    _requestQueue.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }
  
  double _calculateCacheHitRate() {
    // This would be calculated based on actual request statistics
    return 0.75; // 75% placeholder
  }
  
  int _getTotalRequests() => 100; // Placeholder
  int _getCachedRequests() => 75; // Placeholder
  int _getFailedRequests() => 5; // Placeholder
  double _getAverageResponseTime() => 150.0; // Placeholder
  int _getDataSaved() => 1024 * 1024; // 1MB placeholder
  
  Future<void> _loadCacheFromDisk() async {
    // Load cache from persistent storage
    // This would integrate with your storage service
  }
  
  Future<void> _saveCacheToDisk(String key, CachedResponse response) async {
    // Save cache to persistent storage
    // This would integrate with your storage service
  }
  
  Future<void> _clearDiskCache() async {
    // Clear cache from persistent storage
    // This would integrate with your storage service
  }
  
  void dispose() {
    _cacheCleanupTimer?.cancel();
  }
}

// Data classes

class NetworkRequest {
  final String url;
  final String method;
  final Map<String, String> headers;
  final String? body;
  final bool cacheable;
  final RequestPriority priority;
  final Duration? timeout;
  
  const NetworkRequest({
    required this.url,
    this.method = 'GET',
    this.headers = const {},
    this.body,
    this.cacheable = true,
    this.priority = RequestPriority.normal,
    this.timeout,
  });
  
  NetworkRequest copyWith({
    String? url,
    String? method,
    Map<String, String>? headers,
    String? body,
    bool? cacheable,
    RequestPriority? priority,
    Duration? timeout,
  }) {
    return NetworkRequest(
      url: url ?? this.url,
      method: method ?? this.method,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      cacheable: cacheable ?? this.cacheable,
      priority: priority ?? this.priority,
      timeout: timeout ?? this.timeout,
    );
  }
}

class NetworkResponse {
  final int statusCode;
  final String body;
  final Map<String, String> headers;
  final bool isCompressed;
  final DateTime requestTime;
  final DateTime responseTime;
  final bool isFromCache;
  final bool isStale;
  
  const NetworkResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
    this.isCompressed = false,
    required this.requestTime,
    required this.responseTime,
    this.isFromCache = false,
    this.isStale = false,
  });
  
  factory NetworkResponse.fromCached(CachedResponse cached, {bool isStale = false}) {
    return NetworkResponse(
      statusCode: cached.response.statusCode,
      body: cached.response.body,
      headers: cached.response.headers,
      isCompressed: cached.response.isCompressed,
      requestTime: cached.response.requestTime,
      responseTime: cached.response.responseTime,
      isFromCache: true,
      isStale: isStale,
    );
  }
  
  NetworkResponse copyWith({
    int? statusCode,
    String? body,
    Map<String, String>? headers,
    bool? isCompressed,
    DateTime? requestTime,
    DateTime? responseTime,
    bool? isFromCache,
    bool? isStale,
  }) {
    return NetworkResponse(
      statusCode: statusCode ?? this.statusCode,
      body: body ?? this.body,
      headers: headers ?? this.headers,
      isCompressed: isCompressed ?? this.isCompressed,
      requestTime: requestTime ?? this.requestTime,
      responseTime: responseTime ?? this.responseTime,
      isFromCache: isFromCache ?? this.isFromCache,
      isStale: isStale ?? this.isStale,
    );
  }
  
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  
  Duration get responseTime_ => responseTime.difference(requestTime);
}

class CachedResponse {
  final NetworkResponse response;
  final DateTime cachedAt;
  final DateTime expiresAt;
  final int size;
  
  const CachedResponse({
    required this.response,
    required this.cachedAt,
    required this.expiresAt,
    required this.size,
  });
  
  CachedResponse copyWith({
    NetworkResponse? response,
    DateTime? cachedAt,
    DateTime? expiresAt,
    int? size,
  }) {
    return CachedResponse(
      response: response ?? this.response,
      cachedAt: cachedAt ?? this.cachedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      size: size ?? this.size,
    );
  }
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class NetworkOptimizationSettings {
  final bool cacheEnabled;
  final bool compressionEnabled;
  final bool prefetchEnabled;
  
  const NetworkOptimizationSettings({
    required this.cacheEnabled,
    required this.compressionEnabled,
    required this.prefetchEnabled,
  });
}

class NetworkCacheStats {
  final int cacheSize;
  final int cacheCount;
  final int maxCacheSize;
  final double hitRate;
  final double utilizationRate;
  
  const NetworkCacheStats({
    required this.cacheSize,
    required this.cacheCount,
    required this.maxCacheSize,
    required this.hitRate,
    required this.utilizationRate,
  });
}

class NetworkUsageStats {
  final int totalRequests;
  final int cachedRequests;
  final int failedRequests;
  final double averageResponseTime;
  final int dataSaved;
  
  const NetworkUsageStats({
    required this.totalRequests,
    required this.cachedRequests,
    required this.failedRequests,
    required this.averageResponseTime,
    required this.dataSaved,
  });
}

enum RequestPriority { low, normal, high, critical }

class NetworkException implements Exception {
  final String message;
  
  const NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}