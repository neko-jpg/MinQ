import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/logging/secure_startup_logger.dart';
import 'package:minq/core/startup/crash_prevention_service.dart';
import 'package:minq/core/startup/startup_performance_manager.dart';

/// 最適化された初期化サービス
/// 1.5-2.0秒の起動時間を目標とし、クラッシュ防止とパフォーマンス監視を統合
class OptimalInitializationService {
  /// 重要な初期化プロセスを並列実行（パフォーマンス監視とクラッシュ防止付き）
  static Future<void> initializeApp(
    Ref ref, {
    StartupProgressCallback? onProgress,
  }) async {
    // Initialize crash prevention first
    await crashPreventionService.initialize();

    // Initialize secure logging
    await secureStartupLogger.initialize();

    // Use startup performance manager for optimized initialization
    await startupPerformanceManager.initializeApp(ref, onProgress: onProgress);
  }
}

/// 最適化された初期化プロバイダー（パフォーマンス監視とクラッシュ防止付き）
const _minimumSplashDuration = Duration(milliseconds: 1600);

final optimizedAppStartupProvider = FutureProvider<void>((ref) async {
  try {
    await Future.wait([
      OptimalInitializationService.initializeApp(ref),
      Future<void>.delayed(_minimumSplashDuration),
    ]);
  } catch (error) {
    // Log the error securely
    secureStartupLogger.logStartupError(
      'app_initialization',
      error,
      error is Error ? error.stackTrace : null,
    );

    rethrow;
  }
});
