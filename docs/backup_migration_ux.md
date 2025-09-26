# Backup & Device Migration UX

## Overview
The Settings screen now exposes a **Cloud backup** switch (persisted via `LocalPreferencesService.isCloudBackupEnabled`) and a “Device Transfer Guide” modal. When enabled the app links the user’s anonymous Firebase UID with Google sign-in on the next launch and schedules nightly encrypted Isar snapshots. During fresh installs the snapshots are rehydrated after authentication.

## User journey
1. **Enable backup** – Users toggle *Data Sync* → *Cloud backup enabled* toast confirms.
2. **Link account** – On the next launch the user is prompted for Google sign-in (already implemented); the toggle ensures we keep the encrypted snapshot.
3. **Restore** – When the user signs in on a new device the snapshot is downloaded and applied before rendering Home. Manual fallback is available via *Export my data*.

## Edge cases
- If storage quota fails, users receive an in-app notification and the toggle auto-disables.
- When users request account deletion the flag is cleared to avoid retaining backups longer than 30 days.

## Checklist impact
- ✅ `task.md` item **「端末バックアップ/機種変更引継ぎUX」** is satisfied through the new toggle, instructional sheet, and persistence layer updates.
