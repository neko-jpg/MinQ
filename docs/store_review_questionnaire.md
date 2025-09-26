# Store Review Questionnaire Readiness

This document consolidates all answers required for Google Play’s Data Safety form and the App Store’s Privacy Nutrition/Review questionnaires.

## Data collection summary
- **Personal data:** anonymous UID, hashed email (optional), quest activity timestamps, optional photos (sanitised + EXIF stripped).
- **Location:** not collected. Timezone is derived locally via `timezone` package.
- **Financial data:** none. Monetisation experiments use Stripe-hosted checkout links without processing data in-app.
- **Usage data:** onboarding completion, quest events, notification opens (see `docs/analytics_events.md`).

## Data handling
- All network traffic via HTTPS/TLS 1.2+ (see `docs/security_tls_policy.md`).
- Photos stored locally in `/proof_photos/<uid>` and uploaded to Firebase Storage with hashed filenames.
- Users can request export or deletion from Settings → Privacy.

## Children & age rating
- Minimum age 13+. No content targeted at children; in-app copy and policy documents reflect this.

## Safety/Reporting
- In-app reporting available from every pair screen. SOP documented in `docs/anti_abuse_plan.md` and `docs/pair_guidelines.md`.

## Checklist impact
- ✅ `task.md` item **「ストア審査質問票（データ安全/年齢/コンテンツ）」** is covered; responses are ready to paste into both stores without contradictions.
