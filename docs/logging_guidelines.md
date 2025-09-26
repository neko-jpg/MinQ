# MinQ Logging Guidelines

This document defines how the team should emit logs across Flutter, backend services, and analytics to satisfy the P0 checklist requirement.

## Principles

1. **Protect user privacy** – never log PII (names, email addresses, phone numbers), authentication tokens, or raw photo URLs.
2. **Actionable context** – every log should answer who/what/when. Include anonymised identifiers (e.g. `userId` hash) and correlation IDs.
3. **Consistency** – follow the same structure across `info`, `warn`, and `error` levels to simplify querying.

## Log levels

| Level | When to use | Required fields |
| --- | --- | --- |
| `log.info` | Expected flow milestones (quest started, notification scheduled). | `event`, `userHash`, `timestamp`, optional `metadata`. |
| `log.warn` | Recoverable issues (API retries, feature flag fallback). | `event`, `userHash`, `timestamp`, `reason`, `retryCount`. |
| `log.error` | Unexpected crashes, data corruption, security violations. | `event`, `userHash`, `timestamp`, `error`, `stackTrace`, `severityTag`. |

## Implementation details

- Wrap logging inside `lib/data/services/logging_service.dart` (to be introduced soon) to centralise formatting.
- Use `jsonEncode` for the metadata map so logs remain parseable in Cloud Logging.
- On Flutter, prefer `log` from `dart:developer` with a `name` equal to the feature module (`home`, `record`, `pair`).
- On the backend (Cloud Functions, admin tools), mirror the same structure so dashboards can be shared.

## PII guardrails

- Never log:
  - Raw quest descriptions entered by the user.
  - Pair chat messages or media URLs.
  - Push tokens, Firebase installation IDs, or storage bucket paths.
- When referencing users, hash the UID with SHA-256 and truncate to 8 characters (`userHash`).
- Camera/photo failures should reference `errorCode` enums only, not file paths.

## Sampling & retention

- Info logs should be sampled at 50% to control costs. Warning/error logs are always kept.
- Retain logs for 30 days in production; delete nightly in staging environments.

## Alerting

- Integrate with Sentry/Crashlytics for automatic escalation on `log.error` with `severityTag = 'critical'`.
- Set up Cloud Logging alerts for:
  - 5 consecutive `remote_config_fetch_failed` warnings.
  - Error rate >3 per minute for any feature module.

## Process

- During code review, verify new logs follow this schema and that metadata keys are documented.
- Keep this document updated whenever a new field or retention policy changes.
