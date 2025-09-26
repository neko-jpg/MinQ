# Release Playbook

This document satisfies the checklist item "リリース手順書" by detailing the end-to-end mobile release workflow for MinQ.

## Branch Strategy

* `main` – Always releasable. Contains code that passed automated checks and product QA.
* `release/*` – Created when entering release freeze (e.g. `release/1.1.0`). Only bug fixes and release tasks allowed.
* `feature/*` – Squashed into `main` via pull requests with review + CI.

## Release Timeline (Example 1-week cadence)

| Day | Activity |
| --- | --- |
| Mon | Cut release branch, bump version (see `docs/versioning.md`), run smoke tests |
| Tue | QA regression + exploratory testing on iOS/Android matrix |
| Wed | Fix bugs, rerun automated suites |
| Thu | Submit builds to TestFlight/Internal Testing, collect feedback |
| Fri | Publish to production (staged rollout), monitor metrics |

## Checklists

1. **Pre-freeze**
   - [ ] Version updated in `pubspec.yaml`
   - [ ] CHANGELOG entry drafted (`CHANGELOG.md`)
   - [ ] Remote Config template reviewed (`docs/remote_config_strategy.md`)
   - [ ] Crash-free rate ≥99.5% on the candidate build

2. **Release Candidate**
   - [ ] QA sign-off recorded in Jira ticket
   - [ ] Store listing copy verified (`docs/store_descriptions.md`)
   - [ ] Support team briefed on new changes (shared summary + runbook updates)
   - [ ] Build artifacts archived in secure storage (`drive://MinQ/Releases`)

3. **Post-release**
   - [ ] Create tag `vX.Y.Z` and push to origin
   - [ ] Update release metrics in dashboard (`docs/kpi_dashboard.md`)
   - [ ] Start staged rollout (10% → 50% → 100%) with monitoring gates
   - [ ] Post-mortem if any Sev1/Sev2 incidents occurred (see `docs/incident_runbook.md`)

## Tooling & Automation

* CI/CD – GitHub Actions runs `flutter test`, lint, and build jobs on pull requests and the release branch.
* Distribution – Codemagic uploads signed builds to TestFlight and Google Play Internal Testing.
* Monitoring – Firebase Crashlytics + App Distribution for release candidates. Production monitoring described in
  `docs/monitoring_plan.md`.

## Rollback Procedure

1. Pause rollout in Play Console/App Store Connect.
2. Toggle feature flag / Remote Config to disable risky features.
3. Cherry-pick fix into release branch and rebuild OR revert to previous stable tag.
4. Communicate status in `#minq-release` Slack channel and update incident timeline.

## Contact Matrix

| Role | Person | Backup |
| --- | --- | --- |
| Release owner | Aya | Ken |
| iOS engineer | Satoshi | Erika |
| Android engineer | Ken | Mei |
| QA lead | Rina | Sho |
| Support liaison | Mika | Tak |
