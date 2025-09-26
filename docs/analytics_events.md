# Analytics Event Design

Canonical definitions for analytics events referenced in the P0 checklist.

## Event taxonomy

| Event name | Trigger | Parameters | Notes |
| --- | --- | --- | --- |
| `onboarding_complete` | User finishes the final onboarding card. | `method` (`'anonymous' | 'google'`), `duration_seconds`. | Fire once per install. |
| `quest_started` | User accepts or creates a quest. | `quest_id`, `quest_category`, `proof_type` (`'check' | 'photo'`). | Emit for template and custom quests. |
| `record_saved` | Quest proof successfully stored locally and synced. | `quest_id`, `proof_type`, `sync_latency_ms`. | Do not fire on retries to avoid double counting. |
| `streak_n` | Daily streak increments. | `streak_length`. | Fire on celebration screen once per day. |
| `pair_matched` | Pairing flow successfully matches users. | `pair_id`, `match_latency_ms`. | Include `previous_partner` boolean if re-match. |
| `notif_open` | User taps a notification. | `notification_type` (`'morning' | 'evening' | 'aux'`), `quest_id`. | Use notification payload to populate parameters. |

## Implementation guidance

- Use a dedicated `AnalyticsService` wrapper that queues events when offline and flushes when network returns.
- Add unit tests covering parameter validation (e.g. rejecting empty quest IDs).
- Document any new events inside this file and mirror them in the product analytics dashboard.
- Respect user privacy preferences—if a future settings toggle disables analytics, gate all tracking behind it.

## Governance

- Product analytics owner reviews weekly event volume and funnels.
- Engineering adds schema diffs to the `analytics-events` Notion page for cross-team visibility.
- Keep raw event definitions under source control (this file) to avoid drift with BI dashboards.
