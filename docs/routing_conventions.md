# MinQ Routing Conventions

This document codifies how we define and evolve routing inside the MinQ mobile app. It serves as the permanent reference requested in the P0 checklist.

## Router technology

- We use [`go_router`](https://pub.dev/packages/go_router) as the single source of truth for navigation.
- All routes must be declared in `lib/presentation/routing/app_router.dart` with strongly typed path parameters.
- Each route configuration must expose a `name` string constant that matches the URL path without the leading slash. Example: `const homeRouteName = 'home';` for the `/home` path.

## Naming conventions

| Screen | Route name | Path | Notes |
| --- | --- | --- | --- |
| Home | `homeRouteName` | `/home` | Default shell tab. |
| Record | `recordRouteName` | `/record` | Accepts optional `questId` query parameter for deep linking from notifications. |
| Celebration | `celebrationRouteName` | `/celebration` | Requires the most recent quest log to be in memory. |
| Quests | `questsRouteName` | `/quests` | Secondary navigation entry. |
| Pair | `pairRouteName` | `/pair` | Requires authentication guard. |
| Stats | `statsRouteName` | `/stats` | Requires authentication guard. |
| Settings | `settingsRouteName` | `/settings` | Nested inside shell. |
| Onboarding | `onboardingRouteName` | `/onboarding` | Only accessible when `authRepository.isFirstLaunch` is true. |
| Login | `loginRouteName` | `/login` | Fallback route when authentication is required. |

Route names should follow the `<feature>RouteName` pattern. Paths must stay kebab-free to ensure consistent deep link compatibility across Android/iOS.

## Parameters & query strings

- Use typed parameters instead of serializing JSON into strings.
- `GoRoute` definitions must declare expected parameters with `pathParameters`/`queryParameters` constants to avoid typo bugs.
- Non-nullable parameters must be validated before pushing (`assert` with helpful error messages).

## Deep links

- All notification deep links must pass through `notificationTapStreamProvider`.
- When adding a new deep link, document the parameter contract inside this file and add an integration test stub.
- Keep web-compatible URLs (no platform-specific schemes). Deep links should look like `minq://record?questId=abc123` and be mapped to `/record` internally.

## Guarding & redirects

- Authentication is enforced with `redirect` handlers inside `app_router.dart`.
- Feature-flagged screens must check `featureFlagsProvider` before pushing; use fallback screens when disabled.
- Avoid heavy async work inside `redirect`—perform initialization in providers (`appStartupProvider`).

## Testing expectations

- Add a widget test for every new route to ensure it renders without exceptions.
- When adding path parameters, create a regression test for both valid and invalid input to verify redirect logic.

## Change management

- Update this document whenever a new top-level route or guard is introduced.
- Include a link to the relevant product requirement or Jira ticket in the PR description when altering navigation.
