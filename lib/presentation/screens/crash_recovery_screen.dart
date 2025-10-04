import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/controllers/crash_recovery_controller.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class CrashRecoveryScreen extends ConsumerWidget {
  const CrashRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final state = ref.watch(crashRecoveryControllerProvider);

    return Scaffold(
      backgroundColor: tokens.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: EdgeInsets.all(tokens.spacing(6)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.refresh, size: tokens.spacing(12), color: tokens.brandPrimary),
                  SizedBox(height: tokens.spacing(4)),
                  Text(
                    '蜑榊屓縺ｮ繧ｻ繝・す繝ｧ繝ｳ繧貞ｾｩ蜈・＠縺ｾ縺吶°・・,
                    style: tokens.typeScale.h3.copyWith(color: tokens.textPrimary),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    '蜑榊屓縺ｮ襍ｷ蜍輔〒繧｢繝励Μ縺御ｺ域悄縺帙★邨ゆｺ・＠縺ｾ縺励◆縲ら憾諷九ｒ蠕ｩ蜈・☆繧九→縲∽ｿ晏ｭ倥＆繧後※縺・↑縺・ョ繝ｼ繧ｿ繧貞・隱ｭ縺ｿ霎ｼ縺ｿ縺励∪縺吶・,
                    style: tokens.typeScale.bodyMedium.copyWith(color: tokens.textMuted),
                  ),
                  if (state.report != null) ...[
                    SizedBox(height: tokens.spacing(4)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(tokens.spacing(3)),
                      decoration: BoxDecoration(
                        color: tokens.surface,
                        borderRadius: tokens.cornerLarge(),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Text(
                        state.report!.message,
                        style: tokens.typeScale.bodySmall.copyWith(color: tokens.textMuted),
                      ),
                    ),
                  ],
                  SizedBox(height: tokens.spacing(6)),
                  if (state.isRestoring)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref.read(crashRecoveryControllerProvider.notifier).restoreAndResume();
                        },
                        child: const Text('迥ｶ諷九ｒ蠕ｩ蜈・☆繧・),
                      ),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref.read(crashRecoveryControllerProvider.notifier).discardRecovery();
                        },
                        child: const Text('遐ｴ譽・＠縺ｦ襍ｷ蜍輔☆繧・),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
