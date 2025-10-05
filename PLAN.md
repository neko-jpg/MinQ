# Plan

## Scope
- Improve home screen progress cards responsiveness by switching between single-column and two-column layouts with consistent card sizing per `task.md` A.1.
- Normalize spacing within the home screen sections to align with established design tokens (e.g. 8/12/16dp increments) as requested in `task.md` A.1.
- Ensure terms of service and privacy policy links open bundled Markdown content through the policy viewer so they remain available offline (`task.md` C.2).
- Update the onboarding/login flow so transitions use push navigation and provide a visible back affordance on the welcome (onboarding) screen (`task.md` D.1).
- Align primary buttons with design tokens instead of hardcoded black styles, covering the onboarding call-to-action (`task.md` B.2 "真っ黒ボタンの廃止").

## Steps
1. Refactor the home highlights widget to use a `LayoutBuilder` that yields a `GridView`-like two-column arrangement when wide and a single full-width column otherwise, ensuring card widths and heights remain consistent.
2. Audit the home screen paddings and gaps, replacing ad-hoc `SizedBox` heights with `tokens.spacing` values that correspond to standard 8/12/16dp increments, and adjust card padding accordingly.
3. Extend the policy document model with optional asset metadata, add Markdown support, and load `assets/legal/*.md` within `PolicyViewerScreen`; register the asset folder and dependency updates in `pubspec.yaml`.
4. Modify the onboarding screen scaffold to include an `AppBar` with a conditional `BackButton`, switch the CTA buttons to brand-aligned `FilledButton` styles, and invoke push navigation to reach the login screen; expose push navigation via `NavigationUseCase.goToLogin()`.
5. Ensure the login screen reacts to push navigation by showing a top AppBar with a back button when possible, keeping CTA styling consistent with tokens.
6. Run formatting, static analysis, and the full Flutter test suite to satisfy the CI gate.

## Testing
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
