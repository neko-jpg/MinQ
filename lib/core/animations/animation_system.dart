import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 高度なアニメーションシステムの中核クラス（要件46、47、48）
class AnimationSystem {
  static AnimationSystem? _instance;
  static AnimationSystem get instance => _instance ??= AnimationSystem._();

  AnimationSystem._();

  bool _animationsEnabled = true;
  bool _reducedMotion = false;
  bool _hapticFeedbackEnabled = true;
  bool _soundEffectsEnabled = true;

  /// アニメーション設定の初期化
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _animationsEnabled = prefs.getBool('animations_enabled') ?? true;
    _reducedMotion = prefs.getBool('reduced_motion') ?? false;
    _hapticFeedbackEnabled = prefs.getBool('haptic_feedback_enabled') ?? true;
    _soundEffectsEnabled = prefs.getBool('sound_effects_enabled') ?? true;
  }

  /// アニメーション有効状態
  bool get animationsEnabled => _animationsEnabled && !_reducedMotion;

  /// 軽減されたモーション設定
  bool get reducedMotion => _reducedMotion;

  /// ハプティックフィードバック有効状態
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;

  /// サウンドエフェクト有効状態
  bool get soundEffectsEnabled => _soundEffectsEnabled;

  /// アニメーション設定の更新
  Future<void> updateAnimationSettings({
    bool? animationsEnabled,
    bool? reducedMotion,
    bool? hapticFeedbackEnabled,
    bool? soundEffectsEnabled,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (animationsEnabled != null) {
      _animationsEnabled = animationsEnabled;
      await prefs.setBool('animations_enabled', animationsEnabled);
    }

    if (reducedMotion != null) {
      _reducedMotion = reducedMotion;
      await prefs.setBool('reduced_motion', reducedMotion);
    }

    if (hapticFeedbackEnabled != null) {
      _hapticFeedbackEnabled = hapticFeedbackEnabled;
      await prefs.setBool('haptic_feedback_enabled', hapticFeedbackEnabled);
    }

    if (soundEffectsEnabled != null) {
      _soundEffectsEnabled = soundEffectsEnabled;
      await prefs.setBool('sound_effects_enabled', soundEffectsEnabled);
    }
  }

  /// アニメーション継続時間の取得（アクセシビリティ対応）
  Duration getDuration(Duration defaultDuration) {
    if (!animationsEnabled || reducedMotion) {
      return Duration.zero;
    }
    return defaultDuration;
  }

  /// カーブの取得（アクセシビリティ対応）
  Curve getCurve(Curve defaultCurve) {
    if (!animationsEnabled || reducedMotion) {
      return Curves.linear;
    }
    return defaultCurve;
  }

  /// ハプティックフィードバックの実行
  Future<void> playHapticFeedback(HapticFeedbackType type) async {
    if (!hapticFeedbackEnabled) return;

    switch (type) {
      case HapticFeedbackType.light:
        await HapticFeedback.lightImpact();
        break;
      case HapticFeedbackType.medium:
        await HapticFeedback.mediumImpact();
        break;
      case HapticFeedbackType.heavy:
        await HapticFeedback.heavyImpact();
        break;
      case HapticFeedbackType.selection:
        await HapticFeedback.selectionClick();
        break;
    }
  }

  /// マイクロインタラクション用のハプティック
  Future<void> playMicroInteractionHaptic() async {
    await playHapticFeedback(HapticFeedbackType.light);
  }

  /// 成功時のハプティック
  Future<void> playSuccessHaptic() async {
    if (!hapticFeedbackEnabled) return;

    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
  }

  /// エラー時のハプティック
  Future<void> playErrorHaptic() async {
    if (!hapticFeedbackEnabled) return;

    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}

/// ハプティックフィードバックの種類
enum HapticFeedbackType { light, medium, heavy, selection }

/// アニメーション設定プロバイダー
class AnimationSettingsProvider extends ChangeNotifier {
  final AnimationSystem _animationSystem = AnimationSystem.instance;

  bool get animationsEnabled => _animationSystem.animationsEnabled;
  bool get reducedMotion => _animationSystem.reducedMotion;
  bool get hapticFeedbackEnabled => _animationSystem.hapticFeedbackEnabled;
  bool get soundEffectsEnabled => _animationSystem.soundEffectsEnabled;

  Future<void> updateSettings({
    bool? animationsEnabled,
    bool? reducedMotion,
    bool? hapticFeedbackEnabled,
    bool? soundEffectsEnabled,
  }) async {
    await _animationSystem.updateAnimationSettings(
      animationsEnabled: animationsEnabled,
      reducedMotion: reducedMotion,
      hapticFeedbackEnabled: hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled,
    );
    notifyListeners();
  }
}
