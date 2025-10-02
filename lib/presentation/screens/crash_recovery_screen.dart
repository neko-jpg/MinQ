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
                    '前回のセッションを復元しますか？',
                    style: tokens.typeScale.h3.copyWith(color: tokens.textPrimary),
                  ),
                  SizedBox(height: tokens.spacing(2)),
                  Text(
                    '前回の起動でアプリが予期せず終了しました。状態を復元すると、保存されていないデータを再読み込みします。',
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
                        child: const Text('状態を復元する'),
                      ),
                    ),
                    SizedBox(height: tokens.spacing(2)),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await ref.read(crashRecoveryControllerProvider.notifier).discardRecovery();
                        },
                        child: const Text('破棄して起動する'),
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
