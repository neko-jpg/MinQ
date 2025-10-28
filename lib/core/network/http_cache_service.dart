import 'dart:convert';

import 'package:minq/core/logging/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// HTTPキャッシュサービス
class HttpCacheService {
  static const String _cachePrefix = 'http_cache_';
  static const String _cacheMetaPrefix = 'http_cache_meta_';

  // デフォルトキャッシュ期間
  static const Duration _defaultCacheDuration = Duration(hours: 1);
  static const Duration _imageCacheDuration = Duration(days: 7);
  static const Duration _staticAssetCacheDuration = Duration(days: 30);

  /// キャッシュを取得
  Future<CachedResponse?> get(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(url);
      final metaKey = _getMetaKey(url);

      final cachedData = prefs.getString(cacheKey);
      final metaData = prefs.getString(metaKey);

      if (cachedData == null || metaData == null) {
        return null;
      }

      final meta = CacheMeta.fromJson(jsonDecode(metaData));

      // キャッシュ有効期限チェック
      if (meta.isExpired) {
        await _remove(url);
        return null;
      }

      logger.info('Cache hit', data: {'url': url});

      return CachedResponse(data: cachedData, meta: meta);
    } catch (e, stack) {
      logger.error('Failed to get cache', error: e, stackTrace: stack);
      return null;
    }
  }

  /// キャッシュを保存
  Future<void> put({
    required String url,
    required String data,
    Duration? cacheDuration,
    Map<String, String>? headers,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(url);
      final metaKey = _getMetaKey(url);

      final duration = cacheDuration ?? _getCacheDuration(url);
      final expiresAt = DateTime.now().add(duration);

      final meta = CacheMeta(
        url: url,
        cachedAt: DateTime.now(),
        expiresAt: expiresAt,
        headers: headers ?? {},
        etag: headers?['etag'],
        lastModified: headers?['last-modified'],
      );

      await prefs.setString(cacheKey, data);
      await prefs.setString(metaKey, jsonEncode(meta.toJson()));

      logger.info(
        'Cache saved',
        data: {'url': url, 'expiresAt': expiresAt.toIso8601String()},
      );
    } catch (e, stack) {
      logger.error('Failed to save cache', error: e, stackTrace: stack);
    }
  }

  /// キャッシュを削除
  Future<void> _remove(String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_getCacheKey(url));
      await prefs.remove(_getMetaKey(url));
    } catch (e, stack) {
      logger.error('Failed to remove cache', error: e, stackTrace: stack);
    }
  }

  /// 全キャッシュをクリア
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_cacheMetaPrefix)) {
          await prefs.remove(key);
        }
      }

      logger.info('All cache cleared');
    } catch (e, stack) {
      logger.error('Failed to clear cache', error: e, stackTrace: stack);
    }
  }

  /// 期限切れキャッシュを削除
  Future<void> cleanExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final metaKeys = keys.where((k) => k.startsWith(_cacheMetaPrefix));

      for (final metaKey in metaKeys) {
        final metaData = prefs.getString(metaKey);
        if (metaData == null) continue;

        final meta = CacheMeta.fromJson(jsonDecode(metaData));
        if (meta.isExpired) {
          final url = meta.url;
          await _remove(url);
        }
      }

      logger.info('Expired cache cleaned');
    } catch (e, stack) {
      logger.error(
        'Failed to clean expired cache',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// キャッシュサイズを取得
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;

      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          final data = prefs.getString(key);
          if (data != null) {
            totalSize += data.length;
          }
        }
      }

      return totalSize;
    } catch (e, stack) {
      logger.error('Failed to get cache size', error: e, stackTrace: stack);
      return 0;
    }
  }

  /// URLに応じたキャッシュ期間を取得
  Duration _getCacheDuration(String url) {
    if (url.contains(
      RegExp(r'\.(jpg|jpeg|png|gif|webp|svg)$', caseSensitive: false),
    )) {
      return _imageCacheDuration;
    }
    if (url.contains(
      RegExp(r'\.(css|js|woff|woff2|ttf)$', caseSensitive: false),
    )) {
      return _staticAssetCacheDuration;
    }
    return _defaultCacheDuration;
  }

  String _getCacheKey(String url) => '$_cachePrefix${_hashUrl(url)}';
  String _getMetaKey(String url) => '$_cacheMetaPrefix${_hashUrl(url)}';

  String _hashUrl(String url) {
    return url.hashCode.abs().toString();
  }
}

/// キャッシュメタデータ
class CacheMeta {
  final String url;
  final DateTime cachedAt;
  final DateTime expiresAt;
  final Map<String, String> headers;
  final String? etag;
  final String? lastModified;

  CacheMeta({
    required this.url,
    required this.cachedAt,
    required this.expiresAt,
    required this.headers,
    this.etag,
    this.lastModified,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'url': url,
    'cachedAt': cachedAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'headers': headers,
    'etag': etag,
    'lastModified': lastModified,
  };

  factory CacheMeta.fromJson(Map<String, dynamic> json) => CacheMeta(
    url: json['url'] as String,
    cachedAt: DateTime.parse(json['cachedAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    headers: Map<String, String>.from(json['headers'] as Map),
    etag: json['etag'] as String?,
    lastModified: json['lastModified'] as String?,
  );
}

/// キャッシュレスポンス
class CachedResponse {
  final String data;
  final CacheMeta meta;

  CachedResponse({required this.data, required this.meta});
}

/// CDN最適化ヘルパー
class CdnOptimizer {
  /// Cache-Controlヘッダーを生成
  static String getCacheControlHeader({
    required CacheStrategy strategy,
    Duration? maxAge,
  }) {
    switch (strategy) {
      case CacheStrategy.noCache:
        return 'no-cache, no-store, must-revalidate';

      case CacheStrategy.shortTerm:
        final age = maxAge ?? const Duration(minutes: 5);
        return 'public, max-age=${age.inSeconds}';

      case CacheStrategy.mediumTerm:
        final age = maxAge ?? const Duration(hours: 1);
        return 'public, max-age=${age.inSeconds}';

      case CacheStrategy.longTerm:
        final age = maxAge ?? const Duration(days: 7);
        return 'public, max-age=${age.inSeconds}, immutable';

      case CacheStrategy.forever:
        return 'public, max-age=31536000, immutable';
    }
  }

  /// ETagを生成
  static String generateEtag(String content) {
    return '"${content.hashCode.abs().toRadixString(16)}"';
  }

  /// リソースタイプに応じたキャッシュ戦略を取得
  static CacheStrategy getStrategyForResource(String url) {
    // 画像
    if (url.contains(
      RegExp(r'\.(jpg|jpeg|png|gif|webp|svg)$', caseSensitive: false),
    )) {
      return CacheStrategy.longTerm;
    }

    // フォント
    if (url.contains(
      RegExp(r'\.(woff|woff2|ttf|otf)$', caseSensitive: false),
    )) {
      return CacheStrategy.forever;
    }

    // CSS/JS（バージョン付き）
    if (url.contains(RegExp(r'\.(css|js)\?v=', caseSensitive: false))) {
      return CacheStrategy.longTerm;
    }

    // CSS/JS（バージョンなし）
    if (url.contains(RegExp(r'\.(css|js)$', caseSensitive: false))) {
      return CacheStrategy.shortTerm;
    }

    // API
    if (url.contains('/api/')) {
      return CacheStrategy.noCache;
    }

    // デフォルト
    return CacheStrategy.mediumTerm;
  }

  /// Brotli圧縮が利用可能かチェック
  static bool supportsBrotli(Map<String, String> headers) {
    final acceptEncoding = headers['accept-encoding']?.toLowerCase() ?? '';
    return acceptEncoding.contains('br');
  }

  /// 最適な圧縮形式を取得
  static String getOptimalCompression(Map<String, String> headers) {
    final acceptEncoding = headers['accept-encoding']?.toLowerCase() ?? '';

    if (acceptEncoding.contains('br')) {
      return 'br';
    } else if (acceptEncoding.contains('gzip')) {
      return 'gzip';
    } else if (acceptEncoding.contains('deflate')) {
      return 'deflate';
    }

    return 'identity';
  }
}

/// キャッシュ戦略
enum CacheStrategy {
  noCache, // キャッシュしない
  shortTerm, // 短期（5分）
  mediumTerm, // 中期（1時間）
  longTerm, // 長期（7日）
  forever, // 永続（1年）
}

/// キャッシュ統計
class CacheStats {
  int hits = 0;
  int misses = 0;
  int expired = 0;
  int errors = 0;

  double get hitRate {
    final total = hits + misses;
    return total > 0 ? hits / total : 0.0;
  }

  void recordHit() => hits++;
  void recordMiss() => misses++;
  void recordExpired() => expired++;
  void recordError() => errors++;

  void reset() {
    hits = 0;
    misses = 0;
    expired = 0;
    errors = 0;
  }

  Map<String, dynamic> toJson() => {
    'hits': hits,
    'misses': misses,
    'expired': expired,
    'errors': errors,
    'hitRate': hitRate,
  };
}
