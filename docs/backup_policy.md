# MinQ Backup & Data Export Policy

This document satisfies the checklist requirement for a documented backup/export policy.

## Goals

- Ensure users can export or delete their data on demand.
- Provide deterministic server-side backup/restore procedures.
- Meet Apple App Store and Google Play review expectations (data portability and deletion compliance).

## Scope

Applies to data stored in:

- Firebase Authentication (anonymous + optional Google link)
- Cloud Firestore (`users`, `pairs`, `quest_logs`, `pair_reports`)
- Firebase Storage (photo proofs)
- Local Isar database on device

## User-facing flows

1. **Export** – Settings ▸ Privacy ▸ `Request data export`.
   - Triggers a Cloud Function that zips the user's logs, quests, and profile metadata.
   - Response email includes download link valid for 7 days.
2. **Delete** – Settings ▸ Privacy ▸ `Delete my account`.
   - Performs soft delete immediately (revokes authentication, clears local Isar).
   - Hard delete is executed after 7 days unless the user cancels via the email confirmation link.

Both flows will surface status in-app via `AsyncValue` providers.

## Backend backup schedule

- Nightly (02:00 UTC) export of Firestore collections to Google Cloud Storage using `gcloud firestore export`.
- Storage bucket retains 14 days of backups with lifecycle rules.
- Automated Cloud Task verifies export integrity and posts to `#ops-minq` Slack channel.

## Disaster recovery playbook

1. Provision a fresh Firestore database in the same project.
2. Run `gcloud firestore import gs://minq-backups/latest`.
3. Restore Firebase Storage objects from the previous day's bucket snapshot.
4. Re-deploy Cloud Functions after updating the Firestore connection string.

## Compliance considerations

- Export files exclude pair partner identifiers to protect counterpart privacy.
- All backups are encrypted at rest using CMEK (customer-managed encryption keys).
- Access to backup buckets is restricted to the SRE group via IAM.

## Monitoring

- Cloud Monitoring alert if nightly backup duration exceeds 15 minutes.
- PagerDuty incident auto-created for two consecutive backup failures.

## Change management

- Update this document when backup cadence, retention, or export flow copy changes.
- Link PRs affecting backups to the `MINQ-BACKUP` Jira epic.
