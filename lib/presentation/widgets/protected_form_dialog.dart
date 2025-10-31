import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';
import 'package:minq/presentation/theme/theme_extensions.dart';

/// フォーム保護付きダイアログ
/// F009対応: ダイアログ内のフォームでも未保存データ保護を提供
class ProtectedFormDialog extends StatefulWidget {
  const ProtectedFormDialog({
    super.key,
    required this.title,
    required this.child,
    required this.onSave,
    this.onCancel,
    this.hasUnsavedChanges = false,
  });

  final String title;
  final Widget child;
  final VoidCallback onSave;
  final VoidCallback? onCancel;
  final bool hasUnsavedChanges;

  @override
  State<ProtectedFormDialog> createState() => _ProtectedFormDialogState();
}

class _ProtectedFormDialogState extends State<ProtectedFormDialog> {
  
  Future<bool> _showDiscardChangesDialog() async {
    if (!widget.hasUnsavedChanges) {
      return true;
    }

    final tokens = context.tokens;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('変更を破棄しますか？'),
          content: const Text('保存せずに閉じると変更が失われます。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('破棄する'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _handleCancel() async {
    final shouldClose = await _showDiscardChangesDialog();
    if (shouldClose && mounted) {
      if (widget.onCancel != null) {
        widget.onCancel!();
      } else {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    
    return PopScope(
      canPop: !widget.hasUnsavedChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) {
          return;
        }
        
        final shouldPop = await _showDiscardChangesDialog();
        if (mounted && shouldPop) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        title: Text(widget.title),
        content: widget.child,
        actions: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: tokens.brandPrimary,
              foregroundColor: Colors.white,
            ),
            onPressed: widget.onSave,
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}