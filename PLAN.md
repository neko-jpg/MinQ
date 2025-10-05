# Plan

## Scope
- Implement distinct UI states on the home screen for loading, error, offline, and empty datasets per `task.md` A.2.
- Remove developer-only identifiers from the Today logs screen in release builds by guarding them with asserts (`task.md` B.2 デバッグ表示の削除).
- Disable or relabel unfinished entries in the profile settings experience so that demo features are presented as "準備中" and are non-interactive (`task.md` C.3).
- Add a safe fallback when closing the record screen so users can always exit even if the navigation stack is compromised (`task.md` E.2 フリーズ対策).
- Refresh the weekly streak visualization to use intuitive dot indicators with a legend/tooltip for clarity (`task.md` E.3).

## Steps
1. Extend `HomeScreen` to watch the sync status and render dedicated empty, error, and offline bodies using `MinqEmptyState`, while retaining the skeleton for loading and showing cached content with optional offline notice.
2. Introduce helper widgets/utilities for the home empty/offline states and provide actionable buttons (e.g., create quest, retry) wired to navigation or controller refresh.
3. Wrap the Today logs debug subtitles in assert-only builders so production builds hide quest IDs.
4. Audit `profile_setting_screen.dart` for placeholder interactions, swap them with disabled tiles or buttons labeled "準備中", and ensure icon actions without implementations are removed.
5. Update the record screen's close button to pop when possible or route to the home tab otherwise.
6. Redesign the weekly streak row to use filled/outlined dots, emphasize the current day, add tooltips, and append a legend explaining the symbols.
7. Run `flutter pub get`, `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos`, and `flutter test --coverage`.

## Testing
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
