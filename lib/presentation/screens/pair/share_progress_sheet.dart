import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class ShareProgressSheet extends ConsumerStatefulWidget {
  const ShareProgressSheet({super.key, required this.pairId});

  final String pairId;

  @override
  ConsumerState<ShareProgressSheet> createState() => _ShareProgressSheetState();
}

class _ShareProgressSheetState extends ConsumerState<ShareProgressSheet> {
  int _selectedAchievement = 0; // 0: Done, 1: Partial, 2: Not Done
  String _selectedQuest = '運動';

  void _shareProgress() {
    final repo = ref.read(pairRepositoryProvider);
    final uid = ref.read(uidProvider);
    if (repo == null || uid == null) return;

    final achievementMap = {0: '✔ 達成', 1: '△ 部分達成', 2: '✘ 未達成'};
    final achievementText = achievementMap[_selectedAchievement] ?? '';

    final message = '【進捗共有】\nクエスト「$_selectedQuest」を$achievementTextしました！';

    repo.sendMessage(pairId: widget.pairId, senderId: uid, text: message);

    Navigator.of(context).pop();
  }

  void _showMemoDialog() {
    final memoController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('メモを添付'),
        content: TextField(
          controller: memoController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '今日の頑張りを伝えよう'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            child: const Text('キャンセル'),
            onPressed: () => Navigator.of(dialogCtx).pop(),
          ),
          TextButton(
            child: const Text('送信'),
            onPressed: () {
              final repo = ref.read(pairRepositoryProvider);
              final uid = ref.read(uidProvider);
              final memo = memoController.text.trim();
              if (memo.isNotEmpty && repo != null && uid != null) {
                repo.sendMessage(
                  pairId: widget.pairId,
                  senderId: uid,
                  text: memo,
                );
              }
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop(); // Close the bottom sheet as well
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        margin: EdgeInsets.all(tokens.spacing.lg),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: tokens.surface.withAlpha((255 * 0.8).round()),
          borderRadius: tokens.cornerXLarge(),
          border: Border.all(color: tokens.border.withAlpha((255 * 0.5).round())),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, tokens),
            _buildContent(context, tokens),
            _buildFooter(context, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '進捗を共有',
            style: tokens.typography.h2.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MinqTheme tokens) {
    return Flexible(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.lg,
          vertical: tokens.spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestSelector(tokens),
            SizedBox(height: tokens.spacing.xl),
            _buildAttachmentButtons(tokens),
            SizedBox(height: tokens.spacing.xl),
            _buildAchievementSelector(tokens),
            SizedBox(height: tokens.spacing.xl),
            _buildStreakProgress(tokens),
            SizedBox(height: tokens.spacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestSelector(MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'クエストを選択',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        DropdownButtonFormField<String>(
          initialValue: _selectedQuest,
          items: ['運動', '勉強', '読書']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedQuest = value);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.background,
            border: OutlineInputBorder(
              borderRadius: tokens.cornerLarge(),
              borderSide: BorderSide(color: tokens.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentButtons(MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '証拠を添付',
          style: tokens.typography.body.copyWith(color: tokens.textMuted),
        ),
        SizedBox(height: tokens.spacing.sm),
        Row(
          children: [
            Expanded(
              child: _AttachmentButton(
                tokens: tokens,
                icon: Icons.photo_camera,
                label: '写真',
                onPressed: () {
                  /* TODO */
                },
              ),
            ),
            SizedBox(width: tokens.spacing.lg),
            Expanded(
              child: _AttachmentButton(
                tokens: tokens,
                icon: Icons.edit_note,
                label: 'メモ',
                onPressed: _showMemoDialog,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementSelector(MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('達成度', style: tokens.typography.body.copyWith(color: tokens.textMuted)),
        SizedBox(height: tokens.spacing.sm),
        ToggleButtons(
          isSelected: List.generate(
            3,
            (index) => index == _selectedAchievement,
          ),
          onPressed: (index) => setState(() => _selectedAchievement = index),
          borderRadius: tokens.cornerLarge(),
          selectedColor: Colors.white,
          color: tokens.textPrimary,
          fillColor: tokens.brandPrimary,
          splashColor: tokens.brandPrimary.withAlpha((255 * 0.2).round()),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
              child: const Text('✔ 達成'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
              child: const Text('△ 部分'),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.spacing.lg),
              child: const Text('✘ 未達'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStreakProgress(MinqTheme tokens) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '連続記録',
              style: tokens.typography.bodySmall.copyWith(color: tokens.textMuted),
            ),
            Text(
              '🔥 7 日目',
              style: tokens.typography.bodySmall.copyWith(
                color: tokens.textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.sm),
        LinearProgressIndicator(
          value: 0.7,
          backgroundColor: tokens.border,
          valueColor: AlwaysStoppedAnimation<Color>(tokens.brandPrimary),
          minHeight: 8,
          borderRadius: tokens.cornerLarge(),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, MinqTheme tokens) {
    return Padding(
      padding: EdgeInsets.all(tokens.spacing.lg),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.send),
        label: const Text('共有する'),
        onPressed: _shareProgress,
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.brandPrimary,
          foregroundColor: tokens.surface,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
          textStyle: tokens.typography.h5,
        ),
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({
    required this.tokens,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final MinqTheme tokens;
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, color: tokens.brandPrimary),
      label: Text(label, style: TextStyle(color: tokens.textPrimary)),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: tokens.spacing.xl),
        side: BorderSide(
          color: tokens.border,
          width: 2,
          style: BorderStyle.solid,
        ),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      ),
    );
  }
}
