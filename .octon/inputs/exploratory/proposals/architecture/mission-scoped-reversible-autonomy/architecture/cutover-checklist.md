# Cutover Checklist

This checklist defines the branch-level execution order for the Mission-Scoped
Reversible Autonomy cutover. It is intentionally strict because the proposal's
goal is one big-bang, clean-break, atomic implementation rather than a staged
coexistence model.

## Preconditions

Before implementation starts on the cutover branch:

1. Create the durable migration-plan path:
   `/.octon/instance/cognition/context/shared/migrations/<YYYY-MM-DD>-mission-scoped-reversible-autonomy-cutover/plan.md`
2. Record the release target to publish in `octon.yml`
   (`0.6.0` remains the recommended identifier unless superseded by later
   release planning).
3. Inventory active missions and record whether the registry is still empty or
   whether in-place charter migration is required.
4. Record the rollback method as full revert of the cutover change set rather
   than partial retention of old and new autonomy paths.
5. Keep the branch isolated until all blocking validators pass.

## Atomic Execution Sequence

### 1. Lock The Contract Surfaces

- Finalize the proposal package, artifact catalog, validation plan, cutover
  checklist, and active proposal registry entry.
- Update `octon.yml`, the umbrella architecture specification,
  `runtime-vs-ops-contract.md`, the contract registry, and the canonical
  principle surfaces so the durable repo contract is defined before code
  changes depend on it.

### 2. Upgrade Mission Authority And Repo Policy

- Upgrade the mission registry and mission scaffold to `v2`.
- Add `mission-autonomy.yml` and `instance/governance/ownership/registry.yml`.
- Migrate any active mission artifacts in place on the same branch.

### 3. Upgrade Runtime Contracts And Enforcement

- Add the new mission-control schemas and `v2` execution/policy contracts.
- Update engine config and runtime crates so autonomous execution requires
  mission, slice, mode, and reversibility context.
- Remove or dead-code any legacy autonomous launch path that can proceed
  without the new context.

### 4. Introduce Mission-Scoped Control Truth, Evidence, And Continuity

- Create the mission-scoped control tree under
  `state/control/execution/missions/<mission-id>/`.
- Add `state/evidence/control/execution/**` for control-plane receipts.
- Add mission continuity under `state/continuity/repo/missions/<mission-id>/`.

### 5. Add Supervisory Workflows And Generated Read Models

- Add or update workflows for preview publication, boundary-aware pause,
  safing, rollback/compensation, finalize blocking, and digest routing.
- Add mission `now/next/recent/recover` summaries and operator digests.
- Ensure those outputs are projections only and do not become a second journal.

### 6. Enable Blocking Validation And Scenario Coverage

- Add the validator and test families defined in
  `architecture/validation-plan.md`.
- Make them blocking on the same branch where the live drift is corrected.
- Rebuild and validate the generated cognition outputs that the cutover adds.

### 7. Write Closeout Evidence And Merge Only The Final State

- Write the durable migration plan, retained evidence bundle, and ADR.
- Update bootstrap and README guidance to describe the new operating model as
  current.
- Merge only when the final-state validators are green and no dual model
  remains.

## Merge Gate

Do not merge the branch until all of the following are true:

- proposal artifacts, durable contracts, runtime code, control-state files,
  generated summaries, validators, and closeout evidence all exist together
- no legacy autonomous path survives
- no shadow control store or second activity ledger exists
- generated summaries are sourced only from canonical control, evidence, and
  continuity surfaces
- the rollback plan is still a full-branch revert rather than a partial
  coexistence strategy

## Immediate Post-Merge Checks

Immediately after merge, verify:

1. An autonomous launch without mission context is denied.
2. `STAGE_ONLY` fallback works when promote/finalize prerequisites are
   missing but staging is still safe.
3. Active missions, if any exist, render `now`, `next`, `recent`, and
   `recover` summaries without missing canonical inputs.
4. Control-plane mutations emit control receipts in the new retained evidence
   family.
5. Ownership plus subscription routing produces the expected operator digest
   outputs.

## Rollback Triggers

| Trigger | Required response |
| --- | --- |
| Autonomous execution can still proceed without mission context | Revert the full cutover change set. |
| Mission summaries depend on non-canonical sources or a shadow journal | Revert the full cutover change set. |
| Material control-plane mutations do not emit retained control receipts | Revert the full cutover change set. |
| Active mission migration cannot produce a coherent `v2` charter plus control tree | Stop before merge; do not ship a partial branch. |
| Breaker, safing, or break-glass semantics are incorrect in final-state validation | Revert the full cutover change set. |

## Explicit Anti-Patterns

The cutover checklist rejects these shortcuts:

- shipping docs first and runtime enforcement later
- adding generated mission views before canonical control and evidence exist
- retaining a compatibility path for mission-less autonomous execution
- treating chat comments, UI state, or in-memory agent state as binding control
  truth
- attempting rollback by keeping half-new and half-old autonomy models alive
