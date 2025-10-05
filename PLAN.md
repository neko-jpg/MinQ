# Plan

## Scope
- Implement bottom padding adjustment on the home screen list to avoid overlap with the bottom navigation bar.
- Update the "今日のフォーカス" action to open the record screen for the focused quest instead of the quest list.

## Steps
1. Inspect the existing home screen layout to identify how the SafeArea and ListView padding are applied.
2. Update the ListView padding calculation to include design token spacing, the current SafeArea inset, and `kBottomNavigationBarHeight` so the bottom of the list remains visible above navigation.
3. Ensure SafeArea configuration remains correct (top protected, bottom handled by custom padding) and refactor as needed for clarity.
4. Modify the "もっと見る" button inside the focus hero card to navigate directly to the record screen for the focused quest; handle the empty-state gracefully.
5. Run formatting (`dart format`), static analysis (`dart analyze --fatal-infos`), and automated tests (`flutter test --coverage`) to verify no regressions.

## Testing
- `dart format --set-exit-if-changed lib/presentation/screens/home_screen.dart`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
