import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
  bool _isConfirmed = false;
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    if (!_isConfirmed) return;

    final confirmed = await _showFinalConfirmation();
    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _isDeleting = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      FeedbackMessenger.showSuccessToast(
        context,
        'アカウント削除処琁E��開始しました、E,
      );
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
  }

  Future<bool> _showFinalConfirmation() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final expected = l10n.accountDeletionConfirmPhrase;
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            final tokens = context.tokens;
            return AlertDialog(
              title: Text(l10n.accountDeletionConfirmDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountDeletionConfirmDialogDescription,
                    style: tokens.bodySmall.copyWith(color: tokens.textMuted, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.accountDeletionConfirmDialogPrompt,
                    style: tokens.bodySmall.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(hintText: expected),
                    autofocus: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final matches = controller.text.trim() == expected;
                    if (!matches) {
                      FeedbackMessenger.showErrorSnackBar(
                        context,
                        '斁E��が一致しません。確認して再�E力してください、E,
                      );
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text(l10n.accountDeletionConfirmButton),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = MinqTheme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accountDeletionTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(flex: 1),
            Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: tokens.accentError,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.accountDeletionTitle,
              textAlign: TextAlign.center,
              style: tokens.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.accountDeletionWarning,
              textAlign: TextAlign.center,
              style: tokens.bodyLarge.copyWith(color: tokens.textMuted),
            ),
            const Spacer(flex: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: _isConfirmed,
                  onChanged: (value) {
                    setState(() {
                      _isConfirmed = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(
                      l10n.accountDeletionConfirmationCheckbox,
                      style: tokens.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isConfirmed && !_isDeleting
                  ? () {
                      FeedbackMessenger.showInfoToast(
                        context,
                        '安�Eのため、�Eタンを長押しして確定してください、E,
                      );
                    }
                  : null,
              onLongPress: _isConfirmed && !_isDeleting
                  ? () {
                      FeedbackManager.warning();
                      _handleDelete();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: tokens.accentError,
                foregroundColor: Colors.white,
                disabledBackgroundColor: tokens.border,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isDeleting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Text('長押しでアカウントを削除する'),
            ),
            const Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}