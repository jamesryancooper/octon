# Automation Policy

Canonical policy guidance for unattended orchestration launches.

## Scope

Applies to automations under `/.octon/orchestration/runtime/automations/`.

## Policy Rules

1. Automations may launch workflows only through bounded orchestration
   admission paths.
2. Automations may not self-authorize privileged actions.
3. Event-triggered launches require:
   - valid watcher event
   - valid bindings
   - idempotency context
   - policy-compliant concurrency state
4. Scheduled launches require:
   - deterministic schedule-window resolution
   - policy-compliant concurrency state
   - idempotency by schedule window
5. `replace` is allowed only when the target workflow declares
   `execution_controls.cancel_safe: true`.

## Evidence Rules

- Every admitted automation launch writes a decision and a run.
- Every blocked or escalated automation launch writes a decision.
- Automation-local state never replaces decision or run evidence.
