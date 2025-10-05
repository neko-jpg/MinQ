import 'package:flutter/material.dart';

Future<bool> showDiscardChangesDialog(
  BuildContext context, {
  String? title,
  String? message,
  String? discardLabel,
  String? stayLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(title ?? '変更を破棄しますか？'),
          content: Text(message ?? '入力中の内容が保存されていません。この画面を離れると破棄されます。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(stayLabel ?? 'キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(discardLabel ?? '破棄する'),
            ),
          ],
        ),
  );
  return result ?? false;
}
