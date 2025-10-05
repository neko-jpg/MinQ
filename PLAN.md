# Plan

## Scope
- Implement production-ready AI touchpoints by wiring the support chat bot and AI share banner generator per `task.md` A.2.
- Replace the Home "今日のフォーカス" module with an AI-driven recommendation that analyses past progress as required by `task.md` A.2.
- Enforce the navigation contract so hierarchical flows use push while tab changes and resets use go (`task.md` E.2 遷移規約の徹底).
- Protect data-entry experiences with PopScope confirmation flows to prevent accidental loss (`task.md` E.2 PopScopeの網羅的実装).
- Align the system back button and app bar back affordances for consistent behaviour on every screen (`task.md` E.2 戻るボタンの動作統一).

## Steps
1. Expose the real integrations AIBannerGenerator through `AIShareBannerService` and connect the support screen to `SupportChatService`, including loading/error states and persistence of the conversation.
2. Extend `HomeDataController` to derive an AI focus suggestion using `HabitAiSuggestionService` and render the card accordingly, falling back gracefully when no quests exist.
3. Update `NavigationUseCase` and call sites to adopt push for detail/modals while keeping go for shell tab routing; audit manual `context.push` usages to delegate to the service.
4. Introduce a reusable unsaved-change guard that wraps key editors (record, profile settings, support feedback) in `PopScope` with confirmation dialogs.
5. Ensure app bars opt into `automaticallyImplyLeading` where appropriate and hook back buttons/system pops through shared handlers so both paths trigger the same navigation result.
6. Execute `flutter pub get`, `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos`, and `flutter test --coverage`.

## Testing
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
