# Plan

## Scope
- Replace all hard-coded color literals with the design token palette so light/dark themes inherit from a single source of truth.
- Align role-based color usage (primary, surface, border, etc.) with the definitions in `color.md` across shared components and themes.
- Implement light and dark theme configurations that respect token-specific behaviors such as shadows vs. borders while keeping existing UI stable.
- Ensure the published color definitions in `color.md` remain the canonical documentation by syncing any new tokens or theme notes there if needed.

## Steps
1. Audit the design system layer (`lib/core`, `lib/config`, and shared widgets) to locate color token definitions and plan any missing abstractions (e.g., `AppColorScheme`, semantic tokens) needed for the migration.
2. Implement or extend the color token source (likely under `lib/core/theme` or similar) to expose the palette from `color.md`, including role mapping for both light and dark modes; update ThemeData builders to consume these tokens and express differences like light shadows vs. dark outlines.
3. Refactor UI components and styles to remove inline color literals, replacing them with the new semantic tokens or theme lookups so all primary/surface/border usage matches the documented roles.
4. Verify the entire app builds under both themes by running the required formatting, analysis, and test commands; document any unavoidable gaps in `NEXT_TASKS.md`.

## Testing
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `dart analyze --fatal-infos`
- `flutter test --coverage`
