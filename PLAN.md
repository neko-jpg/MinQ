# Plan

## Scope
- Deliver the multi-reminder UX required by `task.md` E.3 by allowing quests to manage several notification times with add/remove/toggle controls.
- Synchronise the reminder configuration with Firestore via `MultipleReminderService` so saves persist and schedule logic stays centralised.

## Steps
1. Enhance `MultipleReminderService` to operate with Flutter `TimeOfDay`, add a provider, and implement a `saveReminders` API that diffs Firestore documents while (re)scheduling or cancelling notifications safely.
2. Load quest reminders inside `EditQuestScreen`, expose UI affordances to add/delete/toggle/edit times, and ensure unsaved-change detection reflects reminder mutations.
3. Persist reminder changes on save by calling the new service API, provide user feedback on failure, and mark `task.md` after verification.
4. Execute the repository's verification pipeline: `flutter pub get`, `dart format --set-exit-if-changed .`, `dart analyze --fatal-infos`, and `flutter test --coverage`.

## Testing
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
