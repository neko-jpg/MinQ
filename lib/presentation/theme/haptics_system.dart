import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// ハ�EチE��クスシスチE�� - 触覚フィードバチE��の統一規格
class HapticsSystem {
  const HapticsSystem._();

  // ========================================
  // 基本ハ�EチE��クス
  // ========================================

  /// 軽ぁE��チE�E - ボタンタチE�E、E��抁E
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// 中程度のタチE�E - 重要なアクション
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// 重いタチE�E - 非常に重要なアクション
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// 選択変更 - スライダー、ピチE��ー
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// バイブレーション - 通知、アラーチE
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  // ========================================
  // セマンチE��チE��ハ�EチE��クス
  // ========================================

  /// 成功 - タスク完亁E��保存�E劁E
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 警呁E- 注意が忁E��E
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// エラー - 失敗、無効な操佁E
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 通知 - 新しい惁E��
  static Future<void> notification() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  // ========================================
  // UI要素別ハ�EチE��クス
  // ========================================

  /// ボタンタチE�E
  static Future<void> buttonTap() async {
    await lightImpact();
  }

  /// プライマリボタンタチE�E
  static Future<void> primaryButtonTap() async {
    await mediumImpact();
  }

  /// スイチE��刁E��替ぁE
  static Future<void> switchToggle() async {
    await selectionClick();
  }

  /// チェチE��ボックス刁E��替ぁE
  static Future<void> checkboxToggle() async {
    await lightImpact();
  }

  /// スライダー移勁E
  static Future<void> sliderMove() async {
    await selectionClick();
  }

  /// ドラチE��開姁E
  static Future<void> dragStart() async {
    await mediumImpact();
  }

  /// ドラチE��終亁E
  static Future<void> dragEnd() async {
    await lightImpact();
  }

  /// ドロチE�E成功
  static Future<void> dropSuccess() async {
    await success();
  }

  /// リフレチE��ュ
  static Future<void> refresh() async {
    await mediumImpact();
  }

  /// ペ�Eジ遷移
  static Future<void> pageTransition() async {
    await lightImpact();
  }

  /// モーダル表示
  static Future<void> modalPresent() async {
    await mediumImpact();
  }

  /// モーダル閉じめE
  static Future<void> modalDismiss() async {
    await lightImpact();
  }

  // ========================================
  // アプリ固有�Eハ�EチE��クス
  // ========================================

  /// クエスト完亁E
  static Future<void> questComplete() async {
    await success();
  }

  /// クエスト作�E
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

  /// レベルアチE�E
  static Future<void> levelUp() async {
    await pairMatched(); // 同じパターン
  }

  // ========================================
  // ヘルパ�EメソチE��
  // ========================================

  /// Reduce Motion設定を老E�Eしてハ�EチE��クスを実衁E
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

/// ハ�EチE��クスイベンチE
class HapticEvent {
  final HapticType type;
  final Duration? delay;

  const HapticEvent({
    required this.type,
    this.delay,
  });

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

/// ハ�EチE��クスタイチE
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// ハ�EチE��クス対応ウィジェチE��拡張
extension HapticWidget on Widget {
  /// タチE�E時にハ�EチE��クスを実衁E
  Widget withHaptic({
    VoidCallback? onTap,
    Future<void> Function()? haptic,
  }) {
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

  /// ボタンハ�EチE��クス付き
  Widget withButtonHaptic(VoidCallback onTap) {
    return withHaptic(
      onTap: onTap,
      haptic: HapticsSystem.buttonTap,
    );
  }
}

/// ハ�EチE��クス対応�Eタン
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
      onPressed: onPressed == null
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

/// ハ�EチE��クス対応アイコンボタン
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
      onPressed: onPressed == null
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

/// ハ�EチE��クス対応スイチE��
class HapticSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const HapticSwitch({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged == null
          ? null
          : (newValue) async {
              await HapticsSystem.switchToggle();
              onChanged!(newValue);
            },
    );
  }
}

/// ハ�EチE��クス対応チェチE��ボックス
class HapticCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  const HapticCheckbox({
    super.key,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: onChanged == null
          ? null
          : (newValue) async {
              await HapticsSystem.checkboxToggle();
              onChanged!(newValue);
            },
    );
  }
}
