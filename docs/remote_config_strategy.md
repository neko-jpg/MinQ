# Remote Config Strategy

This note satisfies the checklist requirement "Remote Config: 通知時刻の初期値/本数、推奨クエスト配信のAB実験" by defining how MinQ
uses Firebase Remote Config to manage rollout and experimentation without shipping new binaries.

## Guiding Principles

1. **Safety first** – Default values mirror the in-app constants so a fetch failure preserves the previous behaviour.
2. **Progressive rollout** – Feature flags graduate from 1% → 5% → 20% → 100% when metrics and error budgets remain healthy.
3. **Experiment discipline** – Every experiment key is associated with a Jira ticket and analytics event annotations.

## Configuration Keys

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `notif_morning_default` | string (HH:mm) | `07:30` | Initial local time for the morning reminder. |
| `notif_evening_default` | string (HH:mm) | `20:30` | Initial local time for the evening reminder. |
| `notif_daily_limit` | number | `3` | Upper bound of push notifications per day. |
| `quest_recommendation_variant` | string | `control` | Variant switch for recommended quests (`control`, `nudges`, `focus_mode`). |
| `record_confetti_enabled` | bool | `true` | Kill-switch for the celebration animation. |

## Release Workflow

1. **Authoring** – Infra engineer updates the Remote Config template stored in `infra/remote_config_defaults.json` (tracked in git).
2. **Review** – Pull request adds experiment rationale, expected impact, success metric, and rollback plan.
3. **Publish** – Changes deployed via Firebase CLI (`firebase remoteconfig:versions:list`). Rollback uses `:rollback` to previous
   version ID.
4. **Monitoring** – Dashboard overlays config variant on KPI charts to detect regressions. Alerts trigger if opt-out rate rises >5%.

## Experiment Template

```
Key: quest_recommendation_variant
Variants: control (60%), nudges (20%), focus_mode (20%)
Hypothesis: Nudges increase daily quest completions by +5% without hurting streak retention.
Primary Metric: Daily Quest Completion Rate
Guardrail Metric: Notification opt-out rate
Duration: Minimum 7 days with 95% power
```

## Governance

* Config changes recorded in the release log (see `docs/versioning.md`).
* Emergency disablement playbook references `docs/incident_runbook.md`.
* No personally identifiable data stored in Remote Config values.
