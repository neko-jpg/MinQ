# Versioning & Build Number Policy

MinQ follows [Semantic Versioning](https://semver.org) for the marketing version (`MAJOR.MINOR.PATCH`) and a monotonically
increasing build number for each platform release. This document defines how the team plans, increments, and documents
versions so that the "バージョニング" task in the release checklist can be considered complete.

## Semantic Versioning Rules

| Version segment | Triggering change examples | Responsibility |
| --- | --- | --- |
| **MAJOR** | Breaking information architecture changes, migration that requires user re-onboarding, protocol incompatibility | Product + Engineering approval in release review |
| **MINOR** | New habit-tracking features, additional notification options, UI refreshes that maintain backwards compatibility | Feature team that owns the initiative |
| **PATCH** | Bug fixes, performance tuning, copy adjustments, dependency updates without user-visible change | Duty engineer for the sprint |

* Android `versionName` and iOS `CFBundleShortVersionString` mirror the semantic version string.
* Build numbers (`versionCode` on Android, `CFBundleVersion` on iOS) increment for **every** internal build, following the
  `YYDDDnn` pattern (year + day-of-year + daily counter). Example: `24183 02` → second build on 2024 day 183.

## Release Planning Workflow

1. **Kick-off** – During sprint planning, any feature targeting release must state the intended semantic version bump.
2. **Pre-freeze** – 48 hours before the cut, the release owner locks the target version in `pubspec.yaml` and opens a draft
   entry in `CHANGELOG.md`.
3. **Tagging** – After QA sign-off, create a git tag `vMAJOR.MINOR.PATCH` and push platform-specific build numbers to
   Codemagic.
4. **Rollout** – Track staged rollout percentages in the release log (see below). Roll back by reverting the tag and
   toggling the Remote Config flag, not by retagging.

## Changelog Maintenance

* `CHANGELOG.md` resides at the repository root. Each entry contains **Added / Changed / Fixed / Metrics** sections.
* Every merged pull request must update the "Unreleased" section (or create a new version section) to prevent drift.
* The release owner moves the Unreleased notes under the version heading when tagging.

## Roles & Audit Trail

| Role | Responsibility |
| --- | --- |
| Release owner (rotates weekly) | Maintains version numbers, leads the release sync, updates build sheets |
| QA lead | Verifies that the published build number matches Store submission |
| Mobile infra | Archives signed artifacts, ensures CHANGELOG is linked in release notes |

## References

* Release Log Spreadsheet – `drive://MinQ/ReleaseLog` (columns: version, build #, rollout %, status)
* Store metadata – `docs/store_descriptions.md`
* Operational emergency plan – `docs/incident_runbook.md`
