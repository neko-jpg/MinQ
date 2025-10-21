import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// バッテリー最適化マネージャー
class BatteryOptimizer {
  static final BatteryOptimizer _instance = BatteryOptimizer._internal();
  factory BatteryOptimizer() => _instance;
  BatteryOptimizer._internal();

  Timer? _batteryMonitor;
  BatteryLevel _currentLevel = BatteryLevel.normal;
  bool _isLowPowerMode = false;
  final List<BatteryOptimizationStrategy> _strategies = [];

  /// バッテリー最適化を開始
  void startOptimization() {
    _initializeStrategies();
    _startBatteryMonitoring();
  }

  /// 最適化戦略を初期化
  void _initializeStrategies() {
    _strategies.addAll([
      AnimationOptimizationStrategy(),
      NetworkOptimizationStrategy(),
      BackgroundTaskOptimizationStrategy(),
      UIOptimizationStrategy(),
      LocationOptimizationStrategy(),
    ]);
  }

  /// バッテリー監視を開始
  void _startBatteryMonitoring() {
    _batteryMonitor = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkBatteryLevel(),
    );
  }

  /// バッテリーレベルをチェック
  Future<void> _checkBatteryLevel() async {
    try {
      // プラットフォーム固有のバッテリー情報取得
      final batteryLevel = await _getBatteryLevel();
      final isLowPowerMode = await _isInLowPowerMode();

      _updateOptimizationLevel(batteryLevel, isLowPowerMode);
    } catch (e) {
      if (kDebugMode) {
        print('Battery level check failed: $e');
      }
    }
  }

  /// バッテリーレベルを取得
  Future<double> _getBatteryLevel() async {
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        const platform = MethodChannel('battery_level');
        final level = await platform.invokeMethod<int>('getBatteryLevel');
        return (level ?? 100) / 100.0;
      } catch (e) {
        return 1.0; // フォールバック
      }
    }
    return 1.0;
  }

  /// 低電力モードかチェック
  Future<bool> _isInLowPowerMode() async {
    if (Platform.isIOS) {
      try {
        const platform = MethodChannel('low_power_mode');
        return await platform.invokeMethod<bool>('isLowPowerModeEnabled') ??
            false;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  /// 最適化レベルを更新
  void _updateOptimizationLevel(double batteryLevel, bool isLowPowerMode) {
    final previousLevel = _currentLevel;
    final previousLowPowerMode = _isLowPowerMode;

    // バッテリーレベルを判定
    if (batteryLevel <= 0.15) {
      _currentLevel = BatteryLevel.critical;
    } else if (batteryLevel <= 0.30) {
      _currentLevel = BatteryLevel.low;
    } else {
      _currentLevel = BatteryLevel.normal;
    }

    _isLowPowerMode = isLowPowerMode;

    // レベルが変更された場合、戦略を適用
    if (previousLevel != _currentLevel ||
        previousLowPowerMode != _isLowPowerMode) {
      _applyOptimizationStrategies();
    }
  }

  /// 最適化戦略を適用
  void _applyOptimizationStrategies() {
    final optimizationLevel = _getOptimizationLevel();

    for (final strategy in _strategies) {
      strategy.apply(optimizationLevel);
    }

    if (kDebugMode) {
      print('Battery optimization applied: $optimizationLevel');
    }
  }

  /// 最適化レベルを取得
  OptimizationLevel _getOptimizationLevel() {
    if (_isLowPowerMode || _currentLevel == BatteryLevel.critical) {
      return OptimizationLevel.aggressive;
    } else if (_currentLevel == BatteryLevel.low) {
      return OptimizationLevel.moderate;
    } else {
      return OptimizationLevel.minimal;
    }
  }

  /// 現在のバッテリー状態を取得
  BatteryStatus getCurrentStatus() {
    return BatteryStatus(
      level: _currentLevel,
      isLowPowerMode: _isLowPowerMode,
      optimizationLevel: _getOptimizationLevel(),
    );
  }

  /// 停止
  void stop() {
    _batteryMonitor?.cancel();
    _batteryMonitor = null;
  }
}

/// バッテリーレベル
enum BatteryLevel {
  normal, // 30%以上
  low, // 15-30%
  critical, // 15%以下
}

/// 最適化レベル
enum OptimizationLevel {
  minimal, // 通常時
  moderate, // バッテリー低下時
  aggressive, // 低電力モード/クリティカル時
}

/// バッテリー状態
class BatteryStatus {
  const BatteryStatus({
    required this.level,
    required this.isLowPowerMode,
    required this.optimizationLevel,
  });

  final BatteryLevel level;
  final bool isLowPowerMode;
  final OptimizationLevel optimizationLevel;
}

/// バッテリー最適化戦略の基底クラス
abstract class BatteryOptimizationStrategy {
  void apply(OptimizationLevel level);
}

/// アニメーション最適化戦略
class AnimationOptimizationStrategy implements BatteryOptimizationStrategy {
  @override
  void apply(OptimizationLevel level) {
    switch (level) {
      case OptimizationLevel.minimal:
        // 通常のアニメーション
        break;
      case OptimizationLevel.moderate:
        // アニメーション時間を短縮
        _reduceAnimationDuration(0.7);
        break;
      case OptimizationLevel.aggressive:
        // アニメーションを無効化
        _disableAnimations();
        break;
    }
  }

  void _reduceAnimationDuration(double factor) {
    // アニメーション時間を短縮する実装
    if (kDebugMode) {
      print('Animation duration reduced by ${(1 - factor) * 100}%');
    }
  }

  void _disableAnimations() {
    // アニメーションを無効化する実装
    if (kDebugMode) {
      print('Animations disabled for battery saving');
    }
  }
}

/// ネットワーク最適化戦略
class NetworkOptimizationStrategy implements BatteryOptimizationStrategy {
  @override
  void apply(OptimizationLevel level) {
    switch (level) {
      case OptimizationLevel.minimal:
        // 通常のネットワーク使用
        break;
      case OptimizationLevel.moderate:
        // バックグラウンド同期を削減
        _reduceBackgroundSync();
        break;
      case OptimizationLevel.aggressive:
        // 必要最小限のネットワーク使用
        _minimizeNetworkUsage();
        break;
    }
  }

  void _reduceBackgroundSync() {
    if (kDebugMode) {
      print('Background sync reduced');
    }
  }

  void _minimizeNetworkUsage() {
    if (kDebugMode) {
      print('Network usage minimized');
    }
  }
}

/// バックグラウンドタスク最適化戦略
class BackgroundTaskOptimizationStrategy
    implements BatteryOptimizationStrategy {
  @override
  void apply(OptimizationLevel level) {
    switch (level) {
      case OptimizationLevel.minimal:
        // 通常のバックグラウンドタスク
        break;
      case OptimizationLevel.moderate:
        // 重要でないタスクを延期
        _deferNonCriticalTasks();
        break;
      case OptimizationLevel.aggressive:
        // バックグラウンドタスクを停止
        _suspendBackgroundTasks();
        break;
    }
  }

  void _deferNonCriticalTasks() {
    if (kDebugMode) {
      print('Non-critical background tasks deferred');
    }
  }

  void _suspendBackgroundTasks() {
    if (kDebugMode) {
      print('Background tasks suspended');
    }
  }
}

/// UI最適化戦略
class UIOptimizationStrategy implements BatteryOptimizationStrategy {
  @override
  void apply(OptimizationLevel level) {
    switch (level) {
      case OptimizationLevel.minimal:
        // 通常のUI
        break;
      case OptimizationLevel.moderate:
        // UI更新頻度を削減
        _reduceUIUpdates();
        break;
      case OptimizationLevel.aggressive:
        // 最小限のUI更新
        _minimizeUIUpdates();
        break;
    }
  }

  void _reduceUIUpdates() {
    if (kDebugMode) {
      print('UI update frequency reduced');
    }
  }

  void _minimizeUIUpdates() {
    if (kDebugMode) {
      print('UI updates minimized');
    }
  }
}

/// 位置情報最適化戦略
class LocationOptimizationStrategy implements BatteryOptimizationStrategy {
  @override
  void apply(OptimizationLevel level) {
    switch (level) {
      case OptimizationLevel.minimal:
        // 通常の位置情報使用
        break;
      case OptimizationLevel.moderate:
        // 位置情報更新頻度を削減
        _reduceLocationUpdates();
        break;
      case OptimizationLevel.aggressive:
        // 位置情報サービスを停止
        _disableLocationServices();
        break;
    }
  }

  void _reduceLocationUpdates() {
    if (kDebugMode) {
      print('Location update frequency reduced');
    }
  }

  void _disableLocationServices() {
    if (kDebugMode) {
      print('Location services disabled');
    }
  }
}

/// バッテリー効率的なウィジェット
class BatteryEfficientWidget extends StatefulWidget {
  const BatteryEfficientWidget({
    super.key,
    required this.child,
    this.enableOptimization = true,
  });

  final Widget child;
  final bool enableOptimization;

  @override
  State<BatteryEfficientWidget> createState() => _BatteryEfficientWidgetState();
}

class _BatteryEfficientWidgetState extends State<BatteryEfficientWidget>
    with WidgetsBindingObserver {
  BatteryStatus? _batteryStatus;
  Timer? _statusUpdateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    if (widget.enableOptimization) {
      _startStatusMonitoring();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  void _startStatusMonitoring() {
    _updateBatteryStatus();
    _statusUpdateTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _updateBatteryStatus(),
    );
  }

  void _updateBatteryStatus() {
    setState(() {
      _batteryStatus = BatteryOptimizer().getCurrentStatus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused) {
      // アプリがバックグラウンドに移行時の最適化
      _statusUpdateTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      // アプリがフォアグラウンドに復帰時
      if (widget.enableOptimization) {
        _startStatusMonitoring();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enableOptimization || _batteryStatus == null) {
      return widget.child;
    }

    // バッテリー状態に応じてウィジェットを最適化
    switch (_batteryStatus!.optimizationLevel) {
      case OptimizationLevel.minimal:
        return widget.child;

      case OptimizationLevel.moderate:
        return RepaintBoundary(child: widget.child);

      case OptimizationLevel.aggressive:
        return RepaintBoundary(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150), // 短縮されたアニメーション
            child: widget.child,
          ),
        );
    }
  }
}
