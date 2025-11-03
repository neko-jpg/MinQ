import 'package:flutter/material.dart';
import 'package:minq/l10n/app_localizations.dart';
import 'package:minq/presentation/theme/design_tokens.dart';
import 'package:minq/presentation/theme/semantic_color_scheme.dart';
import 'package:minq/presentation/theme/elevation_system.dart';
import 'package:minq/presentation/theme/spacing_system.dart';

/// 標準ダイアログ - 統一されたダイアログコンポーネント
class StandardDialog extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final String? message;
  final Widget? content;
  final List<DialogAction> actions;
  final bool dismissible;
  final Widget? icon;
  final DialogType type;

  const StandardDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.message,
    this.content,
    this.actions = const [],
    this.dismissible = true,
    this.icon,
    this.type = DialogType.normal,
  });

  /// 確認ダイアログ
  static Future<bool?> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    bool destructive = false,
  }) {
    final l10n = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder:
          (context) => StandardDialog(
            title: title,
            message: message,
            type: destructive ? DialogType.destructive : DialogType.normal,
            actions: [
              DialogAction(
                label: cancelText ?? l10n.cancel,
                onPressed: () => Navigator.of(context).pop(false),
                isCancel: true,
              ),
              DialogAction(
                label: confirmText,
                onPressed: () => Navigator.of(context).pop(true),
                isPrimary: true,
                isDestructive: destructive,
              ),
            ],
          ),
    );
  }

  /// アラートダイアログ
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    DialogType type = DialogType.normal,
  }) {
    return showDialog(
      context: context,
      builder:
          (context) => StandardDialog(
            title: title,
            message: message,
            type: type,
            actions: [
              DialogAction(
                label: buttonText,
                onPressed: () => Navigator.of(context).pop(),
                isPrimary: true,
              ),
            ],
          ),
    );
  }

  /// エラーダイアログ
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showAlert(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: DialogType.error,
    );
  }

  /// 成功ダイアログ
  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return showAlert(
      context: context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: DialogType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderSystem.dialogRadius,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // アイコン
            if (icon != null || type != DialogType.normal) ...[
              Center(child: _buildIcon(context)),
              SpacingSystem.vSpaceMD,
            ],

            // タイトル
            if (title != null || titleWidget != null) ...[
              titleWidget ??
                  Text(
                    title!,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
              SpacingSystem.vSpaceMD,
            ],

            // メッセージまたはコンテンツ
            if (message != null)
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              )
            else if (content != null)
              content!,

            // アクション
            if (actions.isNotEmpty) ...[
              SpacingSystem.vSpaceXL,
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (icon != null) return icon!;

    final colors = context.tokens.colors;
    final semanticColors = Theme.of(context).extension<SemanticColorScheme>()!;
    IconData iconData;
    Color iconColor;

    switch (type) {
      case DialogType.success:
        iconData = Icons.check_circle;
        iconColor = semanticColors.success ?? colors.primary;
        break;
      case DialogType.error:
        iconData = Icons.error;
        iconColor = colors.error;
        break;
      case DialogType.warning:
        iconData = Icons.warning;
        iconColor = semanticColors.warning ?? colors.primary;
        break;
      case DialogType.destructive:
        iconData = Icons.warning;
        iconColor = colors.error;
        break;
      case DialogType.normal:
        return const SizedBox.shrink();
    }

    return Icon(iconData, size: 48, color: iconColor);
  }

  Widget _buildActions(BuildContext context) {
    if (actions.length == 1) {
      return _buildActionButton(context, actions.first);
    }

    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(child: _buildActionButton(context, actions[0])),
          SpacingSystem.hSpaceSM,
          Expanded(child: _buildActionButton(context, actions[1])),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children:
          actions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildActionButton(context, action),
            );
          }).toList(),
    );
  }

  Widget _buildActionButton(BuildContext context, DialogAction action) {
    if (action.isPrimary) {
      final colors = context.tokens.colors;
      return ElevatedButton(
        onPressed: action.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: action.isDestructive ? colors.error : colors.primary,
          foregroundColor:
              action.isDestructive ? colors.onError : colors.onPrimary,
        ),
        child: Text(action.label),
      );
    }

    if (action.isCancel) {
      return OutlinedButton(
        onPressed: action.onPressed,
        child: Text(action.label),
      );
    }

    return TextButton(onPressed: action.onPressed, child: Text(action.label));
  }
}

/// ダイアログアクション
class DialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isCancel;
  final bool isDestructive;

  const DialogAction({
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isCancel = false,
    this.isDestructive = false,
  });
}

/// ダイアログタイプ
enum DialogType { normal, success, error, warning, destructive }

/// BuildContext拡張
extension DialogExtension on BuildContext {
  /// 確認ダイアログを表示
  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    bool destructive = false,
  }) {
    return StandardDialog.showConfirm(
      context: this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      destructive: destructive,
    );
  }

  /// アラートダイアログを表示
  Future<void> showAlertDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return StandardDialog.showAlert(
      context: this,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// エラーダイアログを表示
  Future<void> showErrorDialog({
    required String title,
    required String message,
  }) {
    return StandardDialog.showError(
      context: this,
      title: title,
      message: message,
    );
  }

  /// 成功ダイアログを表示
  Future<void> showSuccessDialog({
    required String title,
    required String message,
  }) {
    return StandardDialog.showSuccess(
      context: this,
      title: title,
      message: message,
    );
  }
}
