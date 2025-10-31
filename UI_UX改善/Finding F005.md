Finding F005 — プログレッシブヒントの未実装

Severity: P3

Area: Onboarding

Files: lib/presentation/common/onboarding/onboarding_engine.dart:L206–L216

Symptom (現象): OnboardingEngineに定義されている_showFirstQuestHint、_showFirstCompletionHint、_showStreakHintメソッドが空のままで、ユーザーの進捗に応じたヒントが表示されない。結果として初回ユーザーが次に何をすれば良いか分からず離脱リスクが高まる。

Likely Root Cause (推定原因): オンボーディングの詳細仕様が未確定で、実装が後回しになったため。メソッドのシグネチャのみ用意されている状態である。
github.com

Concrete Fix (修正案): 各メソッドでSharedPreferencesに表示済みかどうかを記録しつつ、ScaffoldMessenger.of(context).showSnackBarやカスタムオーバーレイを用いてユーザーにヒントを表示する。たとえば_showFirstQuestHintでは「最初のクエストを作成しましょう！（hintFirstQuest）」、_showFirstCompletionHintでは「初めての完了！継続することでストリークが増えます。（hintFirstCompletion）」、_showStreakHintでは「素晴らしいストリーク！（hintStreak）」と表示する。表示後はmarkTooltipSeen相当のフラグを保存して重複を防ぐ。メソッドにBuildContextを引数として渡せばUI操作が可能。

Tests (テスト): ユニットテストProgressiveHint shows correct messages based on user progressを実装し、UserProgressの状態に応じて正しいヒントが呼び出され、二度目以降は表示されないことを検証する。ウィジェットテストでは実際にSnackBarが表示されることを確認する。

Impact/Effort/Confidence: I=3, E=3 days, C=3

Patch (≤30 lines, unified diff if possible):

未実装のため具体的なパッチは示しませんが、以下のような形でBuildContext contextをパラメータに追加し、ScaffoldMessengerでスナックバーを表示する実装が想定されます：

static Future<void> _showFirstQuestHint(BuildContext context) async {
  if (!context.mounted) return;
  if (await OnboardingEngine.hasSeenTooltip('first_quest_hint')) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(AppLocalizations.of(context)!.hintFirstQuest)),
  );
  await OnboardingEngine.markTooltipSeen('first_quest_hint');
}