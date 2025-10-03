import 'package:flutter/material.dart';

/// Centralized helper for showing user feedback messages with
/// consistent durations and styles across the app.
class FeedbackMessenger {
  FeedbackMessenger._();

  /// Shows a short floating toast-style message for successful actions.
  static void showSuccessToast(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      duration: const Duration(milliseconds: 1500),
    );
  }

  /// Shows an informational toast (used for hints or neutral guidance).
  static void showInfoToast(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      duration: const Duration(milliseconds: 1500),
    );
  }

  /// Shows an error toast message.
  static void showErrorToast(BuildContext context, String message) {
    _showSnackBar(
      context,
      message,
      duration: const Duration(seconds: 2),
    );
  }

  /// Shows an error snackbar with an action button.
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    String actionLabel = '閉じる',
    VoidCallback? onAction,
  }) {
    _showSnackBar(
      context,
      message,
      duration: const Duration(seconds: 3),
      actionLabel: actionLabel,
      onAction: onAction ?? () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
    );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                onPressed: onAction ?? () {},
              ),
      ),
    );
  }
}
