Finding F009 — 戻る操作で未保存データが失われる

Severity: P2

Area: Navigation

Files: 複数のフォーム画面（例: edit_quest_screen.dart, create_quest_screen.dart）

Symptom (現象): Android端末でバックボタンを押すと、未保存の入力内容がある編集画面から確認なく前の画面へ戻ってしまい、ユーザーが意図せずデータを失ってしまう。GoRouterのルート定義にRootBackButtonDispatcherが存在せず、WillPopScopeによる制御が行われていない。

Likely Root Cause (推定原因): Flutter標準の戻る挙動を採用しており、フォーム画面に対する特別な処理が追加されていない。オフラインファースト・データロスト防止の要件が設計に反映されていない。

Concrete Fix (修正案):

アプリのエントリーポイントでRootBackButtonDispatcherを用意し、カスタムバックハンドラを登録する。

編集画面やフォーム画面ではWillPopScopeを配置し、入力に変更がある場合は確認ダイアログを表示する。ユーザーが「破棄」を選んだ時のみ画面を閉じ、キャンセルした場合はそのまま留まる。

GoRouterの設定でバック操作の伝搬を適切に処理し、タブ間遷移と詳細画面遷移の一貫性を保つ。

Tests (テスト): ウィジェットテストUnsavedForm_displays_confirmation_on_backで、未保存データがある状態で戻るボタンを押すと確認ダイアログが表示されることを確認する。ダイアログの「破棄」と「キャンセル」ボタンで挙動が分岐することを検証する。

Impact/Effort/Confidence: I=3, E=2 days, C=4

Patch (≤30 lines, unified diff if possible):

例示として編集画面でのWillPopScope利用方法を示します。

return WillPopScope(
  onWillPop: () async {
    if (_formKey.currentState?.dirty ?? false) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('変更を破棄しますか？'),
          content: const Text('保存せずに戻ると変更が失われます。'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('キャンセル')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('破棄')),    
          ],
        ),
      );
      return discard ?? false;
    }
    return true;
  },
  child: ...,
);