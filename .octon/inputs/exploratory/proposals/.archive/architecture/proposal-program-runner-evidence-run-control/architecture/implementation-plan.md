# Implementation Plan

_Status: Accepted child packet plan. Not implemented in this task._

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: bounded proposal-packet slice with no hard gate requiring a
  transitional compatibility phase.

## Dependency Order

Dependencies: `proposal-program-runner-current-state-gap-map`, `proposal-program-runner-planning-replan-loop`.

## Workstreams

1. Reconfirm the current-state gap map and existing ownership before editing.
2. Update only declared write scopes needed for this child slice.
3. Preserve existing route, validator, workflow, publication, registry,
   cleanup, closeout, archive, disclosure-tier, and run-control ownership.
4. Add focused tests and negative fixtures for the acceptance criteria below.
5. Regenerate generated or registry state only through canonical scripts when
   authored sources require it.
6. Record implementation, conformance, post-implementation drift/churn, and
   validation evidence before promotion, closeout, or archive is considered.

## Write Scopes

- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/engine/runtime/spec/`
- `.octon/framework/constitution/contracts/retention/`
- `.octon/framework/constitution/obligations/evidence.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

## Validation Plan

- Tests cover cancellation during selected route dispatch and no post-cancel dispatch.
- Replay tests cover checkpoint/event divergence, duplicated events, hash-chain breaks, registry digest drift, stale locks, and missing offsets.
- Evidence-tier tests reject raw-copying local evidence into publishable retained evidence and reject hosted gates that require local-only raw evidence.

## Rollback

Use `git-revert` rollback. Do not rely on proposal-local files as runtime
truth. If generated outputs drift, regenerate them through canonical publisher
scripts or revert the authored-source change.
