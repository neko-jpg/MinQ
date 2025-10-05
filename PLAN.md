# Plan

## Scope
- Implement search interaction improvements on the quests screen: update the search field to drive state, filter quests by title or derived tags with debouncing, and render a helpful fallback when no results are found. (task.md B.1 items 1-4)
- Align the "AIおすすめ" heading and error presentation with design guidance so the label always uses the primary text color and error feedback is shown separately in an encouragement tone. (task.md B.2 item 1)

## Steps
1. Audit `QuestsScreen` to understand how quest lists are built per category and identify where to introduce search query state, debouncing, and metadata needed for tag filtering.
2. Add state to track the trimmed, lowercased search query with a 250ms debounce triggered from the search `TextField.onChanged`, and derive lightweight tag collections for quests (title tokens, category keywords) so filtering can match both titles and tags.
3. Update the grid builder to apply the search filter, and when the filtered list is empty, render a dedicated empty state widget that suggests popular keywords and guides users toward AI recommendations.
4. Adjust the AI recommendation section so the heading color is consistently `textPrimary` and refactor the error widget to display the label and a subdued encouragement-colored error message on separate lines with appropriate spacing.
5. Run `dart format`, `dart analyze --fatal-infos`, and `flutter test --coverage` to ensure formatting, static analysis, and automated tests succeed.

## Testing
- `dart format --set-exit-if-changed lib/presentation/screens/quests_screen.dart`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
