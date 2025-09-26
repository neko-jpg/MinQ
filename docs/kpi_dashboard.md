# KPI Dashboard Specification

This document fulfils the checklist item "KPIダッシュボード" by describing the metrics, data sources, and alerting rules for the
habit-formation analytics dashboard. The dashboard is implemented in Looker Studio pulling from BigQuery daily exports.

## Overview

* **Update cadence**: Daily automatic refresh at 06:00 JST with backfill whenever Firestore export completes.
* **Owner**: Growth Analytics squad. Weekly review in Monday metrics sync.
* **Access**: Shared with product, engineering, and leadership via `analytics@minq.app` group.

## Core KPIs

| Metric | Definition | Dimension breakdown | Target |
| --- | --- | --- | --- |
| D1 / D7 Retention | % of users who return on day 1/day 7 after onboarding | Platform, acquisition channel | ≥45% (D1), ≥30% (D7) |
| Daily Quest Completion Rate | # of completed quest logs / # of active quests | Quest category, time of day | ≥65% |
| Notification Open Rate | # notification taps / # notifications delivered | Template, timezone bucket | ≥20% |
| Crash-Free Users | 1 - (users with crash / total active users) | Platform, app version | ≥99.5% |
| Pair Health Index | Composite of message reciprocity and streak stability | Pair age, match cohort | ≥0.75 |

## Supporting Views

1. **Funnel:** Onboarding → Match Found → First Record → 7-day Retention.
2. **Heatmap:** Quest completion across local time (leveraging `flutter_heatmap_calendar` data export).
3. **Alerts Panel:** Highlight segments falling below thresholds for three consecutive days.

## Data Pipeline

1. Firestore exports to BigQuery via scheduled Cloud Functions (`minq-dwh-firestore-export`).
2. Daily aggregation stored in dataset `analytics_app.daily_metrics` with schema:
   - `event_date` (DATE)
   - `metric_key` (STRING)
   - `value` (FLOAT64)
   - `platform`, `locale`, `timezone_bucket`, `quest_category` (STRING)
3. Crashlytics metrics imported using the `app_measurement.crash_free_users` view.

## Alerting

* Looker Studio threshold alerts email the owner group when KPIs fall below target for 3 consecutive days.
* PagerDuty integration (service: `minq-app-quality`) escalates if Crash-Free <99% for 2 days.
* Weekly digest summarises improvements/regressions shared in Slack `#minq-metrics`.

## Next Steps

* Add cohort retention curves for D14 once anonymised pair churn data is available.
* Integrate Remote Config experiment variants as filters (requires config_mgmt dimension in BigQuery).
