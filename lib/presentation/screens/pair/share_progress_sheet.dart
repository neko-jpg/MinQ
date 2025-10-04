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

    final achievementMap = {0: '✁E達�E', 1: '△ 部刁E��戁E, 2: '✁E未達�E'};
    final achievementText = achievementMap[_selectedAchievement] ?? '';

    final message = '【進捗�E有】\nクエスト、E_selectedQuest」を$achievementTextしました�E�E;

    repo.sendMessage(pairId: widget.pairId, senderId: uid, text: message);

    Navigator.of(context).pop();
  }

  void _showMemoDialog() {
    final memoController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('メモを添仁E),
        content: TextField(
          controller: memoController,
          autofocus: true,
          decoration: const InputDecoration(hintText: '今日の頑張りを伝えよう'),
          maxLines: 3,
        ),
        actions: [
          TextButton(child: const Text('キャンセル'), onPressed: () => Navigator.of(dialogCtx).pop()),
          TextButton(
            child: const Text('送信'),
            onPressed: () {
              final repo = ref.read(pairRepositoryProvider);
              final uid = ref.read(uidProvider);
              final memo = memoController.text.trim();
              if (memo.isNotEmpty && repo != null && uid != null) {
                repo.sendMessage(pairId: widget.pairId, senderId: uid, text: memo);
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
        margin: const EdgeInsets.all(16.0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: tokens.surface.withValues(alpha: 0.8),
          borderRadius: tokens.cornerXLarge(),
          border: Border.all(color: tokens.border.withValues(alpha: 0.5)),
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
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('進捗を共朁E, style: tokens.titleLarge.copyWith(color: tokens.textPrimary, fontWeight: FontWeight.bold)),
          IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MinqTheme tokens) {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuestSelector(tokens),
            const SizedBox(height: 24),
            _buildAttachmentButtons(tokens),
            const SizedBox(height: 24),
            _buildAchievementSelector(tokens),
            const SizedBox(height: 24),
            _buildStreakProgress(tokens),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestSelector(MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('クエストを選抁E, style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedQuest,
          items: ['運動', '勉強', '読書'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedQuest = value);
            }
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: tokens.background,
            border: OutlineInputBorder(borderRadius: tokens.cornerLarge(), borderSide: BorderSide(color: tokens.border)),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentButtons(MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('証拠を添仁E, style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _AttachmentButton(tokens: tokens, icon: Icons.photo_camera, label: '写真', onPressed: () { /* TODO */ })),
            const SizedBox(width: 16),
            Expanded(child: _AttachmentButton(tokens: tokens, icon: Icons.edit_note, label: 'メモ', onPressed: _showMemoDialog)),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievementSelector(MinqTheme tokens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('達�E度', style: tokens.bodyMedium.copyWith(color: tokens.textMuted)),
        const SizedBox(height: 8),
        ToggleButtons(
          isSelected: List.generate(3, (index) => index == _selectedAchievement),
          onPressed: (index) => setState(() => _selectedAchievement = index),
          borderRadius: tokens.cornerLarge(),
          selectedColor: Colors.white,
          color: tokens.textPrimary,
          fillColor: tokens.brandPrimary,
          splashColor: tokens.brandPrimary.withValues(alpha: 0.2),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('✁E達�E')),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('△ 部刁E)),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('✁E未遁E)),
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
            Text('連続記録', style: tokens.bodySmall.copyWith(color: tokens.textMuted)),
            Text('🔥 7 日目', style: tokens.bodySmall.copyWith(color: tokens.textMuted, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
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
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.send),
        label: const Text('共有すめE),
        onPressed: _shareProgress,
        style: ElevatedButton.styleFrom(
          backgroundColor: tokens.brandPrimary,
          foregroundColor: tokens.surface,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: tokens.cornerXLarge()),
          textStyle: tokens.titleSmall,
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
        padding: const EdgeInsets.symmetric(vertical: 24),
        side: BorderSide(color: tokens.border, width: 2, style: BorderStyle.solid),
        shape: RoundedRectangleBorder(borderRadius: tokens.cornerLarge()),
      ),
    );
  }
}
