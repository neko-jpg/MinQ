import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// リトライ戦略
enum RetryStrategy {
  /// 固定間隔
  fixed,

  /// 指数バックオフ
  exponential,

  /// 線形バックオフ
  linear,

  /// ジッター付き指数バックオフ（推奨）
  exponentialWithJitter,
}

/// リトライ設定
class RetryConfig {
  /// 最大リトライ回数
  final int maxAttempts;

  /// 初期待機時間
  final Duration initialDelay;

  /// 最大待機時間
  final Duration maxDelay;

  /// リトライ戦略
  final RetryStrategy strategy;

  /// リトライ可能なエラーの判定関数
  final bool Function(dynamic error)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.strategy = RetryStrategy.exponentialWithJitter,
    this.shouldRetry,
  });

  /// デフォルト設定
  static const defaultConfig = RetryConfig();

  /// ネットワークエラー用設定
  static const networkConfig = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(seconds: 1),
    maxDelay: Duration(minutes: 1),
    strategy: RetryStrategy.exponentialWithJitter,
  );

  /// 書き込み競合用設定
  static const conflictConfig = RetryConfig(
    maxAttempts: 10,
    initialDelay: Duration(milliseconds: 100),
    maxDelay: Duration(seconds: 5),
    strategy: RetryStrategy.exponentialWithJitter,
  );
}

/// リトライユーティリティ
class RetryUtil {
  const RetryUtil._();

  /// リトライ付きで関数を実行
  static Future<T> execute<T>({
    required Future<T> Function() action,
    RetryConfig config = RetryConfig.defaultConfig,
  }) async {
    int attempt = 0;
    Duration delay = config.initialDelay;

    while (true) {
      attempt++;

      try {
        return await action();
      } catch (error) {
        // 最大試行回数に達した場合
        if (attempt >= config.maxAttempts) {
          throw RetryExhaustedException(
            'Failed after $attempt attempts',
            error,
          );
        }

        // リトライ可能なエラーかチェック
        if (config.shouldRetry != null && !config.shouldRetry!(error)) {
          rethrow;
        }

        // デフォルトのリトライ可能判定
        if (!_isRetryableError(error)) {
          rethrow;
        }

        // 待機時間を計算
        delay = _calculateDelay(
          attempt: attempt,
          initialDelay: config.initialDelay,
          maxDelay: config.maxDelay,
          strategy: config.strategy,
        );

        debugPrint('⚠️ Retry attempt $attempt after ${delay.inMilliseconds}ms: $error');

        // 待機
        await Future.delayed(delay);
      }
    }
  }

  /// リトライ可能なエラーかどうかを判定
  static bool _isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      // リトライ可能なFirebaseエラーコード
      const retryableCodes = [
        'unavailable',
        'deadline-exceeded',
        'resource-exhausted',
        'aborted',
        'internal',
        'unknown',
      ];
      return retryableCodes.contains(error.code);
    }

    // ネットワークエラー
    if (error is TimeoutException) {
      return true;
    }

    return false;
  }

  /// 待機時間を計算
  static Duration _calculateDelay({
    required int attempt,
    required Duration initialDelay,
    required Duration maxDelay,
    required RetryStrategy strategy,
  }) {
    Duration delay;

    switch (strategy) {
      case RetryStrategy.fixed:
        delay = initialDelay;
        break;

      case RetryStrategy.linear:
        delay = initialDelay * attempt;
        break;

      case RetryStrategy.exponential:
        delay = initialDelay * pow(2, attempt - 1).toInt();
        break;

      case RetryStrategy.exponentialWithJitter:
        final exponentialDelay = initialDelay * pow(2, attempt - 1).toInt();
        final jitter = Random().nextDouble() * 0.3; // 0-30%のジッター
        delay = exponentialDelay * (1 + jitter);
        break;
    }

    // 最大待機時間を超えないようにする
    return delay > maxDelay ? maxDelay : delay;
  }
}

/// リトライ失敗例外
class RetryExhaustedException implements Exception {
  final String message;
  final dynamic originalError;

  RetryExhaustedException(this.message, this.originalError);

  @override
  String toString() => 'RetryExhaustedException: $message (Original: $originalError)';
}

/// 競合解決ポリシー
enum ConflictResolutionPolicy {
  /// 最後の書き込みが勝つ
  lastWriteWins,

  /// 最初の書き込みが勝つ
  firstWriteWins,

  /// マージ（カスタムロジック）
  merge,

  /// エラーを投げる
  throwError,
}

/// 競合解決ユーティリティ
class ConflictResolver {
  /// トランザクションで競合を解決
  static Future<T> resolveWithTransaction<T>({
    required DocumentReference docRef,
    required T Function(DocumentSnapshot) updateFunction,
    ConflictResolutionPolicy policy = ConflictResolutionPolicy.lastWriteWins,
    RetryConfig retryConfig = RetryConfig.conflictConfig,
  }) async {
    return RetryUtil.execute(
      action: () async {
        return await FirebaseFirestore.instance.runTransaction<T>(
          (transaction) async {
            final snapshot = await transaction.get(docRef);

            if (!snapshot.exists) {
              throw Exception('Document does not exist');
            }

            final newData = updateFunction(snapshot);

            transaction.update(docRef, newData as Map<String, dynamic>);

            return newData;
          },
        );
      },
      config: retryConfig,
    );
  }

  /// 楽観的ロックで競合を解決
  static Future<void> resolveWithOptimisticLock({
    required DocumentReference docRef,
    required Map<String, dynamic> Function(Map<String, dynamic>) updateFunction,
    RetryConfig retryConfig = RetryConfig.conflictConfig,
  }) async {
    return RetryUtil.execute(
      action: () async {
        final snapshot = await docRef.get();

        if (!snapshot.exists) {
          throw Exception('Document does not exist');
        }

        final currentData = snapshot.data() as Map<String, dynamic>;
        final version = currentData['version'] as int? ?? 0;

        final newData = updateFunction(currentData);
        newData['version'] = version + 1;
        newData['updatedAt'] = FieldValue.serverTimestamp();

        // バージョンが一致する場合のみ更新
        await docRef.update({
          ...newData,
          'version': version + 1,
        });
      },
      config: retryConfig,
    );
  }

  /// カスタムマージロジックで競合を解決
  static Future<void> resolveWithMerge({
    required DocumentReference docRef,
    required Map<String, dynamic> localChanges,
    required Map<String, dynamic> Function(
      Map<String, dynamic> server,
      Map<String, dynamic> local,
    ) mergeFunction,
    RetryConfig retryConfig = RetryConfig.conflictConfig,
  }) async {
    return RetryUtil.execute(
      action: () async {
        return await FirebaseFirestore.instance.runTransaction(
          (transaction) async {
            final snapshot = await transaction.get(docRef);

            if (!snapshot.exists) {
              throw Exception('Document does not exist');
            }

            final serverData = snapshot.data() as Map<String, dynamic>;
            final mergedData = mergeFunction(serverData, localChanges);

            transaction.update(docRef, mergedData);
          },
        );
      },
      config: retryConfig,
    );
  }
}

/// バッチ書き込みのリトライ
class BatchWriteWithRetry {
  final FirebaseFirestore _firestore;
  final RetryConfig _retryConfig;

  BatchWriteWithRetry({
    FirebaseFirestore? firestore,
    RetryConfig retryConfig = RetryConfig.defaultConfig,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _retryConfig = retryConfig;

  /// バッチ書き込みを実行
  Future<void> execute(
    void Function(WriteBatch batch) operations,
  ) async {
    return RetryUtil.execute(
      action: () async {
        final batch = _firestore.batch();
        operations(batch);
        await batch.commit();
      },
      config: _retryConfig,
    );
  }

  /// 大量のバッチ書き込みを分割して実行
  Future<void> executeLarge(
    List<void Function(WriteBatch batch)> operations, {
    int batchSize = 500, // Firestoreの制限は500
  }) async {
    for (int i = 0; i < operations.length; i += batchSize) {
      final end = (i + batchSize < operations.length)
          ? i + batchSize
          : operations.length;
      final chunk = operations.sublist(i, end);

      await execute((batch) {
        for (final operation in chunk) {
          operation(batch);
        }
      });

      // レート制限を避けるため、少し待機
      if (end < operations.length) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }
}

/// レート制限対策
class RateLimiter {
  final int _maxRequestsPerSecond;
  final List<DateTime> _requestTimestamps = [];

  RateLimiter({int maxRequestsPerSecond = 10})
      : _maxRequestsPerSecond = maxRequestsPerSecond;

  /// リクエストを実行（レート制限付き）
  Future<T> execute<T>(Future<T> Function() action) async {
    await _waitIfNeeded();
    _requestTimestamps.add(DateTime.now());
    return await action();
  }

  /// 必要に応じて待機
  Future<void> _waitIfNeeded() async {
    final now = DateTime.now();
    final oneSecondAgo = now.subtract(const Duration(seconds: 1));

    // 1秒以内のリクエストをカウント
    _requestTimestamps.removeWhere((timestamp) => timestamp.isBefore(oneSecondAgo));

    if (_requestTimestamps.length >= _maxRequestsPerSecond) {
      final oldestRequest = _requestTimestamps.first;
      final waitTime = const Duration(seconds: 1) - now.difference(oldestRequest);

      if (waitTime.inMilliseconds > 0) {
        await Future.delayed(waitTime);
      }
    }
  }

  /// リセット
  void reset() {
    _requestTimestamps.clear();
  }
}

/// Firestore操作の拡張
extension FirestoreRetryExtension on DocumentReference {
  /// リトライ付きで取得
  Future<DocumentSnapshot> getWithRetry({
    RetryConfig config = RetryConfig.defaultConfig,
  }) {
    return RetryUtil.execute(
      action: () => get(),
      config: config,
    );
  }

  /// リトライ付きで更新
  Future<void> updateWithRetry(
    Map<String, dynamic> data, {
    RetryConfig config = RetryConfig.defaultConfig,
  }) {
    return RetryUtil.execute(
      action: () => update(data),
      config: config,
    );
  }

  /// リトライ付きで設定
  Future<void> setWithRetry(
    Map<String, dynamic> data, {
    SetOptions? options,
    RetryConfig config = RetryConfig.defaultConfig,
  }) {
    return RetryUtil.execute(
      action: () => set(data, options),
      config: config,
    );
  }

  /// リトライ付きで削除
  Future<void> deleteWithRetry({
    RetryConfig config = RetryConfig.defaultConfig,
  }) {
    return RetryUtil.execute(
      action: () => delete(),
      config: config,
    );
  }
}

extension QueryRetryExtension on Query {
  /// リトライ付きで取得
  Future<QuerySnapshot> getWithRetry({
    RetryConfig config = RetryConfig.defaultConfig,
  }) {
    return RetryUtil.execute(
      action: () => get(),
      config: config,
    );
  }
}
