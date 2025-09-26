# Monitoring & Observability Plan

Fulfils the checklist item "監視: クラッシュ/ANR/パフォーマンス/通知配信の常時監視設定" by outlining instrumentation and alerting
for MinQ mobile apps.

## Monitoring Stack

| Layer | Tool | Notes |
| --- | --- | --- |
| Crash & ANR | Firebase Crashlytics | Real-time alerts on stability; integrates with PagerDuty |
| Performance | Firebase Performance Monitoring | Tracks cold start, network latency, screen render times |
| Notifications | Firebase Cloud Messaging Delivery data + BigQuery export | Monitors send/deliver/open funnel |
| Backend health | Cloud Monitoring (GKE / Cloud Functions) | Latency and error-rate dashboards |
| User feedback | Zendesk + in-app support form | Tagged as `bug`, `perf`, `notif` for trend analysis |

## Key Service Level Indicators (SLIs)

1. **Crash-Free Session Rate** ≥ 99.5%
2. **Cold Start Time** ≤ 2.5s on Pixel 6 / iPhone 12 reference devices
3. **Notification Delivery Success** ≥ 97% within 60 minutes of scheduled time
4. **Background Sync Success** ≥ 98% within 15 minutes of scheduled window

## Alert Thresholds

| Metric | Warning | Critical | Action |
| --- | --- | --- | --- |
| Crash-Free Users | <99.3% (6h window) | <99.0% (1h window) | Investigate release/feature flag, consider rollback |
| Cold Start P95 | >2.3s | >2.5s | Check performance traces, evaluate lazy-loading tactics |
| Notification Delivery | <95% in last hour | <90% in last hour | Inspect FCM logs, throttle campaigns, notify Support |
| Sync Success | <96% in last 4h | <92% in last 1h | Retry queue healthcheck, escalate to backend team |

## Dashboards

* **App Health Overview** – Combines Crashlytics stability, ANR, and cold start metrics.
* **Notification Pipeline** – Delivery vs opens by template and timezone.
* **Pair Engagement** – Weekly summary of high-five rate vs streak breaks.

## Alert Routing

* PagerDuty service `minq-app-quality` handles Sev1/Sev2. Default escalation: Mobile Infra → Backend → Leadership.
* Slack notifications go to `#minq-alerts`. Warnings post to channel; critical alerts page on-call.
* Support receives daily digest summarising incidents affecting users.

## Maintenance

* Review thresholds quarterly with data science + infra.
* Test alert delivery monthly using synthetic alerts.
* Update dashboards after each major feature launch (owner: Analytics squad).

## Related Documents

* Incident response: `docs/incident_runbook.md`
* KPI Dashboard: `docs/kpi_dashboard.md`
* Remote Config strategy: `docs/remote_config_strategy.md`
