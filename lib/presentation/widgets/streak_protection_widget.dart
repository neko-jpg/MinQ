import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class StreakProtectionWidget extends ConsumerWidget {
  const StreakProtectionWidget({super.key, required this.questId});

  final int questId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            'ストリーク保護を有効化',
            style: tokens.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: tokens.textPrimary,
            ),
          ),
          subtitle: Text(
            '週末や休日に自動的にストリークを保護します',
            style: tokens.bodySmall.copyWith(color: tokens.textMuted),
          ),
          value: false, // TODO: Implement state
          onChanged: (value) {
            // TODO: Implement logic
          },
          activeColor: tokens.brandPrimary,
        ),
      ],
    );
  }
}
