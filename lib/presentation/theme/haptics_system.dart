import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 繝上・繝・ぅ繧ｯ繧ｹ繧ｷ繧ｹ繝・Β - 隗ｦ隕壹ヵ繧｣繝ｼ繝峨ヰ繝・け縺ｮ邨ｱ荳隕乗ｼ
class HapticsSystem {
  const HapticsSystem._();

  // ========================================
  // 蝓ｺ譛ｬ繝上・繝・ぅ繧ｯ繧ｹ
  // ========================================

  /// 霆ｽ縺・ち繝・・ - 繝懊ち繝ｳ繧ｿ繝・・縲・∈謚・
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// 荳ｭ遞句ｺｦ縺ｮ繧ｿ繝・・ - 驥崎ｦ√↑繧｢繧ｯ繧ｷ繝ｧ繝ｳ
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// 驥阪＞繧ｿ繝・・ - 髱槫ｸｸ縺ｫ驥崎ｦ√↑繧｢繧ｯ繧ｷ繝ｧ繝ｳ
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// 驕ｸ謚槫､画峩 - 繧ｹ繝ｩ繧､繝繝ｼ縲√ヴ繝・き繝ｼ
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// 繝舌う繝悶Ξ繝ｼ繧ｷ繝ｧ繝ｳ - 騾夂衍縲√い繝ｩ繝ｼ繝・
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  // ========================================
  // 繧ｻ繝槭Φ繝・ぅ繝・け繝上・繝・ぅ繧ｯ繧ｹ
  // ========================================

  /// 謌仙粥 - 繧ｿ繧ｹ繧ｯ螳御ｺ・∽ｿ晏ｭ俶・蜉・
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 隴ｦ蜻・- 豕ｨ諢上′蠢・ｦ・
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }

  /// 繧ｨ繝ｩ繝ｼ - 螟ｱ謨励∫┌蜉ｹ縺ｪ謫堺ｽ・
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// 騾夂衍 - 譁ｰ縺励＞諠・ｱ
  static Future<void> notification() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.lightImpact();
  }

  // ========================================
  // UI隕∫ｴ蛻･繝上・繝・ぅ繧ｯ繧ｹ
  // ========================================

  /// 繝懊ち繝ｳ繧ｿ繝・・
  static Future<void> buttonTap() async {
    await lightImpact();
  }

  /// 繝励Λ繧､繝槭Μ繝懊ち繝ｳ繧ｿ繝・・
  static Future<void> primaryButtonTap() async {
    await mediumImpact();
  }

  /// 繧ｹ繧､繝・メ蛻・ｊ譖ｿ縺・
  static Future<void> switchToggle() async {
    await selectionClick();
  }

  /// 繝√ぉ繝・け繝懊ャ繧ｯ繧ｹ蛻・ｊ譖ｿ縺・
  static Future<void> checkboxToggle() async {
    await lightImpact();
  }

  /// 繧ｹ繝ｩ繧､繝繝ｼ遘ｻ蜍・
  static Future<void> sliderMove() async {
    await selectionClick();
  }

  /// 繝峨Λ繝・げ髢句ｧ・
  static Future<void> dragStart() async {
    await mediumImpact();
  }

  /// 繝峨Λ繝・げ邨ゆｺ・
  static Future<void> dragEnd() async {
    await lightImpact();
  }

  /// 繝峨Ο繝・・謌仙粥
  static Future<void> dropSuccess() async {
    await success();
  }

  /// 繝ｪ繝輔Ξ繝・す繝･
  static Future<void> refresh() async {
    await mediumImpact();
  }

  /// 繝壹・繧ｸ驕ｷ遘ｻ
  static Future<void> pageTransition() async {
    await lightImpact();
  }

  /// 繝｢繝ｼ繝繝ｫ陦ｨ遉ｺ
  static Future<void> modalPresent() async {
    await mediumImpact();
  }

  /// 繝｢繝ｼ繝繝ｫ髢峨§繧・
  static Future<void> modalDismiss() async {
    await lightImpact();
  }

  // ========================================
  // 繧｢繝励Μ蝗ｺ譛峨・繝上・繝・ぅ繧ｯ繧ｹ
  // ========================================

  /// 繧ｯ繧ｨ繧ｹ繝亥ｮ御ｺ・
  static Future<void> questComplete() async {
    await success();
  }

  /// 繧ｯ繧ｨ繧ｹ繝井ｽ懈・
  static Future<void> questCreate() async {
    await mediumImpact();
  }

  /// 繧ｯ繧ｨ繧ｹ繝亥炎髯､
  static Future<void> questDelete() async {
    await heavyImpact();
  }

  /// 繝壹い繝槭ャ繝√Φ繧ｰ謌仙粥
  static Future<void> pairMatched() async {
    await heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await lightImpact();
  }

  /// 騾｣邯夐＃謌占ｨ倬鹸譖ｴ譁ｰ
  static Future<void> streakAchieved() async {
    await success();
  }

  /// 繝ｬ繝吶Ν繧｢繝・・
  static Future<void> levelUp() async {
    await pairMatched(); // 蜷後§繝代ち繝ｼ繝ｳ
  }

  // ========================================
  // 繝倥Ν繝代・繝｡繧ｽ繝・ラ
  // ========================================

  /// Reduce Motion險ｭ螳壹ｒ閠・・縺励※繝上・繝・ぅ繧ｯ繧ｹ繧貞ｮ溯｡・
  static Future<void> performIfEnabled(
    BuildContext context,
    Future<void> Function() haptic,
  ) async {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!reduceMotion) {
      await haptic();
    }
  }

  /// 繧ｫ繧ｹ繧ｿ繝繝代ち繝ｼ繝ｳ
  static Future<void> customPattern(List<HapticEvent> events) async {
    for (final event in events) {
      await event.execute();
      if (event.delay != null) {
        await Future.delayed(event.delay!);
      }
    }
  }
}

/// 繝上・繝・ぅ繧ｯ繧ｹ繧､繝吶Φ繝・
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

/// 繝上・繝・ぅ繧ｯ繧ｹ繧ｿ繧､繝・
enum HapticType {
  light,
  medium,
  heavy,
  selection,
  vibrate,
}

/// 繝上・繝・ぅ繧ｯ繧ｹ蟇ｾ蠢懊え繧｣繧ｸ繧ｧ繝・ヨ諡｡蠑ｵ
extension HapticWidget on Widget {
  /// 繧ｿ繝・・譎ゅ↓繝上・繝・ぅ繧ｯ繧ｹ繧貞ｮ溯｡・
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

  /// 繝懊ち繝ｳ繝上・繝・ぅ繧ｯ繧ｹ莉倥″
  Widget withButtonHaptic(VoidCallback onTap) {
    return withHaptic(
      onTap: onTap,
      haptic: HapticsSystem.buttonTap,
    );
  }
}

/// 繝上・繝・ぅ繧ｯ繧ｹ蟇ｾ蠢懊・繧ｿ繝ｳ
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

/// 繝上・繝・ぅ繧ｯ繧ｹ蟇ｾ蠢懊い繧､繧ｳ繝ｳ繝懊ち繝ｳ
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

/// 繝上・繝・ぅ繧ｯ繧ｹ蟇ｾ蠢懊せ繧､繝・メ
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

/// 繝上・繝・ぅ繧ｯ繧ｹ蟇ｾ蠢懊メ繧ｧ繝・け繝懊ャ繧ｯ繧ｹ
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
