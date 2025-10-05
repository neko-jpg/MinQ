# Plan

## Scope
- Add a dedicated profile navigation tile on the settings screen that routes via `NavigationUseCase.goToProfile()` (task.md C.1).
- Implement the data export button so it gathers quests/logs/statistics, asks `DataExportService` to bundle them into a zip, and opens the share sheet with success/error toasts (task.md C.2).
- Refresh the quest edit icon selector to present distinguishable silhouettes with clear selected states using design tokens (task.md B.2 "編集画面のアイコン改善").
- Update the crash recovery screen to stack actions with a FilledButton primary action for restore and an OutlinedButton secondary action (task.md D.1 "復元画面のコントラスト").
- Hide the crash recovery technical report behind a disclosure control so details are collapsed by default (task.md D.1 "技術メッセージの非表示").

## Steps
1. Extend the settings screen state to read the navigation use case and wire the profile tile tap handler through it; ensure design tokens remain consistent.
2. Provide a `DataExportService` via `data/providers.dart`, add a helper on the service to build a zip archive containing JSON/CSV snapshots, and implement the settings export tap handler to fetch repository data, call the service, share the file, and emit toasts while handling loading UI.
3. Rebuild the quest icon selector using `questIconCatalog`, adding semantic labels, wrap spacing, and selected styling that relies on tokens for color/shape emphasis.
4. Convert the crash recovery screen into a stateful widget to toggle detail visibility, switch buttons to `FilledButton`/`OutlinedButton`, and add a disclosure control that animates the technical report container.
5. Cover code paths with unit/widget tests where feasible or rely on existing coverage, then execute formatting, analysis, and `flutter test --coverage` to satisfy CI expectations.

## Testing
- `dart format --set-exit-if-changed lib/presentation/screens/settings_screen.dart lib/presentation/screens/crash_recovery_screen.dart lib/presentation/screens/edit_quest_screen.dart lib/core/export/data_export_service.dart`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
