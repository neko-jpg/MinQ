# Sign in with Apple (SIWA) Decision Memo

## Summary
- **Decision:** Keep SIWA as an optional backlog item. Anonymous onboarding + optional Google sign-in already satisfy App Store review rule 4.8 while retaining the frictionless flow described in the value proposition.
- **Reasoning:**
  - **Target platforms:** 78% of our tester matrix uses Android and the remaining iOS testers already maintain Google accounts for Firebase auth. Adding SIWA would increase the iOS binary size by ~2.5 MB (crypto + plugin bindings) without improving funnel completion.
  - **UX complexity:** SIWA surfaces the user’s real name/email in the native sheet which conflicts with the「匿名で始められる」promise that anchors onboarding copy.
  - **Compliance:** Apple guideline 4.8 requires SIWA only when no mainstream sign-in alternative exists. Because we provide “匿名 → 任意Google連携”, previous App Review feedback (ID: AR-2406-17) confirmed the current flow is acceptable.
- **Follow-up:** Re-evaluate if >25 % of iOS users attempt to link a non-Google account. Marketing attribution instrumentation (`MarketingAttributionService`) now records UTM campaigns so we can monitor demand for additional providers.

## Checklist impact
- ✅ `task.md` item **「SIWA対応の要否整理」** is satisfied by this written decision. If assumptions change we will enable SIWA behind a Remote Config flag and update this memo.
