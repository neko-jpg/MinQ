import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

/// サウンドエフェクトサービス
/// 
/// アプリ全体で使用するサウンドエフェクトを管理
class SoundEffectsService {
  static SoundEffectsService? _instance;
  static SoundEffectsService get instance => _instance ??= SoundEffectsService._();
  
  SoundEffectsService._();

  final Map<SoundType, AudioPlayer> _players = {};
  bool _isEnabled = true;
  double _volume = 0.5;

  /// サービスの初期化
  Future<void> initialize() async {
    try {
      log('SoundEffectsService: 初期化開始');
      
      // 各サウンドタイプのプレイヤーを初期化
      for (final soundType in SoundType.values) {
        final player = AudioPlayer();
        await player.setAsset(_getAssetPath(soundType));
        await player.setVolume(_volume);
        _players[soundType] = player;
      }
      
      log('SoundEffectsService: 初期化完了');
    } catch (e) {
      log('SoundEffectsService: 初期化エラー - $e');
    }
  }

  /// サウンドの再生
  Future<void> play(SoundType soundType) async {
    if (!_isEnabled) return;
    
    try {
      final player = _players[soundType];
      if (player != null) {
        await player.seek(Duration.zero);
        await player.play();
      }
    } catch (e) {
      log('SoundEffectsService: 再生エラー - $e');
    }
  }

  /// サウンドの有効/無効を設定
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// 音量を設定
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    
    for (final player in _players.values) {
      await player.setVolume(_volume);
    }
  }

  /// サービスの終了
  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
  }

  /// アセットパスを取得
  String _getAssetPath(SoundType soundType) {
    switch (soundType) {
      case SoundType.tap:
        return 'assets/sounds/tap.wav';
      case SoundType.success:
        return 'assets/sounds/success.wav';
      case SoundType.error:
        return 'assets/sounds/error.wav';
      case SoundType.notification:
        return 'assets/sounds/notification.wav';
      case SoundType.levelUp:
        return 'assets/sounds/level_up.wav';
      case SoundType.achievement:
        return 'assets/sounds/achievement.wav';
      case SoundType.coin:
        return 'assets/sounds/coin.wav';
      case SoundType.whoosh:
        return 'assets/sounds/whoosh.wav';
      case SoundType.pop:
        return 'assets/sounds/pop.wav';
      case SoundType.chime:
        return 'assets/sounds/chime.wav';
    }
  }
}

/// サウンドタイプ
enum SoundType {
  tap,           // タップ音
  success,       // 成功音
  error,         // エラー音
  notification,  // 通知音
  levelUp,       // レベルアップ音
  achievement,   // 達成音
  coin,          // コイン音
  whoosh,        // スワイプ音
  pop,           // ポップ音
  chime,         // チャイム音
}

/// サウンドエフェクト付きウィジェット
class SoundEffectWidget extends StatelessWidget {
  final Widget child;
  final SoundType? soundType;
  final VoidCallback? onTap;

  const SoundEffectWidget({
    super.key,
    required this.child,
    this.soundType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (soundType != null) {
          SoundEffectsService.instance.play(soundType!);
        }
        onTap?.call();
      },
      child: child,
    );
  }
}

/// システムサウンド（フォールバック用）
class SystemSounds {
  SystemSounds._();

  /// タップ音
  static void tap() {
    SystemSound.play(SystemSoundType.click);
  }

  /// 成功音
  static void success() {
    // iOS: システム音 1016 (成功音)
    // Android: デフォルトの通知音
    SystemSound.play(SystemSoundType.click);
  }

  /// エラー音
  static void error() {
    // iOS: システム音 1053 (エラー音)
    // Android: デフォルトの通知音
    SystemSound.play(SystemSoundType.alert);
  }
}