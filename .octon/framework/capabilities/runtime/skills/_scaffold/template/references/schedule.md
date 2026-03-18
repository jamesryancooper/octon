---
# Schedule Documentation (Scheduled Pattern)
# Add this file when a skill is triggered by a timer or recurring schedule.
#
# When to use:
# - Skill runs hourly/daily/weekly on a schedule
# - Skill supports timer-triggered execution windows
# - Skill has schedule-specific guardrails (blackout windows, skip rules)
#
schedule:
  trigger_type: recurring                    # recurring | one-shot | event+timer
  cadence: "{{cadence_description}}"       # e.g., every weekday at 09:00
  timezone: "{{timezone}}"

  constraints:
    blackout_windows:
      - "{{blackout_window_1}}"
    max_runs_per_window: "{{run_cap}}"
    skip_if:
      - "{{skip_condition_1}}"
      - "{{skip_condition_2}}"

  idempotency_window: "{{window}}"        # e.g., 1 hour
  missed_run_policy: "{{policy}}"         # skip | catch-up | enqueue-next
---

# Schedule Reference

**Required when capability:** `scheduled`

Timer/schedule behavior for recurring execution.

## Trigger Configuration

- Trigger type: {{trigger_type}}
- Cadence: {{cadence_description}}
- Timezone: {{timezone}}

## Guardrails

Document blackout windows, skip conditions, and run caps to prevent overload.

## Missed Run Handling

Describe whether missed windows are skipped or replayed.
