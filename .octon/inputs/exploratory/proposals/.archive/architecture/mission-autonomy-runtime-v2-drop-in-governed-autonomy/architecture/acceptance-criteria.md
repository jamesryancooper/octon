# Acceptance Criteria

## Architecture

- v2 primitives are defined and correctly placed.
- No rival control plane is introduced.
- Missions remain continuity containers.
- Runs remain atomic execution units.
- Existing run lifecycle, execution authorization, context-pack, evidence-store, support-target, and generated/effective handle contracts remain intact.

## Runtime

- `octon mission open` opens or verifies mission state from Engagement/Work Package.
- `octon mission continue` enforces Autonomy Window gates.
- Mission Runner selects an Action Slice from Mission Queue.
- Action Slice compiles into a governed run-contract candidate.
- Execution occurs only through existing run lifecycle and authorization paths.
- Mission Runner emits Continuation Decision after each run attempt.
- Mission Queue and Mission Run Ledger update after each run.

## Safety

- No continuation without active scoped lease.
- No continuation when budget is exhausted.
- No continuation when breaker is tripped/latched.
- No continuation with stale context/support/capability posture.
- No connector operation when connector posture has drifted.
- Progress gate prevents repeated failure/churn/unreachable objective.
- Mission closeout requires all relevant runs terminal and closeout-complete.

## Evidence

- Mission evidence bundle exists and references per-run evidence.
- Per-run journals remain the run lifecycle source of truth.
- Mission Run Ledger does not replace run journals.
- Continuation Decisions retain evidence of their inputs.
- Mission closeout retains replay/disclosure/rollback/continuity status.

## Product

- Operator can use `octon continue`, `octon decide`, `octon mission status`, and `octon mission close`.
- Operator can inspect Autonomy Window, Mission Queue, Decision Requests, and mission status.
- Broad external autonomy remains blocked; connector admission is stage-only in v2 MVP.
