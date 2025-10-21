import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ハプティクスシステム - 触覚フィードバックの統一規格
class HapticsSystem {
  const HapticsSystem._();

  // ========================================
  // 基本ハプティクス
  // ========================================

  /// 軽いタップ - ボタンタップ、選択
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// 中程度のタップ - 重要なアクション
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// 重いタップ - 非常に重要なアクション
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// 選択変更 - スライダー、ピッカー
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// バイブレーション - 通知、アラート
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  // ========================================
  // セマンティックハプティクス
  // ========================================

  /// 成功 - タスク完了、保存成功
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 警告 - 注意が必要
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// エラー - 失敗、無効な操作
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 通知 - 新しい情報
  static Future<void> notification() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  // ========================================
  // UI要素別ハプティクス
  // ========================================

  /// ボタンタップ
  static Future<void> buttonTap() async {
    await lightImpact();
  }

  /// プライマリボタンタップ
  static Future<void> primaryButtonTap() async {
    await mediumImpact();
  }

  /// スイッチ切り替え
  static Future<void> switchToggle() async {
    await selectionClick();
  }

  /// チェックボックス切り替え
  static Future<void> checkboxToggle() async {
    await lightImpact();
  }

  /// スライダー移動
  static Future<void> sliderMove() async {
    await selectionClick();
  }

  /// ドラッグ開始
  static Future<void> dragStart() async {
    await mediumImpact();
  }

  /// ドラッグ終了
  static Future<void> dragEnd() async {
    await lightImpact();
  }

  /// ドロップ成功
  static Future<void> dropSuccess() async {
    await success();
  }

  /// リフレッシュ
  static Future<void> refresh() async {
    await mediumImpact();
  }

  /// ページ遷移
  static Future<void> pageTransition() async {
    await lightImpact();
  }

  /// モーダル表示
  static Future<void> modalPresent() async {
    await mediumImpact();
  }

  /// モーダル閉じる
  static Future<void> modalDismiss() async {
    await lightImpact();
  }

  // ========================================
  // アプリ固有のハプティクス
  // ========================================

  /// クエスト完了
  static Future<void> questComplete() async {
    await success();
  }

  /// クエスト作成
  static Future<void> questCreate() async {
    await mediumImpact();
  }

  /// クエスト削除
  static Future<void> questDelete() async {
    await heavyImpact();
  }

  /// ペアマッチング成功
  static Future<void> pairMatched() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }

  /// 連続達成記録更新
  static Future<void> streakAchieved() async {
    await success();
  }

  /// レベルアップ
  static Future<void> levelUp() async {
    await pairMatched(); // 同じパターン
  }

  // ========================================
  // ヘルパーメソッド
  // ========================================

  /// Reduce Motion設定を考慮してハプティクスを実行
  static Future<void> performIfEnabled(
    BuildContext context,
    Future<void> Function() haptic,
  ) async {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      await haptic();
    }
  }

  /// カスタムパターン
  static Future<void> customPattern(List<HapticEvent> events) async {
    for (final event in events) {
      await event.execute();
      if (event.delay != null) {
        await Future.delayed(event.delay!);
      }
    }
  }
}

/// ハプティクスイベント
class HapticEvent {
  final HapticType type;
  final Duration? delay;

  const HapticEvent({required this.type, this.delay});

  Future<void> execute() async {
    switch (type) {
      case HapticType.light:
        await HapticsSystem.lightImpact();
        break;
      case HapticType.medium:
        await HapticsSystem.mediumImpact();
        break;
      case HapticType.heavy:
        await HapticsSystem.heavyImpact();
        break;
      case HapticType.selection:
        await HapticsSystem.selectionClick();
        break;
      case HapticType.vibrate:
        await HapticsSystem.vibrate();
        break;
    }
  }
}

/// ハプティクスタイプ
enum HapticType { light, medium, heavy, selection, vibrate }

/// ハプティクス対応ウィジェット拡張
extension HapticWidget on Widget {
  /// タップ時にハプティクスを実行
  Widget withHaptic({VoidCallback? onTap, Future<void> Function()? haptic}) {
    return GestureDetector(
      onTap: () async {
        if (haptic != null) {
          await haptic();
        } else {
          await HapticsSystem.lightImpact();
        }
        onTap?.call();
      },
      child: this,
    );
  }

  /// ボタンハプティクス付き
  Widget withButtonHaptic(VoidCallback onTap) {
    return withHaptic(onTap: onTap, haptic: HapticsSystem.buttonTap);
  }
}

/// ハプティクス対応ボタン
class HapticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Future<void> Function()? haptic;
  final ButtonStyle? style;

  const HapticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.haptic,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed:
          onPressed == null
              ? null
              : () async {
                if (haptic != null) {
                  await haptic!();
                } else {
                  await HapticsSystem.buttonTap();
                }
                onPressed!();
              },
      child: child,
    );
  }
}

/// ハプティクス対応アイコンボタン
class HapticIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onPressed;
  final Future<void> Function()? haptic;

  const HapticIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.haptic,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: icon,
      onPressed:
          onPressed == null
              ? null
              : () async {
                if (haptic != null) {
                  await haptic!();
                } else {
                  await HapticsSystem.buttonTap();
                }
                onPressed!();
              },
    );
  }
}

/// ハプティクス対応スイッチ
class HapticSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const HapticSwitch({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged:
          onChanged == null
              ? null
              : (newValue) async {
                await HapticsSystem.switchToggle();
                onChanged!(newValue);
              },
    );
  }
}

/// ハプティクス対応チェックボックス
class HapticCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  const HapticCheckbox({super.key, required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged:
          onChanged == null
              ? null
              : (newValue) async {
                await HapticsSystem.checkboxToggle();
                onChanged!(newValue);
              },
    );
  }
}
