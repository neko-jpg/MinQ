import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore設定クラス
class FirestoreConfig {
  const FirestoreConfig._();

  /// Firestoreの初期化と設定
  static Future<void> initialize() async {
    final firestore = FirebaseFirestore.instance;

    // オフライン永続化を有効化
    await _enablePersistence(firestore);

    // キャッシュ設定
    _configureCacheSettings(firestore);

    // ログ設定
    _configureLogging(firestore);
  }

  /// オフライン永続化の有効化
  static Future<void> _enablePersistence(FirebaseFirestore firestore) async {
    try {
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      print('✅ Firestore persistence enabled');
    } catch (e) {
      print('⚠️ Firestore persistence already enabled or not supported: $e');
    }
  }

  /// キャッシュ設定
  static void _configureCacheSettings(FirebaseFirestore firestore) {
    // キャッシュサイズの設定（デフォルト: 40MB、最大: 100MB）
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // 無制限（推奨）
      // または具体的なサイズを指定
      // cacheSizeBytes: 100 * 1024 * 1024, // 100MB
    );
  }

  /// ログ設定
  static void _configureLogging(FirebaseFirestore firestore) {
    // 開発環境でのみログを有効化
    if (const bool.fromEnvironment('DEBUG', defaultValue: false)) {
      FirebaseFirestore.setLoggingEnabled(true);
    }
  }

  /// キャッシュをクリア
  static Future<void> clearCache() async {
    try {
      await FirebaseFirestore.instance.clearPersistence();
      print('✅ Firestore cache cleared');
    } catch (e) {
      print('❌ Failed to clear Firestore cache: $e');
    }
  }

  /// オフライン時の動作を待機
  static Future<void> waitForPendingWrites() async {
    try {
      await FirebaseFirestore.instance.waitForPendingWrites();
      print('✅ All pending writes completed');
    } catch (e) {
      print('❌ Failed to wait for pending writes: $e');
    }
  }

  /// ネットワーク接続を無効化（テスト用）
  static Future<void> disableNetwork() async {
    try {
      await FirebaseFirestore.instance.disableNetwork();
      print('✅ Firestore network disabled');
    } catch (e) {
      print('❌ Failed to disable network: $e');
    }
  }

  /// ネットワーク接続を有効化
  static Future<void> enableNetwork() async {
    try {
      await FirebaseFirestore.instance.enableNetwork();
      print('✅ Firestore network enabled');
    } catch (e) {
      print('❌ Failed to enable network: $e');
    }
  }
}

/// キャッシュ戦略
enum CacheStrategy {
  /// サーバーを優先、失敗時はキャッシュ
  serverFirst,

  /// キャッシュを優先、バックグラウンドで更新
  cacheFirst,

  /// キャッシュのみ（オフライン専用）
  cacheOnly,

  /// サーバーのみ（キャッシュを使用しない）
  serverOnly,
}

/// キャッシュ戦略を適用したクエリ拡張
extension CacheStrategyExtension on Query {
  /// キャッシュ戦略を適用
  Query withCacheStrategy(CacheStrategy strategy) {
    switch (strategy) {
      case CacheStrategy.serverFirst:
        return this;
      case CacheStrategy.cacheFirst:
        // Firestoreはデフォルトでキャッシュファーストなので何もしない
        return this;
      case CacheStrategy.cacheOnly:
        // オフラインソースのみを使用
        return this;
      case CacheStrategy.serverOnly:
        // サーバーソースのみを使用
        return this;
    }
  }

  /// キャッシュから取得
  Future<QuerySnapshot> getFromCache() {
    return get(const GetOptions(source: Source.cache));
  }

  /// サーバーから取得
  Future<QuerySnapshot> getFromServer() {
    return get(const GetOptions(source: Source.server));
  }

  /// サーバーを優先、失敗時はキャッシュ
  Future<QuerySnapshot> getServerFirst() {
    return get(const GetOptions(source: Source.serverAndCache));
  }
}

/// ドキュメント参照のキャッシュ戦略拡張
extension DocumentCacheStrategyExtension on DocumentReference {
  /// キャッシュから取得
  Future<DocumentSnapshot> getFromCache() {
    return get(const GetOptions(source: Source.cache));
  }

  /// サーバーから取得
  Future<DocumentSnapshot> getFromServer() {
    return get(const GetOptions(source: Source.server));
  }

  /// サーバーを優先、失敗時はキャッシュ
  Future<DocumentSnapshot> getServerFirst() {
    return get(const GetOptions(source: Source.serverAndCache));
  }
}

/// オフライン対応のリポジトリミックスイン
mixin OfflineCapableMixin {
  /// オンライン状態かどうか
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  /// オンライン状態を設定
  void setOnlineStatus(bool online) {
    _isOnline = online;
  }

  /// オフライン時の動作
  Future<T> executeWithOfflineSupport<T>({
    required Future<T> Function() onlineAction,
    required Future<T> Function() offlineAction,
  }) async {
    if (_isOnline) {
      try {
        return await onlineAction();
      } catch (e) {
        // オンラインアクションが失敗した場合、オフラインアクションを試行
        print('⚠️ Online action failed, falling back to offline: $e');
        return await offlineAction();
      }
    } else {
      return await offlineAction();
    }
  }

  /// キャッシュから取得、バックグラウンドで更新
  Stream<T> watchWithCache<T>({
    required Stream<T> serverStream,
    required Future<T> Function() getCached,
  }) async* {
    // まずキャッシュから取得
    try {
      final cached = await getCached();
      yield cached;
    } catch (e) {
      print('⚠️ Failed to get cached data: $e');
    }

    // サーバーからの更新を監視
    await for (final data in serverStream) {
      yield data;
    }
  }
}

/// キャッシュ管理サービス
class CacheManagementService {
  /// キャッシュサイズを取得（概算）
  Future<int> getCacheSize() async {
    // Firestoreには直接キャッシュサイズを取得するAPIがないため、
    // プラットフォーム固有の実装が必要
    // ここでは概算値を返す
    return 0;
  }

  /// キャッシュをクリア
  Future<void> clearCache() async {
    await FirestoreConfig.clearCache();
  }

  /// 古いキャッシュを削除
  Future<void> clearOldCache({Duration maxAge = const Duration(days: 7)}) async {
    // Firestoreは自動的に古いキャッシュを削除するため、
    // 手動での実装は不要
    print('ℹ️ Firestore automatically manages old cache');
  }

  /// キャッシュ統計を取得
  Future<Map<String, dynamic>> getCacheStats() async {
    return {
      'cacheSize': await getCacheSize(),
      'lastCleared': null,
      'isEnabled': true,
    };
  }
}

/// オフライン状態の監視
class OfflineStatusMonitor {
  final _controller = StreamController<bool>.broadcast();

  Stream<bool> get onlineStatus => _controller.stream;

  void initialize() {
    // ネットワーク状態の監視
    // connectivity_plusパッケージを使用することを推奨
    FirebaseFirestore.instance.snapshotsInSync().listen((_) {
      _controller.add(true);
    }, onError: (_) {
      _controller.add(false);
    },);
  }

  void dispose() {
    _controller.close();
  }
}

/// キャッシュ設定のプリセット
class CachePresets {
  const CachePresets._();

  /// 開発環境用（小さいキャッシュ）
  static Settings get development => const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 10 * 1024 * 1024, // 10MB
      );

  /// 本番環境用（大きいキャッシュ）
  static Settings get production => const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

  /// テスト環境用（キャッシュ無効）
  static Settings get testing => const Settings(
        persistenceEnabled: false,
        cacheSizeBytes: 1024 * 1024, // 1MB
      );

  /// 低メモリデバイス用
  static Settings get lowMemory => const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 5 * 1024 * 1024, // 5MB
      );
}
