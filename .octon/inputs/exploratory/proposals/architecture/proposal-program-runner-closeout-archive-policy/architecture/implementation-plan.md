# Implementation Plan

_Status: Accepted child packet plan. Not implemented in this task._

## Profile Selection Receipt

- release_state: `pre-1.0`
- change_profile: `atomic`
- rationale: bounded proposal-packet slice with no hard gate requiring a
  transitional compatibility phase.

## Dependency Order

Dependencies: `proposal-program-runner-verification-correction-routing`, `proposal-program-runner-cleanup-hygiene`, `proposal-program-runner-evidence-run-control`.

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

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/prompts/`
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`

## Validation Plan

- Tests cover current policy enforcement for archived/rejected child outcomes and receipt-level requirements.
- Tests cover child archive before parent terminal closeout when required by policy and no forced child archival when a future policy explicitly accepts implemented children.
- Tests cover blocked closeout receipts containing verdict, archive_authorized, selected git route, blocker class, counts, hygiene fingerprint, cleanup summary, and next route condition.

## Rollback

Use `git-revert` rollback. Do not rely on proposal-local files as runtime
truth. If generated outputs drift, regenerate them through canonical publisher
scripts or revert the authored-source change.
