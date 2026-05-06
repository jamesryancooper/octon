# Acceptance Criteria

## Structural Acceptance

- No planning artifact under `inputs/**` or `generated/**` is used as runtime
  authority.
- Durable doctrine and schemas live under `framework/**`.
- Instance enablement lives under `instance/**`.
- Mutable plan state lives under `state/control/**`.
- Plan mutation evidence lives under `state/evidence/**`.
- Generated plan views are derived-only.

## Runtime Acceptance

- A PlanNode cannot directly execute.
- A PlanNode cannot bypass run-contract creation.
- A PlanNode cannot bypass context-pack construction.
- A PlanNode cannot bypass `authorize_execution`.
- A PlanNode cannot widen support targets.
- A PlanNode cannot admit capabilities.
- A PlanNode cannot mutate mission scope without approval.

## Evidence Acceptance

- Every plan revision has a retained evidence record.
- Every compiled leaf has a compile receipt.
- Every authorized execution has run evidence.
- Every plan update after execution cites Run Journal or evidence-store records.
- Every stale plan condition blocks further compile.
- Every rollback updates planning projection without replacing run rollback
  truth.

## Anti-Bloat Acceptance

- Default maximum depth is enforced.
- Rolling-wave limits are enforced.
- Duplicate detection is enforced.
- Dependency cycles are rejected or staged.
- More than two non-useful decomposition passes force execute, block, defer, or
  escalate.
- Future work cannot be decomposed to action-slice level without a risk,
  dependency, approval, rollback, or validation reason.

## Governance Acceptance

- Mission owner approval is required for mission binding or scope mutation.
- Human approval is required for high-risk, irreversible, external,
  protected-zone, support-target, and capability-admission changes.
- Generated dashboards cannot be cited as authority.
- Proposal packet paths cannot remain in promoted runtime targets.

## Rollback Acceptance

- Removing the planning layer leaves mission charters, action slices, run
  contracts, authorization, evidence, rollback, and continuity operational.
- Plan roots can be retired or archived without breaking runtime replay.
- Generated planning projections can be deleted and rebuilt.
- Existing missions and runs remain valid.
