import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/startup/startup_performance_manager.dart';
import 'package:minq/core/startup/crash_prevention_service.dart';
import 'package:minq/core/logging/secure_startup_logger.dart';
import 'package:minq/data/providers.dart';

/// 最適化された初期化サービス
/// 1.5-2.0秒の起動時間を目標とし、クラッシュ防止とパフォーマンス監視を統合
class OptimalInitializationService {
  static const Duration _targetStartupTime = Duration(milliseconds: 1500);
  static const Duration _maxStartupTime = Duration(milliseconds: 2000);

  /// 重要な初期化プロセスを並列実行（パフォーマンス監視とクラッシュ防止付き）
  static Future<void> initializeApp(Ref ref, {StartupProgressCallback? onProgress}) async {
    // Initialize crash prevention first
    await crashPreventionService.initialize();

    // Initialize secure logging
    await secureStartupLogger.initialize();

    // Use startup performance manager for optimized initialization
    await startupPerformanceManager.initializeApp(ref, onProgress: onProgress);
  }

  /// 必須の初期化プロセス（並列実行）
  static Future<void> _criticalInitialization(Ref ref) async {
    await Future.wait([
      _initializeMinimalDatabase(ref),
      _loadEssentialPreferences(ref),
      _initializeBasicTheme(ref),
      _initializeNotifications(ref),
    ]);
  }

  /// 最小限のデータベース初期化
  static Future<void> _initializeMinimalDatabase(Ref ref) async {
    try {
      // Isarデータベースの初期化（進捗フィードバック付き）
      await ref.read(isarProvider.future);

      // データベースヘルスチェック
      final isarService = ref.read(isarServiceProvider);
      final healthStatus = await isarService.getHealthStatus();

      if (healthStatus != DatabaseHealthStatus.healthy) {
        developer.log('Database health check warning: $healthStatus');

        // 必要に応じて最適化を実行
        if (healthStatus == DatabaseHealthStatus.slow) {
          await isarService.optimize();
        }
      }

      // 基本的なクエストデータのシード（非同期で実行）
      unawaited(ref.read(questRepositoryProvider).seedInitialQuests());

    } catch (error) {
      developer.log('Database initialization error: $error');
      // データベースエラーでも続行
    }
  }

  /// 必須設定の読み込み
  static Future<void> _loadEssentialPreferences(Ref ref) async {
    try {
      final localPrefs = ref.read(localPreferencesServiceProvider);

      // ダミーデータモードの確認のみ
      final isDummyMode = await localPrefs.isDummyDataModeEnabled();
      ref.read(dummyDataModeProvider.notifier).state = isDummyMode;

    } catch (error) {
      developer.log('Preferences loading error: $error');
      // 設定エラーでも続行
    }
  }

  /// 基本テーマの初期化
  static Future<void> _initializeBasicTheme(Ref ref) async {
    // テーマ初期化は同期的なので即座に完了
    // 必要に応じて将来的にカスタムテーマ読み込みを追加
  }

  /// 通知サービスの初期化
  static Future<void> _initializeNotifications(Ref ref) async {
    try {
      final notifications = ref.read(notificationServiceProvider);
      final permissionGranted = await notifications.init();
      ref.read(notificationPermissionProvider.notifier).state = permissionGranted;
    } catch (error) {
      developer.log('Notification initialization error: $error');
      // 通知エラーでも続行
    }
  }

  /// 非必須の初期化（遅延実行）
  static void _deferredInitialization(Ref ref) {
    // マイクロタスクとして実行し、UIをブロックしない
    Future.microtask(() async {
      try {
        await _initializeFullServices(ref);
      } catch (error) {
        developer.log('Deferred initialization error: $error');
      }
    });
  }

  /// 完全なサービス初期化（バックグラウンド）
  static Future<void> _initializeFullServices(Ref ref) async {
    try {
      // リモート設定の初期化
      await ref.read(remoteConfigServiceProvider).initialize();

      // Firebase認証とユーザーデータの同期
      await _initializeFirebaseServices(ref);

      // 時刻整合性チェック
      await _checkTimeConsistency(ref);

      // Firestoreとの同期
      await _syncWithFirestore(ref);

    } catch (error) {
      developer.log('Full services initialization error: $error');
    }
  }

  /// Firebaseサービスの初期化
  static Future<void> _initializeFirebaseServices(Ref ref) async {
    final firebaseAvailable = ref.read(firebaseAvailabilityProvider);
    if (!firebaseAvailable) return;

    try {
      final firebaseUser = await ref.read(authRepositoryProvider).signInAnonymously();
      if (firebaseUser == null) return;

      // ユーザーデータの初期化
      await _initializeUserData(ref, firebaseUser.uid);

    } catch (error) {
      developer.log('Firebase services error: $error');
    }
  }

  /// ユーザーデータの初期化
  static Future<void> _initializeUserData(Ref ref, String uid) async {
    try {
      final userRepo = ref.read(userRepositoryProvider);
      var localUser = await userRepo.getUserById(uid);

      if (localUser == null) {
        // 新規ユーザーの作成
        localUser = await _createNewUser(ref, uid);
      }

      // ストリーク情報の更新
      await _updateStreakInfo(ref, localUser);

      // 通知スケジュールの設定
      await _setupNotificationSchedule(ref, localUser);

    } catch (error) {
      developer.log('User data initialization error: $error');
    }
  }

  /// 新規ユーザーの作成
  static Future<dynamic> _createNewUser(Ref ref, String uid) async {
    // 実装は既存のappStartupProviderから移植
    // 簡略化のため詳細は省略
    return null;
  }

  /// ストリーク情報の更新
  static Future<void> _updateStreakInfo(Ref ref, dynamic localUser) async {
    // 実装は既存のappStartupProviderから移植
    // 簡略化のため詳細は省略
  }

  /// 通知スケジュールの設定
  static Future<void> _setupNotificationSchedule(Ref ref, dynamic localUser) async {
    // 実装は既存のappStartupProviderから移植
    // 簡略化のため詳細は省略
  }

  /// 時刻整合性チェック
  static Future<void> _checkTimeConsistency(Ref ref) async {
    try {
      final timeConsistent = await ref
          .read(timeConsistencyServiceProvider)
          .isDeviceTimeConsistent();

      final hasDrift = !timeConsistent;
      ref.read(timeDriftDetectedProvider.notifier).state = hasDrift;

      if (hasDrift) {
        final notifications = ref.read(notificationServiceProvider);
        await notifications.suspendForTimeDrift();
      }
    } catch (error) {
      developer.log('Time consistency check error: $error');
    }
  }

  /// Firestoreとの同期
  static Future<void> _syncWithFirestore(Ref ref) async {
    try {
      final syncService = ref.read(firestoreSyncServiceProvider);
      if (syncService == null) return;

      final authRepo = ref.read(authRepositoryProvider);
      final firebaseUser = authRepo.getCurrentUser();
      if (firebaseUser == null) return;

      await syncService.syncQuestLogs(firebaseUser.uid);

    } catch (error) {
      developer.log('Firestore sync error: $error');
    }
  }
}

/// 最適化された初期化プロバイダー（パフォーマンス監視とクラッシュ防止付き）
final optimizedAppStartupProvider = FutureProvider<void>((ref) async {
  try {
    await OptimalInitializationService.initializeApp(ref);
  } catch (error) {
    // Log the error securely
    secureStartupLogger.logStartupError('app_initialization', error,
        error is Error ? error.stackTrace : null);

    rethrow;
  }
});