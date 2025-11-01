import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/core/animations/animation_system.dart';

/// アニメーション設定プロバイダー
final animationSettingsProvider =
    ChangeNotifierProvider<AnimationSettingsProvider>(
      (ref) => AnimationSettingsProvider(),
    );

/// アニメーション有効状態プロバイダー
final animationsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(animationSettingsProvider);
  return settings.animationsEnabled;
});

/// 軽減モーション状態プロバイダー
final reducedMotionProvider = Provider<bool>((ref) {
  final settings = ref.watch(animationSettingsProvider);
  return settings.reducedMotion;
});

/// ハプティックフィードバック有効状態プロバイダー
final hapticFeedbackEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(animationSettingsProvider);
  return settings.hapticFeedbackEnabled;
});

/// サウンドエフェクト有効状態プロバイダー
final soundEffectsEnabledProvider = Provider<bool>((ref) {
  final settings = ref.watch(animationSettingsProvider);
  return settings.soundEffectsEnabled;
});
