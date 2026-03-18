---
# Execution Model Documentation (Long-Running Pattern)
# Add this file when a skill may run for minutes or hours.
#
# When to use:
# - Skill executes long jobs with multiple progress stages
# - Skill relies on polling loops or background wait intervals
# - Skill needs explicit timeout and resume behavior
#
execution_model:
  duration_profile:
    typical: "{{typical_duration}}"      # e.g., 2-5 minutes
    max_expected: "{{max_duration}}"      # e.g., 60 minutes

  progress_reporting:
    mode: checkpoints                       # checkpoints | logs | callback
    interval: "{{progress_interval}}"     # e.g., every 30 seconds
    fields:
      - phase
      - percent_complete
      - current_operation

  polling:
    enabled: true
    interval_seconds: "{{poll_interval}}"
    max_attempts: "{{poll_attempts}}"
    stop_condition: "{{stop_condition}}"

  timeout_behavior:
    hard_timeout: "{{timeout_duration}}"
    on_timeout: "{{abort_or_escalate}}"   # abort | escalate | retry
---

# Execution Model Reference

**Required when capability:** `long-running`

Runtime model for long-running execution.

## Duration Expectations

- Typical run time: {{typical_duration}}
- Maximum expected run time: {{max_duration}}

## Progress Reporting

Document how progress is exposed to users/operators.

| Signal | Source | Frequency |
|--------|--------|-----------|
| {{signal_1}} | {{source}} | {{frequency}} |
| {{signal_2}} | {{source}} | {{frequency}} |

## Polling Behavior

If polling is used, document interval, stop conditions, and backoff strategy.

## Timeout and Recovery

Describe what happens at hard timeout and how to safely resume or retry.
