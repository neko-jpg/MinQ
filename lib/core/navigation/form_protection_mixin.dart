import 'package:flutter/material.dart';
import 'package:minq/presentation/theme/minq_theme.dart';

/// フォーム保護ミックスイン
/// F009対応: 未保存データがある場合の確認ダイアログを提供
mixin FormProtectionMixin<T extends StatefulWidget> on State<T> {
  
  /// 未保存の変更があるかどうかを判定する
  /// サブクラスで実装する必要がある
  bool get hasUnsavedChanges;
  
  /// 変更破棄の確認ダイアログを表示
  Future<bool> showDiscardChangesDialog() async {
    if (!hasUnsavedChanges) {
      return true;
    }

    final tokens = context.tokens;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('変更を破棄しますか？'),
          content: const Text('保存せずに戻ると変更が失われます。'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.accentError,
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
  
  /// PopScopeで使用するためのコールバック
  Future<void> onPopInvokedWithResult(bool didPop, dynamic result) async {
    if (didPop) {
      return;
    }
    
    final shouldPop = await showDiscardChangesDialog();
    if (mounted && shouldPop) {
      Navigator.of(context).pop();
    }
  }
  
  /// WillPopScopeで使用するためのコールバック（レガシー対応）
  Future<bool> onWillPop() async {
    return await showDiscardChangesDialog();
  }
  
  /// フォーム保護付きのScaffoldを構築
  Widget buildProtectedScaffold({
    required Widget body,
    PreferredSizeWidget? appBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    Widget? bottomNavigationBar,
    Widget? drawer,
    Widget? endDrawer,
    Color? backgroundColor,
  }) {
    return PopScope(
      canPop: !hasUnsavedChanges,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
        bottomNavigationBar: bottomNavigationBar,
        drawer: drawer,
        endDrawer: endDrawer,
        backgroundColor: backgroundColor,
      ),
    );
  }
}