# Play Store Data Safety & App Store Privacy Nutrition Statement

The following matrix captures the disclosures required by Google Play's Data Safety section and Apple's Privacy Nutrition label. Keep this document in sync with store console submissions.

## Data collection overview

| Data type | Collected? | Shared with third parties? | Purpose | Retention |
| --- | --- | --- | --- | --- |
| Email address (optional Google link) | ✅ | ❌ | Account recovery when linking Google. | Until user requests deletion. |
| Anonymous app identifier (Firebase UID) | ✅ | ❌ | Core authentication. | Until account deletion. |
| Usage data (quest completions, streaks) | ✅ | ❌ | App functionality, analytics. | 13 months. |
| Crash logs | ✅ | ✅ (Crashlytics) | Diagnostics. | 90 days. |
| Photos (habit proof) | ✅ | ❌ | Core functionality. | 30 days in Storage, thumbnails cached locally. |
| Precise location | ❌ | ❌ | Not collected. | N/A |
| Contacts | ❌ | ❌ | Not collected. | N/A |

## Data handling commitments

- **Security**: Data encrypted in transit (TLS 1.2+) and at rest (Firestore/Storage-managed encryption, CMEK for backups).
- **Deletion**: Users can delete their account via Settings ▸ Privacy. Requests are fulfilled within 7 days.
- **Data minimisation**: No advertising identifiers or marketing SDKs are included in v1.0.
- **Children**: App intended for users 13+. No specialised handling for children under COPPA/CCPA.

## Required disclosures (Google Play)

- Data is **collected** and **processed** for core functionality and analytics.
- Data is **not shared** with third parties beyond processors (Firebase, Crashlytics, Remote Config).
- Users can request deletion within the app.
- Data is encrypted in transit.

## Required disclosures (App Store)

- **Data linked to the user**: Contact info (email if linked), identifiers, usage data.
- **Data not linked to the user**: Diagnostics (crash logs) aggregated.
- **Tracking**: No tracking across third-party apps/websites.

## Maintenance checklist

- [ ] Update table when adding a new data type or SDK.
- [ ] Review retention windows quarterly with legal.
- [ ] Attach this document to store listing submissions.
