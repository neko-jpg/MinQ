# Plan

## Scope
- Close the remaining items in `task.md` by addressing outstanding navigation polish and ensuring documentation reflects the completed state.
- Implement the missing Welcome screen behavior so its primary and secondary CTAs route through the shared navigation use case and provide an explicit back affordance.
- Update `task.md` checkboxes once functionality is in place to clearly communicate completion.

## Steps
1. Review `task.md` to confirm which checklist entries remain unchecked and identify the code areas involved (notably the Welcome screen navigation flow).
2. Refactor `lib/presentation/welcome/welcome_screen.dart` to consume `navigationUseCaseProvider`, wire the buttons to the onboarding/login routes, and surface an always-available back button that safely falls back when the navigator stack cannot pop.
3. Exercise the updated screen locally (including the fallback back-button path) and update `task.md` to mark the covered tasks as completed.
4. Run the formatting, static analysis, and test commands required by the repository guidelines.

## Testing
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
