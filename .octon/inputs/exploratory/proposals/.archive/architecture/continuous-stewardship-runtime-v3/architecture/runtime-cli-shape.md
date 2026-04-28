# Runtime and CLI Shape

## New Command Group

```text
octon steward open
octon steward status
octon steward observe
octon steward admit
octon steward idle
octon steward renew
octon steward pause
octon steward resume
octon steward revoke
octon steward close
octon steward ledger
octon steward triggers
octon steward epochs
octon steward decisions
```

## Command Semantics

- `open` creates or verifies a Stewardship Program and first epoch, subject to
  program authority and epoch gates.
- `status` reports program, epoch, budget, breaker, trigger, Decision Request,
  mission handoff, and idle/renewal posture.
- `observe` normalizes supported triggers without admitting work.
- `admit` evaluates triggers and emits Stewardship Admission Decisions.
- `idle` emits or displays Idle Decisions.
- `renew` emits Renewal Decisions and opens a new epoch only when gates pass.
- `pause`, `resume`, `revoke`, and `close` transition stewardship control state.
- `ledger`, `triggers`, `epochs`, and `decisions` inspect canonical state.

## Handoff to v2

When a trigger is admitted as `mission_candidate`, the stewardship runtime must
create or update v1/v2-compatible Engagement / Work Package / Mission candidate
records, then hand off to v2 Mission Runner. It must not directly call material
execution tools.

## Current Runtime Reality Note

At packet generation time, the live repo's observed CLI is run-first in earlier
analysis and the v1/v2 product commands are assumed baseline. Implementation
must recheck live CLI before promotion and add minimal compatibility shims if
required.
