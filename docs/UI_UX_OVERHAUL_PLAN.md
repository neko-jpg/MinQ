# MinQ UI/UX Overhaul Plan

## Goals
- Deliver a cohesive, premium visual identity across splash, onboarding, authentication, and in-app surfaces.
- Guarantee predictable navigation (esp. back handling) on mobile and web while keeping the session alive.
- Ship a reliable profile experience with editable fields that persist locally and sync once online.
- Make the core flows resilient offline (MiniQuest creation, quest browsing, recent progress).
- Turn the AI coach from a placeholder into a helpful, context-aware assistant that works without cloud access.
- Remove garbled copy and replace it with polished Japanese/English microcopy suitable for production.

## Current Issues
- **Visual drift**: Splash, onboarding, login, and the main shell use different palettes, typography, and spacing systems. The theme extensions do not enforce consistency.
- **Splash UX**: The current organic animation is fast, busy, and does not guarantee a minimum branding dwell. Users often see a jump cut directly to login or home.
- **Copy regression**: Numerous strings are mojibake due to legacy Shift-JIS data, heavily impacting perceived quality.
- **Profile gap**: `ProfileScreen` renders static mock data; editing routes exist but do not talk to Isar/Supabase. Avatar selection, display name, and tags never persist.
- **Back navigation**: Shell routes mix `go` and `push`, which causes unexpected app exits (Android back) and duplicated screens.
- **Offline blind spots**: Quests, logs, and home view cache locally, but MiniQuest flows, profile data, and onboarding state do not. There is no unified offline snapshot for sync.
- **AI concierge**: The TensorFlow wrapper is wired, yet responses fall back to canned text with no contextual awareness, and there is no quick action hand-off into quests.
- **Light/Dark themes**: Derived from multiple token sets with duplicated logic; colors clip in dark mode and components render with low contrast.

## Guiding Principles
1. **Single design language** built on a refreshed palette (`Midnight Indigo`, `Aurora Violet`, `Horizon Teal`) with matching elevation, typography, and component tokens for light/dark.
2. **Progressive disclosure**: Stage new UI by entry point (Splash → Auth → Onboarding → Home) so QA can validate each layer.
3. **Offline-first data**: Any user-editable surface must read/write to Isar first, then sync asynchronously. UI reflects connectivity via `SyncStatus`.
4. **Deterministic navigation**: Standardize `GoRouter` usage (`go` for shell tabs, `push` for detail flows) and add a scoped back dispatcher to prevent accidental exits.
5. **AI as coach, not gimmick**: Provide structured responses (goal summary, encouragement, next actions) using on-device heuristics and existing quest/log context.

## Workstreams

### 1. Brand System Refresh
- Create `BrandPalette` and `MinqTypographyV2` under `lib/presentation/theme/`.
- Update `buildLightTheme` / `buildDarkTheme` to consume the new tokens.
- Align `MinqTheme` extension values (spacing, shadow, radius) with consistent 4px scale.
- Audit existing components to drop direct `Colors.*` usage in favor of theme lookups.

### 2. Splash Experience
- Replace `OrganicSplashScreen` with a calmer two-phase animation:
  1. **Brand presence (800 ms)**: Fade-in gradient background and wordmark.
  2. **Momentum (900 ms)**: Circle reveal with subtle parallax dots.
- Guarantee minimum display by gating router bootstrap until both animation and initialization future resolve.
- Provide skip fallback for accessibility (double-tap with two fingers).

### 3. Auth & Onboarding Unification
- Rebuild `LoginScreen` and `OnboardingScreen` using shared `AuthScaffold`:
  - Hero illustration, gradient cards, consistent CTAs.
  - Replace mojibake copy with concise Japanese copy plus English subtitle.
- Introduce form states for email login (optional) with proper validation messaging.
- Light/dark parity verified via golden tests.

### 4. Profile Revamp
- Extend `domain/user/user.dart` with:
  - `displayName`, `handle`, `bio`, `avatarSeed`, `focusTags`.
  - Migration path (fallback defaults) handled in `isar_migration_guide.md`.
- Add `ProfileRepository` helpers to read/update profile snapshot with optimistic local writes.
- Refactor `ProfileScreen` to consume real data via `userProfileProvider`.
- Rewrite `ProfileManagementScreen` as `ProfileEditScreen`:
  - Sections: avatar picker (with offline-safe generator), personal info, mission statement, focus tags.
  - Form-level validation and snackbar confirmation.
- Hook navigation buttons (`Edit profile`) to the new screen.

### 5. Navigation & Back Handling
- Add custom `RootBackButtonDispatcher` in `app_router.dart` to intercept Android back.
- For shell tabs, switch to `go` with `state.fullPath` awareness to avoid duplicate stack entries.
- Implement `WillPopScope` on top-level detail screens (quests, AI chat) to prompt before exiting if unsaved changes exist.

### 6. Offline & Sync Enhancements
- Introduce `OfflineSnapshotNotifier` combining quests, logs, and profile into one state.
- Persist MiniQuest drafts and offline creations to Isar; enqueue sync actions via `OfflineModeManager`.
- Surface offline banners/actions in MiniQuest and quest lists (retry, resolve conflicts).
- Expand `localPreferencesService` cache schema to include onboarding completion and latest profile edit timestamp.

### 7. AI Coach Improvements
- Implement deterministic fallback engine:
  - Use quest streak, recent completions, and focus recommendation to craft responses.
  - Provide actionable suggestions and `Quick Actions` (buttons linking to quests, timers).
- Add short delay for typing indicator, haptic feedback on send.
- Update `AiConciergeCard` preview to showcase last insight & next action.
- Write unit tests for recommendation builder and sentiment classification heuristics.

### 8. Copy & Localization Cleanup
- Replace mojibake strings with UTF-8 Japanese copy (with English translation where helpful).
- Centralize strings inside `AppLocalizations` and declare new entries in `.arb` files.
- Add regression test ensuring no mojibake remains (`rg` guard & CI script).

### 9. Testing & QA
- Update golden tests for key screens (splash, login, onboarding, profile, home).
- Add widget tests covering profile edit validation and offline banners.
- Extend integration test to simulate offline MiniQuest creation followed by sync.
- Run `flutter analyze`, `flutter test`, and `flutter format .` before merge.

## Milestones
1. **Foundation (Week 1)**: Theme revamp, splash update, string cleanup scaffolding.
2. **Auth + Onboarding (Week 2)**: New flows live behind feature flags, tests updated.
3. **Profile & Offline (Week 3)**: Editable profile, synced caches, MiniQuest offline queue.
4. **AI Coach (Week 4)**: Conversational improvements, home integration, QA pass.
5. **Polish (Week 5)**: Accessibility audit, performance profiling, documentation updates.

## Risks & Mitigations
- **Isar migration regressions**: Provide default values, add migration test, document fallback behavior.
- **Animation performance**: Use lightweight `ImplicitlyAnimatedWidgets`, profile on low-end Android, add ability to disable animations in settings.
- **Copy synchronization**: Keep `arb` files source-of-truth, run intl generator after updates.
- **Offline sync conflicts**: Introduce per-action status and conflict resolution UI before auto-merging.
- **AI perception**: Ensure offline heuristics feel intentional; log interactions for future tuning.

## Next Steps
1. Implement palette/typography changes and ship new splash (Feature flag: `featureBrandRefresh`).
2. Introduce profile data fields + repository updates, regenerate Isar adapters.
3. Draft AI response heuristics module with unit tests.
4. Replace mojibake copy across top-tier screens while wiring localization.
