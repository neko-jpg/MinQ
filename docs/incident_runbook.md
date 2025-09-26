# Incident Response Runbook

Covers the checklist item "障害対応Runbook" by providing the operational steps for Sev1/Sev2 incidents affecting MinQ.

## Incident Classification

| Severity | Definition | Examples | Response target |
| --- | --- | --- | --- |
| Sev1 | Outage or data loss impacting >30% of users | Login failures, corrupted quest data | Acknowledge in 10 minutes |
| Sev2 | Major degradation with workaround | Push notifications delayed >2h, streak sync lag | Acknowledge in 30 minutes |

## On-call Rotation

* Weekday business hours – Mobile Infra (Ken → Aya → Mei)
* Evenings/Weekends – Shared PagerDuty rotation (`minq-mobile` schedule)

## Response Steps

1. **Alert Intake**
   - Alert sources: Crashlytics, Firebase Monitoring, KPI dashboard anomaly, support escalation.
   - On-call acknowledges PagerDuty alert, posts status in Slack `#minq-incident`.
2. **Triage**
   - Collect logs and correlate with release/Remote Config changes.
   - Determine blast radius and user impact; decide on mitigation vs rollback.
3. **Mitigation**
   - Toggle feature flags, throttle notification senders, or disable matching queue as needed.
   - Communicate workaround instructions to Support for user inquiries.
4. **Resolution**
   - Deploy hotfix build if required (follow `docs/release_process.md` rollback steps).
   - Confirm metrics return to baseline for 30 minutes before closing incident.
5. **Postmortem**
   - Draft incident report within 48 hours including timeline, root cause, impact, corrective actions.
   - Share report in `#minq-postmortems` and store in `drive://MinQ/Incidents`.

## Templates

*Slack update snippet*
```
:rotating_light: Incident Update – <summary>
Severity: Sev1
Start: 2024-07-01 09:12 JST
Impact: <describe>
Mitigation: <actions>
Next update: +30m
```

*Postmortem outline*
1. Summary & impact
2. Timeline (UTC + JST)
3. Root cause analysis (5 Whys)
4. Action items with owners & due dates
5. Lessons learned

## Communication Matrix

| Audience | Channel | Frequency |
| --- | --- | --- |
| Internal stakeholders | Slack `#minq-incident` | Every 30 minutes during Sev1 |
| Support team | Slack `#minq-support` + email | On mitigation + resolution |
| Users | In-app banner / email template | If outage >60 minutes |

## Preventive Measures

* Review monitoring thresholds quarterly (see `docs/monitoring_plan.md`).
* Include incident drills in quarterly chaos exercise.
* Ensure runbook link is part of onboarding for new team members.
