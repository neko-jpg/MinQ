import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/presentation/common/feedback/feedback_manager.dart';
import 'package:minq/presentation/common/feedback/feedback_messenger.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:minq/data/providers.dart';

class AccountDeletionScreen extends ConsumerStatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  ConsumerState<AccountDeletionScreen> createState() =>
      _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends ConsumerState<AccountDeletionScreen> {
  bool _isConfirmed = false;
  bool _isDeleting = false;

  void _handleDelete() async {
    if (!_isConfirmed) return;

    setState(() => _isDeleting = true);

    // TODO: Implement actual account deletion logic in a repository/usecase
    // e.g., await ref.read(userActionsUseCaseProvider).deleteAccount();
    await Future.delayed(const Duration(seconds: 2)); // Simulate network call

    if (mounted) {
      // Navigate to a logged-out state, e.g., the login screen
      // ref.read(navigationUseCaseProvider).goToLogin();
      FeedbackMessenger.showSuccessToast(
        context,
        'アカウント削除処理を開始しました。',
      );
    }

    // In a real app, you would navigate away. For now, just pop.
    if (mounted) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }
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
                        '安全のため、ボタンを長押しして確定してください。',
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