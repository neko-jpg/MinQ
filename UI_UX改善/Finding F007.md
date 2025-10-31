Finding F007 — AIコーチのプロンプトが静的

Severity: P2

Area: AI

Files: lib/core/ai/ai_coach_controller.dart:L32–L73

Symptom (現象): AICoachControllerの_coachSystemPromptは固定文言であり、ユーザーのストリークや最近完了したクエスト、興味タグを反映しないため、AIコーチのアドバイスが画一的になっている。ダイナミックなQuick Actionも無い。

Likely Root Cause (推定原因): MVP段階でシンプルなプロンプトを実装し、TFLiteサービス側の機能を活用する前にリリースされた。ユーザーの状態を参照するための依存注入が設計されていない。

Concrete Fix (修正案):

AICoachControllerにUserProgressやユーザー設定を読み取るプロバイダーを注入する。

_coachSystemPromptでストリーク日数・最近達成したクエスト名・ユーザータグを自然な文章に組み込み、AIモデルに渡す。

応答に含めるQuick Action候補（例:「今日のクエストを表示」「新しいクエストを作成」）を生成し、UIに表示する。

ファーストバックアップとしてストリークが無い場合は励まし、長いストリーク時は祝福するなどルールベースのフォールバックを強化する。

Tests (テスト): ユニットテストAICoachController_system_prompt_includes_streakで、指定したユーザープログレスを渡した際にプロンプトにストリークやタグが含まれることを検証する。ウィジェットテストでQuick Actionが表示されることも確認する。

Impact/Effort/Confidence: I=4, E=3 days, C=4

Patch (≤30 lines, unified diff if possible):

例示として、システムプロンプト組み立て処理を以下のように書き換えることが考えられます。

String _buildSystemPrompt(UserProgress progress, List<String> tags) {
  final streakMsg = progress.currentStreak > 0
      ? 'あなたの現在のストリークは${progress.currentStreak}日です。'
      : 'まだストリークは始まっていません。';
  final tagMsg = tags.isNotEmpty
      ? 'あなたの関心分野は${tags.join('、')}です。'
      : '';
  return 'あなたはユーザーの習慣化を支援するAIコーチです。$streakMsg$tagMsg'
      'ポジティブで具体的なアドバイスを提供してください。';
}